function [a,b,c,d] = compreal(num,den)
%COMPREAL  Companion realization of SIMO transfer functions
%
%   [A,B,C,D] = COMPREAL(NUM,DEN)  produces a state-space realization
%   (A,B,C,D) of the SIMO transfer function NUM/DEN with common 
%   denominator DEN (a row vector).  The numerator NUM should be a
%   PxL matrix where P is the number of outputs and L=LENGTH(DEN).
%
%   See also  TF/SS, COMPBAL.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2002/11/11 22:23:09 $

% RE: This is a low-level function. No error checking!

p = size(num,1);
r = length(den);

if r==1,
   % Simple gain
   a = [];
   b = zeros(0,1);
   c = zeros(p,0);
   d = num;
else
   % Assemble the companion realization (in controller form)
   den = den(2:r);
   c = num;
   d = c(:,1);

   if ~any(c(:)), 
      % Case NUM = 0
      a = [];
      b = zeros(0,1);
      c = zeros(p,0);
   else
      a = [-den ; eye(r-2,r-1)];
      b = eye(r-1,1);
      c = c(:,2:r) - d * den;
      % Balancing
      [a,b,c] = LocalBalance(a,b,c);
   end
end

%----------------------- Local Functions --------------------

function [a,b,c] = LocalBalance(a,b,c)
% Balances companion form exploiting the special structure

% Balance A matrix
na = size(a,1);
if na<2
   ra = zeros(0,1);
else
   [junk,ma] = balance(a,'noperm');
   ra = 1./diag(ma,-1);  % incremental scaling factors 
end

% Balance C
% RE: VC = [c(m) ... c(n)]/c(m) where c(m) is the first nonzero entry
vc = max(abs(c),[],1);
nz = find(vc>0);
if isempty(nz) || nz(1)==na
   rb = zeros(0,1);
else
   vc = vc(nz(1):na)/vc(nz(1));
   nc = length(vc);
   [junk,mc] = balance([vc; eye(nc-1) zeros(nc-1,1)],'noperm');
   rb = 1./diag(mc,-1);  % incremental scaling factors for normalized C
end

% Average out the incremental scalings
idx = na-length(rb):na-1;
ra(idx,:) = sqrt(ra(idx,:) .* rb);

% Form the scaling
s = cumprod([1;ra]);
s = pow2(round(log2(s)));

% Balance (b unchanged)
a = lrscale(a,1./s,s);
c = lrscale(c,[],s);

% Equalize the norms of b and c
cnorm = norm(c,1);
if cnorm>0
   sbc = pow2(round(log2(cnorm)/2));  % sqrt(cnorm)
   c = c / sbc;
   b = b * sbc;
end