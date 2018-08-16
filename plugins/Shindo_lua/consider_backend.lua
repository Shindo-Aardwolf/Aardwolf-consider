-- include files
Plugin_Dir = "/Shindo_lua"
dofile(GetPluginInstallDirectory()..Plugin_Dir.."/Name_Cleanup.lua")

-- Colour Stuff
local ansi = "\27["
local dred = "\27[0;31m"
local dgreen = "\27[0;32m"
local dyellow = "\27[0;33m"
local dblue = "\27[0;34m"
local dmagenta = "\27[0;35m"
local dcyan = "\27[0;36m"
local dwhite = "\27[0;37m"
local bred = "\27[31;1m"
local bgreen = "\27[32;1m"
local byellow = "\27[33;1m"
local bblue = "\27[34;1m"
local bmagenta = "\27[35;1m"
local bcyan = "\27[36;1m"
local bwhite = "\27[37;1m"

--Plugin Variables
local AUTO_CONW = 0
local default_command = "k"
local DOING_CONSIDER = 0
local version = "0.1.1"
local targT = {}
local targCount = 0
local ECHO_CONSIDER = 0

local consider_messages = {
  ["You would stomp (.+) into the ground%."] =
  { range = "-19 and below", colour = bwhite, },
  ["(.+) would be easy, but is it even worth the work out%?"] =
  { range = "-10 to -19", colour = dblue, },
  ["No Problem%! (.+) is weak compared to you%."] =
  { range = "-6 to -9", colour = bblue, },
  ["(.+) looks a little worried about the idea%."] =
  { range = "-2 to -6", colour = dcyan, },
  ["(.+) should be a fair fight%!"] =
  { range = "-2 to +2", colour = bcyan, },
  ["(.+) snickers nervously%."] =
  { range = "+2 to +3", colour = dgreen, },
  ["(.+) chuckles at the thought of you fighting .+%."] =
  { range = "+3 to +8", colour = bgreen, },
  ["Best run away from (.+) while you can%!"] =
  { range = "+8 to +16", colour = dyellow, },
  ["Challenging (.+) would be either very brave or very stupid%."] =
  { range = "+16 to +21", colour = byellow, },
  ["(.+) would crush you like a bug%!"] =
  { range = "+21 to +32", colour = dmagenta, },
  ["(.+) would dance on your grave%!"] =
  { range = "+32 to +41", colour = bmagenta, },
  ["(.+) says 'BEGONE FROM MY SIGHT unworthy%!'"] =
  { range = "+41 to +50", colour = dred, },
  ["You would be completely annihilated by (.+)%!"] =
  { range = "+50 and above", colour = bred, },
} -- end of consider_messages

function strip_tags(preString)
  preString = preString:gsub("%(.*%) ","")
  strippedString = preString
  return strippedString
end

function Conw (argu)
  argu = string.lower(argu)
  --Note(string.format("%s\n",argu))
  if argu == "help" or argu == "?" then
    conw_help = {
      "conw - update window with consider all command.",
      "conw off - emergency shut off procedure.",
      "conw echo - toggle echoing consider message in colour.",
      "conw <word> - set default command.",
      "conw auto - toggle auto update consider window on room entry and after combat.",
      "conw ?/help - show this help.",
      "ck <number> - attack mob number <number> in the list generated.",
      "ck - show the last generated list of mobs."
    }
    for i,v in ipairs (conw_help) do
      sSpa = string.rep (" ", 12 - v:sub(1,v:find("-") - 1):len() )
      Note(string.format("%s%s%s",dyellow, v:sub(1,v:find("-") - 1), sSpa ))
      Note(string.format("%s%s\n", dwhite, v:sub(v:find("-"), v:len())))
    end

    return
  end  -- show help

  if argu == "off" then
    Show_Consider()
    return
  end

  if argu == "echo" then
    if ECHO_CONSIDER == 1 then
      ECHO_CONSIDER = 0
      Note(string.format("%sTurning off consider echoing.%s\n", dyellow, dwhite))
    else
      ECHO_CONSIDER = 1
      Note(string.format("%sTurning on consider echoing.%s\n", byellow, dwhite))
    end

    return
  end

  if argu == "auto" then
    if AUTO_CONW == 1 then
      AUTO_CONW = 0
      EnableTriggerGroup ("auto_consider", 0)
      Note(string.format ("%sAuto consider off.%s\n", bblue, dwhite))
    else
      AUTO_CONW = 1
      EnableTriggerGroup ("auto_consider", 1)
      Note(string.format ("%sAuto consider on.%s\n", bblue, dwhite))
    end

    return
  end -- toggle auto

  if argu and argu:match ("^%w+$") then
    default_command = argu
    Note(string.format("%sDefault command: %s%s%s\n", dblue, bblue, default_command, dwhite))
  end  -- set default kill command
end

function attack_considered(targNum)
  if targNum == nil then Show_Consider() return end
  targNum = tonumber(targNum) or 0
  if (targNum > 0) and (targNum < targCount + 1) then
    SendToServer(string.format("%s %s", default_command, targT[targNum].keyword))
  else
    Note(string.format("%sYou need to select a number from 1 to %s%s\n", dyellow, targCount, dwhite))
  end

end

function send_consider ()
  --Note("startup.\n")
  if DOING_CONSIDER == 1 then
    return
  else
    EnableTriggerGroup ("Cons", true)
    DOING_CONSIDER = 1
    SendToServer ("consider all")
    SendToServer ("echo nhm")
    targT = {}
    targCount = 0
  end

end -- send_consider

function getKeyword(mob)
  local nameCount = 1
  for i, mobInfo in pairs(targT) do
    if mobInfo.name == mob then
      nameCount = nameCount + 1
    end
  end

  mob = stripname(mob)
  if nameCount > 1 then
    mob = string.format("%s.%s", tostring(nameCount), mob)
  end

  return mob
end

function adapt_consider (name, line, wildcards)
  mob = nil
  for k, v in pairs (consider_messages) do
    mob = string.match (wildcards["1"], k)
    if mob ~= nil then 
      mob = strip_tags(mob) 
    end 

    if mob then
      t = {
        keyword = getKeyword(mob),
        name    = mob,
        line    = wildcards["1"],
        colour  = v.colour,
        range   = "(" .. v.range .. ")"
      }
      if ECHO_CONSIDER == 1 then
        Note(string.format("%s%s(%s)%s\n" , v.colour, t.line,  v.range, dwhite ))
      end

      table.insert (targT, t)
      targCount = targCount + 1
      break
    end -- if

  end -- for

end -- adapt_consider

function player_only()
  Note(string.format("%sAre you lonely?%s\n", dyellow, dwhite))
end

function safe_room()
  Note(string.format("%sYou can't attack here!!%s\n", bred, dwhite))
end

function Show_Consider()
  for i,v in ipairs (targT) do
    Note(string.format("%2s. %-30s %s%s%s\n", i, v.name, v.colour, v.range, dwhite))
  end

  DOING_CONSIDER = 0
  EnableTriggerGroup ("Cons", false)
end -- Show_Consider

function OnBackgroundStartup()
  Note(string.format("%sShindo's Consider Plugin version: %s%s%s\n", dgreen, bgreen, version, dwhite))
  DOING_CONSIDER = 0
  EnableTriggerGroup("Cons",false)
  targT = {}
end

Note(string.format("%sShindo's Consider Plugin installed%s\n", dgreen, dwhite))
