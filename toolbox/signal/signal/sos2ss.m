function [a,b,c,d] = sos2ss(sos,g)
%SOS2SS Second-order sections to state space model conversion.
%   [A,B,C,D]=SOS2SS(SOS,G) returns the state space matrices
%   A, B, C and D of the discrete-time system given by the gain G
%   and the matrix SOS in second-order sections form.
%
%   SOS is an L by 6 matrix which contains the coefficients of
%   each second-order section in its rows:
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
%   See also SS2SOS, ZP2SOS, SOS2ZP, SOS2TF 

%   Author: R. Losada 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 01:14:01 $
 
error(nargchk(1,2,nargin))
if nargin == 1,
   g = 1;
end
[num,den] = sos2tf(sos,g);

% Remove trailing zeros first
while num(end) == 0 & den(end) == 0,
   num(end) = [];
   den(end) = [];
end

[a,b,c,d]=tf2ss(num,den);

