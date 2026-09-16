-- X-tail manual RC mixer for ArduPlane
--
-- SERVO2_FUNCTION = 94  -- upper rudder
-- SERVO3_FUNCTION = 95  -- lower rudder
-- SERVO4_FUNCTION = 96  -- left elevator
-- SERVO5_FUNCTION = 97  -- right elevator
--
-- Runs only in Plane MANUAL mode (mode 0).

local UPPER_RUDDER = 94
local LOWER_RUDDER = 95
local LEFT_ELEVATOR = 96
local RIGHT_ELEVATOR = 97

local FULL_SCALE = 4500
local MANUAL_MODE = 0
local UPDATE_MS = 20

local roll_channel = assert(rc:get_channel(assert(param:get("RCMAP_ROLL"))))
local pitch_channel = assert(rc:get_channel(assert(param:get("RCMAP_PITCH"))))
local yaw_channel = assert(rc:get_channel(assert(param:get("RCMAP_YAW"))))

local function constrain(value)
    if value > FULL_SCALE then
        return FULL_SCALE
    end
    if value < -FULL_SCALE then
        return -FULL_SCALE
    end
    return value
end

local function write_mix(roll, pitch, yaw)
    SRV_Channels:set_output_scaled(UPPER_RUDDER, constrain(roll + yaw))
    SRV_Channels:set_output_scaled(LOWER_RUDDER, constrain(-roll + yaw))
    SRV_Channels:set_output_scaled(LEFT_ELEVATOR, constrain(-roll + pitch))
    SRV_Channels:set_output_scaled(RIGHT_ELEVATOR, constrain(roll + pitch))
end

local function update()
    if vehicle:get_mode() == MANUAL_MODE and rc:has_valid_input() then
        local roll = roll_channel:norm_input_dz() * FULL_SCALE
        local pitch = pitch_channel:norm_input_dz() * FULL_SCALE
        local yaw = yaw_channel:norm_input_dz() * FULL_SCALE

        write_mix(roll, pitch, yaw)
    else
        write_mix(0, 0, 0)
    end

    return update, UPDATE_MS
end

SRV_Channels:set_angle(UPPER_RUDDER, FULL_SCALE)
SRV_Channels:set_angle(LOWER_RUDDER, FULL_SCALE)
SRV_Channels:set_angle(LEFT_ELEVATOR, FULL_SCALE)
SRV_Channels:set_angle(RIGHT_ELEVATOR, FULL_SCALE)

gcs:send_text(6, "X-tail manual mixer loaded")
return update, UPDATE_MS
