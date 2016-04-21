function [num,den] = iircomb(N,BW,varargin)
%IIRCOMB IIR comb notching or peaking digital filter design.
%   [NUM,DEN] = IIRCOMB(N,BW) designs an Nth order comb notching digital 
%   filter with a -3 dB width of BW. N which must be a positive integer
%   is the number of notches in the range [0 2pi).  The notching filter 
%   transfer function is in the form
%
%                 1 - z^-N
%      H(z) = b * ---------
%                 1 - az^-N
%
%   The bandwidth BW is related to the Q-factor of a filter by BW = Wo/Q.
%
%   [NUM,DEN] = IIRCOMB(N,BW,Ab) designs a notching filter with a bandwidth
%   of BW at a level -Ab in decibels. If not specified, -Ab defaults to the 
%   -3 dB level (10*log10(1/2).  For peaking comb filters the default Ab is
%   3 dB or 10*log10(2).
%
%   [NUM,DEN] = IIRCOMB(...,TYPE) designs a comb filter with the specified
%   TYPE as either 'notch' or 'peak'.  If not specified it defaults to 'notch'.
%
%   The peaking filter transfer function is in the form
%
%                 1 + z^-N
%      H(z) = b * ---------
%                 1 - az^-N
%
%   EXAMPLE:
%      % Design a filter with a Q=35 to remove a 60 Hz periodic tone
%      % from system running at 600 Hz.
%      Fs = 600; Fo = 60;  Q = 35; BW = (Fo/(Fs/2))/Q;
%      [b,a] = iircomb(Fs/Fo,BW,'notch');  
%      fvtool(b,a);
% 
%   See also IIRNOTCH, IIRPEAK, FIRGR.

%   Author(s): P. Pacheco
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:25:36 $ 

%   References:
%     [1] Sophocles J. Orfanidis, Introduction To Signal Processing
%         Prentice-Hall 1996.

error(nargchk(2,4,nargin));

% Validate input arguments.
[Ab,type,msg] = combargchk(N,BW,varargin);
error(msg);

if strmatch(type, 'notch'),
    % Design a notching comb digital filter.
    [num,den] = notchingComb(N,BW,Ab);
else
    % Design a peaking comb digital filter.
    [num,den] = peakingComb(N,BW,Ab);
end

%------------------------------------------------------------------------
function [b,a] = notchingComb(N,BW,Ab)
% Design a comb digital filter.

% Inputs are normalized by pi.
BW = BW*pi;
D = N;

Gb   = 10^(-Ab/20);
beta = (sqrt(1-Gb.^2)/Gb)*tan(D*BW/4);
gain = 1/(1+beta);

ndelays = zeros(1,D-1);
b = gain*[1 ndelays -1];
a = [1 ndelays -(2*gain-1)];

%------------------------------------------------------------------------
function [b,a] = peakingComb(N,BW,Ab)
% Design a comb digital filter.

% Inputs are normalized by pi.
BW = BW*pi;
D = N;

Gb   = 10^(-Ab/20);
beta = (Gb/sqrt(1-Gb.^2))*tan(D*BW/4);
gain = 1/(1+beta);

ndelays = zeros(1,D-1);
b = (1-gain)*[1 ndelays -1];
a = [1 ndelays (2*gain-1)];

%------------------------------------------------------------------------
function [Ab,type,msg] = combargchk(N,BW,opts);
% Checks the validity of the input arguments to IIRCOMB.

% Initialize output args. to empty.
Ab = [];
type = '';

msg = checkOrder(N);
if msg, return, end

msg = checkBW(BW);
if msg, return, end

[Ab,type,msg] = parseoptions(opts);
if msg, return, end

%------------------------------------------------------------------------
function msg = checkOrder(N)
% Checks the validity of the input arg that specifies the order (or delays).

msg='';
if ~isnumeric(N) | ~all(size(N)==1) | N~=round(N), % Make sure it's an integer
    msg = 'The filter order N must be a positive integer.';
end

%------------------------------------------------------------------------
function [Ab,type,msg] = parseoptions(opts)
% Parse the optional input arguments.

% Define default values.
Ab = abs(10*log10(.5)); % 3-dB width
type = 'notch';

msg='';
switch length(opts)
case 1,
    if ~ischar(opts{1}),
        [Ab,msg] = checkAtten(Ab,opts{1});
    else
        [type,msg] = checkCombType(type,opts{1}); % For comb filters.
    end
    
case 2,
    [Ab,msg] = checkAtten(Ab,opts{1});
	if msg, return, end
    [type, msg] = checkCombType(type,opts{2});    
	if msg, return, end
end
%------------------------------------------------------------------------
function msg = checkBW(BW)
% Check that BW is valid.

msg = '';
if (BW <= 0) | (BW >= 1),
    msg = 'The bandwidth BW must be within 0 and 1.';
end

%------------------------------------------------------------------------
function [Ab,msg] = checkAtten(Ab,option)
% Determine if input argument is the attenuation scalar value.

msg = '';
if isnumeric(option) & all(size(option)==1),  % Make sure it's a scalar
	Ab = abs(option);  % Allow - or + values
else
	msg = 'Level of decibels specified by Ab must be a scalar.';
end

%------------------------------------------------------------------------
function [type,msg] = checkCombType(type,option)
% Determine if input argument is the string 'notching' or 'peaking'.

msg = '';
isValidStr = ~isempty(strmatch(lower(option),'notch')) |...
             ~isempty(strmatch(lower(option),'peak'));
if ~isValidStr,
    msg = 'Invalid option.  To specify the type of comb filter, use ''notch'' or ''peak''.';
else
    type = lower(option);
end

% [EOF]
