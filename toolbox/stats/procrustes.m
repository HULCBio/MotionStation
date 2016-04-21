function [d, Z, transform] = procrustes(X, Y)
%PROCRUSTES Procrustes Analysis
%   D = PROCRUSTES(X, Y) determines a linear transformation (translation,
%   reflection, orthogonal rotation, and scaling) of the points in the
%   matrix Y to best conform them to the points in the matrix X.  The
%   "goodness-of-fit" criterion is the sum of squared errors.  PROCRUSTES
%   returns the minimized value of this dissimilarity measure in D.  D is
%   standardized by a measure of the scale of X, given by
%
%      sum(sum((X - repmat(mean(X,1), size(X,1), 1)).^2, 1))
%
%   i.e., the sum of squared elements of a centered version of X.  However,
%   if X comprises repetitions of the same point, the sum of squared errors
%   is not standardized.
%
%   X and Y are assumed to have the same number of points (rows), and
%   PROCRUSTES matches the i'th point in Y to the i'th point in X.  Points
%   in Y can have smaller dimension (number of columns) than those in X.
%   In this case, PROCRUSTES adds columns of zeros to Y as necessary.
%
%   [D, Z] = PROCRUSTES(X, Y) also returns the transformed Y values.
%
%   [D, Z, TRANSFORM] = PROCRUSTES(X, Y) also returns the transformation
%   that maps Y to Z.  TRANSFORM is a structure with fields:
%      c:  the translation component
%      T:  the orthogonal rotation and reflection component
%      b:  the scale component
%   That is, Z = TRANSFORM.b * Y * TRANSFORM.T + TRANSFORM.c.
%
%   Examples:
%
%      % Create some random points in two dimensions
%      X = normrnd(0, 1, [10 2]);
%
%      % Those same points, rotated, scaled, translated, plus some noise
%      S = [0.5 -sqrt(3)/2; sqrt(3)/2 0.5]; % rotate 60 degrees
%      Y = normrnd(0.5*X*S + 2, 0.05, size(X));
%
%      % Conform Y to X, plot original X and Y, and transformed Y
%      [d, Z, tr] = procrustes(X,Y);
%      plot(X(:,1),X(:,2),'rx', Y(:,1),Y(:,2),'b.', Z(:,1),Z(:,2),'bx');
%
%   See also FACTORAN, CMDSCALE.

%   References:
%     [1] Seber, G.A.F., Multivariate Observations, Wiley, New York, 1984.
%     [2] Bulfinch, T., The Age of Fable; or, Stories of Gods and Heroes,
%         Sanborn, Carter, and Bazin, Boston, 1855.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2004/01/16 20:10:21 $

[n, m]   = size(X);
[ny, my] = size(Y);

if ny ~= n
    error('stats:procrustes:InputSizeMismatch',...
          'X and Y must have the same number of rows (points).');
elseif my > m
    error('stats:procrustes:InputSizeMismatch',...
          'Y cannot have more columns (variables) than X.');
end

% center at the origin
muX = mean(X,1);
muY = mean(Y,1);
X0 = X - repmat(muX, n, 1);
Y0 = Y - repmat(muY, n, 1);

ssqX = sum(X0.^2,1);
ssqY = sum(Y0.^2,1);
constX = all(ssqX <= abs(eps(class(X))*n*muX).^2);
constY = all(ssqY <= abs(eps(class(X))*n*muY).^2);

if ~constX & ~constY
    % the "centered" Frobenius norm
    normX = sqrt(sum(ssqX)); % == sqrt(trace(X0*X0'))
    normY = sqrt(sum(ssqY)); % == sqrt(trace(Y0*Y0'))

    % scale to equal (unit) norm
    X0 = X0 / normX;
    Y0 = Y0 / normY;

    % make sure they're in the same dimension space
    if my < m
        Y0 = [Y0 zeros(n, m-my)];
    end

    % optimum rotation matrix of Y
    A = X0' * Y0;
    [L, D, M] = svd(A);
    T = M * L';

    % optimum (symmetric in X and Y) scaling of Y
    trsqrtAA = sum(diag(D)); % == trace(sqrtm(A'*A))

    % the standardized distance between X and bYT+c
    d = 1 - trsqrtAA.^2;
    if nargout > 1
        Z = normX*trsqrtAA * Y0 * T + repmat(muX, n, 1);
    end
    if nargout > 2
        if my < m
            T = T(1:my,:);
        end
        b = trsqrtAA * normX / normY;
        transform = struct('T',T, 'b',b, 'c',repmat(muX - b*muY*T, n, 1));
    end

% the degenerate cases: X all the same, and Y all the same
elseif constX
    d = 0;
    Z = repmat(muX, n, 1);
    T = eye(my,m);
    transform = struct('T',T, 'b',0, 'c',Z);
else % ~constX & constY
    d = 1;
    Z = repmat(muX, n, 1);
    T = eye(my,m);
    transform = struct('T',T, 'b',0, 'c',Z);
end