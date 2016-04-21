function PD=calcpd(net,TS,Q,Pc)
%CALCPD Calculate delayed network inputs.
%
%  Syntax
%
%    Pd = calcpd(net,TS,Q,Pc)
%
%  Description
%
%    This function calculates the results of passing the network
%    inputs through each input weights tap delay line.
%
%    Pd = CALCPD(NET,TS,Q,Pc) takes,
%      NET - Neural network.
%      TS  - Time steps.
%      Q   - Concurrent size.
%      Pc  - Combined inputs = [initial delay conditions, network inputs].
%    and returns,
%      Pd  - Delayed inputs.
%
%  Examples
%
%    Here we create a linear network with a single input element
%    ranging from 0 to 1, three neurons, and a tap delay on the
%    input with taps at 0, 2, and 4 timesteps.
%
%      net = newlin([0 1],3,[0 2 4]);
%
%    Here is a single (Q = 1) input sequence P with 8 timesteps (TS = 8).
%
%      P = {0 0.1 0.3 0.6 0.4 0.7 0.2 0.1};
%
%    Here we define the 4 initial input delay conditions Pi.
%
%      Pi = {0.2 0.3 0.4 0.1};
%
%    The delayed inputs (the inputs after passing through the tap
%    delays) can be calculated with CALCPD.
%
%      Pc = [Pi P];
%      Pd = calcpd(net,8,1,Pc)
%
%    Here we view the delayed inputs for input weight going to layer 1,
%    from input 1 at timesteps 1 and 2.
%
%      Pd{1,1,1}
%      Pd{1,1,2}

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 21:17:45 $

totalTS = TS + net.numInputDelays;

PD = cell(net.numLayers,net.numInputs,totalTS);
start = 1;
for ts=1:totalTS
  for i=1:net.numLayers
    for j=find(net.inputConnect(i,:))
    delays = net.inputWeights{i,j}.delays;
    inputsize = net.inputs{j}.size;
    numDelays = length(delays);
    pd = zeros(0,Q);
    for k=1:numDelays
      d = delays(k);
    if (ts-d) > 0
      pd = [pd; Pc{j,ts-d}];
    else
      pd = [pd; zeros(inputsize,Q)];
      start = ts+1;
    end
    PD{i,j,ts} = pd;
    end
  end
  end
end

PD = PD(:,:,start:ts);
