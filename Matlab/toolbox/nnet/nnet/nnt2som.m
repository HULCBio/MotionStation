function net = nnt2som(pr,dims,w,olr,osteps,tlr,tnd)
%NNT2SOM Update NNT 2.0 self-organizing map.
%
%  Syntax
%
%    net = nnt2som(pr,[d1 d2 ...],w,olr,osteps,tlr,tnd)
%
%  Description
%
%    NNT2SOM(PR,[D1,D2,...],W,OLR,OSTEPS,TLR,TDN) takes these arguments,
%      PR     - Rx2 matrix of min and max values for R input elements.
%      Di     - Size of ith layer dimension.
%      W      - SxR weight matrix.
%      OLR    - Ordering phase learning rate, default = 0.9.
%      OSTEPS - Ordering phase steps, default = 1000.
%      TLR    - Tuning phase learning rate, default = 0.02;
%      TND    - Tuning phase neighborhood distance, default = 1.
%    Returns a self-organizing map.
%
%    NNT2SOM assumes that the self-organizing map has a
%    grid topology (GRIDTOP) using link distances (LINKDIST).
%    This corresponds with the neighborhood function in NNT 2.0.
%
%    The new network will only output 1 for the neuron with the greatest
%    net input.  In NNT2 the network would also output 0.5 for that neuron's
%    neighbors.
%
%    Once a network has been updated it can be simulated, initialized,
%    adapted, or trained with SIM, INIT, ADAPT, and TRAIN.
%    
%  See also NEWSOM.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $

% Check
if nargin < 3, error('Not enough input arguments.'), end
if size(pr,1) ~= size(w,2), error('PR and W sizes do not match.'), end
if size(pr,2) ~= 2, error('PR must have two columns.'), end

% Defaults
if nargin < 4, olr = 0.9; end
if nargin < 5, osteps = 1000; end
if nargin < 6, tlr = 0.02; end
if nargin < 7, tnd = 1; end

% Update
net = newsom(pr,fliplr(dims),'gridtop','linkdist');
net.iw{1,1} = w;
