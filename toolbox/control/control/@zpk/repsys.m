function sys = repsys(sys,s)
%REPSYS  Replicate SISO LTI model
%
%   RSYS = REPSYS(SYS,K) returns the block-diagonal model
%   Diag(SYS,...,SYS) with SYS repeated K times.
% 
%   RSYS = REPSYS(SYS,[M N]) replicates and tiles SYS to 
%   produce the M-by-N block model RSYS.
%
%   See also LTIMODELS.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:12:04 $

sizes = size(sys.k);
if ~isequal(sizes(1:2),[1 1]),
   error('Only available for SISO models.')
end

if length(s)==1,
   % Block diagonal replication
   z = cell([s s sizes(3:end)]);
   p = cell(size(z));
   z(:) = {zeros(0,1)};
   p(:) = {zeros(0,1)};
   for j=1:s,
      z(j,j,:) = sys.z(1,1,:);
      p(j,j,:) = sys.p(1,1,:);
   end
   sys.z = z;
   sys.p = p;
   sys.k = kron(eye(s),sys.k);
   
else
   % Replication and tiling
   sys.z = repmat(sys.z,s);
   sys.p = repmat(sys.p,s);
   sys.k = repmat(sys.k,s);
   
end

sys.lti = repsys(sys.lti,s);
