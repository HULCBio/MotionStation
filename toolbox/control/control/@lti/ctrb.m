function co = ctrb(sys)
%CTRB  Compute the controllability matrix.
%
%   CO = CTRB(A,B) returns the controllability matrix [B AB A^2B ...].
%
%   CO = CTRB(SYS) returns the controllability matrix of the 
%   state-space model SYS with realization (A,B,C,D).  This is
%   equivalent to CTRB(sys.a,sys.b).
%
%   For ND arrays of state-space models SYS, CO is an array with N+2
%   dimensions where CO(:,:,j1,...,jN) contains the controllability 
%   matrix of the state-space model SYS(:,:,j1,...,jN).  
%
%   See also CTRBF, SS.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:51:28 $

error(nargchk(1,1,nargin))
if ~isa(sys,'ss'),
   error('SYS must be a state-space model.')
end

% Extract data
try
   [a,b] = ssdata(sys);
catch
   error('Not applicable to arrays of models with variable number of states.')
end

% Initialize CO
nx = size(a,1);
bs = size(b);
co = zeros([nx bs(2)*nx bs(3:end)]);

% Compute controllability matrix for each model
for k=1:prod(bs(3:end)),
   co(:,:,k) = ctrb(a(:,:,k),b(:,:,k));
end
