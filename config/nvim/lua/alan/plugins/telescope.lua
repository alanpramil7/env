return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.5",

    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-live-grep-args.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        'nvim-telescope/telescope-ui-select.nvim',
    },

    config = function()
        local telescope = require('telescope')

        telescope.setup({
            file_ignore_patters = {
                "target"
            }
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
        vim.keymap.set('n', '<leader>gc', builtin.git_commits, {})
        vim.keymap.set('n', '<C-p>', builtin.lsp_document_symbols, {})
        vim.keymap.set('n', '<leader>hh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>/', function()
            require('telescope').extensions.live_grep_args.live_grep_args()
        end, { desc = 'Telescope Live Grep Args' })
        vim.keymap.set('x', '<leader>/', function()
            require('telescope-live-grep-args.shortcuts').grep_visual_selection()
        end, { desc = 'Telescope Live Grep Selection' })
    end

}
