function [b,a,error,sos,h0] = iirlpnorm(numOrd,denOrd,f,edges,des,varargin)
%IIRLPNORM Least P-norm optimal IIR filter design.
%   [NUM,DEN] = IIRLPNORM(N,D,F,EDGES,A) returns a filter having a numerator
%   order N and denominator order D which is the best approximation to the
%   desired  frequency response described by F and A in the least-Pth sense.
%   The vector EDGES specifies the band-edge frequency points, i.e., the point
%   where a frequency band starts/stops and a don't care regions stops/starts.
%   EDGES must always contain the first and last frequency points in F.
%   An unconstrained quasi-Newton algorithm is employed and any poles or
%   zeros that lie outside of the unit circle are reflected back inside.
%   N and D should be chosen so that the zeros and poles are used effectively.
%   See the hints below.  Always check the resulting filter using FREQZ.
%
%   F and A must have the same number of elements, which may exceed the
%   number of elements in EDGES.  This allows for the specification of
%   filters having any gain contour within each band.  The frequencies 
%   specified in EDGES must also appear in the vector F. 
%
%   [NUM,DEN] = IIRLPNORM(N,D,F,EDGES,A,W) uses the weights in W to weight the
%   error.  W has one entry per frequency point (the same length as F and A)
%   which tells IIRLPNORM how much emphasis to put on minimizing the error in
%   the vicinity of each frequency point relative to the other points.
%
%   [NUM,DEN] = IIRLPNORM(N,D,F,EDGES,A,W,P) where P is a two-element vector
%   [Pmin Pmax] allows for the specification of the minimum and maximum values
%   of P used in the least-Pth algorithm. Default is [2 128] which essentially
%   yields the L-infinity, or Chebyshev, norm. Pmin and Pmax should be even.
%   If P is the string 'inspect', no optimization will occur. This can be used
%   to inspect the initial pole/zero placement.
%
%   [NUM,DEN] = IIRLPNORM(N,D,F,EDGES,A,W,P,DENS) specifies the grid density DENS
%   used in the optimization. The number of grid points is DENS*(N+D+1).
%   The default is 20. DENS can be specified as a single-element cell array.
%   The grid is not equally spaced.
%
%   [NUM,DEN] = IIRLPNORM(N,D,F,EDGES,A,W,P,DENS,INITNUM,INITDEN) allows for the 
%   specification of the initial estimate of the filter numerator and denominator
%   coefficients in vectors INITNUM and INITDEN respectively.  This may be useful
%   for difficult optimization problems.  The pole-zero editor in the Signal
%   Processing Toolbox can be used for generating INITNUM and INITDEN.
%
%   [NUM,DEN,ERR] = IIRLPNORM(...) returns the least-Pth approximation error ERR.
%
%   [NUM,DEN,ERR,SOS,G] = IIRLPNORM(...) returns the second-order section
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
%
%   EXAMPLE:
%      % Lowpass filter with a peak of 1.6 within the passband.
%      [b,a] = iirlpnorm(5,12,[0 .15 .4 .5 1],[0 .4 .5 1],...
%      [1 1.6 1 0 0],[1 1 1 10 10]);
%
%   See also IIRLPNORMC, FREQZ, IIRGRPDELAY, ZPLANE, FILTER.

%   Author(s): D. Shpak
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/11/21 16:15:14 $ 

%   References:
%     [1] A. Antoniou, Digital Filters:  Analysis, Design, and Applications,
%         2nd ed., McGraw-Hill, 1993.

myArgin = varargin;
if nargin > 6
   myArgin = {myArgin{1} 0.9 myArgin{2:end}};  % To satisfy iirparser.
end

% Parse the input
s = iirparser(1,numOrd,denOrd,f,edges,des,myArgin{:});

% Design the filter
[bs,as,h0,error]=iirlpnormmex(s.numOrd,s.denOrd,s.edges,s.f,...
    s.des,s.wt,s.P,s.density,s.Ho,s.BS,s.AS);

% Compute the transfer function and the sos matrix. h0 is sos gain
[b,a,sos] = computetfandsos(s.numOrd,s.denOrd,bs,as,h0);
