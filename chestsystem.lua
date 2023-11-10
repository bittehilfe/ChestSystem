local depositChest = 'minecraft:chest_0'

local function getConnectedChests()
    local modem = peripheral.find('modem')
    if not modem then
        print('no modem attached')
        return
    end

    local chests = {}
    for _, connected in next, modem.getNamesRemote() do 
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

local options = {
    deposit = function()
        local depositChest = peripheral.wrap(depositChest)
        local items = depositChest.list()
    
        for i, item in next, items do 
            local chestContainingItem = findChestContainingItem(item.name)
            local connectedChests = getConnectedChests()
    
            local success = depositChest.pushItems(chestContainingItem or connectedChests[math.random(1, #connectedChests)], i, item.count)

            while success == 0 do
                success = depositChest.pushItems(connectedChests[math.random(1, #connectedChests)], i, item.count)
            end
    
            print('Deposited ' .. item.name .. ' ' .. item.count .. 'x')
        end
    end,

    withdraw = function(itemName, amount)
        amount = tonumber(amount) or 1
    
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

setmetatable(options, {
    __call = function(self, input)
        local command, parameter = input:match("(%S+)%s*(.*)")
        local option = self[command]
        
        if not option then
            print('invalid input')
            return
        end

        if (command == "deposit" and parameter == "") or (command == "withdraw" and parameter ~= "") then
            local params = {}
            for param in parameter:gmatch("%S+") do
                table.insert(params, param)
            end
            option(table.unpack(params))
        else
            print('Invalid input for ', command)
        end
    end
})

print('options:\ndeposit\nwithdraw (item) (amount)')
while true do 
    local input = read()
    options(input)
end