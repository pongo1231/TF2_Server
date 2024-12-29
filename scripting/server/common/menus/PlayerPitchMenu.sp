#include <sourcemod>
#include <server/serverchat>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

bool playing_mvm = false;

int players_pitch[MAXPLAYERS];

int GetRandomUInt(int min, int max)
{
    return RoundToFloor(GetURandomFloat() * (max - min + 1)) + min;
}

public void OnPluginStart() {
    RegConsoleCmd("menu_player_pitch", MenuOpen);
    AddNormalSoundHook(NormalSoundHook);
}

public void OnMapStart() {
	playing_mvm = GameRules_GetProp("m_bPlayingMannVsMachine") != 0;
}

public Action Delay_ResetPitch(Handle timer, int client) {
    if (IsFakeClient(client) && (!playing_mvm || TF2_GetClientTeam(client) == TFTeam_Red) && GetRandomUInt(1, 10) > 5)
        players_pitch[client - 1] = GetRandomUInt(10, 200);
    else
        players_pitch[client - 1] = 100;

    return Plugin_Handled;
}

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen) {
    CreateTimer(1.0, Delay_ResetPitch, client);

    return true;
}

public Action MenuOpen(int client, int args) {
    if (GetClientTeam(client) == 1) {
        Server_PrintToChat(client, "Menu", "You can't open the player pitch settings as a spectator.");
        return Plugin_Stop;
    }

    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Sound pitch");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    menu.AddItem("150", "Highest");
    menu.AddItem("125", "Higher");
    menu.AddItem("100", "Normal");
    menu.AddItem("75", "Lower");
    menu.AddItem("50", "Lowest");

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select) {
        char info[4];
        GetMenuItem(menu, item, info, sizeof(info));
        players_pitch[client - 1] = StringToInt(info);

        char text[32];
        Format(text, sizeof(text), "Pitch set to %s.", info);
        Server_PrintToChat(client, "Menu", text, true);
    }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu_player");
    } else if (action == MenuAction_End)
        delete menu;
}

public Action NormalSoundHook(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) {
    if (channel == SNDCHAN_VOICE && entity > 0 && entity < MaxClients + 1) {
        if (IsClientInGame(entity)) {
            if (players_pitch[entity - 1] == 0)
                pitch = 100;
            else
                pitch = players_pitch[entity - 1];

            flags |= SND_CHANGEPITCH;

            return Plugin_Changed;
        }
    }

    return Plugin_Continue;
}
