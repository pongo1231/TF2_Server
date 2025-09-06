#include <sourcemod>
#include <sdktools>

char g_chosenPop[PLATFORM_MAX_PATH];

public void OnMapStart()
{
    char map[64];
    GetCurrentMap(map, sizeof(map));

    ArrayList popfiles = new ArrayList(PLATFORM_MAX_PATH);
    CollectPopfilesForMap("scripts/population", map, popfiles);
    CollectPopfilesForMap("custom/custom_missions/scripts/population", map, popfiles);

    if (popfiles.Length > 0)
    {
        int index = GetRandomInt(0, popfiles.Length - 1);
        popfiles.GetString(index, g_chosenPop, sizeof(g_chosenPop));
        CreateTimer(5.0, Timer_SetPopfile, _, TIMER_FLAG_NO_MAPCHANGE);
    }
    delete popfiles;
}

public Action Timer_SetPopfile(Handle timer, any data)
{
    ServerCommand("tf_mvm_popfile \"%s\"", g_chosenPop);
    return Plugin_Stop;
}

void CollectPopfilesForMap(const char[] path, const char[] map, ArrayList popfiles)
{
    DirectoryListing dir = OpenDirectory(path);
    if (dir == null) return;

    char filename[PLATFORM_MAX_PATH];
    while (ReadDirEntry(dir, filename, sizeof(filename)))
    {
        if (StrContains(filename, map, false) != -1 && StrContains(filename, ".pop", false) != -1)
        {
            char fullpath[PLATFORM_MAX_PATH];
            Format(fullpath, sizeof(fullpath), "%s/%s", path, filename);
            popfiles.PushString(fullpath);
        }
    }
    delete dir;
}
