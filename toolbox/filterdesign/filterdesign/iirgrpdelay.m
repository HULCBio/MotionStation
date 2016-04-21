function [num,den,tau,sos] = iirgrpdelay(order,f,edges,des,varargin)
%IIRGRPDELAY Optimal IIR filter design with prescribed group-delay.
%   [NUM,DEN] = IIRGRPDELAY(N,F,EDGES,Gd) returns an allpass IIR filter of
%   order N (must be even) which is the best approximation to the relative
%   group-delay response described by F and Gd in the least-Pth sense. F is
%   a vector of frequencies between 0 and 1 and Gd is a vector of the desired
%   group-delay specified in samples.
%
%   The vector EDGES specifies the band-edge frequencies for multi-band
%   designs. A constrained Newton-type algorithm is employed.
%   Always check the resulting filter using GRPDELAY or FREQZ.
%
%   F and Gd must have the same number of elements, which can exceed the
%   number of elements in EDGES.  This allows for the specification of
%   filter having any group-delay contour within each band.
%
%   [NUM,DEN] = IIRGRPDELAY(N,F,EDGES,Gd,W) uses the weights in W to weight
%   the error.  W has one entry per frequency point (the same length as F
%   and Gd) which tells IIRGRPDELAY how much emphasis to put on minimizing
%   the error in the vicinity of each frequency point relative to the other
%   points.
%
%   [NUM,DEN] = IIRGRPDELAY(N,F,EDGES,Gd,W,RADIUS) returns a filter having a
%   maximum pole radius of RADIUS where 0<RADIUS<1. RADIUS defaults to 0.999999. 
%   Filters having a reduced pole radius may retain better transfer function
%   accuracy when quantized.
%
%   [NUM,DEN] = IIRGRPDELAY(N,F,EDGES,Gd,W,RADIUS,P) where P is a two-element
%   vector [Pmin Pmax] allows for the specification of the minimum and maximum 
%   values of P used in the least Pth algorithm.  Default is [2 128] which 
%   essentially yields the L-infinity, or Chebyshev, norm.  Pmin and Pmax 
%   should be even. If P is the string 'inspect', no optimization will occur.
%   This can be used to inspect the initial pole/zero placement.
%
%   [NUM,DEN] = IIRGRPDELAY(N,F,EDGES,Gd,W,RADIUS,P,DENS) specifies the grid
%   density DENS used in the optimization.  The number of grid points is 
%   DENS*(N+1).  The default is 20.  DENS can be specified as a single-element
%   cell array.  The grid is not equally spaced.
%
%   [NUM,DEN] = IIRGRPDELAY(N,F,EDGES,Gd,W,RADIUS,P,DENS,INITDEN) allows for the
%   specification of the initial estimate of the denominator coefficients in
%   vector INITDEN.  This may be useful for difficult optimization problems.
%   The pole-zero editor in the Signal Processing Toolbox can be used for
%   generating INITDEN.
%
%   [NUM,DEN] = IIRGRPDELAY(N,F,EDGES,Gd,W,RADIUS,P,DENS,INITDEN,TAU1) allows the
%   initial estimate of the group delay offset to be specified.
%   The default for TAU1 is max(Gd).
%
%   [NUM,DEN,TAU] = IIRGRPDELAY(...) returns the resulting group delay
%   offset.  In all cases, the resulting filter has a group delay that
%   approximates [Gd + TAU].  This is because the allpass filter can only
%   have positive  group delay and a non-zero value of TAU accounts for any
%   additional group delay that is needed to meet the shape of the contour
%   specified by (F,Gd).
%
%   Hints: If the zeros/poles cluster together, the order may be too low or 
%   the pole radius may be too restrictive.
%   The message 'Poorly conditioned matrix. See the "help" file.' indicates
%   that the optimization cannot be accurately computed because:
%   1) the approximation error is extremely small (try reducing filter order); or
%   2) the specifications have huge variation, e.g., Gd=[4e5 0.1*ones(1,9) 400];
%
%   EXAMPLE:
%      % Group-delay equalization of an IIR filter. Compute Gd by subtracting
%      % the filter's group delay from its maximum group delay
%      [z,p,k] = ellip(4,1,40,0.2);
%      [sos,g] = zp2sos(z,p,k);
%      H = dfilt.df2sos(sos,g); % Filter to be equalized
%      F = 0:0.001:0.2;
%      g = grpdelay(H,F,2);   % We will only equalize the passband.
%      Gd = max(g)-g;
%      [num,den,tau]=iirgrpdelay(8, F, [0 0.2], Gd);
%      He = dfilt.df2(num,den); % Allpass equalizer
%      Ho = cascade(H,He); % Overall equalized filter
%      grpdelay(Ho);
%
%   See also GRPDELAY, FREQZ, FILTER, ZPLANE, IIRLPNORM, IIRLPNORMC.

%   Author(s): D. Shpak
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/05/11 17:01:33 $ 

%   References:
%     [1] A. Antoniou, Digital Filters:  Analysis, Design, and Applications,
%         2nd ed., McGraw-Hill, 1993.

if rem(order,2) ~= 0
   error('The filter order must be even.');
end

% Parse input
s = iirparser(3,4,order,f,edges,des,varargin{:});

% Catch case when desired group delay is zero
if all(des == 0),
    error('The desired group delay cannot be zero.');
end
    
% Design filter
[as,tau]=iirgrpdelaymex(s.denOrd,s.edges,s.f,s.des,s.wt,...
    s.maxRadius,s.P,s.density,s.Ho,s.AS); %s.Ho is actually group delay estimate in this case

sections = fix((s.denOrd + 1) / 2);

% Get handle to toSos function
toSoshndl = computetfandsos('gettososhndl');

% Convert numerator and denominator into second-order sections format
a = feval(toSoshndl,as, s.denOrd, sections);
sos = [fliplr(a) a];

[num,den] = sos2tf(sos,1);



