-- Spring physics animator. Supports number, Color3, UDim2.
local RunService = game:GetService("RunService")
local Animator   = {}
local springs    = {}

local function step(x, target, v, k, c, dt)
	local f = -k * (x - target) - c * v
	v = v + (f / 1) * dt
	x = x + v * dt
	return x, v
end

local function settled(x, t, v)
	return math.abs(x - t) < 0.001 and math.abs(v) < 0.001
end

local running = false
local function ensureLoop()
	if running then return end
	running = true
	RunService.Heartbeat:Connect(function(dt)
		for key, s in pairs(springs) do
			local vt, tt = s.value, s.target
			if typeof(vt) == "number" then
				local nx, nv = step(vt, tt, s.vel, s.k, s.c, dt)
				s.value, s.vel = nx, nv
				s.set(nx)
				if settled(nx, tt, nv) then springs[key] = nil end

			elseif typeof(vt) == "Color3" then
				local vv = s.vel
				local nr, vr = step(vt.R, tt.R, vv.X, s.k, s.c, dt)
				local ng, vg = step(vt.G, tt.G, vv.Y, s.k, s.c, dt)
				local nb, vb = step(vt.B, tt.B, vv.Z, s.k, s.c, dt)
				local nc = Color3.new(nr, ng, nb)
				s.value = nc
				s.vel   = Vector3.new(vr, vg, vb)
				s.set(nc)
				if settled(nr,tt.R,vr) and settled(ng,tt.G,vg) and settled(nb,tt.B,vb) then
					springs[key] = nil
				end

			elseif typeof(vt) == "UDim2" then
				local vv = s.vel
				local nxs,vxs = step(vt.X.Scale,  tt.X.Scale,  vv[1], s.k, s.c, dt)
				local nxo,vxo = step(vt.X.Offset, tt.X.Offset, vv[2], s.k, s.c, dt)
				local nys,vys = step(vt.Y.Scale,  tt.Y.Scale,  vv[3], s.k, s.c, dt)
				local nyo,vyo = step(vt.Y.Offset, tt.Y.Offset, vv[4], s.k, s.c, dt)
				local nu = UDim2.new(nxs, nxo, nys, nyo)
				s.value = nu
				s.vel   = {vxs, vxo, vys, vyo}
				s.set(nu)
				if settled(nxs,tt.X.Scale,vxs) and settled(nxo,tt.X.Offset,vxo)
				and settled(nys,tt.Y.Scale,vys) and settled(nyo,tt.Y.Offset,vyo) then
					springs[key] = nil
				end
			end
		end
	end)
end

function Animator.spring(instance, prop, target, opts)
	ensureLoop()
	local k   = (opts and opts.stiffness) or 200
	local c   = (opts and opts.damping)   or 20
	local cur = instance[prop]
	local vel
	if     typeof(cur) == "number" then vel = 0
	elseif typeof(cur) == "Color3" then vel = Vector3.new()
	elseif typeof(cur) == "UDim2"  then vel = {0,0,0,0}
	else return end

	-- preserve existing velocity if same spring is already running
	local key = tostring(instance) .. prop
	if springs[key] then vel = springs[key].vel end

	springs[key] = {
		value = cur, target = target,
		vel = vel, k = k, c = c,
		set = function(v) instance[prop] = v end,
	}
end

function Animator.stop(instance, prop)
	springs[tostring(instance) .. prop] = nil
end

return Animator
