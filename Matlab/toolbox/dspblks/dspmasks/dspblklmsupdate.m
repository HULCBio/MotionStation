function [s] = dslblklmsupdate(action)
% DSPBLKLMSUPDATE Mask dynamic dialog function for LMS adaptive filters update
% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:06:48 $

blk=gcb;
s=[];
if nargin==0, action = 'init'; end
switch action
   case 'init'
      % There are checkboxes that optionally
      % add an enable and reset port to the block
      s = drawIcon(blk);
      load_system('dspmathops'); %for normalization
      updateAdaptPort(blk);
      updateStepPort(blk);
      updateBlock(blk);
      CheckParameters(blk);
  case 'stepflag' %called when the stepsize input option is changed
      updateStep(blk);
  otherwise % should not come here
      error('Unhandled case');
end

% -----------------------------------------------
function s = drawIcon(blk)
%Draw the algorithm name on the block
algorithm = get_param(blk, 'Algo');
switch algorithm
    case 'LMS'
        s = 'LMS';
    case 'Normalized LMS'
        s = strvcat('Normalized','   LMS   ');
    case 'Sign-Error LMS'
        s = strvcat('Sign-Error','   LMS   ');
    case 'Sign-Data LMS'
        s = strvcat('Sign-Data','   LMS   ');
    case 'Sign-Sign LMS'
        s = strvcat('Sign-Sign','   LMS   ');
    otherwise
        s = 'LMS';  % should not come here
end

% -----------------------------------------------
function updateStep(blk)
% changes visibility of the step size edit box depending on the stepflag

wantStepPort = strcmp(get_param(blk,'stepflag'),'Input port');
if wantStepPort
    set_param(blk,'MaskVisibilities',{'on','on','off','on','on'});
else
    set_param(blk,'Maskvisibilities',{'on','on','on','on','on'});
end

% -----------------------------------------------
function updateStepPort(blk)
% Manage the "stepflag" feature
% Make port appear if user wants step-size as input
% Make port disappear if user does not want step size as input.
%
% Practically, this is performed by swapping a constant block
% for a port, and vice-versa

stepBlk   = [blk '/Stepsize'];
isStepPortPresent = exist_block(blk, 'Stepsize');
wantStepPort      = strcmp(get_param(blk,'stepflag'),'Input port');
fromblk = 'Error/1';
if exist_block(blk, 'SignErr') fromblk = 'SignErr/1'; end
if wantStepPort && ~isStepPortPresent,
    % add step port
    add_block('built-in/Inport', stepBlk, ...
              'Position', [50   178    90   192], 'Port', '4');
    set_param([blk '/Product'], 'Inputs', '3');
    add_line(blk, ['Stepsize/1'], ['Product/3']);
      
    % remove gain block
    Delete_Block(blk, 'mu', fromblk, 'Product/1');
elseif ~wantStepPort && isStepPortPresent,
    % Remove ports
    delete_line(blk, 'Stepsize/1', ['Product/3']);
    delete_block([blk, '/Stepsize']);
    Add_Block(blk, 'mu', 'built-in/Gain', fromblk, 'Product/1',...
                [170    80   210   110] );
    set_param([blk '/mu'], 'Gain','mu');
    set_param([blk '/Product'], 'Inputs', '2');            
end

% -----------------------------------------------
function updateAdaptPort(blk)
% Manage the "adapt" (Enable) feature
% Make Enable port appear if user wants adaptation-hold control
% Make Enable port disappear if user does not want control over this
%
% An enable port is added or removed under the subsystem depending on the
% choice.

adaptBlk = [blk '/Adapt'];
isAdaptPortPresent = exist_block(blk, 'Adapt');
wantAdaptPort      = strcmp(get_param(blk,'Adapt'),'on');
if wantAdaptPort && ~isAdaptPortPresent,
    % Change Constant to Port
    add_block('built-in/EnablePort',adaptBlk, ...
              'Position', [30    15    50    35]);
elseif ~wantAdaptPort && isAdaptPortPresent,
    % Change Port to Constant
    delete_block(adaptBlk);
end

% -------------------------------------------------
function updateBlock(blk)
Algo = get_param(blk, 'Algo');

if (strcmp(Algo, 'Normalized LMS'))
    %remove sign block from signal path if it already exists
    Delete_Block(blk, 'SignSig', 'conj/1', 'Product/2');
    %Add normalization block
    sbpos = get_param([blk '/conj'],'Position');
    Add_Block(blk, 'Normalization', 'dspmathops/Normalization',...
        'conj/1', 'Product/2', [sbpos(1)+55,  sbpos(2), sbpos(3)+60, sbpos(4)]);
else
    %remove normalization block
    Delete_Block(blk, 'Normalization', 'conj/1', 'Product/2');
end

toblk = 'Product/1';
if exist_block(blk, 'mu') toblk = 'mu/1'; end
if (strcmp(Algo, 'Sign-Error LMS') || strcmp(Algo, 'Sign-Sign LMS'))
    %Add sign block in error path
    Add_Block(blk, 'SignErr', 'built-in/Signum',...
        'Error/1', toblk, [115    80   145   110]);
else
    %remove sign block from error path
    Delete_Block(blk, 'SignErr', 'Error/1', toblk);
end

if (strcmp(Algo, 'Sign-Data LMS') || strcmp(Algo, 'Sign-Sign LMS'))
    %Add sign block in signal path and remove conjugate block
    if (exist_block(blk, 'conj'))
        sbpos = get_param([blk '/conj'],'Position');
        Delete_Block(blk, 'conj', 'Input/1', 'Product/2');
        Add_Block(blk, 'SignSig', 'built-in/Signum',...
            'Input/1', 'Product/2', sbpos);
    end
else
    %remove sign block from signal path and add conjugate block
    if (exist_block(blk, 'SignSig'))
        sbpos = get_param([blk '/SignSig'],'Position');    
        Delete_Block(blk, 'SignSig', 'Input/1', 'Product/2');
        Add_Block(blk, 'conj', 'built-in/Math', 'Input/1', 'Product/2', sbpos);
        set_param([blk '/conj'], 'Function', 'conj');
    end
end

% -----------------------------------------------
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
%Checks validity of the parameters
Checkleakage(blk);

% -----------------------------------------------
function Checkleakage(blk)
%Checks validity of the leakage parameter

leakage = str2double(get_param(blk,'leakage'));  % Get leakage
if (leakage < 0 || leakage > 1)
    error('Leakage parameter should be between 0 and 1.');
end

% -----------------------------------------------

% [EOF] dslblklmsupdate.m
