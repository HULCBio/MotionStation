function varargout = dspblkmean2(action)
% DSPBLKMEAN2 Signal Processing Blockset Mean block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:06:53 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;
fcn = get_param(blk,'run');
isRunning = strcmp(fcn,'on');

switch action

case 'init'
    varargout = {dspGetFixptDataTypeInfo(blk,7)};
    
case 'icon'
	% Setup port label structure:
	if ~isRunning,
		% 1 input (in)
	   % 1 output
   	s.i1 = 1; s.i1s = ''; 
	   s.i2 = 1; s.i2s = '';  %In
     
   	x = [0 NaN 100 NaN 42 58 50 50 50 58 42 NaN 42 58 58 42];
		y = [0 NaN 100 NaN 80 80 80 80 20 20 20 NaN 48 48 51 51];

	else
   	% Running
	   % 2 inputs (in, rst)
   	% 1 output (val)
      isRst = ~strcmp(get_param(blk,'reset_popup'),'None');
      if isRunning & isRst,
		   s.i1 = 1; s.i1s = 'In'; 
         s.i2 = 2; s.i2s = 'Rst';
      else
      	s.i1 = 1; s.i1s = 'In'; 
         s.i2 = 1; s.i2s = '';  % No need to annotate one input
      end      
   
	  x = [-35 NaN 100 NaN 58 42 50 50 50 42 59 NaN 34 18 26 26 26 34 18 NaN 66 82 74 74 74 82 66 NaN 34 18 18 34 34 18 NaN 58 42 42 58 58 42 NaN 82 66 66 82 82 66 NaN 34 34 42 42 NaN 58 58 66 66];
      y = [0 NaN 100 NaN 76 76 76 76 28 28 28 NaN 68 68 68 68 36 36 36 NaN 84 84 84 84 20 20 20 NaN 54 54 52 52 50 50 NaN 50 50 54 54 52 52 NaN 52 52 50 50 54 54 NaN 52 52 52 52 NaN 52 52 52 52];
	end
    varargout = {s, x, y};

case 'dynamic'
   
   orig_ena  = get_param(blk,'MaskEnables');
   new_ena   = orig_ena;
   if ~isRunning,
      % Static mean:
	  new_ena(2) = {'off'};
   else
      % Running mean:
   	  new_ena(2) = {'on'};
   end
   if ~isequal(new_ena, orig_ena),
	    set_param(blk,'MaskEnables',new_ena);
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

% [EOF] dspblkmean2.m