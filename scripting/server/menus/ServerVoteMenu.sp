#include <sourcemod>
#include <server/voting>
#include <server/serverchat>
#include <tf2>
#include <tf2_stocks>

public void OnPluginStart() {
    RegConsoleCmd("menu_server", MenuOpen);
}

public Action MenuOpen(int client, int args) {
    Menu menu = new Menu(Handle_ServerVoteMenu);
    menu.SetTitle("Server Settings");

    char text[128];

    menu.AddItem("server_silly", "Silly settings");

    menu.AddItem("server_scramble_teams", "Scramble teams");

    bool instant_respawn = GetConVarBool(FindConVar("mp_disable_respawn_times"));
    Format(text, sizeof(text), "Instant respawn (Currently: %b)", instant_respawn);
    menu.AddItem("server_instant_respawn", text);

    int halloween_mode = GetConVarInt(FindConVar("tf_forced_holiday"));
    // tf_forced_holiday 2 is Halloween Mode
    if (halloween_mode == 2)
        halloween_mode = 1;
    Format(text, sizeof(text), "Halloween mode (Currently: %i)", halloween_mode);
    menu.AddItem("server_halloween", text);

    bool random_crits = GetConVarBool(FindConVar("tf_weapon_criticals"));
    Format(text, sizeof(text), "Random crits (Currently: %b)", random_crits);
    menu.AddItem("server_random_crits", text);

    int crits_on_cap = GetConVarInt(FindConVar("tf_ctf_bonus_time"));
    Format(text, sizeof(text), "Crits on capture time (CTF) (Currently: %i)", crits_on_cap);
    menu.AddItem("server_crits_on_cap", text);

    int flag_caps_to_win = GetConVarInt(FindConVar("tf_flag_caps_per_round"));
    Format(text, sizeof(text), "Flag captures to win (CTF) (Currently: %i)", flag_caps_to_win);
    menu.AddItem("server_flag_caps_to_win", text);

    menu.AddItem("server_rock_the_vote", "Change Map (Rock The Vote)");

    menu.Display(client, 20);
 
    return Plugin_Handled;
}

public int Handle_ServerVoteMenu(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select)
        switch (param2) {
            case 0:
                FakeClientCommand(param1, "menu_server_silly");
            case 1:
                if (GameRules_GetProp("m_bPlayingMannVsMachine"))
                    Server_PrintToChat(param1, "Menu", "Can't scramble teams in MvM.");
                else
                    Voting_CreateBoolCommandVote("mp_scrambleteams", "Scramble teams?");
            case 2:
                Voting_CreateBoolConVarVote("mp_disable_respawn_times", "Enable instant respawn?");
            case 3:
                Voting_CreateBoolConVarVote("tf_forced_holiday", "Enable halloween mode?", 2, 0);
            case 4:
                Voting_CreateBoolConVarVote("tf_weapon_criticals", "Enable random crits?");
            case 5:
                Voting_CreateConVarVote("tf_ctf_bonus_time", "Set crits on capture time (CTF)", "0", "5", "10", "20", "30", "60");
            case 6:
                Voting_CreateConVarVote("tf_flag_caps_per_round", "Set flag captures to win (CTF)", "1", "2", "3", "4", "5", "10");
            case 7:
                FakeClientCommand(param1, "sm_rtv");
        }
    else if (action == MenuAction_End)
        delete menu;
}