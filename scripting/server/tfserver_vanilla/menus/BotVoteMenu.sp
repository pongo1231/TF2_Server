#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_Menu);
    menu.SetTitle("Bot settings");

    char text[128];

    Format(text, sizeof(text), "Enable bots");
    menu.AddItem("bots_enable", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                Voting_CreateYesNoCommandVote(client, "rcbot_bot_quota_interval 1", "Enable bots?", "rcbot_bot_quota_interval 0; sm_kick @bots");
        }
    else if (action == MenuAction_End)
        delete menu;
}