function [z,p,k] = tf2zp(num,den)
%TF2ZP  Transfer function to zero-pole conversion.
%   [Z,P,K] = TF2ZP(NUM,DEN)  finds the zeros, poles, and gains:
%
%                 (s-z1)(s-z2)...(s-zn)
%       H(s) =  K ---------------------
%                 (s-p1)(s-p2)...(s-pn)
%
%   from a SIMO transfer function in polynomial form:
%
%               NUM(s)
%       H(s) = -------- 
%               DEN(s)
%
%   Vector DEN specifies the coefficients of the denominator in 
%   descending powers of s.  Matrix NUM indicates the numerator 
%   coefficients with as many rows as there are outputs.  The zero
%   locations are returned in the columns of matrix Z, with as many 
%   columns as there are rows in NUM.  The pole locations are returned
%   in column vector P, and the gains for each numerator transfer 
%   function in vector K. 
%
%   For discrete-time transfer functions, it is highly recommended to
%   make the length of the numerator and denominator equal to ensure 
%   correct results.  You can do this using the function EQTFLENGTH in
%   the Signal Processing Toolbox.  However, this function only handles
%   single-input single-output systems.
%   
%   See also ZP2TF.

%   Clay M. Thompson 11-6-90 
%   Revised ACWG 1-17-90
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.2 $  $Date: 2004/01/24 09:22:47 $

[num,den] = tfchk(num,den);

% Normalize transfer function
if length(den)
    coef = den(1);
else
    coef = 1;
end
if abs(coef)<eps,
  error('MATLAB:tf2zp:DenomZeroLeadCoef',...
        'Denominator must have non-zero leading coefficient.');
end
den = den./coef;
num = num./coef;

% Remove leading columns of zeros from numerator
if length(num)
    while(all(num(:,1)==0) && length(num) > 1)
        num(:,1) = [];
    end
end
[ny,np] = size(num);

% Poles
p  = roots(den);

% Zeros and Gain
k = zeros(ny,1);
linf = inf;
z = linf(ones(np-1,1),ones(ny,1));
for i=1:ny
  zz = roots(num(i,:));
  if length(zz), z(1:length(zz), i) = zz; end
  ndx = find(num(i,:)~=0);
  if length(ndx), k(i,1) = num(i,ndx(1)); end
end
