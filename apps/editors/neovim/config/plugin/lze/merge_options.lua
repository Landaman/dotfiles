local function extend_path(path, key)
  local next_path = vim.list_slice(path)
  table.insert(next_path, key)
  return next_path
end

local function should_extend(path, extend)
  for _, candidate in ipairs(extend) do
    if #candidate == #path then
      local matches = true
      for index, segment in ipairs(candidate) do
        if segment ~= path[index] then
          matches = false
          break
        end
      end
      if matches then
        return true
      end
    end
  end
  return false
end

local function is_list(table_value)
  local count = 0
  for key, _ in pairs(table_value) do
    if type(key) ~= "number" then
      return false
    end
    count = count + 1
  end
  return count == #table_value
end

local function merge_list(target, source)
  for _, item in ipairs(source) do
    table.insert(target, item)
  end
end

local function merge_into(target, source, path, extend)
  if type(source) == "function" then
    source = source()
  end

  if type(source) ~= "table" then
    return target
  end

  if should_extend(path, extend) and is_list(target) and is_list(source) then
    merge_list(target, source)
    return target
  end

  for key, value in pairs(source) do
    local child_path = extend_path(path, key)
    if should_extend(child_path, extend) and type(target[key]) == "table" and type(value) == "table" then
      merge_list(target[key], value)
    elseif should_extend(child_path, extend) and target[key] == nil and type(value) == "table" then
      target[key] = {}
      merge_list(target[key], value)
    elseif type(target[key]) == "table" and type(value) == "table" then
      if is_list(target[key]) and is_list(value) then
        target[key] = value
      else
        merge_into(target[key], value, child_path, extend)
      end
    else
      target[key] = value
    end
  end

  return target
end

return function(fragments, extend)
  local opts = {}
  for _, fragment in ipairs(fragments) do
    merge_into(opts, fragment, {}, extend or {})
  end
  return opts
end
