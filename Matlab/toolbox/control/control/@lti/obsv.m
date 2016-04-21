function ob = obsv(sys)
%OBSV  Compute the observability matrix.
%
%   OB = OBSV(A,C) returns the observability matrix [C; CA; CA^2 ...]
%
%   CO = OBSV(SYS) returns the observability matrix of the 
%   state-space model SYS with realization (A,B,C,D).  This is 
%   equivalent to OBSV(sys.a,sys.c).
%
%   For ND arrays of state-space models SYS, OB is an array with N+2
%   dimensions where OB(:,:,j1,...,jN) contains the observability 
%   matrix of the state-space model SYS(:,:,j1,...,jN).  
%
%   See also OBSVF, SS.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:49:00 $

error(nargchk(1,1,nargin))
if ~isa(sys,'ss'),
   error('SYS must be a state-space model.')
end

% Extract data
try
   [a,b,c] = ssdata(sys);
catch
   error('Not applicable to arrays of models with variable number of states.')
end

% Initialize CO
nx = size(a,1);
cs = size(c);
co = zeros([cs(1)*nx nx cs(3:end)]);

% Compute controllability matrix for each model
for k=1:prod(cs(3:end)),
   ob(:,:,k) = obsv(a(:,:,k),c(:,:,k));
end



