function varargout = dspblkadpt(action)
% DSPBLKADPT Mask dynamic dialog function for adaptive filters

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/26 23:27:56 $

blk=gcb;
if nargin==0, action = 'dynamic'; end
switch action
   case 'init'
      % The 5th and 6th dialog entries (both checkboxes)
      %  optionally add an enable and reset port to the block
      updateAdaptPort(blk);
      updateResetPort(blk);
   otherwise
      error('Unhandled case');
end


% -----------------------------------------------      
function updateAdaptPort(blk)
% Manage the "adapt" feature
% Make port appear if user wants adaptation-hold control
% Make port disappear if user does not want control over this
%
% Practically, this is performed by swapping a constant block
% for a port, and vice-versa

adaptBlk      = [blk '/Adapt'];
isAdaptPortPresent = strcmp(get_param(adaptBlk,'BlockType'),'Inport');
wantAdaptPort      = strcmp(get_param(blk,'Adapt'),'on');
if wantAdaptPort & ~isAdaptPortPresent,
    % Change Constant to Port
    pos = get_param(adaptBlk,'Position');
    delete_block(adaptBlk);
    
    % NOTE! Be sure to make this the 3rd input port
    % There is a situation in which this will become the 4th input port,
    % unless we're careful to set this explicitly.  Here's the scenario:
    % Block is configured for a Reset port, but no Enable port.  Hence,
    % the Reset port is the 3rd port.  Then, you add the Reset port, and
    % by default it goes in as the 4th port.  Hence, an inconsistency can
    % develop as to which port is which feature.
    %
    add_block('built-in/Inport',adaptBlk, ...
              'Position', pos, ...
              'Port', '3');

elseif ~wantAdaptPort & isAdaptPortPresent,
    % Change Port to Constant
    pos = get_param(adaptBlk,'Position');
    delete_block(adaptBlk);
    add_block('built-in/Constant',adaptBlk, ...
              'Position',pos,'Value', ...
              'boolean(1)');
end
      

% -----------------------------------------------      
function updateResetPort(blk)
% Manage the "reset" feature
% Make port appear if user wants adaptation-hold control
% Make port disappear if user does not want control over this
%
% Practically, this is performed by swapping a constant block
% for a port, and vice-versa

resetBlk = [blk '/Reset'];
try
    isResetPortPresent = strcmp(get_param(resetBlk,'BlockType'),'Inport');
catch
    % There is no reset port for older version of adaptive filter
    return;
end
resetMode = get_param(blk,'RstPort');  % Get popup state
wantResetPort = ~strcmp(resetMode,'None');

% Adjust ports/constants
if wantResetPort & ~isResetPortPresent,
    % Change Constant to Port
    pos = get_param(resetBlk,'Position');
    delete_block(resetBlk);
    
    % Note: this can be either the 3rd or 4th port, depending
    %   on whether the Adapt port is present.  Not specifying
    %   the port number causes the desired behavior without
    %   specifically managing this.
    %
    add_block('built-in/Inport',resetBlk, ...
              'Position',pos);
elseif ~wantResetPort & isResetPortPresent,
    % Change Port to Constant
    pos = get_param(resetBlk,'Position');
    delete_block(resetBlk);
    add_block('built-in/Constant',resetBlk, ...
              'Position',pos, ...
              'Value','boolean(0)');
end

% Update reset mode of unit delay block:
delayBlk = [blk '/Update/Filter Taps'];
corrBlk  = [blk '/Update/Coefficient Update/Correlation'];
currentResetMode = get_param(delayBlk,'reset_popup');
% Don't turn off reset mode - in 'None' mode, we leave
% it at "Non-zero sample" with a constant-0 input.
if strcmp(resetMode,'None'),
    resetMode='Non-zero sample';
end
if ~strcmp(currentResetMode, resetMode),
    set_param(delayBlk,'reset_popup',resetMode);
    try,
        set_param(corrBlk,'reset_popup',resetMode);
    catch,
    end
end

% [EOF] dspblkadpt.m
