function b=initcon(s,pr)
%INITCON Conscience bias initialization function.
%  
%  Syntax
%
%    b = initcon(s,pr);
%
%   Description
%
%    INITCON is a bias initialization function that initializes
%    biases for learning with the LEARNCON learning function.
%
%    INITCON(S,PR) takes two arguments
%      S  - Number of rows (neurons).
%      PR - Rx2 matrix of R = [Pmin Pmax], default = [1 1].
%    and returns an Sx1 bias vector.
%
%    Note that for biases, R is always 1.  INITCON could
%    also be used to initialize weights, but it is not
%    recommended for that purpose.
%
%  Examples
%
%    Here initial bias values are calculated a 5 neuron layer.
%
%      b = initcon(5)
%
%  Network Use
%
%    You can create a standard network that uses INITCON to initialize
%    weights by calling NEWC.
%
%    To prepare the bias of layer i of a custom network
%    to initialize with INITCON:
%    1) Set NET.initFcn to 'initlay'.
%       (NET.initParam will automatically become INITLAY's default parameters.)
%    2) Set NET.layers{i}.initFcn to 'initwb'.
%    3) Set NET.biases{i}.initFcn to 'initcon'.
%
%    To initialize the network call INIT.
%
%    See NEWC for initialization examples.
%
%  Algorithm
%
%    LEARNCON updates biases so that each bias value b(i) is
%    a function of the average output c(i) of the neuron i associated
%    with the bias.
%
%    INITCON gets initial bias values by assuming that each
%    neuron has responded to equal numbers of vectors in the "past".
%
%  See also INITWB, INITLAY, INIT, LEARNCON.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

if nargin < 1, error('Not enough arguments.'); end
if nargin < 2, pr = [1 1]; end

% Bias values
c = ones(s,1)/s;
b = exp(1 - log(c));
