local M = {}

function M.beforeAll()
	local f = vim.fn.expand("%:p")
	if vim.fn.isdirectory(f) ~= 0 then
		require("lze").trigger_load({ "oil.nvim" })
		return
	end

	local augroup = vim.api.nvim_create_augroup("Oil_lazy_hijack_netrw", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		desc = "Start Oil when a directory is loaded",
		callback = function()
			local event_f = vim.fn.expand("%:p")
			if vim.fn.isdirectory(event_f) ~= 0 then
				require("lze").trigger_load({ "oil.nvim" })
				vim.api.nvim_del_augroup_by_id(augroup)
			end
		end,
	})
end

function M.open()
	if require("oil").get_current_dir() ~= nil then
		return
	end

	require("oil").open()
end

function M.after(opts)
	local oil_git_augroup = vim.api.nvim_create_augroup("oil-git", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		group = oil_git_augroup,
		pattern = { "oil" },
		callback = function()
			local buffer = vim.api.nvim_get_current_buf()
			vim.api.nvim_create_autocmd("BufWritePost", {
				callback = function()
					opts.refresh_filesystem_status()
					if buffer == vim.api.nvim_get_current_buf() then
						return
					end

					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(buffer) then
							return
						end

						local mutator = require("oil.mutator")
						if vim.bo[buffer].modified or vim.b[buffer].oil_dirty or mutator.is_mutating() then
							return
						end

						for _, winid in ipairs(vim.api.nvim_list_wins()) do
							if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == buffer then
								require("oil.view").render_buffer_async(buffer)
								return
							end
						end

						vim.b[buffer].oil_dirty = {}
					end)
				end,
			})
		end,
	})

	require("oil").setup(opts)
	require("oil.columns").register("git", opts.git_column)
end

local function set_highlights()
	vim.api.nvim_set_hl(0, "OilGitUntracked", { fg = "#bb9af7" })
	vim.api.nvim_set_hl(0, "OilGitConflict", { fg = "#ff8700", bold = true, italic = true })
	vim.api.nvim_set_hl(0, "OilGitUnstaged", { link = "OilGitConflict" })
	vim.api.nvim_set_hl(0, "OilGitModified", { fg = "#ff9e64" })
	vim.api.nvim_set_hl(0, "OilGitRenamed", { link = "OilGitModified" })
	vim.api.nvim_set_hl(0, "OilGitStaged", { fg = "#73daca" })
	vim.api.nvim_set_hl(0, "OilGitAdded", { link = "GitSignsAdd" })
end

local function parse_output(proc)
	local result = proc:wait()
	local ret = {}
	if result.code ~= 0 then
		return ret
	end

	for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
		line = line:gsub("/$", "")
		local line_split = vim.split(line, "\t")
		if #line_split == 1 then
			ret[line] = true
			local item_split = vim.split(line, "/")
			if #item_split > 1 then
				ret[item_split[1]] = "dir"
			end
		else
			local status = line_split[1]:sub(1, 1)
			local item = #line_split == 2 and line_split[2] or line_split[3]
			local item_split = vim.split(item, "/")
			ret[item_split[1]] = #item_split == 1 and { status = status } or { status = "M" }
		end
	end

	return ret
end

local function new_filesystem_status()
	return setmetatable({}, {
		__index = function(self, key)
			local ret = {
				ignored = parse_output(
					vim.system(
						{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
						{ cwd = key, text = true }
					)
				),
				tracked = parse_output(
					vim.system({ "git", "ls-tree", "HEAD", "--name-only" }, { cwd = key, text = true })
				),
				untracked = parse_output(
					vim.system(
						{ "git", "ls-files", "--others", "--exclude-standard", "--directory", "--no-empty-directory" },
						{ cwd = key, text = true }
					)
				),
				staged = parse_output(
					vim.system({ "git", "diff", "--staged", "--name-status", "--relative" }, { cwd = key, text = true })
				),
				unstaged = parse_output(
					vim.system({ "git", "diff", "--name-status", "--relative" }, { cwd = key, text = true })
				),
				fd_unrestricted = parse_output(
					vim.system({ "fd", "-uuu", "--exclude=.git/", "--exclude=.DS_Store" }, { cwd = key, text = true })
				),
				fd = parse_output(
					vim.system(
						{ "fd", "--hidden", "--exclude=.git/", "--exclude=.DS_Store" },
						{ cwd = key, text = true }
					)
				),
			}

			rawset(self, key, ret)
			return ret
		end,
	})
end

local function status_highlight(filesystem_status, dir, name, is_hidden)
	if is_hidden or filesystem_status[dir].ignored[name] == true then
		return "OilHidden"
	end

	if filesystem_status[dir].untracked["."] == true then
		return "OilGitUntracked"
	end

	if filesystem_status[dir].untracked[name] then
		if filesystem_status[dir].untracked[name] == true then
			return "OilGitUntracked"
		end
		assert(filesystem_status[dir].untracked[name] == "dir")
		return "OilGitModified"
	end

	local status = nil
	if filesystem_status[dir].unstaged[name] then
		status = filesystem_status[dir].unstaged[name].status
	elseif filesystem_status[dir].staged[name] then
		status = filesystem_status[dir].staged[name].status
	end

	if
		status == "A"
		or status == "C"
		or status == "T"
		or (status == "M" and not filesystem_status[dir].tracked[name])
	then
		return "OilGitAdded"
	elseif status == "M" then
		return "OilGitModified"
	elseif status == "R" then
		return "OilGitRenamed"
	elseif status == "U" then
		return "OilGitConflict"
	elseif status ~= nil then
		assert(false)
	end

	return nil
end

local function status_icon(highlight, staged)
	if highlight == "OilGitUntracked" then
		return { " ", highlight }
	elseif highlight == "OilGitModified" or highlight == "OilGitRenamed" then
		return staged and { " ", "OilGitStaged" } or { "󰄱 ", highlight }
	elseif highlight == "OilGitAdded" then
		return { " ", highlight }
	elseif highlight == "OilGitConflict" then
		return { " ", highlight }
	elseif highlight == "OilHidden" then
		return { " ", highlight }
	end

	return nil
end

function M.opts()
	set_highlights()

	local filesystem_status = new_filesystem_status()
	local refresh = require("oil.actions").refresh
	local orig_refresh = refresh.callback
	refresh.callback = function(...)
		filesystem_status = new_filesystem_status()
		orig_refresh(...)
	end

	local detail = false
	local git_column = {
		render = function(entry, _, bufnr)
			local dir = require("oil").get_current_dir(bufnr)
			if not dir then
				return nil
			end

			local name = entry[2]
			local staged = filesystem_status[dir].staged[name] ~= nil
			return status_icon(status_highlight(filesystem_status, dir, name, false), staged)
		end,
		parse = function(line)
			return line:match("^([^%s]*)%s+(.*)$")
		end,
	}

	return {
		refresh_filesystem_status = function()
			filesystem_status = new_filesystem_status()
		end,
		git_column = git_column,
		watch_for_changes = true,
		default_file_explorer = true,
		columns = { "icon", "git" },
		constrain_cursor = "name",
		view_options = {
			show_hidden = true,
			is_hidden_file = function(name, bufnr)
				local dir = require("oil").get_current_dir(bufnr)
				return dir and not filesystem_status[dir].fd[name] or false
			end,
			is_always_hidden = function(name, bufnr)
				local dir = require("oil").get_current_dir(bufnr)
				if name == ".." then
					return true
				end
				return dir and not filesystem_status[dir].fd_unrestricted[name] or false
			end,
			highlight_filename = function(entry, is_hidden, _, _, bufnr)
				local dir = require("oil").get_current_dir(bufnr)
				if not dir then
					return nil
				end
				return status_highlight(filesystem_status, dir, entry.name, is_hidden)
			end,
		},
		keymaps = {
			gd = {
				desc = "Toggle file detail view",
				callback = function()
					detail = not detail
					if detail then
						require("oil").set_columns({
							"icon",
							{ "permissions", highlight = "OilHidden" },
							{ "size", highlight = "OilHidden" },
							{ "mtime", highlight = "OilHidden" },
							"git",
						})
					else
						require("oil").set_columns({ "icon", "git" })
					end
				end,
			},
		},
	}
end

return M
