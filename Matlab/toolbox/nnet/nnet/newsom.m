function net=newsom(pr,dims,tfcn,dfcn,olr,osteps,tlr,tnd)
%NEWSOM Create a self-organizing map.
%
%  Syntax
%
%    net = newsom
%    net = newsom(PR,[d1,d2,...],tfcn,dfcn,olr,osteps,tlr,tns)
%
%  Description
%
%    Competitive layers are used to solve classification
%    problems.
%
%   NET = NEWSOM creates a new network with a dialog box.
%
%    NET = NEWSOM(PR,[D1,D2,...],TFCN,DFCN,OLR,OSTEPS,TLR,TNS) takes,
%      PR     - Rx2 matrix of min and max values for R input elements.
%      Di     - Size of ith layer dimension, defaults = [5 8].
%      TFCN   - Topology function, default = 'hextop'.
%      DFCN   - Distance function, default = 'linkdist'.
%      OLR    - Ordering phase learning rate, default = 0.9.
%      OSTEPS - Ordering phase steps, default = 1000.
%      TLR    - Tuning phase learning rate, default = 0.02;
%      TND    - Tuning phase neighborhood distance, default = 1.
%    and returns a new self-organizing map.
%
%    The topology function TFCN can be HEXTOP, GRIDTOP, or RANDTOP.
%    The distance function can be LINKDIST, DIST, or MANDIST.
%
%  Examples
%
%    The input vectors defined below are distributed over
%    an 2-dimension input space varying over [0 2] and [0 1].
%    This data will be used to train a SOM with dimensions [3 5].
%
%      P = [rand(1,400)*2; rand(1,400)];
%      net = newsom([0 2; 0 1],[3 5]);
%      plotsom(net.layers{1}.positions)
%
%    Here the SOM is trained for 25 epochs and the input vectors are
%    plotted with the map which the SOM's weights has formed.
%
%      net.trainParam.epochs = 25;
%      net = train(net,P);
%      plot(P(1,:),P(2,:),'.g','markersize',20)
%      hold on
%      plotsom(net.iw{1,1},net.layers{1}.distances)
%      hold off
%
%  Properties
%
%    SOMs consist of a single layer with the NEGDIST weight function,
%    NETSUM net input function, and the COMPET transfer function.
%
%    The layer has a weight from the input, but no bias.
%    The weight is initialized with MIDPOINT.
%
%    Adaption and training are done with TRAINS and TRAINR,
%    which both update the weight with LEARNSOM.
%
%  See also SIM, INIT, ADAPT, TRAIN, TRAINS, TRAINR.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 21:37:41 $

if nargin < 1
  net = newnet('newsom');
  return
end

% Defaults
if nargin < 2, dims = [5 8]; end
if nargin < 3, tfcn = 'hextop'; end
if nargin < 4, dfcn = 'linkdist'; end
if nargin < 5, olr = 0.9; end
if nargin < 6, osteps = 1000; end
if nargin < 7, tlr = 0.02; end
if nargin < 8, tnd = 1; end

% Error Checking
if (~isa(pr,'double')) | ~isreal(pr) | (size(pr,2) ~= 2)
  error('Input ranges is not a two column matrix.')
end
if any(pr(:,1) > pr(:,2))
  error('Input ranges has values in the second column larger in the values in the same row of the first column.')
end
if (~isa(dims,'double')) | (~isreal(dims)) | (size(dims,1) ~= 1) | any(dims <= 0) | any(round(dims) ~= dims)
  error('Dimensions is not a row vector of positive integer values.')
end
if (~isa(olr,'double')) | (~isreal(olr)) | any(size(olr) ~= 1) | (olr < 0) | (olr > 1)
  error('Ordering phase learning rate is not a real value between 0.0 and 1.0.');
end
if (~isa(osteps,'double')) | (~isreal(osteps)) | any(size(osteps) ~= 1) | (osteps < 0) | (round(osteps) == olr)
  error('Ordering phase steps is not a positive integer.');
end
if (~isa(tlr,'double')) | (~isreal(tlr)) | any(size(tlr) ~= 1) | (tlr < 0) | (tlr > 1)
  error('Tuning phase learning rate is not a real value between 0.0 and 1.0.');
end
if (~isa(tnd,'double')) | (~isreal(tnd)) | any(size(tnd) ~= 1) | (tnd < 0)
  error('Tuning phase neighborhood distance is not a positive real value.');
end

% Architecture
net = network(1,1,[0],[1],[0],[1]);

% Simulation
net.inputs{1}.range = pr;
net.layers{1}.dimensions = dims;
net.layers{1}.topologyFcn = tfcn;
net.layers{1}.distanceFcn = dfcn;
net.inputWeights{1,1}.weightFcn = 'negdist';
net.layers{1}.transferFcn = 'compet';

% Learning
net.inputWeights{1,1}.learnFcn = 'learnsom';
net.inputWeights{1,1}.learnParam.order_lr = olr;
net.inputWeights{1,1}.learnParam.order_steps = osteps;
net.inputWeights{1,1}.learnParam.tune_lr = tlr;
net.inputWeights{1,1}.learnParam.tune_nd = tnd;

% Adaption
net.adaptFcn = 'trains';

% Training
net.trainFcn = 'trainr';

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.inputWeights{1,1}.initFcn = 'midpoint';
net = init(net);
