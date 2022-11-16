-------------------------------------------------------------------------------------
---  File:      maps/faf_coop_operation_spirit/faf_coop_operation_spirit_m2aeonai.lua
---  Author(s): Gently
---
---  Summary:   This is the AI file in control of the enemy Aeon bases in
---             Mission 2
-------------------------------------------------------------------------------------

-----------
--- Imports
-----------
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

----------
--- Locals
----------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty

local AeonM2WestBase = BaseManager.CreateBaseManager()
local AeonM2NorthBase = BaseManager.CreateBaseManager()
local AeonM2SouthBase = BaseManager.CreateBaseManager()

------------------
--- Base Functions
------------------

-------------
--- West Base
-------------
function AeonM2WestBaseAI()
    AeonM2WestBase:Initialize(ArmyBrains[Aeon], 'M2_West_Base', 'M2_Aeon_West_Base', 50, {M2_West_Base = 100})
    AeonM2WestBase:StartNonZeroBase({{4, 5, 7}, {3, 4, 5}})
    AeonM2WestBase:SetActive('AirScouting', true)
    AeonM2WestBase:SetActive('LandScouting', true)

    AeonM2WestBaseLandAttacks()
    AeonM2WestBaseNavalAttacks()
    AeonM2WestBaseAirAttacks()
end

--- West Base Land Attacks
function AeonM2WestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Aurora Attack
    quantity = {6, 8, 10}
    opai =  AeonM2WestBase:AddOpAI('BasicLandAttack', 'M2_West_Land_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_West_Land_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end

--- West Base Naval Attacks
function AeonM2WestBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Frigate Attack
    opai = AeonM2WestBase:AddNavalAI('M2_West_Naval_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_West_Naval_Attack_1'
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )
end

--- West Base Air Attacks
function AeonM2WestBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Bomber Attack
    quantity = {2, 4, 6}
    opai =  AeonM2WestBase:AddOpAI('AirAttacks', 'M2_West_Air_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_West_Air_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

--------------
--- North Base
--------------
function AeonM2NorthBaseAI()
    AeonM2NorthBase:Initialize(ArmyBrains[Aeon], 'M2_North_Base', 'M2_Aeon_North_Base', 50, {M2_North_Base = 100})
    AeonM2NorthBase:StartNonZeroBase({{5, 6, 8}, {4, 5, 6}})
    AeonM2NorthBase:SetActive('AirScouting', true)
    AeonM2NorthBase:SetActive('LandScouting', true)

    AeonM2NorthBaseLandAttacks()
    AeonM2NorthBaseNavalAttacks()
    AeonM2NorthBaseAirAttacks()
end

--- North Base Land Attacks
function AeonM2NorthBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Aurora Attack
    quantity = {6, 8, 10}
    opai =  AeonM2NorthBase:AddOpAI('BasicLandAttack', 'M2_North_Land_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_North_Land_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end

--- North Base Naval Attacks
function AeonM2NorthBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Frigate Attack
    opai = AeonM2NorthBase:AddNavalAI('M2_North_Naval_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_North_Naval_Attack_1'
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )
end

--- North Base Air Attacks
function AeonM2NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Bomber Attack
    quantity = {2, 4, 6}
    opai =  AeonM2NorthBase:AddOpAI('AirAttacks', 'M2_North_Air_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_North_Air_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

--------------
--- South Base
--------------
function AeonM2SouthBaseAI()
    AeonM2SouthBase:Initialize(ArmyBrains[Aeon], 'M2_South_Base', 'M2_Aeon_South_Base', 50, {M2_South_Base = 100})
    AeonM2SouthBase:StartNonZeroBase({{5, 6, 8}, {4, 5, 6}})
    AeonM2SouthBase:SetActive('AirScouting', true)
    AeonM2SouthBase:SetActive('LandScouting', true)

    AeonM2SouthBaseLandAttacks()
    AeonM2SouthBaseNavalAttacks()
    AeonM2SouthBaseAirAttacks()
end

--- South Base Land Attacks
function AeonM2SouthBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Aurora Attack
    quantity = {6, 8, 10}
    opai =  AeonM2SouthBase:AddOpAI('BasicLandAttack', 'M2_South_Land_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Land_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end

--- South Base Naval Attacks
function AeonM2SouthBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Frigate Attack
    opai = AeonM2SouthBase:AddNavalAI('M2_South_Naval_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Naval_Attack_1'
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )
end

--- North Base Air Attacks
function AeonM2SouthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Bomber Attack
    quantity = {2, 4, 6}
    opai =  AeonM2SouthBase:AddOpAI('AirAttacks', 'M2_South_Air_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Air_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

--------------------
--- Helper Functions
--------------------

--- Disable Bases
function DisableBases()
    if(AeonM2NorthBase) then
        AeonM2SouthBase:BaseActive(false)
        AeonM2NorthBase:BaseActive(false)
    end
end

--- Activate Bases
function ActivateBases()
    if(AeonM2NorthBase) then
        AeonM2SouthBase:BaseActive(true)
        AeonM2NorthBase:BaseActive(true)
    end
end