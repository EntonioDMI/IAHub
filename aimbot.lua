return function(Fluent, Tab)
    -- [Previous code remains unchanged until isVisible function]
    
    local function isVisible(part)
        if not _G.aimbotSettings.wallCheck then return true end
        
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin).Unit
        local distance = (part.Position - origin).Magnitude
        
        -- Create ray parameters
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        -- Get all accessories and tools to ignore
        local ignoreList = {LocalPlayer.Character, part.Parent, workspace.CurrentCamera}
        
        -- Add accessories and tools to ignore list
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Accessory") or obj:IsA("Tool") or 
               (obj:IsA("BasePart") and obj.Transparency > 0.9) then
                table.insert(ignoreList, obj)
            end
        end
        
        rayParams.FilterDescendantsInstances = ignoreList
        rayParams.IgnoreWater = true
        
        -- Cast the ray
        local result = workspace:Raycast(origin, direction * distance, rayParams)
        
        -- Check if there's no obstacle or if the hit part belongs to the target
        return result == nil or (result.Instance and result.Instance:IsDescendantOf(part.Parent))
    end
    
    -- [Rest of the code remains unchanged]
end
