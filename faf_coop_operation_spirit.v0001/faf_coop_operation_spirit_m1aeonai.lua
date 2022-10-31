-------------------------------------------------------------------------------------
---  File:      maps/faf_coop_operation_spirit/faf_coop_operation_spirit_m1aeonai.lua
---  Author(s): Gently
---
---  Summary:   This is the AI file in control of the enemy Aeon bases in
---             Mission 1
-------------------------------------------------------------------------------------

local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty

local AeonM1Base1 = BaseManager.CreateBaseManager()
local AeonM1Base2 = BaseManager.CreateBaseManager()

-----------------
-- Base Functions
-----------------

--- Set up first base
function AeonM1Base1AI()
    AeonM1Base1:Initialize(ArmyBrains[Aeon], 'M1_Base_1', 'M1_Aeon_Base_1', 20, {M1_Factories_1 = 10})
    AeonM1Base1:StartNonZeroBase(0)
    AeonM1Base1AirDefenses()
    AeonM1Base1LandDefenses()
end

--- Set up second base
function AeonM1Base2AI()
    AeonM1Base2:Initialize(ArmyBrains[Aeon], 'M1_Base_2', 'M1_Aeon_Base_2', 20, {M1_Factories_2 = 10})
    AeonM1Base2:StartNonZeroBase(0)
    AeonM1Base2LandDefenses()
end

--- First base air unit defenses
function AeonM1Base1AirDefenses()
    local opai = nil
    local quantity = {}

    quantity = {10}
    opai = AeonM1Base1:AddOpAI('AirAttacks', 'M1_Base_Air',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Patrol_1A'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity)
end

--- First base land unit defenses
function AeonM1Base1LandDefenses()
    local opai = nil
    local quantity = {}

    quantity = {10}
    opai = AeonM1Base1:AddOpAI('BasicLandAttack', 'M1_Base_Land_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Patrol_1L'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity)
end

--- Second base land unit defenses
function AeonM1Base2LandDefenses()
    local opai = nil
    local quantity = {}

    quantity = {50}
    opai = AeonM1Base1:AddOpAI('BasicLandAttack', 'M1_Base_Land_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Patrol_2L'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity)
end