leaderboardHanchan = {}
leaderboardTonpuusen = {}
leaderboardPage = 1
nameEntry = "_"
nameEntryCursor = 1
nameEntrySubmitSelected = false

function loadLeaderboard()
    leaderboardHanchan = {}
    leaderboardTonpuusen = {}

    if love.filesystem.getInfo("leaderboard_hanchan.txt") then
        local data = love.filesystem.read("leaderboard_hanchan.txt")
        for line in data:gmatch("[^\r\n]+") do
            local name, score = line:match("([^,]+),([^,]+)")
            if name and score then
                table.insert(leaderboardHanchan, {name = name, score = tonumber(score)})
            end
        end
    end

    if love.filesystem.getInfo("leaderboard_tonpuusen.txt") then
        local data = love.filesystem.read("leaderboard_tonpuusen.txt")
        for line in data:gmatch("[^\r\n]+") do
            local name, score = line:match("([^,]+),([^,]+)")
            if name and score then
                table.insert(leaderboardTonpuusen, {name = name, score = tonumber(score)})
            end
        end
    end

    table.sort(leaderboardHanchan, function(a, b) return a.score > b.score end)
    table.sort(leaderboardTonpuusen, function(a, b) return a.score > b.score end)
end

function saveLeaderboard(rounds)
    local leaderboard = rounds == 8 and leaderboardHanchan or leaderboardTonpuusen
    local filename = rounds == 8 and "leaderboard_hanchan.txt" or "leaderboard_tonpuusen.txt"

    local data = ""
    for _, entry in ipairs(leaderboard) do
        data = data .. entry.name .. "," .. entry.score .. "\n"
    end
    love.filesystem.write(filename, data)
end

function isTopTen(score, rounds)
    local leaderboard = rounds == 8 and leaderboardHanchan or leaderboardTonpuusen

    if #leaderboard < 10 then
        return true
    end

    return score > leaderboard[10].score
end

function addToLeaderboard(name, score, rounds)
    local leaderboard = rounds == 8 and leaderboardHanchan or leaderboardTonpuusen

    table.insert(leaderboard, {name = name, score = score})
    table.sort(leaderboard, function(a, b) return a.score > b.score end)

    while #leaderboard > 10 do
        table.remove(leaderboard)
    end

    saveLeaderboard(rounds)
end

function updateLeaderboardScreen()
    if gameState == "nameEntry" then
        love.keyboard.setTextInput(true, 0, 90, 320, 20)
    else
        love.keyboard.setTextInput(false)
    end
end

function drawLeaderboardScreen()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    love.graphics.setColor(1, 1, 1)

    if gameState == "nameEntry" then
        love.graphics.printf("New High Score!", 0, 20, 320, "center")
        love.graphics.printf(game.score .. " pts", 0, 40, 320, "center")
        love.graphics.printf("Enter name:", 0, 70, 320, "center")

        local displayText = ""
        for i = 1, #nameEntry do
            local char = nameEntry:sub(i, i)
            if i == nameEntryCursor and char == "_" then
                displayText = displayText .. "_"
            elseif char == "_" then
                displayText = displayText .. " "
            else
                displayText = displayText .. char
            end
        end
        love.graphics.printf(displayText, 0, 90, 320, "center")

        local buttonY = 200
        local buttonText = "Submit"
        local mx, my = love.mouse.getPosition()
        local isHover = mx >= 110 and mx <= 210 and my >= buttonY and my < buttonY + 20

        if nameEntrySubmitSelected or isHover then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.rectangle("line", 110, buttonY, 100, 20)
        love.graphics.printf(buttonText, 0, buttonY + 3, 320, "center")
        love.graphics.setColor(1, 1, 1)
    elseif gameState == "finalScore" then
        love.graphics.printf("Game Over", 0, 20, 320, "center")
        love.graphics.printf("Final Score: " .. game.score, 0, 40, 320, "center")

        local buttonY = 100
        local mx, my = love.mouse.getPosition()
        local isHover = mx >= 85 and mx <= 235 and my >= buttonY and my < buttonY + 20

        if isHover then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.rectangle("line", 85, buttonY, 150, 20)
        love.graphics.printf("View Leaderboard", 0, buttonY + 3, 320, "center")
        love.graphics.setColor(1, 1, 1)

        drawBackButton()
    else
        local title = leaderboardPage == 1 and "High Scores - Hanchan" or "High Scores - Tonpuu"
        love.graphics.printf(title, 0, 10, 320, "center")

        local leaderboard = leaderboardPage == 1 and leaderboardHanchan or leaderboardTonpuusen
        for i, entry in ipairs(leaderboard) do
            love.graphics.printf(i .. ". " .. entry.name .. " - " .. entry.score, 0, 30 + i * 15, 320, "center")
        end

        drawPagination(leaderboardPage, 2)
        drawBackButton()
    end
end

function nameEntryKeyPressed(key)
    local alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    if nameEntrySubmitSelected then
        if key == "escape" then
            nameEntrySubmitSelected = false
        elseif key == "return" or key == "space" then
            local cleanName = nameEntry:gsub("_", "")
            if #cleanName > 0 then
                playSound(sounds.select)
                addToLeaderboard(cleanName, game.score, maxRounds)
                leaderboardPage = maxRounds == 8 and 1 or 2
                gameState = "leaderboard"
                nameEntry = "_"
                nameEntryCursor = 1
                nameEntrySubmitSelected = false
            end
        end
    else
        if key == "return" or key == "space" then
            nameEntrySubmitSelected = true
        elseif key == "backspace" then
            if nameEntryCursor > 1 then
                nameEntry = nameEntry:sub(1, nameEntryCursor - 2) .. nameEntry:sub(nameEntryCursor)
                nameEntryCursor = nameEntryCursor - 1
            end
        elseif key == "left" then
            nameEntryCursor = math.max(1, nameEntryCursor - 1)
        elseif key == "right" then
            if nameEntryCursor < #nameEntry then
                nameEntryCursor = nameEntryCursor + 1
            elseif #nameEntry < 12 then
                nameEntry = nameEntry .. "_"
                nameEntryCursor = nameEntryCursor + 1
            end
        elseif key == "up" then
            local currentChar = nameEntry:sub(nameEntryCursor, nameEntryCursor)
            if currentChar == "_" then
                nameEntry = nameEntry:sub(1, nameEntryCursor - 1) .. alphabet:sub(#alphabet, #alphabet) .. nameEntry:sub(nameEntryCursor + 1)
            else
                local currentIndex = alphabet:find(currentChar, 1, true)
                if currentIndex then
                    local prevIndex = ((currentIndex - 2) % #alphabet) + 1
                    local prevChar = alphabet:sub(prevIndex, prevIndex)
                    nameEntry = nameEntry:sub(1, nameEntryCursor - 1) .. prevChar .. nameEntry:sub(nameEntryCursor + 1)
                end
            end
        elseif key == "down" then
            local currentChar = nameEntry:sub(nameEntryCursor, nameEntryCursor)
            if currentChar == "_" then
                nameEntry = nameEntry:sub(1, nameEntryCursor - 1) .. alphabet:sub(1, 1) .. nameEntry:sub(nameEntryCursor + 1)
            else
                local currentIndex = alphabet:find(currentChar, 1, true)
                if currentIndex then
                    local nextIndex = (currentIndex % #alphabet) + 1
                    local nextChar = alphabet:sub(nextIndex, nextIndex)
                    nameEntry = nameEntry:sub(1, nameEntryCursor - 1) .. nextChar .. nameEntry:sub(nameEntryCursor + 1)
                end
            end
        end
    end
end

function leaderboardMousePressed(x, y, button)
    if button == 1 then
        if gameState == "nameEntry" then
            -- Submit button
            local buttonY = 200
            if x >= 110 and x <= 210 and y >= buttonY and y < buttonY + 20 then
                local cleanName = nameEntry:gsub("_", "")
                if #cleanName > 0 then
                    playSound(sounds.select)
                    addToLeaderboard(cleanName, game.score, maxRounds)
                    leaderboardPage = maxRounds == 8 and 1 or 2
                    gameState = "leaderboard"
                    nameEntry = "_"
                    nameEntryCursor = 1
                    nameEntrySubmitSelected = false
                end
            end
        elseif gameState == "finalScore" then
            -- View Leaderboard button
            local buttonY = 100
            if x >= 85 and x <= 235 and y >= buttonY and y < buttonY + 20 then
                playSound(sounds.select)
                gameState = "leaderboard"
            end
        elseif gameState == "leaderboard" then
            if isPaginationLeftClicked(x, y, leaderboardPage) then
                leaderboardPage = leaderboardPage - 1
                playSound(sounds.cursor)
            elseif isPaginationRightClicked(x, y, leaderboardPage, 2) then
                leaderboardPage = leaderboardPage + 1
                playSound(sounds.cursor)
            end
        end

        if isBackButtonClicked(x, y) then
            playSound(sounds.back)
            resetMenuState()
            gameState = "menu"
        end
    end
end
