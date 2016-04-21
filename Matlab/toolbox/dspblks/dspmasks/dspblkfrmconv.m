function [p, str] = dspblkfrmconv(action,varargin)
%DSPBLKFRMCONV Mask function for Frame Status Conversion block.
%   Implements all block dialog and implementation changes
%   necessary for the Frame Status Conversion block in the
%   Signal Processing Blockset.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:06:34 $

blk = gcb;  % Cache the block handle once
if nargin==0,
    action = 'dynamic';
end

switch action 
case 'init',
    config_block(blk);
    [p,str]=setup_icon(blk);
case 'dynamic',
    update_block_dialog(blk);
end


% -----------------------------------------------
function update_block_dialog(blk)
% Perform dynamic changes to block dialog

ena = get_param(blk, 'MaskEnables');
if is_dialog_inherit(blk),
    if ~strcmp(ena(2), 'off'),
        ena(2) = {'off'};
        set_param(blk, 'MaskEnables', ena);
    end
else
    if ~strcmp(ena(2), 'on'),
        ena(2) = {'on'};
        set_param(blk, 'MaskEnables', ena);
    end
end


% -----------------------------------------------
function y = is_dialog_inherit(blk)
% Determine if block dialog is set to "inherit" mode
y = strcmp(get_param(blk,'growRefPort'), 'on');


% -----------------------------------------------
function config_block(blk)
% Reconfigure contents of subsystem to reflect
% state of the "inherited" mode dialog box.
%
% inherit: "Inherit output frame status" checkbox
%          on the block dialog is turned on
% direct: the checkbox is turned off

if is_dialog_inherit(blk),      % is the checkbox turned on?
    config_inherit(blk);        % add/remove blocks
    update_inherit_impl(blk);   % setup params in blocks
else
    config_direct(blk);        % add/remove blocks
    update_direct_impl(blk);   % setup params in blocks
end


% -----------------------------------------------
function update_inherit_impl(blk)

% Nothing needs to be done here
%
% No popups or checkboxes on the S-Fcn, just
%   variables which update their values automatically.


% -----------------------------------------------
function update_direct_impl(parent_blk)

% Set the popup in the underlying block
% for the direct-mode (one-in, one-out) implementation
% of frame-status conversion block

child_blk = [parent_blk '/Frame Status'];

requested_outframe = get_param(parent_blk, 'outframe');
current_outframe   = get_param(child_blk,  'outframe');

if ~isequal(current_outframe, requested_outframe),
    set_param(child_blk,'outframe',requested_outframe);
end


% -----------------------------------------------
function config_inherit(blk)
% Configure the block to allow inheriting
% the output status from frame port.
%
% In this mode, the block has two inputs and one output,
% and uses an S-Function to get the job done.

% If the block is already configured for
% inherit-mode, do nothing:
if is_inherit_config(blk), return; end

delete_direct_blocks(blk);
add_inherit_blocks(blk);


% -----------------------------------------------
function config_direct(blk)
% Output frame status is directly specified,
% and block has one input and one output only
%
% (e.g., do not inherit status from frame port)

% If the block is already configured for
% direct-mode, do nothing:
if is_direct_config(blk), return; end

delete_inherit_blocks(blk);
add_direct_blocks(blk);


% -----------------------------------------------
function add_inherit_blocks(blk)
% Construct implementation for the "inherit" mode of operation
%
% For inherit mode, use the S-Function in the Signal Processing Blockset

sfcn='Inherit';
dst_sfcn=[blk '/' sfcn];
add_block('built-in/S-Function',dst_sfcn, ...
    'position',[110 15 190 55], ...
    'FunctionName','sdspfrmconv', ...
    'Parameters', 'growRefPort,outframe');

inport='In1';
outport='Out';
add_line(blk,[inport '/1'],[sfcn '/1']);
add_line(blk,[sfcn '/1'],[outport '/1']);

% add second inport
inport2=[blk '/In2'];
add_block('built-in/Inport',inport2, ...
          'position',[25 60 45 80]);
add_line(blk,'In2/1', [sfcn '/2']);

% -----------------------------------------------
function delete_inherit_blocks(blk)
% Remove all blocks specific to the "inherit" implementation
%
% Leave the In1 and Out port blocks

sfcn='Inherit';
dst_sfcn=[blk '/' sfcn];

inport='In1';
inport2='In2';
outport='Out';
delete_line(blk,[inport '/1'],[sfcn '/1']);
delete_line(blk,[inport2 '/1'],[sfcn '/2']);
delete_line(blk,[sfcn '/1'],[outport '/1']);
delete_block(dst_sfcn);
in2=[blk '/In2'];
delete_block(in2);

% -----------------------------------------------
function add_direct_blocks(blk)
% Construct implementation for the "direct" mode of operation
%
% For direct mode, use the built-in block to gain
% pure virtual behavior (i.e., never generates code)

builtin='Frame Status';
builtin_blk=[blk '/' builtin];
src_blk = 'built-in/FrameConversion';
add_block(src_blk, builtin_blk, ...
    'position',[110 15 190 55]); 

inport='In1';
outport='Out';
add_line(blk,[inport '/1'],[builtin '/1']);
add_line(blk,[builtin '/1'],[outport '/1']);

% -----------------------------------------------
function delete_direct_blocks(blk)
% Remove all blocks specific to the "direct" implementation
%
% Leave the In1 and Out port blocks

fscnv='Frame Status';
dst_fscnv=[blk '/' fscnv];  % full path to block

inport='In1';
outport='Out';
delete_line(blk,[inport '/1'],[fscnv '/1']);
delete_line(blk,[fscnv '/1'],[outport '/1']);
delete_block(dst_fscnv);


% -----------------------------------------------
function y = is_inherit_config(blk)
% Determine if block has been configured for the "inherit"
% mode of operation.  This is *not* looking at the user
% dialog entry --- it actually looks at the underlying
% implemenation to see what state it's in.  We use this to
% deduce whether the dialog and the implementation are
% actually in sync with each other.

% In this mode, we've put a block named "Inherit"
% into the subsystem.  Just check to see if it's present:
%
y = blkexist([blk '/Inherit']);


% -----------------------------------------------
function y = is_direct_config(blk)

y = ~is_inherit_config(blk);


% -----------------------------------------------
function y = blkexist(blk)
% Quick-and-dirty existence check for a Simulink block

sLast = sllasterror;    % Cache Simulink error status
try,
    find_system(blk);
    y=1;
catch
    y=0;
    sllasterror(sLast); % Restore Simulink error status
end


% -----------------------------------------------
function y = direct_frame_requested(blk)
% Determine if block dialog popup is set to "to-frame" mode
%
% NOTE: This doesn't check if block is in inherit mode,
%       just if the popup is set to "to-frame".  Thus,
%       we could say "true" here, even though "inherit"
%       mode is selected.

y = strcmpi(get_param(blk,'outframe'), 'frame-based');


% -----------------------------------------------
function [p,str]=setup_icon(blk)
% Setup icon display

% Setup Inport label(s). There could be one or two depending
% on how the user sets up block for frame status conversion mode.
% No matter what, the first inport is always the 'In' input.

% Setup inport labels.  Either one or two exists.
p.in1 = 'input';      % Choose the side of block to label
p.in2 = 'input';      % Choose the side of block to label
p.i1 = 1; p.i1s = '';
p.i2 = 1; p.i2s = ''; % Assume ONE input only for now

% Setup outport label.  Only one exists.
p.out = 'output';     % Choose the side of block to label
p.o1 = 1; p.o1s = '';

% Readjust port labels for possible 2nd input port
if is_dialog_inherit(blk),    
    
    % Setup the 1st input label to indicate input signal
    p.i1 = 1; p.i1s = 'In';
    % Setup the 2nd input label for reference input
    p.i2 = 2; p.i2s = 'Ref';
    % Setup icon display string
    str = sprintf('       Inherit\n       Frame\n      Status');
    
elseif direct_frame_requested(blk),
    % Setup icon display string
    str = sprintf('To\nFrame');
    
else
    % Setup icon display string
    str = sprintf('To\nSample');
end

% [EOF] dspblkfrmconv.m
