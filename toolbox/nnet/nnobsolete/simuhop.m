function [a,aa] = simuhop(a,w,b,ts)
%SIMUHOP Simulate Hopfield network.
%  
%  This function is obselete.
%  Use NNT2HOP and SIM to update and simulate your network.

nntobsf('simuhop','Use NNT2HOP and SIM to update and simulate your network.')

%  SIMUHOP(A,W,B,TS)
%    A  - SxQ matrix of initial output vectors.
%    W  - SxS weight matrix.
%    B  - Sx1 bias vector.
%    TS - Timesteps to simulate, default = 1.
%  Returns a new output vector after TSth timestep.
%  
%  [A,AA] = SIMUHOP(A,W,B,TS)
%  Returns:
%    A  - Output vector after TSth timesteps.
%    AA - Output vectors from 0 to TSth timesteps.
%  
%  NOTE: If batching, AA only records the network response to the
%    first vector in A. 
%  
%  See also NNSIM, HOPFIELD, SOLVEHOP.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:51 $

if nargin < 3,error('Not enough input arguments.');end
if nargin == 3, ts = 1; end

if nargout <= 1
  for t=1:ts
    a = satlins(w*a,b);
  end
  
elseif nargout == 2
  [s,q] = size(a);
  aa = zeros(s,ts+1);
  aa(:,1) = a(:,1);
  for t=1:ts
    a = satlins(w*a,b);
  aa(:,t+1) = a(:,1);
  end
end

