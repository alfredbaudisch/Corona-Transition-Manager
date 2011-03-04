--[[
	Example on how to use the Transition Manager to add, pause, resume and cancel transitions.

	@author Alfred R. Baudisch <alfred.r.baudisch@gmail.com>
 	@url http://www.karnakgames.com
	@version 1.0, 04/Mar/2011
	@license CODE: Use and modify as you wish.
	@license GRAPHICS: http://www.flyingyogi.com/fun/spritelib.html
]]--
local ui = require("ui")
local tm = require("../transitionManager")
tm = tm.new()

local buttonPause, buttonResume, buttonRestart
local originalPositions = {{0, 0}, {0, 0}}
local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
background:setFillColor(21, 115, 193)

local plane1 = display.newImage("plane.png")
plane1.x = plane1.contentWidth * .5
plane1.y = plane1.contentHeight
originalPositions[1][1] = plane1.x
originalPositions[2][1] = plane1.y

local plane2 = display.newImage("plane.png")
plane2.x = display.contentCenterX
plane2.y = plane2.contentHeight * 3

local plane3 = display.newImage("plane.png")
plane3.x = display.contentCenterX
plane3.y = plane3.contentHeight * 5

local plane4 = display.newImage("plane.png")
plane4.x = plane4.contentWidth * .5
plane4.y = plane4.contentHeight * 7
originalPositions[1][2] = plane4.x
originalPositions[2][2] = plane4.y

local function transitions()
	-- Start a transition.
	-- You start it with the same parameters as a regular Corona transition, except that calling
	-- transitionManager:add instead of transition.to
	tm:add(plane1, {time = 5000, x = display.contentWidth - plane1.contentWidth * .5, onComplete = function() print("Plane 1 finished") end})
	
	tm:add(plane2, {time = 5000, rotation = 270, onComplete = function() print("Plane 2 finished") end})
	
	tm:add(plane3, {time = 5000, alpha = 0, rotation = 270, onComplete = function() print("Plane 3 finished") end})
	
	tm:add(plane4, {time = 5000, x = display.contentWidth - plane1.contentWidth * .5, onComplete = function() print("Plane 4 finished") end})
end

transitions()

local function pause()
	-- Pause all transitions
	tm:pauseAll()
	
	buttonPause.isVisible = false
	buttonResume.isVisible = true
end

local function resume()
	-- Resume transitions
	tm:resumeAll()
	
	buttonPause.isVisible = true
	buttonResume.isVisible = false	
end

local function restart()
	-- Cancel transitions
	tm:cancelAll()
	
	buttonPause.isVisible = true
	buttonResume.isVisible = false

	-- Reposition elements
	plane1.x = originalPositions[1][1]
	plane1.y = originalPositions[2][1]
	plane2.rotation = 0
	plane3.rotation = 0
	plane3.alpha = 1
	plane4.x = originalPositions[1][2]
	plane4.y = originalPositions[2][2]
	
	-- Start transitions again
	transitions()
end

buttonPause = ui.newButton{
	default = "buttonRed.png",
	over = "buttonRedOver.png",
	onRelease = pause,
	text = "Pause",
}
buttonPause.x = display.contentCenterX
buttonPause.y = display.contentHeight - buttonPause.contentHeight * 2

buttonResume = ui.newButton{
	default = "buttonRed.png",
	over = "buttonRedOver.png",
	onRelease = resume,
	text = "Resume",
}
buttonResume.isVisible = false
buttonResume.x = display.contentCenterX
buttonResume.y = display.contentHeight - buttonResume.contentHeight * 2

buttonRestart = ui.newButton{
	default = "buttonRed.png",
	over = "buttonRedOver.png",
	onRelease = restart,
	text = "Restart",
}
buttonRestart.x = display.contentCenterX
buttonRestart.y = display.contentHeight - buttonRestart.contentHeight * 0.8