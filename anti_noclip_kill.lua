--Anti noclip-killing
--Made by SHOOP DA WHOOP
if CLIENT then 
function nkhelp()
	print("~~~~Variables~~~~")
	print("noclipkills_before_kick = ")
	print("	When a player gets this many noclip kills, they will be kicked.")
	print("")
	print("noclipkills_before_ban = ")
	print("	When a player gets this many noclip kills, they will be banned.  The ban time is in noclipkills_ban_length.")
	print("")
	print("noclipkills_ban_length = ")
	print("	When a player gets banned for noclip killing, they will be banned for this long (in seconds).")
	print("")
	print("noclipkills_kick_admins = ")
	print("	Will admins be kicked for noclip killing?")
	print("")
	print("noclipkills_delay = ")
	print("	Getting a kill within this many seconds after un-noclipping will count as half a noclip kill.")
	print("")
	print("~~~~Commands~~~~")
	print("checknk <name>")
	print("	This will check the amount of noclip kills the player has on record")
	print("")
	print("resetnk <name>")
	print("	This will reset the player's noclip kill count")
end
concommand.Add("nkhelp",nkhelp)
return end

if !ConVarExists("noclipkills_before_kick") then
	CreateConVar("noclipkills_before_kick",5,FCVAR_SERVER_CAN_EXECUTE,"When a player gets this many noclip kills, they will be kicked.")
end
if !ConVarExists("noclipkills_before_ban") then
	CreateConVar("noclipkills_before_ban",10,FCVAR_SERVER_CAN_EXECUTE,"When a player gets this many noclip kills, they will be banned.  The ban time is in noclipkills_ban_length.")
end
if !ConVarExists("noclipkills_ban_length") then
	CreateConVar("noclipkills_ban_length",600,FCVAR_SERVER_CAN_EXECUTE,"When a player gets banned for noclip killing, they will be banned for this long (in seconds).")
end
if !ConVarExists("noclipkills_kick_admins") then
	CreateConVar("noclipkills_kick_admins",0,FCVAR_SERVER_CAN_EXECUTE,"Will admins be kicked for noclip killing?")
end
if !ConVarExists("noclipkills_delay") then
	CreateConVar("noclipkills_delay",3,FCVAR_SERVER_CAN_EXECUTE,"Getting a kill within this many seconds after un-noclipping will count as half a noclip kill.")
end 

function checknk(ply, command, args)
	if ! ply:IsAdmin() then return end
	local target = string.lower(tostring(args[1]))
	local found = false
	for _, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), target) then
			found = true
			ply:ChatPrint(v:Nick() .. " has " .. v:GetPData("noclipkills",0) .. " noclip kills")
		end 
	end
	if !found then 
		ply:ChatPrint("Player not found.")
	return end

end
concommand.Add("checknk",checknk)
	
function resetnk(ply, command, args)
	if !ply:IsSuperAdmin() then return end
	local targetname = string.lower(tostring(args[1]))
	local target = targetname
	local found = 0
	for _, v in pairs(player.GetAll()) do
		if string.find(string.lower(v:Nick()), targetname) then
			target = v
			found = found + 1
		end 
	end
	if target == args[1] then 
		ply:ChatPrint("Player not found.")
	return end
	if found > 1 then
		ply:ChatPrint(found .. " players found.  Be more specific.")
	return end
	target:SetPData("noclipkills",0)
	ply:ChatPrint(target:Nick() .. "\'s noclipkills have been reset to 0.")
end
concommand.Add("resetnk",resetnk)

function obvious(victim, weapon, killer)
	if killer:GetMoveType() == MOVETYPE_NOCLIP && !(killer == victim) && !killer:InVehicle() then
		local noclipkills = killer:GetPData("noclipkills",0) + 1
		killer:SetPData("noclipkills",noclipkills)
		killer:ChatPrint("You now have " .. killer:GetPData("noclipkills",0) .. " noclip kills.")
		if noclipkills >= GetConVar("noclipkills_before_ban"):GetInt() then
			if !(GetConVar("noclipkills_kick_admins"):GetBool()) && killer:IsAdmin() then
				killer:ChatPrint("If you weren\'t an admin, you\'d have just been banned.")
			else
				killer:Ban(GetConVar("noclipkills_ban_length"):GetInt(),"Too many noclip kills.")
			end
		end
		if noclipkills >= GetConVar("noclipkills_before_kick"):GetInt() then
			if !(GetConVar("noclipkills_kick_admins"):GetBool()) && killer:IsAdmin() then
				killer:ChatPrint("If you weren\'t an admin, you\'d have just been kicked.")
			else
				killer:Kick("Too many noclip kills")
			end
		end
		for _,v in pairs(player.GetAll()) do
		local id = killer:UniqueID()
		id = tostring(id)
		local command = "chat.AddText(team.GetColor(player.GetByUniqueID(\'" .. id .. "\'):Team()), player.GetByUniqueID(\'" .. id .. "\'):Nick()" ..  ",Color(255,255,255),\' has noclip killed someone and will be slain.\')"
			v:SendLua(command)
		end
		RunConsoleCommand("ulx","slay",killer:Nick())	
	end
end
hook.Add("PlayerDeath","checkobvious",obvious)

--I couldn't get a timer to work with this funciton, so I'll just move it to the timer
-- function checkAfter(killer, frags)   
	-- if killer:Frags() > frags then
		-- local noclipkills = killer:GetPData("noclipkills",0) + 0.5
		-- killer:SetPData("noclipkills",noclipkills)
		-- killer:ChatPrint("You now have " .. killer:GetPData("noclipkills",0) .. " noclip kills.")
		-- if noclipkills >= GetConVar("noclipkills_before_ban"):GetInt() then
			-- if !(GetConVar("noclipkills_kick_admins"):GetBool()) && killer:IsAdmin() then
				-- killer:ChatPrint("If you weren\'t an admin, you\'d have just been banned.")
			-- else
				-- killer:Ban(GetConVar("noclipkills_ban_length"):GetInt(),"Too many noclip kills.")
			-- end
		-- end
		-- if noclipkills >= GetConVar("noclipkills_before_kick"):GetInt() then
			-- if !(GetConVar("noclipkills_kick_admins"):GetBool()) && killer:IsAdmin() then
				-- killer:ChatPrint("If you weren\'t an admin, you\'d have just been kicked.")
			-- else
				-- killer:Kick("Too many noclip kills")
			-- end
		-- end
		-- for _,v in pairs(player.GetAll()) do
		-- local id = killer:UniqueID()
		-- id = tostring(id)
		-- local command = "chat.AddText(team.GetColor(player.GetByUniqueID(\'" .. id .. "\'):Team()), player.GetByUniqueID(\'" .. id .. "\'):Nick()" ..  ",Color(255,255,255),\' might\'ve noclip killed someone and will be slapped for 99 damage.\')"
			-- v:SendLua(command)
		-- end
		-- RunConsoleCommand("ulx","slap",killer:Nick(),99)
	-- end
-- end
function checkBefore(killer)
	if killer:GetMoveType() != MOVETYPE_NOCLIP && !killer:InVehicle() then
		local delay = GetConVar("noclipkills_delay"):GetFloat()
		local frags = killer:Frags()
		timer.Create(tostring(CurTime()),delay,1,function()
		if killer:Frags() > frags then
		local noclipkills = killer:GetPData("noclipkills",0) + 0.5
		killer:SetPData("noclipkills",noclipkills)
		killer:ChatPrint("You now have " .. killer:GetPData("noclipkills",0) .. " noclip kills.")
		if noclipkills >= GetConVar("noclipkills_before_ban"):GetInt() then
			if !(GetConVar("noclipkills_kick_admins"):GetBool()) && killer:IsAdmin() then
				killer:ChatPrint("If you weren\'t an admin, you\'d have just been banned.")
			else
				killer:Ban(GetConVar("noclipkills_ban_length"):GetInt(),"Too many noclip kills.")
			end
		end
		if noclipkills >= GetConVar("noclipkills_before_kick"):GetInt() then
			if !(GetConVar("noclipkills_kick_admins"):GetBool()) && killer:IsAdmin() then
				killer:ChatPrint("If you weren\'t an admin, you\'d have just been kicked.")
			else
				killer:Kick("Too many noclip kills")
			end
		end
		for _,v in pairs(player.GetAll()) do
		local id = killer:UniqueID()
		id = tostring(id)
		local command = "chat.AddText(team.GetColor(player.GetByUniqueID(\'" .. id .. "\'):Team()), player.GetByUniqueID(\'" .. id .. "\'):Nick()" ..  ",Color(255,255,255),\' might\\'ve noclip killed someone and will be slapped for 99 damage.\')"
			v:SendLua(command)
		end
		RunConsoleCommand("ulx","slap",killer:Nick(),99)
	end
end
		)
	end 
end
hook.Add("PlayerNoClip" , "CheckNoclipKills" , checkBefore)