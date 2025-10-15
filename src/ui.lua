function drawButton(text, x, y, w, h, hover)
    if hover then
        love.graphics.setColor(0.3, 0.3, 0.3)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
    end

    love.graphics.rectangle("fill", x, y, w, h)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)

    love.graphics.printf(text, x, y + h / 2 - 6, w, "center")
end

function drawBackButton()
    local mx, my = love.mouse.getPosition()
    local hover = mx >= 5 and mx < 55 and my >= 220 and my < 235

    if hover then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.print("< Back", 5, 220)
end

function isBackButtonClicked(x, y)
    return x >= 5 and x < 55 and y >= 220 and y < 235
end

function isMouseOver(x, y, w, h)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx < x + w and my >= y and my < y + h
end

function drawPagination(currentPage, totalPages)
    local y = 220
    local mx, my = love.mouse.getPosition()

    love.graphics.setColor(1, 1, 1)
    local pageText = "Page " .. currentPage .. "/" .. totalPages
    love.graphics.printf(pageText, 0, y, 320, "center")

    local leftArrowX = 120
    local leftArrowHover = mx >= leftArrowX - 5 and mx < leftArrowX + 15 and my >= y - 2 and my < y + 17
    if leftArrowHover and currentPage > 1 then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print("<", leftArrowX, y)

    local rightArrowX = 195
    local rightArrowHover = mx >= rightArrowX - 5 and mx < rightArrowX + 15 and my >= y - 2 and my < y + 17
    if rightArrowHover and currentPage < totalPages then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(">", rightArrowX, y)

    love.graphics.setColor(1, 1, 1)
end

function isPaginationLeftClicked(x, y, currentPage)
    local leftArrowX = 120
    return x >= leftArrowX - 5 and x < leftArrowX + 15 and y >= 218 and y < 237 and currentPage > 1
end

function isPaginationRightClicked(x, y, currentPage, totalPages)
    local rightArrowX = 195
    return x >= rightArrowX - 5 and x < rightArrowX + 15 and y >= 218 and y < 237 and currentPage < totalPages
end
