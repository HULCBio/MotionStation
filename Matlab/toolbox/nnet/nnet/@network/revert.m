function net = revert(net)
%REVERT Revert network weight and bias values.
%
%  Syntax
%
%    net = revert(net)
%
%  Description
%
%    REVERT(NET) returns neural network NET with weight and bias values
%    restored to the values generated the last time the network was
%    initialized.
%
%    If the network has been altered so that it has different weight
%   and bias connections or different input or layer sizes, then REVERT
%   cannot set the weights and biases to their previous values and they
%   will be set to zeros instead.
%
%  Examples
%
%    Here a perceptron is created with a 2-element input (with ranges
%    of 0 to 1, and -2 to 2) and 1 neuron.  Once it is created we can display
%    the neuron's weights and bias.
%
%      net = newp([0 1;-2 2],1);
%
%    The initial network has weights and biases with zero values.
%
%      net.iw{1,1}, net.b{1}
%
%    We can change these values as follows.
%
%      net.iw{1,1} = [1 2]; net.b{1} = 5;
%      net.iw{1,1}, net.b{1}
%
%    We can recover the network's initial values as follows.
%
%     net = revert(net);
%      net.iw{1,1}, net.b{1}
%
%  See also INIT, SIM, ADAPT, TRAIN.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 21:29:17 $

% Convert network to structure
net = struct(net);

% Are stored revert values ok?
ok = 1;
if ~all(size(net.revert.IW) == size(net.IW))
  ok = 0;
elseif ~all(size(net.revert.LW) == size(net.LW))
  ok = 0;
elseif ~all(size(net.revert.b) == size(net.b))
  ok = 0;
else
  for i=1:size(net.IW,1)
    for j=1:size(net.IW,2)
      if ~all(size(net.revert.IW{i,j}) == size(net.IW{i,j}))
        ok = 0;
      end
    end
  end
  for i=1:size(net.LW,1)
    for j=1:size(net.LW,2)
      if ~all(size(net.revert.LW{i,j}) == size(net.LW{i,j}))
        ok = 0;
      end
    end
  end
  for i=1:size(net.b,1)
    if ~all(size(net.revert.b{i}) == size(net.b{i}))
      ok = 0;
    end
  end
end

% If OK, revert values
if ok
  net.IW = net.revert.IW;
  net.LW = net.revert.LW;
  net.b = net.revert.b;
  
% Otherwise, set to zeros
else
  for i=1:size(net.IW,1)
    for j=1:size(net.IW,2)
      net.IW{i,j} = zeros(size(net.IW{i,j}));
    end
  end
  for i=1:size(net.LW,1)
    for j=1:size(net.LW,2)
      net.LW{i,j} = zeros(size(net.LW{i,j}));
    end
  end
  for i=1:size(net.b,1)
    net.b{i} = zeros(size(net.b{i}));
  end
end

% Convert network back to object
net = class(net,'network');
