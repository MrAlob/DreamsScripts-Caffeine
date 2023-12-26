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
