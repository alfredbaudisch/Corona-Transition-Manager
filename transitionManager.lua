--[[
	TRANSITIONS MANAGER
		
	Keeps track of all transitions in a scene. You can pause, resume and cancel all transitions at once.
	
	NOTE: If you make changes/updates, feel free to send them to me, so we keep improving the class :)

	@author Alfred R. Baudisch <alfred.r.baudisch@gmail.com>
 	@url http://www.karnakgames.com
	@version 0.5b, 04/Mar/2011 
 	@license http://creativecommons.org/licenses/by/3.0/		
]]--
module(..., package.seeall)

function new()
	local transitions = {
		goingOn = 0,
		transitionId = 1,
		db = {},
		
		paused = false,
		pausedSince = 0,
	}

	function transitions:add(object, params)
		local timeNow = system.getTimer()
		local givenCallback	= params.onComplete
		
		local function transitionCallback(nextId)
			local transitionId = nextId
			local callback = givenCallback
			
			return function()
				if callback ~= nil then
					callback()
				end
				
				self.db[transitionId] = nil
				self.goingOn = self.goingOn - 1
			end
		end
		
		if params.alreadyAddedTransitionCallback == nil then
			params.onComplete = transitionCallback(self.transitionId)
			params.alreadyAddedTransitionCallback = true
		end
				
		self.db[self.transitionId] = {
			object = object,
			params = params,
			timeStarted = timeNow,
			transition = transition.to(object, params)
		}
		
		self.transitionId = self.transitionId + 1	
		self.goingOn = self.goingOn + 1	
	end
	
	function transitions:cancelAll(pausing)
		if self.paused then
			self.paused 		= false
			self.pausedSince 	= 0
		
		else		
			for i, v in pairs(self.db) do
				if v.transition ~= nil then 
					transition.cancel(v.transition)
					v.transition = nil
				end
			end			
		end
		
		if pausing == nil or pausing == false then
			self.goingOn 		= 0
			self.transitionId 	= 1
		
			for i, v in pairs(self.db) do
				v = nil
			end
		
			self.db = {}
		end
	
		collectgarbage()
	end
	
	function transitions:pauseAll()
		if self.paused then
			return false
		end
		
		self:cancelAll(true)
		self.paused = true
		self.pausedSince = system.getTimer()
	end
	
	function transitions:resumeAll()
		if not self.paused then
			return false
		end
		
		local timeNow = system.getTimer()
	
		for i, v in pairs(self.db) do
			v.params.time = v.params.time - (self.pausedSince - v.timeStarted)
			v.timeStarted = timeNow
			v.transition = transition.to(v.object, v.params)
		end
		
		self.paused = false
		self.pausedSince = 0
	end
	
	return transitions
end