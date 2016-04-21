function varargout = dspblkvar2(action)
% DSPBLKVAR2 Signal Processing Blockset variance block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:07:38 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;
fcn = get_param(blk,'run');
isRunning = strcmp(fcn,'on');

switch action

case 'init'
    varargout = {dspGetFixptDataTypeInfo(blk,15)};
    
case 'icon'
   % Setup port label structure:
   if ~isRunning,
      % 1 input (in)
      % 1 output
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';  %In
      
      x = 'VAR';
      
   else,
      % Running
      % 2 inputs (in, rst)
      % 1 output (val)
      isRst = strcmp(get_param(blk,'reset_popup'),'Non-zero sample');
      if isRunning & isRst,
		 s.i1 = 1; s.i1s = 'In'; 
         s.i2 = 2; s.i2s = 'Rst';
      else
      	 s.i1 = 1; s.i1s = ''; 
         s.i2 = 1; s.i2s = '';  % No need to annotate one input
      end      
      
      x = 'Running\nVar';
   end
   varargout = {s, x};

case 'dynamic'
   
   orig_ena  = get_param(blk,'MaskEnables');
   new_ena   = orig_ena;
   if ~isRunning,
      % Static var:
	  new_ena(2) = {'off'};
   else
      % Running var:
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
