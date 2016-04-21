function net = nnt2elm(pr,w1,b1,w2,b2,btf,blf,pf)
%NNT2ELM Update NNT 2.0 Elman backpropagation network.
%
%  Syntax
%
%    net = nnt2elm(pr,w1,b1,w2,b2,btf,blf,pf)
%
%  Description
%
%    NNT2ELM(PR,W1,B1,W2,B2,BTF,BLF,PF) takes these arguments,
%      PR - Rx2 matrix of min and max values for R input elements.
%      W1 - S1x(R+S1) weight matrix.
%      B1 - S1x1 bias vector.
%      W2 - S2xS1 weight matrix.
%      B2 - S2x1 bias vector.
%      BTF - Backprop network training function, default = 'traingdx'.
%      BLF - Backprop weight/bias learning function, default = 'learngdm'.
%      PF  - Performance function, default = 'mse'.
%    and returns a feed-forward network.
%
%    The training function BTF can be any of the backprop training
%    functions such as TRAINGD, TRAINGDM, TRAINGDA, and TRAINGDX.
%    Large step-size algorithms such as TRAINLM are not recommended
%    for Elman networks.
%
%    The learning function BLF can be either of the backpropagation
%    learning functions such as LEARNGD, or LEARNGDM.
%
%    The performance function can be any of the differentiable performance
%    functions such as MSE or MSEREG.
%
%    Once a network has been updated it can be simulated,
%    initialized, adapted, or trained with SIM, INIT, ADAPT, and TRAIN.
%
%  See also NEWELM.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

% Check
if size(pr,2) ~= 2, error('PR must have two columns.'), end
if size(pr,1) ~= size(w1,2)-size(w1,1), error('PR and W1 sizes do not match.'), end
if size(w1,1) ~= size(b1,1), error('W1 and B1 sizes do not match.'), end
if size(b1,2) ~= 1, error('B1 must have one column.'), end
if size(w1,1) ~= size(w2,2), error('W1 and W2 sizes do not match.'), end
if size(w2,1) ~= size(b2,1), error('W2 and B2 sizes do not match.'), end
if size(b2,2) ~= 1, error('B2 must have one column.'), end

% Defaults
if nargin < 6, btf = 'traingdx'; end
if nargin < 7, blf = 'learngdm'; end
if nargin < 8, pf = 'mse'; end

% Update
r = size(pr,1);
s1 = length(b1);
s2 = length(b2);
net = newelm(pr,[s1 s2],{'tansig' 'purelin'},btf,blf,pf);
net.iw{1,1} = w1(:,[1:r]);
net.lw{1,1} = w1(:,[1:s1]+r);
net.b{1} = b1;
net.lw{2,1} = w2;
net.b{2} = b2;
