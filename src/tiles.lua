TILE_SIZE = 26

TILES = {
    {1, "m"}, {2, "m"}, {3, "m"}, {4, "m"}, {5, "m"}, {6, "m"}, {7, "m"}, {8, "m"}, {9, "m"}, {0, "m"},
    {1, "s"}, {2, "s"}, {3, "s"}, {4, "s"}, {5, "s"}, {6, "s"}, {7, "s"}, {8, "s"}, {9, "s"}, {0, "s"},
    {1, "p"}, {2, "p"}, {3, "p"}, {4, "p"}, {5, "p"}, {6, "p"}, {7, "p"}, {8, "p"}, {9, "p"}, {0, "p"},
    {1, "z"}, {2, "z"}, {3, "z"}, {4, "z"}, {5, "z"}, {6, "z"}, {7, "z"}, {0, "back"}
}

function getTileBackQuad()
    return love.graphics.newQuad(7 * TILE_SIZE, 3 * TILE_SIZE, TILE_SIZE, TILE_SIZE, tilesheetImage:getDimensions())
end

function getTileQuad(tileType)
    local index = 0
    for i, t in ipairs(TILES) do
        if t[1] == tileType[1] and t[2] == tileType[2] then
            index = i - 1
            break
        end
    end

    local row = math.floor(index / 10)
    local col = index % 10

    return love.graphics.newQuad(col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE, tilesheetImage:getDimensions())
end

function loadTilesheet()
    tilesheetImage = love.graphics.newImage("img/tiles.png")
    gameFont = love.graphics.newFont("font/CompassGold.ttf", 16)
    largeFont = love.graphics.newFont("font/CompassGold.ttf", 32)
    love.graphics.setFont(gameFont)
end

function loadSounds()
    sounds = {
        chi = love.audio.newSource("snd/chi.ogg", "static"),
        pon = love.audio.newSource("snd/pon.ogg", "static"),
        kan = love.audio.newSource("snd/kan.ogg", "static"),
        tsumo = love.audio.newSource("snd/tsumo.ogg", "static"),
        tileup = love.audio.newSource("snd/tileup.ogg", "static"),
        tiledown = love.audio.newSource("snd/tiledown.ogg", "static"),
        cursor = love.audio.newSource("snd/cursor.ogg", "static"),
        select = love.audio.newSource("snd/select.ogg", "static"),
        back = love.audio.newSource("snd/back.ogg", "static"),
        start = love.audio.newSource("snd/start.ogg", "static")
    }
end

function playSound(sound)
    if sound:isPlaying() then
        sound:stop()
    end
    sound:play()
end

function tileEquals(t1, t2)
    return t1[1] == t2[1] and t1[2] == t2[2]
end

function tileLessThan(t1, t2)
    if t1[2] ~= t2[2] then
        local suitOrder = {m = 1, p = 2, s = 3, z = 4}
        return suitOrder[t1[2]] < suitOrder[t2[2]]
    end
    -- Normalize red 5s (0) to 5 for sorting
    local n1 = t1[1] == 0 and 5 or t1[1]
    local n2 = t2[1] == 0 and 5 or t2[1]
    return n1 < n2
end

function sortTiles(tiles)
    table.sort(tiles, tileLessThan)
end

function getTileName(tile, lang)
    lang = lang or "ja"

    if tile[2] == "z" then
        if lang == "en" then
            local honors = {"East", "South", "West", "North", "White", "Green", "Red"}
            return honors[tile[1]]
        else
            local honors = {"Ton", "Nan", "Shaa", "Pei", "Haku", "Hatsu", "Chun"}
            return honors[tile[1]]
        end
    else
        local suitNames = {m = "Man", p = "Pin", s = "Sou"}
        local suitNamesJa = {m = "m", p = "p", s = "s"}
        local num = tile[1] == 0 and 5 or tile[1]
        if lang == "en" then
            return num .. " " .. suitNames[tile[2]]
        else
            return num .. suitNamesJa[tile[2]]
        end
    end
end
