function drawCredits()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Credits", 0, 10, 320, "center")

    local credits = {
        "Programming:",
        "kfarwell",
        "Claude",
        "",
        "Graphics:",
        "Riichi asset by gamblemountain",
        "",
        "Audio:",
        "Mahjong & UI sounds by T-STUDIO",
        "",
        "Font:",
        "Compass Gold by somepx",
        "",
        "Made with LÖVE"
    }

    local startY = 32
    for i, line in ipairs(credits) do
        love.graphics.printf(line, 0, startY + (i - 1) * 14, 320, "center")
    end

    drawBackButton()
end

function creditsMousePressed(x, y, button)
    if button == 1 then
        if isBackButtonClicked(x, y) then
            playSound(sounds.back)
            resetMenuState()
            gameState = "menu"
        end
    end
end

function creditsKeyPressed(key)
    if key == "escape" or key == "space" or key == "return" then
        playSound(sounds.back)
        resetMenuState()
        gameState = "menu"
    end
end
