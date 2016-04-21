function [s] = dspblkblms(action)
% DSPBLKBLMS Mask dynamic dialog function for adaptive filters
% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/10/10 20:53:01 $

blk=gcb;
s=[];
if nargin==0, action = 'init'; end
switch action
   case 'init'
     updateStepPort(blk);
     updateAdaptPort(blk);
     updateResetPort(blk);
     load_system('dspsigattribs');  %for to frame
     updateweightsoutput(blk);
     CheckandSetIC(blk);
 case 'addparams' %called when additional parameters checkbox is selected
                   %or when step size input option is changed
      AddParams(blk);
  otherwise % should not come here
      error('Unhandled case');
end

% -----------------------------------------------
function AddParams(blk)
STEPSIZE = 4;
origmaskvis = get_param(blk,'MaskVisibilities');
ap = get_param(blk, 'addnparflag');
wantStepPort = strcmp(get_param(blk, 'stepflag'),'Input port');
if (strcmp(ap, 'off'))
    newflags = {'on', 'on', 'on', 'on', 'on', 'on', 'off', 'off', 'off', 'off'};
else
    newflags = {'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on'};
end
if wantStepPort
    newflags{STEPSIZE} = 'off';
else
    newflags{STEPSIZE} = 'on';
end

if ~isequal(origmaskvis, newflags)
    set_param(blk, 'MaskVisibilities', newflags);
end

% -----------------------------------------------
function updateStepPort(blk)
% Manage the "stepflag" feature
% Make port appear if user wants step-size as input
% Make port disappear if user does not want step size as input.
%
% mu is either from a port or a parameter in a gain block.
% if we were to use constant block to switch instead of a port
% we wont get free parameter data type conversion. for eg. if inputs
% were single unless the user enters single(mu) in the mask the block
% wont work.

%step port will always be port 3

isStepPortPresent = exist_block(blk, 'Stepsize');
wantStepPort      = strcmp(get_param(blk, 'stepflag'),'Input port');
cr = sprintf('\n');
if wantStepPort && ~isStepPortPresent,
    % add step port
    set_param([blk '/For Iterator' cr 'Subsystem'], 'stepflag_for', 'on');
    add_block('built-in/Inport', [blk '/Stepsize'],...
        'Port', '3', 'Position', [135   298   165   312]);
    add_line(blk, 'Stepsize/1', ['For Iterator' cr 'Subsystem/6']);
elseif ~wantStepPort && isStepPortPresent,
    % Remove ports
    delete_line(blk, 'Stepsize/1', ['For Iterator' cr 'Subsystem/6']);
    delete_block([blk '/Stepsize']);
    set_param([blk '/For Iterator' cr 'Subsystem'], 'stepflag_for', 'off');
end

%-----------------------------------------------------------
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
if wantAdaptPort && ~isAdaptPortPresent,
    % Change Constant to Port
    pos = get_param(adaptBlk,'Position');
    delete_block(adaptBlk);
    
    % Note: this can be either the 3rd or 4th or 5th
    %   on whether the step port and adapt port are present.
    %   You have to specify the port number accordingly.
    %  
    
    stepBlk = [blk '/Stepsize'];
    isStepPortPresent = exist_block(blk, 'Stepsize');
    isResetPortPresent = strcmp(get_param([blk, '/Reset'], 'BlockType'),'Inport');
    portnum = num2str(3+isResetPortPresent+isStepPortPresent);

    add_block('built-in/Inport',adaptBlk, ...
              'Position', pos, ...
              'Port', portnum);

elseif ~wantAdaptPort && isAdaptPortPresent,
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
% Make port appear if user wants to reset
% Make port disappear if user does not want control over this
%
% Practically, this is performed by swapping a constant block
% for a port, and vice-versa

% reset port will always be the last input port
resetBlk = [blk '/Reset'];
isResetPortPresent = strcmp(get_param(resetBlk,'BlockType'),'Inport');
resetMode = get_param(blk,'resetflag');  % Get popup state
wantResetPort = ~strcmp(resetMode,'None');

% Adjust ports/constants
if wantResetPort && ~isResetPortPresent,
    % Change Constant to Port
    pos = get_param(resetBlk,'Position');
    delete_block(resetBlk);

    add_block('built-in/Inport',resetBlk, ...
              'Position',pos);
          
elseif ~wantResetPort && isResetPortPresent,
    % Change Port to Constant
    pos = get_param(resetBlk,'Position');
    delete_block(resetBlk);
    add_block('built-in/Constant',resetBlk, ...
              'Position',pos, ...
              'Value','boolean(0)');
end

cr = sprintf('\n');
% Update reset mode of unit delay block:
delayBlk = [blk '/For Iterator' cr 'Subsystem/Filter Taps'];
currentResetMode = get_param(delayBlk,'reset_popup');
% Don't turn off reset mode - in 'None' mode, we leave
% it at "Non-zero sample" with a constant-0 input.
if strcmp(resetMode,'None'),
    resetMode='Non-zero sample';
end
if ~strcmp(currentResetMode, resetMode),
    set_param(delayBlk,'reset_popup',resetMode);
end

%----------------------------------------------------------
function updateweightsoutput(blk)

cr = sprintf('\n');

%update weight output
weights = get_param(blk, 'weights');
systempath = [blk , '/Frame-Based' cr 'LMS Filter'];
if (strcmp(weights, 'No weights'))
    %first delete at the upper level
    if (exist_block(blk, 'Wts'))
        delete_line(blk, ['For Iterator' cr 'Subsystem/3'], 'To Sample/1');
        delete_line(blk, 'To Sample/1', 'Wts/1');
        delete_block([blk '/To Sample']);
        delete_block([blk '/Wts']);
        set_param([blk , '/For Iterator' cr 'Subsystem'], 'weights_for', 'No output');
    end
else 
    if (strcmp(weights, 'Last in frame'))
        set_param([blk , '/For Iterator' cr 'Subsystem'], 'weights_for', 'Last in frame');
    else
        set_param([blk , '/For Iterator' cr 'Subsystem'], 'weights_for', 'All weights');
    end
    if ~(exist_block(blk, 'Wts'))
        add_block(['dspsigattribs/Frame Status' cr 'Conversion'], [blk '/To Sample'],...
            'Position', [500   262   525   298], 'outframe', 'Sample-based');
        add_block('built-in/Outport', [blk, '/Wts'], ...
            'Position', [550   273   580   287]);        
        add_line(blk, ['For Iterator' cr 'Subsystem/3'], 'To Sample/1');
        add_line(blk, 'To Sample/1', 'Wts/1');
    end
end

%----------------------------------------------------------
function present = exist_block(sys, name)
try
    present = ~isempty(get_param([sys '/' name], 'BlockType'));
catch
    present = false;
end

% -----------------------------------------------
function Add_Block(sys, name, libname, betweenthis, betweenthat, athere)
% Adds block libname as 'name' to 'sys' 'betweenthis' and 'betweenthat' positioned
% athere.
% It is assumed that the inserted block has one input and one output port
if (~exist_block(sys, name))
    delete_line(sys, betweenthis, betweenthat);
    add_block(libname, [sys, '/', name]);
    set_param([sys, '/', name], 'Position', athere);
    add_line(sys, betweenthis, [name, '/1']);
    add_line(sys, [name, '/1'], betweenthat);
end

% -----------------------------------------------
function Delete_Block(sys, name, betweenthis, betweenthat)
% Removes block 'name' in 'sys' 'betweenthis' and 'betweenthat' and
% connects the broken link
% It is assumed that the deleted block has one input and one output port
if (exist_block(sys, name))
    delete_line(sys, betweenthis, [name, '/1']);
    delete_line(sys, [name, '/1'], betweenthat);
    delete_block([sys, '/', name]);
    add_line(sys, betweenthis, betweenthat);
end

% -----------------------------------------------
function CheckandSetIC(blk)
%Checks the length of ic and sets the parameter in the delay block
%accordingly
cr = sprintf('\n');
try
    ic = evalin('base', get_param(blk, 'ic'));
    if (length(ic) > 1)
         set_param([blk '/For Iterator' cr 'Subsystem/Filter Taps'], 'dif_ic_for_dly', 'on');
    else
         set_param([blk '/For Iterator' cr 'Subsystem/Filter Taps'], 'dif_ic_for_dly', 'off');
    end
catch
end

% [EOF] dspblkblms.m
