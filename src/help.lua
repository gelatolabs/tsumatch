helpPage = 1
totalHelpPages = 18

function drawHelp()
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, 240)

    love.graphics.setColor(1, 1, 1)
    local lang = settings.language

    if not tilesheetImage then
        loadTilesheet()
    end

    if helpPage == 1 then
        -- Introduction page
        love.graphics.printf("How to Play", 0, 10, 320, "center")
        love.graphics.print("Using your mouse, arrow keys, touchscreen or\ngamepad, drag tiles any distance horizontally\nor vertically to form melds:", 10, 30)
        local hand = {{4,"s"},{5,"s"},{6,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 82, 0, 1, 1)
        end
        love.graphics.print("Run (chi)", 92, 81)
        love.graphics.print("3 consecutive tiles of the same suit", 92, 92)
        local hand = {{7,"z"},{7,"z"},{7,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 109, 0, 1, 1)
        end
        love.graphics.print("Triplet (pon)", 92, 108)
        love.graphics.print("3 identical tiles", 92, 120)
        local hand = {{1,"p"},{1,"p"},{1,"p"},{1,"p"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 136, 0, 1, 1)
        end
        love.graphics.print("Quad (kan)", 118, 135)
        love.graphics.print("4 identical tiles", 118, 148)
        love.graphics.print("Form 4 melds to complete your hand and score\npoints with yaku. Play 4 or 8 rounds and try\nfor a high score!", 10, 166)

    elseif helpPage == 2 then
        -- Tile list
        love.graphics.printf("Tiles", 0, 10, 320, "center")
        love.graphics.print("Characters (man)", 10, 30)
        local hand = {{1,"m"},{5,"m"},{9,"m"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 49, 0, 1, 1)
        end
        love.graphics.print("Dots (pin)", 160, 30)
        local hand = {{1,"p"},{5,"p"},{9,"p"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 160 + (i-1)*25, 49, 0, 1, 1)
        end
        love.graphics.print("Bamboo (sou)", 10, 81)
        local hand = {{1,"s"},{2,"s"},{3,"s"},{4,"s"},{5,"s"},{6,"s"},{7,"s"},{8,"s"},{9,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 100, 0, 1, 1)
        end
        love.graphics.print("Winds", 10, 132)
        local hand = {{1,"z"},{2,"z"},{3,"z"},{4,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 151, 0, 1, 1)
        end
        love.graphics.print("Dragons", 160, 132)
        local hand = {{5,"z"},{6,"z"},{7,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 160 + (i-1)*25, 151, 0, 1, 1)
        end
        love.graphics.print("Tsumatch! is played without 2-4 and 6-8 man/pin\ntiles. It's too hard otherwise!", 10, 182)

    elseif helpPage == 3 then
        -- Yaku list
        love.graphics.printf("Yaku List", 0, 10, 320, "center")
        if settings.language == "en" then
            love.graphics.print("1 han:\nTsumatch\nAll Runs\nTwin Runs\nAll Simples\nRound Wind\nDragons", 10, 30)
            love.graphics.print("2 han:\nHalf Outside\nPure Straight\nAll Triplets\nTriple Triplets\nTriple Quads\nNo Simples", 93, 30)
            love.graphics.print("3 han:\nHalf Flush\nFull Outside\nTwice Twin Runs", 200, 30)
            love.graphics.print("6 han:\nFull Flush", 200, 110)
            love.graphics.print("Yakuman:\nThree Dragons\nFour Winds", 10, 158)
            love.graphics.print("All Honors\nAll Terminals\nAll Green", 112, 158)
            love.graphics.print("Four Quads\nCounted Yakuman", 204, 158)
        else
            love.graphics.print("1 han:\nTsumatch\nPinfu\nIipeikou\nTanyao\nYakuhai", 10, 30)
            love.graphics.print("2 han:\nChanta\nIttsu\nToitoi\nSanshoku Doukou\nSankantsu\nHonroutou", 90, 30)
            love.graphics.print("3 han:\nHonitsu\nJunchan\nRyanpeikou", 214, 30)
            love.graphics.print("6 han:\nChinitsu", 214, 110)
            love.graphics.print("Yakuman:\nDaisangen\nDaisuushii", 10, 158)
            love.graphics.print("Tsuuiisou\nChinroutou\nRyuuiisou", 90, 158)
            love.graphics.print("Suukantsu\nKazoe Yakuman", 172, 158)
        end

    elseif helpPage == 4 then
        -- Tsumatch
        love.graphics.printf(getYakuName("tsumatch", lang) .. " (1 han)", 0, 15, 320, "center")
        love.graphics.print("Any four melds. Always awarded.", 10, 40)
        local hand = {{1,"m"},{1,"m"},{1,"m"},{2,"s"},{3,"s"},{4,"s"},{6,"s"},{7,"s"},{8,"s"},{3,"z"},{3,"z"},{3,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Pinfu
        love.graphics.printf(getYakuName("pinfu", lang) .. " (1 han)", 0, 108, 320, "center")
        love.graphics.print("All melds are runs. No triplets or quads.", 10, 133)
        hand = {{1,"s"},{2,"s"},{2,"s"},{3,"s"},{3,"s"},{4,"s"},{4,"s"},{5,"s"},{6,"s"},{6,"s"},{7,"s"},{8,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end

    elseif helpPage == 5 then
        -- Iipeikou
        love.graphics.printf(getYakuName("iipeikou", lang) .. " (1 han)", 0, 15, 320, "center")
        love.graphics.print("A pair of identical runs.", 10, 40)
        local hand = {{1,"p"},{1,"p"},{1,"p"},{1,"s"},{1,"s"},{2,"s"},{2,"s"},{3,"s"},{3,"s"},{6,"s"},{7,"s"},{8,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Tanyao
        love.graphics.printf(getYakuName("tanyao", lang) .. " (1 han)", 0, 108, 320, "center")
        love.graphics.print("All tiles are simples (2-8). No terminals (1/9) or\nhonors (winds/dragons).", 10, 133)
        hand = {{5,"m"},{5,"m"},{5,"m"},{2,"s"},{3,"s"},{4,"s"},{4,"s"},{5,"s"},{6,"s"},{8,"s"},{8,"s"},{8,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 177, 0, 1, 1)
        end

    elseif helpPage == 6 then
        -- Yakuhai
        love.graphics.printf(getYakuName("yakuhai", lang) .. " (1 han)", 0, 15, 320, "center")
        love.graphics.print("Triplet or quad of the round wind.\n(Example: East round)", 10, 40)
        local hand = {{9,"m"},{9,"m"},{9,"m"},{1,"s"},{2,"s"},{3,"s"},{5,"s"},{6,"s"},{7,"s"},{1,"z"},{1,"z"},{1,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 84, 0, 1, 1)
        end

        -- Sangenpai
        love.graphics.printf(getYakuName("sangenpai", lang) .. " (1 han)", 0, 124, 320, "center")
        love.graphics.print("Triplet or quad of dragon tiles.", 10, 149)
        hand = {{9,"p"},{9,"p"},{9,"p"},{1,"s"},{1,"s"},{1,"s"},{3,"s"},{4,"s"},{5,"s"},{7,"z"},{7,"z"},{7,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 177, 0, 1, 1)
        end

    elseif helpPage == 7 then
        -- Chanta
        love.graphics.printf(getYakuName("chanta", lang) .. " (2 han)", 0, 15, 320, "center")
        love.graphics.print("All melds include a terminal or honor.", 10, 40)
        local hand = {{1,"m"},{1,"m"},{1,"m"},{1,"s"},{2,"s"},{3,"s"},{7,"s"},{8,"s"},{9,"s"},{4,"z"},{4,"z"},{4,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Sanshoku Doujun (not possible without man/pin simples)
        -- love.graphics.printf(getYakuName("sanshoku_doujun", lang) .. " (2 han)", 0, 108, 320, "center")
        -- love.graphics.print("Same run in all 3 suits.", 10, 133)
        -- hand = {{1,"m"},{2,"m"},{3,"m"},{1,"p"},{2,"p"},{3,"p"},{1,"s"},{2,"s"},{3,"s"},{5,"z"},{5,"z"},{5,"z"}}
        -- for i, tile in ipairs(hand) do
        --     love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        -- end

        -- Ittsu
        love.graphics.printf(getYakuName("ittsu", lang) .. " (2 han)", 0, 108, 320, "center")
        love.graphics.print("Runs 123, 456, and 789 of same suit.", 10, 133)
        hand = {{5,"p"},{5,"p"},{5,"p"},{1,"s"},{2,"s"},{3,"s"},{4,"s"},{5,"s"},{6,"s"},{7,"s"},{8,"s"},{9,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end

    elseif helpPage == 8 then
        -- Toitoi
        love.graphics.printf(getYakuName("toitoi", lang) .. " (2 han)", 0, 15, 320, "center")
        love.graphics.print("All melds are triplets or quads. No runs.", 10, 40)
        local hand = {{5,"m"},{5,"m"},{5,"m"},{9,"p"},{9,"p"},{9,"p"},{3,"s"},{3,"s"},{3,"s"},{2,"z"},{2,"z"},{2,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Sanshoku Doukou
        love.graphics.printf(getYakuName("sanshoku_doukou", lang) .. " (2 han)", 0, 108, 320, "center")
        love.graphics.print("Same triplet or quad in all three suits.", 10, 133)
        hand = {{1,"m"},{1,"m"},{1,"m"},{1,"p"},{1,"p"},{1,"p"},{1,"s"},{1,"s"},{1,"s"},{6,"s"},{7,"s"},{8,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end

    elseif helpPage == 9 then
        -- Sankantsu
        love.graphics.printf(getYakuName("sankantsu", lang) .. " (2 han)", 0, 15, 320, "center")
        love.graphics.print("Three quads.", 10, 40)
        local hand = {{9,"m"},{9,"m"},{9,"m"},{9,"m"},{5,"p"},{5,"p"},{5,"p"},{5,"p"},{6,"s"},{6,"s"},{6,"s"},{6,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end
        hand = {{7,"s"},{8,"s"},{9,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 93, 0, 1, 1)
        end

        -- Honroutou
        love.graphics.printf(getYakuName("honroutou", lang) .. " (2 han)", 0, 133, 320, "center")
        love.graphics.print("All tiles are terminals or honors. No simples.", 10, 158)
        hand = {{1,"m"},{1,"m"},{1,"m"},{9,"p"},{9,"p"},{9,"p"},{1,"s"},{1,"s"},{1,"s"},{5,"z"},{5,"z"},{5,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 186, 0, 1, 1)
        end

    elseif helpPage == 10 then
        -- Honitsu
        love.graphics.printf(getYakuName("honitsu", lang) .. " (3 han)", 0, 15, 320, "center")
        love.graphics.print("All tiles are from one suit or honors.", 10, 40)
        local hand = {{1,"s"},{2,"s"},{3,"s"},{5,"s"},{6,"s"},{7,"s"},{9,"s"},{9,"s"},{9,"s"},{5,"z"},{5,"z"},{5,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Junchan
        love.graphics.printf(getYakuName("junchan", lang) .. " (3 han)", 0, 108, 320, "center")
        love.graphics.print("All melds include a terminal. No honors.", 10, 133)
        hand = {{1,"s"},{2,"s"},{3,"s"},{7,"s"},{8,"s"},{9,"s"},{1,"m"},{1,"m"},{1,"m"},{9,"p"},{9,"p"},{9,"p"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end

    elseif helpPage == 11 then
        -- Ryanpeikou
        love.graphics.printf(getYakuName("ryanpeikou", lang) .. " (3 han)", 0, 15, 320, "center")
        love.graphics.print("Two pairs of identical runs.", 10, 40)
        local hand = {{1,"s"},{1,"s"},{2,"s"},{2,"s"},{3,"s"},{3,"s"},{5,"s"},{5,"s"},{6,"s"},{6,"s"},{7,"s"},{7,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Chinitsu
        love.graphics.printf(getYakuName("chinitsu", lang) .. " (6 han)", 0, 108, 320, "center")
        love.graphics.print("All tiles are from one suit. No honors.", 10, 133)
        hand = {{1,"s"},{2,"s"},{3,"s"},{4,"s"},{4,"s"},{4,"s"},{5,"s"},{6,"s"},{6,"s"},{9,"s"},{9,"s"},{9,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end

    elseif helpPage == 12 then
        -- Daisangen
        love.graphics.printf(getYakuName("daisangen", lang) .. " (Yakuman)", 0, 15, 320, "center")
        love.graphics.print("Three different dragon triplets or quads.", 10, 40)
        local hand = {{1,"s"},{2,"s"},{3,"s"},{5,"z"},{5,"z"},{5,"z"},{6,"z"},{6,"z"},{6,"z"},{7,"z"},{7,"z"},{7,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Daisuushii
        love.graphics.printf(getYakuName("daisuushii", lang) .. " (Yakuman)", 0, 108, 320, "center")
        love.graphics.print("Four different wind triplets or quads.", 10, 133)
        hand = {{1,"z"},{1,"z"},{1,"z"},{2,"z"},{2,"z"},{2,"z"},{3,"z"},{3,"z"},{3,"z"},{4,"z"},{4,"z"},{4,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end

    elseif helpPage == 13 then
        -- Tsuuiisou
        love.graphics.printf(getYakuName("tsuuiisou", lang) .. " (Yakuman)", 0, 15, 320, "center")
        love.graphics.print("All tiles are honors.", 10, 40)
        local hand = {{1,"z"},{1,"z"},{1,"z"},{2,"z"},{2,"z"},{2,"z"},{5,"z"},{5,"z"},{5,"z"},{6,"z"},{6,"z"},{6,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Chinroutou
        love.graphics.printf(getYakuName("chinroutou", lang) .. " (Yakuman)", 0, 108, 320, "center")
        love.graphics.print("All tiles are terminals.", 10, 133)
        hand = {{1,"m"},{1,"m"},{1,"m"},{9,"m"},{9,"m"},{9,"m"},{1,"p"},{1,"p"},{1,"p"},{9,"s"},{9,"s"},{9,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end

    elseif helpPage == 14 then
        -- Ryuuiisou
        love.graphics.printf(getYakuName("ryuuiisou", lang) .. " (Yakuman)", 0, 15, 320, "center")
        love.graphics.print("All tiles are completely green.", 10, 40)
        local hand = {{2,"s"},{3,"s"},{4,"s"},{2,"s"},{3,"s"},{4,"s"},{6,"s"},{6,"s"},{6,"s"},{6,"z"},{6,"z"},{6,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

        -- Suukantsu
        love.graphics.printf(getYakuName("suukantsu", lang) .. " (Yakuman)", 0, 108, 320, "center")
        love.graphics.print("All melds are quads. No runs or triplets.", 10, 133)
        hand = {{5,"m"},{5,"m"},{5,"m"},{5,"m"},{2,"s"},{2,"s"},{2,"s"},{2,"s"},{8,"s"},{8,"s"},{8,"s"},{8,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 161, 0, 1, 1)
        end
        hand = {{4,"z"},{4,"z"},{4,"z"},{4,"z"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 186, 0, 1, 1)
        end

    elseif helpPage == 15 then
        -- Kazoe Yakuman
        love.graphics.printf(getYakuName("kazoe_yakuman", lang), 0, 15, 320, "center")
        love.graphics.print("A hand worth 13 or more han from other yaku.", 10, 40)
        local hand = {{1,"s"},{1,"s"},{2,"s"},{2,"s"},{3,"s"},{3,"s"},{7,"s"},{7,"s"},{8,"s"},{8,"s"},{9,"s"},{9,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 68, 0, 1, 1)
        end

    elseif helpPage == 16 then
        -- Dora
        love.graphics.printf("Dora", 0, 15, 320, "center")
        love.graphics.print("Each bonus tile in your hand is worth 1 han.\nMatching quads reveals additional dora.", 10, 40)
        local hand = {{1,"s"},{0,"back"},{0,"back"},{0,"back"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 84, 0, 1, 1)
        end

        love.graphics.printf("Akadora", 0, 124, 320, "center")
        love.graphics.print("Each red 5 tile in your hand is worth 1 han.", 10, 149)
        hand = {{0,"m"},{0,"p"},{0,"s"}}
        for i, tile in ipairs(hand) do
            love.graphics.draw(tilesheetImage, getTileQuad(tile), 10 + (i-1)*25, 177, 0, 1, 1)
        end

    elseif helpPage == 17 then
        -- Scoring (1/2)
        love.graphics.printf("Scoring (1/2)", 0, 15, 320, "center")
        love.graphics.print("Han from all yaku are added together.\n\n5\n6-7\n8-10\n11-12\n13+\nMultiple yakuman are 32000 pts each.\n\nWith less than 5 han, the score is calculated\nbased on han and fu...", 10, 40)
        love.graphics.print("han - Mangan\nhan - Haneman\nhan - Baiman\nhan - Sanbaiman\nhan - Yakuman", 48, 70)
        love.graphics.print("(8000 pts)\n(12000 pts)\n(16000 pts)\n(24000 pts)\n(32000 pts)", 153, 70)

    elseif helpPage == 18 then
        -- Scoring (2/2)
        love.graphics.printf("Scoring (2/2)", 0, 15, 320, "center")
        love.graphics.print("22 base fu (20 with pinfu)\n+ 4 fu per simple triplet\n+ 8 fu per terminal/honor triplet\n+ 16 fu per simple quad\n+ 32 fu per terminal/honor quad\nFu is rounded up to the nearest 10.\n\nScore = fu * 2^(han+2)\n\n4 han 40+ fu or 3 han 70+ fu is capped at\nmangan (8000 pts).", 10, 40)
    end

    drawPagination(helpPage, totalHelpPages)
    drawBackButton()
end

function helpMousePressed(x, y, button)
    if button == 1 then
        if isBackButtonClicked(x, y) then
            playSound(sounds.back)
            resetMenuState()
            gameState = "menu"
            helpPage = 1
        elseif isPaginationLeftClicked(x, y, helpPage) then
            helpPage = helpPage - 1
            playSound(sounds.cursor)
        elseif isPaginationRightClicked(x, y, helpPage, totalHelpPages) then
            helpPage = helpPage + 1
            playSound(sounds.cursor)
        end
    end
end

function helpKeyPressed(key)
    if key == "escape" then
        playSound(sounds.back)
        resetMenuState()
        gameState = "menu"
        helpPage = 1
    elseif key == "left" or key == "a" then
        if helpPage > 1 then
            helpPage = helpPage - 1
            playSound(sounds.cursor)
        end
    elseif key == "right" or key == "d" or key == "space" then
        if helpPage < totalHelpPages then
            helpPage = helpPage + 1
            playSound(sounds.cursor)
        end
    end
end

function getYakuName(name, lang)
    if lang == "en" then
        return YAKU_NAMES_EN[name] or name
    else
        return YAKU_NAMES_JA[name] or name
    end
end
