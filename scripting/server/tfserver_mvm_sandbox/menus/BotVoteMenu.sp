#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_VoteMenu);
    menu.SetTitle("Bot settings");

    char text[128];

    Format(text, sizeof(text), "RCBot settings");
    menu.AddItem("bots_enable", text);

    Format(text, sizeof(text), "All bots do a voice command on damage (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_bothurtvoice_enabled")));
    menu.AddItem("bots_hurt", text);

    Format(text, sizeof(text), "Robots do a custom taunt on kill (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_bottaunt_enabled")));
    menu.AddItem("bots_taunt", text);

    Format(text, sizeof(text), "Robots only use melee (Silly) (Currently: %b)", GetConVarBool(FindConVar("tf_bot_melee_only")));
    menu.AddItem("mvm_bots_melee", text);

    Format(text, sizeof(text), "Robots are blind (Silly) (Currently: %b)", GetConVarBool(FindConVar("nb_blind")));
    menu.AddItem("mvm_bots_can_attack", text);

    Format(text, sizeof(text), "Kartrobots (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_kartbots_enabled")));
    menu.AddItem("mvm_bots_kartbots", text);

    Format(text, sizeof(text), "Robots are humans (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_robotshuman_enabled")));
    menu.AddItem("mvm_bots_kartbots", text);

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int client, int item) {
    if (action == MenuAction_Select)
        switch (item) {
            case 0:
                FakeClientCommand(client, "menu_bots_rcbot");
            case 1:
                Voting_CreateYesNoConVarVote(client, "sm_bothurtvoice_enabled", "Make bots do a voice command on damage? (Silly)");
            case 2:
                Voting_CreateYesNoConVarVote(client, "sm_bottaunt_enabled", "Make robots do a custom taunt on kill? (Silly)");
            case 3:
                Voting_CreateYesNoConVarVote(client, "tf_bot_melee_only", "Make robots use melee only? (Silly)");
            case 4:
                Voting_CreateYesNoConVarVote(client, "nb_blind", "Make robots blind? (Silly)");
            case 5:
                Voting_CreateYesNoConVarVote(client, "sm_kartbots_enabled", "Enable kartrobots? (Silly)");
            case 6:
                Voting_CreateYesNoConVarVote(client, "sm_robotshuman_enabled", "Make spawned robots human? (Silly)");
        }
    else if (action == MenuAction_End)
        delete menu;
}