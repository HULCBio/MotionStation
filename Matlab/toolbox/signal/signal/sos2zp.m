function [z,p,k] = sos2zp(sos,g)
%SOS2ZP Second-order sections to zero-pole-gain model conversion.
%   [Z,P,K] = SOS2ZP(SOS,G) returns the zeros Z, poles P and gain K
%   of the system given by the gain G and the matrix SOS in
%   second-order sections form. 
%
%   SOS is an L by 6 matrix which contains the coefficients of each
%   second-order section in its rows:
%       SOS = [ b01 b11 b21  1 a11 a21 
%               b02 b12 b22  1 a12 a22
%               ...
%               b0L b1L b2L  1 a1L a2L ]
%   The system transfer function is the product of the second-order 
%   transfer functions of the sections times the gain G. If G is not 
%   specified, it defaults to 1. Each row of the SOS matrix describes
%   a 2nd order transfer function as
%       b0k +  b1k z^-1 +  b2k  z^-2
%       ----------------------------
%       1 +  a1k z^-1 +  a2k  z^-2
%   where k is the row index.
%
%   See also ZP2SOS, SOS2TF, SOS2SS, SS2SOS

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:14:07 $
 
error(nargchk(1,2,nargin))
if nargin == 1,
   g = 1;
end

z = [];
p = [];
k = g;
L = size(sos,1);

for n = 1:L
   if sos(n,6) == 0 & sos(n,3) == 0,
      b = sos(n,1:2); % Remove trailing zeros
      a = sos(n,4:5);
   else
      b = sos(n,1:3);
      a = sos(n,4:6);
   end
   if b(end) == 0 & a(end) == 0,
      b = b(1); % Remove more traling zeros if any
      a = a(1);
   end
   [zt,pt,kt] = tf2zp(b,a); % Find poles and zeros for each row of sos
   z = [z;zt]; % Append zeros
   p = [p;pt]; % Append poles
   k = k*kt;   % Form overall gain
end

