function [b,a]=firrcos(varargin)
%FIRRCOS Raised Cosine FIR Filter design.
%   B=FIRRCOS(N,Fc,DF,Fs) returns an order N low pass linear phase FIR 
%   filter with a raised cosine transition band.  The filter has cutoff
%   frequency Fc, sampling frequency Fs and transition bandwidth DF 
%   (all in Hz).
%
%   Fc +/- DF/2 must be in the range [0,Fs/2].    
%
%   The coefficients of B are normalized so that the nominal passband 
%   gain is always equal to one.
%
%   FIRRCOS(N,Fc,DF) uses a default sampling frequency of Fs = 2.
%
%   B=FIRRCOS(N,Fc,R,Fs,'rolloff') interprets the third argument as the
%   rolloff factor instead of as a transition bandwidth. Alternatively,
%   you can specify B=FIRRCOS(N,Fc,DF,Fs,'bandwidth') which is 
%   equivalent to B=FIRRCOS(N,Fc,DF,Fs).
%
%   R must be in the range [0,1].
%
%   B=FIRRCOS(N,Fc,DF,Fs,DESIGNTYPE) or
%   B=FIRRCOS(N,Fc,R,Fs,'rolloff',DESIGNTYPE) 
%   will design a regular FIR raised cosine filter when DESIGNTYPE is 
%   'normal' or set to an empty matrix. If DESIGNTYPE is 'sqrt', B is the 
%   square root FIR raised cosine filter.
%
%   B=FIRRCOS(...,DESIGNTYPE,DELAY) allows for a variable integer delay to
%   be 
%   specified. When omitted or left empty, DELAY defaults to N/2 or
%   (N+1)/2 depending on whether N is even or odd.
%
%   DELAY must be an integer in the range [0, N+1].
%
%   B=FIRRCOS(...,DELAY,WINDOW) applies a length N+1 window to the 
%   designed filter in order to reduce the ripple in the frequency 
%   response. WINDOW must be a N+1 long column vector. If no window
%   is specified a boxcar (rectangular) window is used.
%
%   WARNING: Care must be exercised when using a window with a delay
%   other than the default.
%
%   [B,A]=FIRRCOS(...) will always return A = 1.
%
%   See also FIRLS, FIR1, FIR2.

%   Author(s): R. Losada and D. Orofino
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/13 00:17:57 $

error(nargchk(3,8,nargin));

[n,fc,fs,R,designType,window,msg] = parse_inputs(varargin{:});
error(msg);

switch designType
case 'normal'   %normal raised cosine design
   b = normal_design(n,fc,fs,R);
case 'sqrt'	% square root raised cosine design
	b = sqrt_design(n,fc,fs,R);
end

if ~isempty(window),
	[b,msg] = apply_win(b,window);
	error(msg);
end

if nargout > 1
   a = 1.0;
end

%--------------------------------------------------------------------------
function b = normal_design(n,fc,fs,R)
ind1 = find(abs(abs(4.*R.*fc.*n) - 1.0) > sqrt(eps));
if ~isempty(ind1),
	nind = n(ind1);
	b(ind1) =  sinc(2.*fc.*nind)./fs   ...
		.* cos(2.*pi.*R.*fc.*nind) ...
		./ (1.0 - (4.*R.*fc.*nind).^2);
end

ind = 1:length(n);
ind(ind1) = [];
b(ind) = R ./ (2.*fs) .* sin(pi ./ (2.*R));

b = 2.*fc.*b;

%-------------------------------------------------------------------------------
function b = sqrt_design(n,fc,fs,R)

ind1 = find(n == 0);
if ~isempty(ind1),
	b(ind1) = - sqrt(2.*fc) ./ (pi.*fs) .* (pi.*(R-1) - 4.*R );
end

ind2 = find(abs(abs(8.*R.*fc.*n) - 1.0) < sqrt(eps));
if ~isempty(ind2),
	b(ind2) = sqrt(2.*fc) ./ (2.*pi.*fs) ...
		* (    pi.*(R+1)  .* sin(pi.*(R+1)./(4.*R)) ...
		- 4.*R     .* sin(pi.*(R-1)./(4.*R)) ...
		+ pi.*(R-1)  .* cos(pi.*(R-1)./(4.*R)) ...
		);
end

ind = 1:length(n);
ind([ind1 ind2]) = [];
nind = n(ind);

b(ind) = -4.*R./fs .* ( cos((1+R).*2.*pi.*fc.*nind) + ...
	sin((1-R).*2.*pi.*fc.*nind) ./ (8.*R.*fc.*nind) ) ...
	./ (pi .* sqrt(1./(2.*fc)) .* ((8.*R.*fc.*nind).^2 - 1));

b = sqrt(2.*fc) .* b;

%-------------------------------------------------------------------------------
function [b,msg] = apply_win(b,window)

msg = '';
if length(window) ~= length(b),
	msg = 'WINDOW must be of the same length as the filter.';
	return
else
	b = b .* window(:).';
end

%-------------------------------------------------------------------------------
function [n,fc,fs,R,designType,window,msg] = parse_inputs(varargin)

% Initialize in case of early return
n = [];
fc = [];
fs = [];
R = [];
designType = '';
window = [];
msg = '';

N = varargin{1};
if isempty(N) | round(N) ~= N | N < 0,
   msg = 'Order must be a positive integer.';
   return
end
L = N+1; % Length of window

fc = varargin{2};

R = varargin{3};  % DF or R

% If optional arguments are not passed, substitute with empty:
for i = nargin+1:8,
   varargin{i}=[];
end

arg5opts = {'rolloff','sqrt','normal','bandwidth'};
% map 5th arg to one of 4 possible choices:
if isempty(varargin{5}),
   varargin{5} = arg5opts{3};
else
   idx = strmatch(lower(varargin{5}), arg5opts);
   if isempty(idx),
      msg = 'Argument 5 is unknown - must be one of: rolloff, bandwidth, sqrt, or normal.';
	  return
   end
   varargin{5} = arg5opts{idx};
end

% Apply defaults as appropriate:
%
% Set up default values
fs = 2;
designType = arg5opts{3};
if rem(L,2),
   delay = (L-1)/2;
else
   delay = L/2;
end


% Setup arg translation:
params = {'fs','designType','delay','window'};

% We define a flag to indicate whether a string for the transition region type was specified
isTranRegionStr = strcmp(varargin{5},'rolloff') | strcmp(varargin{5},'bandwidth');

if isTranRegionStr,
   xlat = [4 6:8];
else
   xlat = 4:7;
end

% Override defaults when needed:
for i=1:length(xlat),
   arg = varargin{xlat(i)};
   if ~isempty(arg),
   	 eval([params{i} '=arg;']);
   end
end

% Check for validity of fs
if ischar(fs),
   msg = 'Fs must be a number';
   return
end

% Check for valid cutoff frequency
if (fc <= 0) | (fc >= fs./2),
   msg = 'The cutoff frequency, Fc, must satisfy 0 < Fc < Fs/2.';
   return
end

% Check for valid rolloff or bandwidth values
if strcmp(varargin{5},'rolloff'),
   % check if input arguments are valid 
   if R < 0 | R > 1,
      msg = 'The rolloff factor, R, must satisfy 0 <= R <= 1.';
	  return
   end
   % check for range of input arguments
   if (fc + R.*fc) > fs/2
      msg = sprintf(['The cutoff frequency, Fc, and rolloff factor, R,\n',...
			  'must be specified such that Fc + Fc*R <= Fs/2.']);
	  return
   end
elseif strcmp(varargin{5},'bandwidth') | ~isTranRegionStr % arg5 is bandwidth, sqrt or normal
   % check for range of input arguments
   if fc - R/2 < 0 | fc + R/2 > fs/2
      msg = sprintf(['The cutoff frequency, Fc, and the transition bandwidth, DF,\n',...
			  'must be specified such that Fc +/- DF/2 is between zero and Fs/2.']);
	  return
   end
   % bandwidth is valid, convert to rolloff
   R = R / (2*fc);
end

if delay < 0 | delay > L
   msg = 'DELAY must be in the range [0, L+1].';
   return
elseif round(delay) ~= delay
   msg = 'DELAY must be an integer.';
   return
end

% R is now always a rolloff factor - DF has been converted
if R == 0,
   R = realmin;
end

%n = -delay/fs : 1/fs : (L-delay-1)/fs;
n = ((0:L-1)-delay) ./ fs;

if isTranRegionStr, % 6th argument, if present, is designType
   arg6opts = {'sqrt','normal'};
   % map 6th arg to one of 2 possible choices:
   if isempty(varargin{6}),
      designType = arg6opts{2};
   else
      idx = strmatch(lower(varargin{6}), arg6opts);
      if isempty(idx),
         msg = 'Argument 6 is unknown - must be one of: sqrt, normal or [].';
		 return
      end
      designType = arg6opts{idx};
   end
end

% EOF
