function a = simusm(p,w,m,n)
%SIMUSM Simulates a self-organizing map.
%  
%  This function is obselete.
%  Use NNT2SOM and SIM to update and simulate your network.

nntobsf('simusm','Use NNT2SOM and SIM to update and simulate your network.')

%  SIMUSM(P,W,B,M,N)
%    P - RxQ matrix of input (column) vectors.
%    W - SxR weight matrix.
%    M - Neighborhood matrix.
%    N - Neighborhood size, default = 1.
%  Returns outputs of the self-organizing map.
%  
%  EXAMPLE: w = initsm([-2 2;0 5],6);
%           m = nbman(2,3);
%           p = [1; 2];
%           a = simusm(p,w,m)
%  
%  See also NNSIM, SELFORG, INITSM, TRAINSM.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:12:35 $

if nargin < 3,error('Not enough arguments.'),end
if nargin ==3, n = 1; end

a = compet(-dist(w,p));
a = 0.5*(a + sparse(m <= n)*a);
