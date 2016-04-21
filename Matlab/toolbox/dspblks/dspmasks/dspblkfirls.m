function varargout = dspblkfirls(action, varargin)
% DSPBLKFIRLS Mask dynamic dialog function for least-squares FIR filter block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:54:54 $ $Revision: 1.11 $

% Cache the block handle once:
blk = gcb;

if nargin==0
   action = 'dynamic';   % mask callback
end

% Get the value of the checkbox for frame-based
frame_based = get_param(blk, 'frame');
   
switch action
case 'dynamic'
    % Execute dynamic dialogs
    filter_type = get_param(blk,'filttype');         
    % The sixth dialog (checkbox for frame-based inputs)
    % disables/enables the seventh dialog(number of channels).
    
    % Get status of frame checkbox
    mask_enables = get_param(blk,'maskenables');
    mask_enables{7} = frame_based;
    set_param(blk,'maskenables',mask_enables);
    
case 'design'
    s = {varargin{2:nargin-1}};
    switch varargin{1},
    case 2, s={s{:},'h'};
    case 3, s={s{:},'d'};
    end
    
    % Inputs could be empty if the mask failed evaluation
    % Trap errors:
    try
        b=firls(s{:});
    catch
        b=1;
    end
    
    h=abs(freqz(b,1,64)); h=h./max(h)*.75;
    w=((1:length(h))-1)/length(h); 
    str = 'firls'; 
    
    % Gather up return arguments:
    varargout = {b,h,w,str};
        
case 'update'
    % Update any other parameters and blocks:
    
    % Set the frame-based attribute for the filter subsystem   
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

% end of dspblkfirls.m
