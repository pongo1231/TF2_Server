#include <sourcemod>
#include <server/serverchat>

char ads[64][256];
int size = 0;
int pointer = 0;

public void OnPluginStart() {
	UpdateAds();
	CreateTimer(180.0, Timer_DisplayAd, _, TIMER_REPEAT);
}

public OnClientPostAdminCheck(int client) {
	Server_PrintToChat(client, "Server", "Welcome To The Server! You Can Open The Player Menu Via /menu.");
}

public Action Timer_DisplayAd(Handle timer) {
	Server_PrintToChatAll("Server", ads[pointer]);
	pointer++;

	if (pointer > size)
		pointer = 0;
}

void UpdateAds() {
	char path[PLATFORM_MAX_PATH];
	char line[128];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "plugins/server/ads/advertisements.txt");

	Handle fileHandle = OpenFile(path, "r");
	int i = 0;
	while (!IsEndOfFile(fileHandle) && ReadFileLine(fileHandle, line, sizeof(line))) {
		ads[i] = line;
		i++;
	}
	size = i - 1;

	delete fileHandle;
}