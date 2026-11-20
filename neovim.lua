-- hexafunk for Neovim: aether.nvim (Omarchy's default engine) for the UI and
-- plugin coverage, with explicit overrides so the syntax roles match the
-- hexafunk spec instead of aether's defaults (purple keywords, orange
-- numbers, plain-fg operators).

local P = {
  bg0_h = "#181915", bg0 = "#23241e", bg0_s = "#2d2e26", bg1 = "#36382e",
  bg2 = "#494b3f", bg3 = "#5f6151", bg4 = "#747864", gray = "#8e927c",
  fg0 = "#f5f1ea", fg1 = "#eee8df", fg2 = "#d4ccc1", fg3 = "#bcb4a9", fg4 = "#a59d93",
  pink = "#ff79bc", pink_dim = "#c41a6e",
  teal = "#00f0d0", teal_dim = "#19c9b0",
  red = "#ff7370", red_dim = "#d94545",
  green = "#afb87a", green_dim = "#8f9a5a",
  yellow = "#fbc956", yellow_dim = "#d6a22e",
  blue = "#3eafcc", blue_dim = "#2b8fab",
  purple = "#c297ed", purple_dim = "#9a6fd0",
  orange = "#fa984c", orange_dim = "#d9762a",
}

-- Syntax roles. Everything below is built from these.
local R = {
  comment  = { fg = P.gray, italic = true },
  keyword  = { fg = P.pink, italic = true },
  func     = { fg = P.teal },
  string   = { fg = P.green },
  type     = { fg = P.yellow },
  variable = { fg = P.blue },
  number   = { fg = P.purple },   -- numbers, booleans, constants, built-ins
  operator = { fg = P.orange },
  punct    = { fg = P.fg3 },
}

-- Dashboard logo: bright teal fading to a deep teal, top to bottom (bright
-- end on top, like the window border). Same hue throughout, so no muddy
-- middle. One highlight group per step: HexafunkHeader1..N.
local HEADER_STEPS = 6
local HEADER_FROM, HEADER_TO = "#00f0d0", "#0e8a78"
local function mix(a, b, t)
  local function ch(h, i) return tonumber(h:sub(i, i + 1), 16) end
  local out = "#"
  for _, i in ipairs({ 2, 4, 6 }) do
    out = out .. string.format("%02x", math.floor(ch(a, i) + (ch(b, i) - ch(a, i)) * t + 0.5))
  end
  return out
end

local function syntax_overrides(hl, c)
  local function set(groups, spec)
    for _, g in ipairs(groups) do
      hl[g] = vim.deepcopy(spec)
    end
  end

  -- Vim legacy groups (also what most plugins link to)
  set({ "Comment", "SpecialComment", "@comment", "@lsp.type.comment.documentation" }, R.comment)
  set({ "Keyword", "Statement", "Conditional", "Repeat", "Exception", "Label",
        "Include", "Define", "PreProc", "PreCondit", "StorageClass" }, R.keyword)
  set({ "Function", "Macro" }, R.func)
  set({ "String", "Character" }, R.string)
  set({ "Type", "Typedef", "Structure" }, R.type)
  set({ "Identifier" }, R.variable)
  set({ "Number", "Float", "Boolean", "Constant", "Special", "SpecialChar", "Debug" }, R.number)
  set({ "Operator" }, R.operator)
  set({ "Delimiter" }, R.punct)
  hl.Tag = { fg = P.pink }
  hl.Todo = { fg = P.bg0_h, bg = P.yellow, bold = true }

  -- Treesitter: keywords (pink)
  set({ "@keyword", "@keyword.function", "@keyword.return", "@keyword.conditional",
        "@keyword.conditional.ternary", "@keyword.repeat", "@keyword.exception",
        "@keyword.import", "@keyword.coroutine", "@keyword.storage", "@keyword.modifier",
        "@keyword.type", "@keyword.directive", "@keyword.directive.define", "@keyword.debug",
        "@type.qualifier", "@label", "@tag", "@tag.builtin" }, R.keyword)
  -- word operators (and / or / not / in / typeof) are operators, not keywords
  set({ "@operator", "@keyword.operator" }, R.operator)

  -- functions (teal); built-in functions are built-ins (purple)
  set({ "@function", "@function.call", "@function.method", "@function.method.call",
        "@function.macro", "@attribute", "@attribute.builtin", "@annotation" }, R.func)
  set({ "@function.builtin" }, R.number)

  -- strings (green)
  set({ "@string", "@string.special", "@string.documentation", "@character" }, R.string)
  hl["@string.escape"] = { fg = P.purple }
  hl["@string.regexp"] = { fg = P.orange }
  hl["@character.special"] = { fg = P.purple }
  hl["@character.printf"] = { fg = P.purple }
  hl["@string.special.url"] = { fg = P.blue, underline = true }
  hl["@string.special.path"] = { fg = P.blue }
  hl["@string.special.symbol"] = { fg = P.purple }

  -- types (yellow). @type.builtin (int, str, bool) stays a type, not a built-in.
  set({ "@type", "@type.builtin", "@type.definition", "@constructor" }, R.type)
  hl["@constructor.lua"] = R.punct -- lua's `{}` table constructor is punctuation

  -- variables (blue), incl. members, params, properties, modules (paths)
  set({ "@variable", "@variable.member", "@variable.parameter", "@property",
        "@module", "@tag.attribute", "@label.json" }, R.variable)
  -- self / this / builtin params are built-ins (purple)
  set({ "@variable.builtin", "@variable.parameter.builtin", "@module.builtin",
        "@namespace.builtin" }, R.number)

  -- numbers, booleans, constants (purple)
  set({ "@number", "@number.float", "@boolean", "@constant", "@constant.builtin",
        "@constant.macro" }, R.number)

  -- punctuation (fg3)
  set({ "@punctuation.bracket", "@punctuation.delimiter", "@tag.delimiter" }, R.punct)
  hl["@punctuation.special"] = { fg = P.orange }

  -- comment annotations
  hl["@comment.todo"] = { fg = P.bg0_h, bg = P.yellow, bold = true }
  hl["@comment.warning"] = { fg = P.bg0_h, bg = P.yellow_dim, bold = true }
  hl["@comment.error"] = { fg = P.bg0_h, bg = P.red, bold = true }
  hl["@comment.note"] = { fg = P.bg0_h, bg = P.teal_dim, bold = true }
  hl["@comment.hint"] = { fg = P.teal_dim }
  hl["@comment.info"] = { fg = P.blue }

  -- markup
  hl["@markup.heading"] = { fg = P.pink, bold = true }
  hl["@markup.link"] = { fg = P.blue }
  hl["@markup.link.url"] = { fg = P.blue, underline = true }
  hl["@markup.link.label"] = { fg = P.teal }
  hl["@markup.raw"] = { fg = P.green }
  hl["@markup.raw.markdown_inline"] = { fg = P.green, bg = P.bg1 }
  hl["@markup.list"] = { fg = P.orange }
  hl["@markup.list.markdown"] = { fg = P.orange, bold = true }
  hl["@markup.quote"] = { fg = P.gray, italic = true }
  hl["@markup.strong"] = { bold = true }
  hl["@markup.italic"] = { italic = true }

  -- LSP semantic tokens. These win over Treesitter, so each one is set
  -- explicitly rather than inheriting aether's links.
  local L = {
    keyword = R.keyword, modifier = R.keyword,
    ["function"] = R.func, method = R.func, macro = R.func, decorator = R.func,
    string = R.string, regexp = { fg = P.orange },
    type = R.type, class = R.type, enum = R.type, interface = R.type, struct = R.type,
    typeParameter = R.type, builtinType = R.type, typeAlias = R.type,
    variable = R.variable, parameter = R.variable, property = R.variable,
    namespace = R.variable, event = R.variable,
    number = R.number, boolean = R.number, enumMember = R.number,
    selfKeyword = R.number, selfParameter = R.number, clsParameter = R.number,
    operator = R.operator,
  }
  for token, spec in pairs(L) do
    hl["@lsp.type." .. token] = vim.deepcopy(spec)
  end
  -- Let Treesitter's comment highlighting (TODO/FIXME) show through.
  hl["@lsp.type.comment"] = {}
  hl["@lsp.typemod.function.defaultLibrary"] = R.number
  hl["@lsp.typemod.method.defaultLibrary"] = R.number
  hl["@lsp.typemod.variable.defaultLibrary"] = R.number
  hl["@lsp.typemod.variable.readonly"] = R.number
  hl["@lsp.typemod.variable.static"] = R.number
  hl["@lsp.typemod.keyword.async"] = R.keyword
  hl["@lsp.mod.deprecated"] = { strikethrough = true }

  -- Editor UI
  hl.CursorLine = { bg = P.bg1 }
  hl.CursorColumn = { bg = P.bg1 }
  hl.ColorColumn = { bg = P.bg0_s }
  hl.CursorLineNr = { fg = P.pink, bold = true }
  hl.LineNr = { fg = P.bg4 }
  -- Selection is the pink-dim block with linen text forced on top. Without
  -- the fg, pink keywords drop to 2.3:1 on it.
  hl.Visual = { bg = P.pink_dim, fg = P.fg0 }
  hl.VisualNOS = { bg = P.pink_dim, fg = P.fg0 }
  hl.Search = { bg = P.yellow_dim, fg = P.bg0_h }
  hl.IncSearch = { bg = P.teal, fg = P.bg0_h, bold = true }
  hl.CurSearch = { bg = P.teal, fg = P.bg0_h, bold = true }
  hl.Substitute = { bg = P.orange, fg = P.bg0_h }
  hl.MatchParen = { fg = P.orange, bg = P.bg2, bold = true }
  -- Directories: teal-dim, matching eza's `ll` and the prompt (code
  -- variables stay blue).
  hl.Directory = { fg = P.teal_dim, bold = true }
  hl.NeoTreeDirectoryIcon = { fg = P.teal_dim }
  hl.NeoTreeDirectoryName = { fg = P.teal_dim }
  hl.NeoTreeRootName = { fg = P.teal_dim, bold = true }
  hl.NvimTreeRootFolder = { fg = P.teal_dim, bold = true }
  hl.NvimTreeFolderIcon = { fg = P.teal_dim }
  hl.NvimTreeFolderName = { fg = P.teal_dim }
  hl.TelescopeResultsDirectory = { fg = P.teal_dim, bold = true }
  hl.SnacksPickerDirectory = { fg = P.teal_dim, bold = true }
  hl.BlinkCmpKindFolder = { fg = P.teal_dim }
  hl.Title = { fg = P.pink, bold = true }
  hl.LspReferenceText = { bg = P.bg2 }
  hl.LspReferenceRead = { bg = P.bg2 }
  hl.LspReferenceWrite = { bg = P.bg2, underline = true }
  hl.LspInlayHint = { fg = P.gray, bg = P.bg0_s, italic = true }
  hl.FloatBorder = { fg = P.bg3, bg = c.bg_float }
  hl.WinSeparator = { fg = P.bg2 }

  -- Git: added teal, modified yellow, removed red, untracked orange
  local git = {
    add = { fg = P.teal }, change = { fg = P.yellow }, delete = { fg = P.red },
    untracked = { fg = P.orange },
  }
  for _, g in ipairs({ "GitSignsAdd", "GitSignsAddNr", "GitSignsAddLn", "MiniDiffSignAdd",
    "NeoTreeGitAdded", "SnacksPickerGitStatusAdded", "diffAdded", "Added" }) do
    hl[g] = vim.deepcopy(git.add)
  end
  for _, g in ipairs({ "GitSignsChange", "GitSignsChangeNr", "GitSignsChangeLn",
    "MiniDiffSignChange", "NeoTreeGitModified", "SnacksPickerGitStatusModified",
    "diffChanged", "Changed" }) do
    hl[g] = vim.deepcopy(git.change)
  end
  for _, g in ipairs({ "GitSignsDelete", "GitSignsDeleteNr", "GitSignsDeleteLn",
    "MiniDiffSignDelete", "NeoTreeGitDeleted", "SnacksPickerGitStatusDeleted",
    "diffRemoved", "Removed" }) do
    hl[g] = vim.deepcopy(git.delete)
  end
  for _, g in ipairs({ "GitSignsUntracked", "NeoTreeGitUntracked",
    "SnacksPickerGitStatusUntracked" }) do
    hl[g] = vim.deepcopy(git.untracked)
  end
  hl.NeoTreeGitConflict = { fg = P.red, bold = true }

  -- Dashboard (snacks.nvim). By default it inherits Special/Number, which
  -- are purple here, so the whole menu came out purple.
  for i = 1, HEADER_STEPS do
    hl["HexafunkHeader" .. i] = { fg = mix(HEADER_FROM, HEADER_TO, (i - 1) / (HEADER_STEPS - 1)) }
  end
  hl.SnacksDashboardHeader = { fg = P.teal }
  hl.SnacksDashboardIcon = { fg = P.teal_dim }
  hl.SnacksDashboardDesc = { fg = P.fg1 }
  hl.SnacksDashboardKey = { fg = P.pink, bold = true }
  hl.SnacksDashboardFile = { fg = P.fg1 }
  hl.SnacksDashboardDir = { fg = P.gray }
  hl.SnacksDashboardFooter = { fg = P.gray }
  hl.SnacksDashboardSpecial = { fg = P.teal_dim }
  hl.SnacksDashboardTitle = { fg = P.pink, bold = true }
end

-- Lualine. Wraps whatever theme function is already configured (Omarchy's
-- transparent-middle tweak) and repaints the mode and position blocks, but
-- only while hexafunk's palette is the active one, so a hot-reload to
-- another aether-based theme isn't left with these colors.
local function hexafunk_lualine(prev_theme)
  return function()
    local base
    if type(prev_theme) == "function" then
      base = prev_theme()
    elseif type(prev_theme) == "table" then
      base = vim.deepcopy(prev_theme)
    else
      base = require("lualine.utils.loader").load_theme("auto")
    end

    local ok, cs = pcall(require, "aether.colorscheme")
    if not (ok and cs.get().hexafunk) then
      return base
    end

    local function mode(bg, fg, b_fg)
      return {
        a = { bg = bg, fg = fg, gui = "bold" },
        b = { bg = "None", fg = b_fg },
        c = { bg = "None", fg = P.fg1 },
        x = { bg = "None", fg = P.fg1 },
        y = { bg = P.teal_dim, fg = P.bg0_h },
        z = { bg = P.teal_dim, fg = P.bg0_h, gui = "bold" },
      }
    end

    return {
      -- branch in linen next to the NORMAL block: bright pink beside pink-dim
      -- reads as a near-miss
      normal = mode(P.pink_dim, P.fg0, P.fg2),
      insert = mode(P.pink, P.bg0_h, P.pink),
      visual = mode(P.green, P.bg0_h, P.green),
      command = mode(P.yellow, P.bg0_h, P.yellow),
      replace = mode(P.red, P.bg0_h, P.red),
      terminal = mode(P.teal, P.bg0_h, P.teal),
      inactive = {
        a = { bg = P.bg0_s, fg = P.gray },
        b = { bg = "None", fg = P.gray },
        c = { bg = "None", fg = P.gray },
      },
    }
  end
end

return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = P.bg0,
        dark_bg = P.bg0_h,
        darker_bg = "#10110e",
        lighter_bg = P.bg1,

        fg = P.fg1,
        dark_fg = P.bg4,
        light_fg = P.fg2,
        bright_fg = P.fg0,
        muted = P.gray,

        red = P.red,
        yellow = P.yellow,
        orange = P.orange,
        green = P.green,
        cyan = P.teal,
        blue = P.blue,
        purple = P.purple, -- set directly; `magenta` would alias it to pink
        brown = "#875125",

        bright_red = "#ff9694",
        bright_yellow = "#fcd680",
        bright_green = "#c3ca9b",
        bright_cyan = "#40f4dc",
        bright_blue = "#6ec3d9",
        bright_purple = "#d1b1f2",

        accent = P.pink,
        cursor = P.fg0,
        foreground = P.fg1,
        background = P.bg0,
        selection = P.pink_dim,
        selection_foreground = P.fg0,
        selection_background = P.pink_dim,
      },
      on_colors = function(c)
        local U = require("aether.utils")
        c.hexafunk = true
        c.git = { add = P.teal, change = P.yellow, delete = P.red, ignore = P.gray }
        c.diff = {
          add = U.blend_bg(P.teal, 0.18),
          delete = U.blend_bg(P.red, 0.22),
          change = U.blend_bg(P.yellow, 0.14),
          text = U.blend_bg(P.yellow, 0.32),
        }
        c.error = P.red
        c.warning = P.yellow
        c.info = P.blue
        c.hint = P.teal_dim
        c.todo = P.yellow
        c.border_highlight = P.pink
        c.bg_search = P.yellow_dim
        -- terminal buffers inside nvim get pink as ANSI magenta
        c.terminal.magenta = P.pink
        c.terminal.magenta_bright = "#ff9acd"
        c.terminal.white = P.fg2
        c.terminal.white_bright = P.fg0
        c.terminal.black_bright = P.gray
      end,
      on_highlights = syntax_overrides,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = hexafunk_lualine(opts.options.theme)

      -- git diff counts: added teal, modified yellow, removed red
      for _, comp in ipairs((opts.sections or {}).lualine_x or {}) do
        if type(comp) == "table" and comp[1] == "diff" then
          comp.diff_color = {
            added = { fg = P.teal },
            modified = { fg = P.yellow },
            removed = { fg = P.red },
          }
        end
      end
    end,
  },
  {
    -- Dashboard logo drawn line by line so each line gets its own step of
    -- the teal fade. Keeps LazyVim's logo, menu and startup line.
    "folke/snacks.nvim",
    opts = function(_, opts)
      local dash = opts.dashboard
      if not (dash and dash.preset and type(dash.preset.header) == "string") then
        return
      end
      local lines = vim.split(dash.preset.header, "\n", { trimempty = true })
      while #lines > 0 and vim.trim(lines[#lines]) == "" do
        table.remove(lines)
      end
      local sections = {}
      for i, line in ipairs(lines) do
        local step = #lines > 1 and math.floor((i - 1) / (#lines - 1) * (HEADER_STEPS - 1) + 0.5) + 1 or 1
        table.insert(sections, {
          text = { { line, hl = "HexafunkHeader" .. step } },
          align = "center",
          padding = i == #lines and 2 or 0,
        })
      end
      table.insert(sections, { section = "keys", gap = 1, padding = 1 })
      table.insert(sections, { section = "startup" })
      dash.sections = sections
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
