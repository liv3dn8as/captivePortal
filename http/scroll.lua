-- MaxScroll
-- John Longworth July 2016
-- This code has been collected from various places and modified by me

DIN = 7  -- ESP8266 GPIO13 - MAX7219 DIN pin
CS  = 8  -- ESP8266 GPIO15 - MAX7219 CS pin 
CLK = 5  -- ESP8266 GPIO14 - MAX7219 CLK pin

gpio.mode(DIN, gpio.OUTPUT)
gpio.mode(CS,  gpio.OUTPUT) 
gpio.mode(CLK, gpio.OUTPUT)

data = {1,2,4,8,16,32,64,128,64,32,16,8,4,2,1,2,4,8,16,32,64,128,64,32,16,8,4,2,1,2,4,8,16,32,64,128}

function set_MAX_Registers() -- Initialise MAX7219 registers
   regSet(0x0b, 0x07)        -- Set Scan Limit
   regSet(0x09, 0x00)        -- Set Decode Mode
   regSet(0x0c, 0x01)        -- Set Shut Down Mode (On)
   regSet(0x0f, 0x00)        -- Set Display Test (Off)
   regSet(0x0a, 0x0c)        -- Set LED Brightness (0 - 15)    
end    

function writeByte(data)     -- Write byte one bit at a time
   i=8
   while (i>0) do
      mask = bit.lshift(0x01,i-1)         
      gpio.write(CLK, 0)    
      dat = bit.band(data,mask)
      if (dat > 0) then 
         gpio.write(DIN, 1)        
      else 
         gpio.write(DIN, 0)   
      end;     
      gpio.write(CLK, 1)    
      i=i-1
   end
end

function regSet(reg, value)  -- Set Register value (16 bits)
   gpio.write(CS, 0)
   writeByte(reg)   
   writeByte(value) 
   gpio.write(CS, 0)    
   gpio.write(CS, 1)
end

function outByte(count)      -- Output 8 bytes of data
   regSet(8, data[1 + count])
   regSet(7, data[2 + count])
   regSet(6, data[3 + count])
   regSet(5, data[4 + count]) 
   regSet(4, data[5 + count])
   regSet(3, data[6 + count])
   regSet(2, data[7 + count])
   regSet(1, data[8 + count])        
end

set_MAX_Registers()  
q=0 
tmr.alarm(0,100,1,function()     
   --print(q)
   outByte(q)   
   q = q + 1
   if (q > 27) then 
      q = 0 
   end 
end)
 