function [f,g,d] = ifir(L,designType,F,DEV,optlevel)
%IFIR  Interpolated FIR filter design.
%   [H,G] = IFIR(L,TYPE,F,DEV) finds a periodic filter H(z^L) where
%   L is the interpolation factor and an image-suppressor filter G(z)
%   such that the cascade of the two filters represents the optimal
%   minimax FIR approximation to the desired response specified by
%   TYPE with bandedge frequencies contained in vector F while not
%   exceeding the peak ripples specified in vector DEV.
%
%   TYPE must be a string with either 'low' for lowpass designs or
%   'high' for highpass designs.  F must be a two-element vector with
%   passband and stopband edge frequency values. For narrowband lowpass
%   filters and wideband highpass filters, L*F(2) should be less than 1.
%   For wideband lowpass filters and narrowband highpass filters,
%   L*(1-F(1)) should be less than 1.
%
%   DEV must contain the peak ripple or deviation allowed for both the
%   passband and the stopband, i.e., it also must be a two-element
%   vector.
%
%   [H,G,D] = IFIR(L,TYPE,F,DEV) returns a delay D that must be 
%   connected in parallel with the cascade of H(z^L) and G(z) in
%   the case of wideband lowpass and highpass filters. This is necessary
%   in order to obtain the desired response. See example 2 below or
%   the Filter Design Toolbox documentation for more information on
%   these cases.
%
%   [...] = IFIR(...,STR) uses the string specified in STR to
%   choose the algorithm level of optimization used. STR can be one
%   of: 'simple', 'intermediate' (default) or 'advanced'. STR basically 
%   provides for a tradeoff between design speed and filter order
%   optimization. The 'advanced' option can result in substantial
%   filter order reduction, especially for G(z).
%
%   EXAMPLE 1: Narrowband lowpass design using an interpolation factor of 6.
%      [h,g]=ifir(6,'low',[.12 .14],[.01 .001]);
%      H = dfilt.dffir(h); G = dfilt.dffir(g);
%      hfv = fvtool(H,G);
%      legend(hfv,'Periodic Filter','Image Suppressor Filter');
%      Hcas = cascade(H,G);
%      hfv2 = fvtool(Hcas);
%      legend(hfv2,'Overall Filter');
%
%   EXAMPLE 2: Wideband highpass design using an interpolation factor of 6.
%      [h,g,d]=ifir(6,'high',[.12 .14],[.001 .01]);
%      H = dfilt.dffir(h); G = dfilt.dffir(g);
%      Hb1 = cascade(H,G); % Branch 1 
%      Hb2 = dfilt.dffir(d); % Branch 2 
%      Hoverall = parallel(Hb1,Hb2); % Overall wideband highpass
%      hfv =  fvtool(Hoverall);
%      legend(hfv,'Overall Filter');
%
%   See also FIRGR, FIRNYQUIST, FIRHALFBAND, FIRPM.

% References: T. Saramaki, FINITE IMPULSE RESPONSE FILTER DESIGN, in
%               HANDBOOK FOR DIGITAL SIGNAL PROCESSING. S.K. Mitra and J.F.            
%               Kaiser Eds. Wiley-Interscience, N.Y., 1993, Chapter 4.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.5 $  $Date: 2004/04/12 23:25:35 $

error(nargchk(4,5,nargin));

if nargin < 5, optlevel = 'intermediate'; end

[optlevel,F,DEV,designType,forceEven,msg] = parseinput(L,designType,F,DEV,optlevel);
error(msg);

% Design a prototype narrowband lowpass IFIR filter
% At this point specs may have been modified as needed
[f,g] = narrowBandLp(L,F,DEV,optlevel,forceEven);


switch designType,
case 'narrowBandLp',
	% Create an object for the narrowband lowpass
	[f,g,d] = designnl(f,g,L);
	
case 'wideBandLp',
	% Create an object for the wideband lowpass
	[f,g,d] = designwl(f,g,L);
	
case 'narrowBandHp',
	% Create an object for the narrowband highpass
	[f,g,d] = designnh(f,g,L);
	
case 'wideBandHp',
	% Create an object for the wideband highpass
	[f,g,d] = designwh(f,g,L);
	
end
	

%------------------------------------------------------------------
function [f,g,d] = designnl(f,g,L)
% Create an object for the narrowband lowpass

% Upsample f, create F(z^L)
f = upsample(f,L);

% Remove trailing zeros
f = f(1:end - (L-1));

d = []; % Not used for narrowband lowpass

%------------------------------------------------------------------
function [f,g,d] = designwl(f,g,L)
% Create an object for the wideband lowpass

% Create two parallel branches, one with a narrowband highpass and one with
% a delay
[f,g] = designnh(f,g,L);

d((length(f)+length(g)-2)./2+1) = 1; % Delay


% M = order(branch1)./2;
% dly(M+1) = 1; % z^(-N/2)
% branch2 = dffir(dly);
% 
% % Connect the two branches in parallel
% h = par(branch1,branch2);

%------------------------------------------------------------------
function [f,g,d] = designnh(f,g,L)
% Create an object for the narrowband highpass

% Find F((-z)^L),
if rem(L,2),
	% Find F(-z) first
	f(2:2:end) = -f(2:2:end);
end
% Now upsample
f = upsample(f,L);

% Find G(-z)
g(2:2:end) = -g(2:2:end);

% Create an object with the cascade of the two filters
h = cascade(dfilt.dffir(f),dfilt.dffir(g));

M = order(h)./2;
if ~rem(M,2),
	% Must add a negative 1 factor to branch1
 	h = cascade(dfilt.dffir(-f), dfilt.dffir(g));
end

% % Get the coeffs from the object
f = tf(h.Section(1));
g = tf(h.Section(2));
d = []; % Not used for narrowband highpass

%------------------------------------------------------------------
function [f,g,d] = designwh(f,g,L)
% Create an object for the wideband highpass

% Create two parallel branches, one with a narrowband lowpass (entering
% with a minus sign to the adder) and one with a delay
[f,g] = designnl(-f,g,L);  % the -f is needed because of the negative 
                           % sign of this branch entering the adder

						   
d((length(f)+length(g)-2)./2+1) = 1; % Delay
% M = order(branch1)./2;
% dly(M+1) = 1; % z^(-N/2)
% branch2 = dffir(dly);
% 
% % Connect the two branches in parallel
% h = par(branch1,branch2);

%------------------------------------------------------------------
function [f,g] = narrowBandLp(L,F,DEV,optlevel,forceEven)
% Design a prototype narrowband lowpass IFIR filter

% Define the lowpass response appropriate for firpm
A = [1 1 0 0];
switch optlevel,
case {'simple','intermediate'},
	
	if forceEven,
		minStr = 'mineven';
	else
		minStr = 'minorder';
	end
	f = firgr(minStr,[L.*F(1:3) 1],A,[DEV(1)./2 DEV(2)]);
	
	g = computeg(L,F,A,DEV,optlevel,minStr);
	
case 'advanced',
	[f,g] = recursivedesign(L,F,A,DEV,forceEven);
end

%----------------------------------------------------------------
function g = computeg(L,F,A,DEV,optlevel,minStr)


switch lower(optlevel),
case 'simple',
	% Compute G as a simple lowpass
	g = firgr(minStr,[0 F(2) 2./L-F(3) 1],A,[DEV(1)./2 DEV(2)]);
case 'intermediate',
	% Improve the order of G in some cases by including don't care regions
	g = computeintermediateg(L,F,DEV,minStr);
	
end
	
%----------------------------------------------------------------
function g = computeintermediateg(L,F,DEV,minStr)

% Compute do care and don't care regions for g
Fg = gFreqIntervals(F,L);

Ag = [1 1 zeros(1,length(Fg)-2)];
DEVg = [DEV(1)./2 DEV(2)*ones(1,(length(Ag)-2)./2)];

g = firgr(minStr,Fg,Ag,DEVg);

%----------------------------------------------------------------
function [fnew,gnew] = recursivedesign(L,F,A,DEV,forceEven)
% Compute F and G recursively

% Estimate required orders for F and G
N1 = ceil(estimateFord(L,F,A,DEV));
N2 = ceil(estimateGord(L,F,DEV));

if forceEven,
	% For certain cases (wideband) for orders to be even
	if rem(N1,2),
		N1 = N1 + 1;
	end
	if rem(N2,2),
		N2 = N2 + 1;
	end
end

% Initialize
fold = [1,zeros(1,N1)];
gold = [zeros(1,N2+1)];

% Compute first iteration
gnew = iterateg(N2,L,fold,F);
fnew = iteratef(N1,L,gnew,F,DEV);

tol = 1e-10;
iter = 0;
maxiter = 100;

while ((norm(fold-fnew,inf) > tol) || (norm(gold-gnew,inf) > tol)) && (iter < maxiter),
	
	% Update old baselines
	gold = gnew;
	% Compute new G
	gnew = iterateg(N2,L,fnew,F);
	
	% Update old baselines
	fold = fnew;
	% Compute new F
	fnew = iteratef(N1,L,gnew,F,DEV);
    
    iter = iter + 1;
end

if iter == maxiter,
    warnstr = sprintf('The iteration limit has been reached.\nDesign may not be right, check with FVTool.');
    warning(generatemsgid('iterationLimit'),warnstr);
end
%----------------------------------------------------------------
function g = iterateg(N2,L,f,F)
% Compute one iteration of G

% Compute do care and don't care regions of g
Fg = gFreqIntervals(F,L);

% Select a very narrow passband with a large weight so that the firpm
% algorithm uses only one frequency grid point in the passband
% Define a small passband edge 
epsilon = 1e-5;
Fedges = [0 epsilon Fg(3:end)];

% Define a large weight
Wpass = 5000;

W = [Wpass ones(1,(length(Fedges)-2)/2)];
    
% Design g
g = firgr(N2,Fedges,{'ifirgfresp',f,L},W);

%----------------------------------------------------------------
function f = iteratef(N1,L,g,F,DEV)
% Compute one iteration of F

% Design g
Fstreched = [F(1) L*F(2) L*F(3) 1];
f = firgr(N1,Fstreched,{'ifirffresp',g,L,DEV});

%----------------------------------------------------------------
function  Fg = gFreqIntervals(F,L)
% Compute do care and don't care regions of g

Fg = [0, F(2), 2./L-F(3)];
n = 2;
while 2.*n./L-F(3) < 1;
	Fg = [Fg, 2.*(n-1)./L+F(3), 2.*n./L-F(3)];
	n = n+1;
end
Fg = [Fg,1];

%------------------------------------------------------------------
function N1 = estimateFord(L,F,A,DEV)
% Estimate required order for F

% Estimate order for conventional design
b = firgr('minorder',F,A,DEV);

% Divide order by L to get an estimate of the streched designed order
N1 = (length(b)-1)./L;

%------------------------------------------------------------------
function N2 = estimateGord(L,F,DEV)
% Estimate required order for G
% From formula in reference

tempArg1 = 1./acosh(acoshArg(F(2),2./L - (F(2)+2.*F(3))./3));

tempArg2 = .5.*L./acosh(acoshArg(L.*F(2)./2,1 - L.*(F(2)+2.*F(3))./6));

N2 = acosh(1./DEV(2)).*(tempArg1+tempArg2);

%-------------------------------------------------------------------
function arg = acoshArg(w1,w2)

arg = (2.*cos(w1.*pi) - cos(w2.*pi) + 1)./(1 + cos(w2.*pi));

%-------------------------------------------------------------------
function [optlevel,Fout,DEV,designType,forceEven,msg] = parseinput(L,designType,F,DEV,optlevel)

% Initialize in case of early return
msg = '';
Fout = [];
forceEven = [];

% Determine what algorithm to use
[optlevel,msg] = determineAlgorithm(optlevel);
if ~isempty(msg),
	return
end

% Check for increasing frequencies
if any(diff(F) <= 0),
	msg = 'Frequencies must be specified in increasing order.';
	return
end

% Determine design type and convert spec to narrow lowpass
[Fout,forceEven,designType,DEV,msg] = determineTypeNSpecs(L,designType,F,DEV);
if ~isempty(msg),
	return
end


%-------------------------------------------------------------------------
function [optlevel,msg] = determineAlgorithm(optlevel)
% Determine which algorithm to use

msg = '';
stropts = {'simple','intermediate','advanced'};

indx = strmatch(lower(optlevel),stropts);

if isempty(indx),
	msg = 'Unrecognized optimization level specified.';
	return
end

optlevel = stropts{indx};

%------------------------------------------------------------------------
function [Fout,forceEven,designType,DEV,msg] = ...
	determineTypeNSpecs(L,designType,F,DEV)
% Determine design type and convert spec to narrow lowpass

% Defaults
msg = '';
Fout = [0 F 1]; % Prepend and append zeroes to make it firpm compatible
forceEven = 0;


interpfactErr = 'The interpolation factor must be an integer greater than one.';
if L ~= round(L) | L < 2,
	msg = interpfactErr;
	return
end

% Determine if lowpass or highpass
designOpts = {'low','high'};
designIndx = strmatch(lower(designType),designOpts);

if isempty(designIndx),
	msg = 'Design type must be ''LOW'' or ''HIGH''.';
	return
end

designType = designOpts{designIndx};

% Determine if narrow-band or wide-band design
switch designType,
case 'low',
	if F(2) < 1/2,
		designType = 'narrowBandLp';
	else
		designType = 'wideBandLp';
		Fout = [0,1-F(2),1-F(1),1];
		DEV = fliplr(DEV);
		forceEven = 1;
		
	end
case 'high',
	if F(2) < 1/2,
		designType = 'wideBandHp';
		forceEven = 1;
		
	else
		designType = 'narrowBandHp';
		Fout = [0,1-F(2),1-F(1),1];
		DEV = fliplr(DEV);
	end
end
	
% Check for a valid interpolation factor	
interperr = 'The interpolation factor L is too large for the frequency specs.';
switch designType,
case {'narrowBandLp','wideBandHp'},
	
	if L.*F(2) >= 1,
		msg = interperr;
		return
	end
case {'narrowBandHp','wideBandLp'},
	if L.*(1-F(1)) >= 1,
		msg = interperr;
		return
	end
end


% [EOF]
