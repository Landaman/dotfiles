---Use the debugpy adapter supplied on PATH by Nix or Mason
return function()
  require("dap-python").setup("debugpy-adapter")
end
