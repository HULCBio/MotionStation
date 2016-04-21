function   [z2, p2, k2] = zpkftransf(z, p, k, ftfnum, ftfden)
%ZPKFTRANSF Zero-pole-gain frequency transformation of the digital filter.
%   [Z2,P2,K2] = ZPKFTRANSF(Z,P,K,FTFNum,FTFDen) returns zeros, Z2,
%   poles, P2, and gain factor, K2, of the transformed lowpass digital filter
%   as well as the numerator, ALLPASSNUM, and the denominator, ALLPASSDEN, of
%   the allpass mapping filter. The prototype lowpass filter is given with
%   zeros, Z, poles, P, and gain factor, K. If FTFDEN is not specified it will
%   default to one. If both FTFNUM and FTFDEN are not specified, they both
%   default to one and the function returns the input filter.
%
%   Inputs:
%     Z       - Zeros of the prototype lowpass filter
%     P       - Poles of the prototype lowpass filter
%     K       - Gain factor of the prototype lowpass filter
%     FTFNum  - Numerator of the mapping filter
%     FTFDen  - Denominator of the mapping filter
%   Outputs:
%     Z2      - Zeros of the target filter
%     P2      - Poles of the target filter
%     K2      - Gain factor of the target filter
%
%   Example:
%        [b, a]          = ellip(3,0.1,30,0.409);      % IIR halfband filter
%        [alpnum,alpden] = allpasslp2lp(0.5, 0.25);
%        [z2, p2, k2]    = zpkftransf(roots(b), roots(a), b(1), alpnum, alpden);
%        fvtool(b, a, k2*poly(z2), poly(p2));
%
%   See also IIRFTRANSF.

%   Author(s): Dr. Artur Krukowski, University of Westminster, London, UK.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/20 21:18:45 $

% Check the input arguments
error(nargchk(3,5,nargin));
error(ftransfargchk(z, 'Zeros of the prototype filter', 'vector'));
error(ftransfargchk(p, 'Poles of the prototype filter', 'vector'));
error(ftransfargchk(k, 'Gain of the prototype filter',  'scalar'));

switch nargin,
    case 5,
        error(ftransfargchk(ftfnum, 'Numerator of the mapping filter',  'vector'));
        error(ftransfargchk(ftfden, 'Denominator of the mapping filter','vector'));
        
        % FIR case -> denominator defaults to unity
    case 4;
        ftfden = 1;
        error(ftransfargchk(ftfnum, 'Numerator of the mapping filter',  'vector'));
        
        % Transformation filter defaults to constant equal one
    case 3,
        ftfnum = 1;
        ftfden = 1;
end

% Calculate the mapping filter
if (ftfnum ~=1) | (ftfden ~= 1),
   % Assign output variables

   z2 = [];
   p2 = [];
   k2 = k * prod(ftfnum(1)-z*ftfden(1))/prod(ftfnum(1)-p*ftfden(1));
   for i=1:length(z),
      z2 = [z2, roots(ftfnum - z(i).*ftfden).'];
   end
   for i=1:length(p),
      p2 = [p2, roots(ftfnum - p(i).*ftfden).'];
   end
 
   % Stabilise the target filter in case it is not after the transformation
   [z2, p2, k2] = pzstable(z2, p2, k2);
   
else
   z2 = z;
   p2 = p;
   k2 = k;

end

z2 = z2(:);
p2 = p2(:);