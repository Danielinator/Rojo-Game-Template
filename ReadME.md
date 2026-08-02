setup with ./setup/setUp

you can pass "aftman add" or "rokit add" or "rokit add --global" to setUp. you must pass something

reccomended stylua settings(.stylua.toml):
call_parentheses = "Input" 
column_width = 100

// this will make sure stylua doesn't make things like 
vide,create "Frame" {} become vide.create("Frame")({}). Also makes sure columns aren't too big.

reccomended selene settings (selene.toml):
std = "roblox"

[rules]
mixed_table = "allow"
// this will make selene recognise your are working with roblox and not yell at you when working with vide