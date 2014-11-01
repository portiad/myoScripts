scriptId = 'iTunesPlayer'

-- tweek volume speed
VOLUME_COUNTER_LIMIT = 5

-- volume counter
volumeCounter = 0


function lock()
    enabled = false
    myo.vibrate("short")
end
function unlock()
    enabled = true
    myo.vibrate("short")
    myo.vibrate("short")
end

-- configuration for cases when Myo is put on backwards
function conditionalRoll(roll)
    if myo.getXDirection()== "towardElbow" then
        roll=-roll;
    end
    return roll
end

function onPoseEdge(pose, edge)

	-- fist activates volume control
	if pose == "fist" then
    	if edge == "on" then
			referenceRoll = math.deg(myo.getRoll()) -- references user's arm position
			moveActive = "on"
		end
		if edge == "off" then
			moveActive = "off"
		end
	end

	 if edge == "on" then
        if pose == "thumbToPinky" then
            if enabled then
                lock()
            else
                unlock()
            end
        end

        -- swipe right for next song, left for previous song, fingers spacef for play/pause
        if enabled then       
		    if pose == "waveOut" then
		    	myo.keyboard("right_arrow","press")
		    end
		    if pose == "waveIn" then
		    	myo.keyboard("left_arrow","press")
		    end
			if pose == "fingersSpread" then
		    	myo.keyboard("space","press")
		    end
        end
    end
end

-- this function gets called every 10ms
function onPeriodic()
	rollValue = math.deg(myo.getRoll()) -- calculates arm position every 10ms
	realTimeRollValue = rollValue - referenceRoll


	if moveActive == "on" then
		volumeCounter = volumeCounter + 1
		if volumeCounter == VOLUME_COUNTER_LIMIT then
			volumeCounter = 0
			if realTimeRollValue > 0 then
				myo.keyboard("up_arrow","down","control")
			else
				myo.keyboard("down_arrow","down","control")
			end
		end
	else
		myo.keyboard("up_arrow","up","control")
	    myo.keyboard("down_arrow","up","control")
	end
end

function onForegroundWindowChange(app, title)
	 if string.match(title, "iTunes") then    
	    return true
    end
end