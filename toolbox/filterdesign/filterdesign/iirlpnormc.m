function [b,a,err,sos,h0] = iirlpnormc(numOrd,denOrd,f,edges,des,varargin)
%IIRLPNORMC Constrained least P-norm optimal IIR filter design.
%   [NUM,DEN] = IIRLPNORMC(N,D,F,EDGES,A) returns a filter having a numerator
%   order N and denominator order D which is the best approximation to the
%   desired frequency response described by F and A in the least-Pth sense.
%   The vector EDGES specifies the band-edge frequency points, i.e., the point
%   where a frequency band starts/stops and a don't care regions stops/starts.
%   EDGES must always contain the first and last frequency points in F.
%   A constrained Newton-type algorithm is employed.  N and D should be chosen
%   so that the zeros and poles are used effectively.  See the hints below.
%   Always check the resulting filter using FREQZ.
%
%   F and A must have the same number of elements, which can exceed the
%   number of elements in EDGES.  This allows for the specification of
%   filters having any gain contour within each band.  The frequencies 
%   specified in EDGES must also appear in the vector F.  
%
%   [NUM,DEN] = IIRLPNORMC(N,D,F,EDGES,A,W) uses the weights in W to weight
%   the error.  W has one entry per frequency point (the same length as
%   F and A) which tells IIRLPNORMC how much emphasis to put on minimizing the
%   error in the vicinity of each frequency point relative to the other points.
%
%   [NUM,DEN] = IIRLPNORMC(N,D,F,EDGES,A,W,RADIUS) returns a filter having a
%   maximum pole radius of RADIUS where 0<RADIUS<1. RADIUS defaults to 0.999999. 
%   Filters having a reduced pole radius may retain better transfer function
%   accuracy when quantized.
%
%   [NUM,DEN] = IIRLPNORMC(N,D,F,EDGES,A,W,RADIUS,P) where P is a two-element
%   vector [Pmin Pmax] allows for the specification of the minimum and maximum
%   values of P used in the least-Pth algorithm. Default is [2 128] which
%   essentially yields the L-infinity, or Chebyshev, norm. Pmin and Pmax should
%   be even.  If P is the string 'inspect', no optimization will occur. This can
%   be used to inspect the initial pole/zero placement.
%
%   [NUM,DEN] = IIRLPNORMC(N,D,F,EDGES,A,W,RADIUS,P,DENS) specifies the grid
%   density DENS used in the optimization. The number of grid points is
%   DENS*(N+D+1).  The default is 20. DENS can be specified as a single-element
%   cell array.  The grid is not equally spaced.
%
%   [NUM,DEN] = IIRLPNORMC(N,D,F,EDGES,A,W,RADIUS,P,DENS,INITNUM,INITDEN) allows
%   for the specification of the initial estimate of the filter numerator and
%   denominator coefficients in vectors INITNUM and INITDEN respectively. This may
%   be useful for difficult optimization problems. The pole-zero editor in the
%   Signal Processing Toolbox can be used for generating INITNUM and INITDEN.
%
%   [NUM,DEN,ERR] = IIRLPNORMC(...) returns the least-Pth approximation error ERR.
%
%   [NUM,DEN,ERR,SOS,G] = IIRLPNORMC(...) returns the second-order section
%   representation in the matrix SOS and gain G.  For numerical reasons it
%   may be beneficial to use SOS and G in some cases.
%
%   Hints:
%   This is a weighted least-Pth optimization.
%   Check the radii and location of the resulting poles and zeros.  
%   If the zeros are all on the unit circle and the poles are well inside of 
%   the unit circle, try increasing the order of the numerator or reducing
%   the error weighting in the stopband.  Similarly, if several poles have a
%   large radius and the zeros are well inside of the unit circle, try 
%   increasing the order of the denominator or reducing the error weight in 
%   the passband.
%   If you reduce the pole radius, it may be necessary to increase the order
%   of the denominator.
%   The message 'Poorly conditioned matrix. See the "help" file.' indicates
%   that the optimization cannot be accurately computed because:
%   1) the approximation error is extremely small (try reducing the number of
%      poles or zeros - see above); or
%   2) the specifications have huge variation, e.g., A=[1 1e9 0 0];
%
%   EXAMPLE:
%      % Lowpass filter with a peak of 1.6 within the passband.
%      [b,a] = iirlpnormc(5,12,[0 .15 .4 .5 1],[0 .4 .5 1],...
%      [1 1.6 1 0 0],[1 1 1 10 10]);
%
%   See also IIRLPNORM, FREQZ, IIRGRPDELAY, ZPLANE, FILTER.

%   Author(s): D. Shpak
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/11/21 16:15:15 $ 

%   References:
%     [1] A. Antoniou, Digital Filters:  Analysis, Design, and Applications,
%         2nd ed., McGraw-Hill, 1993.

% Parse the input
s = iirparser(2,numOrd,denOrd,f,edges,des,varargin{:});

% Design the filter
[bs,as,h0,err]=iirlpnormcmex(s.numOrd,s.denOrd,s.edges,s.f,s.des,s.wt,...
    s.maxRadius,s.P,s.density,s.Ho,s.BS,s.AS);

% Compute the transfer function and the sos matrix. h0 is sos gain
[b,a,sos] = computetfandsos(s.numOrd,s.denOrd,bs,as,h0);

