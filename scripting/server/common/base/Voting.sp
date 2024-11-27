#include <sourcemod>
#include <sdktools>
#include <server/serverchat>

const int countdown = 15;

ConVar g_convar;
char command_name[64];
char command2_name[64];
int true_value;
int false_value;
bool vote_success = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
   CreateNative("Voting_CreateYesNoConVarVote", Voting_CreateYesNoConVarVote);
   CreateNative("Voting_CreateStringConVarVote", Voting_CreateStringConVarVote);
   CreateNative("Voting_CreateYesNoCommandVote", Voting_CreateYesNoCommandVote);
   return APLRes_Success;
}

public void OnMapStart() {
	PrecacheSound("ui/vote_started.wav");
	PrecacheSound("ui/vote_success.wav");
	PrecacheSound("ui/vote_failure.wav");
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
    Server_PrintToChatAll("Vote", text, true);

    EmitSoundToAll("ui/vote_started.wav");
}

public int Handle_YesNoVoting(Menu menu, MenuAction action, int choice, int param2) {
    if (action == MenuAction_VoteEnd) {
        int value;
        if (choice == 1) { // no = 1
            value = false_value;
            EmitSoundToAll("ui/vote_failure.wav");
        } else if (choice == 0) { // yes = 0
            value = true_value;
            EmitSoundToAll("ui/vote_success.wav");
        }

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
    Server_PrintToChatAll("Vote", text, true);

    EmitSoundToAll("ui/vote_started.wav");
}

public int Handle_StringVoting(Menu menu, MenuAction action, int choice, int param2) {
    if (action == MenuAction_VoteEnd) {
        char value[32];
        menu.GetItem(choice, value, sizeof(value));
        SetConVar(g_convar, value);
        EmitSoundToAll("ui/vote_success.wav");
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

    GetNativeString(2, command_name, sizeof(command_name));

    char question[128];
    GetNativeString(3, question, sizeof(question));

    GetNativeString(4, command2_name, sizeof(command2_name));

    char text[128];
    Format(text, sizeof(text), "A vote has been started by %s.", client_name);

    Menu menu = new Menu(Handle_YesNoCommandVoting);
    menu.SetTitle(question);
    menu.AddItem("yes", "Yes");
    menu.AddItem("no", "No");
    menu.ExitButton = false;
    menu.DisplayVoteToAll(countdown);
    Server_PrintToChatAll("Vote", text, true);

    EmitSoundToAll("ui/vote_started.wav");
}

public int Handle_YesNoCommandVoting(Menu menu, MenuAction action, int choice, int param2) {
    if (action == MenuAction_VoteEnd) {
        char text[128];
        if (choice == 0) {
            ServerCommand(command_name);
            Format(text, sizeof(text), "%s has been executed.", command_name);
            EmitSoundToAll("ui/vote_success.wav");
        } else if (choice == 1)
            if (command2_name[0]) {
                ServerCommand(command2_name);
                Format(text, sizeof(text), "%s has been executed.", command2_name);
                EmitSoundToAll("ui/vote_success.wav");
            } else {
                Format(text, sizeof(text), "Vote for %s has failed.", command_name);
                EmitSoundToAll("ui/vote_failure.wav");
            }
        Server_PrintToChatAll("Vote", text, true);
        vote_success = true;
    } else if (action == MenuAction_End) {
        ClearVote();
        delete menu;
    }
}

bool IsVoteRunning() {
    return g_convar || command_name[0] || command2_name[0];
}

void ClearVote() {
    g_convar = null;
    command_name = "";
    command2_name = "";

    if (!vote_success)
        Server_PrintToChatAll("Vote", "No votes received; Vote failed.", true);
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

    Server_PrintToChatAll("Vote", text, true);
    vote_success = true;
}

void WarnClientVoteRunning(int client) {
    Server_PrintToChat(client, "Vote", "A vote is already in progress.", true);
}
