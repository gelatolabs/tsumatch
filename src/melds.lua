function findMelds(board)
    local melds = {}

    for y = 1, BOARD_SIZE do
        for x = 1, BOARD_SIZE - 3 do
            if board[y][x] and board[y][x+1] and board[y][x+2] and board[y][x+3] then
                if checkQuad(board[y][x], board[y][x+1], board[y][x+2], board[y][x+3]) then
                    table.insert(melds, {
                        tiles = {board[y][x], board[y][x+1], board[y][x+2], board[y][x+3]},
                        positions = {{x = x, y = y}, {x = x+1, y = y}, {x = x+2, y = y}, {x = x+3, y = y}}
                    })
                end
            end
        end

        for x = 1, BOARD_SIZE - 2 do
            if board[y][x] and board[y][x+1] and board[y][x+2] then
                if checkSequence(board[y][x], board[y][x+1], board[y][x+2]) then
                    table.insert(melds, {
                        tiles = {board[y][x], board[y][x+1], board[y][x+2]},
                        positions = {{x = x, y = y}, {x = x+1, y = y}, {x = x+2, y = y}}
                    })
                elseif checkTriplet(board[y][x], board[y][x+1], board[y][x+2]) then
                    table.insert(melds, {
                        tiles = {board[y][x], board[y][x+1], board[y][x+2]},
                        positions = {{x = x, y = y}, {x = x+1, y = y}, {x = x+2, y = y}}
                    })
                end
            end
        end
    end

    for x = 1, BOARD_SIZE do
        for y = 1, BOARD_SIZE - 3 do
            if board[y][x] and board[y+1][x] and board[y+2][x] and board[y+3][x] then
                if checkQuad(board[y][x], board[y+1][x], board[y+2][x], board[y+3][x]) then
                    table.insert(melds, {
                        tiles = {board[y][x], board[y+1][x], board[y+2][x], board[y+3][x]},
                        positions = {{x = x, y = y}, {x = x, y = y+1}, {x = x, y = y+2}, {x = x, y = y+3}}
                    })
                end
            end
        end

        for y = 1, BOARD_SIZE - 2 do
            if board[y][x] and board[y+1][x] and board[y+2][x] then
                if checkSequence(board[y][x], board[y+1][x], board[y+2][x]) then
                    table.insert(melds, {
                        tiles = {board[y][x], board[y+1][x], board[y+2][x]},
                        positions = {{x = x, y = y}, {x = x, y = y+1}, {x = x, y = y+2}}
                    })
                elseif checkTriplet(board[y][x], board[y+1][x], board[y+2][x]) then
                    table.insert(melds, {
                        tiles = {board[y][x], board[y+1][x], board[y+2][x]},
                        positions = {{x = x, y = y}, {x = x, y = y+1}, {x = x, y = y+2}}
                    })
                end
            end
        end
    end

    return melds
end

function checkQuad(t1, t2, t3, t4)
    local n1 = t1[1] == 0 and 5 or t1[1]
    local n2 = t2[1] == 0 and 5 or t2[1]
    local n3 = t3[1] == 0 and 5 or t3[1]
    local n4 = t4[1] == 0 and 5 or t4[1]

    return t1[2] == t2[2] and t2[2] == t3[2] and t3[2] == t4[2] and
           n1 == n2 and n2 == n3 and n3 == n4
end

function getMeldType(meld)
    if #meld.tiles == 4 then
        return "kan"
    elseif checkTriplet(meld.tiles[1], meld.tiles[2], meld.tiles[3]) then
        return "pon"
    else
        return "chi"
    end
end

function findMove(board, BOARD_SIZE)
    local function tilesMatch(t1, t2)
        if not t1 or not t2 then return false end
        local n1 = t1[1] == 0 and 5 or t1[1]
        local n2 = t2[1] == 0 and 5 or t2[1]
        return n1 == n2 and t1[2] == t2[2]
    end

    local function tilesConsecutive(t1, t2)
        if not t1 or not t2 then return false end
        if t1[2] ~= t2[2] then return false end
        local n1 = t1[1] == 0 and 5 or t1[1]
        local n2 = t2[1] == 0 and 5 or t2[1]
        return math.abs(n1 - n2) == 1
    end

    local function tilesAlmostConsecutive(t1, t2)
        if not t1 or not t2 then return false end
        if t1[2] ~= t2[2] then return false end
        local n1 = t1[1] == 0 and 5 or t1[1]
        local n2 = t2[1] == 0 and 5 or t2[1]
        return math.abs(n1 - n2) == 2
    end

    ---@param t table
    ---@return number
    local function getTileNumber(t)
        return t[1] == 0 and 5 or t[1]
    end

    -- Start from random position and loop back around
    local startY = math.random(1, BOARD_SIZE)
    local startX = math.random(1, BOARD_SIZE)

    for offset = 0, BOARD_SIZE * BOARD_SIZE - 1 do
        local index = ((startY - 1) * BOARD_SIZE + (startX - 1) + offset) % (BOARD_SIZE * BOARD_SIZE)
        local y = math.floor(index / BOARD_SIZE) + 1
        local x = (index % BOARD_SIZE) + 1

        if board[y][x] then
            -- Check next horizontal tile
            if x < BOARD_SIZE and board[y][x+1] then
                -- Two adjacent tiles
                if tilesMatch(board[y][x], board[y][x+1]) then
                    -- Look for potential kan patterns (tile-tile-gap-tile and tile-gap-tile-tile)
                    if x + 3 <= BOARD_SIZE and board[y][x+3] and tilesMatch(board[y][x], board[y][x+3]) then
                        -- Look for 4th identical tile in the gap column
                        for checkY = 1, BOARD_SIZE do
                            if checkY ~= y and board[checkY][x+2] and tilesMatch(board[y][x], board[checkY][x+2]) then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=x+2, y=checkY}, {x=x+3, y=y}}
                            end
                        end
                    end
                    if x + 3 <= BOARD_SIZE and board[y][x+2] and board[y][x+3] and tilesMatch(board[y][x], board[y][x+2]) and tilesMatch(board[y][x], board[y][x+3]) then
                        for checkY = 1, BOARD_SIZE do
                            if checkY ~= y and board[checkY][x+1] and tilesMatch(board[y][x], board[checkY][x+1]) then
                                return {{x=x, y=y}, {x=x+1, y=checkY}, {x=x+2, y=y}, {x=x+3, y=y}}
                            end
                        end
                    end
                    -- Look for 3rd identical tile in same row (pon)
                    for checkX = 1, BOARD_SIZE do
                        if checkX ~= x and checkX ~= x+1 and board[y][checkX] and tilesMatch(board[y][x], board[y][checkX]) then
                            return {{x=x, y=y}, {x=x+1, y=y}, {x=checkX, y=y}}
                        end
                    end
                    -- Look for 3rd tile in adjacent columns
                    if x > 1 then
                        for checkY = 1, BOARD_SIZE do
                            if checkY ~= y and board[checkY][x-1] and tilesMatch(board[y][x], board[checkY][x-1]) then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=x-1, y=checkY}}
                            end
                        end
                    end
                    if x + 2 <= BOARD_SIZE then
                        for checkY = 1, BOARD_SIZE do
                            if checkY ~= y and board[checkY][x+2] and tilesMatch(board[y][x], board[checkY][x+2]) then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=x+2, y=checkY}}
                            end
                        end
                    end
                elseif tilesConsecutive(board[y][x], board[y][x+1]) and board[y][x][2] ~= "z" then
                    -- Look for 3rd consecutive tile in same row (chi)
                    for checkX = 1, BOARD_SIZE do
                        if checkX ~= x and checkX ~= x+1 and board[y][checkX] then
                            if checkSequence(board[y][x], board[y][x+1], board[y][checkX]) then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=checkX, y=y}}
                            end
                        end
                    end
                    -- Check adjacent columns
                    local n1 = getTileNumber(board[y][x])
                    local n2 = getTileNumber(board[y][x+1])
                    local needBefore = n1 < n2 and (n1 - 1) or (n1 + 1)
                    local needAfter = n2 < n1 and (n2 - 1) or (n2 + 1)

                    -- Check column before x
                    if x > 1 and needBefore >= 1 and needBefore <= 9 then
                        if y > 1 and board[y-1][x-1] then
                            local n3 = getTileNumber(board[y-1][x-1])
                            if board[y-1][x-1][2] == board[y][x][2] and n3 == needBefore then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=x-1, y=y-1}}
                            end
                        end
                        if y < BOARD_SIZE and board[y+1][x-1] then
                            local n3 = getTileNumber(board[y+1][x-1])
                            if board[y+1][x-1][2] == board[y][x][2] and n3 == needBefore then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=x-1, y=y+1}}
                            end
                        end
                    end
                    -- Check column after x+1
                    if x + 2 <= BOARD_SIZE and needAfter >= 1 and needAfter <= 9 then
                        if y > 1 and board[y-1][x+2] then
                            local n3 = getTileNumber(board[y-1][x+2])
                            if board[y-1][x+2][2] == board[y][x][2] and n3 == needAfter then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=x+2, y=y-1}}
                            end
                        end
                        if y < BOARD_SIZE and board[y+1][x+2] then
                            local n3 = getTileNumber(board[y+1][x+2])
                            if board[y+1][x+2][2] == board[y][x][2] and n3 == needAfter then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=x+2, y=y+1}}
                            end
                        end
                    end
                elseif tilesAlmostConsecutive(board[y][x], board[y][x+1]) and board[y][x][2] ~= "z" then
                    -- Look for middle tile in same row
                    for checkX = 1, BOARD_SIZE do
                        if checkX ~= x and checkX ~= x+1 and board[y][checkX] then
                            if checkSequence(board[y][x], board[y][checkX], board[y][x+1]) or
                               checkSequence(board[y][x+1], board[y][checkX], board[y][x]) then
                                return {{x=x, y=y}, {x=x+1, y=y}, {x=checkX, y=y}}
                            end
                        end
                    end
                end
            end

            -- Check next vertical tile
            if y < BOARD_SIZE and board[y+1][x] then
                if tilesMatch(board[y][x], board[y+1][x]) then
                    if y + 3 <= BOARD_SIZE and board[y+3][x] and tilesMatch(board[y][x], board[y+3][x]) then
                        for checkX = 1, BOARD_SIZE do
                            if checkX ~= x and board[y+2][checkX] and tilesMatch(board[y][x], board[y+2][checkX]) then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=checkX, y=y+2}, {x=x, y=y+3}}
                            end
                        end
                    end
                    if y + 3 <= BOARD_SIZE and board[y+2][x] and board[y+3][x] and tilesMatch(board[y][x], board[y+2][x]) and tilesMatch(board[y][x], board[y+3][x]) then
                        for checkX = 1, BOARD_SIZE do
                            if checkX ~= x and board[y+1][checkX] and tilesMatch(board[y][x], board[y+1][checkX]) then
                                return {{x=x, y=y}, {x=checkX, y=y+1}, {x=x, y=y+2}, {x=x, y=y+3}}
                            end
                        end
                    end
                    for checkY = 1, BOARD_SIZE do
                        if checkY ~= y and checkY ~= y+1 and board[checkY][x] and tilesMatch(board[y][x], board[checkY][x]) then
                            return {{x=x, y=y}, {x=x, y=y+1}, {x=x, y=checkY}}
                        end
                    end
                    if y > 1 then
                        for checkX = 1, BOARD_SIZE do
                            if checkX ~= x and board[y-1][checkX] and tilesMatch(board[y][x], board[y-1][checkX]) then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=checkX, y=y-1}}
                            end
                        end
                    end
                    if y + 2 <= BOARD_SIZE then
                        for checkX = 1, BOARD_SIZE do
                            if checkX ~= x and board[y+2][checkX] and tilesMatch(board[y][x], board[y+2][checkX]) then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=checkX, y=y+2}}
                            end
                        end
                    end
                elseif tilesConsecutive(board[y][x], board[y+1][x]) and board[y][x][2] ~= "z" then
                    for checkY = 1, BOARD_SIZE do
                        if checkY ~= y and checkY ~= y+1 and board[checkY][x] then
                            if checkSequence(board[y][x], board[y+1][x], board[checkY][x]) then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=x, y=checkY}}
                            end
                        end
                    end
                    local n1 = getTileNumber(board[y][x])
                    local n2 = getTileNumber(board[y+1][x])
                    local needBefore = n1 < n2 and (n1 - 1) or (n1 + 1)
                    local needAfter = n2 < n1 and (n2 - 1) or (n2 + 1)

                    if y > 1 and needBefore >= 1 and needBefore <= 9 then
                        if x > 1 and board[y-1][x-1] then
                            local n3 = getTileNumber(board[y-1][x-1])
                            if board[y-1][x-1][2] == board[y][x][2] and n3 == needBefore then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=x-1, y=y-1}}
                            end
                        end
                        if x < BOARD_SIZE and board[y-1][x+1] then
                            local n3 = getTileNumber(board[y-1][x+1])
                            if board[y-1][x+1][2] == board[y][x][2] and n3 == needBefore then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=x+1, y=y-1}}
                            end
                        end
                    end
                    if y + 2 <= BOARD_SIZE and needAfter >= 1 and needAfter <= 9 then
                        if x > 1 and board[y+2][x-1] then
                            local n3 = getTileNumber(board[y+2][x-1])
                            if board[y+2][x-1][2] == board[y][x][2] and n3 == needAfter then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=x-1, y=y+2}}
                            end
                        end
                        if x < BOARD_SIZE and board[y+2][x+1] then
                            local n3 = getTileNumber(board[y+2][x+1])
                            if board[y+2][x+1][2] == board[y][x][2] and n3 == needAfter then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=x+1, y=y+2}}
                            end
                        end
                    end
                elseif tilesAlmostConsecutive(board[y][x], board[y+1][x]) and board[y][x][2] ~= "z" then
                    for checkY = 1, BOARD_SIZE do
                        if checkY ~= y and checkY ~= y+1 and board[checkY][x] then
                            if checkSequence(board[y][x], board[checkY][x], board[y+1][x]) or
                               checkSequence(board[y+1][x], board[checkY][x], board[y][x]) then
                                return {{x=x, y=y}, {x=x, y=y+1}, {x=x, y=checkY}}
                            end
                        end
                    end
                end
            end

            -- Check next next horizontal tile (1-tile gap)
            if x + 2 <= BOARD_SIZE and board[y][x+2] then
                if tilesMatch(board[y][x], board[y][x+2]) then
                    -- Look for 3rd identical tile anywhere in the gap column
                    for checkY = 1, BOARD_SIZE do
                        if board[checkY][x+1] and tilesMatch(board[y][x], board[checkY][x+1]) then
                            return {{x=x, y=y}, {x=x+1, y=checkY}, {x=x+2, y=y}}
                        end
                    end
                elseif tilesAlmostConsecutive(board[y][x], board[y][x+2]) and board[y][x][2] ~= "z" then
                    -- Look for middle tile anywhere in the gap column
                    for checkY = 1, BOARD_SIZE do
                        if board[checkY][x+1] and checkSequence(board[y][x], board[checkY][x+1], board[y][x+2]) then
                            return {{x=x, y=y}, {x=x+1, y=checkY}, {x=x+2, y=y}}
                        end
                    end
                end
            end

            -- Check next next vertical tile (1-tile gap)
            if y + 2 <= BOARD_SIZE and board[y+2][x] then
                if tilesMatch(board[y][x], board[y+2][x]) then
                    for checkX = 1, BOARD_SIZE do
                        if board[y+1][checkX] and tilesMatch(board[y][x], board[y+1][checkX]) then
                            return {{x=x, y=y}, {x=checkX, y=y+1}, {x=x, y=y+2}}
                        end
                    end
                elseif tilesAlmostConsecutive(board[y][x], board[y+2][x]) and board[y][x][2] ~= "z" then
                    for checkX = 1, BOARD_SIZE do
                        if board[y+1][checkX] and checkSequence(board[y][x], board[y+1][checkX], board[y+2][x]) then
                            return {{x=x, y=y}, {x=checkX, y=y+1}, {x=x, y=y+2}}
                        end
                    end
                end
            end
        end
    end

    -- No possible moves
    return nil
end
