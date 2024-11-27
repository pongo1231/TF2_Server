#include <sourcemod>
#include <server/serverchat>
#include <sdktools>

int players_pitch[32];

public void OnPluginStart() {
    RegConsoleCmd("menu_player_pitch", MenuOpen);
    AddNormalSoundHook(NormalSoundHook);
}

public bool OnClientConnect(int client, char[] rejectmsg, int maxlen) {
    players_pitch[client - 1] = 100;
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
    if (channel == SNDCHAN_VOICE && entity > 0 && entity < 33) {
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
