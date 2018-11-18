#include <sourcemod>
#include <tf2>
#include <sdktools_functions>

ConVar g_enabled;
ConVar g_spells_dropchance;
ConVar g_spells_rarechance;
ConVar g_spells_despawntime;
ArrayList spells;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_spells_enabled", "0", "Enable plugin");
	g_spells_dropchance = CreateConVar("sm_spells_dropchance", "10.0", "Chance for players to drop spell after death", _, true, 0.0, true, 100.0);
	g_spells_rarechance = CreateConVar("sm_spells_rarechance", "10.0", "Chance for rare spell drops", _, true, 0.0, true, 100.0);
	g_spells_despawntime = CreateConVar("sm_spells_despawntime", "30", "Time until spell disappears (in seconds)", _, true, 0.0);
	spells = CreateArray(2);

	HookEvent("player_death", Event_PlayerDeath);
	CreateTimer(1.0, Timer_SpellsTick, _, TIMER_REPEAT);
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	if (!GetConVarBool(g_enabled))
		return Plugin_Continue;

	if (GetRandomFloat(0.0, 100.0) < GetConVarFloat(g_spells_dropchance)) {
		int victim = GetClientOfUserId(GetEventInt(event, "userid"));
		int spell = CreateEntityByName("tf_spell_pickup")
		float playerPos[3];
		GetClientAbsOrigin(victim, playerPos);
		TeleportEntity(spell, playerPos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(spell, "Tier", GetRandomFloat(0.0, 100.0) <= GetConVarFloat(g_spells_rarechance) ? "1" : "0");
		DispatchKeyValue(spell, "AutoMaterialize", "0");
		DispatchSpawn(spell);
		int data[2];
		data[0] = spell;
		data[1] = GetConVarInt(g_spells_despawntime);
		PushArrayArray(spells, data);
	}

	return Plugin_Continue;
}

public Action Timer_SpellsTick(Handle timer) {
	for (int i = spells.Length - 1; i > -1; i--) {
		int spellData[3];
		GetArrayArray(spells, i, spellData);
		spellData[1]--;
		if (spellData[1] <= 0 || !IsValidEntity(spellData[0])) {
			if (IsValidEntity(spellData[0]))
				RemoveEntity(spellData[0]);
			spells.Erase(i);
			return;
		} else if (spellData[1] <= 10)
			SetEntityRenderFx(spellData[0], RENDERFX_PULSE_FAST);

		SetArrayArray(spells, i, spellData);
	}
}