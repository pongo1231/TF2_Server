#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

bool playing_mvm = false;

void RemoveSpellFromClient(int client) {
    int spell_book = -1;
    while ((spell_book = FindEntityByClassname(spell_book, "tf_weapon_spellbook")) != INVALID_ENT_REFERENCE) {
        if (GetEntPropEnt(spell_book, Prop_Send, "m_hOwnerEntity") == client)
            break;
    }

    if (!IsValidEntity(spell_book))
        return;

    SetEntProp(spell_book, Prop_Send, "m_iSelectedSpellIndex", -1);
    SetEntProp(spell_book, Prop_Send, "m_iSpellCharges", 0);
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    RemoveSpellFromClient(client);

    return Plugin_Continue;
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast) {
    if (playing_mvm)
        return Plugin_Continue;

    for (int client = 1; client < MaxClients; client++) {
        if (IsClientInGame(client))
            RemoveSpellFromClient(client);
    }

    return Plugin_Continue;
}

public Action Event_OnMvMRoundEnd(Handle event, const char[] name, bool dontBroadcast) {
    for (int client = 1; client < MaxClients; client++) {
        if (IsClientInGame(client))
            RemoveSpellFromClient(client);
    }

    return Plugin_Continue;
}

public void OnPluginStart() {
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("teamplay_round_active", Event_OnRoundStart);
    HookEvent("mvm_wave_complete", Event_OnMvMRoundEnd);
}

public void OnMapStart() {
    playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != 0;
}
