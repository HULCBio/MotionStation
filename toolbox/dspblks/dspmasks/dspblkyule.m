function varargout = dspblkyule(action, varargin)
% DSPBLKYULE Mask dynamic dialog function for Yule-Walker IIR filter block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:54:48 $ $Revision: 1.11 $

% Cache the block handle once:
blk = gcb;

if nargin==0,
   action = 'dynamic';
end

% Get the value of the checkbox for frame-based
frame_based = get_param(blk, 'frame');

switch action
case 'dynamic'
   % Execute dynamic dialogs
   
	% Get status of frame checkbox
	mask_enables    = get_param(blk,'maskenables');
	mask_enables{5} = frame_based;
    set_param(blk, 'maskenables', mask_enables);

case 'design'
    % Filter and icon design:
    
   % Inputs (N,F,A) could be empty if the mask failed evaluation
   % Trap errors:
   try
       [b,a] = yulewalk(varargin{:});
   catch
       b=1; a=1;
   end
   
   h = abs(freqz(b,a,64));
   h = h./max(h)*.75;
   w = (0:63)/63;
   str = 'yulewalk';
   
   % Gather up return arguments:
   varargout = {b,a,h,w,str};
   
case 'update'
   % Update any other parameters and blocks:
   
   % Update checkbox on child blocks:
   child     = [blk '/Filter'];
   currFrame = get_param(child,'frame');
   newFrame  = frame_based;
   if ~strcmp(currFrame, newFrame),
      set_param(child, 'frame', newFrame);
   end
   
   
   % Update number of channels parameter
   % if we are not frame-based:
   if strcmp(frame_based,'off'),
      nchans = -1;
   else
      nchans = varargin{1};
   end
   
   % Gather up return arguments:
   varargout = {nchans};

otherwise
    error('Unhandled case');
end

% end of dspblkyule.m
