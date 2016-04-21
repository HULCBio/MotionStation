function [coeffs,poles,k] = residue(u,v,k)
%RESIDUE Partial-fraction expansion (residues).
%   [R,P,K] = RESIDUE(B,A) finds the residues, poles and direct term of
%   a partial fraction expansion of the ratio of two polynomials B(s)/A(s).
%   If there are no multiple roots,
%      B(s)       R(1)       R(2)             R(n)
%      ----  =  -------- + -------- + ... + -------- + K(s)
%      A(s)     s - P(1)   s - P(2)         s - P(n)
%   Vectors B and A specify the coefficients of the numerator and
%   denominator polynomials in descending powers of s.  The residues
%   are returned in the column vector R, the pole locations in column
%   vector P, and the direct terms in row vector K.  The number of
%   poles is n = length(A)-1 = length(R) = length(P). The direct term
%   coefficient vector is empty if length(B) < length(A), otherwise
%   length(K) = length(B)-length(A)+1.
%
%   If P(j) = ... = P(j+m-1) is a pole of multplicity m, then the
%   expansion includes terms of the form
%                R(j)        R(j+1)                R(j+m-1)
%              -------- + ------------   + ... + ------------
%              s - P(j)   (s - P(j))^2           (s - P(j))^m
%
%   [B,A] = RESIDUE(R,P,K), with 3 input arguments and 2 output arguments,
%   converts the partial fraction expansion back to the polynomials with
%   coefficients in B and A.
%
%   Warning: Numerically, the partial fraction expansion of a ratio of
%   polynomials represents an ill-posed problem.  If the denominator
%   polynomial, A(s), is near a polynomial with multiple roots, then
%   small changes in the data, including roundoff errors, can make
%   arbitrarily large changes in the resulting poles and residues.
%   Problem formulations making use of state-space or zero-pole
%   representations are preferable.
%
%   Class support for inputs B,A,R:
%      float: double, single
%
%   See also POLY, ROOTS, DECONV.

%   Reference:  A.V. Oppenheim and R.W. Schafer, Digital
%   Signal Processing, Prentice-Hall, 1975, p. 56-58.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/03/02 21:48:04 $

tol = 0.001;   % Repeated-root tolerance; adjust as needed.

% This section rebuilds the U/V polynomials from residues,
%  poles, and remainder.  Multiple roots are those that
%  differ by less than tol.

if nargin > 2
   [mults,i]=mpoles(v,tol,0);
   p=v(i); r=u(i);
   n = length(p);
   q = [p(:).' ; mults(:).'];   % Poles and multiplicities.   
   v = poly(p); u = zeros(1,n,class(u));
   for indx = 1:n
      ptemp = q(1,:);
      i = indx;
      for j = 1:q(2,indx), ptemp(i) = nan; i = i-1; end
      ptemp = ptemp(find(~isnan(ptemp))); temp = poly(ptemp);
      j = length(temp);
      if j < n, temp = [zeros(1,n-j) temp]; end
      u = u + (r(indx) .* temp);
   end
   if ~isempty(k)
      if any(k ~= 0)
         u = [zeros(1,length(k)) u];
         k = k(:).';
         temp = conv(k,v);
         u = u + temp;
      end
   end
   coeffs = u; poles = v;    % Rename.
   return
end

% This section does the partial-fraction expansion
%  for any order of pole.

u = u(:).'; v = v(:).'; k =[];
f = find(u ~= 0);
if length(f), u = u(f(1):length(u)); end
f = find(v ~= 0);
if length(f), v = v(f(1):length(v)); end
u = u ./ v(1); v = v ./ v(1);   % Normalize.
if length(u) >= length(v), [k,u] = deconv(u,v); end
r = roots(v); 
if isempty(r)
  coeffs = zeros(0,0,superiorfloat(u,v)); 
  poles = zeros(0,0,class(v)); 
  k = ones(superiorfloat(u,v)); 
  return
end
[mults,i]=mpoles(r,tol,1);
p=r(i);

q = zeros(2,length(p),superiorfloat(u,v));   % For poles and multiplicity.
q(1,1) = p(1); q(2,1) = 1; j = 1;
repeated = 0;
for i = 2:length(p)
   av = q(1,j) ./ q(2,j);
   if abs(av - p(i)) <= tol    % Treat as repeated root.
      q(1,j) = q(1,j) + p(i);   % Sum for average value.
      q(2,j) = q(2,j) + 1;
      repeated = 1;
     else
      j = j + 1; q(1,j) = p(i); q(2,j) = 1;
   end
end
q(1,1:j) = q(1,1:j) ./ q(2,1:j);   % Multiple root average.

% Set desired = 1 if you want the output multiple poles
%  to be averaged.

desired = 1;
if repeated & desired
   indx = 0;
   for i = 1:j
      for ii = 1:q(2,i), indx = indx+1; p(indx) = q(1,i); end
   end
end

poles = p(:);  % Rename.

coeffs = zeros(length(p),1,superiorfloat(u,v)); 
if repeated   % Section for repeated root problem.
   v = poly(p);
   next = 0;
   for i = 1:j
      pole = q(1,i); n = q(2,i);
      for indx = 1:n
         next = next + 1;
         coeffs(next) = resi2(u,v,pole,n,indx);
      end
   end
  else   % No repeated roots.
   for i = 1:j
      temp = poly(p([1:i-1, i+1:j]));
      coeffs(i) = polyval(u,p(i)) ./ polyval(temp,p(i));
   end
end
