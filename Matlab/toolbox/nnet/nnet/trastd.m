function [pn] = trastd(p,meanp,stdp)
%TRASTD Preprocesses data using a precalculated mean and standard deviation.
%  
%  Syntax
%
%    [pn] = trastd(p,meanp,stdp)
%
%  Description
%  
%    TRASTD preprocesses the network training set using the mean and 
%    standard deviation that were previously computed by PRESTD.
%     This function needs to be used when a network has been trained 
%     using data normalized by PRESTD.  All subsequent inputs to the  
%     network need to be transformed using the same normalization.
%  
%    TRASTD(P,T) takes these inputs,
%      P - RxQ matrix of input (column) vectors.
%       MEANP - Rx1 vector containing the original means for each input
%       STDP  - Rx1 vector containing the original standard deviations for each input
%    and returns,
%       PN    - RxQ matrix of normalized input vectors
%    
%  Examples
%
%    Here is the code to normalize a given data set so
%     that the inputs and targets will have means
%     of zero and standard deviations of 1.
%  
%      p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
%       t = [-0.08 3.4 -0.82 0.69 3.1];
%      [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
%       net = newff(minmax(pn),[5 1],{'tansig' 'purelin'},'trainlm');
%       net = train(net,pn,tn);
%
%     If we then receive new inputs to apply to the trained network, we will 
%     use TRASTD to transform them first. Then the transformed inputs can be
%     used to simulate the previously trained network.  The network output 
%     must also be unnormalized using POSTSTD.
%
%       p2 = [1.5 -0.8;0.05 -0.3];
%       [p2n] = trastd(p2,meanp,stdp);
%       an = sim(net,pn);
%       [a] = poststd(an,meant,stdt)
%
%  Algorithm
%
%     pn = (p-meanp)/stdp;
%
%  See also PREMNMX, PREPCA, PRESTD, TRAPCA, TRAMNMX.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

if nargin ~= 3
  error('Wrong number of arguments.');
end

[R,Q]=size(p);
oneQ = ones(1,Q);

equal = stdp==0;
nequal = ~equal;
if sum(equal) ~= 0
  warning('Some standard deviations are zero. Those inputs won''t be transformed.');
  meanp = meanp.*nequal + 0*equal;
  stdp = stdp.*nequal + 1*equal;
end

pn = (p-meanp*oneQ)./(stdp*oneQ);

