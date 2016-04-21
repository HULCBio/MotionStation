function str = dspblkdly(action,varargin)
% DSPBLKDLY Mask dynamic dialog function for integer delay block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:54:42 $ $Revision: 1.8 $
if nargin==0
   action = 'dynamic';   % mask callback
end

% Get the value of the checkbox for frame-based
frame_based = get_param(gcb, 'frame');
   
switch action
	case 'dynamic'
      % Execute dynamic dialogs 
      mask_enables = get_param(gcb,'maskenables');
      mask_enables{4} = frame_based;
      mask_enables{5} = frame_based;
		set_param(gcb,'maskenables',mask_enables);
      
   otherwise
      error('unhandled case');
end

% end of dspblkdly.m
