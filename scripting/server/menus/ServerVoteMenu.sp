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
    menu.SetTitle("Server settings");

    char text[128];

    menu.AddItem("server_silly", "Silly settings");

    menu.AddItem("server_scramble_teams", "Scramble teams");

    Format(text, sizeof(text), "Instant respawn (Currently: %b)", GetConVarBool(FindConVar("mp_disable_respawn_times")));
    menu.AddItem("server_instant_respawn", text);

    int halloween_mode = GetConVarInt(FindConVar("tf_forced_holiday"));
    // tf_forced_holiday 2 is Halloween Mode
    if (halloween_mode == 2)
        halloween_mode = 1;
    Format(text, sizeof(text), "Halloween mode (Currently: %i)", halloween_mode);
    menu.AddItem("server_halloween", text);

    Format(text, sizeof(text), "Random crits (Currently: %b)", GetConVarBool(FindConVar("tf_weapon_criticals")));
    menu.AddItem("server_random_crits", text);

    Format(text, sizeof(text), "Crits on capture time (CTF) (Currently: %i)", GetConVarInt(FindConVar("tf_ctf_bonus_time")));
    menu.AddItem("server_crits_on_cap", text);

    Format(text, sizeof(text), "Flag captures to win (CTF) (Currently: %i)", GetConVarInt(FindConVar("tf_flag_caps_per_round")));
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