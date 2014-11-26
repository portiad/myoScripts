scriptId = 'co.portia.examples.chrome_script'

UNLOCKED_TIMEOUT = 10000

unlocked = false
moveActive = false

SCROLL_LIMIT = 5
scroll = 0

function onForegroundWindowChange(app, title)
	myo.debug("onForegroundWindowChange: ".. app .. ", " .. title)
	appTitle = title

	if (app == "com.google.Chrome") then
		return true
	else
		return false
	end
end

function activeAppName()
	return appTitle
end

function  onActiveChange(isActive)
	if not isActive then
		unlocked = false
	end
end


-- Effects

function onWaveIn()
	myo.keyboard("left_arrow", "press", "alt", "command")
end

function onWaveOut()
	myo.keyboard("right_arrow", "press", "alt", "command")
end


-- Helpers

-- Detrmine which arm the myo is on and swap if on left
function conditionallySwapWave(pose)
	if myo.getArm() == "left" then
		if pose == "waveOut" then
			pose = "waveIn"
		elseif pose == "waveIn" then
			pose = "waveOut"
		end
	end
	return pose
end

-- Determine which direction the myo is pointed to
function conditionalRoll(roll)
    if myo.getXDirection()== "towardWrist" then
        roll =- roll;
    end

    return roll
end

-- Toggle lock
function toggleLock()

	unlocked = not unlocked
	myo.vibrate("short")
	
	if unlocked then
		myo.vibrate("short")
		extendUnlock()
	end
end

function extendUnlock()
	unlockedSince = myo.getTimeMilliseconds()
end

-- TODO: timer for how long a position is held

-- Callbacks

function onPoseEdge(pose, edge)

	if edge == "on" then
		if (pose == "thumbToPinky") then
			toggleLock()

		elseif unlocked then

			pose = conditionallySwapWave(pose)
			extendUnlock()
			
			if pose == "waveOut" then
				onWaveOut()
			elseif pose == "waveIn" then
				onWaveIn()
			end
		end
	end

	if (pose == "fist") then
		if edge == "on" and unlocked then
			referenceRoll = math.deg(myo.getRoll()) 
			moveActive = true
			-- references user's arm position
		elseif edge == "off" then
			moveActive = false
		end
	end
end


-- Called every 10ms

function onPeriodic()
	
	local now = myo.getTimeMilliseconds()

	if unlocked then
		if now - unlockedSince > UNLOCKED_TIMEOUT then
			unlocked = false
		end
	end

	if moveActive then
		-- Calculates arm position
		rollValue = math.deg(myo.getRoll())
		realTimeRollValue = conditionalRoll(rollValue - referenceRoll)
		scroll = scroll + 1

		if scroll == SCROLL_LIMIT then
			scroll = 0
			if realTimeRollValue > 0 then
				myo.keyboard("down_arrow","down")
			else
				myo.keyboard("up_arrow","down")
			end
		end
	elseif not moveActive then
		myo.keyboard("up_arrow","up")
	    myo.keyboard("down_arrow","up")
	end
end