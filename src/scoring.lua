scoringResult = nil

function calculateScore()
    local hand = {}
    for _, meld in ipairs(game.hand) do
        for _, tile in ipairs(meld.tiles) do
            table.insert(hand, tile)
        end
    end

    sortTiles(hand)

    local yaku = detectYaku(hand, game.hand)
    local han = 0
    local isYakuman = false

    for _, y in ipairs(yaku) do
        if y.yakuman then
            isYakuman = true
        end
        han = han + y.han
    end

    if han >= 13 and not isYakuman then
        -- Kazoe yakuman
        isYakuman = true
    elseif isYakuman then
        local filteredYaku = {}
        han = 0
        for _, y in ipairs(yaku) do
            if y.yakuman then
                table.insert(filteredYaku, y)
                han = han + y.han
            end
        end
        yaku = filteredYaku
    end

    local fu = calculateFu(game.hand)

    local score = 0
    if isYakuman or han >= 13 then
        score = 32000 * math.floor(han / 13)  -- Yakuman
    elseif han >= 11 then
        score = 24000  -- Sanbaiman
    elseif han >= 8 then
        score = 16000  -- Baiman
    elseif han >= 6 then
        score = 12000  -- Haneman
    elseif han == 5 or (han == 4 and fu >= 40) or (han == 3 and fu >= 70) then
        score = 8000   -- Mangan
    else
        local basePoints = fu * 2 ^ (2 + han)
        score = math.max(basePoints * 4, 8000)
    end

    scoringResult = {
        yaku = yaku,
        han = han,
        fu = fu,
        score = score,
        isYakuman = isYakuman
    }

    game.score = game.score + score
end

function detectYaku(hand, melds)
    local yaku = {}

    table.insert(yaku, {name = "tsumatch", han = 1})

    if checkPinfu(melds) then
        table.insert(yaku, {name = "pinfu", han = 1})
    end

    local hasRyanpeikou = checkRyanpeikou(melds)
    if hasRyanpeikou then
        table.insert(yaku, {name = "ryanpeikou", han = 3})
    end

    if checkIipeikou(melds) and not hasRyanpeikou then
        table.insert(yaku, {name = "iipeikou", han = 1})
    end

    if checkTanyao(hand) then
        table.insert(yaku, {name = "tanyao", han = 1})
    end

    local hasHonroutou = checkHonroutou(hand)
    if hasHonroutou then
        table.insert(yaku, {name = "honroutou", han = 2})
    end

    local hasJunchan = checkJunchan(melds)
    if hasJunchan then
        table.insert(yaku, {name = "junchan", han = 3})
    end

    if checkChanta(melds) and not hasHonroutou and not hasJunchan then
        table.insert(yaku, {name = "chanta", han = 2})
    end

    if checkSanshokuDoujun(melds) then
        table.insert(yaku, {name = "sanshoku_doujun", han = 2})
    end

    if checkIttsu(melds) then
        table.insert(yaku, {name = "ittsu", han = 2})
    end

    if checkToitoi(melds) and not checkHonroutou(hand) then
        table.insert(yaku, {name = "toitoi", han = 2})
    end

    if checkSanshokuDoukou(melds) then
        table.insert(yaku, {name = "sanshoku_doukou", han = 2})
    end

    if checkSankantsu(melds) then
        table.insert(yaku, {name = "sankantsu", han = 2})
    end

    if checkHonitsu(hand) then
        table.insert(yaku, {name = "honitsu", han = 3})
    end

    if checkChinitsu(hand) then
        table.insert(yaku, {name = "chinitsu", han = 6})
    end

    if checkDaisangen(melds) then
        table.insert(yaku, {name = "daisangen", han = 13, yakuman = true})
    end

    local hasDaisuushii = checkDaisuushii(melds)
    if hasDaisuushii then
        table.insert(yaku, {name = "daisuushii", han = 26, yakuman = true})
    end

    if checkTsuuiisou(hand) and not hasDaisuushii then
        table.insert(yaku, {name = "tsuuiisou", han = 13, yakuman = true})
    end

    if checkChinroutou(hand) then
        table.insert(yaku, {name = "chinroutou", han = 13, yakuman = true})
    end

    if checkRyuuiisou(hand) then
        table.insert(yaku, {name = "ryuuiisou", han = 13, yakuman = true})
    end

    if checkSuukantsu(melds) then
        table.insert(yaku, {name = "suukantsu", han = 13, yakuman = true})
    end

    local yakuhaiCount, sangenpaiCount = checkYakuhai(melds, game.roundWind)
    for i = 1, yakuhaiCount do
        table.insert(yaku, {name = "yakuhai", han = 1})
    end
    for i = 1, sangenpaiCount do
        table.insert(yaku, {name = "sangenpai", han = 1})
    end

    local doraCount, akaDoraCount = countDora(hand)
    for i = 1, doraCount do
        table.insert(yaku, {name = "dora", han = 1})
    end
    for i = 1, akaDoraCount do
        table.insert(yaku, {name = "akadora", han = 1})
    end

    return yaku
end

function checkPinfu(melds)
    for _, meld in ipairs(melds) do
        if getMeldType(meld) ~= "chi" then
            return false
        end
    end
    return true
end

function checkIipeikou(melds)
    local sequences = {}
    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "chi" then
            local sorted = {meld.tiles[1], meld.tiles[2], meld.tiles[3]}
            sortTiles(sorted)
            table.insert(sequences, sorted)
        end
    end

    for i = 1, #sequences do
        for j = i + 1, #sequences do
            if tileEquals(sequences[i][1], sequences[j][1]) and
               tileEquals(sequences[i][2], sequences[j][2]) and
               tileEquals(sequences[i][3], sequences[j][3]) then
                return true
            end
        end
    end

    return false
end

function checkTanyao(hand)
    for _, tile in ipairs(hand) do
        local num = tile[1] == 0 and 5 or tile[1]
        if tile[2] == "z" or num == 1 or num == 9 then
            return false
        end
    end
    return true
end

function checkYakuhai(melds, roundWind)
    local yakuhaiCount = 0
    local sangenpaiCount = 0

    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "pon" or getMeldType(meld) == "kan" then
            local tile = meld.tiles[1]
            local num = tile[1] == 0 and 5 or tile[1]

            if tile[2] == "z" then
                if num == roundWind then
                    yakuhaiCount = yakuhaiCount + 1
                elseif num >= 5 then
                    sangenpaiCount = sangenpaiCount + 1
                end
            end
        end
    end

    return yakuhaiCount, sangenpaiCount
end

function checkChanta(melds)
    local hasHonor = false

    for _, meld in ipairs(melds) do
        local hasTerminalOrHonor = false

        for _, tile in ipairs(meld.tiles) do
            local num = tile[1] == 0 and 5 or tile[1]
            if tile[2] == "z" then
                hasTerminalOrHonor = true
                hasHonor = true
            elseif num == 1 or num == 9 then
                hasTerminalOrHonor = true
            end
        end

        if not hasTerminalOrHonor then
            return false
        end
    end

    return hasHonor
end

function checkSanshokuDoujun(melds)
    local sequences = {}
    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "chi" then
            local sorted = {meld.tiles[1], meld.tiles[2], meld.tiles[3]}
            sortTiles(sorted)
            table.insert(sequences, sorted)
        end
    end

    for i = 1, #sequences do
        for j = i + 1, #sequences do
            for k = j + 1, #sequences do
                if sequences[i][1][2] ~= sequences[j][1][2] and
                   sequences[j][1][2] ~= sequences[k][1][2] and
                   sequences[i][1][2] ~= sequences[k][1][2] then
                    local n1 = {sequences[i][1][1] == 0 and 5 or sequences[i][1][1],
                                sequences[i][2][1] == 0 and 5 or sequences[i][2][1],
                                sequences[i][3][1] == 0 and 5 or sequences[i][3][1]}
                    local n2 = {sequences[j][1][1] == 0 and 5 or sequences[j][1][1],
                                sequences[j][2][1] == 0 and 5 or sequences[j][2][1],
                                sequences[j][3][1] == 0 and 5 or sequences[j][3][1]}
                    local n3 = {sequences[k][1][1] == 0 and 5 or sequences[k][1][1],
                                sequences[k][2][1] == 0 and 5 or sequences[k][2][1],
                                sequences[k][3][1] == 0 and 5 or sequences[k][3][1]}

                    if n1[1] == n2[1] and n2[1] == n3[1] and
                       n1[2] == n2[2] and n2[2] == n3[2] and
                       n1[3] == n2[3] and n2[3] == n3[3] then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function checkIttsu(melds)
    local sequences = {}
    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "chi" then
            local sorted = {meld.tiles[1], meld.tiles[2], meld.tiles[3]}
            sortTiles(sorted)
            table.insert(sequences, sorted)
        end
    end

    for suit in pairs({m = true, p = true, s = true}) do
        local has123, has456, has789 = false, false, false

        for _, seq in ipairs(sequences) do
            if seq[1][2] == suit then
                local nums = {seq[1][1] == 0 and 5 or seq[1][1],
                              seq[2][1] == 0 and 5 or seq[2][1],
                              seq[3][1] == 0 and 5 or seq[3][1]}
                table.sort(nums)

                if nums[1] == 1 and nums[2] == 2 and nums[3] == 3 then has123 = true end
                if nums[1] == 4 and nums[2] == 5 and nums[3] == 6 then has456 = true end
                if nums[1] == 7 and nums[2] == 8 and nums[3] == 9 then has789 = true end
            end
        end

        if has123 and has456 and has789 then
            return true
        end
    end

    return false
end

function checkToitoi(melds)
    for _, meld in ipairs(melds) do
        local meldType = getMeldType(meld)
        if meldType ~= "pon" and meldType ~= "kan" then
            return false
        end
    end
    return true
end

function checkSanshokuDoukou(melds)
    local triplets = {}
    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "pon" or getMeldType(meld) == "kan" then
            table.insert(triplets, meld.tiles[1])
        end
    end

    if #triplets < 3 then return false end

    for i = 1, #triplets do
        for j = i + 1, #triplets do
            for k = j + 1, #triplets do
                if triplets[i][2] ~= triplets[j][2] and
                   triplets[j][2] ~= triplets[k][2] and
                   triplets[i][2] ~= triplets[k][2] and
                   triplets[i][2] ~= "z" and triplets[j][2] ~= "z" and triplets[k][2] ~= "z" then
                    local n1 = triplets[i][1] == 0 and 5 or triplets[i][1]
                    local n2 = triplets[j][1] == 0 and 5 or triplets[j][1]
                    local n3 = triplets[k][1] == 0 and 5 or triplets[k][1]

                    if n1 == n2 and n2 == n3 then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function checkSankantsu(melds)
    local count = 0
    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "kan" then
            count = count + 1
        end
    end
    return count == 3
end

function checkHonroutou(hand)
    for _, tile in ipairs(hand) do
        local num = tile[1] == 0 and 5 or tile[1]
        if tile[2] ~= "z" and num ~= 1 and num ~= 9 then
            return false
        end
    end
    return true
end

function checkHonitsu(hand)
    local suit = nil
    local hasHonor = false

    for _, tile in ipairs(hand) do
        if tile[2] == "z" then
            hasHonor = true
        else
            if suit == nil then
                suit = tile[2]
            elseif suit ~= tile[2] then
                return false
            end
        end
    end

    return suit ~= nil and hasHonor
end

function checkJunchan(melds)
    for _, meld in ipairs(melds) do
        local hasTerminal = false

        for _, tile in ipairs(meld.tiles) do
            local num = tile[1] == 0 and 5 or tile[1]
            if tile[2] == "z" then
                return false
            end
            if num == 1 or num == 9 then
                hasTerminal = true
            end
        end

        if not hasTerminal then
            return false
        end
    end

    return true
end

function checkRyanpeikou(melds)
    local sequences = {}
    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "chi" then
            local sorted = {meld.tiles[1], meld.tiles[2], meld.tiles[3]}
            sortTiles(sorted)
            table.insert(sequences, sorted)
        end
    end

    if #sequences ~= 4 then return false end

    local pairCount = 0
    local used = {}

    for i = 1, #sequences do
        if not used[i] then
            for j = i + 1, #sequences do
                if not used[j] then
                    if tileEquals(sequences[i][1], sequences[j][1]) and
                       tileEquals(sequences[i][2], sequences[j][2]) and
                       tileEquals(sequences[i][3], sequences[j][3]) then
                        pairCount = pairCount + 1
                        used[i] = true
                        used[j] = true
                        break
                    end
                end
            end
        end
    end

    return pairCount == 2
end

function checkChinitsu(hand)
    local suit = nil

    for _, tile in ipairs(hand) do
        if tile[2] == "z" then
            return false
        end

        if suit == nil then
            suit = tile[2]
        elseif suit ~= tile[2] then
            return false
        end
    end

    return true
end

function checkDaisangen(melds)
    local dragons = {false, false, false}

    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "pon" or getMeldType(meld) == "kan" then
            local tile = meld.tiles[1]
            local num = tile[1] == 0 and 5 or tile[1]

            if tile[2] == "z" and num >= 5 and num <= 7 then
                dragons[num - 4] = true
            end
        end
    end

    return dragons[1] and dragons[2] and dragons[3]
end

function checkDaisuushii(melds)
    local winds = {false, false, false, false}

    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "pon" or getMeldType(meld) == "kan" then
            local tile = meld.tiles[1]
            local num = tile[1] == 0 and 5 or tile[1]

            if tile[2] == "z" and num >= 1 and num <= 4 then
                winds[num] = true
            end
        end
    end

    return winds[1] and winds[2] and winds[3] and winds[4]
end

function checkTsuuiisou(hand)
    for _, tile in ipairs(hand) do
        if tile[2] ~= "z" then
            return false
        end
    end
    return true
end

function checkChinroutou(hand)
    for _, tile in ipairs(hand) do
        local num = tile[1] == 0 and 5 or tile[1]
        if tile[2] == "z" or (num ~= 1 and num ~= 9) then
            return false
        end
    end
    return true
end

function checkRyuuiisou(hand)
    local greenTiles = {
        {2, "s"}, {3, "s"}, {4, "s"}, {6, "s"}, {8, "s"}, {6, "z"}
    }

    for _, tile in ipairs(hand) do
        local isGreen = false
        for _, green in ipairs(greenTiles) do
            if tileEquals(tile, green) then
                isGreen = true
                break
            end
        end

        if not isGreen then
            return false
        end
    end

    return true
end

function checkSuukantsu(melds)
    local count = 0
    for _, meld in ipairs(melds) do
        if getMeldType(meld) == "kan" then
            count = count + 1
        end
    end
    return count == 4
end

function countDora(hand)
    local doraCount = 0
    local akaDoraCount = 0

    -- Count dora
    for _, tile in ipairs(hand) do
        for _, dora in ipairs(game.doraIndicators) do
            if tileEquals(tile, dora) then
                doraCount = doraCount + 1
            end
        end
    end

    -- Count akadora
    for _, tile in ipairs(hand) do
        if tile[1] == 0 then  -- Red 5
            akaDoraCount = akaDoraCount + 1
        end
    end

    return doraCount, akaDoraCount
end

function calculateFu(melds)
    local fu = 20  -- Base fuutei

    for _, meld in ipairs(melds) do
        local meldType = getMeldType(meld)
        if meldType == "pon" then
            local tile = meld.tiles[1]
            local num = tile[1] == 0 and 5 or tile[1]
            if tile[2] == "z" or num == 1 or num == 9 then
                fu = fu + 8  -- Terminal/honor triplet
            else
                fu = fu + 4  -- Simple triplet
            end
        elseif meldType == "kan" then
            local tile = meld.tiles[1]
            local num = tile[1] == 0 and 5 or tile[1]
            if tile[2] == "z" or num == 1 or num == 9 then
                fu = fu + 32  -- Terminal/honor quad
            else
                fu = fu + 16  -- Simple quad
            end
        end
    end

    if fu == 20 then
        fu = fu + 2  -- Non-pinfu tsumo
    end

    return math.ceil(fu / 10) * 10  -- Round up
end

function drawScoring()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    love.graphics.setColor(1, 1, 1)

    local handTiles = {}
    for _, meld in ipairs(game.hand) do
        for _, tile in ipairs(meld.tiles) do
            table.insert(handTiles, tile)
        end
    end
    sortTiles(handTiles)

    local tileScale = math.min(1, 300 / (#handTiles * 26))
    local totalWidth = #handTiles * 26 * tileScale
    local startX = (320 - totalWidth) / 2

    for i, tile in ipairs(handTiles) do
        love.graphics.draw(tilesheetImage, getTileQuad(tile),
            startX + (i - 1) * 26 * tileScale, 10, 0, tileScale, tileScale)
    end

    local doraY = 10 + 26 * tileScale + 3
    local doraLabel = "Dora"
    local doraLabelWidth = gameFont:getWidth(doraLabel)
    local totalDoraSlots = 4
    local doraWidth = totalDoraSlots * 26 * tileScale
    local doraStartX = 320 - 10 - doraWidth
    local doraLabelX = doraStartX - doraLabelWidth - 5
    local doraLabelY = doraY + (26 * tileScale - gameFont:getHeight()) / 2 - 1

    love.graphics.print(doraLabel, doraLabelX, doraLabelY)

    for i = 1, totalDoraSlots do
        local x = doraStartX + (i - 1) * 26 * tileScale
        if i <= #game.doraIndicators then
            love.graphics.draw(tilesheetImage, getTileQuad(game.doraIndicators[i]), x, doraY, 0, tileScale, tileScale)
        else
            love.graphics.draw(tilesheetImage, getTileBackQuad(), x, doraY, 0, tileScale, tileScale)
        end
    end

    local groupedYaku = {}
    for _, yaku in ipairs(scoringResult.yaku) do
        local name = settings.language == "en" and YAKU_NAMES_EN[yaku.name] or YAKU_NAMES_JA[yaku.name]
        if not name then name = yaku.name end
        if not groupedYaku[yaku.name] then
            groupedYaku[yaku.name] = {displayName = name, count = 0, han = yaku.han}
        end
        groupedYaku[yaku.name].count = groupedYaku[yaku.name].count + 1
    end

    -- Create yaku list sorted by YAKU_ORDER
    local yakuList = {}
    for _, yakuKey in ipairs(YAKU_ORDER) do
        if groupedYaku[yakuKey] then
            table.insert(yakuList, {
                name = groupedYaku[yakuKey].displayName,
                count = groupedYaku[yakuKey].count,
                han = groupedYaku[yakuKey].han
            })
        end
    end

    local startY = 40 + 26 * tileScale + 8
    local col1X = 12
    local col2X = 167
    local lineSpacing = 14
    local itemsPerColumn = math.ceil(#yakuList / 2)

    for i, yaku in ipairs(yakuList) do
        local column = math.floor((i - 1) / itemsPerColumn)
        local row = (i - 1) % itemsPerColumn

        local x = column == 0 and col1X or col2X
        local y = startY + row * lineSpacing

        local displayName = yaku.name
        if yaku.count > 1 then
            displayName = displayName .. " (" .. yaku.count .. ")"
        else
            displayName = displayName .. " (" .. yaku.han .. ")"
        end

        love.graphics.print(displayName, x, y)
    end

    local limitHand = ""
    if scoringResult.isYakuman then
        local yakumanCount = math.floor(scoringResult.han / 13)
        if yakumanCount == 1 then
            limitHand = "Yakuman"
        elseif yakumanCount == 2 then
            limitHand = "Double Yakuman"
        elseif yakumanCount == 3 then
            limitHand = "Triple Yakuman"
        end
    elseif scoringResult.han >= 11 then
        limitHand = "Sanbaiman"
    elseif scoringResult.han >= 8 then
        limitHand = "Baiman"
    elseif scoringResult.han >= 6 then
        limitHand = "Haneman"
    elseif scoringResult.han >= 5 then
        limitHand = "Mangan"
    end

    if limitHand ~= "" then
        love.graphics.printf(limitHand, 0, 185, 320, "center")
    end
    love.graphics.printf(scoringResult.han .. " Han  " .. scoringResult.fu .. " Fu", 0, 200, 320, "center")
    love.graphics.printf(scoringResult.score .. " pts", 0, 215, 320, "center")
end

function scoringMousePressed(x, y, button)
    if button == 1 then
        playSound(sounds.select)
        nextRound()
    end
end

function scoringKeyPressed(key)
    if key == "space" or key == "return" then
        playSound(sounds.select)
        nextRound()
    end
end
