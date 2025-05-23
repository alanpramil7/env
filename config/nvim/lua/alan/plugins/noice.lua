return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            opts = {
                timeout = 500,
                render = "compact", -- Use compact rendering for smaller notifications
            },
        },
    },
    opts = {
        lsp = {
            progress = {
                enabled = true,
                view = "mini", -- Send LSP progress to notify instead of mini
            },
            message = {
                enabled = true,
                view = "mini", -- Send LSP messages to notify
            },
        },
        messages = {
            enabled = true,
            view = "mini",
        },
        presets = {
            bottom_search = true,
            command_palette = false,
            long_message_to_split = true,
        },
    },
}
