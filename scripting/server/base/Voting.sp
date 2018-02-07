#include <sourcemod>
#include <server/serverchat>

char convar_name[256];
int true_value;
int false_value;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
   CreateNative("Voting_CreateBoolConVarVote", Voting_CreateBoolConVarVote);
   CreateNative("Voting_CreateConVarVote", Voting_CreateConVarVote);
   CreateNative("Voting_CreateBoolCommandVote", Voting_CreateBoolCommandVote);
   return APLRes_Success;
}

public int Voting_CreateBoolConVarVote(Handle plugin, int numParams) {
    GetNativeString(1, convar_name, sizeof(convar_name));
    char question[128];
    GetNativeString(2, question, sizeof(question));
    true_value = GetNativeCell(3);
    false_value = GetNativeCell(4);

    Menu menu = new Menu(Handle_BoolVoting);
    menu.SetTitle(question);
    menu.AddItem("yes", "Yes");
    menu.AddItem("no", "No");
    menu.ExitButton = false;
    menu.DisplayVoteToAll(20);
    Server_PrintToChatAll("Vote", "A vote has been started.");
}

public int Handle_BoolVoting(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_VoteEnd) {
    	int value = false_value;
    	if (param1 == 0) // yes = 0
    		value = true_value;

    	SetConVarInt(FindConVar(convar_name), value);
        char text[128];
        Format(text, sizeof(text), "%s has been set to %i.", convar_name, value);
    	Server_PrintToChatAll("Vote", text);
	}
    else if (action == MenuAction_VoteCancel)
    	return;
    else if (action == MenuAction_End)
        delete menu;
}

public int Voting_CreateConVarVote(Handle plugin, int numParams) {
    GetNativeString(1, convar_name, sizeof(convar_name));

    char question[128];
    GetNativeString(2, question, sizeof(question));

    Menu menu = new Menu(Handle_Voting);
    menu.SetTitle(question);

    for (int i = 3; i <= numParams; i++) {
        char value[32];
        GetNativeString(i, value, sizeof(value));
        menu.AddItem(value, value);
    }
    menu.ExitButton = false;
    menu.DisplayVoteToAll(20);
    Server_PrintToChatAll("Vote", "A vote has been started.");
}

public int Handle_Voting(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_VoteEnd) {
        char value[32];
        menu.GetItem(param1, value, sizeof(value));

        SetConVarString(FindConVar(convar_name), value);
        char text[128];
        Format(text, sizeof(text), "%s has been set to %s.", convar_name, value);
        Server_PrintToChatAll("Vote", text);
    }
    else if (action == MenuAction_VoteCancel)
        return;
    else if (action == MenuAction_End)
        delete menu;
}

public int Voting_CreateBoolCommandVote(Handle plugin, int numParams) {
    GetNativeString(1, convar_name, sizeof(convar_name));

    char question[128];
    GetNativeString(2, question, sizeof(question));

    Menu menu = new Menu(Handle_BoolCommandVoting);
    menu.SetTitle(question);
    menu.AddItem("yes", "Yes");
    menu.AddItem("no", "No");
    menu.ExitButton = false;
    menu.DisplayVoteToAll(20);
    Server_PrintToChatAll("Vote", "A vote has been started.");
}

public int Handle_BoolCommandVoting(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_VoteEnd) {
        char result_text[] = "Vote For %s Has Failed.";
        if (param1 == 0) {
            ServerCommand(convar_name);
            result_text = "%s has been executed.";
        }

        char text[128];
        Format(text, sizeof(text), result_text, convar_name);
        Server_PrintToChatAll("Vote", text);
    }
    else if (action == MenuAction_VoteCancel)
        return;
    else if (action == MenuAction_End)
        delete menu;
}