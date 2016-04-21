function sys = repsys(sys,s)
%REPSYS  Replicate SISO LTI model.
%
%   RSYS = REPSYS(SYS,K) forms the block-diagonal model
%   Diag(SYS,...,SYS) with SYS repeated K times.
% 
%   RSYS = REPSYS(SYS,[M N]) replicates and tiles SYS to 
%   produce the M-by-N block model RSYS.
%
%   See also LTIMODELS.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 06:00:43 $

sizes = size(sys.d);
if ~isequal(sizes(1:2),[1 1]),
   error('Only available for SISO models.')
end


if length(s)==1,
   % Block-diagonal replication. Loop over each model
   D = zeros([s*sizes(1:2) sizes(3:end)]);
   I = eye(s);
   for k=1:prod(sizes(3:end)),
      % Use KRON to replicate A,B,C,D (thanks greg ;-)
      sys.a{k} = kron(I,sys.a{k});
      sys.b{k} = kron(I,sys.b{k});
      sys.c{k} = kron(I,sys.c{k});
      D(:,:,k) = kron(I,sys.d(:,:,k));
      sys.e{k} = kron(I,sys.e{k});
   end
   sys.d = D;
   sys.StateName = repmat(sys.StateName,[s 1]);
   
else
   % Replication and tiling
   for k=1:prod(sizes(3:end)),
      sys.b{k} = repmat(sys.b{k},[1 s(2)]);
      sys.c{k} = repmat(sys.c{k},[s(1) 1]);
   end
   sys.d = repmat(sys.d,s);
   
end

sys.lti = repsys(sys.lti,s);
