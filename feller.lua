-- ComputerCraft Felling Turtle Program
-- Usage: fell [depth] [width] [height]
-- Example: fell 10 5 8
-- This will fell an area 10 blocks deep, 5 blocks wide, and 8 blocks high

local function printUsage()
    print("Usage: fell [depth] [width] [height]")
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
local blocksProcessed = 0

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
local validFuels = {
    ["minecraft:charcoal"] = true,
    ["minecraft:bamboo"] = true
}

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

local function moveSingle(diffX, diffY, diffZ, ignoreFuel)
    if diffX > 0 then
       turnTo(1)
       moveForward(ignoreFuel)
    elseif diffX < 0 then
       turnTo(3)
       moveForward(ignoreFuel)
    end
    if diffZ > 0 then
       turnTo(0)
       moveForward(ignoreFuel)
    elseif diffZ < 0 then
       turnTo(2)
       moveForward(ignoreFuel)
    end
    if diffY > 0 then
       moveUp(ignoreFuel)
    elseif diffY < 0 then
       moveDown(ignoreFuel)
    end
end

local function moveSingleAxis(diffX, diffY, diffZ, ignoreFuel)
    if diffX ~= 0 then
        for val = 1, math.abs(diffX) do
            moveSingle((diffX > 0) and 1 or -1, 0, 0, ignoreFuel)
        end
    end
    if diffY ~= 0 then
        for val = 1, math.abs(diffY) do
            moveSingle(0, (diffY > 0) and 1 or -1, 0, ignoreFuel)
        end
    end
    if diffZ ~= 0 then
        for val = 1, math.abs(diffZ) do
            moveSingle(0, 0, (diffZ > 0) and 1 or -1, ignoreFuel)
        end
    end
end

local function moveTo(targetX, targetY, targetZ, ignoreFuel)
    if y - targetY > 0 then -- down
        moveSingleAxis(0, targetY - y, 0, ignoreFuel)
        moveSingleAxis(0, targetX - x, 0, ignoreFuel)
        moveSingleAxis(0, targetZ - z, 0, ignoreFuel)
    else -- equal or up
        moveSingleAxis(0, targetZ - z, 0, ignoreFuel)
        moveSingleAxis(0, targetX - x, 0, ignoreFuel)
        moveSingleAxis(0, targetY - y, 0, ignoreFuel)
    end
end


local function returnDistance()
    return math.abs(x) + math.abs(y) + math.abs(z)
end

local function safeReturnAndGoBack(ignoreFuel, whenDownThereDoWhat)
    currentX = x
    currentY = y
    currentZ = z
    currentFacing = facing
    safeReturn()
    whenDownThereDoWhat()
    moveTo(currentX, currentY, currentZ)
    turnTo(currentFacing)
end

local function anyEmptySlots()
    for i = 1, 16 do
        if turtle.getItemSpace(i) == 64 then
            return true
        end
    end
    return false
end

local function emptyIntoChest()
    turnTo(2)
    -- TODO: turtle.inspect() and check if it's a chest. Ideally also check for space? Else exit() with critical error message
    for inventorySlot = 1, 16 do
        turtle.select(inventorySlot)
        turtle.drop()
    end
end

local function awaitFuel()
    while turtle.getFuelLevel() <= 0 do
        for inventorySlot = 1, 16 do
            inventoryDetail = turtle.getItemDetail(inventorySlot) -- returns: count: int, name: str
            if inventoryDetail and validFuels[inventoryDetail.name] then
                turtle.select(inventorySlot)
                turtle.refuel(inventoryDetail.count)
            end
        end
    end
end

local function ensureFueledAndInventorySpace()
    local fuelLevel = turtle.getFuelLevel()
    assert(fuelLevel > 0)
    if fuelLevel <= 0 then
        print("Warning: No fuel left")
        awaitFuel()
    elseif returnDistance() > fuelLevel then
        print("Warning: Please refuel")
        safeReturnAndGoBack(true, awaitFuel)
    elseif fuelLevel < 1000 then
        print("Warning: Fuel < 1000")
    end
    if not anyEmptySlots() then
        print("Warning: Inventory full")
        safeReturnAndGoBack(true, emptyIntoChest)
    end
end

local function moveForward(ignoreFuel)
    ignoreFuel = ignoreFuel or false
    if not ignoreFuel then
        ensureFueledAndInventorySpace()
    end

    if turtle.detect() then
        turtle.dig()
        blocksProcessed = blocksProcessed + 1
    end
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

local function moveUp()
    if turtle.detectUp() then
        turtle.digUp()
        blocksProcessed = blocksProcessed + 1
    end
    ensureFueledAndInventorySpace()
    if turtle.up() then
        y = y + 1
        return true
    end
    return false
end

local function moveDown(ignoreFuel)
    ignoreFuel = ignoreFuel or false
    if not ignoreFuel then
        ensureFueledAndInventorySpace()
    end

    if turtle.detectDown() then
        turtle.digDown()
        blocksProcessed = blocksProcessed + 1
    end
    ensureFueledAndInventorySpace()
    if turtle.down() then
        y = y - 1
        return true
    end
    return false
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


local function safeReturn()
    moveTo(0, 0, 0, true)
end

-- Main felling operation
local function fell()
    ensureFueledAndInventorySpace()
    blocksProcessed = 0
    for h = 1, height do
        moveForward()
        for w = 1, width do
            for d = 1, depth - 1 do
                moveForward()
            end
            if (w ~= width) then
                if w % 2 then
                    turnRight()
                    moveForward()
                    turnRight()
                else
                    turnLeft()
                    moveForward()
                    turnLeft()
                end
            end
        end
        if h ~= height then
            moveUp()
            turnRight()
            turnRight()
        end
    end
    
    print("Information: Felling complete")
    print(string.format("Processed approximately %d blocks", blocksProcessed))
    print("Information: Returning to start")
    safeReturn()
    print("Information: Emptying into chest")
    emptyIntoChest()
    print("Information: DONE")
end

-- Start the program
fell()
