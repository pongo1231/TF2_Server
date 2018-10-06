#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_helphelphelphelp_enabled", "0", "Enable plugin");
	CreateTimer(0.1, Timer_Spy, _, TIMER_REPEAT);
}

public Action Timer_Spy(Handle timer) {
	if (GetConVarBool(g_enabled))
		for (int i = 1; i < 33; i++)
			if (IsClientInGame(i) && IsFakeClient(i)) {
				FakeClientCommand(i, "voicemenu 2 0"); // HELP!
			}
}