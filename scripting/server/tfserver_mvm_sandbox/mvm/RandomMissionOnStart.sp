#include <sourcemod>
#include <sdktools>

char g_chosenPop[PLATFORM_MAX_PATH];

public void OnMapStart()
{
    char map[64];
    GetCurrentMap(map, sizeof(map));

    ArrayList popfiles = new ArrayList(PLATFORM_MAX_PATH);
    CollectPopfilesForMap("custom/default_missions/scripts/population", map, popfiles);
    CollectPopfilesForMap("custom/custom_missions/scripts/population", map, popfiles);

    if (popfiles.Length > 0)
    {
        int index = GetRandomInt(0, popfiles.Length - 1);
        popfiles.GetString(index, g_chosenPop, sizeof(g_chosenPop));
        ServerCommand("tf_mvm_popfile \"%s\"", g_chosenPop);
    }

    delete popfiles;
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
            char basename[PLATFORM_MAX_PATH];
            strcopy(basename, sizeof(basename), filename);

            int ext = StrContains(basename, ".pop", false);
            if (ext != -1)
            {
                basename[ext] = '\0';
            }

            popfiles.PushString(basename);
        }
    }

    delete dir;
}
