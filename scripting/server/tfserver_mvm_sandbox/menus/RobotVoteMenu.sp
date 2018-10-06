#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_bots_robots", MenuOpen);
}

public Action MenuOpen(int client, int args) {
	Menu menu = new Menu(Handle_VoteMenu);
	menu.SetTitle("Robot settings");
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, false);

	char text[128];

	Format(text, sizeof(text), "Robots do a custom taunt on kill (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_bottaunt_enabled")));
	menu.AddItem("bots_taunt", text);

	Format(text, sizeof(text), "Robots only use melee (Silly) (Currently: %b)", GetConVarBool(FindConVar("tf_bot_melee_only")));
	menu.AddItem("mvm_bots_melee", text);

	Format(text, sizeof(text), "Robots are blind (Silly) (Currently: %b)", GetConVarBool(FindConVar("nb_blind")));
	menu.AddItem("mvm_bots_can_attack", text);

	Format(text, sizeof(text), "Robots are humans (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_robotshuman_enabled")));
	menu.AddItem("mvm_bots_kartbots", text);

	/*Format(text, sizeof(text), "Robots use noclip (Option 'Robots are aggressive' recommended) (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_noclipbots_enabled")));
	menu.AddItem("mvm_bots_noclipbots", text);*/

	Format(text, sizeof(text), "Robots are aggressive (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_chargebots_enabled")));
	menu.AddItem("bots_charge", text);

	Format(text, sizeof(text), "Robots use bumper cars (Silly) (Currently: %b)", GetConVarBool(FindConVar("sm_kartbots_enabled")));
	menu.AddItem("bots_bumpercart", text);

	menu.Display(client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_Select)
		switch (item) {
			case 0:
				Voting_CreateYesNoConVarVote(client, "sm_bottaunt_enabled", "Make robots do a custom taunt on kill? (Silly)");
			case 1:
				Voting_CreateYesNoConVarVote(client, "tf_bot_melee_only", "Make robots use melee only? (Silly)");
			case 2:
				Voting_CreateYesNoConVarVote(client, "nb_blind", "Make robots blind? (Silly)");
			case 3:
				Voting_CreateYesNoConVarVote(client, "sm_robotshuman_enabled", "Make spawned robots human? (Silly)");
			/*case 4:
				Voting_CreateYesNoConVarVote(client, "sm_noclipbots_enabled", "Make robots use noclip? (Option 'Bots are aggressive' recommended) (Silly)");*/
			case 4:
				Voting_CreateYesNoConVarVote(client, "sm_chargebots_enabled", "Make all robots aggressive? (Silly)");
			case 5:
				Voting_CreateYesNoConVarVote(client, "sm_kartbots_enabled", "Should all newly spawned robots use bumper cars? (Silly)");
		}
	else if (action == MenuAction_Cancel) {
        if (item == MenuCancel_ExitBack)
           FakeClientCommand(client, "menu_bots");
	} else if (action == MenuAction_End)
        delete menu;
}