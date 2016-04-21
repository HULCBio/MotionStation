function [mult,xqo] = mixedalg(Tt,xqi,K);
%MIXEDALG Existence test of positive real diagonal multiplier.
%
% [MULT,XQO] = MIXEDALG(T,XQI,K) finds the existence of a complex,diagonal
% multiplier, M, with positive real parts such that
%
%           Re ( Tt.M ) > 0                   .....   ($)
%
%  inputs : Tt   -- a square complex matrix.
%           xqi  -- initial guess for any vector of unit norm.
%            K   -- a column vector defining the type of uncertainties
%                   in the diagonal  uncertainty block
%                -- 1 : denotes real parametric uncertainties normalised
%                       in sector[-1,1]
%                   2 : denotes complex parametric uncertainties normalise
%                       in unit disk
% outputs : mult -- the multiplier vector obtained such that ($) holds.
%                   If ($) do not holds, mult is the zero vector.
%           xqo  -- the final vector x of unit norm such that ($) holds
%

% Authors: Penghin Lee and M. G. Safonov 7/92
%
% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

n = max(size(Tt)); qc = 1; zc = 1e-12; nzc = 1e-12; zcriteria = 5;j = sqrt(-1);
qc_check = 150;

% Scaling
abs_max_Tt_ele = abs ( max(max(Tt)) );
abs_min_Tt_ele = abs ( min(min(Tt)) );
 if abs_max_Tt_ele < 1e-01 | abs_min_Tt_ele < 1e-01;
  scaling_factor = 1e+04;
  else scaling_factor = 1;
 end;

Tt = scaling_factor * Tt;

% Finding the Q(i) matrix for the given Tt matrix
for i = 1:n;
    for m = 1:n;
        if m == i;
         ti(m,:) = Tt(i,:);
        else
            for l = 1:n;
             ti(m,l) = 0;
            end;
        end;
    end;
 q(1:n,((((i-1)*n)+1):(i*n))) = j * (ti - ti');
end;

for i = (n+1):2*n;
    for m = 1:n;
        if m == i - n;
         ti(m,:) = Tt(m,:);
        else
            for l = 1:n;
             ti(m,l) = 0;
            end;
        end;
    end;
 q(1:n,((((i-1)*n)+1):(i*n))) = ti + ti';
end;

for i = 1:2*n;
 zqir(i) = xqi' * q(1:n,((((i-1)*n)+1):(i*n))) * xqi;
end;
zq = real(zqir');

% To ensure initial guess is in the convex hull of the set.
for i = n+1:2*n;
  if zq(i,1) < 0;
   zq(i,1) = 0;
  end;
end;

% To take care of mixed real and/or complex parametric uncertainty
complx_type = find( K == 2 );
complx_type_size = max( size(complx_type) );

if complx_type_size > 0;
  for i = 1 : complx_type_size;
   zq_zero = complx_type(i,1);
   zq(zq_zero,1) = 0;
  end;
end;

% Begin iterations
while zcriteria > zc

% Finding the Q(z) matrix for a z and the Q(i)
qzm = zeros(n);
  for i = 1:2*n;
   qzi = zq(i,1) * q(1:n,((((i-1)*n)+1):(i*n)));
   qzm = qzi + qzm;
  end;

% To find the smallest eigenvalue and the associated eigenvector
[v,lambda] = eig(qzm,'nobalance');
 for i = 1:n;
  lambx(i,1) = real((lambda(i,i)));
 end;
lambmin = min(lambx);

 for i = 1:n;
     if lambmin == lambx(i,1);
      mi=i;
     end;
 end;

  for i = 1:n;
   xq(i,1) = v(i,mi);
  end;
lam(qc,1) = lambmin;

% For computing f(xq) from the computed xq
 for i = 1:2*n;
  fxqi(i) = xq' * q(1:n,((((i-1)*n)+1):(i*n))) * xq;
 end;
fxq = real(fxqi');% The new point is fxq.

%     To compute the optimum value of alpha in
%     min  ||zq1 = alpha*zq  + (1-alpha)fxq ||;
%     for all alpha between 0 and 1

if (zq-fxq) == 0;
 alphaopt = 1;
  else alphaopt = -((zq-fxq)'*fxq) / ((zq-fxq)'*(zq-fxq));
  if alphaopt < 0;
   alphaopt = 0;
  elseif alphaopt > 1;
   alphaopt = 1;
  end;
end;

% The new point zq1
zq1 = alphaopt * zq + (1-alphaopt) * fxq;

% To handle restrictions on  zq
for i = n+1:2*n;
   if zq1(i,1) < 0;
    zq1(i,1) = 0;
   end;
end;

% To take care of mixed real and/or complex parametric uncertainty
if complx_type_size > 0;
  for i = 1 : complx_type_size;
   zq_zero = complx_type(i,1);
   zq1(zq_zero,1) = 0;
  end;
end;

% For convergence of zq

if qc > 3; % In case the initial guess has a very small norm

if norm(zq) < zc
   zcriteria = -1;
else
   zcriteria = norm(zq1-zq) / norm(zq);
end

 if zcriteria > zc & (norm(zq1)/scaling_factor) < nzc;
  zq1 = zeros(2*n,1);
  zcriteria = zc - 1;
 end;

end;

if qc > 10;

  if lam(qc,1) > 0 & lam(qc-1,1) > 0;
   zcriteria = zc - 1;
  end;

if qc == 248 & lam(qc,1) <= 0 & lam(qc,1) >= -30;
    qc_check = 300;
end;

        if (lam(qc,1)<=0 & qc > qc_check);
         zq1 = zeros(2*n,1);
         zcriteria = zc - 1 ;
        end;

end; %if qc>10

qc = qc + 1;
zq = real(zq1);nzqq(qc,1) = norm(zq);

end; %while z

xqo = xq;
mult = zq / scaling_factor;
%
% ----------------- End of MIXEDALG.M %PHL/MGS