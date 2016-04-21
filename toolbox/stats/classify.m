function [outclass, err] = classify(sample, training, group, type, prior)
%CLASSIFY Discriminant analysis.
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP) classifies each row of the data in
%   SAMPLE into one of the groups in TRAINING.  SAMPLE and TRAINING must be
%   matrices with the same number of columns.  GROUP is a grouping variable for
%   TRAINING.  Its unique values define groups, and each element defines which
%   group the corresponding row of TRAINING belongs to.  GROUP can be a numeric
%   vector, a string array, or a cell array of strings.  TRAINING and GROUP must
%   have the same number of rows.  CLASSIFY treats NaNs or empty strings in
%   GROUP as missing values, and ignores the corresponding rows of TRAINING.
%   CLASS indicates which group each row of SAMPLE has been assigned to, and is
%   of the same type as GROUP.
%
%   [CLASS,ERR] = CLASSIFY(SAMPLE,TRAINING,GROUP) also returns an estimate of
%   the misclassification error rate.  CLASSIFY returns the apparent error rate,
%   i.e., the percentage of observations in the TRAINING that are misclassified.
%
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE) allows you to specify the type
%   of discriminant function, one of 'linear', 'quadratic', or 'mahalanobis'.
%   Linear discrimination fits a multivariate normal density to each group, with
%   a pooled estimate of covariance.  Quadratic discrimination fits MVN
%   densities with covariance estimates stratified by group.  Mahalanobis
%   discrimination uses Mahalanobis distances with stratified covariance
%   estimates.  TYPE defaults to 'linear'.
%
%   CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE,PRIOR) allows you to specify
%   prior probabilities for the groups in one of three ways.  PRIOR can be a
%   numeric vector of the same length as the number of unique values in GROUP.
%   If GROUP is numeric, the order of PRIOR must correspond to the sorted values
%   in GROUP, or, if GROUP contains strings, to the order of first occurrence of
%   the values in GROUP.  PRIOR can also be a 1-by-1 structure with fields
%   'prob', a numeric vector, and 'group', of the same type as GROUP, and
%   containing unique values indicating which groups the elements of 'prob'
%   correspond to.  As a structure, PRIOR may contain groups that do not appear
%   in GROUP.  This can be useful if TRAINING is a subset a larger training set.
%   Finally, PRIOR can also be the string value 'empirical', indicating that the
%   group prior probabilities should be estimated from the group relative
%   frequencies in TRAINING.  PRIOR defaults to a numeric vector of equal
%   probabilities, i.e., a uniform distribution.  PRIOR is not used for
%   discrimination by Mahalanobis distance, except for error rate calculation.
%
%   Examples:
%
%      % training data: two normal components
%      training = [mvnrnd([ 1  1],   eye(2), 100); ...
%                  mvnrnd([-1 -1], 2*eye(2), 100)];
%      group = [repmat(1,100,1); repmat(2,100,1)];
%      % some random sample data
%      sample = unifrnd(-5, 5, 100, 2);
%
%      % classify with a known prior, 30% prob of group 1, 70% of group 2
%      c = classify(sample, training, group, 'quad', [.3 .7]);

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.4.2 $  $Date: 2004/01/16 20:09:05 $

%   References:
%     [1] Krzanowski, W.J., Principles of Multivariate Analysis,
%         Oxford University Press, Oxford, 1988.
%     [2] Seber, G.A.F., Multivariate Observations, Wiley, New York, 1984.

if nargin < 3
    error('stats:classify:TooFewInputs','Requires at least three arguments.');
end

% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[gindex,groups] = grp2idx(group);
nans = find(isnan(gindex));
if length(nans) > 0
    training(nans,:) = [];
    gindex(nans) = [];
end
ngroups = length(groups);
gsize = hist(gindex,1:ngroups);

[n,d] = size(training);
if size(gindex,1) ~= n
    error('stats:classify:InputSizeMismatch',...
          'The length of GROUP must equal the number of rows in TRAINING.');
elseif size(sample,2) ~= d
    error('stats:classify:InputSizeMismatch',...
          'SAMPLE and TRAINING must have the same number of columns.');
end
m = size(sample,1);

if nargin < 4 | isempty(type)
    type = 1; % 'linear'
elseif ischar(type)
    i = strmatch(lower(type), strvcat('linear','quadratic','mahalanobis'));
    if length(i) > 1
        error('stats:classify:BadType','Ambiguous value for TYPE:  %s.', type);
    elseif isempty(i)
        error('stats:classify:BadType','Unknown value for TYPE:  %s.', type);
    end
    type = i;
else
    error('stats:classify:BadType','TYPE must be a string.');
end

% Default to a uniform prior
if nargin < 5 | isempty(prior)
    prior = ones(1, ngroups) / ngroups;
% Estimate prior from relative group sizes
elseif ischar(prior) & ~isempty(strmatch(lower(prior), 'empirical'))
    prior = gsize(:)' / sum(gsize);
% Explicit prior
elseif isnumeric(prior)
    if min(size(prior)) ~= 1 | max(size(prior)) ~= ngroups
        error('stats:classify:InputSizeMismatch',...
              'PRIOR must be a vector one element for each group.');
    elseif any(prior < 0)
        error('stats:classify:BadPrior',...
              'PRIOR cannot contain negative values.');
    end
    prior = prior(:)' / sum(prior); % force a normalized row vector
elseif isstruct(prior)
    [pgindex,pgroups] = grp2idx(prior.group);
    ord = repmat(NaN,1,ngroups);
    for i = 1:ngroups
        j = strmatch(groups(i), pgroups(pgindex), 'exact');
        if ~isempty(j)
            ord(i) = j;
        end
    end
    if any(isnan(ord))
        error('stats:classify:BadPrior',...
        'PRIOR.group must contain all of the unique values in GROUP.');
    end
    prior = prior.prob(ord);
    if any(prior < 0)
        error('stats:classify:BadPrior',...
              'PRIOR.prob cannot contain negative values.');
    end
    prior = prior(:)' / sum(prior); % force a normalized row vector
else
    error('stats:classify:BadType',...
        'PRIOR must be a a vector, a structure, or the string ''empirical''.');
end

% Add training data to sample for error rate estimation
if nargout > 1
    sample = [sample; training];
    mm = m+n;
else
    mm = m;
end

gmeans = repmat(NaN, ngroups, d);
for k = 1:ngroups
    gmeans(k,:) = mean(training(find(gindex == k),:),1);
end

D = repmat(NaN, mm, ngroups);
switch type
case 1 % 'linear'
    if n <= ngroups
        error('stats:classify:BadTraining',...
            'TRAINING must have more observations than the number of groups.');
    end
    % Pooled estimate of covariance
    [Q,R] = qr(training - gmeans(gindex,:), 0);
    R = R / sqrt(n - ngroups); % SigmaHat = R'*R
    s = svd(R);
    if any(s <= max(s) * eps(class(s))^(3/4))
        error('stats:classify:BadVariance',...
              'The pooled covariance matrix of TRAINING must be positive definite.');
    end

    % MVN relative log posterior density, by group, for each sample
    for k = 1:ngroups
        A = (sample - repmat(gmeans(k,:), mm, 1)) / R;
        D(:,k) = log(prior(k)) - .5*sum(A .* A, 2);
    end

case {2,3} % 'quadratic' or 'mahalanobis'
    if any(gsize <= 1)
        error('stats:classify:BadTraining',...
              'Each group in TRAINING must have at least two observations.');
    end
    for k = 1:ngroups
        % Stratified estimate of covariance
        [Q,R] = qr(training(find(gindex == k),:) - repmat(gmeans(k,:), gsize(k), 1), 0);
        R = R / sqrt(gsize(k) - 1); % SigmaHat = R'*R
        s = svd(R);
        if any(s <= max(s) * eps(class(s))^(3/4))
            error('stats:classify:BadVariance',...
                  'The covariance matrix of each group in TRAINING must be positive definite.');
        end

        A = (sample - repmat(gmeans(k,:), mm, 1)) / R;
        switch type
        case 2 % 'quadratic'
            % MVN relative log posterior density, by group, for each sample
            D(:,k) = log(prior(k)) - .5*(sum(A .* A, 2) + log(prod(diag(R))^2));
        case 3 % 'mahalanobis'
            % Negative squared Mahalanobis distance, by group, for each
            % sample.  Prior probabilities are not used
            D(:,k) = -sum(A .* A, 2);
        end
    end
end

% find nearest group to each observation in sample data
[tmp outclass] = max(D, [], 2);

% Compute apparent error rate: percentage of training data that
% are misclassified.
if nargout > 1
    trclass = outclass(m+(1:n));
    outclass = outclass(1:m);
    
    miss = trclass ~= gindex;
    e = repmat(NaN,ngroups,1);
    for k = 1:ngroups
        e(k) = sum(miss(find(gindex == k))) / gsize(k);
    end
    err = prior*e;
end

% Convert back to original grouping variable
if isnumeric(group)
    groups = str2num(char(groups));
    outclass = groups(outclass);
elseif ischar(group)
    groups = char(groups);
    outclass = groups(outclass,:);
else %if iscellstr(group)
    outclass = groups(outclass);
end
