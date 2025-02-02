return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    
    -- Load friends list from file
    local friends = {}
    local addingFriends = false
    
    -- Function to save friends list
    local function saveFriends()
        local data = { friends = friends }
        writefile("Friends.yml", HttpService:JSONEncode(data))
    end
    
    -- Function to load friends list
    local function loadFriends()
        if isfile("Friends.yml") then
            local data = HttpService:JSONDecode(readfile("Friends.yml"))
            friends = data.friends or {}
        end
    end
    
    -- Load friends on startup
    loadFriends()
    
    -- Function to check if player is friend
    _G.isFriend = function(player)
        return table.find(friends, player.Name) ~= nil
    end
    
    -- Function to add/remove friend
    local function toggleFriend(player)
        if not addingFriends then return end
        
        local index = table.find(friends, player.Name)
        if index then
            table.remove(friends, index)
        else
            table.insert(friends, player.Name)
        end
        
        saveFriends()
        _G.updateHighlights() -- Update ESP
    end
    
    -- Create friend toggle button
    local addFriendsToggle = Tab:AddToggle("AddFriends", {
        Title = "Add/Remove Friends",
        Description = "Click on players to add/remove them as friends",
        Default = false,
        Callback = function(Value)
            addingFriends = Value
        end
    })
    
    -- Create friends list
    local friendsList = Tab:AddParagraph({
        Title = "Friends List",
        Content = "No friends added"
    })
    
    -- Function to update friends list display
    local function updateFriendsList()
        if #friends == 0 then
            friendsList:SetDesc("No friends added")
        else
            local content = table.concat(friends, "\n")
            friendsList:SetDesc(content)
        end
    end
    
    -- Update initial display
    updateFriendsList()
    
    -- Handle player clicking
    local function onPlayerClicked(player)
        if player == LocalPlayer then return end
        toggleFriend(player)
        updateFriendsList()
    end
    
    -- Connect player clicking
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function()
            if addingFriends then
                onPlayerClicked(player)
            end
        end)
    end)
    
    return {
        isFriend = _G.isFriend,
        getFriends = function() return friends end
    }
end
