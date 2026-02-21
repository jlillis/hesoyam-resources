-- UI theme definition (fonts & colors)
_theme = {
    colors = {
        header = {175, 205, 245},
        text = {70, 90, 100},
        error = {200, 0, 0},
    },
    fonts = {
        futura = "clear-normal",
        bank_gothic = "clear-normal",
        diploma = "clear_normal",
    },
}

-- Loads custom fonts into the theme table.
function loadFonts()
    local font

    font = guiCreateFont("client/fonts/futura-pt-bold.otf", 18)
    if font then
        _theme.fonts.futura = font
    end

    font = guiCreateFont("client/fonts/sabankgothic.ttf", 34)
    if font then
        _theme.fonts.bank_gothic = font
    end

    font = guiCreateFont("client/fonts/saheader.ttf", 48)
    if font then
        _theme.fonts.diploma = font
    end
end
