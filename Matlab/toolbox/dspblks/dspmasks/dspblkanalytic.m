function [x,y] = dspblkanalytic(action)
% DSPBLKANALYTIC Signal Processing Blockset Analytic Signal block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.2 $ $Date: 2004/04/12 23:05:59 $

if nargin==0, action = 'dynamic'; end

% Propagate Frame-based and channel information to subsytem:
blk = gcb;

frame_based = get_param(blk, 'frame');
set_param([blk,'/Integer Delay'],'frame',frame_based);
set_param([blk,'/Remez FIR Filter Design'],'frame',frame_based);

nchans = get_param(blk, 'numChans');
set_param([blk,'/Integer Delay'],'numChans',nchans);
set_param([blk,'/Remez FIR Filter Design'],'numChans',nchans);

switch action
case 'icon'
	x = [0,NaN,100,NaN,[58 58],NaN,[24 92],NaN,[58 24 24 58],NaN,[58 64 68 72 76 80 84 88],NaN, [42 42],NaN,[8 76],NaN,[72 68 64 60 56 52 48 42 36 32 28 24 20 16 12],NaN,[32 43 45 43 35]];
	y = [0,NaN,100,NaN,[43 8],NaN,[16 16],NaN,[18 18 17 17],NaN,[16 24 36 24 28 28 32 16],NaN, [92 56],NaN,[64 64],NaN,[64 80 76 76 72 84 72 64 72 84 72 76 76 80 64],NaN,[51 33 41 33 35] ];
   
case 'dynamic'
	mask_enables = get_param(blk,'maskenables');
	mask_enables{3} = frame_based;
	set_param(blk,'maskenables',mask_enables);
end
