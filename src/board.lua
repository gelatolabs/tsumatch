BOARD_SIZE = 8

TILE_SET = {
    {1, "m"}, {5, "m"}, {9, "m"},
    {1, "p"}, {5, "p"}, {9, "p"},
    {1, "s"}, {2, "s"}, {3, "s"}, {4, "s"}, {5, "s"}, {6, "s"}, {7, "s"}, {8, "s"}, {9, "s"},
    {1, "z"}, {2, "z"}, {3, "z"}, {4, "z"}, {5, "z"}, {6, "z"}, {7, "z"},
    {0, "m"}, {0, "p"}, {0, "s"}
}

function createBoard()
    local board = {}

    -- Generate initial random board
    for y = 1, BOARD_SIZE do
        board[y] = {}
        for x = 1, BOARD_SIZE do
            board[y][x] = generateRandomTile()
        end
    end

    -- Find melds and randomize their tiles until none remain
    local melds = findMelds(board)
    while #melds > 0 do
        for _, meld in ipairs(melds) do
            for _, pos in ipairs(meld.positions) do
                board[pos.y][pos.x] = generateRandomTile()
            end
        end
        melds = findMelds(board)
    end

    return board
end

function generateRandomTile(noRed5)
    local tilePool = {}

    for _, tile in ipairs(TILE_SET) do
        local num, suit = tile[1], tile[2]
        if not (noRed5 and num == 0) then
            -- 1x red 5s, 3x regular 5s, 4x others
            local copies = (num == 0) and 1 or ((num == 5) and 3 or 4)
            for j = 1, copies do
                table.insert(tilePool, {num, suit})
            end
        end
    end

    return tilePool[math.random(#tilePool)]
end

function checkSequence(t1, t2, t3)
    if t1[2] ~= t2[2] or t2[2] ~= t3[2] or t1[2] == "z" then
        return false
    end

    local n1 = t1[1] == 0 and 5 or t1[1]
    local n2 = t2[1] == 0 and 5 or t2[1]
    local n3 = t3[1] == 0 and 5 or t3[1]

    -- Check ascending
    if n1 + 1 == n2 and n2 + 1 == n3 then
        return true
    end

    -- Check descending
    if n1 - 1 == n2 and n2 - 1 == n3 then
        return true
    end

    return false
end

function checkTriplet(t1, t2, t3)
    local n1 = t1[1] == 0 and 5 or t1[1]
    local n2 = t2[1] == 0 and 5 or t2[1]
    local n3 = t3[1] == 0 and 5 or t3[1]

    return t1[2] == t2[2] and t2[2] == t3[2] and n1 == n2 and n2 == n3
end

function getTilePosition(x, y)
    return 9 + (x - 1) * (TILE_SIZE + 1), 12 + (y - 1) * (TILE_SIZE + 1)
end

function getTileAtPosition(mx, my)
    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            local tx, ty = getTilePosition(x, y)
            if mx >= tx and mx < tx + TILE_SIZE and my >= ty and my < ty + TILE_SIZE then
                return x, y
            end
        end
    end
    return nil, nil
end

function drawTileBorder(x, y)
    -- 28x28 border with 3 corner pixels cut out from each corner
    local offset = -1
    local baseX = x + offset
    local baseY = y + offset

    -- Top row
    love.graphics.rectangle("fill", baseX + 2, baseY, 24, 1)

    -- Second row
    love.graphics.rectangle("fill", baseX + 1, baseY + 1, 26, 1)

    -- Middle rows
    love.graphics.rectangle("fill", baseX, baseY + 2, 28, 24)

    -- Second to bottom row
    love.graphics.rectangle("fill", baseX + 1, baseY + 26, 26, 1)

    -- Bottom row
    love.graphics.rectangle("fill", baseX + 2, baseY + 27, 24, 1)
end

function drawBoard(board, dragTile, highlightRow, highlightCol, doraIndicators, tilePositions, selectedTile, hoverTile)
    -- Highlight row or column brighter based on drag direction
    local rowAlpha, colAlpha = 0.5, 0.5
    if dragTile then
        if dragTile.constrainToRow then
            rowAlpha = 0.6
            colAlpha = 0.3
        elseif dragTile.constrainToCol then
            rowAlpha = 0.3
            colAlpha = 0.6
        end
    end

    if highlightRow then
        local tx1, ty = getTilePosition(1, highlightRow)
        local tx2, _ = getTilePosition(BOARD_SIZE, highlightRow)
        love.graphics.setColor(1, 1, 0, rowAlpha)
        love.graphics.rectangle("fill", tx1 - 1, ty - 1, (tx2 + TILE_SIZE) - tx1 + 2, TILE_SIZE + 2)
    end

    if highlightCol then
        local tx, ty1 = getTilePosition(highlightCol, 1)
        local _, ty2 = getTilePosition(highlightCol, BOARD_SIZE)
        love.graphics.setColor(1, 1, 0, colAlpha)
        love.graphics.rectangle("fill", tx - 1, ty1 - 1, TILE_SIZE + 2, (ty2 + TILE_SIZE) - ty1 + 2)
    end

    love.graphics.setColor(1, 1, 1)

    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE do
            if board[y][x] then
                local isDragged = dragTile and dragTile.startX == x and dragTile.startY == y
                if not isDragged then
                    local tx, ty
                    if tilePositions and tilePositions[y] and tilePositions[y][x] then
                        tx = tilePositions[y][x].x
                        ty = tilePositions[y][x].y
                    else
                        tx, ty = getTilePosition(x, y)
                    end

                    local isDora = false
                    if doraIndicators then
                        for _, dora in ipairs(doraIndicators) do
                            if tileEquals(board[y][x], dora) then
                                isDora = true
                                break
                            end
                        end
                    end

                    -- Shake hint tiles
                    local shakeX, shakeY = 0, 0
                    if game.hintPositions and game.hintShakeTime > 0 and game.hintShakeTime < 3 then
                        for tileIndex, pos in ipairs(game.hintPositions) do
                            if pos.x == x and pos.y == y then
                                local shakeAmount = 1
                                local shakeSpeed = 10
                                local phaseOffset = (tileIndex - 1) * 1.5  -- Different phase for each tile
                                shakeX = math.floor(math.sin(game.hintShakeTime * shakeSpeed + phaseOffset) * shakeAmount + 0.5)
                                shakeY = math.floor(math.cos(game.hintShakeTime * shakeSpeed * 1.3 + phaseOffset) * shakeAmount + 0.5)
                                break
                            end
                        end
                    end

                    -- Borders (selection/hover overrides dora)
                    if selectedTile and selectedTile.x == x and selectedTile.y == y then
                        love.graphics.setColor(0.5, 1, 0.5, 1)
                        drawTileBorder(tx + shakeX, ty + shakeY)
                        love.graphics.setColor(1, 1, 1)
                    elseif hoverTile and hoverTile.x == x and hoverTile.y == y then
                        love.graphics.setColor(0.3, 0.8, 0.3, 1)
                        drawTileBorder(tx + shakeX, ty + shakeY)
                        love.graphics.setColor(1, 1, 1)
                    elseif isDora then
                        local pulseAlpha = 0.4 + math.abs(math.sin(game.doraPulseTime * 1.2)) * 0.2
                        love.graphics.setColor(1, 0.8, 0, pulseAlpha)
                        drawTileBorder(tx + shakeX, ty + shakeY)
                        love.graphics.setColor(1, 1, 1)
                    end

                    love.graphics.draw(tilesheetImage, getTileQuad(board[y][x]), tx + shakeX, ty + shakeY)
                end
            end
        end
    end

    if dragTile then
        local dragX, dragY
        if dragTile.constrainToRow then
            dragX = dragTile.x - TILE_SIZE / 2
            local _, gridY = getTilePosition(dragTile.gridX, dragTile.gridY)
            dragY = gridY
        elseif dragTile.constrainToCol then
            local gridX, _ = getTilePosition(dragTile.gridX, dragTile.gridY)
            dragX = gridX
            dragY = dragTile.y - TILE_SIZE / 2
        else
            dragX = dragTile.x - TILE_SIZE / 2
            dragY = dragTile.y - TILE_SIZE / 2
        end

        love.graphics.setColor(0.5, 1, 0.5, 1)
        drawTileBorder(dragX, dragY)
        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(tilesheetImage, getTileQuad(dragTile.tile), dragX, dragY)
    end
end

function isValidMove(board, fromX, fromY, toX, toY)
    if fromX == toX and fromY == toY then
        return false
    end

    local testBoard = {}
    for y = 1, BOARD_SIZE do
        testBoard[y] = {}
        for x = 1, BOARD_SIZE do
            testBoard[y][x] = board[y][x]
        end
    end

    moveTile(testBoard, fromX, fromY, toX, toY)

    local melds = findMelds(testBoard)
    return #melds > 0
end

function moveTile(board, fromX, fromY, toX, toY)
    if fromX == toX and fromY == toY then
        return false
    end

    local tile = board[fromY][fromX]

    if fromY == toY then
        if toX > fromX then
            for x = fromX, toX - 1 do
                board[fromY][x] = board[fromY][x + 1]
            end
        else
            for x = fromX, toX + 1, -1 do
                board[fromY][x] = board[fromY][x - 1]
            end
        end
        board[toY][toX] = tile
    elseif fromX == toX then
        if toY > fromY then
            for y = fromY, toY - 1 do
                board[y][fromX] = board[y + 1][fromX]
            end
        else
            for y = fromY, toY + 1, -1 do
                board[y][fromX] = board[y - 1][fromX]
            end
        end
        board[toY][toX] = tile
    end

    return true
end
