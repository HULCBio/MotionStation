function dspblkfblms(action)
% DSPBLKFBLMS Mask dynamic dialog function for fast block lms adaptive filter
% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:25 $

blk=gcb;
if nargin==0, action = 'init'; end
cr = sprintf('\n');
switch action
   case 'init'
     set_param([blk '/BLMS For Iterator' cr 'Subsystem'], 'algo_for', get_param(blk, 'algo'));
     updateStepPort(blk);
     updateAdaptPort(blk);
     updateResetPort(blk);
     load_system('dspsigattribs');  %for To Frame
     updateweightsoutput(blk);
     blkparent = blk;
     CheckParameters(blk);
     CheckandSetIC(blk);
  case 'addparams' %called when additional parameters checkbox is selected
                   %or when step size input option is changed
      AddParams(blk);
  otherwise % should not come here
      error('Unhandled case');
end

% -----------------------------------------------
function AddParams(blk)
STEPSIZE = 5;
origmaskvis = get_param(blk,'MaskVisibilities');
ap = get_param(blk, 'addnparflag');
wantStepPort = strcmp(get_param(blk, 'stepflag'),'Input port');
if (strcmp(ap, 'off'))
    newflags = {'off', 'on', 'on', 'on', 'on', 'on', 'on', 'off', 'off', 'off', 'off'};
else
    newflags = {'off', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on'};
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
%step port will always be port 3

stepBlk      = [blk '/Step-size'];
isStepPortPresent = strcmp(get_param(stepBlk,'BlockType'),'Inport');
wantStepPort      = strcmp(get_param(blk, 'stepflag'),'Input port');
if wantStepPort && ~isStepPortPresent,
    % Change Constant to Port
    pos = get_param(stepBlk,'Position');
    delete_block(stepBlk);
    add_block('built-in/Inport',stepBlk, ...
              'Position', pos, ...
              'Port', '3');

elseif ~wantStepPort && isStepPortPresent,
    % Change Port to Constant
    pos = get_param(stepBlk,'Position');
    delete_block(stepBlk);
    add_block('built-in/Constant',stepBlk, ...
              'Position',pos,'Value', 'mu',...
              'OutDataTypeMode', 'Inherit via back propagation');
end

%-----------------------------------------------------------
function updateAdaptPort(blk)
% Manage the "adapt" feature
% Make port appear if user wants adaptation-hold control
% Make port disappear if user does not want control over this
%
% Practically, this is performed by swapping a constant block
% for a port, and vice-versa

% The adapt port at the top will be either 3rd or 4th port depending on the
% presence of the step port. 

adaptBlk      = [blk '/Adapt'];
isAdaptPortPresent = strcmp(get_param(adaptBlk,'BlockType'),'Inport');
wantAdaptPort      = strcmp(get_param(blk,'Adapt'),'on');
if wantAdaptPort && ~isAdaptPortPresent,
    % Change Constant to Port
    pos = get_param(adaptBlk,'Position');
    delete_block(adaptBlk);
    
    % Note: this can be either the 3rd or 4th depending
    %   on whether the step port is present or not.
    %   You have to specify the port number accordingly.
    %  
    
    stepBlk = [blk '/Step-size'];
    isStepPortPresent = strcmp(get_param(stepBlk,'BlockType'),'Inport');
    portnum = num2str(3+isStepPortPresent);

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
delayBlk = [blk '/BLMS For Iterator' cr 'Subsystem/Algorithm/Filter Taps'];
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
if (strcmp(weights, 'off'))
    %first delete at the upper level
    if (exist_block(blk, 'Wts'))
        delete_line(blk, ['BLMS For Iterator' cr 'Subsystem/3'], 'To Sample/1');
        delete_line(blk, 'To Sample/1', 'Wts/1');
        delete_block([blk '/To Sample']);
        delete_block([blk '/Wts']);
        set_param([blk , '/BLMS For Iterator' cr 'Subsystem'], 'weights_for', 'off');
    end
else
    set_param([blk , '/BLMS For Iterator' cr 'Subsystem'], 'weights_for', 'on');
    if ~(exist_block(blk, 'Wts'))
        add_block(['dspsigattribs/Frame Status' cr 'Conversion'], [blk '/To Sample'],...
            'Position', [500   262   525   298]);
        add_block('built-in/Outport', [blk, '/Wts'], ...
            'Position', [550   273   580   287]);        
        add_line(blk, ['BLMS For Iterator' cr 'Subsystem/3'], 'To Sample/1');
        add_line(blk, 'To Sample/1', 'Wts/1');
    end
end

%----------------------------------------------------------
function present = exist_block(sys, name)
try
    present = ~isempty(get_param([sys '/' name], 'BlockType'));
catch
    present = false;
    sllastdiagnostic([]); %reset the last error
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
function CheckParameters(blk)

CheckLeakage(blk);
Checkmu(blk);
CheckFilterLength(blk);

% -----------------------------------------------
function CheckLeakage(blk)
%Checks validity of the leakage parameter
errorstatus = 0;
try
	leakage = evalin('base', get_param(blk,'leakage'));  % Get leakage
	if (leakage < 0 || leakage > 1 || ~isreal(leakage))
        errorstatus = 1;
	end
catch
end
if (errorstatus)
    error('Leakage factor should be between 0 and 1.');
end

% -----------------------------------------------
function Checkmu(blk)
%Checks validity of the mu parameter

noStepPort = strcmp(get_param(blk,'stepflag'),'Dialog');

if (noStepPort)
    %check mu
    errorstatus = 0;
    try    
        mu = evalin('base', get_param(blk,'mu'));  % Get leakage
        if (length(mu) > 1 || mu < 0 || ~isreal(mu))
            errorstatus = 1;
        end
    catch
    end
    if (errorstatus)
        error('Step-size value should be a real, positive scalar.');
    end
end

% -----------------------------------------------
function CheckFilterLength(blk)
%Checks validity of the filter length parameter

errorstatus = 0;
try
    N = evalin('base', get_param(blk,'N'));  % Get length
    if (N < 0 || (round(N) ~= N))
        errorstatus = 1;
    end
catch
end
if (errorstatus)
    error('Filter length should be an integer greater than 0.');
end

% -----------------------------------------------
function CheckandSetIC(blk)
%Checks the length of ic and sets the parameter in the delay block
%accordingly
cr = sprintf('\n');
dific = get_param([blk '/BLMS For Iterator' cr 'Subsystem/Algorithm/Filter Taps'], 'dif_ic_for_dly');
dificison = strcmp(dific,'on');
try
    ic = evalin('base', get_param(blk, 'ic'));
    if (length(ic) > 1)
        if (~dificison)
            set_param([blk '/BLMS For Iterator' cr 'Subsystem/Algorithm/Filter Taps'],...
                'dif_ic_for_dly', 'on');
        end
    else
        if (dificison)
            set_param([blk '/BLMS For Iterator' cr 'Subsystem/Algorithm/Filter Taps'],...
                'dif_ic_for_dly', 'off');
        end
    end
catch
end

% [EOF] dspblkblms.m
