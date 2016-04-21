function L = repsys(L,s)
%REPSYS  Replicate SISO LTI model
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
%   $Revision: 1.8.4.2 $  $Date: 2003/01/07 19:32:31 $

if length(s)==1,
   % Block diagonal case: use uniform delay
   L.ioDelay = repmat(L.ioDelay,[s s]);   
   L.InputDelay = repmat(L.InputDelay,[s 1]);
   L.OutputDelay = repmat(L.OutputDelay,[s 1]);
elseif any(s(1:2)>1)
   % Replicate and tile along I/O dimensions
   L.ioDelay = repmat(L.ioDelay,s);
   L.InputDelay = repmat(L.InputDelay,[s(2) 1]);
   L.OutputDelay = repmat(L.OutputDelay,[s(1) 1]);
end

% Discard I/O names and groups
[ny,nu] = size(L.ioDelay(:,:,1));
L.InputName(1:nu,1) = {''};
L.OutputName(1:ny,1) = {''};
L.InputGroup = struct;
L.OutputGroup = struct;