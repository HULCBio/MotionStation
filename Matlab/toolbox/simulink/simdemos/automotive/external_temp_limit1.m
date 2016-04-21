
% Copyright 2003 The MathWorks, Inc.

set_param('auto_climatecontrol/External Temperature in Celsius/External Temp','Value',num2str(x))

ext_temp_value = get_param('auto_climatecontrol/External Temperature in Celsius/External Temp','Value');

if str2num(ext_temp_value) > 100,
    set_ini_cond = 100;
elseif str2num(ext_temp_value) < -99,
    set_ini_cond = -99;
else 
    set_ini_cond = str2num(ext_temp_value);
end

set_param('auto_climatecontrol/Interior Dynamics/Tcabin','InitialCondition',num2str(set_ini_cond+273))
