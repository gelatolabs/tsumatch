function createMenu()
    local _, mx, my = shove.mouseToViewport()
    local items = {
        {text = "Play", action = function() resetRoundSelectState(); gameState = "roundSelect" end},
        {text = "Scores", action = function() leaderboardPage = 1; gameState = "leaderboard" end},
        {text = "Settings", action = function() settingsReturnState = "menu"; resetSettingsState(); gameState = "settings" end},
        {text = "Help", action = function() gameState = "help"; helpPage = 1 end},
        {text = "Credits", action = function() gameState = "credits" end}
    }

    local os = love.system.getOS()
    if os ~= "Web" and os ~= "iOS" and os ~= "Android" then
        table.insert(items, {text = "Quit", action = function() love.event.quit() end})
    end

    return {
        selected = 1,
        useKeyboard = true,  -- Start in keyboard mode to highlight Play
        lastMouseX = mx,
        lastMouseY = my,
        items = items
    }
end

function resetMenuState()
    local _, mx, my = shove.mouseToViewport()
    menuState.selected = 1
    menuState.useKeyboard = true
    menuState.lastMouseX = mx
    menuState.lastMouseY = my
end

function createRoundSelect()
    local _, mx, my = shove.mouseToViewport()
    return {
        selected = 1,
        useKeyboard = true,
        lastMouseX = mx,
        lastMouseY = my,
        items = {
            {text = "Hanchan (8 rounds)", rounds = 8},
            {text = "Tonpuu (4 rounds)", rounds = 4}
        }
    }
end

function resetRoundSelectState()
    local _, mx, my = shove.mouseToViewport()
    roundSelectState.selected = 1
    roundSelectState.useKeyboard = true
    roundSelectState.lastMouseX = mx
    roundSelectState.lastMouseY = my
end

function updateMenu()
    local _, mx, my = shove.mouseToViewport()

    if mx ~= menuState.lastMouseX or my ~= menuState.lastMouseY then
        menuState.lastMouseX = mx
        menuState.lastMouseY = my

        local yOffset = love.system.getOS() == "Web" and 10 or 0

        for i, _ in ipairs(menuState.items) do
            local textY = 70 + yOffset + i * 20
            if my >= textY and my < textY + 15 then
                menuState.useKeyboard = false
                break
            end
        end
    end
end

function drawMenu()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    local yOffset = love.system.getOS() == "Web" and 10 or 0

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(largeFont)
    love.graphics.printf("Tsumatch!", 0, 30 + yOffset, 320, "center")
    love.graphics.setFont(gameFont)

    local _, _, my = shove.mouseToViewport()

    for i, item in ipairs(menuState.items) do
        local textY = 70 + yOffset + i * 20
        local isHover = my >= textY and my < textY + 15

        local shouldHighlight = false
        if menuState.useKeyboard then
            shouldHighlight = (i == menuState.selected)
        else
            shouldHighlight = isHover
            if isHover then
                menuState.selected = i
            end
        end

        if shouldHighlight then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.printf(item.text, 0, textY, 320, "center")
    end
end

function menuMousePressed(x, y, button)
    if button == 1 then
        local yOffset = love.system.getOS() == "Web" and 10 or 0

        for i, item in ipairs(menuState.items) do
            local textY = 70 + yOffset + i * 20
            if y >= textY and y < textY + 15 then
                playSound(sounds.select)
                item.action()
                return
            end
        end
    end
end

function menuKeyPressed(key)
    if key == "up" or key == "w" then
        menuState.useKeyboard = true
        menuState.selected = menuState.selected - 1
        if menuState.selected < 1 then menuState.selected = #menuState.items end
        playSound(sounds.cursor)
    elseif key == "down" or key == "s" then
        menuState.useKeyboard = true
        menuState.selected = menuState.selected + 1
        if menuState.selected > #menuState.items then menuState.selected = 1 end
        playSound(sounds.cursor)
    elseif key == "return" or key == "space" then
        playSound(sounds.select)
        menuState.items[menuState.selected].action()
    end
end

function updateRoundSelect()
    local _, mx, my = shove.mouseToViewport()

    if mx ~= roundSelectState.lastMouseX or my ~= roundSelectState.lastMouseY then
        roundSelectState.lastMouseX = mx
        roundSelectState.lastMouseY = my

        for i, _ in ipairs(roundSelectState.items) do
            local textY = 100 + i * 20
            if my >= textY and my < textY + 15 then
                roundSelectState.useKeyboard = false
                break
            end
        end
    end
end

function drawRoundSelect()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Select Match Length", 0, 60, 320, "center")

    local _, _, my = shove.mouseToViewport()

    for i, item in ipairs(roundSelectState.items) do
        local textY = 100 + i * 20
        local isHover = my >= textY and my < textY + 15

        local shouldHighlight = false
        if roundSelectState.useKeyboard then
            shouldHighlight = (i == roundSelectState.selected)
        else
            shouldHighlight = isHover
            if isHover then
                roundSelectState.selected = i
            end
        end

        if shouldHighlight then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.printf(item.text, 0, textY, 320, "center")
    end
end

function roundSelectMousePressed(x, y, button)
    if button == 1 then
        for i, item in ipairs(roundSelectState.items) do
            local textY = 100 + i * 20
            if y >= textY and y < textY + 15 then
                playSound(sounds.start)
                maxRounds = item.rounds
                roundSelectState.selected = 1
                roundSelectState.useKeyboard = true
                startGame()
                return
            end
        end
    end
end

function roundSelectKeyPressed(key)
    if key == "escape" then
        playSound(sounds.back)
        resetMenuState()
        gameState = "menu"
    elseif key == "up" or key == "w" then
        roundSelectState.useKeyboard = true
        roundSelectState.selected = roundSelectState.selected - 1
        if roundSelectState.selected < 1 then roundSelectState.selected = #roundSelectState.items end
        playSound(sounds.cursor)
    elseif key == "down" or key == "s" then
        roundSelectState.useKeyboard = true
        roundSelectState.selected = roundSelectState.selected + 1
        if roundSelectState.selected > #roundSelectState.items then roundSelectState.selected = 1 end
        playSound(sounds.cursor)
    elseif key == "return" or key == "space" then
        playSound(sounds.start)
        maxRounds = roundSelectState.items[roundSelectState.selected].rounds
        roundSelectState.selected = 1
        roundSelectState.useKeyboard = true
        startGame()
    end
end
