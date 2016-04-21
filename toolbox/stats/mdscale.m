function [Y,stress,disparities] = mdscale(D,p,varargin)
%MDSCALE Non-Metric and Metric Multidimensional Scaling.
%   Y = MDSCALE(D,P) performs non-metric multidimensional scaling on the
%   N-by-N dissimilarity matrix D, and returns Y, a configuration of N
%   points (rows) in P dimensions (cols).  The Euclidean distances between
%   points in Y approximate a monotonic transformation of the corresponding
%   dissimilarities in D.  By default, MDSCALE uses Kruskal's normalized
%   STRESS1 criterion.
%
%   You can specify D as either a full N-by-N matrix, or in upper triangle
%   form such as is output by PDIST.  A full dissimilarity matrix must be
%   real and symmetric, and have zeros along the diagonal and non-negative
%   elements everywhere else.  A dissimilarity matrix in upper triangle
%   form must have real, non-negative entries.  MDSCALE treats NaNs in D as
%   missing values, and ignores those elements.  Inf is not accepted.
%
%   You can also specify D as a full similarity matrix, with ones along the
%   diagonal and all other elements less than one.  MDSCALE tranforms a
%   similarity matrix to a dissimilarity matrix in such a way that
%   distances between the points returned in Y approximate sqrt(1-D).  To
%   use a different transformation, transform the similarities prior to
%   calling MDSCALE.
%
%   [Y,STRESS] = MDSCALE(D,P) returns the minimized stress, i.e., the
%   stress evaluated at Y.
%
%   [Y,STRESS,DISPARITIES] = MDSCALE(D,P) returns the disparities, i.e. the
%   monotonic transformation of the dissimilarities D.
%
%   [...] = MDSCALE(..., 'PARAM1',val1, 'PARAM2',val2, ...) allows you to
%   specify optional parameter name/value pairs that control further details
%   of MDSCALE.  Parameters are:
%
%   'Criterion' - The goodness-of-fit criterion to minimize.  This also
%       determines the type of scaling, either non-metric or metric, that
%       MDSCALE performs.  Choices for non-metric scaling are:
%
%           'stress'  - Stress normalized by the sum of squares of
%                       the interpoint distances, also known as STRESS1.
%                       This is the default.
%           'sstress' - Squared Stress, normalized with the sum of 4th
%                       powers of the interpoint distances.
%
%       Choices for metric scaling are:
%
%           'metricstress'  - Stress, normalized with the sum of squares
%                             of the dissimilarities.
%           'metricsstress' - Squared Stress, normalized with the sum of
%                             4th powers of the dissimilarities.
%           'sammon'        - Sammon's nonlinear mapping criterion.
%                             Off-diagonal dissimilarities must be
%                             strictly positive with this criterion.
%           'strain'        - A criterion equivalent to that used in
%                             classical MDS.
%
%   'Weights' - A matrix or vector the same size as D, containing
%       nonnegative dissimilarity weights.  You can use these to weight the
%       contribution of the corresponding elements of D in computing and
%       minimizing stress.  Elements of D corresponding to zero weights are
%       effectively ignored.
%
%   'Start' - Method used to choose the initial configuration of points
%       for Y.  Choices are:
%
%       'cmdscale' - Use the classical MDS solution.  This is the default.
%                    'cmdscale' is not valid when there are zero weights.
%       'random'   - Choose locations randomly from an appropriately
%                    scaled P-dimensional normal distribution with
%                    uncorrelated coordinates.
%       matrix     - An N-by-P matrix of initial locations.  In this
%                    case, you can pass in [] for P, and MDSCALE infers P
%                    from the second dimension of the matrix. You can also
%                    supply a 3D array, implying a value for 'Replicates'
%                    from the array's third dimension.
%
%   'Replicates' - Number of times to repeat the scaling, each with a new
%       initial configuration.  Defaults to 1.
%
%   'Options' - Options for the iterative algorithm used to minimize the
%       fitting criterion, as created by STATSET.  Choices of STATSET
%       parameters are:
%
%       'Display'     - Level of display output.  Choices are 'off' (the
%                       default), 'iter', and 'final'.
%       'MaxIter'     - Maximum number of iterations allowed.  Defaults
%                       to 200.
%       'TolFun'      - Termination tolerance for the stress criterion
%                       and its gradient.  Defaults to 1e-4.
%       'TolX'        - Termination tolerance for the configuration
%                       location step size.  Defaults to 1e-4.
%
%   Example:
%
%      % Generate some 4D data, and create a dissimilarity matrix.
%      load cereal.mat
%      X = [Calories Protein Fat Sodium Fiber Carbo Sugars Shelf Potass Vitamins];
%      X = X(strmatch('K',Mfg),:); % take a subset from a single manufacturer
%      dissimilarities = pdist(X);
%
%      % Use non-metric scaling to recreate the data in 2D, and make a
%      % Shepard plot of the results.
%      [Y,stress,disparities] = mdscale(dissimilarities,2);
%      distances = pdist(Y);
%      [dum,ord] = sortrows([disparities(:) dissimilarities(:)]);
%      plot(dissimilarities,distances,'bo', ...
%           dissimilarities(ord),disparities(ord),'r.-');
%      xlabel('Dissimilarities'); ylabel('Distances/Disparities')
%      legend({'Distances' 'Disparities'}, 'Location','NorthWest');
%
%      % Do metric scaling on the same dissimilarities.
%      [Y,stress] = mdscale(dissimilarities,2,'criterion','metricsstress');
%      distances = pdist(Y);
%      plot(dissimilarities,distances,'bo', ...
%           [0 max(dissimilarities)],[0 max(dissimilarities)],'k:');
%      xlabel('Dissimilarities'); ylabel('Distances')
%
%   See also CMDSCALE, PDIST, STATSET.

%   In non-metric scaling, MDSCALE finds a configuration of points whose
%   pairwise Euclidean distances have approximately the same rank order as
%   the corresponding dissimilarities.  Equivalently, MDSCALE finds a
%   configuration of points, whose pairwise Euclidean distances approximate
%   a monotonic transformation of the dissimilarities.  These transformed
%   values are known as the disparities.
%
%   In metric scaling, MDSCALE finds a configuration of points whose pairwise
%   Euclidean distances approximate the dissimilarities directly.  There are
%   no disparities in metric scaling.
%
%   References:
%      [1] Cox, R,.F. and Cox, M.A.A. (1994) Multidimensional Scaling,
%          Chapman&Hall.
%      [2] Davison, M.L. (1983) Multidimensional Scaling, Wiley.
%      [3] Seber, G.A.F., (1984) Multivariate Observations, Wiley.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/15 01:00:32 $

if nargin < 2
    error('stats:mdscale:TooFewInputs', ...
          'At least two input arguments required.');
end

paramNames = {'criterion' 'weights' 'start' 'replicates' 'options'};
paramDflts = {[] [] [] [] []};
[errid,errmsg,criterion,weights,start,nreps,options] = ...
                           statgetargs(paramNames, paramDflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:mdscale:%s',errid),errmsg);
end

[n,m] = size(D);

% Make sure weights match dissimilarities, and are non-negative.
if ~isempty(weights)
    if isequal(size(weights),size(D))
        if any(weights < 0)
            error('stats:mdscale:NegativeWeights', ...
                  'Weights must be non-negative.');
        end
    else
        error('stats:mdscale:InputSizeMismatch', ...
              'Dissimilarity and weight inputs must be the same size.');
    end
    weighted = true;
else
    weighted = false;
end

% Treat NaNs as missing, and zero out the corresponding weights.
missing = find(isnan(D));
if ~isempty(missing)
    if ~weighted
        weights = ones(size(D), class(D));
        weighted = true;
    end
    weights(missing) = 0;
end

isEmptyOrZeroWgt = @(badD) (~weighted && isempty(badD)) || ...
                           (weighted && all(weights(badD) == 0));
% Lower triangle form for D, make sure it's a valid dissimilarity matrix
if n == 1
    n = (1+sqrt(1+8*m))/2;
    badD = find((D < 0) | ~isfinite(D));
    if (n == floor(n)) && isEmptyOrZeroWgt(badD)
        dissimilarities = D;
    else
        error('stats:mdscale:InvalidDissimilarities', ...
              'D is not a valid dissimilarity matrix.');
    end
    fullInputD = false;

% Full matrix form, make sure it's valid similarity/dissimilarity matrix
elseif n == m
    badD = find((D < 0) | ~isfinite(D) | abs(D-D') > 10*eps*max(D(:)));
    if isEmptyOrZeroWgt(badD)
        
        % It's a dissimilarity matrix
        if all(diag(D) == 0)
            % nothing to do
            
        % It's a similarity matrix -- transform to dissimilarity matrix.
        % the sqrt is not entirely arbitrary, see Seber, eqn. 5.73
        else
            badD = find(D > 1);
            if all(diag(D) == 1) && isEmptyOrZeroWgt(badD)
                D = sqrt(1 - D);
            else
                error('stats:mdscale:InvalidDissimilarities', ...
                      'D is not a valid dissimilarity or similarity matrix.')
            end
        end
        fullInputD = true;
        
        % Get the lower triangle form for the dissimilarities.
        dissimilarities = D(tril(true(size(D)),-1))';
        if weighted
            weights = weights(tril(true(size(D)),-1))';
        end
    else
        error('stats:mdscale:InvalidDissimilarities', ...
              'D is not a valid dissimilarity or similarity matrix.')
    end
    
else
    error('stats:mdscale:InvalidDissimilarities', ...
          'D is not a valid dissimilarity or similarity matrix.')
end
if weighted
    zeroWgts = find(weights == 0);
    % Fill dissimilarities corresponding to zero weights with anything
    % finite: these dissimilarities must get ignored by being multiplied by
    % the zero weights.
    if ~isempty(zeroWgts)
        dissimilarities(zeroWgts) = 1;
    end
    % It's not strictly necessary to do this for nonmetric scaling, because
    % the dissimilarities get sent through lsqisotonic.
end

% Use Kruskal's STRESS1 by default, or whatever is specified.
if isempty(criterion)
    stressFun = @stressCrit;
    metric = false;
elseif ischar(criterion)
    funNames = {'stress','sstress','metricstress','metricsstress','sammon','strain'};
    i = strmatch(lower(criterion), funNames);
    if length(i) > 1
        error('stats:mdscale:AmbiguousCriterion', ...
              sprintf('Ambiguous ''criterion'' parameter value:  %s.', criterion));
    elseif isempty(i)
        error('stats:mdscale:UnknownCriterion', ...
              sprintf('Unknown ''criterion'' parameter value:  %s.', criterion));
    end
    switch i
    case 1 % 'stress'
        stressFun = @stressCrit;
        metric = false;
    case 2 % 'sstress'
        stressFun = @sstressCrit;
        metric = false;
    case 3 % 'metricstress'
        stressFun = @metricStressCrit;
        metric = true; strain = false;
    case 4 % 'metricsstress'
        stressFun = @metricSStressCrit;
        metric = true; strain = false;
    case 5 % 'sammon'
        if any(dissimilarities <= 0)
            error('stats:mdscale:NonpositiveDissimilarities', ...
                  'D must contain strictly positive values for Sammon mapping.');
        end
        stressFun = @sammonCrit;
        metric = true; strain = false;
    case 6 % 'strain'
        stressFun = @strainCrit;
        metric = true; strain = true;
    end
else
    error('stats:mdscale:InvalidStressFun', ...
          'The value of the ''stressfun'' parameter must be a string.');
end

% Use the classical solution as a starting point by default.
if isempty(start) || ...
   (ischar(start) && isequal(strfind('cmdscale', lower(start)),1))
    if weighted && ~isempty(zeroWgts)
        error('stats:mdscale:NeedPosWeights', ...
              ['Cannot initialize with ''cmdscale'' when there are zero ' ...
               'weights or missing data.\nInitialize with ''random'' or ' ...
               'provide explicit starting points.']);
    end
    % No sense in replicates if there's only one starting point.
    nreps = 1;
    start = 'cmdscale';
    
% Use a random configuration as a starting point.
elseif ischar(start) && isequal(strfind('random', lower(start)),1)
    start = 'random';
    % do nothing else yet
    
% User-supplied configuration(s) as a starting point.
elseif isnumeric(start)
    [r,c,pg] = size(start);
    
    % Infer the number of replicates from the number of starting
    % configurations supplied.
    if isempty(nreps)
        nreps = pg;
    end
    % Otherwise, will have to verify that the number of starting
    % configurations supplied equals the number of replicates.
    
    % The number of dimensions, p, can be left out if 'start' is given
    % explicitly.  Infer p from the starting configuration(s) if necessary.
    if isempty(p), p = c; end
    
    % Make sure the starting configuration(s) have the right size, and save
    % them for later.
    if (r==n) && (c==p) && (pg==nreps)
        explicitY0 = start;
        start = 'explicit';
    else
        error('stats:mdscale:InputSizeMismatch', ...
              'Incorrect size for the ''start'' parameter value.');
    end
    
else
    error('stats:mdscale:InvalidStart', ...
          'The ''start'' parameter value must be ''cmdscale'', ''random'', or a numeric array.');
end

% Assume one replicate if it was not given or inferred from start.
if isempty(nreps), nreps = 1; end

%
% Done processing input args, begin calculation
%

bestStress = Inf; bestY = []; bestDisparities = [];
for rep = 1:nreps
    % Initialize the configuration of points.
    switch start
    case 'cmdscale'
        Y0 = cmdscale(D); % the original D, full if given that way
        if size(Y0,2) >= p
            Y0 = Y0(:,1:p);
        else % D had more than (n-p) negative eigenvalues
            warning('stats:mdscale:ZeroPad', ...
                    'Padding initial configuration with zeros to achieve full dimension.');
            Y0 = [Y0 zeros(n,p-size(Y0,2),class(Y0))];
        end
    case 'random'
        % Scale to have an average squared distance equal to the average
        % squared dissimilarity in D.
        if weighted
            sigsq = mean(dissimilarities(weights>0).^2)./(2.*p);
        else
            sigsq = mean(dissimilarities.^2)./(2.*p);
        end
        Y0 = cast(randn(n,p),class(dissimilarities)) .* sqrt(sigsq);
    case 'explicit'
        Y0 = explicitY0(:,:,rep);
    end
    
    % Do metric or non-metric multidimensional scaling.
    if metric
        if strain
            % Strain uses transformed dissimilarities, and needs them as a
            % square matrix.  It's convenient to do that beforehand here.
            A = squareform(-0.5 .* (dissimilarities.^2));
            if weighted
                weights = squareform(weights);
            end
            [Y,stress,iter] = MDS(Y0,A,weights,stressFun,metric,weighted,options);
        else
            [Y,stress,iter] = MDS(Y0,dissimilarities,weights,stressFun,metric,weighted,options);
        end
        if nargout > 2
            disparities = dissimilarities;
        end
    else
        [Y,stress,iter,disparities] = MDS(Y0,dissimilarities,weights,stressFun,metric,weighted,options);
    end
    
    % Save this solution if it's the best one so far.
    if stress < bestStress
        bestStress = stress;
        bestY = Y;
        if nargout > 2, bestDisparities = disparities; end
    end
end

% Remember the best solution.
stress = bestStress;
Y = bestY;
if nargout > 2
    if fullInputD
        disparities = squareform(bestDisparities);
    else
        disparities = bestDisparities;
    end
end

% Rotate the solution to principal component axes.
[pc,score] = princomp(Y);
Y = score;


%==========================================================================

function [Y,stress,iter,disparities] = ...
             MDS(Y,dissimilarities,weights,stressFun,metric,weighted,options)

[n,p] = size(Y);

% Merge default and user options.
options = statset(statset('mdscale'), options);

% Start with a loose tolerance in the line search.
lineSearchOpts = ...
    struct('Display','off', 'MaxFunEvals',100, 'MaxIter',100, 'TolX',1e-2);

verb = strmatch(options.Display, ['off   '; 'notify';  'final '; 'iter  ']) - 1;
if verb > 2
    disp(' ');
    disp('                     Stress          Norm of         Norm of     Line Search');
    disp('   Iteration       Criterion        Gradient           Step       Iterations');
    disp('  ---------------------------------------------------------------------------');
end

% For metric scaling, there are no disparities, but for convenience in
% the code, set them equal to the dissimilarities.
if metric
    disparities = dissimilarities;
end
if ~weighted
    weights = 1; % dummy weights for the criterion functions
end

oldStress = NaN;
iter = 0;
stepLen = 10;
while true
    % Center Y: Stress is invariant to location.
    Y = Y - repmat(mean(Y,1),n,1);
    
    distances = pdist(Y);
    
    % For non-metric scaling, compute disparities as the values closest to
    % the current interpoint distances, in the least squares sense, while
    % constrained to be monotonic in the given dissimilarities.
    if ~metric
        % Keep the configuration on the same scale as the dissimilarities.
        % The non-metric forms of Stress are invariant to scale.
        scale = max(dissimilarities)/max(distances);
        Y = Y * scale;
        distances = distances * scale;

        if weighted
            disparities = lsqisotonic(dissimilarities, distances, weights);
        else
            disparities = lsqisotonic(dissimilarities, distances);
        end
    end
    
    % Compute stress for the current configuration, and its gradient with
    % respect to Y, with disparities held constant.
    [stress,grad] = feval(stressFun, Y, disparities, weights);
    normGrad = norm(grad(:));
    
    if verb > 2
        if iter == 0
            disp(sprintf('      %6d    %12g    %12g',iter,stress,normGrad));
        else
            disp(sprintf('      %6d    %12g    %12g    %12g          %6d', ...
                         iter,stress,normGrad,stepLen,output.funcCount));
        end
    end
    
    % Test for convergence or failure.
    if stress < options.TolFun
        if verb > 2
            disp('Iterations terminated:  Criterion less than OPTIONS.TolFun.');
        end
        break;
    elseif normGrad < options.TolFun*stress
        if verb > 2
            disp('Iterations terminated:  Relative norm of gradient less than OPTIONS.TolFun.');
        end
        break;
    elseif (oldStress-stress) < options.TolFun*stress
        if verb > 2
            disp('Iterations terminated:  Relative change in criterion less than OPTIONS.TolFun.');
        end
        break;
    elseif stepLen < options.TolX * norm(Y(:))
        if verb > 2
            disp('Iterations terminated:  Norm of change in configuration less than OPTIONS.TolX.');
        end
        break;
    elseif iter == options.MaxIter
        warning('stats:mdscale:IterOrEvalLimit', ...
                'Iteration limit exceeded.  Minimization of criterion did not converge.');
        break;
    end
    
    % Do a line search to minimize stress in the direction of the gradient.
    % Limit the search to twice the length of the previous step.
    iter = iter + 1;
    gradDir = grad ./ normGrad;
    oldStress = stress;
    oldStepLen = stepLen;
    [stepLen, stress, err, output] = ...
            fminbnd(@lineSearchCrit,0,2*stepLen,lineSearchOpts, ...
                    Y,gradDir,disparities,weights,stressFun);
    if (err == 0)
        warning('stats:mdscale:LineSrchIterLimit', ...
                'Line search iteration limit reached.');
    elseif (err < 0)
        error('stats:mdscale:NoSolution', ...
              'No solution found along gradient direction.');
    end
    
    % Take the downhill step.
    Ystep = stepLen*gradDir;
    Y = Y - Ystep;
    
    % Tighten up the line search tolerance, but not beyond the requested
    % tolerance.
    lineSearchOpts.TolX = max(lineSearchOpts.TolX/2, options.TolX);
    
    % Make sure the step size doesn't get too small too fast (especially
    % not zero).
    if stepLen < 0.1.*oldStepLen
        stepLen = 0.1.*oldStepLen;
    end
end
if verb > 1
    disp(sprintf('%d iterations, Final stress criterion = %g',iter,stress));
end


%==========================================================================

function val = lineSearchCrit(t,Y,gradDir,disparities,weights,stressFun)
%LINESEARCHOBJFUN Objective function for linesearch in non-metric MDS.

% Given a step size, evaluate the stress at a downhill step away from the
% current configuration.
val = feval(stressFun,Y-t*gradDir,disparities,weights);


%==========================================================================

function [S,grad] = stressCrit(Y,disparities,weights)
%STRESS Stress criterion for nonmetric multidimensional scaling.

% The Euclidean norm of the differences between the distances and the
% disparities, normalized by the Euclidean norm of the distances.
%
% Zero weights are ok as long as the corresponding dissimilarities are
% finite.  However, any zero distances will throw an error:  this criterion
% is not differentiable when two points are coincident - it involves, in
% effect, abs(Y(i,k)-Y(j,k)).  This does sometimes happen, even though a
% configuration that is a local minimizer cannot have coincident points.

distances = pdist(Y);
diffs = distances - disparities;
sumDiffSq = sum(weights.*diffs.^2);
sumDistSq = sum(weights.*distances.^2);
S = sqrt(sumDiffSq ./ sumDistSq);
if nargout > 1
    [n,p] = size(Y);
    if sumDiffSq > 0
        if all(distances > 0)
            dS = squareform(weights.* ...
                     (diffs./sumDiffSq - distances./sumDistSq) ./ distances);
            repcols = zeros(1,n);
            for i = 1:p
                repcols = repcols + 1;
                dY = Y(:,repcols) - Y(:,repcols)';
                grad(:,i) = sum(dS.*dY,2) .* S;
            end
        else
            error('stats:mdscale:ColocatedPoints', ...
                  ['Points in the configuration have co-located.  Try a' ...
                   ' different\nstarting point, or use a different criterion.']);
        end
    else
        grad = repmat(0,n,p);
    end
end


%==========================================================================

function [S,grad] = metricStressCrit(Y,dissimilarities,weights)
%METRICSTRESS Stress criterion for metric MDS.

% The Euclidean norm of the differences between the distances and the
% dissimilarities, normalized by the Euclidean norm of the dissimilarities.
%
% Zero weights are ok as long as the corresponding dissimilarities are
% finite.  However, any zero distances will throw an error:  this criterion
% is not differentiable when two points are coincident - it involves, in
% effect, abs(Y(i,k)-Y(j,k)).  This does sometimes happen, even though a
% configuration that is a local minimizer cannot have coincident points.

distances = pdist(Y);
diffs = distances - dissimilarities;
sumDiffSq = sum(weights.*diffs.^2);
sumDissSq = sum(weights.*dissimilarities.^2);
S = sqrt(sumDiffSq./sumDissSq);

if nargout > 1
    [n,p] = size(Y);
    if sumDiffSq > 0
        if all(distances > 0)
            dS = squareform(weights.*diffs ./ distances);
            repcols = zeros(1,n);
            for i = 1:p
                repcols = repcols + 1;
                dY = Y(:,repcols) - Y(:,repcols)';
                grad(:,i) = sum(dS.*dY,2) ./ (sumDissSq.*S);
            end
        else
            error('stats:mdscale:ColocatedPoints', ...
                  ['Points in the configuration have co-located.  Try a' ...
                   ' different\nstarting point, or use a different criterion.']);
        end
    else
        grad = repmat(0,n,p);
    end
end


%==========================================================================

function [S,grad] = sstressCrit(Y,disparities,weights)
%SSTRESS Squared stress criterion for nonmetric multidimensional scaling.

% The Euclidean norm of the differences between the squared distances and
% the squared disparities, normalized by the Euclidean norm of the squared
% distances.
%
% Zero weights are ok as long as the corresponding dissimilarities are
% finite.  Zero distances are also OK:  this criterion is differentiable
% even when two points are coincident.

% The normalization used here is sum(distances.^4).  Some authors instead
% use sum(disparities.^4).
distances = pdist(Y);
diffs = distances.^2 - disparities.^2;
sumDiffSq = sum(weights.*diffs.^2);
sumDist4th = sum(weights.*distances.^4);
S = sqrt(sumDiffSq ./ sumDist4th);
if nargout > 1
    [n,p] = size(Y);
    if sumDiffSq > 0
        dS = squareform(weights.* (diffs./sumDiffSq - (distances.^2)./sumDist4th));
        repcols = zeros(1,n);
        for i = 1:p
            repcols = repcols + 1;
            dY = Y(:,repcols) - Y(:,repcols)';
            grad(:,i) = sum(dS.*dY,2) .* S .* 2;
        end
    else
        grad = repmat(0,n,p);
    end
end


%==========================================================================

function [S,grad] = metricSStressCrit(Y,dissimilarities,weights)
%METRICSSTRESS Squared stress criterion for metric MDS.

% The Euclidean norm of the differences between the squared distances and
% the squared dissimilarities, normalized by the Euclidean norm of the
% squared dissimilarities.
%
% Zero weights are ok as long as the corresponding dissimilarities are
% finite.  Zero distances are also OK:  this criterion is differentiable
% even when two points are coincident.

distances = pdist(Y);
diffs = distances.^2 - dissimilarities.^2;
sumDiffSq = sum(weights.*diffs.^2);
sumDiss4th = sum(weights.*dissimilarities.^4);
S = sqrt(sumDiffSq./sumDiss4th);
if nargout > 1
    [n,p] = size(Y);
    if sumDiffSq > 0
        dS = squareform(weights.*diffs);
        repcols = zeros(1,n);
        for i = 1:p
            repcols = repcols + 1;
            dY = Y(:,repcols) - Y(:,repcols)';
            grad(:,i) = 2 .* sum(dS.*dY,2) ./ (sumDiss4th.*S);
        end
    else
        grad = repmat(0,n,p);
    end
end


%==========================================================================

function [S,grad] = sammonCrit(Y,dissimilarities,weights)
%SAMMON Sammon mapping criterion for metric multidimensional scaling.

% The sum of the scaled, squared differences between the distances and
% the dissimilarities, normalized by the sum of the dissimilarities. 
% The squared differences are scaled by the dissimilarities before summing.
%
% Zero weights are ok as long as the corresponding dissimilarities are
% finite.  However, zero distances or dissimilarities will cause problems.

distances = pdist(Y);
diffs = distances - dissimilarities;
sumDiffSq = sum(weights.*diffs.^2 ./ dissimilarities);
sumDiss = sum(weights.*dissimilarities);
S = sumDiffSq ./ sumDiss;
if nargout > 1
    [n,p] = size(Y);
    if sumDiffSq > 0
        if all(distances > 0)
            dS = squareform(weights.*diffs ./ (distances.*dissimilarities));
            repcols = zeros(1,n);
            for i = 1:p
                repcols = repcols + 1;
                dY = Y(:,repcols) - Y(:,repcols)';
                grad(:,i) = 2 .* sum(dS.*dY,2) ./ sumDiss;
            end
        else
            error('stats:mdscale:ColocatedPoints', ...
                  ['Points in the configuration have co-located.  Try a' ...
                   ' different\nstarting point, or use a different criterion.']);
        end
    else
        grad = repmat(0,n,p);
    end
end


%==========================================================================

function [S,grad] = strainCrit(Y,A,weights)
%STRAIN Strain criterion for metric multidimensional scaling.

% Let Y be a minimizer of norm(A-Yc*Yc'), where Yc = (I-ones(n)/n)*Y = P*Y
% (i,e,, Y centered at the origin), and A = -0.5*(D.^2).  Then X = P*Y is a
% minimizer of norm(B-X*X'), where B = P*A*P (the two quantities differ by
% norm(B-A), a constant).  This is exactly the criterion that is minimized
% in CMDS, but now we have a form that is easier to weight.
%
% Zero weights are ok as long as the corresponding dissimilarities are
% finite.

[n,p] = size(Y);
Yc = Y - repmat(mean(Y,1),n,1);
diffs = weights.*(A - Yc*Yc') ./ sum(weights(:));
S = norm(diffs,'fro');
if nargout > 1
    repcols = zeros(1,n);
    for i = 1:p
        repcols = repcols + 1;
        dSrows = diffs .* Yc(:,repcols);
        dScols = diffs .* Yc(:,repcols)';
        grad(:,i) = (sum(sum(dSrows+dScols,2),1)./n - 2.*sum(dScols,2)) ./ S;
    end
end
