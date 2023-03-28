
<h1>Installation</h1>

1. Install Files
2. Drag and Drop them to your resources Folder
3. Add `ensure zykem_bansystem` to your server.cfg and type ```refresh\nrestart zykem_bansystem``` in your server console

<h1>Usage</h1>

# Commands

```lua
/identifiers - shows your identifiers
/zban targetId duration reason -- /zban 1 1d Cheating
/zunban banId -- /zunban BKDkd923
```

# Code

 Get User Identifiers

```lua
exports.zykem_bansystem:getUserCoins(source)
```
 Ban Player

```lua
exports.zykem_bansystem:banPlayer(banner,target,duration,reason)

banner = {group = "playerGroup", name = "playerName"}
target = target source (serverId)
duration = 1s,1d,1w,1m,1y (second,day,week,month,year)
```
 Unban Player

```lua
exports.zykem_bansystem.unbanPlayer(admin,banId)

admin = {type = 'adminType', group = 'adminGroup', name = 'adminName'}

If you are unbanning someone from code (not by command) then this is how your admin table should look like:
{type = "console", group = "best", name = "console"} -- in my case best, since its the group that has unban permission set in sv_config

```
 Kick Player

```lua
exports.zykem_bansystem.kickPlayer(admin,source,reason)

admin = {group = "playerGroup"}
source = target source (serverId)

```



<h1>Preview</h1>
<ul>
  <li>none yet</li>
</ul>

<h1>Features</h1>
<ul>
  <li>Bans every identifier that fivem provides</li>
  <li>2 Locales (Polish/English)</li>
  <li>HWID Bans (FiveM Tokens)</li>
</ul>

<h1>Todo - nothing</h1>
 Suggestions? message me on discord zykem#0643

