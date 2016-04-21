function [s,x,y] = dspblkmin(action)
% DSPBLKMIN Signal Processing Blockset Minimum block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:06:55 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;
fcn = get_param(blk,'fcn');  % Value and Index|Value|Index|Running

switch action
case 'icon'
   % Default used for cases 1-3: case 4 overrides this.
   x = [0 NaN 100 NaN 42 58 50 50 50 58 42 NaN 42 58 58 42];
   y = [0 NaN 100 NaN 80 80 80 80 20 20 20 NaN 22 22 18 18];

   % Setup port label structure:
   switch fcn
   case 'Value and Index'
      % 1 input (in)
      % 2 outputs (val,idx)
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';  %In
      s.o1 = 1; s.o1s = 'Val';
      s.o2 = 2; s.o2s = 'Idx';  
   case 'Value'
      % 1 input (in)
      % 1 output (val)
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';  %In
      s.o1 = 1; s.o1s = '';
      s.o2 = 1; s.o2s = 'Val';  %Val
   case 'Index'
      % 1 input (in)
      % 1 output (idx)
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';  %In
      s.o1 = 1; s.o1s = '';
      s.o2 = 1; s.o2s = 'Idx';  %Idx
   case 'Running'
      % Running
      % 2 inputs (in, rst)
      % 1 output (val)
		isRst = strcmp(get_param(blk,'reset'),'on');
      if isRst,
      	s.i1 = 1; s.i1s = 'In'; 
         s.i2 = 2; s.i2s = 'Rst';
      else
      	s.i1 = 1; s.i1s = ''; 
         s.i2 = 1; s.i2s = 'In';
      end
      s.o1 = 1; s.o1s = '';
      s.o2 = 1; s.o2s = '';  %Val
      
      x = [-35 NaN 100 NaN 42 58 50 50 50 58 42 NaN 34 18 26 26 26 34 18 NaN 66 82 74 74 74 82 66 NaN 34 18 18 34 42 58 58 42 NaN 66 82 82 66 58];
      y = [0 NaN 100 NaN 80 80 80 80 28 28 28 NaN 80 80 80 80 40 40 40 NaN 80 80 80 80 16 16 16 NaN 42 42 38 38 30 30 26 26 NaN  14 14 18 18 26];
      
   end
   
case 'dynamic'
      
	isRunning    = strcmp(fcn,'Running');
   mask_enables = get_param(blk,'maskenables');
      
   if ~isRunning,
      % Static mean:
	   mask_enables(2:4) = {'off'};
   else
      % Running mean:
   	frame = get_param(blk,'frame');
      mask_enables(2:3) = {'on'};
      mask_enables{4} = frame;
   end
   
   set_param(blk,'maskenables',mask_enables);
end
