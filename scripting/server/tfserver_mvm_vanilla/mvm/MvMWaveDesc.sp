#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <SteamWorks>

//char missionname[32];
bool playing_mvm = false;

public void OnPluginStart() {
	CreateTimer(5.0, Timer_UpdateWaveStatus, _, TIMER_REPEAT);
}

public void OnMapStart() {
	playing_mvm = IsGamemodeMvm();
	if (playing_mvm)
		SteamWorks_SetGameDescription("Fetching wave status...");
}

public Action Timer_UpdateWaveStatus(Handle timer) {
	if (!playing_mvm)
		return Plugin_Continue;

	char wave_status[32];
	bool show_wave_status = true;
	switch (GameRules_GetRoundState()) {
		case RoundState_Init, RoundState_Pregame, RoundState_StartGame: {
			wave_status = "Idle";
			show_wave_status = false;
		}
		case RoundState_Preround, RoundState_BetweenRounds:  
			wave_status = "Setting up";
		case RoundState_RoundRunning:
			wave_status = "Wave running";
		case RoundState_GameOver: {
			wave_status = "Mission completed";
			show_wave_status = false;
		}
	}
	if (GetClientCount() == 0)
		wave_status = "Idle";

	/*char mission_text[32];
	if (!missionname[0])
		Format(mission_text, sizeof(mission_text), "Normal");
	else
		strcopy(mission_text, sizeof(mission_text), missionname);*/

	int mvm_info = FindEntityByClassname(-1, "tf_objective_resource");
	int current_wave;
	int max_waves;
	if (mvm_info == -1)
		show_wave_status = false;
	else {
		current_wave = GetEntProp(mvm_info, Prop_Data, "m_nMannVsMachineWaveCount");
		max_waves = GetEntProp(mvm_info, Prop_Data, "m_nMannVsMachineMaxWaveCount");
	}

	if (wave_status[0]) {
		char wave_text[32];
		if (show_wave_status)
			Format(wave_text, sizeof(wave_text), "| Wave: %i / %i", current_wave, max_waves);

		char desc_text[128];
		Format(desc_text, sizeof(desc_text), "Status: %s %s", wave_status, wave_text);

		SteamWorks_SetGameDescription(desc_text);
	}

	return Plugin_Handled;
}

/*void InitMapName() {
	char mapname[64];
	char _missionname[32];

	bool first_underscore = false;
	bool record_name = false;
	GetCurrentMap(mapname, sizeof(mapname));
	int missionname_index = 0;
	for (int i = 0; mapname[i + 1]; i++)
		if (StrEqual(mapname[i], "_"))
			if (!record_name)
				if (!first_underscore)
					first_underscore = true;
				else {
					record_name = true;
					continue;
				}
			else {
				_missionname[missionname_index] = ' ';
				missionname_index++;
			}
		else if (record_name) {
			if (i - 1 > -1 && StrEqual(mapname[i - 1], "_"))	
				_missionname[missionname_index] = CharToUpper(mapname[i]);
			else
				_missionname[missionname_index] = mapname[i];
			missionname_index++;
		}

	strcopy(missionname, sizeof(missionname), _missionname);
}*/

bool IsGamemodeMvm() {
	if (GameRules_GetProp("m_bPlayingMannVsMachine") == -1)
		return false;
	else
		return true;
}