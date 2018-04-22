#include <sourcemod>

Handle hudSync;
char hostname[64];

public void OnPluginStart() {
	SetHudTextParams(0.01, 0.01, 15.0 , 0, 153, 0, 127, 2, 0.1, 0.1, strlen(hostname) * 0.1);
	hudSync = CreateHudSynchronizer();
	CreateTimer(15.0, Timer_ShowHudText, _, TIMER_REPEAT);
	GetConVarString(FindConVar("hostname"), hostname, sizeof(hostname));
}

public Action Timer_ShowHudText(Handle timer) {
	for (int i = 1; i < GetMaxClients() + 1; i++)
		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
			ShowSyncHudText(i, hudSync, hostname);
}


public void OnPluginEnd() {
	delete hudSync;
}