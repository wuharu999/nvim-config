return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "toggle floating terminal" },
      { "<leader>tb", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "toggle bottom terminal" },
      { "<leader>tc", "<cmd>lua _CodexToggle()<cr>", desc = "toggle codex terminal" },
    },
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        direction = "float",
        close_on_exit = false,
        float_opts = {
          border = "curved",
          width = function()
            return math.floor(vim.o.columns * 0.9)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.8)
          end,
        },
      })

      local Terminal = require("toggleterm.terminal").Terminal

      local codex = Terminal:new({
        cmd = "codex",
        direction = "float",
        hidden = true,
        close_on_exit = false,
        float_opts = {
          border = "curved",
          width = function()
            return math.floor(vim.o.columns * 0.9)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.85)
          end,
        },
      })

      function _CodexToggle()
        codex:toggle()
      end
    end,
  },
}
