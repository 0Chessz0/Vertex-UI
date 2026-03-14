local RunService = game:GetService("RunService")

local Animator = {}
Animator.__index = Animator

local activeSprings = {}

local function stepSpring(state, target, velocity, mass, damping, stiffness, dt)
	local x = state
	local v = velocity
	local k = stiffness
	local c = damping
	local m = mass
	local f = -k * (x - target) - c * v
	local a = f / m
	v = v + a * dt
	x = x + v * dt
	return x, v
end

local function ensureDriver()
	if Animator._driving then
		return
	end
	Animator._driving = true
	RunService.Heartbeat:Connect(function(dt)
		for key, spring in pairs(activeSprings) do
			local value = spring.value
			local target = spring.target
			local velocity = spring.velocity
			local mass = spring.mass
			local damping = spring.damping
			local stiffness = spring.stiffness
			if typeof(value) == "number" then
				local x, v = stepSpring(value, target, velocity, mass, damping, stiffness, dt)
				spring.value = x
				spring.velocity = v
				spring.setter(x)
				if math.abs(x - target) < 0.001 and math.abs(v) < 0.001 then
					activeSprings[key] = nil
				end
			elseif typeof(value) == "Color3" then
				local r, vr = stepSpring(value.R, target.R, velocity.R, mass, damping, stiffness, dt)
				local g, vg = stepSpring(value.G, target.G, velocity.G, mass, damping, stiffness, dt)
				local b, vb = stepSpring(value.B, target.B, velocity.B, mass, damping, stiffness, dt)
				local new = Color3.new(r, g, b)
				spring.value = new
				spring.velocity = Vector3.new(vr, vg, vb)
				spring.setter(new)
				if (new - target).magnitude < 0.001 and spring.velocity.Magnitude < 0.001 then
					activeSprings[key] = nil
				end
			elseif typeof(value) == "UDim2" then
				local sx, svx = stepSpring(value.X.Scale, target.X.Scale, velocity.X.Scale, mass, damping, stiffness, dt)
				local ox, ovx = stepSpring(value.X.Offset, target.X.Offset, velocity.X.Offset, mass, damping, stiffness, dt)
				local sy, svy = stepSpring(value.Y.Scale, target.Y.Scale, velocity.Y.Scale, mass, damping, stiffness, dt)
				local oy, ovy = stepSpring(value.Y.Offset, target.Y.Offset, velocity.Y.Offset, mass, damping, stiffness, dt)
				local new = UDim2.new(sx, ox, sy, oy)
				spring.value = new
				spring.velocity = {
					X = { Scale = svx, Offset = ovx },
					Y = { Scale = svy, Offset = ovy },
				}
				spring.setter(new)
				local delta = Vector4.new(
					target.X.Scale - sx,
					target.X.Offset - ox,
					target.Y.Scale - sy,
					target.Y.Offset - oy
				)
				local vmag = math.abs(svx) + math.abs(ovx) + math.abs(svy) + math.abs(ovy)
				if (math.abs(delta.X) + math.abs(delta.Y) + math.abs(delta.Z) + math.abs(delta.W)) < 0.001 and vmag < 0.001 then
					activeSprings[key] = nil
				end
			end
		end
	end)
end

local function springKey(instance, property)
	return tostring(instance) .. ":" .. property
end

function Animator.spring(instance, property, target, options)
	ensureDriver()
	local key = springKey(instance, property)
	local current = instance[property]
	local mass = options and options.mass or 1
	local damping = options and options.damping or 18
	local stiffness = options and options.stiffness or 180
	local velocity
	if typeof(current) == "number" then
		velocity = 0
	elseif typeof(current) == "Color3" then
		velocity = Vector3.new()
	elseif typeof(current) == "UDim2" then
		velocity = {
			X = { Scale = 0, Offset = 0 },
			Y = { Scale = 0, Offset = 0 },
		}
	end
	activeSprings[key] = {
		value = current,
		target = target,
		velocity = velocity,
		mass = mass,
		damping = damping,
		stiffness = stiffness,
		setter = function(val)
			instance[property] = val
		end,
	}
end

function Animator.stop(instance, property)
	activeSprings[springKey(instance, property)] = nil
end

return Animator

