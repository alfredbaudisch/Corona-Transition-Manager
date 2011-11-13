--[[
	TRANSITIONS MANAGER
		
	Keeps track of all transitions in a scene. You can pause, resume and cancel all transitions at once.
	
	NOTE: If you make changes/updates, feel free to send them to me, so we keep improving the class :)

	@author Alfred R. Baudisch <alfred.r.baudisch@gmail.com>
 	@url http://www.karnakgames.com
	@version 0.6b, 09/Nov/2011 
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
		local tween
		
		local thisId = self.transitionId
		
		self.db[thisId] = {
			object = {},
			params = {},
			timeStarted = 0,
			transition = {},
			remove = {},
			cancel = {}
		}
		
		-- Remove this transition pointers and count
		local function removeItself(whichId)
			local transitionId = whichId
			
			return function()
				if self.db[transitionId].transition ~= nil then
					self.db[transitionId].transition = nil
				end
				
				self.db[transitionId] = nil
				self.goingOn = self.goingOn - 1
			end
		end
		
		-- Allow to cancel this transition
		local function cancelItself(whichId)
			local transitionId = whichId
			
			return function()
				if self.db[transitionId].transition ~= nil then
					transition.cancel(self.db[transitionId].transition)
					self.db[transitionId].transition = nil
				end
				
				self.db[transitionId].remove()
			end
		end
		
		-- Create the callback which will call removal from object
		local function transitionCallback(nextId)
			local transitionId = nextId
			local callback = givenCallback
			
			return function()
				if callback ~= nil then
					callback()
				end
				
				local remove = removeItself(transitionId)
				remove()
			end
		end
		
		if params.alreadyAddedTransitionCallback == nil then
			params.onComplete = transitionCallback(thisId)
			params.alreadyAddedTransitionCallback = true
		end
				
		self.db[thisId] = {
			object = object,
			params = params,
			timeStarted = timeNow,
			transition = transition.to(object, params),
			remove = removeItself(thisId),
			cancel = cancelItself(thisId)
		}
		
		self.transitionId = self.transitionId + 1	
		self.goingOn = self.goingOn + 1	
		
		return self.db[thisId]
	end
	
	function transitions:cancelAll(pausing, ignorePaused)
		if self.goingOn <= 0 then
			return false
		end
		
		if self.paused and (not ignorePaused or ignorePaused == nil) then
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
			if ignorePaused then
				self.paused 		= false
				self.pausedSince 	= 0
			end
			
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