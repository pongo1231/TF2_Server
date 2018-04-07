#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

char base_hostname[] = "DuckyServers EU | Freak Fortress 2"
ConVar g_hostname;

public void OnPluginStart() {
	g_hostname = FindConVar("hostname");
	CreateTimer(15.0, UpdateHostname);
}

public void OnMapStart() {
	CreateTimer(15.0, UpdateHostname);
}

public Action UpdateHostname(Handle timer) {
	char hostname[128];

	char mapname[64];
	char gamemode[16];
	GetCurrentMap(mapname, sizeof(mapname));
	if (SplitString(mapname, "_", gamemode, sizeof(gamemode)) == -1)
		Format(hostname, sizeof(hostname), "%s [%s]", base_hostname, mapname);
	else {
		Format(hostname, sizeof(hostname), "%s [%s, %s]", base_hostname, gamemode, mapname);
	}

	SetConVarString(g_hostname, hostname);
}