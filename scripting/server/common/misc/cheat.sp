#include <sourcemod>

public void OnPluginStart() {
	RegAdminCmd("sm_cheat", Handle_Cheat, ADMFLAG_ROOT);
	RegAdminCmd("cheat", Handle_Cheat, ADMFLAG_ROOT);
}

public Action Handle_Cheat(int client, int args) {
	char cmd[512];
	GetCmdArgString(cmd, sizeof(cmd));

	ConVar sv_cheats = FindConVar("sv_cheats");
	bool enabled = GetConVarBool(sv_cheats);
	int flags = GetConVarFlags(sv_cheats);

	if (!enabled) {
		SetConVarFlags(sv_cheats, FCVAR_NONE);
		SetConVarBool(sv_cheats, true);
	}
	FakeClientCommand(client, cmd);
	if (!enabled) {
		SetConVarBool(sv_cheats, false);
		SetConVarFlags(sv_cheats, flags);
	}

	return Plugin_Handled;
}