#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <sdkhooks>

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "item_currencypack_custom"))
	{
		//SetEntProp(entity, Prop_Send, "m_bDistributed", true);
		SDKHook(entity, SDKHook_SpawnPost, OnMoneyCreated);
	}
}

public Action OnMoneyCreated(int entity)
{
	float moneyOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", moneyOrigin);

	int closestClient = -1;
	float closestDistance = -1.0;
	float closestOrigin[3];
	for (int client = 1; client < MaxClients; client++)
	{
		if (!IsClientInGame(client) || IsFakeClient(client) || TF2_GetClientTeam(client) != TFTeam_Red  || !IsPlayerAlive(client))
			continue;

		float clientOrigin[3];
		GetClientAbsOrigin(client, clientOrigin);

		float distance = GetVectorDistance(moneyOrigin, clientOrigin, true);
		if (closestDistance > 0.0 && distance > closestDistance)
			continue;

		if (closestClient != -1 && TF2_GetPlayerClass(closestClient) == TFClass_Scout && TF2_GetPlayerClass(client) != TFClass_Scout)
			continue;

		closestClient = client;
		closestDistance = distance;
		closestOrigin = clientOrigin;
	}

	if (closestClient == -1)
		return Plugin_Continue;

	TeleportEntity(entity, closestOrigin, NULL_VECTOR, NULL_VECTOR);

	return Plugin_Handled;
}