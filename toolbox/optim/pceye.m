function[RPCMTX,ppvec] = pceye(A,pcoptions,DM,DG,varargin);
%PCEYE Precondition based on DM and DG.
%
%
% PRODUCE DIAGONAL PRECONDITIONER (FACTOR) FOR
%
%       M = DM*(A'*A)*DM + DG
%
% WHERE DM AND DG ARE NON-NEGATIVE SPARSE DIAGONAL MATRICES,
% AND `A' IS UNKNOWN (empty input argument)
%
%
% Initialization

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/02/01 22:07:35 $

  if nargin < 2
    error('optim:pceye:NotEnoughInputs','pceye requires at least 2 arguments.')
  end
  n = length(DM);
  ppvec = (1:n)';
  d1 = full(diag(DM)); 
  d2 = full(diag(DG)); 
  dd = sqrt(d1.*d1 + abs(d2));
  RPCMTX = sparse(1:n,1:n,dd);
