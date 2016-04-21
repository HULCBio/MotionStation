function [gX,normgX] = calcgxmodref(net,X,PD,BZ,IWZ,LWZ,N,Ac,El,perf,Q,TS);
%CALCGXMODREF Calculate weight and bias performance gradient as a single vector for a
%              fixed Neural Network based Model Reference Controller.
%
%  Syntax
%
%    [gX,normgX] = CALCGXMODREF(net,X,Pd,BZ,IWZ,LWZ,N,Ac,El,perf,Q,TS);
%
%  Description
%
%    This function calculates the gradient of a network's performance
%    with respect to its vector of weight and bias values X.
%
%    If the network has no layer delays with taps greater than 0
%    the result is the true gradient.
%
%    If the network as layer delays greater than 0, the result is
%    the Elman gradient, an approximation of the true gradient.
%
%    [gX,normgX] = CALCGXMODREF(NET,X,Pd,BZ,IWZ,LWZ,N,Ac,E,perf,Q,TS) takes,
%      NET    - Neural network.
%      X      - Vector of weight and bias values.
%      Pd     - Delayed inputs.
%      BZ     - Concurrent biases.
%      IWZ    - Weighted inputs.
%      LWZ    - Weighted layer outputs.
%      N      - Net inputs.
%      Ac     - Combined layer outputs.
%      El     - Layer errors.
%      perf   - Network performance.
%      Q      - Concurrent size.
%      TS     - Time steps.
%    and returns,
%      gX     - Gradient dPerf/dX.
%      normgX - Norm of gradient.
%
%  Examples
%
%    Here we create a linear network with a single input element
%    ranging from 0 to 1, two neurons, and a tap delay on the
%    input with taps at 0, 2, and 4 timesteps.  The network is
%    also given a recurrent connection from layer 1 to itself with
%    tap delays of [1 2].
%
%      net = newlin([0 1],2);
%      net.layerConnect(1,1) = 1;
%      net.layerWeights{1,1}.delays = [1 2];
%
%    Here is a single (Q = 1) input sequence P with 5 timesteps (TS = 5),
%    and the 4 initial input delay conditions Pi, combined inputs Pc,
%    and delayed inputs Pd.
%
%      P = {0 0.1 0.3 0.6 0.4};
%      Pi = {0.2 0.3 0.4 0.1};
%      Pc = [Pi P];
%      Pd = calcpd(net,5,1,Pc);
%
%    Here the two initial layer delay conditions for each of the
%    two neurons, and the layer targets for the two neurons over
%    five timesteps are defined.
%
%      Ai = {[0.5; 0.1] [0.6; 0.5]};
%      Tl = {[0.1;0.2] [0.3;0.1], [0.5;0.6] [0.8;0.9], [0.5;0.1]};
%
%    Here the network's weight and bias values are extracted, and
%    the network's performance and other signals are calculated.
%
%      X = getx(net);
%      [perf,El,Ac,N,BZ,IWZ,LWZ] = calcperf(net,X,Pd,Tl,Ai,1,5);
%
%    Finally we can use CALCGXMODREF to calculate the gradient of performance
%    with respect to the weight and bias values X.
%
%      [gX,normgX] = calcgxmodref(net,X,Pd,BZ,IWZ,LWZ,N,Ac,El,perf,1,5);
%
%  See also CALCJX, CALCJEJJ.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Orlando De Jesus, Martin Hagan, Model Reference Controller Neural Network, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:10:43 $

dPerformFcn = feval(net.performFcn,'deriv');
gE = feval(dPerformFcn,'e',El,X,perf,net.performParam);
[gX] = calcgradxmodref(net,Q,PD,BZ,IWZ,LWZ,N,Ac,gE,TS);
normgX = sqrt(sum(sum(gX.^2)));
