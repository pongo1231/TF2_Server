#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <server/serverchat>

ConVar g_enabled;
bool dmgVoiceClients[32];

public void OnPluginStart() {
	g_enabled = CreateConVar("sm_bothurtvoice_enabled", "1", "Enable plugin");
	RegConsoleCmd("menu_player_dmgvoice", PlayerToggleDmgVoice);
	HookEvent("player_hurt", Event_PlayerHurt);
}

public Action PlayerToggleDmgVoice(int client, int args) {
    dmgVoiceClients[client] = !dmgVoiceClients[client];
    if (dmgVoiceClients[client])
    	Server_PrintToChat(client, "Menu", "Enabled Damage Voice.");
    else
    	Server_PrintToChat(client, "Menu", "Disabled Damage Voice.");

    return Plugin_Handled;
}

public void OnClientDisconnect_Post(int client) {
	dmgVoiceClients[client] = false;
}

public Action Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast) {
	if (!GetConVarBool(g_enabled))
		return Plugin_Continue;

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int hurter = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (IsFakeClient(victim) || dmgVoiceClients[victim])
		PlayRandomVoice(victim);
	if (hurter != 0 && (IsFakeClient(hurter) || dmgVoiceClients[hurter]))
		PlayRandomVoice(hurter);

	return Plugin_Handled;
}

public void OnMapStart() {
	PrecacheSound("ui/duel_event.wav");
}

public void OnClientPutInServer(int client) {
	EmitSoundToClient(client, "ui/duel_event.wav");
}

public void TF2_OnConditionAdded(int client, TFCond condition) {
	if (condition == TFCond_SpawnOutline)
		PlayRandomVoice(client);
}

char VoiceInputs[][] = {
	"TLK_PLAYER_TAUNT",
	"TLK_PLAYER_THANKS",
	"TLK_PLAYER_MEDIC",
	"TLK_PLAYER_HELP",
	"TLK_PLAYER_GO",
	"TLK_PLAYER_MOVEUP",
	"TLK_PLAYER_LEFT",
	"TLK_PLAYER_RIGHT",
	"TLK_PLAYER_YES",
	"TLK_PLAYER_NO",
	"TLK_PLAYER_INCOMING",
	"TLK_PLAYER_CLOAKEDSPY",
	"TLK_PLAYER_SENTRYAHEAD",
	"TLK_PLAYER_TELEPORTERHERE",
	"TLK_PLAYER_DISPENSERHERE",
	"TLK_PLAYER_SENTRYHERE",
	"TLK_PLAYER_ACTIVATECHARGE",
	"TLK_PLAYER_CHARGEREADY",
	"TLK_PLAYER_BATTLECRY",
	"TLK_PLAYER_CHEERS",
	"TLK_PLAYER_JEERS",
	"TLK_PLAYER_POSITIVE",
	"TLK_PLAYER_NEGATIVE",
	"TLK_PLAYER_NICESHOT",
	"TLK_PLAYER_GOODJOB",
	"TLK_SPY_SAPPER",
	"TLK_PLAYER_PAIN",
	"TLK_PLAYER_ATTACKER_PAIN",
	"TLK_ONFIRE",
	"TLK_CAPTURE_BLOCKED",
	"TLK_PICKUP_BUILDING",
	"TLK_REDEPLOY_BUILDING",
	"TLK_CARRYING_BUILDING",
	"TLK_GRAB_BALL",
	"TLK_CAPTURED_POINT",
	"TLK_ROUND_START",
	"TLK_ROUND_START_COMP",
	"TLK_SUDDENDEATH_START",
	"TLK_STALEMATE",
	"TLK_BUILDING_OBJECT",
	"TLK_DETONATED_OBJECT",
	"TLK_LOST_OBJECT",
	"TLK_KILLED_OBJECT",
	"TLK_MEDIC_CHARGEREADY",
	"TLK_TELEPORTED",
	"TLK_FLAGPICKUP",
	"TLK_FLAGCAPTURED",
	"TLK_CART_MOVING_FORWARD",
	"TLK_CART_STOP",
	"TLK_CART_MOVING_BACKWARD",
	"TLK_ATE_FOOD",
	"TLK_DOUBLE_JUMP",
	"TLK_DODGING",
	"TLK_DODGE_SHOT",
	"TLK_GRAB_BALL",
	"TLK_REGEN_BALL",
	"TLK_DEFLECTED",
	"TLK_BALL_MISSED",
	"TLK_STUNNED",
	"TLK_STUNNED_TARGET",
	"TLK_TIRED",
	"TLK_BAT_BALL",
	"TLK_ACHIEVEMENT_AWARD",
	"TLK_JARATE_LAUNCH",
	"TLK_JARATE_HIT",
	"TLK_TAUNT_LAUGH",
	"TLK_TAUNT_PYRO_ARMAGEDDON",
	"TLK_KILLED_PLAYER",
	"TLK_MINIGUN_FIREWEAPON",
	"TLK_REQUEST_DUEL",
	"TLK_DUEL_WAS_REJECTED",
	"TLK_ACCEPT_DUEL",
	"TLK_DUEL_WAS_ACCEPTED",
	"TLK_COMBO_KILLED",
	"TLK_MANNHATTAN_GATE_ATK",
	"TLK_MANNHATTAN_GATE_TAKE",
	"TLK_RESURRECTED",
	"TLK_MEDIC_HEAL_SHIELD",
	"TLK_MVM_LOOT_COMMON",
	"TLK_MVM_LOOT_RARE",
	"TLK_MVM_LOOT_ULTRARARE",
	"TLK_PLAYER_SPELL_PICKUP_COMMON",
	"TLK_PLAYER_SPELL_PICKUP_RARE",
	"TLK_MVM_BOMB_DROPPED",
	"TLK_MVM_BOMB_CARRIER_UPGRADE1",
	"TLK_MVM_BOMB_CARRIER_UPGRADE2",
	"TLK_MVM_BOMB_CARRIER_UPGRADE3",
	"TLK_MVM_DEFENDER_DIED",
	"TLK_MVM_FIRST_BOMB_PICKUP",
	"TLK_MVM_BOMB_PICKUP",
	"TLK_MVM_SENTRY_BUSTER",
	"TLK_MVM_SENTRY_BUSTER_DOWN",
	"TLK_MVM_SNIPER_CALLOUT",
	"TLK_MVM_LAST_MAN_STANDING",
	"TLK_MVM_ENCOURAGE_MONEY",
	"TLK_MVM_MONEY_PICKUP",
	"TLK_MVM_ENCOURAGE_UPGRADE",
	"TLK_MVM_UPGRADE_COMPLETE",
	"TLK_MVM_GIANT_CALLOUT",
	"TLK_MVM_GIANT_HAS_BOMB",
	"TLK_MVM_GIANT_KILLED",
	"TLK_MVM_GIANT_KILLED_TEAMMATE",
	"TLK_MVM_SAPPED_ROBOT",
	"TLK_MVM_CLOSE_CALL",
	"TLK_MVM_TANK_CALLOUT",
	"TLK_MVM_TANK_DEAD",
	"TLK_MVM_TANK_DEPLOYING",
	"TLK_MVM_ATTACK_THE_TANK",
	"TLK_MVM_TAUNT",
	"TLK_MVM_WAVE_START",
	"TLK_MVM_WAVE_WIN",
	"TLK_MVM_WAVE_LOSE",
	"TLK_MVM_DEPLOY_RAGE",
	"TLK_PLAYER_SPELL_SKELETON_HORDE",
	"TLK_PLAYER_CAST_METEOR_SWARM",
	"TLK_GAME_OVER_COMP",
	"TLK_MATCH_OVER_COMP",
	"TLK_PLAYER_CAST_SKELETON_HORDE",
	"TLK_PLAYER_CAST_METEOR_SWARM",
	"TLK_PLAYER_CAST_MONOCULOUS",
	"TLK_PLAYER_CAST_MOVEMENT_BUFF",
	"TLK_PLAYER_CAST_LIGHTNING_BALL",
	"TLK_PLAYER_CAST_BOMB_HEAD_CURSE",
	"TLK_PLAYER_CAST_TELEPORT",
	"TLK_PLAYER_CAST_STEALTH",
	"TLK_PLAYER_CAST_BLAST_JUMP",
	"TLK_PLAYER_CAST_SELF_HEAL",
	"TLK_PLAYER_CAST_MERASMUS_ZAP",
	"HalloweenLongFall",
	"TLK_PLAYER_SHOW_ITEM_TAUNT", // Some weird pyro sound
	""
}

char Classes[][] = {
	"Scout",
	"Soldier",
	"Pyro",
	"Demoman",
	"Heavy",
	"Engineer",
	"Medic",
	"Sniper",
	"Spy"
}

void PlayRandomVoice(int client) {
	if (GetRandomInt(0, 100) > 50) {
		if (GetRandomInt(0, 1) == 0)
			SetVariantString("domination:dominated");
		else
			SetVariantString("domination:revenge");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		char contextClass[32];
		Format(contextClass, sizeof(contextClass), "victimclass:%s", Classes[GetRandomInt(0, sizeof(Classes) - 1)]);
		SetVariantString(contextClass);
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("beinghealed:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("damagecritical:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsDominating:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("PlayerOnWinningTeam:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("PlayerOnLosingTeam:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsMedicDoubleFace:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsMedicBirdHead:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsHeavyBirdHead:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsSoldierBirdHead:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsSniperBirdHead:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsSoldierMaggotHat:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsSoldierWizardHat:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsUnicornHead:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsMedicZombieBird:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsHauntedHat:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsRobotCostume:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsFairyHeavy:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsDemowolf:1");
		AcceptEntityInput(client, "AddContext");
	}

	if (GetRandomInt(0, 100) > 50) {
		SetVariantString("IsFrankenHeavy:1");
		AcceptEntityInput(client, "AddContext");
	}

	SetVariantString("randomnum:100");
	AcceptEntityInput(client, "AddContext");
	SetVariantString("IsMvMDefender:1");
	AcceptEntityInput(client, "AddContext");
	SetVariantString("IsCompWinner:1");
	AcceptEntityInput(client, "AddContext");

	SetVariantString(VoiceInputs[GetRandomInt(0, sizeof(VoiceInputs) - 1)]);
	AcceptEntityInput(client, "SpeakResponseConcept");

	AcceptEntityInput(client, "ClearContext");
}