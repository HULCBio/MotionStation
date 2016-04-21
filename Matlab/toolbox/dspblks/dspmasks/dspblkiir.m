function varargout = dspblkiir(action, varargin)
% DSPBLKIIR Mask dynamic dialog function for IIR filter block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:06:41 $ $Revision: 1.14.4.2 $

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
	% The eighth dialog (checkbox for frame-based inputs)
	% disables/enables the ninth dialog(number of channels).
      
	mask_enables = get_param(blk,'maskenables');
	mask_enables{9} = frame_based;
	mask_prompts = get_param(blk,'maskprompts');
	mask_visibilities = get_param(blk,'maskvisibilities');
      
    filter_type = get_param(blk,'filttype');
    method = get_param(blk,'method');   
    switch filter_type
    case {'Lowpass','Highpass'},
         if (strcmp(method, 'Chebyshev II'))
            mask_prompts{4} = 'Stopband edge frequency (0 to 1):';
         else
            mask_prompts{4} = 'Passband edge frequency (0 to 1):';
         end
         mask_visibilities(5) = {'off'};
         mask_prompts{5} = 'Should not be visible!';
        % Only enable upper-band edge dialog for bandpass or bandstop
    case {'Bandpass','Bandstop'},
        mask_visibilities(5) = {'on'};
        if (strcmp(method, 'Chebyshev II'))
        	  mask_prompts{4} = 'Lower stopband edge frequency (0 to 1):';
           mask_prompts{5} = 'Upper stopband edge frequency:';
        else
        	  mask_prompts{4} = 'Lower passband edge frequency (0 to 1):';
           mask_prompts{5} = 'Upper passband edge frequency:';
        end
             
    otherwise
        error('Unknown filter type');
    end
      
    % Enable the appropriate passband and stopband ripple dialogs
    switch method
    case {'Chebyshev I'},
        mask_visibilities{6} = 'on';
        mask_visibilities{7} = 'off';
    case {'Chebyshev II'},
        mask_visibilities{6} = 'off';
        mask_visibilities{7} = 'on';
    case {'Elliptic'},
        mask_visibilities{6} = 'on';
        mask_visibilities{7} = 'on';
    otherwise
        mask_visibilities{6} = 'off';
        mask_visibilities{7} = 'off';         
    end
    
    set_param(blk,'maskenables',mask_enables, ...
        'maskvisibilities',mask_visibilities, ...
        'maskprompts',mask_prompts);
    
case 'design'
    %Butterworth|Chebyshev I|Chebyshev II|Elliptic
    %Lowpass|Highpass|Bandpass|Bandstop
    [varargout{1:nargout}] = dspiirdes(varargin{:});
    
case 'update'
    % Update any other parameters and blocks:
    
    % Update checkbox on child blocks:
    % Set the frame-based attribute for the filter subsystem   
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
    error('unhandled case');
end


function [b,a,h,w,str]=dspiirdes(method,type,N,Wlo,Whi,Rp,Rs)
%DSPIIRDES Signal Processing Blockset digital iir filter design interface
% Usage:
%    [b,a,h,w,str]=dspiirdes(method,type,N,Wlo,Whi,Rp,Rs);
% where:
%   	 b,a: Coefficients of filter. 
%        h: magnitude frequency response
%           of designed filter (for icon only)
%        w: normalized frequencies corresponding to indices of h (for icon only)
%      str: name of design function called (for icon only)
%

% $Revision: 1.14.4.2 $ $Date: 2004/04/12 23:06:41 $

% Defaults for return:
a=[]; b=[];h=[]; w=[]; str='';

% Default LHS for filter designs:
lhs='[b,a]';

switch method
case 'Butterworth'
  m={'butter',N};
case 'Chebyshev I'
  m={'cheby1',N,Rp};
case 'Chebyshev II'
  m={'cheby2',N,Rs};
case 'Elliptic'
  m={'ellip',N,Rp,Rs};
otherwise,
  error('Unknown filter method selected');
end

switch type
case 'Lowpass',
  t={m{:},Wlo};
case 'Highpass',
  t={m{:},Wlo,'high'};
case 'Bandpass',
  t={m{:},[Wlo Whi]};
case 'Bandstop',
  t={m{:},[Wlo Whi],'stop'};
otherwise,
  error('Unknown filter type selected.');
end

% Return filter design coefficients:
s=[lhs '=feval(t{:});'];

% Inputs could be empty if the mask failed evaluation
% Trap errors:
try
    eval(s);
catch
    a=1;
    b=1;
end

% Return name for icon
str=m{1};

% Compute frequency response for icon
h=abs(freqz(b,a,64));
% Scale icon for display:
h=h./max(h)*0.75;  % Scaled for icon
w = (0:63)/63;  % normalize to [0,1]

% end of dspblkiir.m
