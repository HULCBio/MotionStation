function net=initlay(net)
%INITLAY Layer-by-layer network initialization function.
%
%  Syntax
%
%    net = initlay(net)
%    info = initlay(code)
%
%  Description
%
%    INITLAY is a network initialization function which
%    initializes each layer i according to its own initialization
%    function NET.layers{i}.initFcn.
%
%    INITLAY(NET) takes:
%      NET - Neural network.
%    and returns the network with each layer updated.
%
%    INITLAY(CODE) return useful information for each CODE string:
%      'pnames'    - Names of initialization parameters.
%      'pdefaults' - Default initialization parameters.
%
%    INITLAY does not have any initialization parameters.
%
%  Network Use
%
%    You can create a standard network that uses INITLAY by calling
%    NEWP, NEWLIN, NEWFF, NEWCF, and many other new network functions.
%
%    To prepare a custom network to be initialized with INITLAY:
%    1) Set NET.initFcn to 'initlay'.
%       (This will set NET.initParam to the empty matrix [] since
%       INITLAY has no initialization parameters.)
%    2) Set each NET.layers{i}.initFcn to a layer initialization function.
%       (Examples of such functions are INITWB and INITNW).
%
%    To initialize the network call INIT.
%
%    See NEWP and NEWLIN for initialization examples.
%
%  Algorithm
%
%    The weights and biases of each layer i are initialized according
%    to NET.layers{i}.initFcn.
%
%  See also INITWB, INITNW, INIT.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

% FUNCTION INFO
% =============

if isstr(net)
  switch (net)
    case 'pnames',
    net = {};
    case 'pdefaults',
    net = [];
    otherwise,
    error('Unrecognized code.')
  end
  return
end

% NETWORK
for i=1:net.numLayers
  initFcn = net.layers{i}.initFcn;
  if length(initFcn)
    net = feval(initFcn,net,i);
  end
end
  
