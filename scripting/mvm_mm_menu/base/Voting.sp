#include <sourcemod>
#include <server/serverchat>

const int countdown = 15;

ConVar g_convar;
ConVar g_convar2;
int true_value;
int false_value;
bool vote_success = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
   CreateNative("Voting_CreateYesNoConVarVote", Voting_CreateYesNoConVarVote);
   CreateNative("Voting_CreateStringConVarVote", Voting_CreateStringConVarVote);
   CreateNative("Voting_CreateYesNoCommandVote", Voting_CreateYesNoCommandVote);
   return APLRes_Success;
}

public int Voting_CreateYesNoConVarVote(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if (IsVoteRunning()) {
        WarnClientVoteRunning(client);
        return;
    }

    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    char convar_name[128];
    GetNativeString(2, convar_name, sizeof(convar_name));
    g_convar = FindConVar(convar_name);

    char question[128];
    GetNativeString(3, question, sizeof(question));
    true_value = GetNativeCell(4);
    false_value = GetNativeCell(5);

    char text[128];
    Format(text, sizeof(text), "A vote has been started by %s.", client_name);

    Menu menu = new Menu(Handle_YesNoVoting);
    menu.SetTitle(question);
    menu.AddItem("yes", "Yes");
    menu.AddItem("no", "No");
    menu.ExitButton = false;
    menu.DisplayVoteToAll(countdown);
    Server_PrintToChatAll("Vote", text);
}

public int Handle_YesNoVoting(Menu menu, MenuAction action, int choice, int param2) {
    if (action == MenuAction_VoteEnd) {
        int value = false_value;
        if (choice == 0) // yes = 0
            value = true_value;

        char value_string[8];
        IntToString(value, value_string, sizeof(value_string));
        SetConVar(g_convar, value_string);
    } else if (action == MenuAction_End) {
        ClearVote();
        delete menu;
    }
}

public int Voting_CreateStringConVarVote(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if (IsVoteRunning()) {
        WarnClientVoteRunning(client);
        return;
    }

    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    char convar_name[128];
    GetNativeString(2, convar_name, sizeof(convar_name));
    g_convar = FindConVar(convar_name);

    char question[128];
    GetNativeString(3, question, sizeof(question));

    char text[128];
    Format(text, sizeof(text), "A vote has been started by %s.", client_name);

    Menu menu = new Menu(Handle_StringVoting);
    menu.SetTitle(question);

    for (int i = 4; i <= numParams; i++) {
        char value[32];
        GetNativeString(i, value, sizeof(value));
        menu.AddItem(value, value);
    }
    menu.ExitButton = false;
    menu.DisplayVoteToAll(countdown);
    Server_PrintToChatAll("Vote", text);
}

public int Handle_StringVoting(Menu menu, MenuAction action, int param1, int choice) {
    if (action == MenuAction_VoteEnd) {
        char value[32];
        menu.GetItem(choice, value, sizeof(value));
        SetConVar(g_convar, value);
    } else if (action == MenuAction_End) {
        ClearVote();
        delete menu;
    }
}

public int Voting_CreateYesNoCommandVote(Handle plugin, int numParams) {
    int client = GetNativeCell(1);
    if (IsVoteRunning()) {
        WarnClientVoteRunning(client);
        return;
    }

    char client_name[64];
    GetClientName(client, client_name, sizeof(client_name));

    char convar_name[128];
    GetNativeString(2, convar_name, sizeof(convar_name));
    g_convar = FindConVar(convar_name);

    char question[128];
    GetNativeString(3, question, sizeof(question));

    char convar_name2[128];
    GetNativeString(4, convar_name2, sizeof(convar_name2));
    if (convar_name2[0])
        g_convar2 = FindConVar(convar_name2);

    char text[128];
    Format(text, sizeof(text), "A vote has been started by %s.", client_name);

    Menu menu = new Menu(Handle_YesNoCommandVoting);
    menu.SetTitle(question);
    menu.AddItem("yes", "Yes");
    menu.AddItem("no", "No");
    menu.ExitButton = false;
    menu.DisplayVoteToAll(countdown);
    Server_PrintToChatAll("Vote", text);
}

public int Handle_YesNoCommandVoting(Menu menu, MenuAction action, int param1, int choice) {
    if (action == MenuAction_VoteEnd) {
        char text[128];
        char convar_name[64];
        GetConVarName(g_convar, convar_name, sizeof(convar_name));
        if (choice == 0) {
            ServerCommand(convar_name);
            Format(text, sizeof(text), "%s has been executed.", convar_name);
        } else if (choice == 1) {
            if (g_convar2) {
                char convar_name2[64];
                GetConVarName(g_convar2, convar_name2, sizeof(convar_name2));
                ServerCommand(convar_name2);
                Format(text, sizeof(text), "%s has been executed.", convar_name2);
            } else
                Format(text, sizeof(text), "Vote for %s has failed.", convar_name);
        }
        Server_PrintToChatAll("Vote", text);
    } else if (action == MenuAction_End) {
        ClearVote();
        delete menu;
    }
}

bool IsVoteRunning() {
    return g_convar || g_convar2;
}

void ClearVote() {
    g_convar = null;
    g_convar2 = null;

    if (!vote_success)
        Server_PrintToChatAll("Vote", "No votes received; Vote failed.");
    vote_success = false;
}

void SetConVar(ConVar cvar, char[] newValue) {
    char text[128];
    char oldValue[8];
    GetConVarString(cvar, oldValue, sizeof(oldValue));
    char convar_name[64];
    GetConVarName(cvar, convar_name, sizeof(convar_name));
    if (StrEqual(oldValue, newValue))
        Format(text, sizeof(text), "%s has been left unchanged. (%s)", convar_name, newValue);
    else {
        SetConVarString(g_convar, newValue);
        Format(text, sizeof(text), "%s has been set to %s.", convar_name, newValue);
    }

    Server_PrintToChatAll("Vote", text);
    vote_success = true;
}

void WarnClientVoteRunning(int client) {
    Server_PrintToChat(client, "Vote", "A vote is already in progress.");
}