function a = simuc(p,w,b)
%SIMUC Simulate competitive layer.
%  
%  This function is obselete.
%  Use NNT2C and SIM to update and simulate your network.

nntobsf('simuc','Use NNT2C and SIM to update and simulate your network.')

%  SIMUC(P,W)
%    P - RxQ matrix of input (column) vectors.
%    W - SxR weight matrix.
%  Returns outputs of the competitive layer.
%  
%  SIMUC(P,W,B)
%    B - Sx1 bias vector.
%  Returns outputs of the competitive layer using biases.
%  
%  EXAMPLE: w = initc([0 1;-5 5],3);
%           p = [2; -3];
%           a = simuc(p,w)
%  
%  See also NNSIM, COMPNET, INITC, TRAINC.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:42 $

if nargin < 2,error('Not enough arguments.'),end

if nargin == 2
  a = compet(-dist(w,p));
else
  a = compet(-dist(w,p),b);
end
