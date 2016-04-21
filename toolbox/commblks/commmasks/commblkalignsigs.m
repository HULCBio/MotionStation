function commblkalignsigs(block, action)
% COMMBLKALIGNSIGS Mask dynamic dialog function for Align Signals block

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2002/10/20 12:43:03 $

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
  maskCorrLength       = [];
  maskStopUpdate       = [];
  maskNumConstDelay    = [];
  numConstDelayDefault = '3';
  
  % --- Set Field index numbers and mask variable data
  setallfieldvalues(block);
  
  % --- Ensure that the mask is correct
  cbStopUpdate(block);
  
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
  
otherwise
  error('Unknown argument for function ''commblkalignsigs''');
  
end   % end of switch(action) statement
return;

% ----------------
% --- Subfunctions
% ----------------

%*****************************************************************************
% Function Name:    cbStopUpdate
% Description:      Modify the mask based on en(dis)abling of continuous updates
%                   of the computed delay
% Inputs:           current block, Value, and Enable cell arrays
% Return Values:    Modified Value and Enable cell arrays
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

% [EOF] commblkalignsigs.m