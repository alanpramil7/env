return {
    {
        "xiyaowong/nvim-transparent",
        config = function()
            require("transparent").setup({
                extra_groups = {
                    -- Use `ToggleTransparent` command to toggle transparency
                    "ToggleTransparent"
                }
            })

            -- Example keymapping to toggle transparency
            vim.cmd("command! ToggleTransparent lua require('transparent').toggle()")
            vim.keymap.set("n", "<leader>tp", ":ToggleTransparent<CR>")
        end
    },
}
