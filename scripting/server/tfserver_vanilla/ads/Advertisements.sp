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
	Server_PrintToChat(client, "Server", "Welcome to the server! You can open the player menu via /menu.");
	Server_PrintToChat(client, "Server", "Also make sure to check out our steam group: steamcommunity.com/groups/duckyservers");
	Server_PrintToChat(client, "Server", "Type /rank to see your stats.");
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
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "configs/advertisements.txt");

	Handle fileHandle = OpenFile(path, "r");
	int i = 0;
	while (!IsEndOfFile(fileHandle) && ReadFileLine(fileHandle, line, sizeof(line))) {
		ads[i] = line;
		i++;
	}
	size = i - 1;

	delete fileHandle;
}