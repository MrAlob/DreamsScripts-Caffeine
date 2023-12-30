local Unlocker, Caffeine, Rotation = ...

-- Units
local Player = Caffeine.UnitManager:Get("player")

-- Spells
local spells = Rotation.Spells

-- Gets the index of the talent tree with the most points of the most invested talent tree
---@return number talentIndex
function Caffeine.GetSpec()
	local talentIndex = 0
	local talentPoints = 0

	-- Loop through talent trees
	for i = 1, 3 do
		local _, _, pointsSpent = GetTalentTabInfo(i)

		-- Update if current tree has more points
		if pointsSpent > talentPoints then
			talentIndex = i
			talentPoints = pointsSpent
		end
	end

	return talentIndex
end

-- Determine the class of the player
---@return string className
function Caffeine.GetClass()
	local _, className = UnitClass("player")
	return className
end

--- Determines if a unit is a boss
---@return boolean isBoss
function Caffeine.Unit:CustomIsBoss()
	local id = ObjectID(self:GetOMToken())

	-- Lady Deathwhisper (36855)
	if id == 36855 then
		return true
	end

	-- Sindragossa
	if id == 36853 then
		return true
	end

	-- Professor Putricide
	if id == 36678 then
		return true
	end

	-- Skybreaker Sorcerer
	if id == 37116 then
		return true
	end

	-- Kor'kron Battle Mage
	if id == 37117 then
		return true
	end

	-- Blazing Skeleton
	if id == 36791 then
		return true
	end

	-- Raid Boss
	if self:IsBoss() then
		return true
	end

	-- Dungeon Boss
	if Player:GetInstanceInfo("party", 2) then
		if UnitClassification(self:GetOMToken()) == "elite" and UnitLevel(self:GetOMToken()) == 82 then
			return true
		end
	end

	return false
end

--- Estimates the time it will take for a unit to die
---@return number TimeToDie
function Caffeine.Unit:CustomTimeToDie()
	local timeToDie = self:TimeToDie()
	local healthPercent = self:GetHP()

	if timeToDie == 0 and healthPercent > 10 then
		return 200
	else
		return timeToDie
	end
end

--- Checks if the unit is of a specified creature type.
---@return boolean isCreatureType
function Caffeine.Unit:IsCreatureType(creatureType)
	local unitCreatureType = UnitCreatureType(self:GetOMToken())
	return unitCreatureType == creatureType
end

--- Gets the instance information and checks if it matches the provided criteria.
---@param instanceType string
---@param difficultyID number
---@param instanceID number
---@return boolean
function Caffeine.Unit:GetInstanceInfo(instanceType, difficultyID, instanceID)
	local _, type, difficulty, _, _, _, _, instance = GetInstanceInfo()

	if instanceID then
		return type == instanceType and difficulty == difficultyID and instance == instanceID
	else
		return type == instanceType and difficulty == difficultyID
	end
end

--- Gets the instance information
---@return string|number
function Caffeine.Unit:GetInstanceInfoByParameter(param)
	local _, type, difficulty, _, _, _, _, instance = GetInstanceInfo()

	if param == "type" then
		return type
	elseif param == "difficultyID" then
		return difficulty
	elseif param == "instanceID" then
		return instance
	else
		error("Invalid parameter. Valid parameters are 'type', 'difficultyID', or 'instanceID'.")
	end
end

function Caffeine.Unit:InVehicle()
	return UnitInVehicle(self:GetOMToken())
end

function Caffeine.Unit:UsingVehicle()
	return UnitUsingVehicle(self:GetOMToken())
end

local Draw = Caffeine.Draw:New()
local function hasValue(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

Draw:Sync(function(draw)
	-- Check for the type, difcultyID, instanceID
	if Player:GetInstanceInfoByParameter("instanceID") == 631 then
		-- Drawing at Lady Deathwhisper for Venguful Shade
		local GameObjectIDs = { 48819, 71001 } -- The IDs of the GameObjects you want to draw a circle around
		local circleRadius = 6 -- The radius of the circle
		local playerPos = Player:GetPosition() -- Get the position of the player
		local combatReach = Player:GetCombatReach() -- Get the player's combat reach
		local objects = Objects() -- Retrieve all objects

		for i, object in ipairs(objects) do
			local objectID = ObjectID(object)
			if hasValue(GameObjectIDs, objectID) then -- Check if the object has one of the desired IDs
				local x, y, z = ObjectPosition(object) -- Get the position of the GameObject
				local distance = Draw:Distance(playerPos.x, playerPos.y, playerPos.z, x, y, z) -- Calculate the distance from the player to the GameObject

				-- Calculate the direction vector from the player to the GameObject
				local dirX, dirY = x - playerPos.x, y - playerPos.y
				local mag = math.sqrt(dirX ^ 2 + dirY ^ 2)
				dirX, dirY = dirX / mag, dirY / mag -- Normalize the direction vector

				-- Calculate the edge point of the circle around the GameObject
				local edgeX, edgeY = x - dirX * circleRadius, y - dirY * circleRadius

				-- Draw the line to the edge of the circle around the GameObject
				draw:SetColor(255, 0, 0, 100) -- Set the color for the line (red in this case)
				draw:SetWidth(2) -- Set the width of the line
				draw:Line(playerPos.x, playerPos.y, playerPos.z, edgeX, edgeY, z)

				-- Draw the filled circle around the GameObject
				draw:SetColor(255, 0, 0, 100) -- Set the color for the circle (red in this case)
				draw:FilledCircle(x, y, z, circleRadius)

				-- Draw the name of the GameObject
				draw:SetColor(255, 255, 255, 200) -- Set the color for the text (white in this case)
				draw:Text("Vengeful Shade", "GameFontNormal", x, y, z + 0.5)

				-- Draw the distance below the GameObject's name
				draw:SetColor(255, 255, 255, 200) -- Set the color for the text (white in this case)
				draw:Text(string.format("Distance: %.1f", distance), "GameFontNormal", x, y, z)

				-- Draw the filled circle around the player using combat reach as the radius
				draw:SetColor(255, 0, 0, 100) -- Set the color for the circle (red in this case)
				draw:FilledCircle(playerPos.x, playerPos.y, playerPos.z, combatReach)
			end
		end
	end

	-- Higher Learning
	if Player:GetInstanceInfoByParameter("instanceID") == 571 then
		local HigherLearningObjectIDs = { 192867, 192865, 192708, 192710, 192713, 192866, 192709, 192711 }
		local higherLearningCircleRadius = 1
		local objects = Objects() -- Retrieve all objects
		local playerPos = Player:GetPosition() -- Get the position of the player

		-- Set common drawing properties for lines and circles
		draw:SetWidth(2)
		draw:SetColor(0, 191, 255, 200) -- Light blue color

		for i, object in ipairs(objects) do
			local objectID = ObjectID(object)
			if hasValue(HigherLearningObjectIDs, objectID) then
				local x, y, z = ObjectPosition(object)
				local distance = Draw:Distance(playerPos.x, playerPos.y, playerPos.z, x, y, z)

				-- Draw the line from the player to the GameObject
				draw:Line(playerPos.x, playerPos.y, playerPos.z, x, y, z)

				-- Draw the filled circle around the GameObject
				draw:SetColor(0, 191, 255, 200)
				draw:Circle(x, y, z, higherLearningCircleRadius)

				-- Set color for text
				draw:SetColor(255, 255, 255, 200) -- White color

				-- Draw the name of the GameObject
				local name = ObjectName(object)
				draw:Text(name, "GameFontNormal", x, y, z + 0.5) -- Adjust z position for text readability

				-- Draw the distance below the GameObject's name
				draw:Text(string.format("Distance: %.1f", distance), "GameFontNormal", x, y, z)
			end
		end
	end

	return false
end)

Draw:Enable()
