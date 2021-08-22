# __[CSSV34]Crash_ban__

![MySenPai](https://pa1.narvii.com/6862/6098ddd3be86e6253a9a2174796bf3fba9c06867r1-500-260_hq.gif)


# F.A.Q
 ## __Что делает данный плагин?__

- ### Данный плагин банит игроков по STEAM_ID + IP + CFG(Командой которую вы можете дописать, или изменить в `.sp`)

- ### Данный бан работает на всех хостингах, пользуйтесь :D

***
# Требование:

## GameServer:
- [Sourcemode 1.8 - Sourcemode 1.11](https://www.sourcemod.net/downloads.php?branch=stable)

***


# Установка
- #### Распаковать архив `.zip` соблюдая иерархию католога.

***
# Список команд:
```c
test_crashban - Протестировать бан на себе.

crashban_info - Информация о плагине в console клиента(который ввел эту команду)

sm_crashban - Вызов меню самого бана

````
***
Что можно изменить в `.sp` (как добавить еще бан не только по 1 cvar команде)
```c#
Пример:
Добавление cvar команды (по типу sv_logecho)
if(b_enable) QueryClientConVar(client, "xbox_throttlespoof, sv_logecho", ClientConVar);
QueryClientConVar(client, "xbox_throttlespoof, sv_logecho", ClientConVar);

В случае бана будет в cfg читера вписанны команды (xbox_throttlespoof 20, sv_logecho 228)
KvSetString(Kv, "cmd", "xbox_throttlespoof 201;sv_logecho 228;retry;");

В случае разбана у читера будут стандартные команды которые у него были(xbox_throttlespoof 200;sv_logecho 227;)

KvSetString(Kv, "cmd", "xbox_throttlespoof 200;");

P.S Удачи разбераться в .sp, сам по себе исходный код понятен, в будущем будет вывод банов с поддержкой SB/SB++/MA
```

***

 __ПОДДЕРЖКА СТРОГО В [VK](VK.COM/CYXARUK1337)__

***

__P.S Просьба оставить коментарий на в профиле [HLMOD](https://hlmod.ru/members/pr-e-fix.110719/)__
***
![MySenPai](https://pa1.narvii.com/8008/5ff3a5128bf7a511810414eecce8018a7b0a52cer1-500-282_hq.gif)
