function a = simup(p,w,b)
%SIMUP Simulate perceptron layer.
%  
%  This function is obselete.
%  Use NNT2P and SIM to update and simulate your network.

nntobsf('simup','Use NNT2P and SIM to update and simulate your network.')

%  SIMUP(P,W,B)
%    P - RxQ matrix of input (column) vectors.
%    W - SxR weight matrix.
%    B - Sx1 bias (column) vector.
%  Returns outputs of the perceptron layer.
%  
%  EXAMPLE: [w,b] = initp([0 1;-5 5],3);
%           p = [2; -3];
%           a = simup(p,w,b)
%  
%  See also NNSIM, PERCEPT, HARDLIM, INITP, LEARNP, TRAINP

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:16:00 $

if nargin < 2,error('Not enough arguments.'),end

a = hardlim(w*p,b);
