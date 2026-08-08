setup with ./setup/setUp

you can pass "aftman add" or "rokit add" or "rokit add --global" to setUp. you must pass something

you must run rokit init / aftman init before setup

How to modify rojo to allow for custom aliases: (required)

1. In roblox studio, go into studio settings and enable "plugin debugging enabled". Restart studio.
2. Then, open the "PluginDebugService" in your explorer. MAKE SURE YOU INSTALLED ROJO THROUGH THE COMMAND ROJO PLUGIN INSTALL, OR TRHOUGH THE VSCODE GUI. This will not work if you use the plugin found on the creator store.
3. Go into "user_RojoManagedPlugin.rbxm" (or whatever your rojo is called)
4. Go into Rojo\Packages\RbxDom\PropertyDescriptor
5. Replace the entirety of PropertyDescriptor with the text in replace.txt
6. Right click "user_RojoManagedPlugin.rbxm" (or whatever your rojo is called) and click "Save and reload plugin"
You will need to repeat this from step 3 if you ever reinstall the plugin.
You may need to delete existing files and resync them to apply changes to all files (this is a hack job so dont expect it to work well)

reccomended stylua settings(.stylua.toml):
call_parentheses = "Input" 
column_width = 100
syntax = "Luau"

// this will make sure stylua doesn't make things like 
fluid,create "Frame" {} become fluid.create("Frame")({}). Also makes sure columns aren't too big.
also also makes sure stylua works with all luau syntax

reccomended selene settings (selene.toml):
std = "roblox"

[rules]
mixed_table = "allow"
// this will make selene recognise your are working with roblox and not yell at you when working with fluid