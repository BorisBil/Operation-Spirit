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
local M2AeonBaseAI = import('/maps/faf_coop_operation_spirit.v0001/faf_coop_operation_spirit_m2aeonai.lua')

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
local SkipNIS3 = false
local SkipNIS4 = false

------------
--- Start up
------------
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
    for _, unit in ScenarioInfo.M1Civilians do
        unit:SetReclaimable(false)
        unit:SetCanBeKilled(false)
        unit:SetCanTakeDamage(false)
        unit:SetCapturable(false)
    end
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

-------------
--- Intro NIS
-------------
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
end

-------------
--- Mission 1
-------------
function Mission1()

    --- Spawn ACUs
    ForkThread(SpawnAllACUs)

    --- 1st Wave Reinforcements
    ForkThread(OffmapLandM1Reinforcements)
    
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

---------------
--- NIS Scene 2
---------------
function NIS2()
    WaitSeconds(4)
    
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

-----------------------
--- Mission 1 Continued
-----------------------
function Mission1Cont()

    --- Transport in Reinforcements
    Transport_Drops = 1
    ForkThread(TransportReinforcements)
    
    --- Frigates and AA Boat Reinforcements
    ForkThread(OffmapSeaReinforcements)
    
    --- Small Enemy Naval Attack
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Sea', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Sea_Attack')
    
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
                IntroNIS3()
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
                ForkThread(Mission1KillT2Def)
                Transport_Drops = 3
                ForkThread(TransportReinforcements)
                for _, unit in ScenarioInfo.M1AeonRadar do
                    if unit and not unit.Dead then
                        unit:Kill()
                    end
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S2)
end

function IntroNIS3()
    
    --- Spawn enemy base and units

    --- West Base and Patrols
    M2AeonBaseAI.AeonM2WestBaseAI()
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Air_West', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_West_Air')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Land1_West', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_West_Land')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Land2_West', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_West_Land')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Naval_West', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_West_Sea')

    --- North Base and Patrols
    M2AeonBaseAI.AeonM2NorthBaseAI()
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Air_North', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_North_Air')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Land1_North', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_North_Land')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Land2_North', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_North_Land')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Naval_North', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_North_Sea')

    --- South Base and Patrols
    M2AeonBaseAI.AeonM2SouthBaseAI()
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Air_South', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_South_Air')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Land_South', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_South_Land')
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Naval_South', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_South_Sea')

    --- Disable North and South bases
    M2AeonBaseAI.DisableBases()

    --- Civilians
    ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Civilians')
    ScenarioInfo.M2AeonStructure = ScenarioUtils.CreateArmyUnit('Objective', 'M2_Objective')

    --- Miscellaneous 
    ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Walls')
    ScenarioInfo.M2AeonT2Defenses = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_T2_Def')
    ScenarioInfo.M2AeonT2Arty = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_T2_Arty')
    ScenarioInfo.M2AeonStealthGen = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Stealth_Gens')

    
    ForkThread(NIS3)
end

---------------
--- NIS Scene 3
---------------
function NIS3()
    WaitSeconds(4)
    
    --- Sea Reinforcements
    for i = 1, 2 do
        ForkThread(OffmapSeaReinforcements)
    end

    --- Set area for Mission 2
    ScenarioFramework.SetPlayableArea('M2_Area', false)
    
    Cinematics.EnterNISMode()
    
    local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50, 'M2_Vis_1', 0, ArmyBrains[Player1])
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS3_Cam_1'), 3)
    WaitSeconds(4)
    
    --- Destroy vis markers, but keep intel
    ForkThread(
    function()
        WaitSeconds(2)
        VisMarker2_1:Destroy()
        WaitSeconds(2)
    end
    )

    Cinematics.ExitNISMode()
    Mission2()
end

-------------
--- Mission 2
-------------
function Mission2()
    ScenarioInfo.MissionNumber = 2

    --- End T1 build restrictions
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.RemoveRestriction(player, categories.TECH1)
    end
    
    --- Primary Objective 1: Kill the island base
    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
    'primary',                      
    'incomplete',                  
    'Destroy the Base',    
    'Destroy the operating enemy base on the island.',  
    'kill',                         
    {                               
        MarkUnits = true,
        Requirements = {
            {
                Area = 'M2_West_Base',
                Category = categories.FACTORY,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Aeon,
            },
        },
    }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)

    --- Player Reinforcements
    Transport_Drops = 4
    ForkThread(TransportReinforcements)
    WaitSeconds(10)
    Transport_Drops = 5
    ForkThread(TransportReinforcements)

    --- Create trigger to next part of mission 2, requiring player to scout the stealth gens in the inactive North and South bases
    ScenarioFramework.CreateArmyIntelTrigger(NIS4, ArmyBrains[Player1], 'LOSNow', false, true, categories.COUNTERINTELLIGENCE, true, ArmyBrains[Aeon])

    --- Create trigger to destroy T2 arty when spotted
    ScenarioFramework.CreateArmyIntelTrigger(M2CivBaseSpotted, ArmyBrains[Player1], 'LOSNow', false, true, categories.AEON, true, ArmyBrains[Objective])

    --- Create timer trigger for additional bases becoming active
    ScenarioFramework.CreateTimerTrigger(M2ActivateBases, 400)
end

--- NIS for when the bases are scouted
function NIS4()
    WaitSeconds(3)
    Cinematics.EnterNISMode()
    
    local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'M2_Vis_2', 0, ArmyBrains[Player1])
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS4_Cam_1'), 2)
    WaitSeconds(3)

    local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(50, 'M2_Vis_3', 0, ArmyBrains[Player1])
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('NIS4_Cam_2'), 3)
    WaitSeconds(3)

    --- Destroy vis markers, but keep intel
    ForkThread(
    function()
        WaitSeconds(2)
        VisMarker2_2:Destroy()
        WaitSeconds(2)
        VisMarker2_3:Destroy()
        WaitSeconds(2)
    end
    )

    Cinematics.ExitNISMode()
    
    Mission2Add()
end


--- Create objectives when bases are spotted
function Mission2Add()
    
    --- Primary Objective 2: Destroy the North base
    ScenarioInfo.M2P2 = Objectives.CategoriesInArea(
    'primary',                      
    'incomplete',                  
    'Destroy the Base',    
    'Destroy the operating enemy base on the island.',  
    'kill',                         
    {                               
        MarkUnits = true,
        Requirements = {
            {
                Area = 'M2_North_Base',
                Category = categories.FACTORY,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Aeon,
            },
        },
    }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P2)

    --- Primary Objective 3: Destroy the South base
    ScenarioInfo.M2P3 = Objectives.CategoriesInArea(
    'primary',                      
    'incomplete',                  
    'Destroy the Base',    
    'Destroy the operating enemy base on the island.',  
    'kill',                         
    {                               
        MarkUnits = true,
        Requirements = {
            {
                Area = 'M2_South_Base',
                Category = categories.FACTORY,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Aeon,
            },
        },
    }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P3)

    --- When player scouts the civilian island, create secondary objective
    ScenarioFramework.CreateArmyIntelTrigger(M2CivBaseSpotted, ArmyBrains[Player1], 'LOSNow', false, true, categories.AEON, true, ArmyBrains[Objective])
end

--- Create objective when base is spotted
function M2CivBaseSpotted()
    
    --- Secondary Objective 1: Capture the target
    ScenarioInfo.M2S1 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Capture the Structure',             
        'Capture the structure that seems to be causing the localized malfunctions.',
        {
            Units = {ScenarioInfo.M2AeonStructure},
            FlashVisible = true,
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)
end

--- Create objective when arty is spotted
function M2ArtySpotted()
    --- Secondary Objective 2: Destroy the artillery
    ScenarioInfo.M2S2 = Objectives.CategoriesInArea(
    'secondary',                      
    'incomplete',                  
    'Destroy Artillery Defenses',    
    'Destroy the Artillery installations guarding the entrance to the bases.',  
    'kill',                         
    {                               
        MarkUnits = true,
        Requirements = {
            {
                Area = 'M2_North_Base',
                Category = categories.ARTILLERY,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Aeon,
            },
        },
    }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S2)
end

-------------
--- Mission 3
-------------

function NIS5()
end

function Mission3()
end

--------------------
--- Helper Functions
--------------------

-----------------------------
--- Destroy T2 Defenses In M1
-----------------------------
function Mission1KillT2Def()
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

-----------------------------
--- Destroy T2 Defenses In M2
-----------------------------
function Mission2KillT2Def()
    local flipToggle = false
    for _, unit in ScenarioInfo.M2AeonT2Defenses do
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

-------------------------------
--- Off-map Land Reinforcements
-------------------------------
function OffmapLandM1Reinforcements()
    for i = 1, 6 do
        local tank = ScenarioUtils.CreateArmyUnit('Player1', 'LightTank1')
        IssueMove({tank}, ScenarioUtils.MarkerToPosition('M1_Land_1R'))
        WaitSeconds(1)
    end
end

------------------------------
--- Off-map Sea Reinforcements
------------------------------
function OffmapSeaReinforcements()
    for i = 1, 2 do
        local boat = ScenarioUtils.CreateArmyUnit('Player1', 'Frigate')
        IssueMove({boat}, ScenarioUtils.MarkerToPosition('M1_Sea_Attackc'))
        WaitSeconds(1)
    end
    local boat = ScenarioUtils.CreateArmyUnit('Player1', 'PatrolBoat')
    IssueMove({boat}, ScenarioUtils.MarkerToPosition('M1_Sea_Attackc'))
end

--------------------------------------------
--- Transport in Reinforcements from off-map
--------------------------------------------
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
    WaitSeconds(2)
    --- IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M1_Reinforcements'))
end

--------------
--- ACU Spawns
--------------
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
--- ACU Death
-------------
function PlayerDeath(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
end