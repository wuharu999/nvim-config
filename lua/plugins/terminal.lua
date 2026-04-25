return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>tt",
        function()
          Snacks.terminal.focus(nil, {
            cwd = LazyVim.root(),
            win = {
              position = "float",
              width = 0.9,
              height = 0.85,
              border = "rounded",
              title = " Terminal ",
              title_pos = "center",
            },
          })
        end,
        desc = "Terminal (Floating Root)",
        mode = { "n", "t" },
      },
    },
    opts = {
      terminal = {
        win = {
          keys = {
            esc = { "<esc>", "hide", mode = "n", desc = "Hide Terminal" },
            q = "hide",
          },
        },
      },
    },
  },
}
