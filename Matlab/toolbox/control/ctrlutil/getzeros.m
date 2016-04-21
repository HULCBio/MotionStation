function [z,gain] = getzeros(a,b,c,d,e,tol,varargin)
%GETZEROS  Compute zeros of state-space model.
% 
%   Z = GETZEROS(A,B,C,D,E,TOL) returns the transmission zeros Z
%   of the state-space model with data (A,B,C,D,E).  TOL is a
%   relative tolerance controlling rank decisions.  Increasing
%   TOL will get rid of zeros near infinity but may incorrectly
%   estimate the relative degree (default = 100*EPS).
%
%   [Z,GAIN] = GETZEROS(A,B,C,D,E,TOL) also returns the transfer 
%   function gain (in the zero-pole-gain sense) for SISO models.
%
%   [Z,G] = GETZEROS(A,B,C,D,E,TOL,'io') returns the cell array Z
%   of zeros and the matrix G of gains for each I/O pair.
%   
%   LOW-LEVEL UTILITY.

%   Author: P.Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2002/11/11 22:23:11 $

ni = nargin;
if ni<6 || isempty(tol) || tol<=0
   tol = 100 * eps;
end
ioFlag = (ni==7);
ioSize = size(d);

% REVISIT
if ~isempty(e),
   % Absorb E in A,B
   a = e\a;  b = e\b;
   e = [];
end

% Balance A,B,C realization (critical, e.g., for ltigallery:badzero2)
% RE: Seeks I/O scaling that maximizes numerical range compression in 
%     B,C while maintaining A nearly balanced 
%     (see tests in tpolzer:lvlOneAccuracy for motivation)
[a,b,c,e] = abcbalance(a,b,c,e,Inf,'noperm','scale');

if ioFlag
   % Zeros of each I/O pair in MIMO model
   z = cell(ioSize);
   gain = zeros(ioSize);
   for j=1:ioSize(2)
      for i=1:ioSize(1)
         [ar,br,cr,er] = smreal(a,b(:,j),c(i,:),e);
         [z{i,j},gain(i,j)] = sisozero([d(i,j) cr ; br ar],er,tol);
      end
   end
   
elseif isequal(ioSize,[1 1])
   % In SISO case, exploit structural info 
   %   c*b=c*A*b=...c*A^(m-2)*b=0 (hard zero) -> relative degree is >=m
   % This ensures sys and ss(sys) have same number of zeros for a ZPK model sys
   [z,gain] = sisozero([d c;b a],[],tol);
   
else
   % MIMO case
   z = mimozero(ioSize,[b a;d c],[],tol);
   gain = [];
end