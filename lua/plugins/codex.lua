return {
  {
    "kkrampis/codex.nvim",
    cmd = { "Codex", "CodexToggle" },
    keys = {
      {
        "<leader>ac",
        function()
          require("user.codex").toggle()
        end,
        desc = "AI Codex: Toggle Panel",
        mode = { "n", "t" },
      },
      {
        "<leader>aC",
        function()
          require("user.codex").focus()
        end,
        desc = "AI Codex: Focus Panel/Code",
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

      local user_codex = {}

      local function is_codex_buf(buf)
        return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "codex"
      end

      local function start_codex_insert()
        vim.schedule(function()
          local buf = vim.api.nvim_get_current_buf()
          if is_codex_buf(buf) and vim.bo[buf].buftype == "terminal" then
            vim.cmd.startinsert()
          end
        end)
      end

      function user_codex.toggle()
        require("codex").toggle()
        start_codex_insert()
      end

      function user_codex.focus()
        if vim.bo.filetype == "codex" then
          pcall(vim.cmd.wincmd, "p")
          return
        end

        require("codex").open()
        start_codex_insert()
      end

      package.loaded["user.codex"] = user_codex

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

      vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
        group = vim.api.nvim_create_augroup("user_codex_terminal_insert", { clear = true }),
        callback = function(event)
          if is_codex_buf(event.buf) then
            start_codex_insert()
          end
        end,
      })
    end,
  },
}
