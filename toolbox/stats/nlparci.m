function ci = nlparci(beta,resid,J)
%NLPARCI Confidence intervals for parameters in nonlinear regression.
%   CI = NLPARCI(BETA,RESID,J) returns 95% confidence intervals CI for the
%   nonlinear least squares parameter estimates BETA.  Before calling
%   NLPARCI, use NLINFIT to fit a nonlinear regression model and get the
%   coefficient estimates BETA, residuals RESID, and Jacobian J.
%
%   The confidence interval calculation is valid for systems where 
%   the number of rows of J exceeds the length of BETA.
%
%   Example:
%      load reaction;
%      [beta,resid,J] = nlinfit(reactants,rate,@hougen,beta);
%      ci = nlparci(beta,resid,J);
%
%   See also NLINFIT, NLPREDCI, NLINTOOL.

%   References:
%      [1] Seber, G.A.F, and Wild, C.J. (1989) Nonlinear Regression, Wiley.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.2.2 $  $Date: 2004/01/16 20:09:57 $

%initialization
if nargin < 3
   error('stats:nlparci:TooFewInputs','Requires three inputs.');
end;

resid = resid(:);
missing = find(isnan(resid) & all(isnan(J),2));
if ~isempty(missing)
    resid(missing) = [];
    J(missing,:) = [];
end
[m,n] = size(J);
if m <= n
   error('stats:nlparci:NotEnoughData',...
         'The number of observations must exceed the number of parameters.');
end;

if length(beta) ~= n
   error('stats:nlparci:InputSizeMismatch',...
         'The length of beta must equal the number of columns in J.')
end

% approximation when a column is zero vector
temp = find(max(abs(J)) == 0);
if ~isempty(temp)
   J(temp,:) = J(temp,:) + sqrt(eps(class(J)));
end;

%calculate covariance
[Q R] = qr(J,0);
Rinv = R\eye(size(R));
diag_info = sum((Rinv.*Rinv)')';

v = m-n;
rmse = sqrt(sum(resid.*resid)/v);

% calculate confidence interval
delta = sqrt(diag_info) .* rmse*tinv(0.975,v);
ci = [(beta(:) - delta) (beta(:) + delta)];

%--end of nlparci.m---

