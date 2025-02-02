return function(Fluent, Tab)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local HttpService = game:GetService("HttpService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = workspace.CurrentCamera
    
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
    
    -- Function to show visual feedback
    local function showFeedbackEffect(character, isAdding)
        if not character then return end
        
        -- Create temporary highlight for feedback
        local feedbackHighlight = Instance.new("Highlight")
        feedbackHighlight.FillTransparency = 1
        feedbackHighlight.OutlineColor = isAdding and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        feedbackHighlight.OutlineTransparency = 0
        feedbackHighlight.Parent = character
        
        -- Animate the feedback
        local tween = game:GetService("TweenService"):Create(
            feedbackHighlight,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {OutlineTransparency = 1}
        )
        
        tween.Completed:Connect(function()
            feedbackHighlight:Destroy()
        end)
        
        tween:Play()
    end
    
    -- Function to add/remove friend
    local function toggleFriend(player)
        if not addingFriends or not player then return end
        
        local index = table.find(friends, player.Name)
        local isAdding = index == nil
        
        if isAdding then
            table.insert(friends, player.Name)
        else
            table.remove(friends, index)
        end
        
        showFeedbackEffect(player.Character, isAdding)
        saveFriends()
        updateFriendsList()
        
        -- Update highlights if enabled
        if _G.updateHighlights then
            _G.updateHighlights()
        end
    end
    
    -- Function to get player from mouse hit
    local function getPlayerFromHit(x, y)
        local ray = Camera:ViewportPointToRay(x, y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        if raycastResult and raycastResult.Instance then
            local character = raycastResult.Instance:FindFirstAncestorOfClass("Model")
            if character then
                return Players:GetPlayerFromCharacter(character)
            end
        end
        return nil
    end
    
    -- Handle mouse input
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 and addingFriends then
            local mouseLocation = UserInputService:GetMouseLocation()
            local player = getPlayerFromHit(mouseLocation.X, mouseLocation.Y)
            if player and player ~= LocalPlayer then
                toggleFriend(player)
            end
        end
    end)
    
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
    function updateFriendsList()
        if #friends == 0 then
            friendsList:SetDesc("No friends added")
        else
            local content = table.concat(friends, "\n")
            friendsList:SetDesc(content)
        end
    end
    
    -- Update initial display
    updateFriendsList()
    
    return {
        isFriend = _G.isFriend,
        getFriends = function() return friends end
    }
end
