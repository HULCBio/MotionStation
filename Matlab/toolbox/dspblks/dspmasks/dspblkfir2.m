function varargout = dspblkfir2(action, varargin)
% DSPBLKFIR Mask dynamic dialog function for the FIR filter block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:06:30 $ $Revision: 1.7.4.2 $

% Cache the block handle once:
blk = gcb;

if nargin==0,
   action = 'dynamic';   % mask callback
end


switch action
case 'dynamic'
   % Execute dynamic dialogs      
   mask_enables = get_param(blk,'maskenables');
   mask_prompts = get_param(blk,'maskprompts');
   mask_visibilities = get_param(blk,'maskvisibilities');
   
   filter_type = get_param(blk,'filttype');   
   switch filter_type
   case {'Lowpass','Highpass'},
      mask_visibilities(3) = {'on'};
      mask_visibilities(4) = {'off'};
      mask_visibilities(5) = {'off'};
      mask_visibilities(6) = {'off'};
      mask_visibilities(7) = {'off'};
      mask_visibilities(8) = {'off'};
      mask_prompts{3} = 'Cutoff frequency (0 to 1):';
      % Only enable upper-band edge dialog for bandpass or bandstop
   case {'Bandpass','Bandstop'},
      mask_visibilities(3) = {'on'};
      mask_visibilities(4) = {'on'};
      mask_visibilities(5) = {'off'};
      mask_visibilities(6) = {'off'};
      mask_visibilities(7) = {'off'};
      mask_visibilities(8) = {'off'};
      mask_prompts{3} = 'Lower cutoff frequency (0 to 1):';
      mask_prompts{4} = 'Upper cutoff frequency:';
   case 'Multiband',
      mask_visibilities(3) = {'off'};
      mask_visibilities(4) = {'off'};
      mask_visibilities(5) = {'on'};
      mask_visibilities(6) = {'on'};
      mask_visibilities(7) = {'off'};
      mask_visibilities(8) = {'off'};
   case 'Arbitrary Shape (fir2)',
      mask_visibilities(3) = {'off'};
      mask_visibilities(4) = {'off'};
      mask_visibilities(5) = {'off'};
      mask_visibilities(6) = {'off'};
      mask_visibilities(7) = {'on'};
      mask_visibilities(8) = {'on'};
   otherwise
      error('Unknown filter type');
   end
   
   window_type = get_param(blk,'wintype');
   switch window_type
   case 'Chebyshev',
      mask_enables(11) = {'off'};
      mask_enables(10) = {'on'};
   case 'Kaiser',
      mask_enables(10) = {'off'}; 
      mask_enables(11) = {'on'};
   otherwise
      mask_enables(10) = {'off'};
      mask_enables(11) = {'off'};
   end      
   
   set_param(blk, ...
      'maskenables', mask_enables, ...
      'maskvisibilities', mask_visibilities, ...
      'maskprompts', mask_prompts);
   
case 'design'
   %Bartlett|Blackman|Boxcar|Chebyshev|Hamming|Hann|Hanning|Kaiser|Triangular
   %filttype,N,Wlo,Whi,window,Rs
   N = varargin{2};

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

   % Compute the window to be used in the filter design
   window = calc_window(varargin{9},varargin{10},varargin{11},N);
   
   % Design the filter
   if (strcmp(varargin{1}, 'Arbitrary Shape (fir2)')),
      varargout{1} = fir2(varargin{2},varargin{7:8},window);
      varargout{nargout} = 'fir2';
   else 
      filter_type = get_param(blk,'filttype');
      switch filter_type
      case 'Multiband',
         % If we have an odd order multiband with high gain at the nyquist
         % frequency, fir1 will increase the order of the filter by one.
         % Hence we bump the window length by one as well.
         if (rem(N,2) & rem(length(varargin{5}),2) & varargin{6} == 1) | ...
               (rem(N,2) & ~rem(length(varargin{5}),2) & varargin{6} == 2),
            % We must recompute the window
            window = calc_window(varargin{9},varargin{10},N+1);
         end               
         varargout{1} = dspfir1des(varargin{1:2},varargin{5:6},window);
      case {'Lowpass','Highpass','Bandpass','Bandstop'},
         % If we have an odd order highpass or bandstop filter the window
         % length must be increased by one (this is due to the spec for fir1).
         if rem(N,2) & any(strcmp(filter_type,{'Highpass','Bandstop'})),
            % We must recompute the window
            window = calc_window(varargin{9},varargin{10},N+1);
         end
         varargout{1} = dspfir1des(varargin{1:4},window);         
      end
      varargout{nargout} = 'fir1';
   end
   [h,w] = firiconmag(varargout{1});
   varargout{2} = h;
   varargout{3} = w;   
      
otherwise
   error('unhandled case');
end

% ---------------------------------------------------------------------

function [b,h,w]=dspfir1des(type,N,Wlo,Whi,window)
%DSPFIRDES Signal Processing Blockset fir1 filter design interface
% Usage:
%    [b,h,w]=dspfdes(type,N,Wlo,Whi);
% where:
%        b: Coefficients of filter
%        h: magnitude frequency response
%           of designed filter (for icon only)
%        w: normalized frequencies corresponding to indices of h (for icon only)
%


% Defaults for return:
b=[]; h=[]; w=[];

% Default LHS for filter designs:
m={'fir1',N};
lhs='b';  % Override LHS for FIR1

switch type
case 'Lowpass',
	t={m{:},Wlo};
case 'Highpass',
	t={m{:},Wlo,'high'};
case 'Bandpass',
	t={m{:},[Wlo Whi]};
case 'Bandstop',
	t={m{:},[Wlo Whi],'stop'};
case 'Multiband',
   if (Whi == 1)
      Whi = 'DC-0';
   else
      Whi = 'DC-1';
   end
	t={m{:},Wlo,Whi};
otherwise,
  error('Unknown filter type selected.');
end

t = {t{:}, window};
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

% ---------------------------------------------------------------------

function window = calc_window(wintype,cheby_winarg,kaiser_winarg,N)
% Calculate the window to be used in the filter design
if (strcmp(wintype, 'Chebyshev'))
   wintype = 'chebwin';
elseif (strcmp(wintype, 'Triangular'))
   wintype = 'triang';
end
if strcmp(wintype, 'chebwin')
   Rs = cheby_winarg;
   window = eval([lower(wintype) '(N+1, Rs)']);
elseif strcmp(wintype, 'Kaiser')
   Kbeta = kaiser_winarg;
   window = eval([lower(wintype) '(N+1, Kbeta)']);
else
   window = eval([lower(wintype) '(N+1)']);
end

% ---------------------------------------------------------------------

function [h, w] = firiconmag(b)
% Compute frequency response for icon
h = abs(freqz(b,1,64));
h = h./max(h)*0.75;  % Scaled for icon
w = (0:63)/63;  % normalize to [0,1]

% [EOF] dspblkfir2.m
