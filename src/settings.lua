settings = {
    volume = 0.5,
    language = "ja",
    fullscreen = false
}

function fullscreenToggleable()
    local os = love.system.getOS()
    return os ~= "Web" and os ~= "iOS" and os ~= "Android"
end

settingsState = {
    draggingSlider = false,
    selectedOption = 1,  -- 1=volume, 2=language, 3=fullscreen (if not web/mobile)
    maxOptions = fullscreenToggleable() and 3 or 2,
    useKeyboard = true,
    lastMouseX = 0,
    lastMouseY = 0
}

function resetSettingsState()
    local _, mx, my = shove.mouseToViewport()
    settingsState.selectedOption = 1
    settingsState.useKeyboard = true
    settingsState.lastMouseX = mx
    settingsState.lastMouseY = my
end

function loadSettings()
    if love.filesystem.getInfo("settings.txt") then
        local data = love.filesystem.read("settings.txt")
        for line in data:gmatch("[^\r\n]+") do
            local key, value = line:match("([^=]+)=([^=]+)")
            if key == "volume" then
                settings.volume = tonumber(value)
            elseif key == "language" then
                settings.language = value
            elseif key == "fullscreen" then
                settings.fullscreen = value == "true"
            end
        end
    end
end

function saveSettings()
    local data = "volume=" .. settings.volume .. "\nlanguage=" .. settings.language .. "\nfullscreen=" .. tostring(settings.fullscreen)
    love.filesystem.write("settings.txt", data)
end

function drawSettings()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Settings", 0, 20, 320, "center")

    local _, _, my = shove.mouseToViewport()

    -- Volume
    local shouldHighlightVolume = false
    if settingsState.useKeyboard then
        shouldHighlightVolume = (settingsState.selectedOption == 1)
    else
        shouldHighlightVolume = (my >= 60 and my < 90)
    end
    if shouldHighlightVolume then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print("Volume: " .. math.floor(settings.volume * 100) .. "%", 50, 60)
    love.graphics.setColor(1, 1, 1)

    local sliderX, sliderY = 50, 75
    local sliderWidth = 220
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", sliderX, sliderY, sliderWidth, 4)

    love.graphics.setColor(0.7, 0.7, 0.7)
    local knobX = sliderX + settings.volume * sliderWidth
    love.graphics.circle("fill", knobX, sliderY + 2, 6)

    -- Language
    local shouldHighlightLanguage = false
    if settingsState.useKeyboard then
        shouldHighlightLanguage = (settingsState.selectedOption == 2)
    else
        shouldHighlightLanguage = (my >= 100 and my < 115)
    end
    if shouldHighlightLanguage then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print("Language: " .. (settings.language == "ja" and "Romaji" or "English"), 50, 100)

    -- Fullscreen (hidden on web and mobile)
    if fullscreenToggleable() then
        local shouldHighlightFullscreen = false
        if settingsState.useKeyboard then
            shouldHighlightFullscreen = (settingsState.selectedOption == 3)
        else
            shouldHighlightFullscreen = (my >= 120 and my < 135)
        end
        if shouldHighlightFullscreen then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.print("Fullscreen: " .. (settings.fullscreen and "On" or "Off"), 50, 120)
    end

    -- Print LÖVE version and OS
    love.graphics.setColor(0.5, 0.5, 0.5)
    local major, minor, revision = love.getVersion()
    local os = love.system.getOS()
    local infoText = string.format("LÖVE %d.%d.%d on %s", major, minor, revision, os)
    local textWidth = gameFont:getWidth(infoText)
    love.graphics.print(infoText, 320 - textWidth - 5, 240 - gameFont:getHeight() - 3)
    love.graphics.setColor(1, 1, 1)

    drawBackButton()
end

function updateSettings()
    local _, mx, my = shove.mouseToViewport()

    -- Detect mouse movement
    if mx ~= settingsState.lastMouseX or my ~= settingsState.lastMouseY then
        settingsState.lastMouseX = mx
        settingsState.lastMouseY = my

        -- Check if mouse is over any option
        if my >= 60 and my < 90 then
            settingsState.useKeyboard = false
        elseif my >= 100 and my < 115 then
            settingsState.useKeyboard = false
        elseif fullscreenToggleable() and my >= 120 and my < 135 then
            settingsState.useKeyboard = false
        end
    end

    if settingsState.draggingSlider then
        local sliderX = 50
        local sliderWidth = 220
        settings.volume = math.max(0, math.min(1, (mx - sliderX) / sliderWidth))
        saveSettings()
    end
end

function settingsMousePressed(x, y, button)
    if button == 1 then
        if isBackButtonClicked(x, y) then
            playSound(sounds.back)
            if settingsReturnState == "menu" or not settingsReturnState then
                resetMenuState()
            end
            gameState = settingsReturnState or "menu"
            return
        end

        local sliderX, sliderY = 50, 75
        local sliderWidth = 220
        if x >= sliderX and x <= sliderX + sliderWidth and y >= sliderY - 6 and y <= sliderY + 10 then
            settingsState.draggingSlider = true
            settings.volume = math.max(0, math.min(1, (x - sliderX) / sliderWidth))
            saveSettings()
        elseif y >= 100 and y < 115 then
            settings.language = settings.language == "ja" and "en" or "ja"
            saveSettings()
            playSound(sounds.select)
        elseif y >= 120 and y < 135 and fullscreenToggleable() then
            settings.fullscreen = not settings.fullscreen
            love.window.setFullscreen(settings.fullscreen)
            saveSettings()
            playSound(sounds.select)
        end
    end
end

function settingsMouseReleased(_, _, button)
    if button == 1 then
        settingsState.draggingSlider = false
    end
end

function settingsKeyPressed(key)
    if key == "escape" then
        playSound(sounds.back)
        if settingsReturnState == "menu" or not settingsReturnState then
            resetMenuState()
        end
        gameState = settingsReturnState or "menu"
    elseif key == "up" or key == "w" then
        settingsState.useKeyboard = true
        settingsState.selectedOption = settingsState.selectedOption - 1
        if settingsState.selectedOption < 1 then settingsState.selectedOption = settingsState.maxOptions end
        playSound(sounds.cursor)
    elseif key == "down" or key == "s" then
        settingsState.useKeyboard = true
        settingsState.selectedOption = settingsState.selectedOption + 1
        if settingsState.selectedOption > settingsState.maxOptions then settingsState.selectedOption = 1 end
        playSound(sounds.cursor)
    elseif key == "left" or key == "a" then
        if settingsState.selectedOption == 1 then
            -- Volume down
            settings.volume = math.max(0, settings.volume - 0.1)
            saveSettings()
            playSound(sounds.cursor)
        elseif settingsState.selectedOption == 2 then
            -- Toggle language
            settings.language = settings.language == "ja" and "en" or "ja"
            saveSettings()
            playSound(sounds.select)
        elseif settingsState.selectedOption == 3 and fullscreenToggleable() then
            -- Toggle fullscreen
            settings.fullscreen = not settings.fullscreen
            love.window.setFullscreen(settings.fullscreen)
            saveSettings()
            playSound(sounds.select)
        end
    elseif key == "right" or key == "d" then
        if settingsState.selectedOption == 1 then
            -- Volume up
            settings.volume = math.min(1, settings.volume + 0.1)
            saveSettings()
            playSound(sounds.cursor)
        elseif settingsState.selectedOption == 2 then
            -- Toggle language
            settings.language = settings.language == "ja" and "en" or "ja"
            saveSettings()
            playSound(sounds.select)
        elseif settingsState.selectedOption == 3 and fullscreenToggleable() then
            -- Toggle fullscreen
            settings.fullscreen = not settings.fullscreen
            love.window.setFullscreen(settings.fullscreen)
            saveSettings()
            playSound(sounds.select)
        end
    elseif key == "return" or key == "space" then
        if settingsState.selectedOption == 2 then
            settings.language = settings.language == "ja" and "en" or "ja"
            saveSettings()
            playSound(sounds.select)
        elseif settingsState.selectedOption == 3 and fullscreenToggleable() then
            settings.fullscreen = not settings.fullscreen
            love.window.setFullscreen(settings.fullscreen)
            saveSettings()
            playSound(sounds.select)
        end
    end
end
