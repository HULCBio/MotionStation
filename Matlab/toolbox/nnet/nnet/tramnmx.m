function [pn] = tramnmx(p,minp,maxp)
%TRAMNMX Transform data using a precalculated min and max.
%  
%  Syntax
%
%     [pn] = tramnmx(p,minp,maxp)
%
%  Description
%  
%    TRAMNMX transforms the network input set using 
%    minimum and maximum values that were previously 
%     computed by PREMNMX.  This function needs to be 
%     used when a network has been trained using data normalized 
%     by PREMNMX.  All subsequent inputs to the network need to
%     be transformed using the same normalization.
%  
%    TRAMNMX(P,MINP,MAXP) takes these inputs,
%      P - RxQ matrix of input (column) vectors.
%       MINP- Rx1 vector containing original minimums for each input
%       MAXP- Rx1 vector containing original maximums for each input
%    and returns,
%       PN  - RxQ matrix of normalized input vectors
%    
%  Example
%
%    Here is the code to normalize a given data set so
%     that the inputs and targets will fall in the
%     range [-1,1], using PREMNMX, and the code to train a network
%     with the normalized data.
%  
%      p = [-10 -7.5 -5 -2.5 0 2.5 5 7.5 10];
%       t = [0 7.07 -10 -7.07 0 7.07 10 7.07 0];
%      [pn,minp,maxp,tn,mint,maxt] = premnmx(p,t);
%       net = newff(minmax(pn),[5 1],{'tansig' 'purelin'},'trainlm');
%       net = train(net,pn,tn);
%
%     If we then receive new inputs to apply to the trained
%     network, we will use TRAMNMX to transform them
%     first. Then the transformed inputs can be used
%     to simulate the previously trained network.  The
%     network output must also be unnormalized using
%     POSTMNMX.
%
%       p2 = [4 -7];
%       [p2n] = tramnmx(p2,minp,maxp);
%       an = sim(net,pn);
%       [a] = postmnmx(an,mint,maxt);
%
%  Algorithm
%
%     pn = 2*(p-minp)/(maxp-minp) - 1;
%
%  See also PREMNMX, PRESTD, PREPCA, TRASTD, TRAPCA.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nargin ~= 3
  error('Wrong number of arguments.');
end

equal = minp==maxp;
nequal = ~equal;
if sum(equal) ~= 0
  warning('Some maximums and minimums are equal. Those inputs won''t be transformed.');
  minp = minp.*nequal - 1*equal;
  maxp = maxp.*nequal + 1*equal;
end

[R,Q]=size(p);
oneQ = ones(1,Q);

pn = 2*(p-minp*oneQ)./((maxp-minp)*oneQ) - 1;


