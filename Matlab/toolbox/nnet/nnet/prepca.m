function [Ptrans,TransMat] = prepca(P,min_frac)
%PREPCA Principal component analysis.
%  
%  Syntax
%
%    [ptrans,transMat] = prepca(P,min_frac)
%
%  Description
%  
%    PREPCA preprocesses the network input training
%    set by applying a principal component analysis.
%     This analysis transforms the input data so that
%     the elements of the input vectors will be uncorrelated.
%     In addition, the size of the input vectors may be
%     reduced by retaining only those components which
%     contribute more than a specified fraction (min_frac) of the
%     total variation in the data set.
%  
%    PREPCA(p,min_frac) takes these inputs:
%      P        - RxQ matrix of centered input (column) vectors.
%       min_frac - Minimum fraction variance component to keep.
%    and returns:
%       Ptrans   - Transformed data set.
%       TransMat - Transformation matrix.
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
%      [pn,meanp,stdp] = prestd(p);
%      [ptrans,transMat] = prepca(pn,0.02);
%
%    Since the second row of p is almost a multiple of the first
%     row, this example will produce a transformed data set which
%     contains only one row.  
%
%  Algorithm
%
%    This routine uses singular value decomposition to compute
%     the principal components.  The input vectors are multiplied
%     by a matrix whose rows consist of the eigenvectors of the
%     input covariance matrix.  This produces transformed input 
%     vectors whose components are uncorrelated and ordered according  
%     to the magnitude of their variance.  Those components which
%     contribute only a small amount to the total variance in
%     the data set are eliminated.
%     It is assumed that the input data set has already been normalized
%     so that it has a zero mean.  The function PRESTD can be used
%     to normalize the data.
%
%  See also PRESTD, PREMNMX, TRAPCA.
%
%   References
%
%     Jolliffe, Principal Component Analysis, Springer, 1986.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $

[R,Q]=size(P);

if  R > Q, error('Input matrix has more rows than columns.'); end  

% Use the singular value decomposition to compute the principal components
[TransMat,s,v] = svd(P,0);

% Compute the variance of each principal component
var = diag(s).^2/(Q-1);

% Compute total variance and fractional variance
total_variance = sum(var);
frac_var = var./total_variance;

% Find the componets which contribute more than min_frac of the total variance
greater = (frac_var > min_frac);
size_pc = sum(greater);

% Reduce the transformation matrix appropriately
TransMat = TransMat(:,1:size_pc)';

% Transform the data
Ptrans = TransMat*P;

