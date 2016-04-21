function rtwdemo_basicsc_config(model, optimization, sc)
%RTWDEMO_BASICSC_CONFIG  Configure model for basic data packaging demo.

% $Revision: 1.1.4.1 $
% $Date: 2004/04/19 01:16:56 $
%
% Copyright 1994-2002 The MathWorks, Inc.

switch nargin
 case 1
  optimization = 'on';
  sc = 'Auto';
 case 2
  sc = 'Auto';
 case 3
  % No action
 otherwise
  error('Invalid number of input arguments.');
end

evalin('base', 'clear');

% Reset model settings to default state:
model = get_param(model, 'Handle');
set_param(model, ...
          'RTWInlineParameters',      optimization, ...
          'OptimizeBlockIOStorage',   optimization, ...
          'TunableVars',              '', ...
          'TunableVarsStorageClass',  '', ...
          'TunableVarsTypeQualifier', '');

% Define signals
l_ConfigSignal(model, 'input1',  sc);
l_ConfigSignal(model, 'input2',  sc);
l_ConfigSignal(model, 'input3',  sc);
l_ConfigSignal(model, 'input4',  sc);
l_ConfigSignal(model, 'option1', sc);
l_ConfigSignal(model, 'option2', sc);
l_ConfigSignal(model, 'output',  sc);

% Define states
l_ConfigState(model, 'DataStoreMemory', 'DataStoreName',   'mode', sc);
l_ConfigState(model, 'UnitDelay',       'StateIdentifier', 'X',    sc);

% Define parameters
l_ConfigParam(model, 'K1',      sc, int8(2));
l_ConfigParam(model, 'K2',      sc, 3);
l_ConfigParam(model, 'T1Break', sc, [-5:5]);
l_ConfigParam(model, 'T1Data',  sc, [-1,-0.99,-0.98,-0.96,-0.76,0,0.76,0.96,0.98,0.99,1]);
l_ConfigParam(model, 'T2Break', sc, [1:3])
l_ConfigParam(model, 'T2Data',  sc, [4 5 6;16 19 20;10 18 23]);
l_ConfigParam(model, 'UPPER',   sc, 10);
l_ConfigParam(model, 'LOWER',   sc, -10);

% Set color of current configuration block.
configBlks = find_system(model, 'MaskType', 'Basic data packaging - configure model');
for idx = 1:length(configBlks)
  set_param(configBlks(idx), 'BackGroundColor', 'Gray');
end
set_param(gcbh, 'BackGroundColor', 'Red');


%============================================================
% SUBFUNCTIONS:
%============================================================
function l_ConfigSignal(model, name, sc)
% Configure settings in the model for a particular piece of data.

hPort = find_system(model, 'FindAll', 'on', 'Type', 'port', 'Name', name);

switch sc
 case 'SimulinkGlobal'
  tP = 'on';
  sc = 'Auto';
 case {'Auto', 'ExportedGlobal'}
  tP = 'off';
 otherwise
   error('Unexpected storage class.');
end

set_param(hPort, ...
          'TestPoint',                 tP, ...
          'MustResolveToSignalObject', 'off', ...
          'RTWStorageClass',           sc, ...
          'RTWStorageClass',           sc, ...
          'RTWStorageTypeQualifier',   '');

%endfunction

%============================================================
function l_ConfigState(model, blockType, propForName, name, sc)
% Configure settings in the model for a particular piece of data.

hBlk = find_system(model, ...
                   'BlockType', blockType, ...
                   propForName, name);

switch sc
 case 'SimulinkGlobal'
  sc = 'Auto';
 case {'Auto', 'ExportedGlobal'}
  % No action
 otherwise
   error('Unexpected storage class.');
end

set_param(hBlk, ...
          'StateMustResolveToSignalObject', 'off', ...
          'RTWStateStorageClass',           sc, ...
          'RTWStateStorageClass',           sc, ...
          'RTWStateStorageTypeQualifier',   '');

%endfunction

%============================================================
function l_ConfigParam(model, name, sc, value)
% Create parameter and add it to the list of tunable variables

assignin('base', name, value);
  
if strcmp(sc, 'Auto')
  % Do not add it to the list of tunable vars.
else
  % Get current model settings:
  tunVars = get_param(model, 'TunableVars');
  tunSC   = get_param(model, 'TunableVarsStorageClass');
  tunTQ   = get_param(model, 'TunableVarsTypeQualifier');
  firstVar = isempty(tunVars);
  
  % Add parameter name
  tunVars = [tunVars, ',', name];

  % Add storage class setting
  switch sc
   case 'SimulinkGlobal'
    tunSC = [tunSC, ',Auto'];
   case 'ExportedGlobal'
    tunSC = [tunSC, ',ExportedGlobal'];
   otherwise
    error('Unexpected storage class.');
  end
  
  % Add empty type qualifier setting
  tunTQ = [tunTQ, ','];
  
  % Remove leading ',' for first variable
  if firstVar
    tunVars(1) = '';
    tunSC(1)   = '';
    tunTQ(1)   = '';
  end
  
  % Update model settings:
  set_param(model, ...
            'TunableVars',              tunVars, ...
            'TunableVarsStorageClass',  tunSC, ...
            'TunableVarsTypeQualifier', tunTQ);
end
  
%endfunction
  
% EOF