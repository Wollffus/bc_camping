Tent={}
Campfire={}

function play_sound_frontend(audioName, audioRef,b1,p2,b3,p4)
    PlaySound(audioName, audioRef, true,0,true,0)
end

function playAnim(dict,name)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, name, 8.0, 8.0, 2000, 0, 0, true, 0, false, 0, false)
end


function IsPlayerNearEntityWithDistance(entity,distance)
    playerPed = PlayerPedId()
    playerPedCoords = GetEntityCoords(playerPed)
    entityCoords = GetEntityCoords(entity)
    local dist = GetDistanceBetweenCoords(playerPedCoords,entityCoords,true)

    if dist < distance then
        return true
    else
        return false
    end
end

function addBlipForCoords(blipname,bliphash,coords)
    if bliphash==1754365229 then
        Campfire.Blip = Citizen.InvokeNative(0x554D9D53F696D002,1664425300, coords[1], coords[2], coords[3])
        SetBlipSprite(Campfire.Blip,bliphash,true)
        SetBlipScale(Campfire.Blip,0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, Campfire.Blip, blipname)
    else
        Tent.Blip = Citizen.InvokeNative(0x554D9D53F696D002,1664425300, coords[1], coords[2], coords[3])
        SetBlipSprite(Tent.Blip,bliphash,true)
        SetBlipScale(Tent.Blip,0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, Tent.Blip, blipname)
    end

end

function IsThereAnyPropInFrontOfPed(playerPed,frontOffset,radius)


		for k,v in pairs(Config.PropsNearby) do
	        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.5, 0))
			local tentEntity = (GetClosestObjectOfType(x,y,z, 2.5, GetHashKey(v), false, false, false))

			if tentEntity ~= 0 then
				return true
			end
		end

		return false


end

function equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

local playerPed = nil
local playerCoords = nil
local playerHeading = nil
local isPlayerNearTent = nil
local isPlayerNearCampfire = nil
local isPedBuildingTent = nil
local tentroll = 0

Tent.isCreated=false
Tent.isFinished=false
Tent.isClosed=false
Tent.Blip=nil
Tent.Prop=nil
Tent.Pos = nil
Tent.PosHeading=nil
Tent.BedPos=nil
Tent.isBedCreated=false
Tent.isHitchingPostCreated = false

Tent.RequiredItems = { ["wood"]=0, ["leather"]=0 }
Tent.ActualItems = { ["wood"]=0, ["leather"]=0 }
Campfire.RequiredItems = { ["wood"]=0, ["rock"]=0 }
Campfire.ActualItems = { ["wood"]=0, ["rock"]=0 }

Campfire.isCreated=false
Campfire.isFinished=false
Campfire.isOff=false
Campfire.Blip=nil
Campfire.Prop=nil
Campfire.Pos = nil
Campfire.PosHeading=nil

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(0)

		playerPed = PlayerPedId()
		playerCoords = GetEntityCoords(playerPed)
		playerHeading = GetEntityHeading(playerPed)

		if Tent.Prop then
			isPlayerNearTent = IsPlayerNearEntityWithDistance(Tent.Prop,Config.Tent.DistanceToInteract)
			isPlayerNearCampfire = IsPlayerNearEntityWithDistance(Campfire.Prop,Config.Campfire.DistanceToInteract)
			Tent.Pos=GetEntityCoords(Tent.Prop)
			Tent.PosHeading=GetEntityHeading(Tent.Prop)
		end

		if Campfire.Prop then
			Campfire.Pos=GetEntityCoords(Campfire.Prop)
			Campfire.PosHeading=GetEntityHeading(Campfire.Prop)
		end
	end
end)

Citizen.CreateThread(function()

WarMenu.CreateMenu('Tent', 'Camp')

    while true do
        Citizen.Wait(0)


        if isPedBuildingTent then
                playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
                Citizen.Wait(1400)
        end

        if isPlayerNearTent then

        	if not hasAlertInteractKey and Tent.isCreated then
				hasAlertInteractKey=true
				TriggerEvent("redemrp_notification:start", "Press G for camp options" , 4, "success")
			end
            if IsControlPressed(0, 0x760A9C6F) then -- Key to press
                if not WarMenu.IsMenuOpened('Tent') then
                     WarMenu.OpenMenu('Tent')
                end
            end


            if WarMenu.IsMenuOpened('Tent') then

                    if Tent.isFinished then
                    	if not Tent.Blip then
			                Citizen.Wait(500)
			                addBlipForCoords("My Tent",GetHashKey("BLIP_CAMP_TENT"),vector3(Tent.Pos["x"],Tent.Pos["y"],Tent.Pos["z"]))
			            end

                            if Tent.isClosed then
                                    if WarMenu.Button('Open Tent') then
                                            DeleteObject(Tent.Prop)
                                            play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
                                            Tent.Prop = CreateObject(GetHashKey("S_TENT_MAROPEN01X"), Tent.Pos.x, Tent.Pos.y, Tent.Pos.z, true, false, true)
                                            SetEntityAsMissionEntity(Tent.Prop)
                                            SetEntityHeading(Tent.Prop, Tent.PosHeading)
                                            PlaceObjectOnGroundProperly(Tent.Prop)
                                            Tent.isClosed=false
                                    end
                            else
                                    if WarMenu.Button('Close Tent') then
                                            DeleteObject(Tent.Prop)
                                            play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
                                            Tent.Prop = CreateObject(GetHashKey("S_TENT_MARCLOSED01X"), Tent.Pos.x, Tent.Pos.y, Tent.Pos.z, true, false, true)
                                            SetEntityAsMissionEntity(Tent.Prop)
                                            SetEntityHeading(Tent.Prop, Tent.PosHeading)
                                            PlaceObjectOnGroundProperly(Tent.Prop)
                                            Tent.isClosed=true
                                    end
                            end

                            	if not Tent.isHitchingPostCreated then
	                        		if WarMenu.Button('Craft Hitch Post') then

	                        			local propInFrontOfPed = IsThereAnyPropInFrontOfPed(playerPed,1.5,2.0)

	                        	 	   	if propInFrontOfPed then
	                                    	TriggerEvent("redemrp_notification:start", "You can't build here" , 2, "warning")
	                                    else
                                            exports.redemrp_progressbars:DisplayProgressBar(7000, "Setting Hitch post...")
		                                    for i=1,5 do
		                                        playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
		                                        Citizen.Wait(1500)
		                                    end

											local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.4, 0))
											local prop = CreateObject(GetHashKey("p_hitchingPost04x"), x,y,z+2, true, false, true)
		                                    SetEntityAsMissionEntity(prop,playerHeading)
											PlaceObjectOnGroundProperly(prop)
											Tent.HitchingPostProp=prop
											Tent.isHitchingPostCreated=true

	                            		end
	                        		end
	                        	end

                    else

                            if WarMenu.Button('Craft Tent') then

                                if equals(Tent.ActualItems,Tent.RequiredItems,false) then
                                    playAnim("mech_pickup@saddle@putdown_saddle","putdown")
                                    Citizen.Wait(850)
                                    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0))
                                    tentroll = CreateObject(GetHashKey("S_CVAN_TENTROLL01"), x, y, z, true, false, true)
                                    SetEntityAsMissionEntity(tentroll)
                                    SetEntityHeading(tentroll, playerHeading)
                                    PlaceObjectOnGroundProperly(tentroll)
                                    FreezeEntityPosition(tentroll,true)
                                    Citizen.Wait(2500)
                                    exports.redemrp_progressbars:DisplayProgressBar(7000, "Finalizing Tent...")
                                    for i=1,5 do
                                        playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
                                        Citizen.Wait(1500)
                                    end
                                     DeleteObject(Tent.Prop)
                                     DeleteObject(tentroll)
                                   local prop = CreateObject(GetHashKey("S_TENT_MAROPEN01X"), Tent.Pos, true, false, true)
                                   SetEntityAsMissionEntity(prop)
                                   SetEntityHeading(prop, Tent.PosHeading)
                                   PlaceObjectOnGroundProperly(prop)
                                    Tent.Prop=prop
                                    Tent.isFinished=true
                                else
                                    TriggerEvent("redemrp_notification:start", "You need 5 wood and 5 stones" , 2, "warning")
                                end


                                 for itemR,valorR in pairs(Tent.RequiredItems) do
                                    for itemA,valorA in pairs(Tent.ActualItems) do
                                        if itemA == itemR then
                                            Tent.ActualItems[itemA] = valorR
                                        end
                                    end
                                end
                            end

                    end

                    if not Campfire.isCreated then

                        if WarMenu.Button('Craft Campfire') then

                                	local propInFrontOfPed = IsThereAnyPropInFrontOfPed(playerPed,2.5,2.5)

                        	 	   	if propInFrontOfPed then
                                    	TriggerEvent("redemrp_notification:start", "You can't build here" , 2, "warning")
                                    else

	                                    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.4, 0))
	                                    Campfire.Prop = CreateObject(GetHashKey("P_CAMPFIRE_WIN2_01X"), x, y, z-2, true, false, true)
	                                    SetEntityAsMissionEntity(Campfire.Prop)
	                                    SetEntityHeading(Campfire.Prop, playerHeading)
	                                        for i=1,1 do
	                                            playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
	                                            Citizen.Wait(1500)
	                                        end
	                                    local a=GetEntityCoords(Campfire.Prop)
	                                    local b=(a.z+0.9)
	                                        for i=(a.z+0.7),b,0.03 do
	                                            SetEntityCoords(Campfire.Prop,a.x,a.y,i,false,false,false,false)
	                                            Citizen.Wait(45)
	                                        end
	                                    PlaceObjectOnGroundProperly(Campfire.Prop)
	                                    Campfire.isCreated = true
	                                    Campfire.isOff=true
                            		end


                        end
                    else

                        if not Campfire.isFinished then

                            if WarMenu.Button('Build Campfire') then
                                if equals(Campfire.ActualItems,Campfire.RequiredItems,false) then
                                    exports.redemrp_progressbars:DisplayProgressBar(7000, "Building Campfire...")
                                    for i=1,5 do
                                        playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
                                        Citizen.Wait(1500)
                                    end
                                    DeleteObject(Campfire.Prop)
                                    local prop = CreateObject(GetHashKey("P_CAMPFIRE01X_NOFIRE"), Campfire.Pos, true, false, true)
                                    SetEntityAsMissionEntity(prop)
                                    SetEntityHeading(prop, Campfire.PosHeading)
                                    PlaceObjectOnGroundProperly(prop)
                                    Campfire.Prop=prop
                                    Campfire.isFinished=true
                                else
                                	TriggerEvent("redemrp_notification:start", "You need 5 wood and 4 fabrics" , 2, "warning")
                                end

                                for itemR,valorR in pairs(Campfire.RequiredItems) do
                                    for itemA,valorA in pairs(Campfire.ActualItems) do
                                        if itemA == itemR then
                                            Campfire.ActualItems[itemA] = valorR
                                        end
                                    end
                                end
                            end
                        else
                        	if not Campfire.isLogSitCreated then
	                        	 if WarMenu.Button('Set Up Seat') then
	                        	 	   local propInFrontOfPed = IsThereAnyPropInFrontOfPed(playerPed,1.5,2.0)


	                        	 	   	if propInFrontOfPed then
                                        	TriggerEvent("redemrp_notification:start", "You can't build here" , 2, "warning")
                                        else
                                                exports.redemrp_progressbars:DisplayProgressBar(7000, "Setting up Seat...")
		                                    for i=1,5 do
		                                        playAnim("mini_games@story@beechers@build_floor@john","hammer_loop_good")
		                                        Citizen.Wait(1500)
		                                    end

	                                    	local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.4, 0))
		                                    local prop = CreateObject(GetHashKey("p_bench_log01x"), x,y,z, true, false, true)
		                                    SetEntityAsMissionEntity(prop)
		                                    SetEntityHeading(prop, playerHeading)
		                                    PlaceObjectOnGroundProperly(prop)
		                                    Campfire.LogProp=prop
		                                    Campfire.isLogSitCreated=true
	                        	 	   	end
	                        	 	   end
                        	end

                            if Campfire.isOff then
                                    if WarMenu.Button('Light Fire') then
                                    	if isPlayerNearCampfire then
	                                        DeleteObject(Campfire.Prop)
	                                        play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
	                                        Campfire.Prop = CreateObject(GetHashKey("P_CAMPFIRE01X"), Campfire.Pos.x, Campfire.Pos.y, Campfire.Pos.z+2, true, false, true)
	                                        SetEntityAsMissionEntity(Campfire.Prop)
	                                        SetEntityHeading(Campfire.Prop, Campfire.PosHeading)
	                                        PlaceObjectOnGroundProperly(Campfire.Prop)
	                                        Campfire.isOff=false
	                                        Citizen.Wait(800)
										else
											TriggerEvent("redemrp_notification:start", "You must be around the fire" , 2, "warning")
										end

                                    end
                            else
                                    if WarMenu.Button('Extinguish Fire') then
                                    	if isPlayerNearCampfire then
	                                        DeleteObject(Campfire.Prop)
	                                        play_sound_frontend("INFO_HIDE", "Ledger_Sounds", true,0,true,0)
	                                        Campfire.Prop = CreateObject(GetHashKey("P_CAMPFIRE01X_NOFIRE"), Campfire.Pos.x, Campfire.Pos.y, Campfire.Pos.z+2, true, false, true)
	                                        SetEntityAsMissionEntity(Campfire.Prop)
	                                        SetEntityHeading(Campfire.Prop, Campfire.PosHeading)
	                                        PlaceObjectOnGroundProperly(Campfire.Prop)
	                                        Campfire.isOff=true
	                                        Citizen.Wait(800)
	                                    else
                                        	TriggerEvent("redemrp_notification:start", "You must be around the fire" , 2, "warning")
	                                    end
                                    end
                            end

                        end
                    end

                if Tent.BedProp and Tent.isBedCreated then

                        if Tent.IsPedSleepingOnBed then
                            if WarMenu.Button('Get Up') then
                                ClearPedTasks(playerPed)
                                Tent.IsPedSleepingOnBed = false
                            end
                        else
                                if WarMenu.Button('Lay Down') then
                                    if IsPlayerNearEntityWithDistance(Tent.BedProp,Config.Tent.DistanceToSleepInBed) then
                                        local BedX,BedY,BedZ = table.unpack(GetOffsetFromEntityInWorldCoords(Tent.BedProp, 0,0, 0.0,0.0))
                                         Citizen.InvokeNative(0x4D1F61FC34AF3CD1, playerPed, GetHashKey("WORLD_HUMAN_SLEEP_GROUND_ARM"), BedX,BedY,BedZ+0.3,Tent.BedPosHeading-180, 0, true)
                                         Citizen.Wait(1)
                                        Tent.IsPedSleepingOnBed = true
                                    else
                                        TriggerEvent("redemrp_notification:start", "You must be around the bed" , 2, "warning")
                                    end
                                end
                        end
                else
                    if WarMenu.Button('Craft Bed') then
	                    TaskGotoEntityOffset(playerPed, Tent.Prop, 4000,0.0,3.0,1.0,1500)
						local BedX,BedY,BedZ = table.unpack(GetOffsetFromEntityInWorldCoords(Tent.Prop, 0.3, 1.0, 0.0))
						playAnim("mech_pickup@saddle@putdown_saddle","putdown")
						Citizen.Wait(800)
						local bed = CreateObject(GetHashKey("P_AMBBLANKETROLL01X"), BedX,BedY,BedZ, true, false, true)
						SetEntityAsMissionEntity(bed)
						SetEntityHeading(bed, Tent.PosHeading)
						PlaceObjectOnGroundProperly(bed)
						DeleteObject(bed)
	                    local BedX,BedY,BedZ = table.unpack(GetOffsetFromEntityInWorldCoords(Tent.Prop, 0, 0.86, 0.0))
	                    local bed = CreateObject(GetHashKey("s_bedrollfurlined01x"), BedX,BedY,BedZ, true, false, true)
                        SetEntityAsMissionEntity(bed)
                        SetEntityHeading(bed, Tent.PosHeading+95)
                        PlaceObjectOnGroundProperly(bed)
                        Tent.BedProp=bed
                        Tent.BedPos=vector3(BedX,BedY,BedZ)
                        Tent.BedPosHeading=GetEntityHeading(Tent.BedProp)
                        Tent.isBedCreated=true
                	end
            	end

         		WarMenu.Display()
            end
        else
        	hasAlertInteractKey=false

	        if WarMenu.IsMenuOpened('Tent') then
	            WarMenu.CloseMenu()
	        end

        end


    end
end)

RegisterCommand('delcamp', function(source, args, rawCommand)

    if Tent.Prop~=nil then
        RemoveBlip(Tent.Blip)
        DeleteObject(Tent.Prop)
        DeleteObject(Tent.BedProp)
        DeleteObject(Tent.HitchingPostProp)
        Tent={}
        Citizen.Wait(500)
    end
end)

RegisterCommand('camp', function(source, args, rawCommand)

    if Tent.Prop~=nil then
        RemoveBlip(Tent.Blip)
        DeleteObject(Tent.Prop)
        DeleteObject(Tent.BedProp)
        Tent = {}
        Citizen.Wait(500)
    end

    exports.redemrp_progressbars:DisplayProgressBar(15700, "Setting Structure...")
    isPedBuildingTent = true
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 4.4, 0))
    Tent.Prop = CreateObject(GetHashKey("S_TENTCARAVAN01C"), x, y, z, true, false, true)
    SetEntityAsMissionEntity(Tent.Prop)
    SetEntityHeading(Tent.Prop, playerHeading)


    local a=GetEntityCoords(Tent.Prop)
    local b=(a.z-1.3)
    for i=(a.z-4.2),b,0.01 do
        SetEntityCoords(Tent.Prop,a.x,a.y,i,false,false,false,false)
        Citizen.Wait(45)
    end

    PlaceObjectOnGroundProperly(Tent.Prop)
    Tent.isCreated = true
    isPedBuildingTent=false
    Citizen.Wait(4000)

end)

RegisterCommand('delfire', function(source, args, rawCommand)

    if Campfire.Prop~=nil then
        RemoveBlip(Campfire.Blip)
        DeleteObject(Campfire.Prop)
        DeleteObject(Campfire.LogProp)
        Campfire={}
        Citizen.Wait(500)
    end
end)
