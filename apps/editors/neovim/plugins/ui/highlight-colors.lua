local M = {}

local function color_item(ctx)
  if ctx.item.source_name ~= "LSP" then
    return nil
  end

  return require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
end

function M.blinkOpts()
  return {
    completion = {
      menu = {
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local icon = ctx.kind_icon
                local item = color_item(ctx)
                if item and item.abbr ~= "" then
                  icon = item.abbr
                end
                return icon .. ctx.icon_gap
              end,
              highlight = function(ctx)
                local highlight = "BlinkCmpKind" .. ctx.kind
                local item = color_item(ctx)
                if item and item.abbr_hl_group then
                  highlight = item.abbr_hl_group
                end
                return highlight
              end,
            },
          },
        },
      },
    },
  }
end

return M
