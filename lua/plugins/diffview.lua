return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diff Review" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Git Diff Review" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git File History" },
      {
        "<leader>ad",
        "<cmd>DiffviewOpen<cr>",
        desc = "AI Codex: Review File Changes",
      },
      {
        "<leader>aD",
        "<cmd>DiffviewClose<cr>",
        desc = "AI Codex: Close Change Review",
      },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
    },
  },
}
