function varargout = dspblkminmax(action,minmaxfcn)
% DSPBLKMINMAX Signal Processing Blockset Minimum/Maximum block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/06 15:25:09 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;
fcn = get_param(blk,'fcn');  % Value and Index|Value|Index|Running

switch action
 case 'init'
  varargout = {dspGetFixptDataTypeInfo(blk,13)};
  
 case 'icon'
   % Default used for cases 1-3: case 4 overrides this.
   x = [0 NaN 100 NaN 42 58 50 50 50 58 42 NaN 42 58 58 42];
   if strcmp(minmaxfcn,'max')
     y = [0 NaN 100 NaN 80 80 80 80 20 20 20 NaN 82 82 78 78];
   else
     y = [0 NaN 100 NaN 80 80 80 80 20 20 20 NaN 22 22 18 18];
   end
   
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
	  isRst = ~strcmp(get_param(blk,'reset'),'None');
      if isRst,
      	s.i1 = 1; s.i1s = 'In'; 
         s.i2 = 2; s.i2s = 'Rst';
      else
      	s.i1 = 1; s.i1s = ''; 
         s.i2 = 1; s.i2s = 'In';
      end
      s.o1 = 1; s.o1s = '';
      s.o2 = 1; s.o2s = '';  %Val
    
      if strcmp(minmaxfcn,'max')
        x = [-35 NaN 100 NaN 58 42 50 50 50 58 42 NaN 34 22 18 26 26 26 34 18 NaN 66 82 74 74 74 82 66 NaN 34 18 18 34 42 42 58 NaN 66 82 82 66 58 58 42];
        y = [0 NaN 100 NaN 20 20 20 20 72 72 72 NaN 20 20 20 20 20 60 60 60 NaN 20 20 20 20 84 84 84 NaN 58 58 62 62 70 74 74 NaN 86 86 82 82 74 70 70];
      else
        x = [-35 NaN 100 NaN 42 58 50 50 50 58 42 NaN 34 18 26 26 26 34 18 NaN 66 82 74 74 74 82 66 NaN 34 18 18 34 42 58 58 42 NaN 66 82 82 66 58];
        y = [0 NaN 100 NaN 80 80 80 80 28 28 28 NaN 80 80 80 80 40 40 40 NaN 80 80 80 80 16 16 16 NaN 42 42 38 38 30 30 26 26 NaN  14 14 18 18 26];
      end
   end
   varargout = {s, x, y};
     
 case 'dynamic'   
    isRunning = strcmp(fcn,'Running');
    orig_ena  = get_param(blk,'MaskEnables');
    new_ena   = orig_ena;
    if ~isRunning,
        % Static max:
        new_ena(2) = {'off'};
    else
        % Running max:
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
end

% [EOF] dspblkminmax.m
