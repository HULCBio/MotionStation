function [s,x] = dspblkrms(action)
% DSPBLKRMS Signal Processing Blockset RMS block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:07:11 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;
fcn = get_param(blk,'run');
isRunning = strcmp(fcn,'on');

switch action
case 'icon'
   % Setup port label structure:
   if ~isRunning,
      % 1 input (in)
      % 1 output
      s.i1 = 1; s.i1s = ''; 
      s.i2 = 1; s.i2s = '';  %In
      
      x = 'RMS';
      
   else
      % Running
      % 2 inputs (in, rst)
      % 1 output (val)
      isRst = strcmp(get_param(blk,'reset'),'on');
      if isRunning & isRst,
		   s.i1 = 1; s.i1s = 'In'; 
         s.i2 = 2; s.i2s = 'Rst';
      else
      	s.i1 = 1; s.i1s = ''; 
         s.i2 = 1; s.i2s = '';  % No need to annotate one input
      end      
      
      x = 'Running\nRMS';
   end
   
case 'dynamic'

   frame        = get_param(blk,'frame');
   mask_enables = get_param(blk,'maskenables');
   if ~isRunning,
      % Static mean:
	   mask_enables(2:4) = {'off'};
   else
      % Running mean:
   	mask_enables(2:3) = {'on'};
      mask_enables(4) = {frame};
   end
   set_param(blk,'maskenables',mask_enables);
   
otherwise
   error('unhandled case');
end
