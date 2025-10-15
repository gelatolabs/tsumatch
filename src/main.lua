shove = require("lib/shove")

function love.load()
    math.randomseed(os.time())

    require("game")
    require("tiles")
    require("board")
    require("melds")
    require("yaku_names")
    require("scoring")
    require("ui")
    require("menu")
    require("leaderboard")
    require("settings")
    require("help")
    require("credits")

    loadSettings()

    love.window.setTitle("Tsumatch!")

    local os = love.system.getOS()
    local isMobile = os == "iOS" or os == "Android"

    local fitMethod = isMobile and "aspect" or "pixel"
    shove.setResolution(320, 240, {fitMethod = fitMethod, scalingFilter = "nearest"})

    -- Start in fullscreen based on setting, or always on mobile, never on web (bugged)
    if (isMobile or settings.fullscreen) and os ~= "Web" then
        local windowWidth, windowHeight = love.window.getDesktopDimensions()
        shove.setWindowMode(windowWidth, windowHeight, {fullscreen = true, resizable = true})
    else
        shove.setWindowMode(640, 480, {resizable = true})
    end

    loadLeaderboard()
    loadTilesheet()
    loadSounds()

    gameState = "menu"
    menuState = createMenu()
    roundSelectState = createRoundSelect()
    maxRounds = 8

    joystick = nil
    joystickAxisState = {}
    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 then
        joystick = joysticks[1]
    end

    cursorVisible = true
    love.mouse.setVisible(true)

    inputRepeat = {
        keys = {},
        initialDelay = 0.4,
        repeatDelay = 0.1
    }
end

function love.update(dt)
    -- Navigation input repeat
    local navigationKeys = {"up", "down", "left", "right", "w", "a", "s", "d"}
    for _, key in ipairs(navigationKeys) do
        if inputRepeat.keys[key] then
            inputRepeat.keys[key].timer = inputRepeat.keys[key].timer + dt
            local delay = inputRepeat.keys[key].hasRepeated and inputRepeat.repeatDelay or inputRepeat.initialDelay

            if inputRepeat.keys[key].timer >= delay then
                inputRepeat.keys[key].timer = 0
                inputRepeat.keys[key].hasRepeated = true
                -- Trigger the key press again
                if gameState == "menu" then
                    menuKeyPressed(key)
                elseif gameState == "roundSelect" then
                    roundSelectKeyPressed(key)
                elseif gameState == "game" then
                    gameKeyPressed(key)
                elseif gameState == "settings" then
                    settingsKeyPressed(key)
                elseif gameState == "help" then
                    helpKeyPressed(key)
                end
            end
        end
    end

    if gameState == "menu" then
        updateMenu()
    elseif gameState == "roundSelect" then
        updateRoundSelect()
    elseif gameState == "game" then
        updateGame(dt)
    elseif gameState == "leaderboard" or gameState == "nameEntry" or gameState == "finalScore" then
        updateLeaderboardScreen()
    elseif gameState == "settings" then
        updateSettings()
    end
end

function love.draw()
    shove.beginDraw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "roundSelect" then
        drawRoundSelect()
    elseif gameState == "game" then
        drawGame()
    elseif gameState == "scoring" then
        drawScoring()
    elseif gameState == "leaderboard" or gameState == "nameEntry" or gameState == "finalScore" then
        drawLeaderboardScreen()
    elseif gameState == "help" then
        drawHelp()
    elseif gameState == "credits" then
        drawCredits()
    elseif gameState == "settings" then
        drawSettings()
    end
    shove.endDraw()
end

function love.mousepressed(_, _, button)
    local _, x, y = shove.mouseToViewport()

    if not cursorVisible then
        cursorVisible = true
        love.mouse.setVisible(true)
    end

    if gameState == "menu" then
        menuMousePressed(x, y, button)
    elseif gameState == "roundSelect" then
        roundSelectMousePressed(x, y, button)
    elseif gameState == "game" then
        gameMousePressed(x, y, button)
    elseif gameState == "scoring" then
        scoringMousePressed(x, y, button)
    elseif gameState == "leaderboard" or gameState == "nameEntry" or gameState == "finalScore" then
        leaderboardMousePressed(x, y, button)
    elseif gameState == "help" then
        helpMousePressed(x, y, button)
    elseif gameState == "credits" then
        creditsMousePressed(x, y, button)
    elseif gameState == "settings" then
        settingsMousePressed(x, y, button)
    end
end

function love.mousereleased(_, _, button)
    local _, x, y = shove.mouseToViewport()


    if gameState == "game" then
        gameMouseReleased(x, y, button)
    elseif gameState == "settings" then
        settingsMouseReleased(x, y, button)
    end
end

function love.mousemoved()
    local _, x, y = shove.mouseToViewport()

    if not cursorVisible then
        cursorVisible = true
        love.mouse.setVisible(true)
    end

    if gameState == "game" then
        gameMouseMoved(x, y)
    end
end

function love.keypressed(key)
    if cursorVisible then
        cursorVisible = false
        love.mouse.setVisible(false)
    end

    -- Toggle fullscreen (except during name entry or on web/mobile)
    local os = love.system.getOS()
    if key == "f" and gameState ~= "nameEntry" and os ~= "Web" and os ~= "iOS" and os ~= "Android" then
        love.window.setFullscreen(not love.window.getFullscreen())
        settings.fullscreen = love.window.getFullscreen()
        saveSettings()
        return
    end

    -- Track navigation keys for repeat
    local navigationKeys = {up=true, down=true, left=true, right=true, w=true, a=true, s=true, d=true}
    if navigationKeys[key] then
        inputRepeat.keys[key] = {timer = 0, hasRepeated = false}
    end

    if gameState == "menu" then
        menuKeyPressed(key)
    elseif gameState == "roundSelect" then
        roundSelectKeyPressed(key)
    elseif gameState == "game" then
        gameKeyPressed(key)
    elseif gameState == "scoring" then
        scoringKeyPressed(key)
    elseif gameState == "help" then
        helpKeyPressed(key)
    elseif gameState == "credits" then
        creditsKeyPressed(key)
    elseif gameState == "settings" then
        settingsKeyPressed(key)
    elseif gameState == "nameEntry" or gameState == "leaderboard" then
        if gameState == "nameEntry" then
            nameEntryKeyPressed(key)
        elseif gameState == "leaderboard" then
            if key == "escape" then
                playSound(sounds.back)
                resetMenuState()
                gameState = "menu"
            elseif key == "left" or key == "a" or key == "right" or key == "d" then
                leaderboardPage = leaderboardPage == 1 and 2 or 1
                playSound(sounds.cursor)
            end
        end
    end
end

function love.keyreleased(key)
    local navigationKeys = {up=true, down=true, left=true, right=true, w=true, a=true, s=true, d=true}
    if navigationKeys[key] then
        inputRepeat.keys[key] = nil
    end
end

function love.textinput(text)
    if gameState == "nameEntry" then
        if #nameEntry < 12 then
            nameEntry = nameEntry:sub(1, nameEntryCursor - 1) .. text .. nameEntry:sub(nameEntryCursor)
            nameEntryCursor = nameEntryCursor + #text
        end
    end
end

function love.joystickadded(stick)
    if not joystick then
        joystick = stick
    end
end

function love.joystickremoved(stick)
    if joystick == stick then
        joystick = nil
        local joysticks = love.joystick.getJoysticks()
        if #joysticks > 0 then
            joystick = joysticks[1]
        end
    end
end

function love.gamepadpressed(stick, button)
    if stick ~= joystick then return end

    if cursorVisible then
        cursorVisible = false
        love.mouse.setVisible(false)
    end

    -- Map gamepad buttons to keys
    if button == "dpup" or button == "dpdown" or button == "dpleft" or button == "dpright" then
        local key = button == "dpup" and "up" or button == "dpdown" and "down" or button == "dpleft" and "left" or "right"
        love.keypressed(key)
    elseif button == "a" then
        love.keypressed("return")
    elseif button == "b" then
        if gameState == "nameEntry" then
            love.keypressed("backspace")
        else
            love.keypressed("escape")
        end
    elseif button == "start" then
        love.keypressed("escape")
    end
end

function love.gamepadaxis(stick, axis, value)
    if stick ~= joystick then return end

    local deadzone = 0.5
    local wasActive = joystickAxisState[axis] and math.abs(joystickAxisState[axis]) > deadzone
    local isActive = math.abs(value) > deadzone

    if isActive and not wasActive then
        if cursorVisible then
            cursorVisible = false
            love.mouse.setVisible(false)
        end

        if axis == "leftx" then
            local key = value < 0 and "left" or "right"
            love.keypressed(key)
        elseif axis == "lefty" then
            local key = value < 0 and "up" or "down"
            love.keypressed(key)
        end
    elseif not isActive and wasActive then
        if axis == "leftx" then
            inputRepeat.keys["left"] = nil
            inputRepeat.keys["right"] = nil
        elseif axis == "lefty" then
            inputRepeat.keys["up"] = nil
            inputRepeat.keys["down"] = nil
        end
    end

    joystickAxisState[axis] = value
end

function love.gamepadreleased(stick, button)
    if stick ~= joystick then return end

    if button == "dpup" then
        inputRepeat.keys["up"] = nil
    elseif button == "dpdown" then
        inputRepeat.keys["down"] = nil
    elseif button == "dpleft" then
        inputRepeat.keys["left"] = nil
    elseif button == "dpright" then
        inputRepeat.keys["right"] = nil
    end
end
