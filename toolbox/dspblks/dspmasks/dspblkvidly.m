function str = dspblkvidly(vargargin)
% DSPBLKVIDLY Mask dynamic dialog function for variable integer delay block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:55:17 $ $Revision: 1.6 $
if nargin==0
   action = 'dynamic';   % mask callback
else
   action = 'design';    
end
varargin

% Get the value of the checkbox for frame-based
frame_based = get_param(gcb, 'frame');
   
switch action
	case 'dynamic'
      % Execute dynamic dialogs 
      mask_enables = get_param(gcb,'maskenables');
      mask_enables{4} = frame_based;
		set_param(gcb,'maskenables',mask_enables);
      
   case 'design' 
      str = 'Integer\nDelay';
      
   otherwise
      error('unhandled case');
end

% end of dspblkvidly.m
