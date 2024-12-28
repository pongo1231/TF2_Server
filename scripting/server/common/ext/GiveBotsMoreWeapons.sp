// Full credit to Pick on the bots-united.com Discord server

#include <tf2_stocks>
#include <tf2attributes>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.14"
#define DROP_NAME "plugin_potential_drop_wep"

ConVar g_hCVTimer;
ConVar g_hCVEnabled;
ConVar g_hCVMVMREDEnabled;
ConVar g_hCVTeam;
Handle g_hEquipWearable;
bool g_bMVM;
bool g_bMedieval;
bool g_bLateLoad;
float g_fWeaponDropTime = 0.0;

public Plugin myinfo = 
{
	name = "Give Bots More Weapons",
	author = "PC Gamer, with code by luki1412, manicogaming, That Annoying Guide, and Shadowysn",
	description = "Gives TF2 bots more non-stock weapons",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	if (GetEngineVersion() != Engine_TF2) 
	{
		Format(error, err_max, "This plugin only works for Team Fortress 2.");
		return APLRes_Failure;
	}

	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	ConVar hCVversioncvar = CreateConVar("sm_gbmw_version", PLUGIN_VERSION, "Give Bots Weapons version cvar", FCVAR_NOTIFY|FCVAR_DONTRECORD); 
	g_hCVEnabled = CreateConVar("sm_gbmw_enabled", "1", "Enables/disables this plugin", FCVAR_NONE, true, 0.0, true, 1.0);
	g_hCVMVMREDEnabled = CreateConVar("sm_gbmw_MVM_red_enabled", "1", "Enables/disables Giving RED team weapons in MvM", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCVTimer = CreateConVar("sm_gbmw_delay", "1.0", "Delay for giving weapons to bots", FCVAR_NONE, true, 0.1, true, 30.0);
	g_hCVTeam = CreateConVar("sm_gbmw_team", "1", "Team to give weapons to: 1-both, 2-red, 3-blu", FCVAR_NONE, true, 1.0, true, 3.0);
	
	
	HookEvent("post_inventory_application", player_inv);
	HookConVarChange(g_hCVEnabled, OnEnabledChanged);
	HookEvent("player_spawn", OnPlayerSpawn);
	
	SetConVarString(hCVversioncvar, PLUGIN_VERSION);

	if (g_bLateLoad)
	{
		OnMapStart();
	}
	
	GameData hTF2 = new GameData("sm-tf2.games"); // sourcemod's tf2 gamdata

	if (!hTF2)
	SetFailState("This plugin is designed for a TF2 dedicated server only.");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(hTF2.GetOffset("RemoveWearable") - 1);    // EquipWearable offset is always behind RemoveWearable, subtract its value by 1
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hEquipWearable = EndPrepSDKCall();

	if (!g_hEquipWearable)
	SetFailState("Failed to create call: CBasePlayer::EquipWearable");

	delete hTF2; 
}

public void OnEnabledChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (GetConVarBool(g_hCVEnabled))
	{
		HookEvent("post_inventory_application", player_inv);
		HookEvent("player_hurt", player_hurt);
	}
	else
	{
		UnhookEvent("post_inventory_application", player_inv);
		UnhookEvent("player_hurt", player_hurt);
	}
}

public void OnMapStart()
{
	if (GameRules_GetProp("m_bPlayingMannVsMachine"))
	{
		g_bMVM = true;
	}
	
	if (GameRules_GetProp("m_bPlayingMedieval"))
	{
		g_bMedieval = true;
	}	
}

public void OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (IsPlayerHere(client))
	{
		SetFakeClientConVar(client, "cl_autoreload", "1");
		SetFakeClientConVar(client, "hud_medicautocallers", "1");
	}
}

public void player_hurt(Handle event, const char[] name, bool dontBroadcast) 
{
	if (!GetConVarBool(g_hCVEnabled))
	{
		return;
	}

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsPlayerHere(victim))
	{
		int actwep = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
		int wep = GetPlayerWeaponSlot(victim, 0);
		int wepIndex;

		if (IsValidEntity(wep))
		{
			wepIndex = GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex");
		}

		switch (wepIndex) 
		{
			case 594: // Make Pyros use Phlog Charge
			{
				if (GetEntPropFloat(victim, Prop_Send, "m_flRageMeter") > 99.9 && wep == actwep) 
				{
					FakeClientCommand(victim, "taunt");
				}
			}
		}
	}
	
	return;
}

public Action OnPlayerRunCmd(int victim, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
	if (g_bMVM && TF2_GetClientTeam(victim) != TFTeam_Red)
		return Plugin_Continue;

	if (IsPlayerHere(victim) && IsPlayerAlive(victim))
	{	
		if (buttons&IN_ATTACK)
		{
			int actwep = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
			int wep = GetPlayerWeaponSlot(victim, 0);
			int wepIndex;

			if (IsValidEntity(wep))
			{
				wepIndex = GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex");
			}

			int wep2 = GetPlayerWeaponSlot(victim, 1);
			int wepIndex2;

			if (IsValidEntity(wep2))
			{
				wepIndex2 = GetEntProp(wep2, Prop_Send, "m_iItemDefinitionIndex");
			}
			
			int wep3 = GetPlayerWeaponSlot(victim, 2);
			int wepIndex3;

			if (IsValidEntity(wep3))
			{
				wepIndex3 = GetEntProp(wep3, Prop_Send, "m_iItemDefinitionIndex");
			}
			
			TFClassType class = TF2_GetPlayerClass(victim);

			switch (wepIndex) 
			{
				case 448: //Make scouts use soda popper charge bar
				{
					if (GetEntPropFloat(victim, Prop_Send, "m_flHypeMeter") > 99.9 && wep == actwep) 
					{
						buttons ^= IN_ATTACK;
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 441: //Make soldiers use charge shot on cow managler
				{
					if (GetEntPropFloat(wep, Prop_Send, "m_flEnergy") > 19.9 && wep == actwep && GetRandomUInt(1,2) == 1) 
					{
						buttons ^= IN_ATTACK;
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 730: //Make soldiers not kill themselves using the beggers bazzoka
				{
					if (wep == actwep && GetEntProp(wep, Prop_Data, "m_iClip1") > 2) 
					{
						buttons ^= IN_ATTACK;
						return Plugin_Changed;
					}					
				}
			}

			switch (wepIndex2) 
			{
				case 751: //Make snipers use the cleaners carbine charge bar
				{
					if (wep2 == actwep && GetRandomUInt(1,2) == 1) 
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 30668: //Wrangler secondary fire
				{
					if (wep2 == actwep)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 140: //Wrangler secondary fire
				{
					if (wep2 == actwep)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 1086: //Wrangler secondary fire
				{
					if (wep2 == actwep)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
			}
			
			switch (wepIndex3) 
			{
				case 648: //Make scout use ball secondary
				{
					if (wep3 == actwep) 
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 44: //Make scout use ball secondary
				{
					if (wep3 == actwep) 
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 589: //Make engineer use teleport to home
				{
					if (GetClientHealth(victim) < 100 && wep3 == actwep) 
					{
						FakeClientCommand(victim, "eureka_teleport 0");
					}
				}
			}
			
			switch (class) 
			{
				case TFClass_DemoMan: //demoman charge behavior
				{
					if (wep2 != -1) //if weapon is not a shield stop here
					{
						return Plugin_Continue;
					}
					else if (GetRandomUInt(1,2) == 1) // otherwise make demo left click when he attacked with grenade launcher
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case TFClass_Scout: //Scout jumps in combat
				{
					if (GetRandomUInt(1,25) == 1) 
					{
						buttons |= IN_JUMP;
						return Plugin_Changed;
					}
				}
			}
		}
		else
		{
			int actwep = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");

			int wep2 = GetPlayerWeaponSlot(victim, 1);
			int wepIndex2;

			if (IsValidEntity(wep2))
			{
				wepIndex2 = GetEntProp(wep2, Prop_Send, "m_iItemDefinitionIndex");
			}
			
			int wep3 = GetPlayerWeaponSlot(victim, 2);
			int wepIndex3;

			if (IsValidEntity(wep3))
			{
				wepIndex3 = GetEntProp(wep3, Prop_Send, "m_iItemDefinitionIndex");
			}
			
			TFClassType class = TF2_GetPlayerClass(victim);
			
			switch (wepIndex2) 
			{
				case 42: //sandvich code (mostly repeated)
				{
					if (GetClientHealth(victim) < 200)
					{
						EquipWeaponSlot(victim, 1);
					
						if (wep2 == actwep && GetClientHealth(victim) < 200)
						{
							buttons |= IN_ATTACK;
							return Plugin_Changed;
						}
					}
					else if (wep2 == actwep && GetRandomUInt(1,2) == 1)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 863:
				{
					if (GetClientHealth(victim) < 200) 
					{
						EquipWeaponSlot(victim, 1);
					
						if (wep2 == actwep && GetClientHealth(victim) < 200)
						{
							buttons |= IN_ATTACK;
							return Plugin_Changed;
						}
					}
					else if (wep2 == actwep && GetRandomUInt(1,2) == 1)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 1002:
				{
					if (GetClientHealth(victim) < 200) 
					{
						EquipWeaponSlot(victim, 1);
					
						if (wep2 == actwep && GetClientHealth(victim) < 200)
						{
							buttons |= IN_ATTACK;
							return Plugin_Changed;
						}
					}
					else if (wep2 == actwep && GetRandomUInt(1,2) == 1)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 159:
				{
					if (GetClientHealth(victim) < 250) 
					{
						EquipWeaponSlot(victim, 1);
					
						if (wep2 == actwep && GetClientHealth(victim) < 250)
						{
							buttons |= IN_ATTACK;
							return Plugin_Changed;
						}
					}
					else if (wep2 == actwep && GetRandomUInt(1,2) == 1)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 433:
				{
					if (GetClientHealth(victim) < 250) 
					{
						EquipWeaponSlot(victim, 1);
					
						if (wep2 == actwep && GetClientHealth(victim) < 250)
						{
							buttons |= IN_ATTACK;
							return Plugin_Changed;
						}
					}
					else if (wep2 == actwep && GetRandomUInt(1,2) == 1)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 1190:
				{
					if (GetClientHealth(victim) < 250) 
					{
						EquipWeaponSlot(victim, 1);
					
						if (wep2 == actwep && GetClientHealth(victim) < 250)
						{
							buttons |= IN_ATTACK;
							return Plugin_Changed;
						}
					}
					else if (wep2 == actwep && GetRandomUInt(1,2) == 1)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case 30668: //wrangler put away as to not keep sentry wrangled when away
				{
					if (wep2 == actwep && GetRandomUInt(1,2) == 1) 
					{
						EquipWeaponSlot(victim, 2);
						return Plugin_Changed;
					}
				}
				case 140:
				{
					if (wep2 == actwep && GetRandomUInt(1,2) == 1) 
					{
						EquipWeaponSlot(victim, 2);
						return Plugin_Changed;
					}
				}
				case 1086:
				{
					if (wep2 == actwep && GetRandomUInt(1,2) == 1) 
					{
						EquipWeaponSlot(victim, 2);
						return Plugin_Changed;
					}
				}
				case 311: //eat steak when we equip it when we run out of ammo
				{
					if (wep2 == actwep && GetRandomUInt(1,2) == 1) 
					{
						buttons |= IN_ATTACK;
						return Plugin_Changed;
					}
				}
			}
			
			switch (wepIndex3) 
			{
				case 304: //medic use amputator taunt 
				{
					if (GetClientHealth(victim) < 100 && wep3 != actwep)
					{
						EquipWeaponSlot(victim, 2);
						FakeClientCommand(victim, "taunt");
						return Plugin_Changed;
					}
				}
			}
			
			switch (class)
			{
				case TFClass_DemoMan: //shield code again 
				{
					if (wep2 != -1) 
					{
						return Plugin_Continue;
					}
					else if (GetRandomUInt(1,2) == 1 && wep3 == actwep)
					{
						buttons |= IN_ATTACK2;
						return Plugin_Changed;
					}
				}
				case TFClass_Medic:
				{
					if (GetRandomUInt(1,2) == 1 && wep2 == actwep) 
					{
						buttons |= IN_ATTACK;
						return Plugin_Changed;
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_hCVEnabled || g_bMVM || classname[0] != 't' || strcmp(classname, "tf_dropped_weapon", false) != 0)
		return;
	
	g_fWeaponDropTime = GetGameTime();
	SetEntPropString(entity, Prop_Data, "m_iName", DROP_NAME);
	RequestFrame(ReqFrame_Test, entity);
}

void ReqFrame_Test(int entity)
{
	if (!RealValidEntity(entity)) return;
	SetEntPropString(entity, Prop_Data, "m_iName", "");
}

public void player_inv(Handle event, const char[] name, bool dontBroadcast) 
{
	if (!GetConVarBool(g_hCVEnabled))
	{
		return;
	}

	int userd = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userd);

	if (!g_bMVM && IsPlayerHere(client))
	{
		int team = GetClientTeam(client);
		int team2 = GetConVarInt(g_hCVTeam);
		float timer = GetConVarFloat(g_hCVTimer);
		
		switch (team2)
		{
		case 2:
			{
				if (team != 2)
				{
					return;
				}
			}
		case 3:
			{
				if (team != 3)
				{
					return;
				}
			}
		}

		if (g_fWeaponDropTime == GetGameTime())
		{
			int ent;
			while ((ent = FindEntityByClassname(ent, "tf_dropped_weapon")) != -1)
			{
				if (!IsValidEntity(ent)) continue;
				
				static char targetname[26];
				GetEntPropString(ent, Prop_Data, "m_iName", targetname, sizeof(targetname));
				if (strcmp(targetname, DROP_NAME, false) != 0) continue;
				
				AcceptEntityInput(ent, "Kill");
			}
		}

		CreateTimer(timer, Timer_GiveWeapons, userd);
	}

	if (g_bMVM && GetConVarBool(g_hCVMVMREDEnabled) && IsPlayerHere(client))
	{
		int team = GetClientTeam(client);
		float timer = GetConVarFloat(g_hCVTimer);
		
		if (team != 2)
		{
			return;
		}
		
		if (g_fWeaponDropTime == GetGameTime())
		{
			int ent;
			while ((ent = FindEntityByClassname(ent, "tf_dropped_weapon")) != -1)
			{
				if (!IsValidEntity(ent)) continue;
				
				static char targetname[26];
				GetEntPropString(ent, Prop_Data, "m_iName", targetname, sizeof(targetname));
				if (strcmp(targetname, DROP_NAME, false) != 0) continue;
				
				AcceptEntityInput(ent, "Kill");
			}
		}
		
		CreateTimer(timer, Timer_GiveWeapons, userd);
	}
		
}

public Action Timer_GiveWeapons(Handle timer, any data)
{
	int client = GetClientOfUserId(data);
	
	if (!GetConVarBool(g_hCVEnabled) || !IsPlayerHere(client))
	{
		return Plugin_Handled;
	}
	
	if (!g_bMVM && IsPlayerHere(client))
	{
		int team = GetClientTeam(client);
		int team2 = GetConVarInt(g_hCVTeam);
		
		switch (team2)
		{
		case 2:
			{
				if (team != 2)
				{
					return Plugin_Stop;
				}
			}
		case 3:
			{
				if (team != 3)
				{
					return Plugin_Stop;
				}
			}
		}
	}
	
	if (g_bMVM && GetConVarBool(g_hCVMVMREDEnabled) && IsPlayerHere(client))
	{
		int team = GetClientTeam(client);
		
		if (team != 2)
		{
			return Plugin_Stop;
		}
	}

	TFClassType class = TF2_GetPlayerClass(client);

	switch (class)
	{
	case TFClass_Scout:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,6);
				TF2_RemoveWeaponSlot(client, 0);

				switch (rnd)
				{
				case 1:
					{
						int rnd8 = GetRandomUInt(1,3);
						switch (rnd8)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 45, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 1078, 6);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 45, 9);
							}
						}
					}
				case 2:
					{
						int rnd6 = GetRandomUInt(1,2);
						switch (rnd6)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_handgun_scout_primary", 220, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_handgun_scout_primary", 220, 16);
							}
						}
					}
				case 3:
					{
						int rnd7 = GetRandomUInt(1,2);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_soda_popper", 448, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_soda_popper", 448, 16);
							}
						}
					}
				case 4:
					{
						CreateWeapon(client, "tf_weapon_pep_brawler_blaster", 772, 6);
					}
				case 5:
					{
						CreateWeapon(client, "tf_weapon_scattergun", 1103, 6);
					}
				case 6:
					{
						int rnd8 = GetRandomUInt(1,7);
						switch (rnd8)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 13, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 669, 6);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 200, 9);
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 200, 16);
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_scattergun", 200, 11);
							}
						case 6:
							{
								int rnd9 = GetRandomUInt(1,8);
								switch (rnd9)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 799, 11);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 808, 11);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 888, 11);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 897, 11);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 906, 11);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 915, 11);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 964, 11);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 973, 11);
									}
								}
							}
						case 7:
							{
								int rnd10 = GetRandomUInt(1,14);
								switch (rnd10)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15002, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15015, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15029, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15036, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15053, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15065, 11);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15069, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15106, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15107, 15);
									}
								case 10:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15108, 15);
									}
								case 11:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15131, 15);
									}
								case 12:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15151, 15);
									}
								case 13:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15157, 15);
									}
								case 14:
									{
										CreateWeapon(client, "tf_weapon_scattergun", 15021, 15);
									}
								}
							}
						}
					}
				}
				
				int rnd2 = GetRandomUInt(1,7);
				TF2_RemoveWeaponSlot(client, 1);
				
				switch (rnd2)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_handgun_scout_secondary", 773, 6);
					}
				case 2:
					{
						int rnd14 = GetRandomUInt(1,2);
						switch (rnd14)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_handgun_scout_secondary", 449, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_handgun_scout_secondary", 449, 16);
							}
						}
					}
				case 3:
					{
						int rnd800 = GetRandomUInt(1,2);
						switch (rnd800)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_cleaver", 812, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_cleaver", 833, 3);
							}
						}
					}
				case 4:
					{
						int rnd9 = GetRandomUInt(1,2);
						switch (rnd9)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_jar_milk", 222, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_jar_milk", 1121, 6);
							}
						}
					}
				case 5:
					{
						int rnd8 = GetRandomUInt(1,2);
						switch (rnd8)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_lunchbox_drink", 46, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_lunchbox_drink", 1145, 6);
							}
						}
					}
				case 6:
					{
						CreateWeapon(client, "tf_weapon_lunchbox_drink", 163, 6);
					}
				case 7:
					{
						int rnd3 = GetRandomUInt(1,3);
						switch (rnd3)
						{
						case 1:
							{
								int rnd7 = GetRandomUInt(1,2);
								switch (rnd7)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_pistol", 160, 3);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_pistol", 294, 6);
									}
								}
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_pistol", 30666, 6);
							}
						case 3:
							{
								int rnd7 = GetRandomUInt(1,3);
								switch (rnd7)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_pistol", 23, 5);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_pistol", 209, 16);
									}
								case 3:
									{
										int rnd8 = GetRandomUInt(1, 13);
										switch (rnd8)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15013, 15);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15018, 15);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15035, 15);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15041, 15);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15046, 15);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15056, 15);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15060, 15);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15061, 15);
											}
										case 9:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15100, 15);
											}
										case 10:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15101, 15);
											}
										case 11:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15102, 15);
											}
										case 12:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15126, 15);
											}
										case 13:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15148, 15);
											}
										}
									}
								}
							}
						}
					}
				}
			}
			
			int rnd3 = GetRandomUInt(1,8);
			TF2_RemoveWeaponSlot(client, 2);
			
			switch (rnd3)
			{
			case 1:
				{
					CreateWeapon(client, "tf_weapon_bat_wood", 44, 6);
				}
			case 2:
				{
					int rnd6 = GetRandomUInt(1,2);
					switch (rnd6)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_bat", 325, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_bat", 452, 6);
						}
					}
				}
			case 3:
				{
					CreateWeapon(client, "tf_weapon_bat", 317, 6);
				}
			case 4:
				{
					CreateWeapon(client, "tf_weapon_bat", 349, 6);
				}
			case 5:
				{
					CreateWeapon(client, "tf_weapon_bat", 355, 6);
				}
			case 6:
				{
					CreateWeapon(client, "tf_weapon_bat_giftwrap", 648, 6);
				}
			case 7:
				{
					CreateWeapon(client, "tf_weapon_bat", 450, 6);
				}
			case 8:
				{
					int rnd24 = GetRandomUInt(1,2);
					switch (rnd24)
					{
					case 1:
						{
							int rnd25 = GetRandomUInt(1,2);
							switch (rnd25)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_bat_fish", 572, 6);
								}
							case 2:
								{
									int rnd7 = GetRandomUInt(1,3);
									switch (rnd7)
									{
									case 1:
										{
											CreateWeapon(client, "tf_weapon_bat_fish", 221, 6);
										}
									case 2:
										{
											CreateWeapon(client, "tf_weapon_bat_fish", 999, 6);
										}
									case 3:
										{
											CreateWeapon(client, "tf_weapon_bat_fish", 221, 16);
										}
									}
								}
							}
						}
					case 2:
						{
							int rnd7 = GetRandomUInt(1,13);
							switch (rnd7)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_bat", 264, 6);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_bat", 423, 11);
								}
							case 3:
								{
									CreateWeapon(client, "tf_weapon_bat", 474, 6);
								}
							case 4:
								{
									CreateWeapon(client, "tf_weapon_bat", 880, 6);
								}
							case 5:
								{
									CreateWeapon(client, "tf_weapon_bat", 939, 6);
								}
							case 6:
								{
									CreateWeapon(client, "tf_weapon_bat", 954, 11);
								}
							case 7:
								{
									CreateWeapon(client, "tf_weapon_bat", 1013, 6);
								}
							case 8:
								{
									CreateWeapon(client, "tf_weapon_bat", 1071, 11);
								}
							case 9:
								{
									CreateWeapon(client, "tf_weapon_bat", 1123, 6);
								}
							case 10:
								{
									CreateWeapon(client, "tf_weapon_bat", 1127, 6);
								}
							case 11:
								{
									CreateWeapon(client, "tf_weapon_bat", 30667, 15);
								}
							case 12:
								{
									CreateWeapon(client, "tf_weapon_bat", 30758, 6);
								}
							case 13:
								{
									int rnd9 = GetRandomUInt(1,3);
									switch (rnd9)
									{
									case 1:
										{
											CreateWeapon(client, "tf_weapon_bat", 190, 11);
										}
									case 2:
										{
											CreateWeapon(client, "tf_weapon_bat", 660, 6);
										}
									case 3:
										{
											CreateWeapon(client, "tf_weapon_bat", 0, 5);
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
	case TFClass_Sniper:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,5);
				TF2_RemoveWeaponSlot(client, 0);
				
				switch (rnd)
				{
				case 1:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_compound_bow", 1092, 6);
							}
						case 2:
							{
								int rnd9 = GetRandomUInt(1,2);
								switch (rnd9)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_compound_bow", 1005, 6);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_compound_bow", 56, 6);
									}
								}
							}
						}
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_sniperrifle", 230, 6);
					}
				case 3:
					{
						int rnd6 = GetRandomUInt(1,2);
						switch (rnd6)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_sniperrifle", 526, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_sniperrifle", 30665, 15);
							}
						}
					}
				case 4:
					{
						CreateWeapon(client, "tf_weapon_sniperrifle", 752, 6);
					}
				case 5:
					{
						int rnd4 = GetRandomUInt(1,4);
						switch (rnd4)
						{     
						case 1:
							{
								CreateWeapon(client, "tf_weapon_sniperrifle", 851, 6);
							}
						case 2:
							{
								int rnd11 = GetRandomUInt(1,2);
								switch (rnd11)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_sniperrifle", 402, 6);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_sniperrifle", 402, 16);
									}
								}
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_sniperrifle", 1098, 6);
							}
						case 4:
							{
								int rnd11 = GetRandomUInt(1,6);
								switch (rnd11)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_sniperrifle", 14, 5);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_sniperrifle", 664, 6);
									}
								case 3:
									{
										int rnd10 = GetRandomUInt(1,8);
										switch (rnd10)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 792, 11);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 801, 11);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 881, 11);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 890, 11);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 899, 11);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 908, 11);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 957, 11);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 966, 11);
											}
										}
									}
								case 4:
									{
										int rnd14 = GetRandomUInt(1,14);
										switch (rnd14)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15000, 15);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15007, 15);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15019, 15);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15023, 15);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15033, 15);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15059, 15);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15070, 15);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15071, 15);
											}
										case 9:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15072, 15);
											}
										case 10:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15111, 15);
											}
										case 11:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15112, 15);
											}
										case 12:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15135, 15);
											}
										case 13:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15136, 15);
											}
										case 14:
											{
												CreateWeapon(client, "tf_weapon_sniperrifle", 15154, 15);
											}
										}
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_sniperrifle", 201, 11);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_sniperrifle", 201, 9);
									}
								}
							}
						}
					}				
				}
				
				int rnd2 = GetRandomUInt(1,6);
				TF2_RemoveWeaponSlot(client, 1);

				switch (rnd2)
				{
				case 1:
					{
						CreateWeapon(client, "tf_wearable_razorback", 57, 6);
					}
				case 2:
					{
						CreateWeapon(client, "tf_wearable", 231, 6);
					}
				case 3:
					{
						CreateWeapon(client, "tf_wearable", 642, 6);
					}
				case 4:
					{
						CreateWeapon(client, "tf_weapon_charged_smg", 751, 6);
					}
				case 5:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_jar", 1105, 6);
							}
						case 2:
							{
								int rnd9 = GetRandomUInt(1,2);
								switch (rnd9)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_jar", 58, 6);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_jar", 1083, 6);
									}
								}
							}
						}
					}
				case 6:
					{
						int rnd6 = GetRandomUInt(1,6);
						switch (rnd6)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_smg", 16, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_smg", 1149, 6);
							}
						case 3:
							{
								int rnd10 = GetRandomUInt(1,9);
								switch (rnd10)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_smg", 15001, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_smg", 15022, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_smg", 15032, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_smg", 15037, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_smg", 15058, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_smg", 15076, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_smg", 15110, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_smg", 15134, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_smg", 15153, 15);
									}
								}
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_smg", 203, 11);
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_smg", 203, 9);
							}
						case 6:
							{
								CreateWeapon(client, "tf_weapon_smg", 203, 16);
							}
						}
					}
				}
			}
			
			int rnd3 = GetRandomUInt(1,4);
			TF2_RemoveWeaponSlot(client, 2);

			switch (rnd3)
			{
			case 1:
				{
					CreateWeapon(client, "tf_weapon_club", 171, 6);
				}
			case 2:
				{
					CreateWeapon(client, "tf_weapon_club", 232, 6);
				}
			case 3:
				{
					int rnd6 = GetRandomUInt(1,2);
					switch (rnd6)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_club", 401, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_club", 401, 16);
						}
					}
				}
			case 4:
				{
					int rnd8 = GetRandomUInt(1,12);
					switch (rnd8)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_club", 264, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_club", 423, 11);
						}
					case 3:
						{
							CreateWeapon(client, "tf_weapon_club", 474, 6);
						}
					case 4:
						{
							CreateWeapon(client, "tf_weapon_club", 880, 6);
						}
					case 5:
						{
							CreateWeapon(client, "tf_weapon_club", 939, 6);
						}
					case 6:
						{
							CreateWeapon(client, "tf_weapon_club", 954, 11);
						}
					case 7:
						{
							CreateWeapon(client, "tf_weapon_club", 1013, 6);
						}
					case 8:
						{
							CreateWeapon(client, "tf_weapon_club", 1071, 11);
						}
					case 9:
						{
							CreateWeapon(client, "tf_weapon_club", 1123, 6);
						}
					case 10:
						{
							CreateWeapon(client, "tf_weapon_club", 1127, 6);
						}
					case 11:
						{
							CreateWeapon(client, "tf_weapon_club", 30758, 6);
						}
					case 12:
						{
							int rnd9 = GetRandomUInt(1,2);
							switch (rnd9)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_club", 3, 5);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_club", 193, 11);
								}
							}
						}
					}
				}					
			}			
		}
		
	case TFClass_Soldier:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,7);
				TF2_RemoveWeaponSlot(client, 0);

				switch (rnd)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_rocketlauncher_directhit", 127, 6);
					}
				case 2:
					{
						int rnd4 = GetRandomUInt(1,4);
						switch (rnd4)
						{     
						case 1:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher", 228, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher", 1085, 6);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher", 228, 9);
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher", 228, 16);
							}
						}
					}
				case 3:
					{
						CreateWeapon(client, "tf_weapon_rocketlauncher", 414, 6);
					}
				case 4:
					{
						CreateWeapon(client, "tf_weapon_particle_cannon", 441, 6);
					}
				case 5:
					{
						int rnd4 = GetRandomUInt(1,2);
						switch (rnd4)
						{     
						case 1:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher_airstrike", 1104, 16);
							}
						}
					}
				case 6:
					{
						CreateWeapon(client, "tf_weapon_rocketlauncher", 730, 6);
					}
				case 7:
					{
						int rnd4 = GetRandomUInt(1,2);
						switch (rnd4)
						{     
						case 1:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher", 513, 6);
							}
						case 2:
							{
								int rnd69 = GetRandomUInt(1,6);
								switch (rnd69)
								{     
								case 1:
									{
										CreateWeapon(client, "tf_weapon_rocketlauncher", 18, 5);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_rocketlauncher", 658, 6);
									}
								case 3:
									{
										int rnd11 = GetRandomUInt(1,8);
										switch (rnd11)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 800, 11);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 809, 11);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 889, 11);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 898, 11);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 907, 11);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 916, 11);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 965, 11);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 974, 11);
											}
										}
									}
								case 4:
									{
										int rnd12 = GetRandomUInt(1,12);
										switch (rnd12)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15006, 15);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15014, 15);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15028, 15);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15043, 15);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15052, 15);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15057, 15);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15081, 15);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15104, 15);
											}
										case 9:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15105, 15);
											}
										case 10:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15129, 15);
											}
										case 11:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15130, 15);
											}
										case 12:
											{
												CreateWeapon(client, "tf_weapon_rocketlauncher", 15150, 15);
											}
										}
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_rocketlauncher", 205, 9);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_rocketlauncher", 205, 16);
									}
								}
							}
						}
					}
				}
				
				int rnd2 = GetRandomUInt(1,8);
				TF2_RemoveWeaponSlot(client, 1);
				
				switch (rnd2)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_raygun", 442, 6);
					}
				case 2:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 1153, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 1153, 16);
							}
						}
					}
				case 3:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 415, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 415, 16);
							}
						}
					}
				case 4:
					{
						int rnd6 = GetRandomUInt(1,2);
						switch (rnd6)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_buff_item", 129, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_buff_item", 1001, 6);
							}
						}
					}
				case 5:
					{
						CreateWeapon(client, "tf_weapon_buff_item", 226, 6);
					}
				case 6:
					{
						CreateWeapon(client, "tf_weapon_buff_item", 354, 6);
					}
				case 7:
					{
						CreateWeapon(client, "tf_wearable", 444, 6);
					}
				case 8:
					{
						int rnd7 = GetRandomUInt(1,5);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 10, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 1141, 6);
							}
						case 3:
							{
								int rnd11 = GetRandomUInt(1,9);
								switch (rnd11)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15003, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15016, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15044, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15047, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15085, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15109, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15132, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15133, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_shotgun_soldier", 15152, 15);
									}
								}
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 199, 11);
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_shotgun_soldier", 199, 16);
							}
						}
					}
				}
			}
			
			int rnd3 = GetRandomUInt(1,6);
			TF2_RemoveWeaponSlot(client, 2);
			
			switch (rnd3)
			{
			case 1:
				{
					CreateWeapon(client, "tf_weapon_shovel", 128, 6);
				}
			case 2:
				{
					CreateWeapon(client, "tf_weapon_shovel", 154, 6);
				}
			case 3:
				{
					CreateWeapon(client, "tf_weapon_shovel", 775, 6);
				}
			case 4:
				{
					CreateWeapon(client, "tf_weapon_katana", 357, 6);
				}
			case 5:
				{
					CreateWeapon(client, "tf_weapon_shovel", 447, 6);
				}
			case 6:
				{
					int rnd5 = GetRandomUInt(1,12);
					switch (rnd5)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_shovel", 264, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_shovel", 423, 11);
						}
					case 3:
						{
							CreateWeapon(client, "tf_weapon_shovel", 474, 6);
						}
					case 4:
						{
							CreateWeapon(client, "tf_weapon_shovel", 880, 6);
						}
					case 5:
						{
							CreateWeapon(client, "tf_weapon_shovel", 939, 6);
						}
					case 6:
						{
							CreateWeapon(client, "tf_weapon_shovel", 1013, 6);
						}
					case 7:
						{
							CreateWeapon(client, "tf_weapon_shovel", 1071, 11);
						}
					case 8:
						{
							CreateWeapon(client, "tf_weapon_shovel", 1123, 6);
						}
					case 9:
						{
							CreateWeapon(client, "tf_weapon_shovel", 1127, 6);
						}
					case 10:
						{
							CreateWeapon(client, "tf_weapon_shovel", 30758, 6);
						}
					case 11:
						{
							CreateWeapon(client, "tf_weapon_shovel", 954, 11);
						}
					case 12:
						{
							int rnd9 = GetRandomUInt(1,2);
							switch (rnd9)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_shovel", 6, 5);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_shovel", 196, 11);
								}
							}
						}
					}
				}					
			}
		}
		
	case TFClass_DemoMan:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,5); 
				TF2_RemoveWeaponSlot(client, 0);
				
				switch (rnd)
				{
				case 1:
					{
						int rnd8 = GetRandomUInt(1,2);
						switch (rnd8)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 308, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 308, 16);
							}
						}
					}
				case 2:
					{
						int rnd9 = GetRandomUInt(1,2);
						switch (rnd9)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 1151, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 1151, 16);
							}
						}
					}
				case 3:
					{
						int rnd9 = GetRandomUInt(1,2);
						switch (rnd9)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 996, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 996, 16);
							}
						}
					}
				case 4:
					{
						int rnd4 = GetRandomUInt(1,2);
						switch (rnd4)
						{
						case 1:
							{
								CreateWeapon(client, "tf_wearable", 405, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_wearable", 608, 6);
							}
						}
					}
				case 5:
					{
						int rnd7 = GetRandomUInt(1,6);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 19, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 1007, 6);
							}
						case 3:
							{
								int rnd11 = GetRandomUInt(1,8);
								switch (rnd11)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15077, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15079, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15091, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15092, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15116, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15117, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15142, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_grenadelauncher", 15158, 15);
									}
								}
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 206, 11);
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 206, 9);
							}
						case 6:
							{
								CreateWeapon(client, "tf_weapon_grenadelauncher", 206, 16);
							}
						}
					}	
				}
				
				int rnd2 = GetRandomUInt(1,6); 
				TF2_RemoveWeaponSlot(client, 1);
				
				switch (rnd2)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_pipebomblauncher", 1150, 6);
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_pipebomblauncher", 130, 6);
					}
				case 3:
					{
						int rnd4 = GetRandomUInt(1,2);
						switch (rnd4)
						{     
						case 1:
							{
								CreateWeapon(client, "tf_wearable_demoshield", 131, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_wearable_demoshield", 1144, 6);
							}
						}
					}
				case 4:
					{
						CreateWeapon(client, "tf_wearable_demoshield", 406, 6);
					}
				case 5:
					{
						CreateWeapon(client, "tf_wearable_demoshield", 1099, 6);
					}
				case 6:
					{
						int rnd5 = GetRandomUInt(1,8);
						switch (rnd5)
						{     
						case 1:
							{
								CreateWeapon(client, "tf_weapon_pipebomblauncher", 20, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_pipebomblauncher", 661, 6);
							}
						case 3:
							{
								int rnd12 = GetRandomUInt(1,8);
								switch (rnd12)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 797, 11);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 806, 11);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 886, 11);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 895, 11);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 904, 11);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 913, 11);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 962, 11);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 971, 11);
									}
								}
							}
						case 4:
							{
								int rnd14 = GetRandomUInt(1,13);
								switch (rnd14)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15009, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15012, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15024, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15038, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15045, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15048, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15082, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15083, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15084, 15);
									}
								case 10:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15113, 15);
									}
								case 11:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15137, 15);
									}
								case 12:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15138, 15);
									}
								case 13:
									{
										CreateWeapon(client, "tf_weapon_pipebomblauncher", 15155, 15);
									}
								}
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_pipebomblauncher", 207, 9);
							}
						case 6:
							{
								CreateWeapon(client, "tf_weapon_pipebomblauncher", 207, 16);
							}
						case 7:
							{
								CreateWeapon(client, "tf_weapon_pipebomblauncher", 207, 11);
							}
						case 8:
							{
								CreateWeapon(client, "tf_weapon_pipebomblauncher", 661, 11);
							}
						}
					}					
				}
			}
			
			int rnd3 = GetRandomUInt(1,8);
			TF2_RemoveWeaponSlot(client, 2);
			
			switch (rnd3)
			{
			case 1:
				{
					int rnd5 = GetRandomUInt(1,3);
					switch (rnd5)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_sword", 266, 5);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_sword", 482, 6);
						}
					case 3:
						{
							int rnd4 = GetRandomUInt(1,3);
							switch (rnd4)
							{     
							case 1:
								{
									CreateWeapon(client, "tf_weapon_sword", 132, 6);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_sword", 132, 9);
								}
							case 3:
								{
									CreateWeapon(client, "tf_weapon_sword", 1082, 9);
								}
							}
						}
					}
				}
			case 2:
				{
					CreateWeapon(client, "tf_weapon_shovel", 154, 6);
				}
			case 3:
				{
					int rnd4 = GetRandomUInt(1,2);
					switch (rnd4)
					{     
					case 1:
						{
							CreateWeapon(client, "tf_weapon_sword", 172, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_sword", 172, 16);
						}
					}
				}
			case 4:
				{
					CreateWeapon(client, "tf_weapon_stickbomb", 307, 6);
				}
			case 5:
				{
					int rnd7 = GetRandomUInt(1,2);
					switch (rnd7)
					{     
					case 1:
						{
							CreateWeapon(client, "tf_weapon_sword", 327, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_sword", 327, 16);
						}
					}
				}
			case 6:
				{
					CreateWeapon(client, "tf_weapon_katana", 357, 6);
				}
			case 7:
				{
					int rnd8 = GetRandomUInt(1,2);
					switch (rnd8)
					{     
					case 1:
						{
							CreateWeapon(client, "tf_weapon_sword", 404, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_sword", 404, 16);
						}
					}
				}
			case 8:
				{
					int rnd6 = GetRandomUInt(1,13);
					switch (rnd6)
					{
					case 1:
						{
							int rnd9 = GetRandomUInt(1,2);
							switch (rnd9)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_bottle", 1, 5);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_bottle", 191, 11);
								}
							}
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_bottle", 264, 6);
						}
					case 3:
						{
							CreateWeapon(client, "tf_weapon_bottle", 423, 11);
						}
					case 4:
						{
							CreateWeapon(client, "tf_weapon_bottle", 474, 6);
						}
					case 5:
						{
							CreateWeapon(client, "tf_weapon_bottle", 609, 6);
						}
					case 6:
						{
							CreateWeapon(client, "tf_weapon_bottle", 880, 6);
						}
					case 7:
						{
							CreateWeapon(client, "tf_weapon_bottle", 939, 6);
						}
					case 8:
						{
							CreateWeapon(client, "tf_weapon_bottle", 954, 11);
						}
					case 9:
						{
							CreateWeapon(client, "tf_weapon_bottle", 1013, 6);
						}
					case 10:
						{
							CreateWeapon(client, "tf_weapon_bottle", 1071, 11);
						}
					case 11:
						{
							CreateWeapon(client, "tf_weapon_bottle", 1123, 6);
						}
					case 12:
						{
							CreateWeapon(client, "tf_weapon_bottle", 1127, 6);
						}
					case 13:
						{
							CreateWeapon(client, "tf_weapon_bottle", 30758, 6);
						}
					}
				}					
			}				
		}
		
	case TFClass_Medic:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,4); 
				TF2_RemoveWeaponSlot(client, 0);
				
				switch (rnd)
				{
				case 1:
					{
						int rnd7 = GetRandomUInt(1,2);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_syringegun_medic", 36, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_syringegun_medic", 36, 9);
							}
						}
					}
				case 2:
					{
						int rnd6 = GetRandomUInt(1,3);
						switch (rnd6)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_crossbow", 305, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_crossbow", 1079, 6);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_crossbow", 305, 16);
							}
						}
					}
				case 3:
					{
						CreateWeapon(client, "tf_weapon_syringegun_medic", 412, 6);
					}
				case 4:
					{
						int rnd7 = GetRandomUInt(1,2);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_syringegun_medic", 17, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_syringegun_medic", 204, 11);
							}
						}
					}				
				}
				
				int rnd2 = GetRandomUInt(1,4);
				TF2_RemoveWeaponSlot(client, 1);
				switch (rnd2)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_medigun", 35, 6);
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_medigun", 411, 6);
					}
				case 3:
					{
						CreateWeapon(client, "tf_weapon_medigun", 998, 6);
					}
				case 4:
					{
						int rnd4 = GetRandomUInt(1,7);
						switch (rnd4)
						{     
						case 1:
							{
								CreateWeapon(client, "tf_weapon_medigun", 29, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_medigun", 663, 6);
							}
						case 3:
							{
								int rnd13 = GetRandomUInt(1,8);
								switch (rnd13)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_medigun", 796, 11);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_medigun", 805, 11);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_medigun", 885, 11);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_medigun", 894, 11);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_medigun", 903, 11);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_medigun", 912, 11);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_medigun", 961, 11);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_medigun", 970, 11);
									}
								}
							}
						case 4:
							{
								int rnd12 = GetRandomUInt(1,12);
								switch (rnd12)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15008, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15010, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15025, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15039, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15050, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15078, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15097, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15121, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15122, 15);
									}
								case 10:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15145, 15);
									}
								case 11:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15146, 15);
									}
								case 12:
									{
										CreateWeapon(client, "tf_weapon_medigun", 15120, 15);
									}
								}
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_medigun", 211, 11);
							}
						case 6:
							{
								CreateWeapon(client, "tf_weapon_medigun", 211, 9);
							}
						case 7:
							{
								CreateWeapon(client, "tf_weapon_medigun", 211, 16);
							}
						}
					}				
				}
			}
			int rnd3 = GetRandomUInt(1,3);
			TF2_RemoveWeaponSlot(client, 2);
			
			switch (rnd3)
			{
			case 1:
				{
					int rnd7 = GetRandomUInt(1,3);
					switch (rnd7)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 37, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 1003, 6);
						}
					case 3:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 37, 16);
						}
					}
				}
			case 2:
				{
					int rnd8 = GetRandomUInt(1,2);
					switch (rnd8)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 304, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 304, 16);
						}
					}
				}
			case 3:
				{
					int rnd4 = GetRandomUInt(1,12);
					switch (rnd4)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 264, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 423, 11);
						}
					case 3:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 474, 6);
						}
					case 4:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 880, 6);
						}
					case 5:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 939, 6);
						}
					case 6:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 1013, 6);
						}
					case 7:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 1071, 11);
						}
					case 8:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 1123, 6);
						}
					case 9:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 1127, 6);
						}
					case 10:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 30758, 6);
						}
					case 11:
						{
							CreateWeapon(client, "tf_weapon_bonesaw", 954, 11);
						}
					case 12:
						{
							int rnd9 = GetRandomUInt(1,3);
							switch (rnd9)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_bonesaw", 8, 5);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_bonesaw", 198, 11);
								}
							case 3:
								{
									CreateWeapon(client, "tf_weapon_bonesaw", 1143, 6);
								}
							}
						}
					}
				}			
			}			
		}
		
	case TFClass_Heavy:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,5);
				TF2_RemoveWeaponSlot(client, 0);
				
				switch (rnd)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_minigun", 41, 6);
					}
				case 2:
					{
						int rnd10 = GetRandomUInt(1,2);
						switch (rnd10)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_minigun", 312, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_minigun", 312, 16);
							}
						}
					}
				case 3:
					{
						int rnd9 = GetRandomUInt(1,4);
						switch (rnd9)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_minigun", 424, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_minigun", 424, 5);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_minigun", 424, 9);
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_minigun", 424, 16);
							}
						}
					}
				case 4:
					{
						int rnd8 = GetRandomUInt(1,3);
						switch (rnd8)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_minigun", 811, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_minigun", 811, 15);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_minigun", 832, 3);
							}
						}
					}
				case 5:
					{
						int rnd4 = GetRandomUInt(1,2);
						switch (rnd4)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_minigun", 298, 6);
							}
						case 2:
							{
								int rnd8 = GetRandomUInt(1,3);
								switch (rnd8)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_minigun", 15, 5);
									}
								case 2:
									{
										int rnd13 = GetRandomUInt(1,7);
										switch (rnd13)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_minigun", 793, 11);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_minigun", 802, 11);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_minigun", 882, 11);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_minigun", 891, 11);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_minigun", 900, 11);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_minigun", 909, 11);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_minigun", 958, 11);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_minigun", 967, 11);
											}
										}
									}
								case 3:
									{
										int rnd12 = GetRandomUInt(1,15);
										switch (rnd12)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15004, 15);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15020, 15);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15026, 15);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15031, 15);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15040, 15);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15055, 15);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15086, 15);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15087, 15);
											}
										case 9:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15088, 15);
											}
										case 10:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15098, 15);
											}
										case 11:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15099, 15);
											}
										case 12:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15123, 15);
											}
										case 13:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15124, 15);
											}
										case 14:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15125, 15);
											}
										case 15:
											{
												CreateWeapon(client, "tf_weapon_minigun", 15147, 15);
											}
										}
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_minigun", 202, 11);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_minigun", 202, 9);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_minigun", 202, 16);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_minigun", 850, 6);
									}
								}
							}
						}
					}					
				}
				
				int rnd2 = GetRandomUInt(1,7);
				TF2_RemoveWeaponSlot(client, 1);
				
				switch (rnd2)
				{
				case 1:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 425, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 425, 16);
							}
						}
					}
				case 2:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 1153, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 1153, 16);
							}
						}
					}	
				case 3:
					{
						int rnd7 = GetRandomUInt(1,5);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 11, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 1141, 6);
							}
						case 3:
							{
								int rnd11 = GetRandomUInt(1,9);
								switch (rnd11)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15003, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15016, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15044, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15047, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15085, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15109, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15132, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15133, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_shotgun_hwg", 15152, 15);
									}
								}
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 199, 16);
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_shotgun_hwg", 199, 11);
							}
						}
					}
				case 4:
					{
						CreateWeapon(client, "tf_weapon_lunchbox", 311, 6);
					}
				case 5:
					{
						int rnd5 = GetRandomUInt(1,3);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_lunchbox", 42, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_lunchbox", 863, 6);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_lunchbox", 1002, 6);
							}
						}
					}
				case 6:
					{
						int rnd6 = GetRandomUInt(1,2);
						switch (rnd6)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_lunchbox", 159, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_lunchbox", 433, 6);
							}
						}
					}
				case 7:
					{
						CreateWeapon(client, "tf_weapon_lunchbox", 1190, 6);
					}
				}
			}
			int rnd3 = GetRandomUInt(1,8);
			TF2_RemoveWeaponSlot(client, 2);
			
			switch (rnd3)
			{
			case 1:
				{
					CreateWeapon(client, "tf_weapon_fists", 43, 6);
				}
			case 2:
				{
					int rnd5 = GetRandomUInt(1,2);
					switch (rnd5)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_fists", 1100, 6);
						}
					case 2:
						{
							int rnd8 = GetRandomUInt(1,2);
							switch (rnd8)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_fists", 1084, 6);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_fists", 239, 6);
								}
							}
						}
					}
				}
			case 3:
				{
					CreateWeapon(client, "tf_weapon_fists", 310, 6);
				}
			case 4:
				{
					CreateWeapon(client, "tf_weapon_fists", 331, 6);
				}
			case 5:
				{
					CreateWeapon(client, "tf_weapon_fists", 426, 6);
				}
			case 6:
				{
					CreateWeapon(client, "tf_weapon_fists", 656, 6);
				}
			case 7:
				{
					CreateWeapon(client, "tf_weapon_fists", 1184, 6);
				}
			case 8:
				{
					int rnd6 = GetRandomUInt(1,13);
					switch (rnd6)
					{
					case 1:
						{
							int rnd9 = GetRandomUInt(1,2);
							switch (rnd9)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_fists", 5, 5);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_fists", 195, 11);
								}
							}
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_fists", 587, 6);
						}
					case 3:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 264, 6);
						}
					case 4:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 423, 11);
						}
					case 5:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 474, 6);
						}
					case 6:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 880, 6);
						}
					case 7:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 939, 6);
						}
					case 8:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 954, 11);
						}
					case 9:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 1013, 6);
						}
					case 10:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 1071, 11);
						}
					case 11:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 1123, 6);
						}
					case 12:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 1127, 6);
						}
					case 13:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 30758, 6);
						}
					}
				}
			}						
		}
		
	case TFClass_Pyro:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,5);
				TF2_RemoveWeaponSlot(client, 0);
				
				switch (rnd)
				{
				case 1:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_flamethrower", 40, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_flamethrower", 1146, 6);
							}
						}
					}
				case 2:
					{
						int rnd9 = GetRandomUInt(1,2);
						switch (rnd9)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_flamethrower", 215, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_flamethrower", 215, 16);
							}
						}
					}
				case 3:
					{
						CreateWeapon(client, "tf_weapon_flamethrower", 594, 6);
					}
				case 4:
					{
						int rnd9 = GetRandomUInt(1,2);
						switch (rnd9)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher_fireball", 1178, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_rocketlauncher_fireball", 1178, 16);
							}
						}
					}
				case 5:
					{
						int rnd4 = GetRandomUInt(1,3);
						switch (rnd4)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_flamethrower", 741, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_flamethrower", 30474, 6);
							}
						case 3:
							{
								int rnd15 = GetRandomUInt(1,7);
								switch (rnd15)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_flamethrower", 21, 5);
									}
								case 2:
									{
										int rnd16 = GetRandomUInt(1,8);
										switch (rnd16)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 798, 11);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 807, 11);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 887, 11);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 896, 11);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 905, 11);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 914, 11);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 963, 11);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 972, 11);
											}
										}
									}
								case 3:
									{
										int rnd12 = GetRandomUInt(1,13);
										switch (rnd12)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15005, 15);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15017, 15);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15030, 15);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15034, 15);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15049, 15);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15054, 15);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15066, 15);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15067, 15);
											}
										case 9:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15068, 15);
											}
										case 10:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15089, 15);
											}
										case 11:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15090, 15);
											}
										case 12:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15115, 15);
											}
										case 13:
											{
												CreateWeapon(client, "tf_weapon_flamethrower", 15141, 15);
											}
										}
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_flamethrower", 659, 6);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_flamethrower", 208, 11);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_flamethrower", 208, 9);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_flamethrower", 208, 16);
									}
								}
							}
						}
					}	
				}
				
				int rnd2 = GetRandomUInt(1,7);
				TF2_RemoveWeaponSlot(client, 1);
				
				switch (rnd2)
				{
				case 1:
					{
						int rnd7 = GetRandomUInt(1,2);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_flaregun", 39, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_flaregun", 1081, 6);
							}
						}
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_flaregun_revenge", 595, 6);
					}
				case 3:
					{
						int rnd7 = GetRandomUInt(1,2);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_flaregun", 740, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_flaregun", 740, 16);
							}
						}
					}
				case 4:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 1153, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 1153, 16);
							}
						}
					}
				case 5:
					{
						int rnd6 = GetRandomUInt(1,2);
						switch (rnd6)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 415, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 415, 16);
							}
						}
					}
				case 6:
					{
						CreateWeapon(client, "tf_weapon_jar_gas", 1180, 6);
					}
				case 7:
					{
						int rnd8 = GetRandomUInt(1,5);
						switch (rnd8)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 12, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 1141, 6);
							}
						case 3:
							{
								int rnd11 = GetRandomUInt(1,9);
								switch (rnd11)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15003, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15016, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15044, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15047, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15085, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15109, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15132, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15133, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_shotgun_pyro", 15152, 15);
									}
								}
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 199, 16);
							}
						case 5:
							{
								CreateWeapon(client, "tf_weapon_shotgun_pyro", 199, 11);
							}
						}
					}				
				}
			}
			
			int rnd3 = GetRandomUInt(1,7);
			TF2_RemoveWeaponSlot(client, 2);
			
			switch (rnd3)
			{
			case 1:
				{
					int rnd5 = GetRandomUInt(1,2);
					switch (rnd5)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 457, 6);
						}
					case 2:
						{
							int rnd6 = GetRandomUInt(1,3);
							switch (rnd6)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_fireaxe", 38, 6);
								}
							case 2:
								{
									CreateWeapon(client, "tf_weapon_fireaxe", 1000, 6);
								}
							case 3:
								{
									CreateWeapon(client, "tf_weapon_fireaxe", 38, 9);
								}
							}
						}
					}
				}
			case 2:
				{
					int rnd8 = GetRandomUInt(1,2);
					switch (rnd8)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 326, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 326, 16);
						}
					}
				}
			case 3:
				{
					int rnd9 = GetRandomUInt(1,2);
					switch (rnd9)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 214, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_fireaxe", 214, 16);
						}
					}
				}
			case 4:
				{
					CreateWeapon(client, "tf_weapon_fireaxe", 348, 6);
				}
			case 5:
				{
					CreateWeapon(client, "tf_weapon_fireaxe", 593, 6);
				}
			case 6:
				{
					int rnd9 = GetRandomUInt(1,2);
					switch (rnd9)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_breakable_sign", 813, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_breakable_sign", 834, 3);
						}
					}
				}
			case 7:
				{
					CreateWeapon(client, "tf_weapon_slap", 1181, 6);
				}				
			}			
		}
	case TFClass_Spy:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,4);
				TF2_RemoveWeaponSlot(client, 0);
				
				switch (rnd)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_revolver", 224, 6);
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_revolver", 460, 6);
					}
				case 3:
					{
						CreateWeapon(client, "tf_weapon_revolver", 525, 6);
					}
				case 4:
					{
						int rnd23 = GetRandomUInt(1,2);
						switch (rnd23)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_revolver", 161, 6);
							}
						case 2:
							{
								int rnd5 = GetRandomUInt(1,5);
								switch (rnd5)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_revolver", 24, 6);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_revolver", 1142, 6);
									}
								case 3:
									{
										int rnd12 = GetRandomUInt(1,11);
										switch (rnd12)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15011, 15);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15027, 15);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15042, 15);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15051, 15);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15062, 15);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15063, 15);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15064, 15);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15103, 15);
											}
										case 9:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15128, 15);
											}
										case 10:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15127, 15);
											}
										case 11:
											{
												CreateWeapon(client, "tf_weapon_revolver", 15149, 15);
											}
										}
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_revolver", 210, 11);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_revolver", 210, 16);
									}
								}
							}
						}
					}					
				}
				int rnd2 = GetRandomUInt(1,2);
				TF2_RemoveWeaponSlot(client, 1);
				
				switch (rnd2)
				{
				case 1:
					{
						CreateWeapon(client, "tf_weapon_builder", 810, 6);
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_builder", 736, 11);
					}
				}
			}
			
			int rnd3 = GetRandomUInt(1,5);
			TF2_RemoveWeaponSlot(client, 2);
			CreateWeapon(client, "tf_weapon_pda_spy", 27, 6);
			
			switch (rnd3)
			{
			case 1:
				{
					CreateWeapon(client, "tf_weapon_knife", 356, 6);
				}
			case 2:
				{
					CreateWeapon(client, "tf_weapon_knife", 461, 6);
				}
			case 3:
				{
					CreateWeapon(client, "tf_weapon_knife", 649, 6);
				}
			case 4:
				{
					int rnd7 = GetRandomUInt(1,2);
					switch (rnd7)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_knife", 225, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_knife", 574, 6);
						}
					}
				}
			case 5:
				{
					int rnd6 = GetRandomUInt(1,3);
					switch (rnd6)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_knife", 638, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_knife", 727, 6);
						}
					case 3:
						{
							int rnd11 = GetRandomUInt(1,7);
							switch (rnd11)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_knife", 665, 6);
								}
							case 2:
								{
									int rnd12 = GetRandomUInt(1,8);
									switch (rnd12)
									{
									case 1:
										{
											CreateWeapon(client, "tf_weapon_knife", 794, 11);
										}
									case 2:
										{
											CreateWeapon(client, "tf_weapon_knife", 803, 11);
										}
									case 3:
										{
											CreateWeapon(client, "tf_weapon_knife", 883, 11);
										}
									case 4:
										{
											CreateWeapon(client, "tf_weapon_knife", 892, 11);
										}
									case 5:
										{
											CreateWeapon(client, "tf_weapon_knife", 901, 11);
										}
									case 6:
										{
											CreateWeapon(client, "tf_weapon_knife", 910, 11);
										}
									case 7:
										{
											CreateWeapon(client, "tf_weapon_knife", 959, 11);
										}
									case 8:
										{
											CreateWeapon(client, "tf_weapon_knife", 968, 11);
										}
									}
								}
							case 3:
								{
									int rnd12 = GetRandomUInt(1,8);
									switch (rnd12)
									{
									case 1:
										{
											CreateWeapon(client, "tf_weapon_knife", 15062, 15);
										}
									case 2:
										{
											CreateWeapon(client, "tf_weapon_knife", 15094, 15);
										}
									case 3:
										{
											CreateWeapon(client, "tf_weapon_knife", 15095, 15);
										}
									case 4:
										{
											CreateWeapon(client, "tf_weapon_knife", 15096, 15);
										}
									case 5:
										{
											CreateWeapon(client, "tf_weapon_knife", 15118, 15);
										}
									case 6:
										{
											CreateWeapon(client, "tf_weapon_knife", 15119, 15);
										}
									case 7:
										{
											CreateWeapon(client, "tf_weapon_knife", 15143, 15);
										}
									case 8:
										{
											CreateWeapon(client, "tf_weapon_knife", 15144, 15);
										}
									}
								}
							case 4:
								{
									CreateWeapon(client, "tf_weapon_knife", 194, 11);
								}
							case 5:
								{
									CreateWeapon(client, "tf_weapon_knife", 194, 9);
								}
							case 6:
								{
									CreateWeapon(client, "tf_weapon_knife", 194, 16);
								}
							case 7:
								{
									CreateWeapon(client, "tf_weapon_knife", 4, 5);
								}
							}
						}
					}
				}					
			}

			int rnd4 = GetRandomUInt(1,3);
			TF2_RemoveWeaponSlot(client, 4);
			
			switch (rnd4)
			{
			case 1:
				{
					CreateWeapon(client, "tf_weapon_invis", 59, 6);
				}
			case 2:
				{
					CreateWeapon(client, "tf_weapon_invis", 60, 6);
				}
			case 3:
				{
					int rnd8 = GetRandomUInt(1,3);
					switch (rnd8)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_invis", 212, 11);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_invis", 297, 6);
						}
					case 3:
						{
							CreateWeapon(client, "tf_weapon_invis", 947, 6);
						}
					}
				}
			}
		}
	case TFClass_Engineer:
		{
			if (!g_bMedieval)
			{
				int rnd = GetRandomUInt(1,6);
				TF2_RemoveWeaponSlot(client, 0);
				
				switch (rnd)
				{
				case 1:
					{
						int rnd8 = GetRandomUInt(1,3);
						switch (rnd8)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_sentry_revenge", 141, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_sentry_revenge", 1004, 6);
							}
						case 3:
							{
								CreateWeapon(client, "tf_weapon_sentry_revenge", 141, 9);
							}
						}
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_drg_pomson", 588, 6);
					}
				case 3:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_primary", 1153, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_primary", 1153, 16);
							}
						}
					}	
				case 4:
					{
						CreateWeapon(client, "tf_weapon_shotgun_primary", 527, 6);
					}
				case 5:
					{
						int rnd11 = GetRandomUInt(1,2);
						switch (rnd11)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_building_rescue", 997, 6);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_building_rescue", 997, 16);
							}
						}
					}						
				case 6:
					{
						int rnd7 = GetRandomUInt(1,4);
						switch (rnd7)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_shotgun_primary", 9, 5);
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_shotgun_primary", 1141, 6);
							}
						case 3:
							{
								int rnd11 = GetRandomUInt(1,9);
								switch (rnd11)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15003, 15);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15016, 15);
									}
								case 3:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15044, 15);
									}
								case 4:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15047, 15);
									}
								case 5:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15085, 15);
									}
								case 6:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15109, 15);
									}
								case 7:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15132, 15);
									}
								case 8:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15133, 15);
									}
								case 9:
									{
										CreateWeapon(client, "tf_weapon_shotgun_primary", 15152, 15);
									}
								}
							}
						case 4:
							{
								CreateWeapon(client, "tf_weapon_shotgun_primary", 199, 16);
							}
						}
					}					
				}
			
				int rnd2 = GetRandomUInt(1,3);
				TF2_RemoveWeaponSlot(client, 1);
				
				switch (rnd2)
				{
				case 1:
					{
						int rnd5 = GetRandomUInt(1,2);
						switch (rnd5)
						{
						case 1:
							{
								CreateWeapon(client, "tf_weapon_laser_pointer", 30668, 15);
							}
						case 2:
							{
								int rnd7 = GetRandomUInt(1,2);
								switch (rnd7)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_laser_pointer", 140, 6);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_laser_pointer", 1086, 6);
									}
								}
							}
						}
					}
				case 2:
					{
						CreateWeapon(client, "tf_weapon_mechanical_arm", 528, 6);
					}
				case 3:
					{
						int rnd3 = GetRandomUInt(1,3);
						switch (rnd3)
						{
						case 1:
							{
								int rnd7 = GetRandomUInt(1,2);
								switch (rnd7)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_pistol", 160, 3);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_pistol", 294, 6);
									}
								}
							}
						case 2:
							{
								CreateWeapon(client, "tf_weapon_pistol", 30666, 6);
							}
						case 3:
							{
								int rnd7 = GetRandomUInt(1,3);
								switch (rnd7)
								{
								case 1:
									{
										CreateWeapon(client, "tf_weapon_pistol", 23, 5);
									}
								case 2:
									{
										CreateWeapon(client, "tf_weapon_pistol", 209, 16);
									}
								case 3:
									{
										int rnd8 = GetRandomUInt(1, 13);
										switch (rnd8)
										{
										case 1:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15013, 15);
											}
										case 2:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15018, 15);
											}
										case 3:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15035, 15);
											}
										case 4:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15041, 15);
											}
										case 5:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15046, 15);
											}
										case 6:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15056, 15);
											}
										case 7:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15060, 15);
											}
										case 8:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15061, 15);
											}
										case 9:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15100, 15);
											}
										case 10:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15101, 15);
											}
										case 11:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15102, 15);
											}
										case 12:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15126, 15);
											}
										case 13:
											{
												CreateWeapon(client, "tf_weapon_pistol", 15148, 15);
											}
										}
									}
								}
							}
						}
					}
				}
				int rnd4 = GetRandomUInt(1,2);
				if(rnd4 == 1)
				{
					TF2_RemoveWeaponSlot(client, 3);				
					CreateWeapon(client, "tf_weapon_pda_engineer_build", 737, 11);
				}
				else
				{
					TF2_RemoveWeaponSlot(client, 3);				
					CreateWeapon(client, "tf_weapon_pda_engineer_build", 25, 6);
				}				
				
				TF2_RemoveWeaponSlot(client, 4);
				CreateWeapon(client, "tf_weapon_pda_engineer_destroy", 26, 6);					
			}
			int rnd3 = GetRandomUInt(1,5);
			TF2_RemoveWeaponSlot(client, 2);

			switch (rnd3)
			{
			case 1:
				{
					CreateWeapon(client, "tf_weapon_wrench", 155, 6);
				}
			case 2:
				{
					CreateWeapon(client, "tf_weapon_wrench", 142, 6);
				}
			case 3:
				{
					int rnd6 = GetRandomUInt(1,2);
					switch (rnd6)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_wrench", 329, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_wrench", 329, 16);
						}
					}
				}
			case 4:
				{
					int rnd5 = GetRandomUInt(1,3);
					switch (rnd5)
					{
					case 1:
						{
							CreateWeapon(client, "tf_weapon_wrench", 169, 6);
						}
					case 2:
						{
							CreateWeapon(client, "tf_weapon_wrench", 1123, 6);
						}
					case 3:
						{
							int rnd12 = GetRandomUInt(1,7);
							switch (rnd12)
							{
							case 1:
								{
									CreateWeapon(client, "tf_weapon_wrench", 662, 6);
								}
							case 2:
								{
									int rnd13 = GetRandomUInt(1,8);
									switch (rnd13)
									{
									case 1:
										{
											CreateWeapon(client, "tf_weapon_wrench", 795, 11);
										}
									case 2:
										{
											CreateWeapon(client, "tf_weapon_wrench", 804, 11);
										}
									case 3:
										{
											CreateWeapon(client, "tf_weapon_wrench", 884, 11);
										}
									case 4:
										{
											CreateWeapon(client, "tf_weapon_wrench", 893, 11);
										}
									case 5:
										{
											CreateWeapon(client, "tf_weapon_wrench", 902, 11);
										}
									case 6:
										{
											CreateWeapon(client, "tf_weapon_wrench", 911, 11);
										}
									case 7:
										{
											CreateWeapon(client, "tf_weapon_wrench", 960, 11);
										}
									case 8:
										{
											CreateWeapon(client, "tf_weapon_wrench", 969, 11);
										}
									}
								}
							case 3:
								{
									int rnd13 = GetRandomUInt(1,7);
									switch (rnd13)
									{
									case 1:
										{
											CreateWeapon(client, "tf_weapon_wrench", 15073, 15);
										}
									case 2:
										{
											CreateWeapon(client, "tf_weapon_wrench", 15074, 15);
										}
									case 3:
										{
											CreateWeapon(client, "tf_weapon_wrench", 15075, 15);
										}
									case 4:
										{
											CreateWeapon(client, "tf_weapon_wrench", 15139, 15);
										}
									case 5:
										{
											CreateWeapon(client, "tf_weapon_wrench", 15140, 15);
										}
									case 6:
										{
											CreateWeapon(client, "tf_weapon_wrench", 15114, 15);
										}
									case 7:
										{
											CreateWeapon(client, "tf_weapon_wrench", 15156, 15);
										}
									}
								}
							case 4:
								{
									CreateWeapon(client, "tf_weapon_wrench", 197, 9);
								}
							case 5:
								{
									CreateWeapon(client, "tf_weapon_wrench", 197, 16);
								}
							case 6:
								{
									CreateWeapon(client, "tf_weapon_wrench", 197, 11);
								}
							case 7:
								{
									CreateWeapon(client, "tf_weapon_wrench", 7, 5);
								}
							}
						}
					}
				}
			case 5:
				{
					CreateWeapon(client, "tf_weapon_wrench", 589, 6);
				}					
			}	
		}
	}
	
	return Plugin_Handled;
}

bool CreateWeapon(int client, char[] classname, int itemindex, int quality, int level = 0)
{
	int weapon = CreateEntityByName(classname);

	if (!IsValidEntity(weapon))
	{
		return false;
	}
	
	char entclass[64];
	GetEntityNetClass(weapon, entclass, sizeof(entclass));
	SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", itemindex);	 
	SetEntProp(weapon, Prop_Send, "m_bInitialized", 1);
	SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), quality);
	TF2Attrib_SetByDefIndex(weapon, 2025, 1.0);

	if (level)
	{
		SetEntProp(weapon, Prop_Send, "m_iEntityLevel", level);
	}
	else
	{
		SetEntProp(weapon, Prop_Send, "m_iEntityLevel", GetRandomUInt(1,100));
	}

	switch (itemindex)
	{
	case 25, 26:
		{
			DispatchSpawn(weapon);
			EquipPlayerWeapon(client, weapon); 

			return true; 			
		}
	case 735, 736, 810, 933, 1080, 1102:
		{
			SetEntProp(weapon, Prop_Send, "m_iObjectType", 3);
			SetEntProp(weapon, Prop_Data, "m_iSubType", 3);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 0);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 1);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 0, _, 2);
			SetEntProp(weapon, Prop_Send, "m_aBuildableObjectTypes", 1, _, 3);
		}	
	case 998:
		{
			SetEntProp(weapon, Prop_Send, "m_nChargeResistType", GetRandomUInt(0,2));
		}
	case 1071:
		{
			TF2Attrib_SetByName(weapon, "item style override", 0.0);
			TF2Attrib_SetByName(weapon, "loot rarity", 1.0);		
			TF2Attrib_SetByName(weapon, "turn to gold", 1.0);
			SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 11);			

			DispatchSpawn(weapon);
			EquipPlayerWeapon(client, weapon); 
			
			return true; 
		}
	case 1178:
		{
			SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4), 40, 4);
		}
	case 39,351,740,1081,997:
		{
			SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4), 16, 4);			
		}
	case 305,1079:
		{
			SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4), 38, 4);
		}
	case 56,1092,1005:
		{
			SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4), 12, 4);
		}
	case 130:
		{
			SetEntData(client, FindSendPropInfo("CTFPlayer", "m_iAmmo") + (GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4), 36, 4);
		}
	}

	if(quality == 9)
	{
		TF2Attrib_SetByName(weapon, "is australium item", 1.0);
		TF2Attrib_SetByName(weapon, "item style override", 1.0);
		SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 11);
		
		TF2Attrib_SetByDefIndex(weapon, 2025, 1.0);

		if (GetRandomUInt(1,5) == 1)
		{
			TF2Attrib_SetByDefIndex(weapon, 2025, 2.0);
			TF2Attrib_SetByDefIndex(weapon, 2014, GetRandomUInt(1,7) + 0.0);
		}
		else if (GetRandomUInt(1,5) == 2)
		{
			TF2Attrib_SetByDefIndex(weapon, 2025, 3.0);
			TF2Attrib_SetByDefIndex(weapon, 2014, GetRandomUInt(1,7) + 0.0);
			TF2Attrib_SetByDefIndex(weapon, 2013, GetRandomUInt(2002,2008) + 0.0);
		}
		
		TF2Attrib_SetByDefIndex(weapon, 214, view_as<float>(GetRandomUInt(0, 9000)));		
	}

	if(itemindex == 200 || itemindex == 220 || itemindex == 448 || itemindex == 15002 || itemindex == 15015 || itemindex == 15021 || itemindex == 15029 || itemindex == 15036 || itemindex == 15053 || itemindex == 15065 || itemindex == 15069 || itemindex == 15106 || itemindex == 15107 || itemindex == 15108 || itemindex == 15131 || itemindex == 15151 || itemindex == 15157 || itemindex == 449 || itemindex == 15013 || itemindex == 15018 || itemindex == 15035 || itemindex == 15041 || itemindex == 15046 || itemindex == 15056 || itemindex == 15060 || itemindex == 15061 || itemindex == 15100 || itemindex == 15101
			|| itemindex == 15102 || itemindex == 15126 || itemindex == 15148 || itemindex == 44 || itemindex == 221 || itemindex == 205 || itemindex == 228 || itemindex == 1104 || itemindex == 15006 || itemindex == 15014 || itemindex == 15028 || itemindex == 15043 || itemindex == 15052 || itemindex == 15057 || itemindex == 15081 || itemindex == 15104 || itemindex == 15105 || itemindex == 15129 || itemindex == 15130 || itemindex == 15150 || itemindex == 196 || itemindex == 447 || itemindex == 208 || itemindex == 215 || itemindex == 1178 || itemindex == 15005 || itemindex == 15017 || itemindex == 15030 || itemindex == 15034
			|| itemindex == 15049 || itemindex == 15054 || itemindex == 15066 || itemindex == 15067 || itemindex == 15068 || itemindex == 15089 || itemindex == 15090 || itemindex == 15115 || itemindex == 15141 || itemindex == 351 || itemindex == 740 || itemindex == 192 || itemindex == 214 || itemindex == 326 || itemindex == 206 || itemindex == 308 || itemindex == 996 || itemindex == 1151 || itemindex == 15077 || itemindex == 15079 || itemindex == 15091 || itemindex == 15092 || itemindex == 15116 || itemindex == 15117 || itemindex == 15142 || itemindex == 15158 || itemindex == 207 || itemindex == 130 || itemindex == 15009
			|| itemindex == 15012 || itemindex == 15024 || itemindex == 15038 || itemindex == 15045 || itemindex == 15048 || itemindex == 15082 || itemindex == 15083 || itemindex == 15084 || itemindex == 15113 || itemindex == 15137 || itemindex == 15138 || itemindex == 15155 || itemindex == 172 || itemindex == 327 || itemindex == 404 || itemindex == 202 || itemindex == 41 || itemindex == 312 || itemindex == 424 || itemindex == 15004 || itemindex == 15020 || itemindex == 15026 || itemindex == 15031 || itemindex == 15040 || itemindex == 15055 || itemindex == 15086 || itemindex == 15087 || itemindex == 15088 || itemindex == 15098
			|| itemindex == 15099 || itemindex == 15123 || itemindex == 15124 || itemindex == 15125 || itemindex == 15147 || itemindex == 425 || itemindex == 997 || itemindex == 197 || itemindex == 329 || itemindex == 15073 || itemindex == 15074 || itemindex == 15075 || itemindex == 15139 || itemindex == 15140 || itemindex == 15114 || itemindex == 15156 || itemindex == 305 || itemindex == 211 || itemindex == 15008 || itemindex == 15010 || itemindex == 15025 || itemindex == 15039 || itemindex == 15050 || itemindex == 15078 || itemindex == 15097 || itemindex == 15121 || itemindex == 15122 || itemindex == 15123 || itemindex == 15145
			|| itemindex == 15146 || itemindex == 35 || itemindex == 411 || itemindex == 37 || itemindex == 304 || itemindex == 201 || itemindex == 402 || itemindex == 15000 || itemindex == 15007 || itemindex == 15019 || itemindex == 15023 || itemindex == 15033 || itemindex == 15059 || itemindex == 15070 || itemindex == 15071 || itemindex == 15072 || itemindex == 15111 || itemindex == 15112 || itemindex == 15135 || itemindex == 15136 || itemindex == 15154 || itemindex == 203 || itemindex == 15001 || itemindex == 15022 || itemindex == 15032 || itemindex == 15037 || itemindex == 15058 || itemindex == 15076 || itemindex == 15110
			|| itemindex == 15134 || itemindex == 15153 || itemindex == 193 || itemindex == 401 || itemindex == 210 || itemindex == 15011 || itemindex == 15027 || itemindex == 15042 || itemindex == 15051 || itemindex == 15062 || itemindex == 15063 || itemindex == 15064 || itemindex == 15103 || itemindex == 15128 || itemindex == 15129 || itemindex == 15149 || itemindex == 194 || itemindex == 649 || itemindex == 15062 || itemindex == 15094 || itemindex == 15095 || itemindex == 15096 || itemindex == 15118 || itemindex == 15119 || itemindex == 15143 || itemindex == 15144 || itemindex == 209 || itemindex == 15013 || itemindex == 15018
			|| itemindex == 15035 || itemindex == 15041 || itemindex == 15046 || itemindex == 15056 || itemindex == 15060 || itemindex == 15061 || itemindex == 15100 || itemindex == 15101 || itemindex == 15102 || itemindex == 15126 || itemindex == 15148 || itemindex == 415 || itemindex == 15003 || itemindex == 15016 || itemindex == 15044 || itemindex == 15047 || itemindex == 15085 || itemindex == 15109 || itemindex == 15132 || itemindex == 15133 || itemindex == 15152 || itemindex == 1153)
	{
		if(GetRandomUInt(1,10) == 1)
		{
			TF2Attrib_SetByDefIndex(weapon, 2053, 1.0);
		}
	}
	
	if(quality == 11)
	{
		SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 11);
		
		TF2Attrib_SetByDefIndex(weapon, 2025, 1.0);

		if (GetRandomUInt(1,5) == 1)
		{
			TF2Attrib_SetByDefIndex(weapon, 2025, 2.0);
			TF2Attrib_SetByDefIndex(weapon, 2014, GetRandomUInt(1,7) + 0.0);
		}
		else if (GetRandomUInt(1,5) == 2)
		{
			TF2Attrib_SetByDefIndex(weapon, 2025, 3.0);
			TF2Attrib_SetByDefIndex(weapon, 2014, GetRandomUInt(1,7) + 0.0);
			TF2Attrib_SetByDefIndex(weapon, 2013, GetRandomUInt(2002,2008) + 0.0);
		}
		
		TF2Attrib_SetByDefIndex(weapon, 214, view_as<float>(GetRandomUInt(0, 9000)));
	}

	if (quality == 15)
	{
		switch(itemindex)
		{
		case 30665, 30666, 30667, 30668:
			{
				TF2Attrib_RemoveByDefIndex(weapon, 725);
			}
		default:
			{
				TF2Attrib_SetByDefIndex(weapon, 725, GetRandomFloat(0.0,1.0));
			}
		}
	}

	if (quality == 16)
	{
		quality = 14;
		int rndp = GetRandomUInt(1,152);
		switch(rndp)
		{
		case 1:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(102));
			}
		case 2:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(104));
			}
		case 3:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(106));
			}
		case 4:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(109));
			}
		case 5:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(113));
			}
		case 6:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(114));
			}
		case 7:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(122));
			}
		case 8:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(160));
			}
		case 9:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(139));
			}
		case 10:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(144));
			}
		case 11:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(130));
			}
		case 12:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(151));
			}
		case 13:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(105));
			}
		case 14:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(112));
			}
		case 15:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(120));
			}
		case 16:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(163));
			}
		case 17:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(143));
			}
		case 18:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(161));
			}
		case 19:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(301));
			}
		case 20:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(300));
			}
		case 21:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(304));
			}
		case 22:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(303));
			}
		case 23:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(308));
			}
		case 24:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(309));
			}
		case 25:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(302));
			}
		case 26:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(305));
			}
		case 27:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(306));
			}
		case 28:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(307));
			}
		case 29:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(310));
			}
		case 30:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(205));
			}
		case 31:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(207));
			}
		case 32:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(210));
			}
		case 33:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(212));
			}
		case 34:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(202));
			}
		case 35:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(204));
			}
		case 36:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(206));
			}
		case 37:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(209));
			}
		case 38:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(200));
			}
		case 39:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(201));
			}
		case 40:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(203));
			}
		case 41:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(208));
			}
		case 42:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(211));
			}
		case 43:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(213));
			}
		case 44:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(228));
			}
		case 45:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(230));
			}
		case 46:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(214));
			}
		case 47:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(225));
			}
		case 48:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(223));
			}
		case 49:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(218));
			}
		case 50:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(226));
			}
		case 51:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(234));
			}
		case 52:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(232));
			}
		case 53:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(220));
			}
		case 54:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(221));
			}
		case 55:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(217));
			}
		case 56:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(215));
			}
		case 57:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(390));
			}
		case 58:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(391));
			}
		case 59:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(241));
			}
		case 60:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(242));
			}
		case 61:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(243));
			}
		case 62:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(235));
			}
		case 63:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(237));
			}
		case 64:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(244));
			}
		case 65:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(236));
			}
		case 66:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(238));
			}
		case 67:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(239));
			}
		case 68:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(240));
			}
		case 69:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(254));
			}
		case 70:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(250));
			}
		case 71:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(247));
			}
		case 72:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(246));
			}
		case 73:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(245));
			}
		case 74:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(251));
			}
		case 75:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(252));
			}
		case 76:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(248));
			}
		case 77:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(249));
			}
		case 78:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(253));
			}
		case 79:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(257));
			}
		case 80:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(255));
			}
		case 81:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(259));
			}
		case 82:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(268));
			}
		case 83:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(260));
			}
		case 84:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(261));
			}
		case 85:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(264));
			}
		case 86:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(266));
			}
		case 87:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(256));
			}
		case 88:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(258));
			}
		case 89:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(262));
			}
		case 90:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(263));
			}
		case 91:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(265));
			}
		case 92:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(267));
			}
		case 93:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(269));
			}
		case 94:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(280));
			}
		case 95:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(281));
			}
		case 96:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(271));
			}
		case 97:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(283));
			}
		case 98:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(279));
			}
		case 99:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(272));
			}
		case 100:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(278));
			}
		case 101:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(277));
			}
		case 102:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(270));
			}
		case 103:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(273));
			}
		case 104:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(276));
			}
		case 105:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(282));
			}
		case 106:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(275));
			}
		case 107:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(287));
			}
		case 108:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(291));
			}
		case 109:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(294));
			}
		case 110:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(285));
			}
		case 111:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(289));
			}
		case 112:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(295));
			}
		case 113:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(297));
			}
		case 114:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(284));
			}
		case 115:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(286));
			}
		case 116:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(290));
			}
		case 117:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(292));
			}
		case 118:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(293));
			}
		case 119:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(296));
			}
		case 120:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(403));
			}
		case 121:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(400));
			}
		case 122:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(405));
			}
		case 123:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(404));
			}
		case 124:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(409));
			}
		case 125:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(410));
			}
		case 126:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(401));
			}
		case 127:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(402));
			}
		case 128:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(406));
			}
		case 129:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(407));
			}
		case 130:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(408));
			}
		case 131:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(411));
			}
		case 132:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(412));
			}
		case 133:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(413));
			}
		case 134:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(414));
			}
		case 135:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(415));
			}
		case 136:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(416));
			}
		case 137:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(417));
			}
		case 138:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(418));
			}
		case 139:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(419));
			}
		case 140:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(420));
			}
			case 141:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(421));
			}
		case 142:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(422));
			}
		case 143:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(423));
			}
		case 144:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(424));
			}
		case 145:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(425));
			}
		case 146:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(426));
			}
		case 147:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(427));
			}
		case 148:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(428));
			}
		case 149:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(429));
			}
		case 150:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(430));
			}
		case 151:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(431));
			}
		case 152:
			{
				TF2Attrib_SetByDefIndex(weapon, 834, view_as<float>(432));
			}
		}
		if (GetRandomUInt(1,8) < 7)
		{
			TF2Attrib_SetByDefIndex(weapon, 725, GetRandomFloat(0.0,1.0));		
		}
		
		SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 14);		
	}
	
	if (quality >0 && quality < 9)
	{
		int rnd4 = GetRandomUInt(1,4);
		switch (rnd4)
		{
		case 1:
			{
				SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 1);
			}
		case 2:
			{
				SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 3);
			}
		case 3:
			{
				SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 7);
			}
		case 4:
			{
				SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 11);
				if (GetRandomUInt(1,5) == 1)
				{
					TF2Attrib_SetByDefIndex(weapon, 2025, 1.0);
				}
				else if (GetRandomUInt(1,5) == 2)
				{
					TF2Attrib_SetByDefIndex(weapon, 2025, 2.0);
					TF2Attrib_SetByDefIndex(weapon, 2014, GetRandomUInt(1,7) + 0.0);
				}
				else if (GetRandomUInt(1,5) == 3)
				{
					TF2Attrib_SetByDefIndex(weapon, 2025, 3.0);
					TF2Attrib_SetByDefIndex(weapon, 2014, GetRandomUInt(1,7) + 0.0);
					TF2Attrib_SetByDefIndex(weapon, 2013, GetRandomUInt(2002,2008) + 0.0);
				}
				
				TF2Attrib_SetByDefIndex(weapon, 214, view_as<float>(GetRandomUInt(0, 9000)));
			}
		}
	}
	
	if (itemindex == 405 || itemindex == 608 || itemindex == 1101 || itemindex == 133 || itemindex == 444 || itemindex == 57 || itemindex == 231 || itemindex == 642 || itemindex == 131 || itemindex == 406 || itemindex == 1099 || itemindex == 1144)
	{
		DispatchSpawn(weapon);
		SDKCall(g_hEquipWearable, client, weapon);
		CreateTimer(0.1, TimerHealth, client);
	}
	else
	{
		DispatchSpawn(weapon);
		EquipPlayerWeapon(client, weapon); 
	}

	if (GetRandomUInt(1,20) == 1)
	{
		TF2Attrib_SetByName(weapon, "SPELL: Halloween death ghosts", 1.0);
	}
	
	if (GetRandomUInt(1,10) == 1)
	{
		if (itemindex == 21 || itemindex == 208 || itemindex == 40 || itemindex == 215 || itemindex == 594 || itemindex == 659 || itemindex == 741 || itemindex == 798 || itemindex == 807 || itemindex == 887 || itemindex == 896 || itemindex == 905 || itemindex == 914 || itemindex == 963 || itemindex == 972 || itemindex == 1146 || itemindex == 1178 || itemindex == 15005 || itemindex == 15017 || itemindex == 15030 || itemindex == 15034 || itemindex == 15049 || itemindex == 15054 || itemindex == 15066 || itemindex == 15067 || itemindex == 15068 || itemindex == 15089 || itemindex == 15090 || itemindex == 15115 || itemindex == 15141 || itemindex == 30474)
		{
			TF2Attrib_SetByName(weapon, "SPELL: Halloween green flames", 1.0);
		}
	}
	
	if (GetRandomUInt(1,10) == 1)
	{
		if (itemindex == 18 || itemindex == 205 || itemindex == 127 || itemindex == 228 || itemindex == 414 || itemindex == 513 || itemindex == 658 || itemindex == 730 || itemindex == 800 || itemindex == 809 || itemindex == 889 || itemindex == 898 || itemindex == 907 || itemindex == 916 || itemindex == 965 || itemindex == 974 || itemindex == 1085 || itemindex == 1104 || itemindex == 15006 || itemindex == 15014 || itemindex == 15028 || itemindex == 15043 || itemindex == 15052 || itemindex == 15057 || itemindex == 15081 || itemindex == 15104 || itemindex == 15105 || itemindex == 15129 || itemindex == 15130 || itemindex == 15150 || itemindex == 19 || itemindex == 206 || itemindex == 308 || itemindex == 996 || itemindex == 1007 || itemindex == 1151 || itemindex == 15077 || itemindex == 15079 || itemindex == 15091 || itemindex == 15092 || itemindex == 15116 || itemindex == 15117 || itemindex == 15142 || itemindex == 15158 || itemindex == 20 || itemindex == 207 || itemindex == 130 || itemindex == 661 || itemindex == 797 || itemindex == 806 || itemindex == 886 || itemindex == 895 || itemindex == 904 || itemindex == 913 || itemindex == 962 || itemindex == 971 || itemindex == 1150 || itemindex == 15009 || itemindex == 15012 || itemindex == 15024 || itemindex == 15038 || itemindex == 15045 || itemindex == 15048 || itemindex == 15082 || itemindex == 15083 || itemindex == 15084 || itemindex == 15113 || itemindex == 15137 || itemindex == 15138 || itemindex == 15155 || itemindex == 7 || itemindex == 197 || itemindex == 155 || itemindex == 169 || itemindex == 329 || itemindex == 423 || itemindex == 589 || itemindex == 662 || itemindex == 795 || itemindex == 804 || itemindex == 884 || itemindex == 893 || itemindex == 902 || itemindex == 911 || itemindex == 960 || itemindex == 969 || itemindex == 1071 || itemindex == 1123 || itemindex == 15073 || itemindex == 15074 || itemindex == 15075 || itemindex == 15139 || itemindex == 15140 || itemindex == 15114 || itemindex == 15156 || itemindex == 30758)
		{
			TF2Attrib_SetByName(weapon, "SPELL: Halloween pumpkin explosions", 1.0);
		}
	}
	
	if (GetRandomUInt(1,10) == 1)
	{
		if (TF2_GetPlayerClass(client) == TFClass_Medic)
		{
			TF2_SwitchtoSlot(client, 1);
		}
		else
		{
			TF2_SwitchtoSlot(client, 0);
		}
		
		SetEntData(weapon, FindSendPropInfo(entclass, "m_iEntityQuality"), 5);			
		int iRand = GetRandomUInt(1,4);
		if (iRand == 1)
		{
			TF2Attrib_SetByDefIndex(weapon, 134, 701.0);	
		}
		else if (iRand == 2)
		{
			TF2Attrib_SetByDefIndex(weapon, 134, 702.0);	
		}	
		else if (iRand == 3)
		{
			TF2Attrib_SetByDefIndex(weapon, 134, 703.0);	
		}
		else if (iRand == 4)
		{
			TF2Attrib_SetByDefIndex(weapon, 134, 704.0);	
		}
	}
	
	if (TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		TF2_SwitchtoSlot(client, 1);
	}
	else if (TF2_GetPlayerClass(client) == TFClass_Spy)
	{
		TF2_SwitchtoSlot(client, 2);
	}
	else if (TF2_GetPlayerClass(client) == TFClass_Heavy)
	{
		TF2_SwitchtoSlot(client, 2);
	}
	else if (TF2_GetPlayerClass(client) == TFClass_Pyro)
	{
		TF2_SwitchtoSlot(client, 2);
	}
	else if (TF2_GetPlayerClass(client) == TFClass_Scout)
	{
		TF2_SwitchtoSlot(client, 2);
	}
	else
	{
		TF2_SwitchtoSlot(client, 0);
	}
	
	return true;
}

public Action TimerHealth(Handle timer, any client)
{
	int hp = GetPlayerMaxHp(client);
	
	if (hp > 0)
	{
		SetEntityHealth(client, hp);
	}
	return Plugin_Handled;
}

int GetPlayerMaxHp(int client)
{
	if (!IsClientInGame(client))
	{
		return -1;
	}

	int entity = GetPlayerResourceEntity();

	if (entity == -1)
	{
		return -1;
	}

	return GetEntProp(entity, Prop_Send, "m_iMaxHealth", _, client);
}

bool IsPlayerHere(int client)
{
	if (client < 1 || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}
	
	return (client && IsClientInGame(client) && IsFakeClient(client));
}

int GetRandomUInt(int min, int max)
{
	return RoundToFloor(GetURandomFloat() * (max - min + 1)) + min;
}

stock void TF2_SwitchtoSlot(int client, int slot)
{
	if (slot >= 0 && slot <= 5 && IsClientInGame(client) && IsPlayerAlive(client))
	{
		char wepclassname[64];
		int wep = GetPlayerWeaponSlot(client, slot);
		if (wep > MaxClients && IsValidEdict(wep) && GetEdictClassname(wep, wepclassname, sizeof(wepclassname)))
		{
			FakeClientCommandEx(client, "use %s", wepclassname);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", wep);
		}
	}
}

stock bool IsWeaponSlotActive(int client, int slot)
{
    return GetPlayerWeaponSlot(client, slot) == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
}

stock void EquipWeaponSlot(const int client, const int slot)
{
	if (IsWeaponSlotActive(client, slot))
		return;

	int iWeapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(iWeapon))
		EquipWeapon(client, iWeapon);
}

stock void EquipWeapon(const int client, const int weapon)
{
	char class[80];
	GetEntityClassname(weapon, class, sizeof(class));
	Format(class, sizeof(class), "use %s", class);
	FakeClientCommand(client, class);
}

stock bool RealValidEntity(int entity)
{ return (entity > 0 && IsValidEntity(entity)); }
