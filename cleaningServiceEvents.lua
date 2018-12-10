--
-- CleaningServiceEvents
--
-- @package 	fs17.cleaningService.specializations.cleaningServiceEvents
-- @auhtor 		IceBlade <www.cg-production.com>
-- @copyright 	2018 CG-Production
-- @license    	www.cg-production.com/license/FS_Script_Licence_2018_1.txt
-- @version		1.0.0.1
-- @history		<1.0.0.0> <11.03.2018> creation
-- 

CleaningServiceEvents = {};
CleaningServiceEvents_mt = Class(CleaningServiceEvents, Event);
InitEventClass(CleaningServiceEvents, 'CleaningServiceEvents');

function CleaningServiceEvents:emptyNew()
    local self = Event:new(CleaningServiceEvents_mt);
    return self;
end;

function CleaningServiceEvents:new(vehicle)
    local self = CleaningServiceEvents:emptyNew();
    self.vehicle = vehicle;
    return self;
end;

function CleaningServiceEvents:writeStream(streamId, connection)
    writeNetworkNodeObject(streamId, self.vehicle);
end

function CleaningServiceEvents:readStream(streamId, connection)
    self.vehicle = readNetworkNodeObject(streamId);
    self:run(connection);
end

function CleaningServiceEvents:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(self, nil, connection, self.vehicle);
    end;
    self.vehicle:setDirtAmount(0);
end

function CleaningServiceEvents.sendEvent(vehicle, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(CleaningServiceEvents:new(vehicle), nil, nil, vehicle);
        else
            g_client:getServerConnection():sendEvent(CleaningServiceEvents:new(vehicle));
        end;
    end
end;
