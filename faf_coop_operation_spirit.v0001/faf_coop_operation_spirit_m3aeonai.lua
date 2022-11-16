-------------------------------------------------------------------------------------
---  File:      maps/faf_coop_operation_spirit/faf_coop_operation_spirit_m2aeonai.lua
---  Author(s): Gently
---
---  Summary:   This is the AI file in control of the enemy Aeon bases in
---             Mission 3
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

local AeonM3WestBase = BaseManager.CreateBaseManager()
local AeonM3EastBase = BaseManager.CreateBaseManager()
local AeonM3ForwardBase = BaseManager.CreateBaseManager()

------------------
--- Base Functions
------------------

-------------
--- West Base
-------------
function AeonM3WestBaseAI()
    AeonM3WestBase:Initialize(ArmyBrains[Aeon], 'M3_West_Base', 'M3_Aeon_West_Base', 100, {M3_West_Base = 100})
    AeonM3WestBase:StartNonZeroBase({{8, 9, 10}, {6, 7, 8}})
    AeonM3WestBase:SetActive('AirScouting', true)
    AeonM3WestBase:SetActive('LandScouting', true)

    AeonM3WestBaseLandAttacks()
    AeonM3WestBaseNavalAttacks()
    AeonM3WestBaseAirAttacks()
end

--- West Base Land Attacks
function AeonM3WestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Aurora Attack
    quantity = {6, 8, 10}
    opai =  AeonM3WestBase:AddOpAI('BasicLandAttack', 'M3_West_Land_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_West_Land_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end

--- West Base Naval Attacks
function AeonM3WestBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Frigate Attack
    opai = AeonM3WestBase:AddNavalAI('M3_West_Naval_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_West_Naval_Attack_1'
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 6,
            MinFrigates = 4,
            Priority = 100,
        }
    )
end

--- West Base Air Attacks
function AeonM3WestBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Bomber Attack
    quantity = {4, 6, 8}
    opai =  AeonM3WestBase:AddOpAI('AirAttacks', 'M3_West_Air_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_West_Air_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

-------------
--- East Base
-------------
function AeonM3EastBaseAI()
    AeonM3EastBase:Initialize(ArmyBrains[Aeon], 'M3_East_Base', 'M3_Aeon_East_Base', 100, {M3_East_Base = 100})
    AeonM3EastBase:StartNonZeroBase({{9, 10, 11}, {7, 8, 9}})
    AeonM3EastBase:SetActive('AirScouting', true)
    AeonM3EastBase:SetActive('LandScouting', true)

    AeonM3EastBaseLandAttacks()
    AeonM3EastBaseNavalAttacks()
    AeonM3EastBaseAirAttacks()
end

--- East Base Land Attacks
function AeonM3EastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Aurora Attack
    quantity = {6, 8, 10}
    opai =  AeonM3EastBase:AddOpAI('BasicLandAttack', 'M3_East_Land_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_Land_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end

--- East Base Naval Attacks
function AeonM3EastBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Frigate Attack
    opai = AeonM3EastBase:AddNavalAI('M3_East_Naval_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_Naval_Attack_1'
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 6,
            MinFrigates = 4,
            Priority = 100,
        }
    )
end

--- East Base Air Attacks
function AeonM3EastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Bomber Attack
    quantity = {4, 6, 8}
    opai =  AeonM3EastBase:AddOpAI('AirAttacks', 'M3_East_Air_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_Air_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

----------------
--- Forward Base
----------------
function AeonM3ForwardBaseAI()
    AeonM3ForwardBase:Initialize(ArmyBrains[Aeon], 'M3_Forward_Base', 'M3_Aeon_Forward_Base', 30, {M3_Forward_Base = 100})
    AeonM3ForwardBase:StartNonZeroBase({{1, 2, 3}, {1, 2, 3}})
    AeonM3ForwardBase:SetActive('AirScouting', true)
    AeonM3ForwardBase:SetActive('LandScouting', true)

    AeonM3ForwardBaseLandAttacks()
    AeonM3ForwardBaseAirAttacks()
end

--- Forward Base Air Attacks
function AeonM3ForwardBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Bomber Attack
    quantity = {4, 6, 8}
    opai =  AeonM3ForwardBase:AddOpAI('AirAttacks', 'M3_Forward_Air_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Forward_Air_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

--- Forward Base Land Attacks
function AeonM3ForwardBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --- Aurora Attack
    quantity = {6, 8, 10}
    opai =  AeonM3EastBase:AddOpAI('BasicLandAttack', 'M3_Forward_Land_Attack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Forward_Land_Attack_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end