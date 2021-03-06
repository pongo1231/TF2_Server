#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_server", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Server settings");
    SetMenuExitBackButton(menu, true);
    SetMenuExitButton(menu, false);

    char text[128];

    menu.AddItem("server_silly", "Silly settings");

    int halloween_mode = GetConVarInt(FindConVar("tf_forced_holiday"));
    // tf_forced_holiday 2 is Halloween Mode
    if (halloween_mode == 2)
        halloween_mode = 1;
    Format(text, sizeof(text), "Halloween mode (Currently: %i)", halloween_mode);
    menu.AddItem("server_halloween", text);

    Format(text, sizeof(text), "Instant Respawn (Currently: %i)", GetConVarInt(FindConVar("mp_disable_respawn_times")));
    menu.AddItem("server_instant_respawn", text);

    menu.Display(client, MENU_TIME_FOREVER);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                FakeClientCommand(client, "menu_server_silly");
            case 1:
                Voting_CreateYesNoConVarVote(client, "tf_forced_holiday", "Enable halloween mode?", 2, 0);
            case 2:
                Voting_CreateYesNoConVarVote(client, "mp_disable_respawn_times", "Enable instant respawning?");
        }
    else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu");
    } else if (action == MenuAction_End)
        delete menu;
}