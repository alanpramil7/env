-- - "gruvbox"     - Retro groove colors
-- - "tokyonight"  - Modern Tokyo night theme
-- - "catppuccin"  - Soothing pastel theme
-- - "kanagawa"    - Japanese-inspired theme
-- - "nord"        - Arctic-inspired theme
-- - "onedark"     - Atom One Dark theme
-- - "nightfox"    - Customizable theme family
-- - "rose-pine"   - Soho vibes theme
-- - "photon"      - Minimal theme
-- - "material"    - Google Material Design

local active_colorscheme = "rose-pine" -- Change this to switch themes

local colorschemes = {
    -- GRUVBOX - Retro groove color scheme
    {
        "ellisonleao/gruvbox.nvim",
        name = "gruvbox",
        priority = 1000,
        opts = {
            terminal_colors = true,
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
                strings = true,
                emphasis = true,
                comments = true,
                operators = false,
                folds = true,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            inverse = true,
            contrast = "", -- "hard", "soft", or ""
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = false,
        },
        config = function(_, opts)
            require("gruvbox").setup(opts)
            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- TOKYONIGHT - Modern and popular theme
    {
        "folke/tokyonight.nvim",
        name = "tokyonight",
        priority = 1000,
        opts = {
            style = "storm", -- storm, night, moon, day
            light_style = "day",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
                functions = {},
                variables = {},
                sidebars = "dark",
                floats = "dark",
            },
            sidebars = { "qf", "help" },
            day_brightness = 0.3,
            hide_inactive_statusline = false,
            dim_inactive = false,
            lualine_bold = false,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- CATPPUCCIN - Soothing pastel theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha", -- latte, frappe, macchiato, mocha
            background = { light = "latte", dark = "mocha" },
            transparent_background = false,
            show_end_of_buffer = false,
            term_colors = false,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 0.15,
            },
            styles = {
                comments = { "italic" },
                conditionals = { "italic" },
                loops = {},
                functions = {},
                keywords = {},
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
            },
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
                telescope = true,
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- KANAGAWA - Japanese-inspired theme
    {
        "rebelot/kanagawa.nvim",
        name = "kanagawa",
        priority = 1000,
        opts = {
            compile = false,
            undercurl = true,
            commentStyle = { italic = true },
            functionStyle = {},
            keywordStyle = { italic = true },
            statementStyle = { bold = true },
            typeStyle = {},
            transparent = false,
            dimInactive = false,
            terminalColors = true,
            colors = {
                palette = {},
                theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
            },
            overrides = function(colors)
                return {}
            end,
            theme = "wave", -- wave, dragon, lotus
            background = {
                dark = "wave",
                light = "lotus"
            },
        },
        config = function(_, opts)
            require("kanagawa").setup(opts)
            vim.cmd.colorscheme("kanagawa")
        end,
    },

    -- NORD - Arctic-inspired theme
    {
        "shaunsingh/nord.nvim",
        name = "nord",
        priority = 1000,
        opts = {
            contrast = true,
            borders = false,
            disable_background = false,
            cursorline_transparent = false,
            enable = {
                terminal_colors = true,
            },
            italic = {
                comments = true,
                keywords = true,
                functions = false,
                strings = false,
                variables = false,
            },
            uniform_diff_background = true,
        },
        config = function(_, opts)
            vim.g.nord_contrast = opts.contrast
            vim.g.nord_borders = opts.borders
            vim.g.nord_disable_background = opts.disable_background
            vim.g.nord_cursorline_transparent = opts.cursorline_transparent
            vim.g.nord_enable_sidebar_background = true
            vim.g.nord_italic = false
            vim.g.nord_uniform_diff_background = opts.uniform_diff_background
            require("nord").set()
            vim.cmd.colorscheme("nord")
        end,
    },

    -- ONEDARK - Atom One Dark theme
    {
        "navarasu/onedark.nvim",
        name = "onedark",
        priority = 1000,
        opts = {
            style = "darker", -- dark, darker, cool, deep, warm, warmer
            transparent = false,
            term_colors = true,
            ending_tildes = false,
            cmp_itemkind_reverse = false,
            toggle_style_key = nil,
            toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
            code_style = {
                comments = 'italic',
                keywords = 'none',
                functions = 'none',
                strings = 'none',
                variables = 'none'
            },
            lualine = {
                transparent = false,
            },
            colors = {},
            highlights = {},
            diagnostics = {
                darker = true,
                undercurl = true,
                background = true,
            },
        },
        config = function(_, opts)
            require("onedark").setup(opts)
            require("onedark").load()
        end,
    },

    -- NIGHTFOX - Customizable theme family
    {
        "EdenEast/nightfox.nvim",
        name = "nightfox",
        priority = 1000,
        opts = {
            options = {
                compile_path = vim.fn.stdpath("cache") .. "/nightfox",
                compile_file_suffix = "_compiled",
                transparent = false,
                terminal_colors = true,
                dim_inactive = false,
                module_default = true,
                styles = {
                    comments = "italic",
                    conditionals = "NONE",
                    constants = "NONE",
                    functions = "NONE",
                    keywords = "NONE",
                    numbers = "NONE",
                    operators = "NONE",
                    strings = "NONE",
                    types = "NONE",
                    variables = "NONE",
                },
                inverse = {
                    match_paren = false,
                    visual = false,
                    search = false,
                },
            },
            palettes = {},
            specs = {},
            groups = {},
        },
        config = function(_, opts)
            require("nightfox").setup(opts)
            vim.cmd.colorscheme("nightfox") -- or carbonfox, dawnfox, dayfox, duskfox, nordfox, terafox
        end,
    },

    -- ROSE-PINE - Soho vibes theme
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        opts = {
            variant = "auto", -- auto, main, moon, dawn
            dark_variant = "main",
            dim_inactive_windows = false,
            extend_background_behind_borders = true,
            enable = {
                terminal = true,
                legacy_highlights = true,
                migrations = true,
            },
            styles = {
                bold = true,
                italic = true,
                transparency = false,
            },
            groups = {
                border = "muted",
                link = "iris",
                panel = "surface",
                error = "love",
                hint = "iris",
                info = "foam",
                note = "pine",
                todo = "rose",
                warn = "gold",
                git_add = "foam",
                git_change = "rose",
                git_delete = "love",
                git_dirty = "rose",
                git_ignore = "muted",
                git_merge = "iris",
                git_rename = "pine",
                git_stage = "iris",
                git_text = "rose",
                git_untracked = "subtle",
            },
            palette = {},
            highlight_groups = {},
            before_highlight = function(group, highlight, palette)
            end,
        },
        config = function(_, opts)
            require("rose-pine").setup(opts)
            vim.cmd.colorscheme("rose-pine")
        end,
    },

    -- PHOTON - Minimal theme
    {
        "axvr/photon.vim",
        name = "photon",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("photon")
        end,
    },

    -- MATERIAL - Google Material Design
    {
        "marko-cerovac/material.nvim",
        name = "material",
        priority = 1000,
        opts = {
            contrast = {
                terminal = false,
                sidebars = false,
                floating_windows = false,
                cursor_line = false,
                non_current_windows = false,
                filetypes = {},
            },
            styles = {
                comments = { italic = true },
                strings = { bold = false },
                keywords = { underline = false },
                functions = { bold = false, undercurl = false },
                variables = {},
                operators = {},
                types = {},
            },
            plugins = {
                "gitsigns",
                "nvim-cmp",
                "nvim-navic",
                "nvim-tree",
                "nvim-web-devicons",
                "telescope",
                "which-key",
            },
            disable = {
                colored_cursor = false,
                borders = false,
                background = false,
                term_colors = false,
                eob_lines = false
            },
            high_visibility = {
                lighter = false,
                darker = false
            },
            lualine_style = "default",
            async_loading = true,
            custom_colors = nil,
            custom_highlights = {},
        },
        config = function(_, opts)
            vim.g.material_style = "darker" -- darker, lighter, oceanic, palenight, deep ocean
            require("material").setup(opts)
            vim.cmd.colorscheme("material")
        end,
    },
}

-- Find and return the active colorscheme
for _, colorscheme in ipairs(colorschemes) do
    if colorscheme.name == active_colorscheme then
        return colorscheme
    end
end

-- Fallback to gruvbox if active_colorscheme is not found
return colorschemes[1]

--[[
HOW TO USE:
1. Change the 'active_colorscheme' variable at the top to switch themes
2. Available options:
   - "gruvbox"     - Retro groove colors
   - "tokyonight"  - Modern Tokyo night theme
   - "catppuccin"  - Soothing pastel theme
   - "kanagawa"    - Japanese-inspired theme
   - "nord"        - Arctic-inspired theme
   - "onedark"     - Atom One Dark theme
   - "nightfox"    - Customizable theme family
   - "rose-pine"   - Soho vibes theme
   - "photon"      - Minimal theme
   - "material"    - Google Material Design

QUICK SWITCHING:
You can create a command to switch themes on the fly:
vim.api.nvim_create_user_command('ColorScheme', function(opts)
    vim.cmd.colorscheme(opts.args)
end, {
    nargs = 1,
    complete = function()
        return { "gruvbox", "tokyonight", "catppuccin", "kanagawa", "nord", "onedark", "nightfox", "rose-pine", "photon", "material" }
    end
})

Then use :ColorScheme <theme_name> to switch themes
--]]
