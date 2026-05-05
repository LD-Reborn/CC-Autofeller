-- ComputerCraft Felling Turtle Program
-- Usage: fell <depth> <width> <height>
-- Example: fell 10 5 8
-- This will fell an area 10 blocks deep, 5 blocks wide, and 8 blocks high

local function printUsage()
    print("Usage: fell <depth> <width> <height>")
    print("Example: fell 10 5 8")
    print("  depth:  How far forward to fell (blocks)")
    print("  width:  How wide the area is (blocks)")
    print("  height: How high to fell (blocks)")
end

-- Parse command line arguments
local args = {...}
if #args < 3 then
    printUsage()
    return
end

local depth = tonumber(args[1])
local width = tonumber(args[2])
local height = tonumber(args[3])

-- Validate input
if not depth or not width or not height then
    print("Error: All parameters must be numbers!")
    printUsage()
    return
end

if depth < 1 or width < 1 or height < 1 then
    print("Error: All parameters must be positive numbers!")
    return
end

print("Starting feller program...")
print(string.format("Parameters: Depth=%d, Width=%d, Height=%d", depth, width, height))
print("Press Ctrl+T to stop")

-- Track position and orientation
local x, y, z = 0, 0, 0  -- relative to start
local facing = 0  -- 0=forward(+z), 1=right(+x), 2=back(-z), 3=left(-x)

local function turnRight()
    turtle.turnRight()
    facing = (facing + 1) % 4
end

local function turnLeft()
    turtle.turnLeft()
    facing = (facing - 1) % 4
end

local function turnTo(direction)
    while facing ~= direction do
        turnRight()
    end
end

local function moveForward()
    if turtle.forward() then
        if facing == 0 then z = z + 1
        elseif facing == 1 then x = x + 1
        elseif facing == 2 then z = z - 1
        elseif facing == 3 then x = x - 1
        end
        return true
    end
    return false
end

local function moveBack()
    if turtle.back() then
        if facing == 0 then z = z - 1
        elseif facing == 1 then x = x - 1
        elseif facing == 2 then z = z + 1
        elseif facing == 3 then x = x + 1
        end
        return true
    end
    return false
end

local function moveUp()
    if turtle.up() then
        y = y + 1
        return true
    end
    return false
end

local function moveDown()
    if turtle.down() then
        y = y - 1
        return true
    end
    return false
end

local function digForward()
    return turtle.dig()
end

local function digUp()
    return turtle.digUp()
end

local function digDown()
    return turtle.digDown()
end

local function dropInventory()
    for slot = 1, 16 do
        if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            turtle.drop()
        end
    end
    turtle.select(1)
end

-- Main felling operation
local function fell()
    local blocksProcessed = 0
    
    -- Iterate through width (side to side)
    for w = 1, width do
        -- Iterate through depth (forward and back)
        for d = 1, depth do
            -- Iterate through height (up and down from ground)
            for h = 1, height do
                -- Dig at current level
                digForward()
                blocksProcessed = blocksProcessed + 1
                
                if h < height then
                    moveUp()
                end
            end
            
            -- Return to ground level
            while y > 0 do
                moveDown()
            end
            
            -- Move to next depth position
            if d < depth then
                if not moveForward() then
                    print("Warning: Unable to move forward at depth position " .. d)
                    break
                end
            end
        end
        
        -- Reset depth: move back to starting depth position
        while z > 0 do
            moveBack()
        end
        
        -- Move to next width position
        if w < width then
            -- Turn left to move along width axis
            turnTo(3)  -- Face left (-x direction)
            if not moveForward() then
                print("Warning: Unable to move to next width position")
                break
            end
            -- Turn back to forward (facing +z)
            turnTo(0)
        end
    end
    
    -- Return to starting position
    turnTo(1)  -- Face right
    while x > 0 do
        moveForward()
    end
    turnTo(0)  -- Face forward
    
    print("Felling complete!")
    print(string.format("Processed approximately %d blocks", blocksProcessed))
    
    -- Ask if user wants to drop inventory
    print("Drop inventory? (y/n)")
    local input = read()
    if input:lower() == "y" then
        dropInventory()
        print("Inventory dropped")
    end
end

-- Start the program
fell()
