function Y = pdist(X,dist,varargin)
%PDIST Pairwise distance between observations.
%   Y = PDIST(X) returns a vector Y containing the Euclidean distances
%   between each pair of observations in the N-by-P data matrix X.  Rows of
%   X correspond to observations, columns correspond to variables.  Y is a
%   1-by-(N*(N-1)/2) row vector, corresponding to the N*(N-1)/2 pairs of
%   observations in X.
%
%   Y = PDIST(X, DISTANCE) computes Y using DISTANCE.  Choices are:
%
%       'euclidean'   - Euclidean distance
%       'seuclidean'  - Standardized Euclidean distance, each coordinate
%                       in the sum of squares is inverse weighted by the
%                       sample variance of that coordinate
%       'cityblock'   - City Block distance
%       'mahalanobis' - Mahalanobis distance
%       'minkowski'   - Minkowski distance with exponent 2
%       'cosine'      - One minus the cosine of the included angle
%                       between observations (treated as vectors)
%       'correlation' - One minus the sample correlation between
%                       observatons (treated as sequences of values).
%       'hamming'     - Hamming distance, percentage of coordinates
%                       that differ
%       'jaccard'     - One minus the Jaccard coefficient, the
%                       percentage of nonzero coordinates that differ
%       'chebychev'   - Chebychev distance (maximum coordinate difference)
%       function      - A distance function specified using @, for
%                       example @DISTFUN
%
%   A distance function must be of the form
%
%         function D = DISTFUN(XI, XJ, P1, P2, ...),
%
%   taking as arguments a 1-by-P vector XI containing a single row of X, an
%   M-by-P matrix XJ containing multiple rows of X, and zero or more
%   additional problem-dependent arguments P1, P2, ..., and returning an
%   M-by-1 vector of distances D, whose Kth element is the distance between
%   the observations XI and XJ(K,:).
%
%   Y = PDIST(X, DISTFUN, P1, P2, ...) passes the arguments P1, P2, ...
%   directly to the function DISTFUN.
%
%   Y = PDIST(X, 'minkowski', P) computes Minkowski distance using the
%   positive scalar exponent P.
%
%   The output Y is arranged in the order of ((1,2),(1,3),..., (1,N),
%   (2,3),...(2,N),.....(N-1,N)), i.e. the lower left triangle of the full
%   N-by-N distance matrix in column order.  To get the distance between
%   the Ith and Jth observations (I < J), either use the formula
%   Y((I-1)*(N-I/2)+J-I), or use the helper function Z = SQUAREFORM(Y),
%   which returns an N-by-N square symmetric matrix, with the (I,J) entry
%   equal to distance between observation I and observation J.
%
%   Example:
%
%      X = randn(100, 5);                 % some random points
%      Y = pdist(X, 'euclidean');         % unweighted distance
%      Wgts = [.1 .3 .3 .2 .1];           % coordinate weights
%      Ywgt = pdist(X, @weucldist, Wgts); % weighted distance
%
%      function d = weucldist(XI, XJ, W) % weighted euclidean distance
%      d = sqrt((repmat(XI,size(XJ,1),1)-XJ).^2 * W');
%
%   See also SQUAREFORM, LINKAGE, SILHOUETTE.

%   An example of distance for data with missing elements:
%
%      X = randn(100, 5);     % some random points
%      X(unidrnd(prod(size(X)),1,20)) = NaN; % scatter in some NaNs
%      D = pdist(X, @naneucdist);
%
%      function d = naneucdist(XI, XJ) % euclidean distance, ignoring NaNs
%      [m,p] = size(XJ);
%      sqdx = (repmat(XI,m,1) - XJ) .^ 2;
%      pstar = sum(~isnan(sqdx),2); % correction for missing coords
%      pstar(pstar == 0) = NaN;
%      d = sqrt(nansum(sqdx,2) .* p ./ pstar);
%
%
%   For a large number of observations, it is sometimes faster to compute
%   the distances by looping over coordinates of the data (though the code
%   is more complicated):
%
%      function d = nanhamdist(XI, XJ) % hamming distance, ignoring NaNs
%      [m,p] = size(XJ);
%      nesum = zeros(m,1);
%      pstar = zeros(m,1);
%      for q = 1:p
%          notnan = ~(isnan((XI(q)) | isnan(XJ(:,q)));
%          nesum = nesum + (XI(q) ~= XJ(:,q)) & notnan;
%          pstar = pstar + notnan;
%      end
%      nesum(any() | nans((i+1):n)) = NaN;
%      Y(k:(k+n-i-1)) = nesum ./ pstar;

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.9 $ $Date: 2004/03/02 21:49:18 $

if nargin < 2
    dist = 'euc';
else
    if ischar(dist)
        methods = {'euclidean'; 'seuclidean'; 'cityblock'; 'chebychev'; ...
                   'mahalanobis'; 'minkowski'; 'cosine'; 'correlation'; ...
                   'hamming'; 'jaccard'};
        i = strmatch(lower(dist), methods);
        if length(i) > 1
            error('stats:pdist:BadDistance',...
                  'Ambiguous ''DISTANCE'' argument:  %s.', dist);
        elseif isempty(i)
            % Assume an unrecognized string is a user-supplied distance
            % function name, change it to a handle.
            distfun = str2func(dist);
            distargs = varargin;
            dist = 'usr';
        else
            dist = lower(methods{i}(1:3));
        end
    elseif isa(dist, 'function_handle') ||  isa(dist, 'inline')
        distfun = dist;
        distargs = varargin;
        dist = 'usr';
    else
        error('stats:pdist:BadDistance',...
              'The ''DISTANCE'' argument must be a string or a function.');
    end
end

[n,p] = size(X);
if n < 2
    % Degenerate case, just return an empty of the proper size.
    Y = zeros(1,0,class(X));
    return;
end

if ~strcmp(dist,'usr')
    if any(imag(X(:)))
        error('stats:pdist:InvalidData','PDIST does not accept complex inputs.');
    elseif ~isfloat(X)
        X = double(X);
    end
end

switch dist
case 'seu' % Standardized Euclidean weights by coordinate variance
    additionalArg = 1 ./ var(X)';
case 'mah' % Mahalanobis
    additionalArg = cov(X) \ eye(p); %inv(cov(X));
case 'min' % Minkowski distance needs a third argument
    if nargin < 3  % use default value for exponent
        additionalArg = 2;
    elseif varargin{1} > 0
        additionalArg = varargin{1}; % get exponent from input args
    else
        error('stats:pdist:InvalidExponent',...
              'The exponent for the Minkowski metric must be positive.');
    end
case 'cos' % Cosine
    Xnorm = sqrt(sum(X.^2, 2));
    if min(Xnorm) <= eps(max(Xnorm))
        error('stats:pdist:InappropriateDistance',...
              ['Some points have small relative magnitudes, making them ', ...
               'effectively zero.\nEither remove those points, or choose a ', ...
               'distance other than cosine.'], []);
    end
    X = X ./ Xnorm(:,ones(1,p));
    additionalArg = [];
case 'cor' % Correlation
    X = X - repmat(mean(X,2),1,p);
    Xnorm = sqrt(sum(X.^2, 2));
    if min(Xnorm) <= eps(max(Xnorm))
        error('stats:pdist:InappropriateDistance',...
              ['Some points have small relative standard deviations, making ', ...
               'them effectively constant.\nEither remove those points, or ', ...
               'choose a distance other than correlation.'], []);
    end
    X = X ./ Xnorm(:,ones(1,p));
    additionalArg = [];
otherwise
    additionalArg = [];
end

% Call a mex file to compute distances for the standard distance measures
% and real double or single data.
if ~strcmp(dist,'usr') && isfloat(X) % ~usr => ~complex
    Y = pdistmex(X',dist,additionalArg);
    
% This M equivalent works for real single and double.
elseif ~strcmp(dist,'usr')
    if strmatch(dist, {'ham' 'jac' 'che'})
        nans = any(isnan(X),2);
    end
    outClass = class(X);
    Y = zeros(1,n*(n-1)./2, outClass);
    k = 1;
    for i = 1:n-1
        switch dist
        case 'euc'    % Euclidean
            dsq = zeros(n-i,1,outClass);
            for q = 1:p
                dsq = dsq + (X(i,q) - X((i+1):n,q)).^2;
            end
            Y(k:(k+n-i-1)) = sqrt(dsq);

        case 'seu'    % Standardized Euclidean
            wgts = additionalArg;
            dsq = zeros(n-i,1,outClass);
            for q = 1:p
                dsq = dsq + wgts(q) .* (X(i,q) - X((i+1):n,q)).^2;
            end
            Y(k:(k+n-i-1)) = sqrt(dsq);

        case 'cit'    % City Block
            d = zeros(n-i,1,outClass);
            for q = 1:p
                d = d + abs(X(i,q) - X((i+1):n,q));
            end
            Y(k:(k+n-i-1)) = d;

        case 'mah'    % Mahalanobis
            invcov = additionalArg;
            del = repmat(X(i,:),n-i,1) - X((i+1):n,:);
            dsq = sum((del*invcov).*del,2);
            Y(k:(k+n-i-1)) = sqrt(dsq);

        case 'min'    % Minkowski
            expon = additionalArg;
            dpow = zeros(n-i,1,outClass);
            for q = 1:p
                dpow = dpow + abs(X(i,q) - X((i+1):n,q)).^expon;
            end
            Y(k:(k+n-i-1)) = dpow .^ (1./expon);

        case {'cos' 'cor'}   % Cosine
            d = zeros(n-i,1,outClass);
            for q = 1:p
                d = d + (X(i,q).*X((i+1):n,q));
            end
            Y(k:(k+n-i-1)) = 1 - d;

        case 'ham'    % Hamming
            nesum = zeros(n-i,1,outClass);
            for q = 1:p
                nesum = nesum + (X(i,q) ~= X((i+1):n,q));
            end
            nesum(nans(i) | nans((i+1):n)) = NaN;
            Y(k:(k+n-i-1)) = nesum ./ p;

        case 'jac'    % Jaccard
            nzsum = zeros(n-i,1,outClass);
            nesum = zeros(n-i,1,outClass);
            for q = 1:p
                nz = (X(i,q) ~= 0 | X((i+1):n,q) ~= 0);
                ne = (X(i,q) ~= X((i+1):n,q));
                nzsum = nzsum + nz;
                nesum = nesum + (nz & ne);
            end
            nesum(nans(i) | nans((i+1):n)) = NaN;
            Y(k:(k+n-i-1)) = nesum ./ nzsum;

        case 'che'    % Chebychev
            dmax = zeros(n-i,1,outClass);
            for q = 1:p
                dmax = max(dmax, abs(X(i,q) - X((i+1):n,q)));
            end
            dmax(nans(i) | nans((i+1):n)) = NaN;
            Y(k:(k+n-i-1)) = dmax;

        end
        k = k + (n-i);
    end
    
% Compute distances for a caller-defined distance function.
else % if strcmp(dist,'usr')
    warning('stats:pdist:APIChanged', ...
            'The input arguments for caller-defined distance functions has\nchanged beginning in R14.  See the help for details.');
    try
        Y = feval(distfun,X(1,:),X(2,:),distargs{:})';
    catch
        [errMsg,errID] = lasterr;
        if strcmp('MATLAB:UndefinedFunction', errID) ...
                && ~isempty(strfind(errMsg, func2str(distfun)))
            error('stats:pdist:DistanceFunctionNotFound',...
                  'The distance function ''%s'' was not found.', func2str(distfun));
        end
        % Otherwise, let the catch block below generate the error message
        Y = [];
    end
    
    % Make the return have whatever type the distance function returns.
    Y = zeros(1,n*(n-1)./2, class(Y));
    
    k = 1;
    for i = 1:n-1
        try
            Y(k:(k+n-i-1)) = feval(distfun,X(i,:),X((i+1):n,:),distargs{:})';
        catch
            [errMsg,errID] = lasterr;
            if isa(distfun, 'inline')
                error('stats:pdist:DistanceFunctionError',...
                      ['The inline distance function generated the following ', ...
                       'error:\n%s'], lasterr);
            else
                error('stats:pdist:DistanceFunctionError',...
                      ['The distance function ''%s'' generated the following ', ...
                       'error:\n%s'], func2str(distfun),lasterr);
            end
        end
        k = k + (n-i);
    end
end
