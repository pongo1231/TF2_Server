#include <sourcemod>
#include <sdktools>

float g_chance = 0.0;

public void OnConfigsExecuted()
{
    if (GetRandomInt(0, 99) < 60)
    {
        g_chance = GetURandomFloat() * 0.20;
    }
    else
    {
        g_chance = GetURandomFloat() * 0.8 + 0.20;
    }

    TrySetGravitySpecial();
    TrySetDirect("mp_disable_respawn_times", "1");
    TrySetDirect("tf_grapplinghook_enable", "1");
    TrySetDirectSpecial("mp_friendlyfire", "1");
    TrySetDirectSpecial("rcbot_melee_only", "1");

    TrySetWithSMSpecial("sm_bottaunt_enabled", "1", true);
    TrySetWithSMSpecial("sm_bbr_enable", "1", false);
    TrySetWithSMSpecial("tf2_x10_enabled", "1", false);
    TrySetWithSMSpecial("sm_alwayscrits_enabled", "1", false);
    TrySetWithSMSpecial("goomba_enabled", "1", false);
    TrySetWithSMSpecial("sm_spells_enabled", "1", false);
    TrySetWithSMSpecial("sm_aia_all", "1", false);
    TrySetWithSMSpecial("sm_hugeexplosions_enabled", "1", false);
    TrySetWithSMSpecial("sm_deadlywater_enabled", "1", true);
    TrySetWithSMSpecial("sm_spyspyspyspy_enabled", "1", true);
    TrySetWithSMSpecial("sm_helphelphelphelp_enabled", "1", true);

    TrySetRCBotClassSpecial();
}

void TrySetDirect(const char[] cvarName, const char[] value)
{
    if (RollChance()) ServerCommand("%s %s", cvarName, value);
}

void TrySetDirectSpecial(const char[] cvarName, const char[] value)
{
    if (RollChance() && RollLowerChance()) ServerCommand("%s %s", cvarName, value);
}

void TrySetWithSMSpecial(const char[] cvarName, const char[] value, bool lower)
{
    if (RollChance() && (!lower || RollLowerChance()))
    {
        ServerCommand("sm_cvar %s %s", cvarName, value);
    }
}

void TrySetGravitySpecial()
{
    if (!RollChance() || !RollLowerChance()) return;

    static const int gravities[] = {1, 400, 800, 1600};
    int pick = gravities[GetRandomInt(0, sizeof(gravities) - 1)];
    ServerCommand("sm_gravity %d", pick);
}

void TrySetRCBotClassSpecial()
{
    if (!RollChance() || !RollLowerChance()) return;

    static const char classes[][] =
    {
        "None", "Scout", "Soldier", "Pyro", "Demoman",
        "Heavy", "Engineer", "Medic", "Sniper", "Spy"
    };

    int index = GetRandomInt(0, sizeof(classes) - 1);
    ServerCommand("sm_cvar menu_bots_rcbot_force_class %s", classes[index]);
}

bool RollChance()
{
    return (GetURandomFloat() <= g_chance);
}

bool RollLowerChance()
{
    return (GetURandomFloat() <= 0.25);
}
