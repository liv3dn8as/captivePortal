-- Put together by liv3dn8as, Created April 2017 for ESP-Mesh Project
-- Needed Modules: crypto, enduser_setup, file, GPIO
-- HTTP, mDNS, MQTT, net, node, SNTP, timer, UART, WiFi,

-- Define some variables
theSSID="theNODE" -- set SSID to same as Router to form Mesh
thePWD="thisisONLYatest" -- passphrase
theAUTH=wifi.WPA_WPA2_PSK -- set authentication mode
theChan=5 -- Main router is 11

print("---------------------")
print("Setting up WiFi AP...")

-- Configuration area for forming Mesh
wifi.setmode(wifi.STATIONAP)
cfg={}
   cfg.ssid=theSSID
   cfg.pwd=thePWD
   cfg.auth=theAUTH
   cfg.channel=theChan
   cfg.hidden=0 --1 if true
wifi.ap.config(cfg)

print("Done.")
print("---------------------")

--connect = require("connect")
--connect.start()
--Attempt to use enduser_setup instead of hardcoding in credentials
enduser_setup.manual(true)
--moved to connect.lua
enduser_setup.start(
   function()
      print("Connected to wifi as:" .. wifi.sta.getip())
   end,
   function(err, str)
      print("enduser_setup: Err #" .. err .. ": " .. str)
   end

--print -- Lua print function can server as the debug callback
);

--enduser_setup.stop()

-- Call theMesh.lua file
-- dofile ("theMesh.lua")


--print ("---------------------")
-- print("Setting up WiFi AP...")

-- wifi.setmode(wifi.SOFTAP)
-- cfg={}
--     cfg.ssid="captivePortal"
--     wifi.ap.config(cfg)

--print("Done.")
--print ("---------------------")

majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
print("Flash size is "..flashsize.." kBytes.")

remaining, used, total=file.fsinfo()
    print("File system:\n Total : "..(total/1024).." kBytes\n Used  : "..(used/1024).." kBytes\n Remain: "..(remaining/1024).." kBytes")

--local compileAndRemoveIfNeeded = function(f)
--   if file.open(f) then
--      file.close()
--      print('Compiling:', f)
--      node.compile(f)
--      file.remove(f)
--      collectgarbage()
--    else
--    print("No need to compile ", f )
--    end
--end
--print ("---------------------")
--print("Compiling LUA files...")

--local serverFiles = {'dns-liar.lua', 'server.lua'}
--for i, f in ipairs(serverFiles) do compileAndRemoveIfNeeded(f) end

--compileAndRemoveIfNeeded = nil
--serverFiles = nil
--collectgarbage()

--print("Compiling done.")
--print ("---------------------")

function startup()
    uart.on("data")
    if abort == true then
        print('startup aborted')
        return
        end
--	print ("---------------------")
--    print('Starting HTTP Server')
--    dofile('server.lc')
--    print ('Starting DNS Server')
--    dofile('dns-liar.lc')
--	print ("---------------------")
    end

 -- prepare abort procedure
    abort = false
    print('Send some xxxx Keystrokes now to abort startup.')
    -- if <CR> is pressed, abort
      uart.on("data", "x", 
      function(data)
        print("receive from uart:", data)
        if data=="x" then
          abort = true 
          uart.on("data") 
        end        
    end, 0)


print ('Will launch servers in 5 seconds...')
tmr.alarm(0,5000,0,startup)
