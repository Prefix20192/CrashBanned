#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
 
Handle g_hArray;
char g_sBanFiles[64];
 
static const char CHAT_PREFIX[]  = "\x04[Crash_ban] \x01";
 
public Plugin myinfo =
{
    name  = "[CSSV34]Crash_ban",
    description    = "[CSSV34]Crash_ban",
    author  = "Pr[E]fix",
    version  = "1.0",
    url   = "vk.com/cyxaruk1337"
};
 
bool b_enable = true;
 
public void OnPluginStart()
{
    AddCommandListener(Command_Crash, "test_crashban");
    RegConsoleCmd("crashban_info", Cmd_info);
    RegAdminCmd("sm_crashban", Command_Ban, 8, "", "", 0);
    g_hArray = CreateArray(ByteCountToCells(32), 0);
    BuildPath(Path_SM, g_sBanFiles, 256, "data/super_bans_list.txt");
    ReadBans();
}
 
public void OnClientPutInServer(int client)
{
    if(b_enable) QueryClientConVar(client, "xbox_throttlespoof", ClientConVar);
    QueryClientConVar(client, "cl_disablehtmlmotd", HtmlClientConVar);
}

public Action Cmd_info(int client, int args)
{    
    PrintToConsole(client, "\n\n\n--------------CrashBanCssV34--------------\n====== Название плагина: CrashBan\n====== Автор плагина: Pr[E]fix\n====== Контакты автора плагина: VK: vk.com/cyxaruk1337 Telegram: @Prefix20192\n");
}
 
public void ClientConVar(QueryCookie cookie, int client, ConVarQueryResult result, char[] cvarName, char[] cvarValue)
{
    if(result)
    {
  LogMessage("No response for the cvar for player %N", client);
  CreateTimer(5.0, Timer_Recheck, GetClientSerial(client), 0);
  return;
    }
    if(StringToInt(cvarValue) == 201)
    {
  Crash(client);
  BanClient(client, 0, 9, "Banned by admin", "You are banned!", "crash_ban", 0);
    }
    char buffer[24];
    GetClientIP(client, buffer, 24, true);
    strcopy(buffer, FindCharInString(buffer, 46, true) + 1, buffer);
    if(FindStringInArray(g_hArray, buffer) != -1) Crash(client);
    GetClientAuthId(client, AuthId_SteamID64, buffer, 24, true);
    if(FindStringInArray(g_hArray, buffer) != -1) Crash(client);
}
 
public Action Timer_Recheck(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if(!client) return Plugin_Continue;
 
    QueryClientConVar(client, "xbox_throttlespoof", ClientConVar);
 
    return Plugin_Continue;
}
 
public void HtmlClientConVar(QueryCookie cookie, int client, ConVarQueryResult result, char[] cvarName, char[] cvarValue)
{
    if(result)
    {
  CreateTimer(5.0, Timer_RechekMotd, GetClientSerial(client), 0);
  return;
    }
    if(StringToInt(cvarValue)) KickClient(client, "Для игры на сервере, введите в консоле 'cl_disablehtmlmotd 0'");
}
 
public Action Timer_RechekMotd(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if(!client) return Plugin_Continue;
 
    QueryClientConVar(client, "cl_disablehtmlmotd", HtmlClientConVar);
 
    return Plugin_Continue;
}
 
void ReadBans()
{
    Handle file = OpenFile(g_sBanFiles, "r");
    if(file)
    {
  char buffer[32];
  while(!IsEndOfFile(file))
  {
   if(ReadFileLine(file, buffer, 32))
   {
    int pos = StrContains(buffer, ";", true);
    if(pos != -1) buffer[pos] = 0;
    TrimString(buffer);
   }
  }
  CloseHandle(file);
    }
}
 
public Action Command_Ban(int client, int args)
{
    if(!client) return Plugin_Continue;
 
    DisplayMainMenu(client);
 
    return Plugin_Handled;
}
 
void DisplayMainMenu(int client)
{
    Handle menu = CreateMenu(MainMenuHandler);
    SetMenuTitle(menu, "[CSSV34] CRASHBAN");
    SetMenuExitButton(menu, true);
    AddMenuItem(menu, "1", "Забанить игрока", 0);
    AddMenuItem(menu, "2", "Разбанить игрока", 0);
    if(b_enable) AddMenuItem(menu, "3", "Выключить защиту", 0);
    else AddMenuItem(menu, "3", "Включить защиту", 0);
    DisplayMenu(menu, client, 0);
}
 
public int MainMenuHandler(Handle menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
  case MenuAction_Select: {
   char g_szItem[32];
   GetMenuItem(menu, param2, g_szItem, 32);
   switch(StringToInt(g_szItem))
   {
    case 1: DisplayBanMenu(param1);
    case 2: DisplayUnbanMenu(param1);
    case 3:
    {
     b_enable = !b_enable;
     PrintToChat(param1, "%sЗащита %s", CHAT_PREFIX, b_enable ? "включена" : "выключена");
     if(b_enable)
     {
      for(int i = 1; i < MaxClients; i++)
      {
       if(IsClientInGame(i)) OnClientPutInServer(i);
      }
     }
     DisplayMainMenu(param1);
    }
   }
  }
  case MenuAction_End: CloseHandle(menu);
    }
    return 0;
}
 
void DisplayUnbanMenu(int client)
{
    Handle menu = CreateMenu(MenuUnbanHandler);
    SetMenuTitle(menu, "Выберите игрока");
    SetMenuExitBackButton(menu, true);
    FillMenuByPlayers(menu, -1);
    DisplayMenu(menu, client, 0);
}
 
public int MenuUnbanHandler(Handle menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
  case MenuAction_Select:
  {
   char g_szItem[32];
   GetMenuItem(menu, param2, g_szItem, 32);
   int client = GetClientOfUserId(StringToInt(g_szItem));
   if(!client)
   {
    PrintToChat(param1, "%sИгрок отсутствует на сервере", CHAT_PREFIX);
    DisplayMainMenu(param1);
    return 0;
   }
   NoSteam_UnbanClient(client);
   PrintToChat(param1, "%sИгрок %N разбанен", CHAT_PREFIX, client);
   DisplayMainMenu(param1);
  }
  case MenuAction_Cancel: if(param2 == MenuCancel_ExitBack) DisplayMainMenu(param1);
  case MenuAction_End: CloseHandle(menu);
    }
    return 0;
}
 
void DisplayBanMenu(int client)
{
    Handle menu = CreateMenu(MenuBanHandler);
    SetMenuTitle(menu, "Выберите игрока");
    SetMenuExitBackButton(menu, true);
    FillMenuByPlayers(menu, -1);
    DisplayMenu(menu, client, 0);
}
 
public int MenuBanHandler(Handle menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
  case MenuAction_Select: {
   char g_szItem[32];
   GetMenuItem(menu, param2, g_szItem, 32);
   int client = GetClientOfUserId(StringToInt(g_szItem));
   if(!client)
   {
    PrintToChat(param1, "%sИгрок отсутствует на сервере", CHAT_PREFIX);
    DisplayMainMenu(param1);
    return 0;
   }
   NoSteam_BanClient(client);
   PrintToChat(param1, "%sИгрок %N забанен", CHAT_PREFIX, client);
   DisplayMainMenu(param1);
  }
  case MenuAction_Cancel: if(param2 == MenuCancel_ExitBack) DisplayMainMenu(param1);
  case MenuAction_End: CloseHandle(menu);
    }
    return 0;
}
 
void FillMenuByPlayers(Handle menu, int skipclient)
{
    char name[36];
    char id[32];
    int i = 1;
    while(i <= MaxClients)
    {
  if (skipclient != i && IsClientInGame(i))
  {
   GetClientName(i, name, 33);
   IntToString(GetClientUserId(i), id, 32);
   AddMenuItem(menu, id, name, 0);
   i++;
  }
  i++;
    }
}
 
void NoSteam_BanClient(int client)
{
    char buffer[32];
    GetClientIP(client, buffer, 32, true);
    strcopy(buffer, FindCharInString(buffer, 46, true) + 1, buffer);
    Handle file = OpenFile(g_sBanFiles, "a");
    if(FindStringInArray(g_hArray, buffer) == -1)
    {
  PushArrayString(g_hArray, buffer);
  if(file) WriteFileLine(file, buffer);
    }
    GetClientAuthId(client, AuthId_SteamID64, buffer, 32, true);
    if(FindStringInArray(g_hArray, buffer) == -1)
    {
  PushArrayString(g_hArray, buffer);
  if(file) WriteFileLine(file, buffer);
    }
    if(file) CloseHandle(file);
    Handle Kv = CreateKeyValues("data", "", "");
    KvSetString(Kv, "title", "Script failed");
    KvSetString(Kv, "type", "0");
    KvSetString(Kv, "msg", "...Script/Load... Failed");
    KvSetString(Kv, "cmd", "xbox_throttlespoof 201;retry;");
    ShowVGUIPanel(client, "info", Kv, true);
    CloseHandle(Kv);
}
 
void NoSteam_UnbanClient(int client)
{
    Handle Kv = CreateKeyValues("data", "", "");
    KvSetString(Kv, "title", "Unbanned");
    KvSetString(Kv, "type", "0");
    KvSetString(Kv, "msg", "Вы разбанены!");
    KvSetString(Kv, "cmd", "xbox_throttlespoof 200;");
    ShowVGUIPanel(client, "info", Kv, true);
    CloseHandle(Kv);
    char buffer[32];
    GetClientIP(client, buffer, 32, true);
    strcopy(buffer, FindCharInString(buffer, 46, true) + 1, buffer);
    int index = FindStringInArray(g_hArray, buffer);
    if(index != -1) RemoveFromArray(g_hArray, index);
    GetClientAuthId(client, AuthId_SteamID64, buffer, 32, true);
    index = FindStringInArray(g_hArray, buffer);
    if(index != -1) RemoveFromArray(g_hArray, index);
}
 
public Action Command_Crash(int client, char[] command, int args)
{
    if(!client) return Plugin_Continue;
 
    CreateTimer(1.0, Timer_CrashPlayer, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
 
    return Plugin_Handled;
}
 
public Action Timer_CrashPlayer(Handle timer, any serial)
{
    int client = GetClientFromSerial(serial);
    if(!client) return Plugin_Continue;
 
    Crash(client);
    PrintToChatAll("%sИгрок %N забанен", CHAT_PREFIX, client);
 
    return Plugin_Continue;
}
 
void Crash(int client)
{
    Handle setup = CreateKeyValues("data", "", "");
    KvSetString(setup, "title", "FabFapBan");
    KvSetNum(setup, "type", 2);
    KvSetString(setup, "msg", "http://sourcetm.myarena.ru/css/crash.html");
    ShowVGUIPanel(client, "info", setup, false);
    CloseHandle(setup);
    PrintToChatAll("%sИгрок %N забанен", CHAT_PREFIX, client);
}
