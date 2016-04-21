function [Ptrans] = trapca(P,TransMat)
%TRAPCA Principal component transformation.
%  
%  Syntax
%
%    [Ptrans] = trapca(P,TransMat)
%
%  Description
%  
%    TRAPCA preprocesses the network input training set by applying 
%    a principal component transformation that was previously computed 
%     by PREPCA.  This function needs to be used when a network has been 
%     trained using data normalized by PREPCA.  All subsequent inputs to 
%     the network need to be transformed using the same normalization.
%  
%    TRAPCA(P,TransMat) takes these inputs,
%      P        - RxQ matrix of centered input (column) vectors.
%       TransMat - Transformation matrix.
%    and returns,
%       Ptrans   - Transformed data set.
%    
%  Examples
%
%    Here is the code to perform a principal component analysis and
%     retain only those components which contribute more than
%     2 percent to the variance in the data set.  PRESTD is
%     called first to create zero mean data, which are needed
%     for PREPCA.
%  
%      p=[-1.5 -0.58 0.21 -0.96 -0.79; -2.2 -0.87 0.31 -1.4  -1.2];
%       t = [-0.08 3.4 -0.82 0.69 3.1];
%      [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
%      [ptrans,transMat] = prepca(pn,0.02);
%       net = newff(minmax(ptrans),[5 1],{'tansig' 'purelin'},'trainlm');
%       net = train(net,ptrans,tn);
%
%     If we then receive new inputs to apply to the trained
%     network, we will use TRASTD and TRAPCA to transform them
%     first. Then the transformed inputs can be used
%     to simulate the previously trained network.  The
%     network output must also be unnormalized using
%     POSTSTD.
%
%       p2 = [1.5 -0.8;0.05 -0.3];
%       [p2n] = trastd(p2,meanp,stdp);
%       [p2trans] = trapca(p2n,transMat)
%       an = sim(net,p2trans);
%       [a] = poststd(an,meant,stdt);
%
%  Algorithm
%
%    Ptrans = TransMat*P;
%
%  See also PRESTD, PREMNMX, PREPCA, TRASTD, TRAMNMX.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

if nargin ~= 2
  error('Wrong number of arguments.');
end


% Transform the data
Ptrans = TransMat*P;

