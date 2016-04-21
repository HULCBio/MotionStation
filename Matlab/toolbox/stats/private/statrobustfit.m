function [b,stats] = statrobustfit(X,y,wfun,tune,wasnan,addconst)
%STATROBUSTFIT Calculation function for ROBUSTFIT

% Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 1.4.2.7 $  $Date: 2004/01/24 09:36:32 $

% Must check for valid function in this scope
c = class(wfun);
fnclass = class(@bisquare);
if (~isequal(c,fnclass) & ~isequal(c,'inline') ...
    & (~isequal(c,'char') | isempty(which(wfun))))
   error('stats:robustfit:BadWeight','Weight function is not valid.');
end

[n,p] = size(X);
if (addconst)
   X = [ones(n,1) X];
   p = p+1;
end
if (n<=p)
   error('stats:robustfit:NotEnoughData',...
         'Not enough points to perform robust estimation.');
end

% Find the least squares solution.
[Q,R,perm] = qr(X,0);
tol = abs(R(1)) * max(n,p) * eps(class(R));
xrank = sum(abs(diag(R)) > tol);
if xrank==p
    b(perm,:) = R \ (Q'*y);
else
    % Use only the non-degenerate parts of R and Q, but don't reduce
    % R because it is returned in stats and is expected to be of
    % full size.
    warning('stats:robustfit:RankDeficient',...
            'X is rank deficient, rank = %d',xrank);
    b(perm,:) = [R(1:xrank,1:xrank) \ (Q(:,1:xrank)'*y); zeros(p-xrank,1)];
    perm = perm(1:xrank);
end
b0 = zeros(size(b));

% Adjust residuals using leverage, as advised by DuMouchel & O'Brien
E = X(:,perm)/R(1:xrank,1:xrank);
h = min(.9999, sum((E.*E)')');
adjfactor = 1 ./ sqrt(1-h);

dfe = n-xrank;
ols_s = norm(y-X*b) / sqrt(dfe);

% Perform iteratively reweighted least squares to get coefficient estimates
D = sqrt(eps(class(X)));
iter = 0;
iterlim = 50;
wxrank = xrank;    % rank of weighted version of x
while((iter==0) | any(abs(b-b0) > D*max(abs(b),abs(b0))))
   iter = iter+1;
   if (iter>iterlim)
      warning('stats:statrobustfit:IterationLimit','Iteration limit reached.');
      break;
   end
   
   % Compute residuals from previous fit, then compute scale estimate
   r = y - X*b;
   radj = r .* adjfactor;
   s = madsigma(radj,wxrank);
   if (s==0), s=1; end
   
   % Compute new weights from these residuals, then re-fit
   w = feval(wfun, radj/(s*tune));
   b0 = b;
   [b,wxrank] = wfit(y,X,w);
end

if (nargout>1)
   % Compute robust mse according to DuMouchel & O'Brien (1989)
   r = y - X*b;
   radj = r .* adjfactor;
   mad_s = madsigma(radj,xrank);
   robust_s = robustsigma(wfun, radj, xrank, mad_s, tune, h);

   % Shrink robust value toward ols value if the robust version is
   % smaller, but never decrease it if it's larger than the ols value
   sigma = max(robust_s, ...
               sqrt((ols_s^2 * xrank^2 + robust_s^2 * n) / (xrank^2 + n)));

   % Get coefficient standard errors and related quantities
   RI = R(1:xrank,1:xrank)\eye(xrank);
   tempC = (RI * RI') * sigma^2;
   tempse = sqrt(max(eps(class(tempC)),diag(tempC)));
   C = repmat(NaN,p,p);
   se = repmat(0,p,1);
   C(perm,perm) = tempC ./ (tempse * tempse');
   se(perm) = tempse;

   % Make outputs conform with inputs
   [r,w,h,adjfactor] = statinsertnan(wasnan,r,w,h,adjfactor);
   
   % Save everything
   stats.ols_s = ols_s;
   stats.robust_s = robust_s;
   stats.mad_s = mad_s;
   stats.s = sigma;
   stats.resid = r;
   stats.rstud = r .* adjfactor / sigma;
   stats.se = se;
   stats.coeffcorr = C;
   stats.t = repmat(NaN,size(b));
   stats.t(se>0) = b(se>0) ./ se(se>0);
   stats.p = 2 * tcdf(-abs(stats.t), dfe);
   stats.w = w;
   stats.R = R;
   stats.dfe = dfe;
   stats.h = h;
end

% -----------------------------
function [b,r] = wfit(y,x,w)
%WFIT    weighted least squares fit

% Create weighted x and y
[m,n] = size(x);
sw = sqrt(w);
yw = y .* sw;
xw = x .* sw(:,ones(1,n));

% Computed weighted least squares results
[b,r] = linsolve(xw,yw,struct('RECT',true));

% -----------------------------
function s = madsigma(r,p);
%MADSIGMA    Compute sigma estimate using MAD of residuals
m = median(r);
rs = sort(abs(r-m));
if (abs(m) > rs(end))
    % Unexpectedly all residuals are very small
    rs = sort(abs(r));
end
s = median(rs(max(1,p):end)) / 0.6745;
if (s==0), s = .5*mean(rs); end

% -----------------------------
function s = robustsigma(wfun,r,p,s,t,h)
%ROBUSTSIGMA    Compute robust sigma estimate of DuMouchel & O'Brien
%   This function uses a formula from DuMouchel & O'Brien.  It is
%   based on ideas in Huber, pp. 172-175 and 195-198.

st = s*t;
n = length(r);
u = r ./ st;
phi = u .* feval(wfun,u);
delta = 0.01;
u1 = u + delta;
phi1 = u1 .* feval(wfun,u1);
dphi = (phi1 - phi) ./ delta;
m1 = mean(dphi);
m2 = mean((dphi-m1).^2);
K = 1 + (p/n) * (m2 / m1.^2);

s = (K/m1) * sqrt(sum(phi.^2 .* st^2 .* (1-h)) ./ (n-p));


% --------- weight functions

function w = andrews(r)
r = max(sqrt(eps(class(r))), abs(r));
w = (abs(r)<pi) .* sin(r) ./ r;

function w = bisquare(r)
w = (abs(r)<1) .* (1 - r.^2).^2;

function w = cauchy(r)
w = 1 ./ (1 + r.^2);

function w = fair(r)
w = 1 ./ (1 + abs(r));

function w = huber(r)
w = 1 ./ max(1, abs(r));

function w = logistic(r)
r = max(sqrt(eps(class(r))), abs(r));
w = tanh(r) ./ r;

function w = ols(r)
w = ones(size(r));

function w = talwar(r)
w = 1 * (abs(r)<1);

function w = welsch(r)
w = exp(-(r.^2));
