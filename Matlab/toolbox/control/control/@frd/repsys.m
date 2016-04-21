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

%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2002/11/11 22:21:30 $

sizes = size(sys.ResponseData);

if length(s)==1
   % Block diagonal replication
   if ~isequal(sizes(1:2),[1 1]),
      error('Only available for SISO models.')
   end
   originalResp = sys.ResponseData;
   resp = zeros([s,s,sizes(3:end)]);
   for j=1:s
      resp(j,j,:) = originalResp;
   end
   sys.ResponseData = resp;
   
else
   % Replication and tiling
   srd = [s(1:2),1,s(3:end)];
   m = min(length(srd),length(sizes));
   if any(srd(1:m)~=1 & sizes(1:m)~=1)
      error('Can only replicate singleton dimensions.')
   end
   sys.ResponseData = repmat(sys.ResponseData,srd);
end

sys.lti = repsys(sys.lti,s);
