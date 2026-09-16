-- X-tail ArduPilot-demand mixer for ArduPlane
--
-- SERVO2_FUNCTION = 94  -- upper rudder
-- SERVO3_FUNCTION = 95  -- lower rudder
-- SERVO4_FUNCTION = 96  -- left elevator
-- SERVO5_FUNCTION = 97  -- right elevator
--
-- Do not assign physical outputs to functions 4, 19, or 21.
-- The script reads their internal ArduPlane demands:
--   4  = Aileron / roll
--   19 = Elevator / pitch
--   21 = Rudder / yaw

local AILERON = 4
local ELEVATOR = 19
local RUDDER = 21

local UPPER_RUDDER = 94
local LOWER_RUDDER = 95
local LEFT_ELEVATOR = 96
local RIGHT_ELEVATOR = 97

local FULL_SCALE = 4500
local UPDATE_MS = 20

local function constrain(value)
    if value > FULL_SCALE then
        return FULL_SCALE
    end
    if value < -FULL_SCALE then
        return -FULL_SCALE
    end
    return value
end

local function update()
    local roll = SRV_Channels:get_output_scaled(AILERON)
    local pitch = SRV_Channels:get_output_scaled(ELEVATOR)
    local yaw = SRV_Channels:get_output_scaled(RUDDER)

    SRV_Channels:set_output_scaled(UPPER_RUDDER, constrain(roll + yaw))
    SRV_Channels:set_output_scaled(LOWER_RUDDER, constrain(-roll + yaw))
    SRV_Channels:set_output_scaled(LEFT_ELEVATOR, constrain(-roll + pitch))
    SRV_Channels:set_output_scaled(RIGHT_ELEVATOR, constrain(roll + pitch))

    return update, UPDATE_MS
end

SRV_Channels:set_angle(UPPER_RUDDER, FULL_SCALE)
SRV_Channels:set_angle(LOWER_RUDDER, FULL_SCALE)
SRV_Channels:set_angle(LEFT_ELEVATOR, FULL_SCALE)
SRV_Channels:set_angle(RIGHT_ELEVATOR, FULL_SCALE)

gcs:send_text(6, "X-tail demand mixer loaded")
return update, UPDATE_MS
