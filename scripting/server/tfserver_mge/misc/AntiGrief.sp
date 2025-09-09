#include <sourcemod>
#include <sdktools>

#define CHECK_INTERVAL 0.1
#define REQUIRED_TIME 0.5

float g_vecMin[3] = { -4276.0, 7169.0, -1614.0 };
float g_vecMax[3] = { -2735.0, 8574.0, -544.0 };

float g_flInsideTime[MAXPLAYERS+1];
float g_flBuildingInsideTime[2049];

public void OnPluginStart()
{
    CreateTimer(CHECK_INTERVAL, Timer_CheckEntities, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_CheckEntities(Handle timer)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client) || IsFakeClient(client) || IsClientObserver(client))
            continue;

        float pos[3];
        GetClientAbsOrigin(client, pos);

        if (IsInsideBox(pos))
        {
            g_flInsideTime[client] += CHECK_INTERVAL;

            if (g_flInsideTime[client] >= REQUIRED_TIME)
            {
                ForcePlayerSuicide(client);
                g_flInsideTime[client] = 0.0;
            }
        }
        else
        {
            g_flInsideTime[client] = 0.0;
        }
    }

    int ent = -1;
    while ((ent = FindEntityByClassname(ent, "obj_*")) != -1)
    {
        if (!IsValidEdict(ent)) continue;

        float pos[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);

        if (IsInsideBox(pos))
        {
            g_flBuildingInsideTime[ent] += CHECK_INTERVAL;

            if (g_flBuildingInsideTime[ent] >= REQUIRED_TIME)
            {
                AcceptEntityInput(ent, "Kill");
                g_flBuildingInsideTime[ent] = 0.0;
            }
        }
        else
        {
            g_flBuildingInsideTime[ent] = 0.0;
        }
    }

    return Plugin_Continue;
}

bool IsInsideBox(float pos[3])
{
    return (pos[0] >= g_vecMin[0] && pos[0] <= g_vecMax[0] &&
            pos[1] >= g_vecMin[1] && pos[1] <= g_vecMax[1] &&
            pos[2] >= g_vecMin[2] && pos[2] <= g_vecMax[2]);
}
