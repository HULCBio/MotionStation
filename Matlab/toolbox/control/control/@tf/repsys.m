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
%   $Revision: 1.6 $  $Date: 2002/04/10 06:07:06 $

sizes = size(sys.num);
if ~isequal(sizes(1:2),[1 1]),
   error('Only available for SISO models.')
end


if length(s)==1,
   % Block diagonal replication
   num = cell([s s sizes(3:end)]);
   den = cell(size(num));
   num(:) = {0};
   den(:) = {1};
   for j=1:s,
      num(j,j,:) = sys.num(1,1,:);
      den(j,j,:) = sys.den(1,1,:);
   end
   sys.num = num;
   sys.den = den;
   
else
   % Replication and tiling
   sys.num = repmat(sys.num,s);
   sys.den = repmat(sys.den,s);
   
end

sys.lti = repsys(sys.lti,s);
