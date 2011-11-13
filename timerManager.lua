--[[
	TIMER MANAGER
		
	Just a helper to allow an easy way to cancel all ongoing timers when switching screens, etc.
	Example:
	local timers = require("timerManager")
	timers:add(1000, someFunctionToCall)
	timers:add(2000, someFunctionToCall2)
	
	.. requested to change scene, even with timers going on:
	timers:cancelAll()
	
	NOTE: If you make changes/updates, feel free to send them to me, so we keep improving the class :)

	@author Alfred R. Baudisch <alfred.r.baudisch@gmail.com>
 	@url http://www.karnakgames.com
	@version 0.1b, 09/Nov/2011 
 	@license http://creativecommons.org/licenses/by/3.0/		
]]--
local timers = {
	db = {}
}

function timers:add(time, callback, amount)
	local createdTimer = timer.performWithDelay(time, callback, amount)
	table.insert(self.db, createdTimer)
	return createdTimer
end

function timers:pauseAll()
	local amountTimers = #self.db

	for i = 1, amountTimers do
		if self.db[i] ~= nil then timer.pause(self.db[i]) end
	end
end

function timers:resumeAll()
	local amountTimers = #self.db

	for i = 1, amountTimers do
		if self.db[i] ~= nil then timer.resume(self.db[i]) end
	end
end

function timers:cancelAll()
	local amountTimers = #self.db

	for i = 1, amountTimers do
		if self.db[i] ~= nil then
			timer.cancel(self.db[i])
			self.db[i] = nil
		end
	end
end

return timers