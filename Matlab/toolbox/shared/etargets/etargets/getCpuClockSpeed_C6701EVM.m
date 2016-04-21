function HzVal = getCpuClockSpeed_C6701EVM
% Extract CPU clock speed value from RTW Options.
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:58 $
% Copyright 2002-2003 The MathWorks, Inc.

configSet = getActiveConfigSet(gcs);
c1 = get_param(configSet, 'c6701evmCpuClockRate');
% popupstrings = '25MHz|33.25MHz|100MHz|133MHz';
c2 = strrep(c1,'MHz','');
HzVal = str2num(c2) * 1e6;

% EOF   getCpuClockSpeed_C6701EVM