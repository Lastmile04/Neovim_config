return {
    {
        "3rd/image.nvim",
        build = false,
        opts = {
            processor = "magick_cli",
            backend = "kitty",
            hijack_file_patterns = {
                "*.png",
                "*.jpg",
                "*.jpeg",
                "*.gif",
                "*.webp",
                "*.avif",
                "*.svg",
            },
        },
    },
}
