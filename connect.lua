local module = {}

function module.start()
enduser_setup.manual(true)
enduser_setup.start(
   function()
      print("Connected to wifi as: " .. wifi.sta.getip())
   end,
   function(err, str)
      print("enduser_setup: Err #" .. err .. ": " .. str)
   end
);

end

return module
