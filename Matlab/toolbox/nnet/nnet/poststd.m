function [p,t] = poststd(pn,meanp,stdp,tn,meant,stdt)
%POSTSTD Postprocesses data which has been preprocessed by PRESTD.
%  
%  Syntax
%
%    [p,t] = poststd(pn,meanp,stdp,tn,meant,stdt)
%     [p] = poststd(pn,meanp,stdp)
%
%  Description
%  
%    POSTSTD postprocesses the network training
%    set which was preprocessed by PRESTD.  It converts
%     the data back into unnormalized units.
%  
%    POSTSTD takes these inputs,
%       PN    - RxQ matrix of normalized input vectors
%       MEANP - Rx1 vector containing standard deviations for each P
%       STDP  - Rx1 vector containing standard deviations for each P
%       TN    - SxQ matrix of normalized target vectors
%       MEANT - Sx1 vector containing standard deviations for each T
%       STDT  - Sx1 vector containing standard deviations for each T
%    and returns,
%      P - RxQ matrix of input (column) vectors.
%       T - SxQ matrix of target vectors.
%    
%  Examples
%
%    In this example we normalize a set of training data with
%     PRESTD, create and train a network using the normalized
%     data, simulate the network, unnormalize the output of the
%     network using POSTSTD, and perform a linear regression between 
%     the network outputs (unnormalized) and the targets to check the
%     quality of the network training.
%  
%      p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
%       t = [-0.08 3.4 -0.82 0.69 3.1];
%      [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
%       net = newff(minmax(pn),[5 1],{'tansig' 'purelin'},'trainlm');
%       net = train(net,pn,tn);
%       an = sim(net,pn);
%       a = poststd(an,meant,stdt);
%       [m,b,r] = postreg(a,t);
%
%  Algorithm
%
%     p = stdp*pn + meanp;
%
%  See also PREMNMX, PREPCA, POSTMNMX, PRESTD.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

[R,Q]=size(pn);
oneQ = ones(1,Q);

equal = stdp==0;
nequal = ~equal;
if sum(equal) ~= 0
  warning('Some standard deviations are zero. Those inputs won''t be transformed.');
  meanp0 = meanp.*nequal + 0*equal;
  stdp0 = stdp.*nequal + 1*equal;
else
  meanp0 = meanp;
  stdp0 = stdp;  
end

p = (stdp0*oneQ).*pn + meanp0*oneQ;

if nargin==6
  equal = stdt==0;
  nequal = ~equal;
  if sum(equal) ~= 0
    warning('Some standard deviations are zero. Those targets won''t be transformed.');
    meant0 = meant.*nequal + 0*equal;
    stdt0 = stdt.*nequal + 1*equal;
  else
    meant0 = meant;
    stdt0 = stdt;  
  end
  t = (stdt0*oneQ).*tn + meant0*oneQ;
end
