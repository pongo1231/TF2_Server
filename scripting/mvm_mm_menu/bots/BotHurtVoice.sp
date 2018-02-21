#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

public Plugin info = {
	name = "BotHurtVoice",
	author = "pongo1231",
	description = "Makes bots hurl.",
	version = "1.0",
	url = "n/a"
}

ConVar g_enabled;

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_bothurtvoice_enabled", "1", "Enable plugin");
	HookEvent("player_hurt", Event_PlayerHurt);
}

public Action Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast) {
	if (!GetConVarBool(g_enabled))
		return Plugin_Continue;

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int hurter = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (victim != 0) {
		if (IsFakeClient(victim)) {
			int voice_menu = GetRandomInt(0, 2);
			int voice_item = GetRandomInt(0, 8);
			char command[16];
			Format(command, sizeof(command), "voicemenu %i %i", voice_menu, voice_item);
			FakeClientCommand(victim, command);
		}

		if (hurter != 0 && IsFakeClient(hurter)) {
			int voice_menu = GetRandomInt(0, 2);
			int voice_item = GetRandomInt(0, 8);
			char command[16];
			Format(command, sizeof(command), "voicemenu %i %i", voice_menu, voice_item);
			FakeClientCommand(hurter, command);
		}
	}

	return Plugin_Handled;
}