#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

public Plugin info = {
	name = "RemoveSpellOnDeath",
	author = "pongo1231",
	description = "Removes player spell on death",
	version = "1.0",
	url = "gopong.dev"
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    int spell_book = -1;
    while ((spell_book = FindEntityByClassname(spell_book, "tf_weapon_spellbook")) != INVALID_ENT_REFERENCE) {
        if (GetEntPropEnt(spell_book, Prop_Send, "m_hOwnerEntity") == victim)
            break;
    }

    if (spell_book == INVALID_ENT_REFERENCE)
        return Plugin_Continue;

    SetEntProp(spell_book, Prop_Send, "m_iSelectedSpellIndex", 0);
    SetEntProp(spell_book, Prop_Send, "m_iSpellCharges", 0);

	return Plugin_Continue;
}

public void OnPluginStart() {
	HookEvent("player_death", Event_PlayerDeath);
}
