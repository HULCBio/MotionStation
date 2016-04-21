function w = initzero(s,pr)
%INITZERO Zero weight/bias initialization function.
%  
%  Syntax
%
%    W = initzero(S,PR)
%    b = initzero(S,[1 1])
%
%  Description
%
%    INITZERO(S,PR) takes these arguments,
%      S - Number of rows (neurons).
%      PR - Rx2 matrix of input value ranges = [Pmin Pmax].
%    and returns an SxR weight matrix of zeros.
%
%    INITZERO(S,[1 1])
%    returns an Sx1 bias vector of zeros.
%  
%  Examples
%
%    Here initial weights and biases are calculated for
%    a layer with two inputs ranging over [0 1] and [-2 2],
%    and 4 neurons.
%
%      W = initzero(5,[0 1; -2 2])
%      b = initzero(5,[1 1])
%
%  Network Use
%
%    You can create a standard network that uses INITZERO to initialize
%    its weights by calling NEWP or NEWLIN.
%
%    To prepare the weights and the bias of layer i of a custom network
%    to be initialized with MIDPOINT:
%    1) Set NET.initFcn to 'initlay'.
%       (NET.initParam will automatically become INITLAY's default parameters.)
%    2) Set NET.layers{i}.initFcn to 'initwb'.
%    3) Set each NET.inputWeights{i,j}.initFcn to 'initzero'.
%       Set each NET.layerWeights{i,j}.initFcn to 'initzero';
%       Set each NET.biases{i}.initFcn to 'initzero';
%
%    To initialize the network call INIT.
%
%    See NEWP or NEWLIN for initialization examples.
%
%  See also INITWB, INITLAY, INIT.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin < 2, error('Not enough arguments.'); end

r = size(pr,1);
w = zeros(s,r);
