#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_spyspyspyspy_enabled", "0", "Enable plugin");
	CreateTimer(0.1, Timer_Spy, _, TIMER_REPEAT);
}

public Action Timer_Spy(Handle timer) {
	if (GetConVarBool(g_enabled))
		for (int client = 1; client < MaxClients + 1; client++)
			if (IsClientInGame(client) && IsFakeClient(client)) {
				//FakeClientCommand(client, "voicemenu 2 0"); // HELP!
				FakeClientCommand(client, "voicemenu 1 1"); // SPY!
			}
}
