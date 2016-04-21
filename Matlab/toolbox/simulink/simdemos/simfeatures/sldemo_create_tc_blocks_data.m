%SLDEMO_CREATE_TC_BLOCKS_DATA data for example thermocouple lookup tables
%
% The tcvoltage.m and tctemp.m functions can be obtained from MATLAB 
% Central.

% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/01 16:22:54 $ 

if exist('tcvoltage.m') ~= 2,
    error(['The tcvoltage.m and tctemp.m functions needed '...
        'for this demo can be obtained from MATLAB Central.']);
end

TypeB_degC  = [0:1820];
TypeB_degC  = TypeB_degC(1:2:end);
TypeB_Volts = tcvoltage('B', TypeB_degC);

TypeE_degC  = [-270:1000];
TypeE_degC  = TypeE_degC(1:2:end);
TypeE_Volts = tcvoltage('E', TypeE_degC);

TypeJ_degC = [-210:1200];
TypeJ_degC = TypeJ_degC(1:2:end);
TypeJ_Volts = tcvoltage('J', TypeJ_degC);

TypeK_degC = [-270:1372];
TypeK_degC = TypeK_degC(1:2:end);
TypeK_Volts = tcvoltage('K', TypeK_degC);

TypeN_degC = [-270:1300];
TypeN_degC = TypeN_degC(1:2:end);
TypeN_Volts = tcvoltage('N', TypeN_degC);

TypeR_degC = [-50:1768];
TypeR_degC = TypeR_degC(1:2:end);
TypeR_Volts = tcvoltage('R', TypeR_degC);

TypeS_degC = [-50:1768];
TypeS_degC = TypeS_degC(1:2:end);
TypeS_Volts = tcvoltage('S', TypeS_degC);

TypeT_degC = [-270:400];
TypeT_degC = TypeT_degC(1:2:end);
TypeT_Volts = tcvoltage('T', TypeT_degC);

save sldemo_tc_blocks_data.mat

%[EOF] sldemo_create_tc_blocks_data.m