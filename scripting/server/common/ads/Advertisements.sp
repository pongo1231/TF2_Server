#include <sourcemod>
#include <server/serverchat>

char ads[64][512];
int size = 0;
int pointer = 0;

public void OnPluginStart() {
    UpdateAds();
    CreateTimer(180.0, Timer_DisplayAd, _, TIMER_REPEAT);
}

public OnClientPostAdminCheck(int client) {
    if (IsFakeClient(client))
        return;

    Server_PrintToChat(client, "Server", "Welcome to the server! You can open the player menu via /menu.");
    Server_PrintToChat(client, "Server", "Also make sure to check out our steam group: steamcommunity.com/groups/duckyservers");
}

public Action Timer_DisplayAd(Handle timer) {
    if (!IsServerProcessing())
        return Plugin_Continue;

    Server_PrintToChatAll("Server", ads[pointer]);
    pointer++;

    if (pointer > size)
        pointer = 0;

    return Plugin_Handled;
}

void UpdateAds() {
    char path[PLATFORM_MAX_PATH];
    char line[256];
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
