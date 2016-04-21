function varargout = dspblkg711(action, varargin)
%DSPBLKG711 Signal Processing Blockset G.711 block

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2003/12/06 15:24:49 $

% Icon drawing and port labels
  
blk = gcbh;
  
switch action
 case 'icon'
  mode = varargin{1};
  [iS, iL, oL] = LocIcon(mode);
  varargout = {iS, iL, oL};
 case 'enables'
  LocEnables(blk);
 otherwise
  error('Unhandled case');
end

%
% Return the strings needed for the icon
%
function [iconStr, inLabel, outLabel] = LocIcon(mode)
iconStr  = 'G.711';
switch (mode)
 case 1
  inLabel  = 'PCM';
  outLabel = 'A';
 case 2
  inLabel  = 'PCM';
  outLabel = 'mu';
 case 3
  inLabel  = 'A';
  outLabel = 'PCM';
 case 4
  inLabel  = 'mu';
  outLabel = 'PCM';
 case 5
  inLabel  = 'A';
  outLabel = 'mu';
 case 6
  inLabel  = 'mu';
  outLabel = 'A';
 otherwise
  iconStr  = '';
  inLabel  = '';
  outLabel = '';
end

%
% Function that is called during MaskDialogCallback to 
% set the appropriate dialog enables and disables.
%
function LocEnables(blkH)
mode = get_param(blkH, 'mode');

if strcmp(mode, 'Encode PCM to A-law') | ...
  strcmp(mode, 'Encode PCM to mu-law')
  set_param(blkH, 'MaskEnables', {'on', 'on'});
  set_param(blkH, 'MaskVisibilities', {'on', 'on'});
else
  set_param(blkH, 'MaskEnables', {'on', 'off'});
  set_param(blkH, 'MaskVisibilities', {'on', 'off'});
end
  

% [EOF] dspblkg711.m
