function varargout = dspblkiir2(action, varargin)
% DSPBLKIIR2 Mask dynamic dialog function for IIR filter block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:06:42 $ $Revision: 1.9.4.2 $

% Cache the block handle once:
blk = gcb;

if nargin==0
  action = 'dynamic';   % mask callback
end

switch action
case 'dynamic'
        % Execute dynamic dialogs      
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
    case {'Bandstop'},
         mask_visibilities(5) = {'on'};
         mask_prompts{4} = 'Lower stopband edge frequency (0 to 1):';
           mask_prompts{5} = 'Upper stopband edge frequency (0 to 1):';
    case {'Bandpass'},
         mask_visibilities(5) = {'on'};
         mask_prompts{4} = 'Lower passband edge frequency (0 to 1):';
         mask_prompts{5} = 'Upper passband edge frequency (0 to 1):';
             
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
    
    set_param(blk,...
        'maskvisibilities', mask_visibilities,...
        'maskprompts',      mask_prompts);
    
case 'design'
    %Butterworth|Chebyshev I|Chebyshev II|Elliptic
    %Lowpass|Highpass|Bandpass|Bandstop
    [varargout{1:nargout}] = dspiirdes(varargin{:});
    
otherwise
    error('unhandled case');
end


function [b,a,h,w,str]=dspiirdes(method,type,N,Wlo,Whi,Rp,Rs)
%DSPIIRDES Signal Processing Blockset digital iir filter design interface
% Usage:
%    [b,a,h,w,str]=dspiirdes(method,type,N,Wlo,Whi,Rp,Rs);
% where:
%        b,a: Coefficients of filter. 
%        h: magnitude frequency response
%           of designed filter (for icon only)
%        w: normalized frequencies corresponding to indices of h (for icon only)
%      str: name of design function called (for icon only)
%

% $Revision: 1.9.4.2 $ $Date: 2004/04/12 23:06:42 $

% Check for inf or Nan filter order
if isnan(N) | isinf(N),
   error('NaN or Inf not allowed for filter order.');
end

% Check for non-integer filter order
if ~isequal(floor(N), N),
   error('Filter order must be an integer value.');
end

% Check for (filter order < 1)
if N < 1,
   error('Filter order must be positive.');
end

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

% end of dspblkiir2.m
