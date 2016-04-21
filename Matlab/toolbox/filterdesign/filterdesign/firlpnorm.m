function [b,err] = firlpnorm(varargin)
%FIRLPNORM Least P-norm optimal FIR filter design.
%   B = FIRLPNORM(N,F,EDGES,A) returns a filter having a numerator
%   order N which is the best approximation to the desired  frequency 
%   response described by F and A in the least-Pth sense, where P=128.
%   The vector EDGES specifies the band-edge frequencies for multi-band 
%   designs.  An unconstrained quasi-Newton algorithm is employed.  
%   Always check the resulting filter using FREQZ.
%
%   F and A must have the same number of elements, which may exceed the
%   number of elements in EDGES.  This allows for the specification of
%   filters having any gain contour within each band.  The frequencies 
%   specified in EDGES must also appear in the vector F.  
%
%   B = FIRLPNORM(N,F,EDGES,A,W) uses the weights in W to weight the
%   error.  W has one entry per frequency point (the same length length as F
%   and A) which tells FIRLPNORM how much emphasis to put on minimizing the
%   error in the vicinity of each frequency point relative to the other points.
%
%   B = FIRLPNORM(N,F,EDGES,A,W,P) where P is a two-element vector
%   [Pmin Pmax] allows for the specification of the minimum and maximum values
%   of P used in the least-Pth algorithm. Default is [2 128] which essentially
%   yields the L-infinity, or Chebyshev, norm. Pmin and Pmax should be even.
%   If P is the string 'inspect', no optimization will occur. This can be used
%   to inspect the initial pole/zero placement. The algorithm starts the
%   optimization with Pmin, and then moves towards an optimal filter in
%   the Pmax sense.
%
%   B = FIRLPNORM(N,F,EDGES,A,W,P,DENS) specifies the grid density DENS
%   used in the optimization. The number of grid points is DENS*(N+1).
%   The default is 20. DENS can be specified as a single-element cell array.
%   The grid is equally spaced.
%
%   B = FIRLPNORM(N,F,EDGES,A,W,P,DENS,INITNUM) allows for the specification 
%   of the initial estimate of the filter coefficients in vector INITNUM.  
%   This may be useful for difficult optimization problems.  The pole-zero 
%   editor in the Signal Processing Toolbox can be used for generating INITNUM.
%
%   [B,ERR] = FIRLPNORM(...) returns the least-Pth approximation error ERR.
%
%   B = FIRLPNORM(...,'minphase') where the string 'minphase' is the last
%   argument results in a minimum-phase FIR filter.  The default is mixed phase.
%   The minimum-phase optimization method used is different from the mixed-
%   phase optimization and may yield slightly different results.
%
%   EXAMPLE 1:
%      % Lowpass filter with a peak of 1.4 within the passband.
%      B = firlpnorm(22,[0 .15 .4 .5 1],[0 .4 .5 1],[1 1.4 1 0 0],[1 1 1 2 2]);
%
%   See also FIRGR, IIRLPNORM, IIRLPNORMC, FREQZ, IIRGRPDELAY, ZPLANE, FILTER.

%   Author(s): D. Shpak
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/12 23:25:30 $ 

%   References:
%     [1] A. Antoniou, Digital Filters:  Analysis, Design, and Applications,
%         2nd ed., McGraw-Hill, 1993.

if nargin > 4 & ischar(varargin{end}) & ...
		~isempty(strmatch(lower(varargin{end}),'linphase')),
    
    warning('The linear phase option is no longer supported and will be removed in future versions.');
	% Design a linear phase filter
	[b,err,err_msg] = firlpnorm_lp(varargin{1:end-1});
	error(err_msg);
else
	% Design a nonlinear phase filter
	[b,err] = firlpnorm_nlp(varargin{:});
end


%-----------------------------------------------------------------------
function [b,err,err_msg] = firlpnorm_lp(varargin)
%FIRLPNORM_LP Linear phase FIRLPNORM function.
%   This function calls the nonlinear phase FIRLPNORM function and then
%   convolves the resulting filter with a reversed version of it to 
%   obtain a linear phase filter.

err_msg = '';

% Use half the order
if rem(varargin{1},2),
	err_msg = 'To design a linear phase filter you must specify an even order.';
	return
else
	varargin{1} = varargin{1}./2;
end

% Take sqrt of magnitude specs
varargin{4} = sqrt(varargin{4});

% Design nonlinear phase filter
[b,err] = firlpnorm_nlp(varargin{:});

% Create linear phase filter
b = conv(b,fliplr(b));
% Make sure it is symmetric
b = (b + fliplr(b))./2;

% Error has been doubled
err = 2.*err;

%-----------------------------------------------------------------------
function [b,err] = firlpnorm_nlp(numOrd,f,edges,des,varargin)
%FIRLPNORM_NLP Nonlinear phase FIRLPNORM function.


if length(varargin) > 0 & ~iscell(varargin{end}) & strcmp ('minphase', lower(varargin{end}))
    minPhase = 1;
    if length(varargin) == 1
        myArgin = {};
    else
    	myArgin = varargin(1:end-1);
    end
else
    minPhase = 0;
	myArgin = varargin;
end
if nargin > 5
   myArgin = {myArgin{1} 0.9 myArgin{2:end}};  % To satisfy iirparser.
end

% Parse the input
s = iirparser(4+minPhase,numOrd,0,f,edges,des,myArgin{:});

% Design the filter
[b,err]=firlpnormmex(s.numOrd,s.edges,s.f,...
    s.des,s.wt,s.P,s.density,s.BS,minPhase);

% Compute the transfer function and the sos matrix. b(1) is sos gain
if minPhase == 1
	[b,a,sos] = computetfandsos(s.numOrd,0,b(2:end),[],b(1));
else
    sos = []; % This could be expensive to compute
end

% EOF

