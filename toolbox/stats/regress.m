function [b,bint,r,rint,stats] = regress(y,X,alpha)
%REGRESS Multiple linear regression using least squares.
%   B = REGRESS(Y,X) returns the vector B of regression coefficients in the
%   linear model Y = X*B.  X is an n-by-p design matrix, with rows
%   corresponding to observations and columns to predictor variables.  Y is
%   an n-by-1 vector of response observations.
%
%   [B,BINT] = REGRESS(Y,X) returns a matrix BINT of 95% confidence
%   intervals for B.
%
%   [B,BINT,R] = REGRESS(Y,X) returns a vector R of residuals.
%
%   [B,BINT,R,RINT] = REGRESS(Y,X) returns a matrix RINT of intervals that
%   can be used to diagnose outliers.  If RINT(i,:) does not contain zero,
%   then the i-th residual is larger than would be expected, at the 5%
%   significance level.  This is evidence that the I-th observation is an
%   outlier.
%
%   [B,BINT,R,RINT,STATS] = REGRESS(Y,X) returns a vector STATS containing
%   the R-square statistic, the F statistic and p value for the full model,
%   and an estimate of the error variance.
%
%   [...] = REGRESS(Y,X,ALPHA) uses a 100*(1-ALPHA)% confidence level to
%   compute BINT, and a (100*ALPHA)% significance level to compute RINT.
%
%   X should include a column of ones so that the model contains a constant
%   term.  The F statistic and p value are computed under the assumption
%   that the model contains a constant term, and they are not correct for
%   models without a constant.  The R-square value is the ratio of the
%   regression sum of squares to the total sum of squares.
%
%   If columns of X are linearly dependent, REGRESS sets the maximum
%   possible number of elements of B to zero to obtain a "basic solution",
%   and returns zeros in elements of BINT corresponding to the zero
%   elements of B.
%
%   REGRESS treats NaNs in X or Y as missing values, and removes them.
%
%   See also LSCOV, POLYFIT, REGSTATS, ROBUSTFIT, STEPWISE.

%   References:
%      [1] Chatterjee, S. and A.S. Hadi (1986) "Influential Observations,
%          High Leverage Points, and Outliers in Linear Regression",
%          Statistical Science 1(3):379-416.
%      [2] Draper N. and H. Smith (1981) Applied Regression Analysis, 2nd
%          ed., Wiley.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.13.2.3 $  $Date: 2004/01/16 20:10:25 $

if  nargin < 2
    error('stats:regress:TooFewInputs', ...
          'REGRESS requires at least two input arguments.');
elseif nargin == 2
    alpha = 0.05;
end

% Check that matrix (X) and left hand side (y) have compatible dimensions
[n,ncolX] = size(X);
if ~isvector(y)
    error('stats:regress:InvalidData', 'Y must be a vector.');
elseif numel(y) ~= n
    error('stats:regress:InvalidData', ...
          'The number of rows in Y must equal the number of rows in X.');
end

% Remove missing values, if any
wasnan = (isnan(y) | any(isnan(X),2));
havenans = any(wasnan);
if havenans
   y(wasnan) = [];
   X(wasnan,:) = [];
   n = length(y);
end

% Use the rank-revealing QR to remove dependent columns of X.
[Q,R,perm] = qr(X,0);
p = sum(abs(diag(R)) > max(n,ncolX)*eps(abs(R(1))));
if p < ncolX
    warning('stats:regress:RankDefDesignMat', ...
            'X is rank deficient to within machine precision.');
    R = R(1:p,1:p);
    Q = Q(:,1:p);
    perm = perm(1:p);
end

% Compute the LS coefficients, filling in zeros in elements corresponding
% to rows of X that were thrown out.
b = zeros(ncolX,1);
b(perm) = R \ (Q'*y);

if nargout >= 2
    % Find a confidence interval for each component of x
    % Draper and Smith, equation 2.6.15, page 94
    RI = R\eye(p);
    nu = max(0,n-p);                % Residual degrees of freedom
    yhat = X*b;                     % Predicted responses at each data point.
    r = y-yhat;                     % Residuals.
    if nu ~= 0
        rmse = norm(r)/sqrt(nu);    % Root mean square error.
        tval = tinv((1-alpha/2),nu);
    else
        rmse = NaN;
        tval = 0;
    end
    s2 = rmse^2;                    % Estimator of error variance.
    se = zeros(ncolX,1);
    se(perm,:) = rmse*sqrt(sum((RI .* RI)',1))';
    bint = [b-tval*se, b+tval*se];

    % Find the standard errors of the residuals.
    % Get the diagonal elements of the "Hat" matrix.
    % Calculate the variance estimate obtained by removing each case (i.e. sigmai)
    % see Chatterjee and Hadi p. 380 equation 14.
    if nargout >= 4
        T = X(:,perm)*RI;
        hatdiag = sum(T .* T,2);
        ok = ((1-hatdiag) > sqrt(eps(class(hatdiag))));
        hatdiag(~ok) = 1;
        if nu > 1
            denom = (nu-1) .* (1-hatdiag);
            sigmai = zeros(length(denom),1);
            sigmai(ok) = sqrt(max(0,(nu*s2/(nu-1)) - (r(ok) .^2 ./ denom(ok))));
            ser = sqrt(1-hatdiag) .* sigmai;
            ser(~ok) = Inf;
        elseif nu == 1
            ser = sqrt(1-hatdiag) .* rmse;
            ser(~ok) = Inf;
        else % if nu == 0
            ser = rmse*ones(length(y),1); % == Inf
        end

        % Create confidence intervals for residuals.
        rint = [(r-tval*ser) (r+tval*ser)];
    end

    % Calculate R-squared and the other statistics.
    if nargout == 5
        % There are several ways to compute R^2, all equivalent when X has
        % a constant term, but not equivalent when X doesn't.  This version
        % remains between 0 and 1 regardless.
        RSS = norm(yhat-mean(y))^2;  % Regression sum of squares.
        TSS = norm(y-mean(y))^2;     % Total sum of squares.
        r2 = RSS/TSS;                % R-square statistic.
        if p > 1
            F = (RSS/(p-1))/s2;      % F statistic for regression
        else
            F = NaN;
        end
        prob = 1 - fcdf(F,p-1,nu);   % Significance probability for regression
        stats = [r2 F prob s2];

        % All that requires a constant.  Do we have one?
        if ~any(all(X==1,1))
            % Apparently not, but look for an implied constant.
            b0 = R\(Q'*ones(n,1));
            if (sum(abs(1-X(:,perm)*b0))>n*sqrt(eps(class(X))))
                warning('stats:regress:NoConst',...
                        ['R-square and the F statistic are not well-defined' ...
                         ' unless X has a column of ones.\nType "help' ...
                         ' regress" for more information.']);
            end
        end
    end

    % Restore NaN so inputs and outputs conform
    if havenans
        if nargout >= 3
            tmp = repmat(NaN,length(wasnan),1);
            tmp(~wasnan) = r;
            r = tmp;
            if nargout >= 4
                tmp = repmat(NaN,length(wasnan),2);
                tmp(~wasnan,:) = rint;
                rint = tmp;
            end
        end
    end

end % nargout >= 2
