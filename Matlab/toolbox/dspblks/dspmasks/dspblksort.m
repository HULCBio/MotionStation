function varargout = dspblksort(action, dir,otype)
% DSPBLKSORT Signal Processing Blockset sort block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.3 $ $Date: 2004/04/12 23:07:17 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;

switch action
    
    case 'init'
    varargout = {dspGetFixptDataTypeInfo(blk,13)};
  
    case 'icon'
    % Draw icon:
    x=0.75*[0.05 0.37 0.37 0.05 0.05 NaN 0.05 0.21 0.21 0.05 0.05 NaN 0.05 0.13 0.13 0.05 0.05 NaN 0.05 0.45 0.45 0.05 0.05 NaN 0.05 0.29 0.29 0.05 0.05 NaN 0.315 0.415 0.415 0.49 0.415 0.415 0.315 0.315 NaN 0.55 0.63 0.63 0.55 0.55 NaN 0.55 0.71 0.71 0.55 0.55 NaN 0.55 0.79 0.79 0.55 0.55 NaN 0.55 0.87 0.87 0.55 0.55 NaN 0.55 0.95 0.95 0.55 0.55];
    if dir == 1,
    % Ascending:
    y=[0.9375 0.9375 0.8125 0.8125 0.9375 NaN 0.75 0.75 0.625 0.625 0.75 NaN 0.5625 0.5625 0.4375 0.4375 0.5625 NaN 0.375 0.375 0.25 0.25 0.375 NaN 0.1875 0.1875 0.0625 0.0625 0.1875 NaN 0.475 0.475 0.425 0.525 0.625 0.575 0.575 0.475 NaN 0.9375 0.9375 0.8125 0.8125 0.9375 NaN 0.75 0.75 0.625 0.625 0.75 NaN 0.5625 0.5625 0.4375 0.4375 0.5625 NaN 0.375 0.375 0.25 0.25 0.375 NaN 0.1875 0.1875 0.0625 0.0625 0.1875];
    else,
	% Descending:   
    y=[0.9375 0.9375 0.8125 0.8125 0.9375 NaN 0.75 0.75 0.625 0.625 0.75 NaN 0.5625 0.5625 0.4375 0.4375 0.5625 NaN 0.375 0.375 0.25 0.25 0.375 NaN 0.1875 0.1875 0.0625 0.0625 0.1875 NaN 0.475 0.475 0.425 0.525 0.625 0.575 0.575 0.475 NaN 0.0625 0.0625 0.1875 0.1875 0.0625 NaN 0.25 0.25 0.375 0.375 0.25 NaN 0.4375 0.4375 0.5625 0.5625 0.4375 NaN 0.625 0.625 0.75 0.75 0.625 NaN 0.8125 0.8125 0.9375 0.9375 0.8125];
    end
    % Draw port label structure:
    switch otype
    case 1,
    % 1 input (in)
    % 2 outputs (val,idx)
    s.i1 = 1; s.i1s = ''; 
    s.i2 = 1; s.i2s = '';  %In
    s.o1 = 1; s.o1s = 'Val';
    s.o2 = 2; s.o2s = 'Idx';  
    case 2,
	% 1 input (in)
	% 1 output (val)
    s.i1 = 1; s.i1s = ''; 
    s.i2 = 1; s.i2s = '';  %In
    s.o1 = 1; s.o1s = '';
    s.o2 = 1; s.o2s = 'Val';  %Val
    case 3,
    % 1 input (in)
	% 1 output (idx)
    s.i1 = 1; s.i1s = ''; 
    s.i2 = 1; s.i2s = '';  %In
    s.o1 = 1; s.o1s = '';
    s.o2 = 1; s.o2s = 'Idx';  %Idx
    end
    varargout = {s, x, y};
    
    case 'dynamic'
    curVis = get_param(blk,'maskvisibilities');
    [curVis,lastVis] = dspProcessFixptMaskParams(blk,curVis);
    if ~isequal(curVis,lastVis)
        set_param(blk,'maskvisibilities',curVis);
    end
    varargout = {};
    
end

% [EOF] dspblksort.m
