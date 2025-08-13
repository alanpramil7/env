return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    filtered_items = {
                        visible = false, -- Set to false to hide hidden files by default
                        hide_dotfiles = false, -- Hide dotfiles by default
                        hide_gitignored = false, -- Hide gitignored files
                        hide_by_name = {
                            -- Add files/folders to always hide
                            "node_modules",
                            ".venv"
                        },
                        always_show = { -- Files/folders to always show
                            ".env",
                        },
                    },
                },
                window = {
                    position = "right",
                },
            })
            -- Keybinding to toggle Neo-tree
            vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
        end,
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
        },
        config = function()
            require("lsp-file-operations").setup()
        end,
    },
    {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        config = function()
            require("window-picker").setup({
                filter_rules = {
                    include_current_win = false,
                    autoselect_one = true,
                    -- filter using buffer options
                    bo = {
                        -- if the file type is one of following, the window will be ignored
                        filetype = { "neo-tree", "neo-tree-popup", "notify" },
                        -- if the buffer type is one of following, the window will be ignored
                        buftype = { "terminal", "quickfix" },
                    },
                },
            })
        end,
    },
}
