function [Y, e] = cmdscale(D)
%CMDSCALE Classical Multidimensional Scaling.
%   Y = CMDSCALE(D) takes an n-by-n distance matrix D, and returns an n-by-p 
%   configuration matrix Y.  Rows of Y are the coordinates of n points in
%   p-dimensional space for some p < n.  When D is a Euclidean distance matrix,
%   the distances between those points are given by D.  p is the dimension of
%   the smallest space in which the n points whose interpoint distances are
%   given by D can be embedded.
% 
%   [Y,E] = CMDSCALE(D) also returns the eigenvalues of Y*Y'.  When D is 
%   Euclidean, the first p elements of E are positive, the rest zero.  If the 
%   first k elements of E are much larger than the remaining (n-k), then you 
%   can use the first k columns of Y as k-dimensional points, whose interpoint 
%   distances approximate D.  This can provide a useful dimension reduction for 
%   visualization, e.g., for k==2.
% 
%   D need not be a Euclidean distance matrix.  If it is non-Euclidean, or is
%   a more general dissimilarity matrix, then some elements of E are negative,
%   and CMDSCALE chooses p as the number of positive eigenvalues.  In this case,
%   the reduction to p or fewer dimensions provides a reasonable approximation
%   to D only if the negative elements of E are small in magnitude.
% 
%   You can specify D as either a full dissimilarity matrix, or in upper 
%   triangle vector form such as is output by PDIST.  A full dissimilarity
%   matrix must be real and symmetric, and have zeros along the diagonal and
%   positive elements everywhere else.  A dissimilarity matrix in upper
%   triangle form must have real, positive entries.  You can also specify D
%   as a full similarity matrix, with ones along the diagonal and all other
%   elements less than one.  CMDSCALE tranforms a similarity matrix to a
%   dissimilarity matrix in such a way that distances between the points
%   returned in Y equal or approximate sqrt(1-D).  If you want to use a
%   different transformation, you can transform the similarities prior to
%   calling CMDSCALE.
%
%   Example:
%
%      % some points in 4D, but "close" to 3D, reduce them to distances only
%      X = [ normrnd(0,1,10,3) normrnd(0,.1,10,1) ];
%      D = pdist(X, 'euclidean');
%
%      % find a configuration with those inter-point distances
%      [Y e] = cmdscale(D);
%      dim = sum(e > eps^(3/4)) % four, but fourth one small
%      maxerr2 = max(abs(pdist(X) - pdist(Y(:,1:2)))) % poor reconstruction
%      maxerr3 = max(abs(pdist(X) - pdist(Y(:,1:3)))) % good reconstruction
%      maxerr4 = max(abs(pdist(X) - pdist(Y))) % exact reconstruction
%
%      D = pdist(X, 'cityblock'); % D is now non-Euclidean
%      [Y e] = cmdscale(D);
%      min(e) % one is large negative
%      maxerr = max(abs(pdist(X) - pdist(Y))) % poor reconstruction
%
%   See also MDSCALE, PDIST, PROCRUSTES.

%   References:
%     [1] Seber, G.A.F., Multivariate Observations, Wiley, 1984

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.7.2.3 $ $Date: 2004/04/11 00:47:41 $

[n m] = size(D);
del = 10*eps(class(D));

% lower triangle form for D, make sure it's a valid dissimilarity matrix
if n == 1
    n = (1+sqrt(1+8*m))/2;
    if n == fix(n) & all(D >= 0)
        D = squareform(D); % assumes zero diagonal, similarity not allowed
    else
        error('stats:cmdscale:BadDistance',...
              'Not a valid dissimilarity or distance matrix.');
    end
    
% full matrix form, make sure it's valid similarity/dissimilarity matrix
elseif n == m & all(all(D >= 0 & abs(D - D') <= del*max(max(D))))
    
    % it's a dissimilarity matrix
    if all(diag(D) < del)
        % nothing to do
        
    % it's a similarity matrix -- transform to dissimilarity matrix.
    % the sqrt is not entirely arbitrary, see Seber, eqn. 5.73
    elseif all(abs(diag(D) - 1) < del) & all(all(D < 1+del))
        D = sqrt(1 - D);
    else
        error('stats:cmdscale:BadDistance',...
              'Not a valid dissimilarity or similarity matrix.')
    end
else
    error('stats:cmdscale:BadDistance',...
          'Not a valid dissimilarity or distance matrix.')
end

P = eye(n) - repmat(1/n,n,n);
B = P * (-.5 * D .* D) * P;
[V E] = eig((B+B')./2); % guard against spurious complex e-vals from roundoff
[e i] = sort(diag(E)); e = flipud(e); i = flipud(i); % sort descending

% keep only positive e-vals (beyond roundoff)
keep = find(e > max(abs(e)) * eps(class(e))^(3/4));
if isempty(keep)
    Y = zeros(n,1);
else
    Y = V(:,i(keep)) * diag(sqrt(e(keep)));
end
