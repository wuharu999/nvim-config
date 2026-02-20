return {
  {
    -- GitHub Copilot inline completions for Neovim
    "github/copilot.vim",
    event = "InsertEnter", -- Lazy-load when entering insert mode
    init = function()
      -- Keep normal <Tab> behavior; do not let Copilot map Tab
      vim.g.copilot_no_tab_map = true

      -- Enable Copilot inline suggestions in all filetypes (including comments)
      vim.g.copilot_filetypes = {
        ["*"] = true,
      }
    end,
    keys = {
      -- Accept current ghost suggestion with Ctrl+l
      {
        "<C-l>",
        'copilot#Accept("<CR>")',
        mode = "i",
        expr = true,
        replace_keycodes = false,
        desc = "Copilot: Accept suggestion",
      },

      -- Recommended inline-suggestion controls
      { "<M-]>", "<Plug>(copilot-next)", mode = "i", desc = "Copilot: Next suggestion" },
      { "<M-[>", "<Plug>(copilot-previous)", mode = "i", desc = "Copilot: Previous suggestion" },
      { "<C-]>", "<Plug>(copilot-dismiss)", mode = "i", desc = "Copilot: Dismiss suggestion" },
      { "<M-l>", "<Plug>(copilot-accept-line)", mode = "i", desc = "Copilot: Accept line" },
      { "<M-w>", "<Plug>(copilot-accept-word)", mode = "i", desc = "Copilot: Accept word" },
    },
  },
}
