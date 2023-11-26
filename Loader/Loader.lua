local Unlocker, Caffeine, Rotation = ...

-- Gets the index of the talent tree with the most points.
---@return number talentIndex of the most invested talent tree.
function Rotation.GetSpec()
    local talentIndex = 0
    local talentPoints = 0

    -- Loop through talent trees.
    for i = 1, 3 do
        local _, _, pointsSpent = GetTalentTabInfo(i)

        -- Update if current tree has more points.
        if pointsSpent > talentPoints then
            talentIndex = i
            talentPoints = pointsSpent
        end
    end

    return talentIndex
end

-- Function to determine the class of the player.
---@return string className of the player.
function Rotation.GetClass()
    local _, className = UnitClass("player")
    return className
end
