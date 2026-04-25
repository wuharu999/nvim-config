return {
  {
    "gen740/SmoothCursor.nvim",
    event = "VeryLazy",
    config = function()
      require("smoothcursor").setup({
        type = "default",
        autostart = true,
        fancy = {
          enable = true,
          head = { cursor = ">", texthl = "SmoothCursor" },
          body = {
            { cursor = "o", texthl = "SmoothCursorRed" },
            { cursor = "o", texthl = "SmoothCursorOrange" },
            { cursor = "*", texthl = "SmoothCursorYellow" },
            { cursor = "*", texthl = "SmoothCursorGreen" },
            { cursor = ".", texthl = "SmoothCursorAqua" },
            { cursor = ".", texthl = "SmoothCursorBlue" },
            { cursor = ".", texthl = "SmoothCursorPurple" },
          },
          tail = { cursor = nil, texthl = "SmoothCursor" },
        },
        speed = 25,
        intervals = 35,
        priority = 10,
        threshold = 1,
        flyin_effect = nil,
        disable_float_win = true,
        disabled_filetypes = {
          "snacks_dashboard",
          "snacks_terminal",
          "TelescopePrompt",
        },
      })
    end,
  },

  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = true,
      cursor_scrolls_alone = true,
      duration_multiplier = 0.7,
      easing = "quadratic",
      mappings = {
        "<C-u>",
        "<C-d>",
        "<C-b>",
        "<C-f>",
        "<C-y>",
        "<C-e>",
        "zt",
        "zz",
        "zb",
      },
    },
  },
}
