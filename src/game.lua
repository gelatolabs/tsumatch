function startGame()
    loadTilesheet()

    game = {
        board = createBoard(),
        hand = {},
        round = 1,
        roundWind = 1,
        score = 0,
        doraIndicators = {},
        kanCount = 0,
        dragTile = nil,
        highlightRow = nil,
        highlightCol = nil,
        animations = {},
        popup = nil,
        popupTimer = 0,
        tilePositions = {},
        selectedTile = nil,
        hoverTile = nil,
        paused = false,
        pauseMenuSelected = 1,
        pauseMenuUseKeyboard = true,
        pauseMenuLastMouseX = 0,
        pauseMenuLastMouseY = 0,
        hintTimer = 0,
        hintDelay = 10,
        hintPositions = nil,
        hintShakeTime = 0,
        droppingTiles = false,
        doraPulseTime = 0,
        particles = {},
        dropDelay = 0
    }

    initializeTilePositions()

    for i = 1, 1 + game.kanCount do
        table.insert(game.doraIndicators, generateRandomTile(true))
    end

    gameState = "game"
end

function updateGame(dt)
    -- Handle pause menu mouse movement detection
    if game.paused then
        local _, mx, my = shove.mouseToViewport()
        if mx ~= game.pauseMenuLastMouseX or my ~= game.pauseMenuLastMouseY then
            game.pauseMenuLastMouseX = mx
            game.pauseMenuLastMouseY = my

            local pauseMenuItems = {"Resume", "Settings", "Quit"}
            for i = 1, #pauseMenuItems do
                local itemY = 90 + i * 20
                if my >= itemY and my < itemY + 15 and mx >= 80 and mx <= 240 then
                    game.pauseMenuUseKeyboard = false
                    break
                end
            end
        end
    end

    updateTilePositions(dt)
    updateParticles(dt)

    game.doraPulseTime = game.doraPulseTime + dt

    if game.dropDelay > 0 then
        game.dropDelay = game.dropDelay - dt
        if game.dropDelay <= 0 then
            dropTiles()
            game.droppingTiles = true
        end
    end

    for i = #game.animations, 1, -1 do
        game.animations[i].timer = game.animations[i].timer + dt
        if game.animations[i].timer >= game.animations[i].duration then
            if game.animations[i].type == "handComplete" then
                gameState = "scoring"
                calculateScore()
            end
            table.remove(game.animations, i)
        end
    end

    if game.popupTimer > 0 then
        game.popupTimer = game.popupTimer - dt
        if game.popupTimer <= 0 then
            game.popup = nil
        end
    end

    if #game.animations == 0 and game.popup == nil and #game.hand < 4 and game.dropDelay <= 0 then
        local melds = findMelds(game.board)
        if #melds > 0 then
            processMelds({melds[1]})
            game.dropDelay = 0.4
            game.hintPositions = nil
        elseif not game.dragTile and not game.hintPositions then
            local randomMove = findMove(game.board, BOARD_SIZE)
            if not randomMove then
                shuffleBoard()
                game.popup = "Out of moves,\nshuffling"
                game.popupTimer = 2.0
                game.popupX = nil
                game.popupY = nil
                game.hintPositions = nil
            else
                game.hintPositions = randomMove
            end
        end
    end

    if game.droppingTiles then
        local allTilesSettled = true
        for y = 1, BOARD_SIZE do
            for x = 1, BOARD_SIZE do
                if game.tilePositions[y] and game.tilePositions[y][x] then
                    local pos = game.tilePositions[y][x]
                    local dx = pos.targetX - pos.x
                    local dy = pos.targetY - pos.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist > 0.5 then
                        allTilesSettled = false
                        break
                    end
                end
            end
            if not allTilesSettled then break end
        end

        if allTilesSettled then
            game.droppingTiles = false
            fillBoard()
            syncTilePositions()
        end
    end

    -- Hint shake animation
    if not game.paused and #game.animations == 0 and not game.popup and not game.dragTile and not game.selectedTile and not game.droppingTiles then
        game.hintTimer = game.hintTimer + dt

        if game.hintTimer >= game.hintDelay and game.hintPositions then
            game.hintShakeTime = game.hintShakeTime + dt
            if game.hintShakeTime > 8 then
                game.hintShakeTime = 0
            end
        end
    else
        -- Reset on interaction
        if game.hintShakeTime > 0 then
            syncTilePositions()
        end
        game.hintTimer = game.hintPositions and 5 or 0
        game.hintShakeTime = 0
    end
end

function drawGame()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 235, 0, 85, 240)

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.line(234, 0, 234, 240)

    love.graphics.setColor(1, 1, 1)

    -- Virtual keyboard drag tile
    local effectiveDragTile = game.dragTile
    local effectiveHighlightRow = game.highlightRow
    local effectiveHighlightCol = game.highlightCol

    if game.selectedTile then
        effectiveHighlightRow = game.selectedTile.y
        effectiveHighlightCol = game.selectedTile.x

        if game.keyboardDragPos then
            local tx, ty = getTilePosition(game.keyboardDragPos.x, game.keyboardDragPos.y)
            effectiveDragTile = {
                tile = game.board[game.selectedTile.y][game.selectedTile.x],
                gridX = game.keyboardDragPos.x,
                gridY = game.keyboardDragPos.y,
                startX = game.selectedTile.x,
                startY = game.selectedTile.y,
                x = tx + TILE_SIZE / 2,
                y = ty + TILE_SIZE / 2,
                constrainToRow = game.keyboardDragPos.y == game.selectedTile.y,
                constrainToCol = game.keyboardDragPos.x == game.selectedTile.x
            }
        end
    end

    drawBoard(game.board, effectiveDragTile, effectiveHighlightRow, effectiveHighlightCol, game.doraIndicators, game.tilePositions, game.selectedTile, game.hoverTile)
    drawParticles()

    love.graphics.setColor(1, 1, 1)
    local windNames = {"East", "South", "West", "North"}
    love.graphics.print(windNames[game.roundWind] .. " " .. ((game.round - 1) % 4 + 1), 240, 3)
    love.graphics.print(game.score .. " pts", 240, 19)

    local doraY = 40
    local doraCol = 0
    local doraRow = 0
    for i = 1, 4 do
        local x = 238 + doraCol * TILE_SIZE
        local y = doraY + doraRow * TILE_SIZE

        if i <= #game.doraIndicators then
            love.graphics.draw(tilesheetImage, getTileQuad(game.doraIndicators[i]), x, y)
        else
            love.graphics.draw(tilesheetImage, getTileBackQuad(), x, y)
        end

        doraCol = doraCol + 1
        if doraCol >= 2 then
            doraCol = 0
            doraRow = doraRow + 1
        end
    end

    local separatorY = doraY + 2 * TILE_SIZE + 5
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.line(239, separatorY, 315, separatorY)
    love.graphics.setColor(1, 1, 1)

    local handY = separatorY + 5
    local handTiles = {}
    for _, meld in ipairs(game.hand) do
        local meldTiles = {}
        for _, tile in ipairs(meld.tiles) do
            table.insert(meldTiles, tile)
        end
        sortTiles(meldTiles)
        for _, tile in ipairs(meldTiles) do
            table.insert(handTiles, tile)
        end
    end

    local tileX, tileY = 238, handY
    local tilesPerRow = 3
    for i, tile in ipairs(handTiles) do
        if (i - 1) % tilesPerRow == 0 and i > 1 then
            tileY = tileY + TILE_SIZE
            tileX = 238
        end
        love.graphics.draw(tilesheetImage, getTileQuad(tile), tileX, tileY)
        tileX = tileX + TILE_SIZE
    end

    if game.popup then
        local oldFont = love.graphics.getFont()
        love.graphics.setFont(largeFont)

        local textWidth = 0
        local lineCount = 0
        for line in game.popup:gmatch("[^\n]+") do
            local lineWidth = largeFont:getWidth(line)
            if lineWidth > textWidth then
                textWidth = lineWidth
            end
            lineCount = lineCount + 1
        end
        local textHeight = lineCount * largeFont:getHeight()

        local x, y

        if game.popupX and game.popupY then
            x = game.popupX - textWidth / 2
            y = game.popupY
            -- Clamp x so text doesn't overflow screen
            x = math.max(0, math.min(x, 234 - textWidth))
        else
            -- Centered popup
            x = 117 - textWidth / 2
            y = 120 - textHeight / 2
        end

        local lineY = y
        for line in game.popup:gmatch("[^\n]+") do
            local lineWidth = largeFont:getWidth(line)
            local lineX = x + (textWidth - lineWidth) / 2

            -- Black text outline
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print(line, lineX - 2, lineY - 2)
            love.graphics.print(line, lineX, lineY - 2)
            love.graphics.print(line, lineX + 2, lineY - 2)
            love.graphics.print(line, lineX - 2, lineY)
            love.graphics.print(line, lineX + 2, lineY)
            love.graphics.print(line, lineX - 2, lineY + 2)
            love.graphics.print(line, lineX, lineY + 2)
            love.graphics.print(line, lineX + 2, lineY + 2)

            -- White text
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(line, lineX, lineY)

            lineY = lineY + largeFont:getHeight()
        end

        love.graphics.setFont(oldFont)
    end

    -- Pause button
    love.graphics.setColor(1, 1, 1)
    local pauseButtonX, pauseButtonY = 304, 5
    for i = 0, 2 do
        love.graphics.rectangle("fill", pauseButtonX, pauseButtonY + i * 4, 10, 2)
    end

    -- Pause menu
    if game.paused then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, 320, 240)

        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 80, 60, 160, 120)

        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("line", 80, 60, 160, 120)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("PAUSED", 80, 70, 160, "center")

        local _, mx, my = shove.mouseToViewport()
        local pauseMenuItems = {"Resume", "Settings", "Quit"}
        for i, item in ipairs(pauseMenuItems) do
            local y = 90 + i * 20
            local isHover = my >= y and my < y + 15 and mx >= 80 and mx <= 240

            local shouldHighlight = false
            if game.pauseMenuUseKeyboard then
                shouldHighlight = (i == game.pauseMenuSelected)
            else
                shouldHighlight = isHover
                if isHover then
                    game.pauseMenuSelected = i
                end
            end

            if shouldHighlight then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(item, 80, y, 160, "center")
        end
    end
end

function gameMousePressed(x, y, button)
    if button == 1 then
        -- Pause button
        if x >= 304 and x <= 314 and y >= 6 and y <= 16 then
            if game.paused then
                playSound(sounds.back)
            else
                playSound(sounds.select)
                game.pauseMenuSelected = 1
                game.pauseMenuUseKeyboard = true
                local _, mx, my = shove.mouseToViewport()
                game.pauseMenuLastMouseX = mx
                game.pauseMenuLastMouseY = my
            end
            game.paused = not game.paused
            return
        end

        -- Pause menu
        if game.paused then
            local pauseMenuItems = {"Resume", "Settings", "Quit"}
            for i, _ in ipairs(pauseMenuItems) do
                local itemY = 90 + i * 20
                if y >= itemY and y < itemY + 15 and x >= 80 and x <= 240 then
                    if i == 1 then -- Resume
                        playSound(sounds.back)
                        game.paused = false
                    elseif i == 2 then -- Settings
                        playSound(sounds.select)
                        game.paused = false
                        settingsReturnState = "game"
                        resetSettingsState()
                        gameState = "settings"
                    elseif i == 3 then -- Quit
                        playSound(sounds.back)
                        resetMenuState()
                        gameState = "menu"
                    end
                    return
                end
            end
            return
        end
    end

    if button == 1 and #game.animations == 0 and game.popup == nil and not game.paused then
        local tileX, tileY = getTileAtPosition(x, y)
        if tileX and tileY then
            game.dragTile = {
                tile = game.board[tileY][tileX],
                gridX = tileX,
                gridY = tileY,
                startX = tileX,
                startY = tileY,
                x = x,
                y = y,
                constrainToRow = false,
                constrainToCol = false
            }
            game.highlightRow = tileY
            game.highlightCol = tileX
            playSound(sounds.tileup)
        end
    end
end

function gameMouseReleased(x, y, button)
    if button == 1 and game.dragTile then
        local targetX, targetY = game.dragTile.gridX, game.dragTile.gridY

        if (targetX ~= game.dragTile.startX or targetY ~= game.dragTile.startY) and
           (targetX == game.dragTile.startX or targetY == game.dragTile.startY) and
           isValidMove(game.board, game.dragTile.startX, game.dragTile.startY, targetX, targetY) then
            moveTile(game.board, game.dragTile.startX, game.dragTile.startY, targetX, targetY)
            syncTilePositions()
        else
            syncTilePositions()
        end

        playSound(sounds.tiledown)
        game.dragTile = nil
        game.highlightRow = nil
        game.highlightCol = nil
    end
end

function gameKeyPressed(key)
    if key == "escape" then
        if game.paused then
            -- Leave pause menu
            playSound(sounds.back)
            game.paused = false
            return
        elseif game.dragTile then
            -- Cancel mouse drag
            syncTilePositions()
            game.dragTile = nil
            game.highlightRow = nil
            game.highlightCol = nil
            return
        elseif game.selectedTile then
            -- Cancel keyboard drag (handled below)
        else
            playSound(sounds.select)
            game.paused = true
            game.pauseMenuSelected = 1
            game.pauseMenuUseKeyboard = true
            local _, mx, my = shove.mouseToViewport()
            game.pauseMenuLastMouseX = mx
            game.pauseMenuLastMouseY = my
            return
        end
    end

    if game.paused then
        if key == "up" or key == "w" then
            game.pauseMenuUseKeyboard = true
            game.pauseMenuSelected = game.pauseMenuSelected - 1
            if game.pauseMenuSelected < 1 then game.pauseMenuSelected = 3 end
            playSound(sounds.cursor)
        elseif key == "down" or key == "s" then
            game.pauseMenuUseKeyboard = true
            game.pauseMenuSelected = game.pauseMenuSelected + 1
            if game.pauseMenuSelected > 3 then game.pauseMenuSelected = 1 end
            playSound(sounds.cursor)
        elseif key == "return" or key == "space" then
            if game.pauseMenuSelected == 1 then -- Resume
                playSound(sounds.back)
                game.paused = false
            elseif game.pauseMenuSelected == 2 then -- Settings
                playSound(sounds.select)
                game.paused = false
                settingsReturnState = "game"
                resetSettingsState()
                gameState = "settings"
            elseif game.pauseMenuSelected == 3 then -- Quit
                playSound(sounds.back)
                resetMenuState()
                gameState = "menu"
            end
        end
        return
    end

    if game.popup or #game.animations > 0 then
        return
    end

    if not game.selectedTile then
        -- Navigate board
        if not game.hoverTile then
            game.hoverTile = {x = 1, y = 1}
        end

        if (key == "up" or key == "w") and game.hoverTile.y > 1 then
            game.hoverTile.y = game.hoverTile.y - 1
        elseif (key == "down" or key == "s") and game.hoverTile.y < BOARD_SIZE then
            game.hoverTile.y = game.hoverTile.y + 1
        elseif (key == "left" or key == "a") and game.hoverTile.x > 1 then
            game.hoverTile.x = game.hoverTile.x - 1
        elseif (key == "right" or key == "d") and game.hoverTile.x < BOARD_SIZE then
            game.hoverTile.x = game.hoverTile.x + 1
        elseif key == "space" or key == "return" then
            game.selectedTile = {x = game.hoverTile.x, y = game.hoverTile.y}
            playSound(sounds.tileup)
        end
    else
        -- Move selected tile preview
        if not game.keyboardDragPos then
            game.keyboardDragPos = {x = game.selectedTile.x, y = game.selectedTile.y}
        end

        local startX, startY = game.selectedTile.x, game.selectedTile.y
        local dragX, dragY = game.keyboardDragPos.x, game.keyboardDragPos.y

        if key == "escape" then
            syncTilePositions()
            game.selectedTile = nil
            game.keyboardDragPos = nil
            return
        elseif key == "space" or key == "return" then
            -- Try to drop the tile here
            if (dragX ~= startX or dragY ~= startY) and
               isValidMove(game.board, startX, startY, dragX, dragY) then
                moveTile(game.board, startX, startY, dragX, dragY)
                syncTilePositions()
                game.hoverTile = {x = dragX, y = dragY}
                game.selectedTile = nil
                game.keyboardDragPos = nil
                playSound(sounds.tiledown)
                return
            else
                -- Cancel invalid move
                syncTilePositions()
                game.selectedTile = nil
                game.keyboardDragPos = nil
                playSound(sounds.tiledown)
                return
            end
        end

        -- Move tile along its row or column
        local newDragX, newDragY = dragX, dragY

        -- Can only move vertically if still in original column
        if (key == "up" or key == "w") and dragY > 1 and dragX == startX then
            newDragY = dragY - 1
            newDragX = startX
        elseif (key == "down" or key == "s") and dragY < BOARD_SIZE and dragX == startX then
            newDragY = dragY + 1
            newDragX = startX
        -- Can only move horizontally if still in original row
        elseif (key == "left" or key == "a") and dragX > 1 and dragY == startY then
            newDragX = dragX - 1
            newDragY = startY
        elseif (key == "right" or key == "d") and dragX < BOARD_SIZE and dragY == startY then
            newDragX = dragX + 1
            newDragY = startY
        end

        -- Update preview
        if newDragX ~= dragX or newDragY ~= dragY then
            game.keyboardDragPos.x = newDragX
            game.keyboardDragPos.y = newDragY
            simulateTileSlide(startX, startY, newDragX, newDragY)
        end
    end
end

function gameMouseMoved(x, y)
    if not game.dragTile then
        local mx, my = getTileAtPosition(x, y)
        if mx and my then
            game.hoverTile = {x = mx, y = my}
        end
    end

    if game.dragTile then
        local startTx, startTy = getTilePosition(game.dragTile.startX, game.dragTile.startY)
        local moveThreshold = TILE_SIZE / 2

        local deltaX = x - startTx - TILE_SIZE / 2
        local deltaY = y - startTy - TILE_SIZE / 2

        if not game.dragTile.constrainToRow and not game.dragTile.constrainToCol then
            if math.abs(deltaX) > math.abs(deltaY) and math.abs(deltaX) > moveThreshold then
                game.dragTile.constrainToRow = true
            elseif math.abs(deltaY) > math.abs(deltaX) and math.abs(deltaY) > moveThreshold then
                game.dragTile.constrainToCol = true
            end
        end

        -- Clamp to board bounds
        local topLeftX, topLeftY = getTilePosition(1, 1)
        local bottomRightX, bottomRightY = getTilePosition(BOARD_SIZE, BOARD_SIZE)

        local boardLeft = topLeftX + TILE_SIZE / 2
        local boardTop = topLeftY + TILE_SIZE / 2
        local boardRight = bottomRightX + TILE_SIZE / 2
        local boardBottom = bottomRightY + TILE_SIZE / 2

        game.dragTile.x = math.max(boardLeft, math.min(boardRight, x))
        game.dragTile.y = math.max(boardTop, math.min(boardBottom, y))

        if game.dragTile.constrainToRow or game.dragTile.constrainToCol then
            local newGridX, newGridY

            if game.dragTile.constrainToRow then
                newGridY = game.dragTile.startY
                local relX = (x - 9) / (TILE_SIZE + 1)
                newGridX = math.max(1, math.min(BOARD_SIZE, math.floor(relX) + 1))
            elseif game.dragTile.constrainToCol then
                newGridX = game.dragTile.startX
                local relY = (y - 12) / (TILE_SIZE + 1)
                newGridY = math.max(1, math.min(BOARD_SIZE, math.floor(relY) + 1))
            end

            if newGridX and newGridY then
                if game.dragTile.constrainToRow and newGridX ~= game.dragTile.gridX then
                    simulateTileSlide(game.dragTile.startX, game.dragTile.startY, newGridX, newGridY)
                    game.dragTile.gridX = newGridX
                elseif game.dragTile.constrainToCol and newGridY ~= game.dragTile.gridY then
                    simulateTileSlide(game.dragTile.startX, game.dragTile.startY, newGridX, newGridY)
                    game.dragTile.gridY = newGridY
                end
            end
        end
    end
end

function simulateTileSlide(fromX, fromY, toX, toY)
    -- Original position, reset
    if toX == fromX and toY == fromY then
        syncTilePositions()
        return
    end

    -- Reset tile positions in the row/column
    if fromY == toY then
        for x = 1, BOARD_SIZE do
            local tx, ty = getTilePosition(x, fromY)
            game.tilePositions[fromY][x].targetX = tx
            game.tilePositions[fromY][x].targetY = ty
        end
    elseif fromX == toX then
        for y = 1, BOARD_SIZE do
            local tx, ty = getTilePosition(fromX, y)
            game.tilePositions[y][fromX].targetX = tx
            game.tilePositions[y][fromX].targetY = ty
        end
    end

    -- Shift tiles to make space
    if fromY == toY then
        if toX > fromX then
            -- Dragging right: shift tiles between fromX+1 and toX to the left
            for x = fromX + 1, toX do
                local tx, ty = getTilePosition(x - 1, fromY)
                game.tilePositions[fromY][x].targetX = tx
                game.tilePositions[fromY][x].targetY = ty
            end
        else
            -- Dragging left: shift tiles between toX and fromX-1 to the right
            for x = toX, fromX - 1 do
                local tx, ty = getTilePosition(x + 1, fromY)
                game.tilePositions[fromY][x].targetX = tx
                game.tilePositions[fromY][x].targetY = ty
            end
        end
    elseif fromX == toX then
        if toY > fromY then
            -- Dragging down: shift tiles between fromY+1 and toY up
            for y = fromY + 1, toY do
                local tx, ty = getTilePosition(fromX, y - 1)
                game.tilePositions[y][fromX].targetX = tx
                game.tilePositions[y][fromX].targetY = ty
            end
        else
            -- Dragging up: shift tiles between toY and fromY-1 down
            for y = toY, fromY - 1 do
                local tx, ty = getTilePosition(fromX, y + 1)
                game.tilePositions[y][fromX].targetX = tx
                game.tilePositions[y][fromX].targetY = ty
            end
        end
    end
end

function processMelds(melds)
    for _, meld in ipairs(melds) do
        table.insert(game.hand, meld)

        local sumX, sumY = 0, 0
        for _, pos in ipairs(meld.positions) do
            local tx, ty = getTilePosition(pos.x, pos.y)
            createDissolveEffect(tx, ty, game.board[pos.y][pos.x])

            game.board[pos.y][pos.x] = nil
            sumX = sumX + tx
            sumY = sumY + ty
        end

        local meldType = getMeldType(meld)
        if settings.language == "en" then
            local names = {chi = "Run!", pon = "Triplet!", kan = "Quad!"}
            game.popup = names[meldType]
        else
            local names = {chi = "Chi!", pon = "Pon!", kan = "Kan!"}
            game.popup = names[meldType]
        end
        game.popupTimer = 1.0
        game.popupX = sumX / #meld.positions + TILE_SIZE / 2

        -- If meld is on the top row, popup below instead of above
        local avgY = sumY / #meld.positions
        local topRowY = getTilePosition(1, 1)
        local _, topRowYPos = topRowY, select(2, getTilePosition(1, 1))

        if avgY <= topRowYPos + TILE_SIZE then
            game.popupY = avgY + TILE_SIZE + 15
        else
            game.popupY = avgY - 40
        end

        if #game.hand < 4 then
            playSound(sounds[meldType])
        end

        if meldType == "kan" then
            game.kanCount = game.kanCount + 1
            table.insert(game.doraIndicators, generateRandomTile(true))
        end
    end

    if #game.hand == 4 then
        game.popup = "Tsumatch!"
        game.popupTimer = 1.5
        game.popupX = 110
        game.popupY = 100
        playSound(sounds.tsumo)

        table.insert(game.animations, {
            type = "handComplete",
            timer = 0,
            duration = 1.5
        })
    end
end

function dropTiles()
    for x = 1, BOARD_SIZE do
        local writeY = BOARD_SIZE
        for y = BOARD_SIZE, 1, -1 do
            if game.board[y][x] then
                if y ~= writeY then
                    game.board[writeY][x] = game.board[y][x]
                    game.board[y][x] = nil

                    local tx, ty = getTilePosition(x, writeY)
                    game.tilePositions[y][x].targetX = tx
                    game.tilePositions[y][x].targetY = ty
                    game.tilePositions[writeY][x] = game.tilePositions[y][x]
                    game.tilePositions[y][x] = {x = tx, y = ty, targetX = tx, targetY = ty}
                end
                writeY = writeY - 1
            end
        end
    end
end

function fillBoard()
    for x = 1, BOARD_SIZE do
        for y = 1, BOARD_SIZE do
            if not game.board[y][x] then
                game.board[y][x] = generateRandomTile()
                local tx, ty = getTilePosition(x, y)
                game.tilePositions[y][x].x = tx
                game.tilePositions[y][x].y = ty - 240
                game.tilePositions[y][x].targetX = tx
                game.tilePositions[y][x].targetY = ty
            end
        end
    end
end

function initializeTilePositions()
    game.tilePositions = {}
    for y = 1, BOARD_SIZE do
        game.tilePositions[y] = {}
        for x = 1, BOARD_SIZE do
            local tx, ty = getTilePosition(x, y)
            game.tilePositions[y][x] = {x = tx, y = ty, targetX = tx, targetY = ty}
        end
    end
end

function updateTilePositions(dt)
    local animSpeed = 400
    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            if game.tilePositions[y] and game.tilePositions[y][x] then
                local pos = game.tilePositions[y][x]
                local dx = pos.targetX - pos.x
                local dy = pos.targetY - pos.y
                local dist = math.sqrt(dx * dx + dy * dy)

                if dist > 0.5 then
                    local moveAmount = math.min(animSpeed * dt, dist)
                    pos.x = pos.x + (dx / dist) * moveAmount
                    pos.y = pos.y + (dy / dist) * moveAmount
                else
                    pos.x = pos.targetX
                    pos.y = pos.targetY
                end
            end
        end
    end
end

function syncTilePositions()
    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            if game.tilePositions[y] and game.tilePositions[y][x] then
                local tx, ty = getTilePosition(x, y)
                game.tilePositions[y][x].targetX = tx
                game.tilePositions[y][x].targetY = ty
            end
        end
    end
end

function shuffleBoard()
    local tiles = {}
    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            if game.board[y][x] then
                table.insert(tiles, game.board[y][x])
            end
        end
    end

    for i = #tiles, 2, -1 do
        local j = math.random(i)
        tiles[i], tiles[j] = tiles[j], tiles[i]
    end

    local index = 1
    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            game.board[y][x] = tiles[index]
            index = index + 1
        end
    end

    syncTilePositions()
end

function nextRound()
    game.round = game.round + 1

    if game.round > maxRounds then
        if isTopTen(game.score, maxRounds) then
            gameState = "nameEntry"
            nameEntry = "_"
            nameEntryCursor = 1
            nameEntrySubmitSelected = false
        else
            leaderboardPage = maxRounds == 8 and 1 or 2
            gameState = "finalScore"
        end
        return
    end

    -- Switch to South wind halfway through hanchan
    if maxRounds == 8 and game.round == 5 then
        game.roundWind = 2
    end

    game.board = createBoard()
    game.hand = {}
    game.doraIndicators = {generateRandomTile(true)}
    game.kanCount = 0
    game.selectedTile = nil
    game.hoverTile = nil

    initializeTilePositions()

    gameState = "game"
end

function createDissolveEffect(tileX, tileY, tile)
    -- Split tile into 4x4 pieces
    local pieceSize = TILE_SIZE / 4

    for py = 0, 3 do
        for px = 0, 3 do
            local particle = {
                x = tileX + px * pieceSize,
                y = tileY + py * pieceSize,
                vx = (math.random() - 0.5) * 80,
                vy = (math.random() - 0.5) * 80 - 30,
                life = 1.0,
                fadeSpeed = 1.5 + math.random() * 0.5,
                quad = getTileQuad(tile),
                quadX = px * pieceSize,
                quadY = py * pieceSize,
                size = pieceSize
            }
            table.insert(game.particles, particle)
        end
    end
end

function updateParticles(dt)
    for i = #game.particles, 1, -1 do
        local p = game.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 150 * dt  -- Gravity
        p.life = p.life - p.fadeSpeed * dt

        if p.life <= 0 then
            table.remove(game.particles, i)
        end
    end
end

function drawParticles()
    for _, p in ipairs(game.particles) do
        love.graphics.setColor(1, 1, 1, math.max(0, p.life))

        -- Sub-quad for piece of the tile
        local imgW, imgH = tilesheetImage:getDimensions()
        local qx, qy = p.quad:getViewport()
        local subQuad = love.graphics.newQuad(
            qx + p.quadX,
            qy + p.quadY,
            p.size,
            p.size,
            imgW, imgH
        )

        love.graphics.draw(tilesheetImage, subQuad, p.x, p.y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end
