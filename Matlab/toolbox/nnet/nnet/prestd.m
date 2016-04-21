function [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t)
%PRESTD Preprocesses the data so that the mean is 0 and the standard deviation is 1.
%  
%  Syntax
%
%    [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t)
%     [pn,meanp,stdp] = prestd(p)
%
%  Description
%  
%    PRESTD preprocesses the network training
%    set by normalizing the inputs and targets so that
%     they have means of zero and standard deviations of 1.
%  
%    PRESTD(P,T) takes these inputs,
%      P - RxQ matrix of input (column) vectors.
%       T - SxQ matrix of target vectors.
%    and returns,
%       PN    - RxQ matrix of normalized input vectors
%       MEANP - Rx1 vector containing mean for each P
%       STDP  - Rx1 vector containing standard deviations for each P
%       TN    - SxQ matrix of normalized target vectors
%       MEANT - Sx1 vector containing mean for each T
%       STDT  - Sx1 vector containing standard deviations for each T
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
%
%     If you just want to normalize the input:
%
%       [pn,meanp,stdp] = prestd(p);
%
%  Algorithm
%
%     pn = (p-meanp)/stdp;
%
%  See also PREMNMX, PREPCA, TRASTD.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.9 $

if nargin > 2
  error('Wrong number of arguments.');
end

meanp = mean(p')';
stdp = std(p')';
[R,Q]=size(p);
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

pn = (p-meanp0*oneQ)./(stdp0*oneQ);

if nargin==2
  meant = mean(t')';
  stdt = std(t')';
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
  tn = (t-meant0*oneQ)./(stdt0*oneQ);
end
