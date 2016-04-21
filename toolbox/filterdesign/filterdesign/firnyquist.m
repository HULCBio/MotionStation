function b = firnyquist(N,L,R,varargin)
%FIRNYQUIST  Nyquist (L-th band) FIR filter design.
%   B = FIRNYQUIST(N,L,R) designs an N-th order, L-th band, Nyquist FIR
%   filter with a rolloff factor R and an equiripple characteristic.
%   The rolloff factor R is related to the normalized transition width
%   TW by: TW = 2*Pi*R/L [rad/sample].
%
%   The order, N, must be even. L must be an integer greater than one.
%   If L is not specified, it defaults to 4.  R must be such that
%   0 < R < 1. If R is not specified, it defaults to 0.5.
%
%   B = FIRNYQUIST(N,L,WIN) designs an N-th order, L-th band,
%   Nyquist FIR filter using the N+1 length vector WIN to window the
%   truncated impulse response.
%
%   B = FIRNYQUIST('minorder',L,R,Dev) designs a minimum order,
%   L-th band Nyquist FIR filter with a rolloff factor R using a Kaiser
%   window. The peak ripple is constrained by the scalar Dev.
%
%   B = FIRNYQUIST(N,L,R,D) and B = FIRNYQUIST(N,L,R,D,'normal')
%   specify the rate of decay (attenuation) in the stopband by means of
%   the scalar D. D must be nonnegative. If omitted or left empty,
%   D defaults to 0, which yields an equiripple stopband. A nonequiripple
%   stopband may be desirable for decimation purposes.
%
%   B = FIRNYQUIST(N,L,R,'nonnegative') and 
%   B = FIRNYQUIST(N,L,R,D,'nonnegative') return an FIR filter with
%   nonnegative zero-phase response.  This filter can be spectrally
%   factored into a minimum-phase and a maximum-phase "square-root"
%   filters. This allows the use of the spectral factors in matched-
%   filtering applications.
%
%   Bmin = FIRNYQUIST(N,L,R,'minphase') returns a minimum-phase FIR
%   spectral factor Bmin of order N such that B = CONV(Bmin,Bmax) is
%   an L-th band FIR Nyquist filter of order 2N with rolloff factor R.
%   Bmax, the maximum-phase spectral factor, can be obtained by simply
%   reversing the coefficients of Bmin, i.e., Bmax = Bmin(end:-1:1).
%
%   NOTE: The equiripple case can present numerical problems. Always
%   verify your result with FREQZ.
%
%   EXAMPLE 1: Design a minimum-phase factor of a Nyquist filter.
%      bmin = firnyquist(47,10,.45,'minphase');
%      b = firnyquist(2*47,10,.45,'nonnegative');
%      [h,w,s]  = freqz(b); hmin = freqz(bmin);
%      fvtool(b,1,bmin,1);
%
%   EXAMPLE 2: Comparison of filters with different decay
%      b1 = firnyquist(72,8,.2,0); % Equiripple
%      b2 = firnyquist(72,8,.2,10);
%      b3 = firnyquist(72,8,.2,20);
%      fvtool(b1,1,b2,1,b3,1);
%
%   See also FIRHALFBAND, FIRRCOS, FIRGR, FIRMINPHASE, FIRLS,
%   FDESIGN/NYQUIST, FDESIGN/HALFBAND, FREQZ.

%   References: 
%     [1] T. Saramaki, Finite impulse response filter design, in 
%          Handbook for Digital Signal Processing. S.K. Mitra and
%          J.F. Kaiser Eds. Wiley-Interscience, N.Y., 1993, Chapter 4.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.3 $  $Date: 2004/04/12 23:25:32 $

error(nargchk(1,5,nargin));


if nargin < 2 | isempty(L),     L = 4; end
if nargin < 3 | isempty(R),     R = 0.5; end

[isMinOrd,isRemez,Dev,Decay,nonNegFlag,minPhaseFlag,msg] = parse_optIn(N,L,R,varargin{:});
error(msg);

if isRemez,
		% Use equiripple method
	b = firpmdesign(N,L,R,Decay,nonNegFlag,minPhaseFlag);
else
	% Use Kaiser window method
	b = kaiserdesign(N,L,R,isMinOrd,Dev);
end

%---------------------------------------------------------------------
function b = kaiserdesign(N,L,R,isMinOrd,Dev)
% Nyquist filter design via Kaiser window
%
% R can be a rolloff if scalar or a window if vector

if isMinOrd,
	% R is rolloff
	[N,wn,beta] = computeOrd(L,R,Dev,'k');
	R = kaiser(N+1,beta); % Now R is window
end


% Now design the lowpass windowed filter, don't use fir1 so we get
% exact zeros every L-th sample and exactly 1/L for the middle sample
b = lowpasslband(N,L,R);

%---------------------------------------------------------------------
function b = firpmdesign(N,L,R,Decay,nonnegativeflag,minPhaseFlag)
% Nyquist filter design via firpm

% If minimum phase design, design a nonnegative zerophase
% filter of twice the order. We will then extract the 
% minimum phase factor resulting in a filter with the original order.
if minPhaseFlag,
	N = 2*N;
end

% Determine K = integer(N/2L)
M = N./2; K = fix(M./L);

% Initialize algorithm
hp = 1;
if nonnegativeflag,
	% Initial guess of extremal frequencies
	Omega = zeros(fix((M-K)./2)+1,1);
	% Initialize such that difference is greater than alpha
	Omegabar = ones(fix((M-K)./2)+1,1); 
else
	% Initial guess of extremal frequencies
	Omega = zeros(M-K+1,1);
	% Initialize such that difference is greater than alpha
	Omegabar = ones(M-K+1,1); 
end

alpha = 1e-6; % Tolerance constant
iter = 0;
maxiter = 100;
while (norm(Omega-Omegabar,inf) > alpha) && (iter < maxiter),
    iter = iter + 1;
    Omega = Omegabar;
	% Compute both subfilters, Hp and Hs, iteratively
	[hs,hsbar,hp,Omegabar] = iterate(M,K,R,L,hp,nonnegativeflag,Decay);
end

if iter == maxiter,
    warnstr = sprintf('The iteration limit has been reached.\nDesign may not be right, check with FVTool.');
    warning(generatemsgid('iterationLimit'),warnstr);
end

if ~minPhaseFlag,
	b = conv(hp,hs);
	% Enforce symmetry
	b = (b + b(end:-1:1))./2;

else
	hpmin = firminphase(hp);
	b = conv(hsbar,hpmin);
end

%-------------------------------------------------------------
function [hs,hsbar,hp,Omegabar] = iterate(M,K,R,L,hp,nonnegativeflag,Decay)
% Compute both subfilters, Hp and Hs, iteratively

% Compute the Hs factor of the overall filter
[hs,hsbar,res,ws] = computehs(M,K,R,L,hp,nonnegativeflag,Decay);

% Store extremal frequencies 
extremfreqs = res.fgrid(res.iextr);

% Keep the ones in the stopband
Omegabar = extremfreqs(extremfreqs>ws./pi);

% Compute the other part, Hp, of the overall filter
hp = computehp(hs,K,L,M);


%-------------------------------------------------------------
function [hs,hsbar,res,ws] = computehs(M,K,R,L,hp,nonnegativeflag,Decay)
% Compute the Hs factor of the overall filter

% Define a small passband edge for Hs
epsilon = 1e-9;

% Define a large weight
Wpass = 5000;

% Compute the stopband edge
ws = (1+R)./L;

Fedges = [0 epsilon ws 1];

W = [Wpass 1];

if nonnegativeflag,
	[hsbar,err,res] = firgr(M-K,Fedges,...
        {'firnyquistfresp',hp,nonnegativeflag,Decay},W);
	hs = conv(hsbar,hsbar);
else
    [hs,err,res] = firgr(2.*(M-K),Fedges,...
        {'firnyquistfresp',hp,nonnegativeflag,Decay},W);
    hsbar = 1; % Bogus, but won't be used anyway
end


%-------------------------------------------------------------
function hp = computehp(hs,K,L,M)
% Given hs, compute new hp such that the Nyquist constrains hold.
% To do so, use the matrix form of convolution, and retain only
% the rows of the convolution matrix for which b=conv(hs,hp) is
% known. Further, use the symmetry of coefficients to reduce
% the number of equations by half, and solve for hp.

A = convmtx(hs(:),2.*K+1);

% To reduce the number of equations we "fold" the convolution matrix
Ared = [2*A(M+1,1:K),A(M+1,K+1);...
		2*(A(M+2:end,1:K)+A(M:-1:1,1:K)),2*A(M+2:end,K+1)];

% Form indexes of known entries of b
indx = [1:L:M+1];

% Form rhs of system of equations (decimate b to known values)
breddec = [1./L;zeros(K,1)];

% Form decimated reduced convolution matrix
Areddec = Ared(indx,:); % Should result in a KxK dimensional matrix

% Compute halfhp from Areddec*halfhp = breddec
halfhp = Areddec\breddec;

% Form type I filter
hp = [halfhp;halfhp(K:-1:1)];

%---------------------------------------------------------------------------
function [N,varargout] = computeOrd(L,R,Dev,str)

% Find the bandedges by converting rolloff to transition width
TW = 2*R/L;
fp = 1./L - TW./2;
fs = 1./L + TW./2;

switch str,
case 'k',
	% Find the minimum order required
	[N,wn,beta] = kaiserord([fp,fs],[1 0],[Dev,Dev]);
	varargout = {wn,beta};
case 'r',
	[N,F,A,W] = firpmord([fp,fs],[1 0],[Dev,Dev]);
	varargout = {F,A,W};
end

% Make sure order is even
if (rem(N,2) == 1),
	N = N + 1;
end

%---------------------------------------------------------------------------
function [isMinOrd,isRemez,Dev,Decay,nonNegFlag,minPhaseFlag,msg] = parse_optIn(N,L,R,varargin)
% Parse optional inputs

% Generate defaults
isMinOrd = 0;
isRemez = 1;
Dev = [];
Decay = 0;
nonNegFlag = 0;
minPhaseFlag= 0;
S = 'normal';
msg = '';

if ischar(N),
	isMinOrd = 1;
	isRemez = 0;
	if (nargin < 4) | isempty(varargin{1}),
		msg = 'You must specify a peak ripple with the minorder option.';
		return
	end
end

% If R is a vector it is a window
if length(R) > 1,
	if isMinOrd,
		msg = 'You cannot specify a window vector with the ''minorder'' option.';
		return
	end

	isRemez = 0;
end

% If there is a 4th argument, it can be dev, decay or a string
if nargin > 3,
	if ischar(varargin{1}),
		S = varargin{1};
	elseif isnumeric(varargin{1}) & (length(varargin{1}) == 1),
		if isMinOrd,
			Dev = varargin{1};
		else
			Decay = varargin{1};
		end
	else
		msg = 'The 4th input argument must be a scalar or a string.';
		return
	end
end

% If there is a 5th arg, it must be a string 
if nargin > 4,
	S = varargin{2};
end

[nonNegFlag,minPhaseFlag,isRemez,msg] = validateinput(N,L,R,S,nonNegFlag,isRemez);
% Put a return here in case we add code below 
if ~isempty(msg),
	return
end
%-------------------------------------------------------------------
function [nonNegFlag,minPhaseFlag,isRemez,msg] = validateinput(N,L,R,S,nonNegFlag,isRemez)

% Initialize outputs
msg = '';
minPhaseFlag = 0; 


Lerrmsg = 'The L-th band must be an integer greater than one.';

if L ~= round(L),
	msg = Lerrmsg;
	return
end

if L <= 1,
	msg = Lerrmsg;
	return
end

if length(R) == 1, % If not it is a window vector
	Rerrmsg = 'The rolloff factor, R, must satisfy 0 < R < 1.';
	if R <= 0 | R >= 1,
		msg = Rerrmsg;
		return
	end
end

strOpts = {'nonnegative','normal','minphase'};
indx = strmatch(lower(S),strOpts);
if length(indx) ~= 1,
	msg = 'Unrecognized or ambiguous string specified.';
	return
end


switch indx,
case 1,
	nonNegFlag = 1;
case 3,
	minPhaseFlag = 1;
	% If minphase design mus be nonnegative
	nonNegFlag = 1;
end


if ~ischar(N),
	if ~isnumeric(N) | isnan(N) | isinf(N),
		msg = 'Unrecognized order specified.';
		return
	end
	
	Nerrmsg = 'The filter order must be an even integer.';
	
	
	if N ~= round(N),
		msg = Nerrmsg;
		return
	end
	
	if rem(N,2) & ~minPhaseFlag,
		msg = Nerrmsg;
		return
	end
end


% [EOF]


