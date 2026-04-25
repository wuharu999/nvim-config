return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
      on_colors = function(colors)
        colors.bg = "#16161e"
        colors.bg_dark = "#11111a"
        colors.bg_float = "#11111a"
        colors.bg_sidebar = "#11111a"
        colors.bg_statusline = "#11111a"
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
