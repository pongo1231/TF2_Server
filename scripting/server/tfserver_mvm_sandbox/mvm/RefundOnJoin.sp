#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

ConVar enabled;
ConVar refund_on_change_class;
bool playing_mvm = false;

public void OnPluginStart() {
	enabled = CreateConVar("sm_refundonjoin_enabled", "0", "Enable plugin");
	refund_on_change_class = CreateConVar("sm_refundonjoin_changeclass", "0", "Refund on class change too");

	HookEvent("player_changeclass", EventPlayerChangeClass_Pre, EventHookMode_Pre);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != -1;
}

void RefundUpgradesForClient(int client) {
	KeyValues respec = new KeyValues("MVM_Respec");

	bool inUpgradeZone = GetEntProp(client, Prop_Send, "m_bInUpgradeZone") != 0;
	if (!inUpgradeZone)
		SetEntProp(client, Prop_Send, "m_bInUpgradeZone", 1);

	FakeClientCommandKeyValues(client, respec);

	if (!inUpgradeZone)
		SetEntProp(client, Prop_Send, "m_bInUpgradeZone", 0);

	delete respec;
}

public void OnClientPutInServer(int client) {
	if (!playing_mvm || !GetConVarBool(enabled))
		return;

	RefundUpgradesForClient(client);
}

public Action EventPlayerChangeClass_Pre(Handle event, const char[] name, bool dontBroadcast) {
	if (!playing_mvm || !GetConVarBool(enabled) || !GetConVarBool(refund_on_change_class))
		return Plugin_Continue;

	RefundUpgradesForClient(GetClientOfUserId(GetEventInt(event, "userid")));

	return Plugin_Handled;
}
