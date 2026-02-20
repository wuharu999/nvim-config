local function list_insert_unique(list, item)
  if not vim.tbl_contains(list, item) then
    table.insert(list, item)
  end
end

local function split_env_paths(value)
  local out = {}
  for p in string.gmatch(value or "", "([^:]+)") do
    if p ~= "" then
      table.insert(out, p)
    end
  end
  return out
end

local function ros2_python_extra_paths(root_dir)
  local paths = {}

  local function add(path)
    if path and path ~= "" and vim.fn.isdirectory(path) == 1 and not vim.tbl_contains(paths, path) then
      table.insert(paths, path)
    end
  end

  local function add_site_packages(prefix)
    for _, site in ipairs(vim.fn.glob(prefix .. "/lib/python*/site-packages", true, true)) do
      add(site)
    end
  end

  if root_dir and root_dir ~= "" then
    add(root_dir .. "/src")
    add(root_dir .. "/install")

    for _, install_prefix in ipairs(vim.fn.glob(root_dir .. "/install/*", true, true)) do
      add(install_prefix)
      add_site_packages(install_prefix)
    end
  end

  for _, prefix in ipairs(split_env_paths(vim.env.AMENT_PREFIX_PATH)) do
    add(prefix)
    add_site_packages(prefix)
  end

  for _, p in ipairs(split_env_paths(vim.env.PYTHONPATH)) do
    add(p)
  end

  return paths
end

local function detect_compile_commands_dir(root_dir)
  if not root_dir or root_dir == "" then
    return nil
  end

  local root_cc = root_dir .. "/compile_commands.json"
  if vim.fn.filereadable(root_cc) == 1 then
    return root_dir
  end

  local build_candidates = vim.fn.glob(root_dir .. "/build/**/compile_commands.json", true, true)
  if #build_candidates > 0 then
    return vim.fn.fnamemodify(build_candidates[1], ":h")
  end

  return nil
end

local function codex_cmd()
  local script = [=[
set -euo pipefail
ROOT="$(git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG="$ROOT/.codex-config"
MODEL=""
if [ -f "$CONFIG" ]; then
  MODEL=$(sed -n 's/^[[:space:]]*model[[:space:]]*=[[:space:]]*//p' "$CONFIG" | head -n 1 | tr -d '"' | tr -d "'")
fi
if [ -z "$MODEL" ]; then
  MODEL="codex-mini-latest"
  if [ ! -f "$CONFIG" ]; then
    printf 'model="%s"\n' "$MODEL" > "$CONFIG"
  elif ! grep -q '^[[:space:]]*model[[:space:]]*=' "$CONFIG"; then
    printf '\nmodel="%s"\n' "$MODEL" >> "$CONFIG"
  fi
fi
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME"
INSTR_DIR="$CODEX_HOME/project_instructions"
mkdir -p "$INSTR_DIR"
INSTR_FILE="$INSTR_DIR/$(printf '%s' "$ROOT" | sed 's/[^A-Za-z0-9]/_/g').md"
{
  echo "# Project context"
  echo "Project root: $ROOT"
  echo ""
  echo "Top-level entries:"
  ls -a "$ROOT"
  if [ -f "$ROOT/AGENTS.md" ]; then
    echo ""
    echo "## AGENTS.md"
    cat "$ROOT/AGENTS.md"
  fi
  if [ -f "$ROOT/README.md" ]; then
    echo ""
    echo "## README.md"
    cat "$ROOT/README.md"
  fi
} > "$INSTR_FILE"
RESUME_MODE=""
if [ -f "$CONFIG" ]; then
  RESUME_MODE=$(sed -n 's/^[[:space:]]*resume[[:space:]]*=[[:space:]]*//p' "$CONFIG" | head -n 1 | tr -d '"' | tr -d "'")
fi
if codex resume --help >/dev/null 2>&1; then
  if [ "$RESUME_MODE" = "last" ] || [ "$RESUME_MODE" = "true" ] || [ "$RESUME_MODE" = "1" ]; then
    exec codex resume --last
  fi
fi
exec codex --full-auto -m "$MODEL" -c "model_instructions_file=\"$INSTR_FILE\""
]=]

  return { "bash", "-lc", script }
end

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
        desc = "Codex: Toggle",
        mode = { "n", "t" },
      },
    },
    opts = {
      cmd = codex_cmd(),
      panel = true,
      keymaps = {
        toggle = nil,
      },
    },
    config = function(_, opts)
      require("codex").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "codex",
        callback = function()
          pcall(vim.cmd, "wincmd H")
        end,
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      list_insert_unique(opts.ensure_installed, "pyright")
      list_insert_unique(opts.ensure_installed, "clangd")
    end,
  },

  {
    "tzachar/cmp-ai",
    event = "InsertEnter",
    enabled = function()
      return vim.env.OPENAI_API_KEY ~= nil and vim.env.OPENAI_API_KEY ~= ""
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.compat",
    },
    config = function()
      local ok, cmp_ai = pcall(require, "cmp_ai.config")
      if not ok then
        return
      end

      cmp_ai:setup({
        max_lines = 200,
        provider = "OpenAI",
        provider_options = {
          model = "codex-mini-latest",
        },
        notify = false,
        run_on_every_keystroke = false,
        ignored_file_types = {
          TelescopePrompt = true,
          prompt = true,
        },
      })
    end,
  },

  {
    "saghen/blink.compat",
    optional = true,
    opts = {},
  },

  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      "saghen/blink.compat",
      "tzachar/cmp-ai",
    },
    opts = function(_, opts)
      if not (vim.env.OPENAI_API_KEY ~= nil and vim.env.OPENAI_API_KEY ~= "") then
        return
      end

      opts.sources = opts.sources or {}
      opts.sources.compat = opts.sources.compat or {}
      list_insert_unique(opts.sources.compat, "cmp_ai")

      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      list_insert_unique(opts.sources.default, "cmp_ai")

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.cmp_ai = vim.tbl_deep_extend("force", opts.sources.providers.cmp_ai or {}, {
        name = "AI",
        module = "blink.compat.source",
        score_offset = 80,
      })

      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-y>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      })

      opts.cmdline = vim.tbl_deep_extend("force", opts.cmdline or {}, {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<C-Space>"] = { "show", "fallback" },
          ["<C-y>"] = { "select_and_accept", "fallback" },
          ["<CR>"] = { "accept_and_enter", "fallback" },
        },
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = true },
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers["*"] = opts.servers["*"] or {}

      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        opts.servers["*"].capabilities = blink.get_lsp_capabilities(opts.servers["*"].capabilities or {})
      else
        local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if ok_cmp then
          opts.servers["*"].capabilities =
            vim.tbl_deep_extend("force", opts.servers["*"].capabilities or {}, cmp_nvim_lsp.default_capabilities())
        end
      end

      opts.servers.pyright = vim.tbl_deep_extend("force", opts.servers.pyright or {}, {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.python = config.settings.python or {}
          config.settings.python.analysis = config.settings.python.analysis or {}
          config.settings.python.analysis.extraPaths = ros2_python_extra_paths(config.root_dir)
        end,
      })

      opts.servers.clangd = vim.tbl_deep_extend("force", opts.servers.clangd or {}, {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=never",
        },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern("compile_commands.json", "compile_flags.txt", "package.xml", "CMakeLists.txt", ".git")(fname)
            or util.find_git_ancestor(fname)
        end,
        on_new_config = function(new_config, root_dir)
          local cc_dir = detect_compile_commands_dir(root_dir)
          if not cc_dir then
            return
          end

          new_config.cmd = new_config.cmd or { "clangd" }
          for i = #new_config.cmd, 1, -1 do
            if new_config.cmd[i]:match("^%-%-compile%-commands%-dir=") then
              table.remove(new_config.cmd, i)
            end
          end
          table.insert(new_config.cmd, "--compile-commands-dir=" .. cc_dir)
        end,
      })
    end,
  },
}
