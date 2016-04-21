function varargout = dspblkhist2(action, varargin)
%DSPBLKHIST2 Signal Processing Blockset histogram block helper function.

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $ $Date: 2004/04/12 23:06:38 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;
fcn = get_param(blk,'run');
isRunning = strcmp(fcn,'on');

% Define centered icon:
x1 = [0.19 0.82 NaN 0.19 0.19 0.28 NaN 0.28 0.28 0.37 NaN ...
      0.37 0.37 0.46 NaN 0.46 0.46 0.55 NaN 0.55 0.55 NaN ...
      0.55 0.64 0.64 NaN 0.64 0.73 0.73 NaN 0.73 0.82 0.82];
y1 = [0.1 0.1 NaN 0.1 0.3 0.3 NaN 0.1 0.5 0.5 NaN 0.1 0.7 ...
      0.7 NaN 0.1 0.9 0.9 NaN 0.1 0.9 NaN 0.7 0.7 0.1 NaN ...
      0.5 0.5 0.1 NaN 0.3 0.3 0.1];

% Define shifted icon (to make room for input port labels):
x2 = [0.29 0.92 NaN 0.29 0.29 0.38 NaN 0.38 0.38 0.47 NaN ...
      0.47 0.47 0.56 NaN 0.56 0.56 0.65 NaN 0.65 0.65 NaN ...
      0.65 0.74 0.74 NaN 0.74 0.83 0.83 NaN 0.83 0.92 0.92];
y2 = [0.125 0.125 NaN 0.125 0.325 0.325 NaN 0.125 0.525 0.525 ...
      NaN 0.125 0.725 0.725 NaN 0.125 0.925 0.925 NaN 0.125 ...
      0.925 NaN 0.725 0.725 0.125 NaN 0.525 0.525 0.125 NaN ...
      0.325 0.325 0.125];

switch action
  
 case 'init'
  % has MISC + ACCUM + PRODOUT params
  %       1  +   4   +    8   = 13
  varargout = {dspGetFixptDataTypeInfo(blk,13)};
  
 case 'icon'
  
  % Setup port label structure:
  if ~isRunning,
    % 1 input (in)
    % 1 output
    s.i1 = 1; s.i1s = ''; 
    s.i2 = 1; s.i2s = '';  %In
    x=x1; y=y1;
  else
    % Running mode
    % 2 inputs (in, rst)
    % 1 output (val)
    isRst = ~strcmp(get_param(blk,'trigtype'),'None');
    if isRunning & isRst,
      s.i1 = 1; s.i1s = 'In'; 
      s.i2 = 2; s.i2s = 'Rst';
      x=x2; y=y2;
    else
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';  % No need to annotate one input
      x=x1; y=y1;
    end
  end
  varargout = {s, x, y};
  
 case 'dynamic'
  RESET = 6;
  TRIGTYPE = 7;
  
  mask_vis_last = get_param(blk,'maskvisibilities');
  mask_vis = mask_vis_last;
  mask_vis{RESET} = fcn;  % 'on' or 'off'    reset port
  mask_vis{TRIGTYPE} = 'off';
  if isRunning 
    %% need to update visibilities before accessing reset
    %% reset will be visible if running
    set_param(blk, 'maskvisibilities', mask_vis);
    mask_vis_last = mask_vis;
    mask_vis{TRIGTYPE} = get_param(blk, 'reset');  % trigger type
  end
  if ~isequal(mask_vis, mask_vis_last)
    set_param(blk,'maskvisibilities',mask_vis);  
  end
  
  curVis = get_param(blk,'maskvisibilities');
  [curVis,lastVis] = dspProcessFixptMaskParams(blk,curVis);
  if ~isequal(curVis,lastVis)
    set_param(blk,'maskvisibilities',curVis);
  end
  varargout = {};
  
 otherwise
  error('unhandled case');
end
