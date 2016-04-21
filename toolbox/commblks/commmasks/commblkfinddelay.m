function commblkfinddelay(block, action)
% COMMBLKFINDDELAY Mask dynamic dialog function for the Find Delay block

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:02:53 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************

switch(action)
  
  %*********************************************************************
  % Function Name:     init
  % Description:       Main initialization code
  % Inputs:            current block
  % Return Values:     none
  %********************************************************************
case 'init'
  % --- Declare variables to avoid any collisions with other variables/functions
  % --- on the path
  maskCorrLength    = [];
  maskChgSigOP      = [];
  maskStopUpdate    = [];
  maskNumConstDelay = [];
  numConstDelayDefault = '3';  
  
  % --- Set Field index numbers and mask variable data
  setallfieldvalues(block);
  
  % --- Ensure that the mask is correct
  cbStopUpdate(block);
  cbChgSigOP(block);
  
  % Error checking
  
  % Correlation window length
  if (isempty(maskCorrLength) || ...
      numel(maskCorrLength) ~= 1 || ...
      maskCorrLength <= 0 || ...
      round(maskCorrLength) ~= maskCorrLength || ...
      maskCorrLength == inf || ...
      ischar(maskCorrLength))
    error('The correlation window length must be a positive integer scalar');
  end
  
  % Number of constant delay outputs to disable updates
  if (maskStopUpdate == 1)
    if (isempty(maskNumConstDelay) || ...
        numel(maskNumConstDelay) ~= 1 || ...
        maskNumConstDelay < 3 || ...
        round(maskNumConstDelay) ~= maskNumConstDelay || ...
        maskNumConstDelay == inf || ...
        ischar(maskNumConstDelay))
      error('The number of constant delay outputs to disable updates must be an integer scalar greater than 2');
    end
  end

  % Even if the "Disable ongoing updates" option is off, the number of constant delay
  % outputs to disable updates must be set to at least 3 in order to satisfy some
  % dimension requirements in the Enable Logic
  if (maskStopUpdate == 0 && ...
      maskNumConstDelay < 3)
    MN = get_param(block,'MaskNames');
    for i = 1:length(MN)                % Protect against new future mask variables
      if (strcmp(MN{i}, 'numConstDelay'))
        set_param(block, MN{i}, numConstDelayDefault);
      end
    end
  end 
  
% ---- end of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbStopUpdate'
    cbStopUpdate(block);
  
case 'cbChgSigOP'
    cbChgSigOP(block);
  
otherwise
    error('Unknown argument for function ''commblkfinddelay''');
  
end     % end of switch(action) statement
return;

% ----------------
% --- Subfunctions
% ----------------

%*****************************************************************************
% Function Name:    cbStopUpdate
% Description:      Modify the mask based on en(dis)abling of continuous updates
%                   of the computed delay
% Inputs:           current block, Value, and Visibility cell arrays
% Return Values:    Modified Value and Visibility cell arrays
%*****************************************************************************
function cbStopUpdate(block)

% --- Set Field index numbers
setfieldindexnumbers(block);

Vals  = get_param(block, 'MaskValues');
Vis   = get_param(block, 'MaskVisibilities');

switch lower(Vals{idxStopUpdate})
    case 'on'
        Vis{idxNumConstDelay} = 'on';
        set_param(block, 'MaskVisibilities', Vis);
    case 'off'
        Vis{idxNumConstDelay} = 'off';
        set_param(block, 'MaskVisibilities', Vis);
    otherwise
        error('Unknown value for "Disable recurring updates" checkbox');
end
return;

%*****************************************************************************
% Function Name:    cbChgSigOP
% Description:      Modify the mask based on en(dis)abling of the optional
%                   "changed signal" output port
% Inputs:           current block and Value cell arrays
% Return Values:    "Change signal" output port label
%*****************************************************************************
function cbChgSigOP(block)

% --- Set Field index numbers
setfieldindexnumbers(block);

Vals  = get_param(block, 'MaskValues');

numOPPorts = find_system(block, 'LookUnderMasks', 'all', ...
    'FollowLinks', 'on', 'SearchDepth', 1, 'BlockType', 'Outport');
hasChgPort = max(size(numOPPorts)) == 2;
switch lower(Vals{idxChgSigOP})
    case 'on'
        % If the "Changed signal" output port already exists, then do not create
        % any new ports.  (The port exists if the size of numOPPorts is 2 x 1.)
        % If the port doesn't exist, delete the terminator block and create the
        % port in the subsystem under the top-level block.
        if (~hasChgPort)
            pos = get_param([block '/Terminator'], 'Position');
            delete_block([block '/Terminator']);
            add_block('built-in/Outport', [block '/chg'], ...
                'Position', pos);
        end

    case 'off'
        % If the "Changed signal" output port already does not exist, then do
        % not delete it.  (The port exists if the size of numOPPorts is 1 x 1.)
        % If the port does exist, then delete it and add a terminator instead.
        if (hasChgPort)
            pos = get_param([block '/chg'], 'Position');            
            delete_block([block '/chg']);
            add_block('built-in/Terminator', [block '/Terminator'], ...
                'Position', pos);
        end
        
    otherwise
        error ...
         ('Unknown value for "Include "change signal" output port checkbox.');
end
return;

% [EOF] commblkfinddelay.m
