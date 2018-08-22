# Aardwolf-consider

To view the help file for this plugin please use **conw help**, this will list all the commands for the plugin.  

The plugin starts in the off state by default, to make it run the consider triggers in every room send **conw auto** via the command line. This toggles the triggers on and off.  

To modify the default attack command send **conw** *newcommand* via the commands line, where *newcommand* is an alias or mud command you want it to send when starting combat. Remember that Blowtorch aliases are expanded from plugins , so if in blowtorch you aliased kk to strangle $1;bs $1;circle;circle and use **conw kk* then the mud will receive the expanded alias when you use the **ck 1** command.  

**conw** , with no arguments will manually run the triggers and output a numbered list of the mobs in the room as well as their level range. You then use **ck 1** to attack the first mob in the list, **ck 2** the second, etc.  

By default the plugin gags the normal mud consider messages when you use the conw command or it is set to run automatically. To stop this behaviour use **conw echo** to toggle gagging on and off.  
