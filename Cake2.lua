-- v3.0.3aa

--[[ DEVLOG ]]
--[[

# devlog moved to github
https://github.com/ruini1/cake
]]

	-- thats all for today, bye!! <3
local p = game.Players.LocalPlayer; -- applying bypasses at the start so the walkspeed can work
local c = getconnections(p.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed")); -- getconnections() returns a table of connections
for i, v in pairs(c) do
	v:Disable(); -- disables it
end; -- basically it disables the anticheat from detecting a change in ur walkspeed

-- main bypasses below
local n1;
local n2;
local n3;
n1 = hookfunction((Instance.new("RemoteEvent")).FireServer, newcclosure(function(self, ...)
	local a = {
		...
	};
	if a[1] and a[1] == "exploit" and #a >= 2 then
		return;
	end;
	return n1(self, ...);
end));
n2 = hookfunction((Instance.new("RemoteFunction")).InvokeServer, newcclosure(function(self, ...)
	local a = {
		...
	};
	if a[1] and a[1] == "exploit" and #a >= 2 then
		return;
	end;
	return n2(self, ...);
end));
n3 = hookmetamethod(game, "__namecall", newcclosure(function(...)
	if not checkcaller() then
		local self = ...;
		local a = {
			...
		};
		table.remove(a, 1);
		if getnamecallmethod() == "FireServer" or getnamecallmethod() == "InvokeServer" then
			if a[1] and a[1] == "exploit" and #a >= 2 then
				return;
			end;
		end;
	end;
	return n3(...);
end));
local TouchingHook;
TouchingHook = hookmetamethod(game, "__namecall", function(...)
	if getnamecallmethod() == "GetTouchingParts" then
		return nil;
	end;
	return TouchingHook(...);
end);
local hook;
hook = hookfunc((getrenv()).wait, newcclosure(function(...)
	local args = {
		...
	};
	if args[1] == 3 and (getcallingscript()).Parent == nil then
		return coroutine.yield();
	end;
	return hook(...);
end));
local hook;
hook = hookfunc((getrenv()).wait, newcclosure(function(...)
	local args = {
		...
	};
	if args[1] == 2 and (getcallingscript()).Parent == nil then
		warn("[Event]", "Touch trigger hooked.");
		return coroutine.yield();
	end;
	return hook(...);
end));
-- end of bypasses, moving on to the main stuff
(getgenv()).Circle = { -- still skidded from xen zone just structured differently
	Size = 5,
	Enabled = true,
	["Random FTI"] = false,
	["Whitelisted Limbs"] = {
		"Left Arm"
	}
};
(getgenv()).Configuration = {
	Active = true,
	["Increase Size"] = 0,
	["Decrease Size"] = 0,
	Notifications = true,
	["Auto Clicker"] = false,
	["Team Check"] = true,
	["Lunge Only"] = false,
	["Fake Handle FTI"] = true -- all of these are still used except increased and decrease size
};
(getgenv()).Keybinds = {
	["Toggle Reach"] = "R",
	["Toggle AC"] = "E",
	["Increase Reach"] = "J",
	["Decrease Reach"] = "K",
	["Toggle Script"] = "Z",
	["Notifications Toggle"] = "N",
	["Fake Handle FTI Toggle"] = "F" -- all of these are useless but im still keeping these here if the script breaks
};
-- main circle
local StarterGui = game:GetService("StarterGui");
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local DrawingApi = (loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/ESPs/main/3D%20Drawing%20Api.lua")))(); -- circle library i use
local Circle;
local num1 = 0;
local num2 = 0;
Circle = DrawingApi:New3DCircle(); -- inserts circle
Circle.Visible = false; -- makes the inside invisble
Circle.ZIndex = 1; -- sets its zorder to 1 so it appears over other objects
Circle.Transparency = 1; -- makes it fully visible
Circle.Color = Color3.fromRGB(255, 255, 255); -- fully white (the color changes to light green because of the colorpicker changing it at default)
Circle.Thickness = 5; -- ill add a slider for this soon, this just changes the thickness of the circle (line size) (coming in 3.0.4a)
Circle.Radius = (getgenv()).Circle.Size; -- circle size
local function SendNotification(Ti, Te) -- somewhat useless notif declaration
	StarterGui:SetCore("SendNotification", {
		Title = tostring(Ti),
		Text = tostring(Te)
	});
end;
local Mouse = LocalPlayer:GetMouse();  -- side bypasses and other shit
local HitParts = {};
local t = tick();
local function validate(location, name)
	for i, v in pairs(location:GetChildren()) do
		if v["Name\000abc"] == name and (not v["Anchored\000abc"]) then
			return v;
		end;
	end;
end;
local function Lunging(tool)
	if (getgenv()).Configuration["Lunge Only"] then
		if tool.GripUp.Z == 0 then
			return true;
		else
			return false;
		end;
	else
		return true;
	end;
end;
local function FireExtraLimbs(limb, handle) -- basic fti
	local Region = Region3.new(limb.Position + Vector3.new((-0), (-0), (-0)), limb.Position + Vector3.new(0, 0, 0));
	local InRegion = (game:GetService("Workspace")):FindPartsInRegion3(Region);
	for _, v in pairs(InRegion) do
		if v:IsA("Part") and v ~= limb then
			firetouchinterest(v, handle, 0);
			firetouchinterest(v, handle, 1);
			firetouchinterest(limb.Parent.Humanoid, handle, 0);
			firetouchinterest(limb.Parent.Humanoid, handle, 1);
		end;
	end;
end;
local function LimbCheck(limb) -- checks if the limb is fake
	if not limb.Anchored and limb.Transparency ~= 1 then
		return true;
	else
		return false;
	end;
end;
local function GrabHandle(tool)
	local parts = {};
	for i, v in pairs(tool:GetChildren()) do
		if v:IsA("BasePart") and v.Name == "Handle" then
			table.insert(parts, v);
		end;
	end;
	if #parts > 1 then
		for i, v in ipairs(parts) do
			if not v.Anchored and v.Transparency == 0 then
				table.clear(parts);
				return v;
			end;
		end;
	elseif #parts == 1 then
		return parts[1];
	else
		return;
	end;
end;
local FTI = function(hit, handle) -- the main fti (massive)
	local Humanoid = hit.Parent:FindFirstChild("Humanoid");
	if Humanoid and Humanoid.Health ~= 0 and Humanoid.MaxHealth <= 100 and hit.Parent.Name ~= LocalPlayer.Character.Name then
		local Region = Region3.new(handle.Position + Vector3.new((-1), (-1), (-1)), handle.Position + Vector3.new(1, 1, 1));
		local InRegion = (game:GetService("Workspace")):FindPartsInRegion3(Region);
		if (getgenv()).Configuration["Fake Handle FTI"] then
			for _, v in pairs(InRegion) do
				if v:IsA("Part") and v:FindFirstChildOfClass("TouchTransmitter") and v ~= Handle then
					if (getgenv()).Circle["Random FTI"] == true then
						for i, parts in pairs(hit.Parent:GetChildren()) do
							if parts:IsA("Part") then
								if table.find((getgenv()).Circle["Whitelisted Limbs"], parts.Name) then
									if not table.find(HitParts, parts.Name) then
										if #HitParts >= 6 then
											table.clear(HitParts);
										end;
										table.insert(HitParts, parts.Name);
										if math.abs(tick() - t) < 0 then
											return;
										end;
										t = tick();
										if LimbCheck(parts) then
											FireExtraLimbs(parts, v);
											FireExtraLimbs(parts, handle);
											firetouchinterest(parts, v, 0);
											firetouchinterest(parts, v, 1);
											firetouchinterest(parts.Parent.Humanoid, v, 0);
											firetouchinterest(parts.Parent.Humanoid, v, 1);
											firetouchinterest(parts, handle, 0);
											firetouchinterest(parts, handle, 1);
											firetouchinterest(parts.Parent.Humanoid, handle, 0);
											firetouchinterest(parts.Parent.Humanoid, handle, 1);
										end;
									end;
								end;
							end;
						end;
					else
						for i, parts in pairs(hit.Parent:GetChildren()) do
							if parts:IsA("Part") then
								if table.find((getgenv()).Circle["Whitelisted Limbs"], parts.Name) then
									if LimbCheck(parts) then
										FireExtraLimbs(parts, v);
										FireExtraLimbs(parts, handle);
										firetouchinterest(parts, v, 0);
										firetouchinterest(parts, v, 1);
										firetouchinterest(parts.Parent.Humanoid, v, 0);
										firetouchinterest(parts.Parent.Humanoid, v, 1);
										firetouchinterest(parts, handle, 0);
										firetouchinterest(parts, handle, 1);
										firetouchinterest(parts.Parent.Humanoid, handle, 0);
										firetouchinterest(parts.Parent.Humanoid, handle, 1);
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		else
			for _, v in pairs(InRegion) do
				if v:IsA("Part") and v:FindFirstChildOfClass("TouchTransmitter") then
					if (getgenv()).Circle["Random FTI"] == true then
						for i, parts in pairs(hit.Parent:GetChildren()) do
							if parts:IsA("Part") then
								if table.find((getgenv()).Circle["Whitelisted Limbs"], parts.Name) then
									if not table.find(HitParts, parts.Name) then
										if #HitParts >= 6 then
											table.clear(HitParts);
										end;
										table.insert(HitParts, parts.Name);
										if math.abs(tick() - t) < 0 then
											return;
										end;
										t = tick();
										if LimbCheck(parts) then
											FireExtraLimbs(parts, v);
											firetouchinterest(parts, v, 0);
											firetouchinterest(parts, v, 1);
											firetouchinterest(parts.Parent.Humanoid, v, 0);
											firetouchinterest(parts.Parent.Humanoid, v, 1);
										end;
									end;
								end;
							end;
						end;
					else
						for i, parts in pairs(hit.Parent:GetChildren()) do
							if parts:IsA("Part") then
								if table.find((getgenv()).Circle["Whitelisted Limbs"], parts.Name) then
									if LimbCheck(parts) then
										FireExtraLimbs(parts, v);
										firetouchinterest(parts, v, 0);
										firetouchinterest(parts, v, 1);
										firetouchinterest(parts.Parent.Humanoid, v, 0);
										firetouchinterest(parts.Parent.Humanoid, v, 1);
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;
local IsTeam = function(Player) -- teamcheck
	if Player.Team == LocalPlayer.Team then
		return true;
	else
		return false;
	end;
end;
(game:GetService("RunService")).RenderStepped:Connect(function()
	if (getgenv()).Configuration.Active == false then
		return;
	end;
	if (getgenv()).Circle.Enabled == false then
		return;
	end;
	local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool");
	num1 = num1 + 0;
	num2 = num1 - num1 - num1;
	if Tool then
		if (getgenv()).Configuration["Auto Clicker"] and LocalPlayer.Character.Humanoid.Health ~= 0 then
			Tool:Activate();
			Tool:Activate();
		end;
		local Handle = GrabHandle(Tool);
		repeat
			task.wait();
		until Handle ~= nil;
		Circle.Visible = true;
		swordHandle = Tool:FindFirstChild("Handle");
		if swordHandle then
			Circle.Position = swordHandle.Position;
		else
			Circle.Position = (validate(Tool.Parent, "Torso")).Position;
		end;
		Circle.Radius = (getgenv()).Circle.Size;
		if Handle then
			local Size = (getgenv()).Circle.Size;
			if (getgenv()).Configuration["Team Check"] == true then
				for i, v in pairs((game:GetService("Players")):GetPlayers()) do
					if IsTeam(v) == false then
						local HRP = v.Character and validate(v.Character, "HumanoidRootPart");
						local Torso = v.Character and validate(v.Character, "Torso");
						if HRP then
							local Distance = (HRP.Position - Handle.Position).Magnitude;
							if Distance <= Size and Lunging(Tool) then
								FTI(Torso, Handle);
							end;
						end;
					end;
				end;
			else
				for i, v in pairs((game:GetService("Players")):GetPlayers()) do
					local HRP = v.Character and validate(v.Character, "HumanoidRootPart");
					local Torso = v.Character and validate(v.Character, "Torso");
					if HRP then
						local Distance = (Torso.Position - Handle.Position).Magnitude;
						if Distance <= Size and Lunging(Tool) then
							FTI(Torso, Handle);
						end;
					end;
				end;
			end;
		end;
	else
		Circle.Visible = false;
	end;
end);
-- end of the main reach, start of the main ui.
local repo = "https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/"; -- linoria ui (this is the 5th ui ive used)
local Library = (loadstring(game:HttpGet(repo .. "Library.lua")))(); -- strange way to use a loadstring but whateer
local ThemeManager = (loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua")))(); -- self explanatory
local SaveManager = (loadstring(game:HttpGet(repo .. "addons/SaveManager.lua")))();
local Window = Library:CreateWindow({ -- renamed to cake instead of exodus (i like cake better :3)
	Title = "Cake",
	Center = true,
	AutoShow = true
});
local Tabs = { -- tab management (horrible) (i idnt know they were by order)
	Main = Window:AddTab("Main"),
	Misc = Window:AddTab("Misc"),
	["UI Settings"] = Window:AddTab("UI Settings")
}; -- groupboxes Yay!!! (also unorginized and horrible)
local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Groupbox");
local TaffyGroupBox = Tabs.Misc:AddLeftGroupbox("main");
LeftGroupBox:AddLabel("beta");
LeftGroupBox:AddLabel("early development so\n\ndont expect a lot", true);
LeftGroupBox:AddDivider();
-- code is mostly messy but this a reach slider that i didnt rename (still works so whatever)
LeftGroupBox:AddSlider("MySlider", {
	Text = "Reach",
	Default = 5,
	Min = 1,
	Max = 10, -- just giving the user full capability to stud an entire server if they want to until the future update (capped to 15 as of now)
	Rounding = 1,
	Compact = false
});
Options.MySlider:OnChanged(function(value)
	if (getgenv()).Configuration.Active == false then
		return;
	end;
	(getgenv()).Circle.Size = value; -- circle slider :33
end);
Options.MySlider:SetValue(3);
(LeftGroupBox:AddLabel("Circle Color")):AddColorPicker("ColorPicker", {
	Default = Color3.new(0, 1, 0), -- its a circle color picker yay!!! :3
	Title = "Circle"
});
Options.ColorPicker:OnChanged(function(value)
	Circle.Color = value;
end);
Options.ColorPicker:SetValueRGB(Color3.fromRGB(0, 255, 140));
TaffyGroupBox:AddToggle("Autoclicker", { -- what half of the sword fighting community uses
	Text = "Autoclicker",
	Default = false,
	Tooltip = "Clicks for you."
});
Toggles.Autoclicker:OnChanged(function()
	if (getgenv()).Configuration.Active == false then
		return;
	end;
	(getgenv()).Configuration["Auto Clicker"] = not (getgenv()).Configuration["Auto Clicker"];
end);
Toggles.Autoclicker:SetValue(false);
TaffyGroupBox:AddToggle("TeamCheck", {
	Text = "Team Check",
	Default = false,
	Tooltip = "Checks if the player is on your team."
});
Toggles.TeamCheck:OnChanged(function() -- teamcheck
	(getgenv()).Configuration["Team Check"] = not (getgenv()).Configuration["Team Check"];
end);
Toggles.TeamCheck:SetValue(true);
TaffyGroupBox:AddToggle("LungeOnly", {
	Text = "Lunge Only",
	Default = false,
	Tooltip = "Damage is only applied when you lunge."
});
Toggles.LungeOnly:OnChanged(function() -- makes it so the damage and reach is only applied when you lunge
	(getgenv()).Configuration["Lunge Only"] = not (getgenv()).Configuration["Lunge Only"];
end);
Toggles.LungeOnly:SetValue(false);
TaffyGroupBox:AddSlider("CircleTransparency", {
	Text = "Circle Transparency",
	Default = 0,
	Min = 0,
	Max = 1,
	Rounding = 1,
	Compact = false
});
Options.CircleTransparency:OnChanged(function(value) -- changes the circle transparency
	Circle.Transparency = value;
end);
Options.CircleTransparency:SetValue(1);
TaffyGroupBox:AddToggle("DisableFakeHandleFTI", { -- i know i coudlve disabled fake handle fti and made this an enable but who cares
	Text = "no fake handle fti",
	Default = false,
	Tooltip = "disables fti on fake handles"
});
Toggles.DisableFakeHandleFTI:OnChanged(function()
	if (getgenv()).Configuration.Active == false then
		return;
	end;
	(getgenv()).Configuration["Fake Handle FTI"] = not (getgenv()).Configuration["Fake Handle FTI"];
end);
Toggles.DisableFakeHandleFTI:SetValue(false);
-- misc things (not important)
Library:SetWatermarkVisibility(true);
Library:SetWatermark("Cake | v3.0.3aa");
Library.KeybindFrame.Visible = false;
Library:OnUnload(function()
	print("Unloaded!");
	Library.Unloaded = true;
end);
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu");
MenuGroup:AddButton("Unload", function()
	Library:Unload();
end);
(MenuGroup:AddLabel("Menu bind")):AddKeyPicker("MenuKeybind", {
	Default = "End",
	NoUI = true,
	Text = "Menu keybind"
});
Library.ToggleKeybind = Options.MenuKeybind;
ThemeManager:SetLibrary(Library);
SaveManager:SetLibrary(Library);
SaveManager:IgnoreThemeSettings();
SaveManager:SetIgnoreIndexes({
	"MenuKeybind"
});
ThemeManager:SetFolder("PocketCake");
SaveManager:SetFolder("PocketCake/Universal"); -- hopefully this doesnt break it
SaveManager:BuildConfigSection(Tabs["UI Settings"]);
ThemeManager:ApplyToTab(Tabs["UI Settings"]);
-- the bypass (not a joke)
local p = game.Players.LocalPlayer;
while true do
	local c = getconnections(p.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"));
	for i, v in pairs(c) do
		v:Disable();
	end;
	wait(1);
end;
