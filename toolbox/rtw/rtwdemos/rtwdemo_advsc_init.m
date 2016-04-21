function rtwdemo_advsc_init(sc)
%RTWDEMO_ADVSC_INIT  Define Simulink data objects for advanced data packaging demo.

% $Revision: 1.1.6.1 $
% $Date: 2004/04/19 01:16:55 $
%
% Copyright 1994-2002 The MathWorks, Inc.

switch nargin
 case 0
  sc = 'Auto';
 case 1
  % No action
 otherwise
  error('Invalid number of input arguments.');
end

evalin('base', 'clear');

% Define signals
l_CreateData('input1',  'Signal', sc);
l_CreateData('input2',  'Signal', sc);
l_CreateData('input3',  'Signal', sc);
l_CreateData('input4',  'Signal', sc);
l_CreateData('output',  'Signal', sc);

% Define states
l_CreateData('mode', 'State', sc);
l_CreateData('X',    'State', sc);

% Define parameters
l_CreateData('K1',      'Parameter', sc, int8(2));
l_CreateData('K2',      'Parameter', sc, 3);
l_CreateData('T1Break', 'Parameter', sc, [-5:5]);
l_CreateData('T1Data',  'Parameter', sc, [-1,-0.99,-0.98,-0.96,-0.76,0,0.76,0.96,0.98,0.99,1]);
l_CreateData('T2Break', 'Parameter', sc, [1:3])
l_CreateData('T2Data',  'Parameter', sc, [4 5 6;16 19 20;10 18 23]);
l_CreateData('UPPER',   'Parameter', sc, 10);
l_CreateData('LOWER',   'Parameter', sc, -10);

% Set color of current configuration block.
model = get_param(bdroot(gcbh), 'Handle');
configBlks = find_system(model, 'MaskType', 'Advanced data packaging - create data');
for idx = 1:length(configBlks)
  set_param(configBlks(idx), 'BackGroundColor', 'Gray');
end
set_param(gcbh, 'BackGroundColor', 'Red');


%============================================================
% SUBFUNCTIONS:
%============================================================
function l_CreateData(name, dClass, sc, value)
% Create a data object in the base workspace

% Special handling for different classes of data.
switch dClass
 case 'Parameter'
  tmpObj = Simulink.Parameter;
  % Set Value
  tmpObj.Value = value;
  % Set StructName for Custom storage class
  structName = 'PARAM';
  
 case 'Signal'
  tmpObj = Simulink.Signal;
  % Set StructName for Custom storage class
  structName = 'SIGNAL';
  
 case 'State'
  tmpObj = Simulink.Signal;
  % Set StructName for Custom storage class
  structName = 'STATE';
 
 otherwise
  error('Invalid data object class.');
end

% Set common data attributes:
% - StorageClass
tmpObj.RTWInfo.StorageClass = sc;

% - CustomStorageClass
if strcmp(sc, 'Custom')
  tmpObj.RTWInfo.CustomStorageClass = 'Struct';
  tmpObj.RTWInfo.CustomAttributes.StructName = structName;
end

% Set Dimensions for Data Store Memory.
if strcmp(name, 'mode')
  tmpObj.Dimensions = [1 1];
end

% Add variable to base workspace.
assignin('base', name, tmpObj);
  
%endfunction

% EOF