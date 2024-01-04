local depositChest = 'minecraft:chest_0'

local function getConnectedChests()
    local modem = peripheral.find('modem')
    if not modem then
        print('no modem attached')
        return
    end

    local chests = {}
    local connectedNames = modem.getNamesRemote()
    for i = 1, #connectedNames do 
        local connected = connectedNames[i]
        if string.find(peripheral.getType(connected), 'chest') and connected ~= depositChest then
            table.insert(chests, connected)
        end
    end

    return chests
end

local function findChestContainingItem(itemName)
    for _, connectedChest in next, getConnectedChests() do 
        local currentChest = peripheral.wrap(connectedChest).list()
        for _, item in next, currentChest do 
            if string.find(item.name, itemName) then
                return connectedChest
            end
        end
    end
    return nil
end

local function findItemIndex(itemList, itemName)
    for i, item in next, itemList do 
        if string.find(item.name, itemName) then
            return i, item
        end
    end
end

local commands = {
    help = function()
        print('commands: \n withdraw: \n deposit: \n help')
    end,

    deposit = function()
        local start = os.clock()
        local depositChest = peripheral.wrap(depositChest)
        local items = depositChest.list()

        for i, item in next, items do 
            local connectedChests = getConnectedChests()

            for _, chest in next, connectedChests do 
                coroutine.wrap(function()
                    depositChest.pushItems(chest, i, item.count)
                end)()
            end
        end

        print('took ' .. os.clock() - start .. ' seconds')
    end,
    
    withdraw = function(itemName, amount)
        while amount > 0 do
            local chestContainingItem = findChestContainingItem(itemName)
            if not chestContainingItem then
                print(itemName .. ' not found')
                return
            end
    
            local chest = peripheral.wrap(chestContainingItem)
            local itemIndex, itemTable = findItemIndex(chest.list(), itemName)
    
            if itemIndex then
                local currentStackSize = math.min(amount, 64)
                local success = chest.pushItems(depositChest, itemIndex, currentStackSize)
    
                if success > 0 then
                    print('Withdrawn ' .. itemTable.name .. ' ' .. success .. 'x')
                    amount = amount - success
                end
            end
        end
    end,
}

setmetatable(commands, {
    __call = function(self, input)
        local option, parameter, amount = input[1], input[2] or nil, tonumber(input[3]) or 1
        local command = self[option]

        if not command then
            print('invalid input enter <help> for more options')
            return
        end

        command(parameter, amount)
    end
})

term.setTextColor(colors.green)
while true do
    local input = read()
    local words = {}

    for word in input:gmatch("%S+") do
        if #words > 3 then
            break
        end
        table.insert(words, word)
    end
    commands(words)
end
