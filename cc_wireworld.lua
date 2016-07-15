local args = { ... }

local CELL_NONE = 1
local CELL_WIRE = 2
local CELL_HEAD = 3
local CELL_TAIL = 4

local COLORS = { colors.black, colors.yellow, colors.blue, colors.red }

local width, height = term.getSize()

local selectedType = CELL_WIRE
local ticking = false

local grid = {}

for x = 1, width do
    grid[x] = {}
    for y = 1, height do
        grid[x][y] = CELL_NONE
    end
end 

local function updateGrid()
    local newGrid = {}

    for x = 1, #grid do
        newGrid[x] = {}

        for y = 1, #grid[x] do
            local old = grid[x][y]
            local new

            if old == CELL_NONE then
                new = CELL_NONE
            elseif old == CELL_HEAD then
                new = CELL_TAIL
            elseif old == CELL_TAIL then
                new = CELL_WIRE
            elseif old == CELL_WIRE then
                local n = 0

                for j = -1, 1 do
                    for i = -1, 1 do
                        local k = x + i
                        local l = y + j

                        if not (k < 1 or l < 1 or k > width or l > height) then
                            if grid[k][l] == CELL_HEAD then
                                n = n + 1
                            end
                        end
                    end
                end

                if n == 1 or n == 2 then
                    new = CELL_HEAD
                else
                    new = CELL_WIRE
                end 
            end 

            newGrid[x][y] = new
        end
    end

    grid = newGrid
end

local delay = 0.1
local timer = os.startTimer(delay)
local running = true
while running do
    local e, p1, p2, p3, p4, p5 = os.pullEvent()
    if e == "timer" and p1 == timer then
        timer = os.startTimer(delay)

        if ticking then
            updateGrid()
        end

        for y = 1, height do
            term.setCursorPos(1, y)
            for x = 1, width do
                term.setBackgroundColor(COLORS[grid[x][y]])
                term.write(" ")
            end
        end
    elseif e == "mouse_click" then
        if not grid[p2] then
            grid[p2] = {}
        end

        if p1 == 1 then
            grid[p2][p3] = selectedType
        elseif p1 == 2 then
            grid[p2][p3] = CELL_NONE
        end 
    elseif e == "key" then
        if p1 == keys.one then
            selectedType = CELL_WIRE
        elseif p1 == keys.two then
            selectedType = CELL_HEAD
        elseif p1 == keys.three then
            selectedType = CELL_TAIL
        elseif p1 == keys.p then
            ticking = not ticking
        elseif p1 == keys.u then
            if not ticking then
                updateGrid()
            end
        elseif p1 == keys.c then
            if not ticking then
                for x = 1, width do
                    for y = 1, height do
                        grid[x][y] = CELL_NONE
                    end
                end
            end
        elseif p1 == keys.r then
            if not ticking then
                for x = 1, width do
                    for y = 1, height do
                        if grid[x][y] == CELL_HEAD or grid[x][y] == CELL_TAIL then
                            grid[x][y] = CELL_WIRE
                        end
                    end
                end
            end
        elseif p1 == keys.t then
            running = false
        end
    end
end