% M-script: sldemo_create_tc_tabledata.m
%
% Create data in current workspace for file sldemo_tc.mdl
%
%

% roa, 2004-Feb-15
% Copyright 1991-2004 The MathWorks, Inc.
% $Revision: 1.1.4.2 $

% --- The data file below was created with the readstdtcdata.m function

if exist('thermocouple_its90.mat','file') ~= 0
    load thermocouple_its90.mat
else
    error( ...
        ['Data file thermocouple_its90.mat was not found.  Please ', ...
         'see the Simulink demos area and read the thermocouple demo', ...
         'for instructions on making this file with readstdtcdata.m']);
end

% --- get the Type S data for voltage and temperature

es = tcdata(7).VData;  % in millivolts!
ts = tcdata(7).TData;

% --- Create a table entry for each voltage that corresponds
%     to a value the A/D converter is scaled to in sldemo_tc.mdl.
%     The temperature data will go into the block named:
%
%     sldemo_tc/
%     Software specification for converting
%     ADC values to temperature/
%     Type S direct conversion
%
%     The linear space is volts:    
%
%          0 counts is       -0.236 mV /  -50 degC, 
%       4096 counts would be 18.661 mV / 1765 degC

e_vs_counts = -0.236 + (0:4095)' * (1/4096) * (18.661 - (-0.236));
TypeS_tdegc_vs_bits = single(interp1(es,ts,e_vs_counts, 'linear','extrap'));


% --- Create breakpoint and table data for block:
%
%     sldemo_tc/
%     Software specification for converting
%     ADC values to temperature/
%     Type S interpolated conversion
%
%     The linear space is volts:    
%
%          0 counts is       -0.236 mV /  -50 degC, 
%       4096 counts would be 18.661 mV / 1765 degC

TypeS_bits_bp = [(0:50:4095)'; 4095];
TypeS_millivolts_bp = -0.236 + TypeS_bits_bp * (1/4096) * (18.661 - (-0.236));

% do the interpolation in double precision, then downcast

TypeS_tdegc_interp = single(interp1(es,ts,TypeS_millivolts_bp,'linear','extrap'));
TypeS_bits_bp      = single(TypeS_bits_bp);

% --- Create breakpoint and table data for block:
%
%   sldemo_tc/Type S Thermocouple model/
%   Type S thermocouple voltage characteristic (with 0C ice ref)
%
%     The linear space is degC:    
%
%          0 counts is       -0.236 mV /  -50 degC, 
%       4096 counts would be 18.661 mV / 1765 degC

TypeS_T_degC  = (-50:1765)';
TypeS_E_Volts = 0.001 * interp1(ts,es,TypeS_T_degC,'linear');

% --- clean up

clear tcdata es ts TypeS_millivolts_bp

%[EOF] sldemo_create_tc_tabledata.m
