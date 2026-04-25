return {
  {
    "kkrampis/codex.nvim",
    cmd = { "Codex", "CodexToggle" },
    keys = {
      {
        "<leader>ac",
        function()
          require("codex").toggle()
        end,
        desc = "AI Codex: Toggle Panel",
        mode = { "n", "t" },
      },
      {
        "<leader>aC",
        function()
          require("codex").open()
        end,
        desc = "AI Codex: Focus Panel",
        mode = { "n", "t" },
      },
    },
    opts = {
      cmd = "codex",
      autoinstall = true,
      panel = true,
      use_buffer = false,
      width = 0.38,
      keymaps = {
        toggle = nil,
        quit = "<C-q>",
      },
    },
    config = function(_, opts)
      require("codex").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_codex_panel", { clear = true }),
        pattern = "codex",
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], {
            buffer = event.buf,
            desc = "AI Codex: Focus Code Left",
            silent = true,
          })
          vim.keymap.set("n", "<C-h>", "<C-w>h", {
            buffer = event.buf,
            desc = "AI Codex: Focus Code Left",
            silent = true,
          })
        end,
      })
    end,
  },
}
