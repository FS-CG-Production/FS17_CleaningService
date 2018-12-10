--
-- CleaningService
--
-- @package 	fs17.cleaningService.specializations.cleaningService
-- @auhtor 		IceBlade <www.cg-production.com>
-- @copyright 	2018 CG-Production
-- @license    	www.cg-production.com/license/FS_Script_Licence_2018_1.txt
-- @version		1.0.0.1
-- @history		<1.0.0.0> <11.03.2018> creation
-- 

CleaningService = {};

function CleaningService:loadMap(name)
	if g_currentMission.cleaningService ~= nil then
		error("[CleaningService.lua] Modification is loaded more than one time. Remove all copy's of the modification");
	end;

	g_currentMission.cleaningService = true;
	self.pricePercent = 0.01;
	self.vehicleOffset = 1;
	self.priceItems = {
		10, -- unkeep high pressure cleaner
		80, -- wear-free
		100, -- employee
	};
	self.minDirtAmount = -1;
end;

function CleaningService:deleteMap()
end;

function CleaningService:mouseEvent(posX, posY, isDown, isUp, button) 
end;

function CleaningService:keyEvent(unicode, sym, modifier, isDown) 
end;

function CleaningService:update(dt)
	if g_currentMission.cleaningService then
		local playerPosX, playerPosY, playerPosZ = getWorldTranslation(g_currentMission.player.rootNode);
		for v, vehicle in pairs(g_currentMission.vehicles) do
			if vehicle.sizeWidth ~= nil and vehicle.sizeLength ~= nil then
				local x,y,z = getWorldTranslation(vehicle.rootNode);
				if playerPosX < (x + (vehicle.sizeWidth / 2) + self.vehicleOffset) and playerPosX > (x - (vehicle.sizeWidth / 2) - self.vehicleOffset) then
					if playerPosZ < (z + (vehicle.sizeLength / 2) + self.vehicleOffset) and playerPosZ > (z - (vehicle.sizeLength / 2) - self.vehicleOffset) then
						if vehicle:getDirtAmount() > self.minDirtAmount then
							local price = self:getCleanPrice(vehicle.price, vehicle:getDirtAmount());
							if price ~= 0 then
								local string = string.format(g_i18n:getText("clean"), price);
								g_currentMission:addHelpButtonText(string, InputBinding.Clean, nil, GS_PRIO_HIGH);
								if InputBinding.hasEvent(InputBinding.Clean) then
									self:updateDirtAmount(vehicle, false);
									if g_server ~= nil then
										g_currentMission:addSharedMoney(-price);
									else
										g_client:getServerConnection():sendEvent(CheatMoneyEvent:new(-price));
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

function CleaningService:updateDirtAmount(vehicle, noEventSend)
	vehicle:setDirtAmount(0);
	CleaningServiceEvents.sendEvent(vehicle, false);
end

function CleaningService:getCleanPrice(vehiclePrice, dirtAmount)
	if vehiclePrice ~= nil and vehiclePrice ~= 0 then
		vehiclePrice = vehiclePrice * self.pricePercent;
		for item in pairs(self.priceItems) do
			vehiclePrice = vehiclePrice + item;
		end;
		vehiclePrice = math.ceil(vehiclePrice);
		return vehiclePrice;
	else
		return 0;
	end;
end;

function CleaningService:draw()
end;

addModEventListener(CleaningService);
