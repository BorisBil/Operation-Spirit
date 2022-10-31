-------------------------------------------------------------------------------------
---  File:      maps/faf_coop_operation_spirit/faf_coop_operation_spirit_script.lua
---  Author(s): Gently
---
---  Summary:   This is the main file in control of the events during
---             Operation Spirit
-------------------------------------------------------------------------------------

-----------
--- Imports
-----------
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Objectives = import( '/lua/ScenarioFramework.lua' ).Objectives
local SimCamera = import('/lua/SimCamera.lua').SimCamera
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local Cinematics = import('/lua/cinematics.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local Utilities = import('/lua/utilities.lua')
local M1AeonBaseAI = import('/maps/faf_coop_operation_spirit.v0001/faf_coop_operation_spirit_m1aeonai.lua')

-----------
--- Globals
-----------

--- Reinforcement Transport Drop total
Transport_Drops = 0

--- Army IDs
ScenarioInfo.Player1 = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.Seraphim = 3
ScenarioInfo.Civilians = 4
ScenarioInfo.Objective = 5
ScenarioInfo.Wrecks = 6
ScenarioInfo.Player2 = 7

----------
--- Locals
----------
local Player1 = ScenarioInfo.Player1
local Aeon = ScenarioInfo.Aeon
local Seraphim = ScenarioInfo.Seraphim
local Civilians = ScenarioInfo.Civilians
local Objective = ScenarioInfo.Objective
local Wrecks = ScenarioInfo.Wrecks
local Player2 = ScenarioInfo.Player2

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionTimer = ScenarioInfo.Options.Expansion

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 1

---------------
--- Debug only!
---------------
local Debug = false
local SkipNIS1 = false
local SkipNIS2 = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    
    --- Number of Players
    ScenarioInfo.NumberOfPlayers = table.getsize(ScenarioInfo.HumanPlayers)
    
    --- Set Colors
    ScenarioFramework.SetAeonPlayerColor(Player1)
    ScenarioFramework.SetAeonEvilColor(Aeon)
    ScenarioFramework.SetSeraphimColor(Seraphim)
    ScenarioFramework.SetAeonAlly2Color(Civilians)
    ScenarioFramework.SetNeutralColor(Objective)
    local colors = {
        ['Player2'] = {67, 110, 238}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
    
    --- Civilian Town
    ScenarioInfo.M1Civilians = ScenarioUtils.CreateArmyGroup('Civilians', 'M1_Civilians')
    ScenarioInfo.M1AeonRadar = ScenarioUtils.CreateArmyUnit('Objective', 'M1_Objective')

    --- Enemy Bases and Units
    M1AeonBaseAI.AeonM1Base1AI()
    M1AeonBaseAI.AeonM1Base2AI()
    ScenarioUtils.CreateArmyGroup('Aeon', 'M1_Base_1')
    ScenarioUtils.CreateArmyGroup('Aeon', 'M1_Base_2')
    ScenarioUtils.CreateArmyGroup('Aeon', 'M1_Base_3')
    ScenarioInfo.M1AeonT2Defenses = ScenarioUtils.CreateArmyGroup('Aeon', 'M1_Def')
    ScenarioUtils.CreateArmyGroup('Aeon', 'M1_Walls')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Land_1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_1L')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Air_1', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_1A')

    --- Set structure to be unkillable for ease of play
    ScenarioInfo.M1AeonRadar:SetReclaimable(false)
    ScenarioInfo.M1AeonRadar:SetCanBeKilled(false)
    ScenarioInfo.M1AeonRadar:SetCanTakeDamage(false)

    --- Set civilians to be unkillable for ease of play
    ScenarioInfo.M1Civilians:SetReclaimable(false)
    ScenarioInfo.M1Civilians:SetCanBeKilled(false)
    ScenarioInfo.M1Civilians:SetCanTakeDamage(false)
    ScenarioInfo.M1Civilians:SetCapturable(false)
end

function OnStart(scenario)
    
    --- Build Restrictions
    ScenarioFramework.AddRestrictionForAllHumans( categories.TECH1 
                                                + categories.TECH2
                                                + categories.TECH3 )
    
    --- ACU Upgrade Restrictions
    ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                            'T3Engineering',
                                            'AdvancedEngineering',
                                            'ChronoDampener',
                                            'Shield',
                                            'ShieldHeavy',
                                            'HeatSink',
                                            'Teleporter'})
    
    --- Set the maximum number of units that the players is allowed to have
    ScenarioFramework.SetSharedUnitCap(200)

    --- Set playable area
    ScenarioFramework.SetPlayableArea('M1_Area', false)

    --- Proceed to NIS
    if not SkipNIS1 then
        ForkThread(NIS1)
    else
        Mission1()
    end
end

------------
-- Intro NIS
------------
function NIS1()
    --- Enter cinematic mode, move to Aeon base target
    Cinematics.EnterNISMode()
    local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(30, 'M1_Vis_1', 0, ArmyBrains[Player1])
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS1_Cam_1'), 3)
    WaitSeconds(3)
    
    --- Filler
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS1_Cam_2'), 3)
    
    --- Spawn Player units, initiate attack
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'M1_Land', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_1L')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'M1_Air', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_1A')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'M1_Sea', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Sea')
    ScenarioUtils.CreateArmyGroup('Player1', 'M1_Resources')

    WaitSeconds(3)
    
    --- Move to ACU Spawn
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS1_Cam_3'), 1)
    
    --- Destroy intel
    ForkThread(
    function()
        WaitSeconds(2)
        VisMarker1_1:Destroy()
        WaitSeconds(2)
        ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1'), 40)
    end
    )

    Cinematics.ExitNISMode()

    --- Proceed to Mission 1
    Mission1()
    
    --- 1st Reinforcements
    for i = 1, 6 do
        local tank = ScenarioUtils.CreateArmyUnit('Player1', 'LightTank1')
        IssueMove({tank}, ScenarioUtils.MarkerToPosition('M1_Land_1R'))
        WaitSeconds(1)
    end
end

------------
-- Mission 1
------------
function Mission1()

    --- Spawn ACUs
    ForkThread(SpawnAllACUs)
    
    --- Mission Number
    ScenarioInfo.MissionNumber = 1

    --- Primary Objective 1: Kill the base
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
    'primary',                      
    'incomplete',                  
    'Destroy Forward Base',    
    'Destroy the base and its protectors in order to set up operations.',  
    'kill',                         
    {                               
        MarkUnits = true,
        Requirements = {
            {
                Area = 'M1_Base_1',
                Category = categories.FACTORY + categories.ECONOMIC + categories.ANTIAIR + categories.DIRECTFIRE + categories.INDIRECTFIRE,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Aeon,
            },
        },
    }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                --- Proceed to NIS
                if not SkipNIS2 then
                    NIS2()
                else
                    Mission1Cont()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
end

--------------
-- NIS Scene 2
--------------
function NIS2()
    WaitSeconds(5)
    
    --- Create enemy patrols
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Land_2a', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_2L')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Land_2b', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_2L')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Land_3', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_3L')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Air_2', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Patrol_2A')

    
    --- Set playable area
    ScenarioFramework.SetPlayableArea('M1_Area_Exp', false)

    Cinematics.EnterNISMode()

    --- Show the civilian town and the secondary objective, surrounded by defenses
    local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'M1_Vis_2', 0, ArmyBrains[Player1])
    local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaLocation(50, 'M1_Vis_3', 0, ArmyBrains[Player1])
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS2_Cam_1'), 3)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS2_Cam_2'), 3)
    WaitSeconds(2)

    --- Destroy vis markers, but keep intel
    ForkThread(
    function()
        WaitSeconds(2)
        VisMarker1_2:Destroy()
        VisMarker1_3:Destroy()
        WaitSeconds(2)
    end
    )

    Cinematics.ExitNISMode()
    WaitSeconds(2)
    Mission1Cont()
end

----------------------
-- Mission 1 Continued
----------------------
function Mission1Cont()
    Transport_Drops = 1
    ForkThread(TransportReinforcements)
    Transport_Drops = 3
    ForkThread(TransportReinforcements)
    
    --- Primary Objective 2: Kill the second base
    ScenarioInfo.M1P2 = Objectives.CategoriesInArea(
    'primary',                      
    'incomplete',                  
    'Destroy Civilian Defenses',    
    'Destroy the malfunctioning defenses surrounding the civilian town.',  
    'kill',                         
    {                               
        MarkUnits = true,
        Requirements = {
            {
                Area = 'M1_Base_2',
                Category = categories.FACTORY + categories.ECONOMIC + categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.ANTIAIR,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Aeon,
            },
        },
    }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result)
            if(result) then
                ForkThread(NIS3)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P2)
    
    --- Secondary Objective 1: Kill the defenses around the capture target
    ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
    'secondary',                      
    'incomplete',                  
    'Destroy Civilian Defenses',    
    'Destroy the malfunctioning defenses surrounding the civilian target structure',  
    'kill',                         
    {                               
        MarkUnits = true,
        Requirements = {
            {
                Area = 'M1_Base_3',
                Category = categories.FACTORY + categories.ECONOMIC + categories.DIRECTFIRE + categories.INDIRECTFIRE + categories.ANTIAIR,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Aeon,
            },
        },
    }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                Transport_Drops = 2
                ForkThread(TransportReinforcements)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)

    --- Secondary Objective 2: Capture the target
    ScenarioInfo.M1S2 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Capture the Structure',             
        'Capture the structure that seems to be causing the localized malfunctions.',
        {
            Units = {ScenarioInfo.M1AeonRadar},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1S2:AddResultCallback(
        function(result)
            if(result) then
                ForkThread(Mission1KillT2PD)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S2)
end

function NIS3()
    Mission2()
end

function Mission2()
end

-------------------
-- Helper Functions
-------------------

-------------
-- Destroy PD
-------------
function Mission1KillT2PD()
    local flipToggle = false
    for _, unit in ScenarioInfo.M1AeonT2Defenses do
        if unit and not unit.Dead then
            unit:Kill()
            if flipToggle then
                WaitSeconds(0.1)
                flipToggle = false
            else
                WaitSeconds(0.1)
                flipToggle = true
            end
        end
    end
end

-------------------------------------------
-- Transport in Reinforcements from off-map
-------------------------------------------
function TransportReinforcements()
    local allUnits = {}
    local allTransports = {}
        
    local transport = ScenarioUtils.CreateArmyUnit('Player1', 'Transport_' .. Transport_Drops)
    local units = ScenarioUtils.CreateArmyGroup('Player1', 'M1_Land_R' .. Transport_Drops)
    table.insert(allTransports, transport)
    for k, v in units do
        table.insert(allUnits, v)
    end

    ScenarioFramework.AttachUnitsToTransports(units, {transport})
    WaitSeconds(0.5)
    IssueMove({transport}, ScenarioUtils.MarkerToPosition('M1_Land_1R'))
    WaitSeconds(10)
    IssueMove({transport}, ScenarioUtils.MarkerToPosition('M1_Land_1R'))
    --- IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M1_Reinforcements'))
end

-------------
-- ACU Spawns
-------------
function SpawnAllACUs()
    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)
    
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy == ScenarioInfo.Player2 then
            ScenarioInfo.CoopCDR[2] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)
            WaitSeconds(0.5)
        end
    end
end

-------------
-- ACU Death
-------------
function PlayerDeath(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
end