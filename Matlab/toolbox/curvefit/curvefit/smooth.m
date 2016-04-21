function [c,ww] = smooth(varargin)
%SMOOTH  Smooth data.
%   Z = SMOOTH(Y) smooths data Y using a 5-point moving average.
%
%   Z = SMOOTH(Y,SPAN) smooths data Y using SPAN as the number of points used
%   to compute each element of Z.
%
%   Z = SMOOTH(Y,SPAN,METHOD) smooths data Y with specified METHOD. The
%   available methods are:
%
%           'moving'   - Moving average (default)
%           'lowess'   - Lowess (linear fit)
%           'loess'    - Loess (quadratic fit)
%           'sgolay'   - Savitzky-Golay
%           'rlowess'  - Robust Lowess (linear fit)
%           'rloess'   - Robust Loess (quadratic fit)
%
%   Z = SMOOTH(Y,METHOD) uses the default SPAN 5.
%
%   Z = SMOOTH(Y,SPAN,'sgolay',DEGREE) and Z = SMOOTH(Y,'sgolay',DEGREE)
%   additionally specify the degree of the polynomial to be used in the
%   Savitzky-Golay method. The default DEGREE is 2. DEGREE must be smaller
%   than SPAN.
%
%   Z = SMOOTH(X,Y,...) additionally specifies the X coordinates.  If X is
%   not provided, methods that require X coordinates assume X = 1:N, where
%   N is the length of Y.
%
%   Notes:
%   1. When X is given and X is not uniformly distributed, the default method
%   is 'lowess'.  The 'moving' method is not recommended.
%
%   2. For the 'moving' and 'sgolay' methods, SPAN must be odd.
%   If an even SPAN is specified, it is reduced by 1.
%
%   3. If SPAN is greater than the length of Y, it is reduced to the
%   length of Y.
%
%   4. In the case of (robust) lowess and (robust) loess, it is also
%   possible to specify the SPAN as a percentage of the total number
%   of data points. When SPAN is less than or equal to 1, it is
%   treated as a percentage.
%
%   For example:
%
%   Z = SMOOTH(Y) uses the moving average method with span 5 and
%   X=1:length(Y).
%
%   Z = SMOOTH(Y,7) uses the moving average method with span 7 and
%   X=1:length(Y).
%
%   Z = SMOOTH(Y,'sgolay') uses the Savitzky-Golay method with DEGREE=2,
%   SPAN = 5, X = 1:length(Y).
%
%   Z = SMOOTH(X,Y,'lowess') uses the lowess method with SPAN=5.
%
%   Z = SMOOTH(X,Y,SPAN,'rloess') uses the robust loess method.
%
%   Z = SMOOTH(X,Y) where X is unevenly distributed uses the
%   'lowess' method with span 5.
%
%   Z = SMOOTH(X,Y,8,'sgolay') uses the Savitzky-Golay method with
%   span 7 (8 is reduced by 1 to make it odd).
%
%   Z = SMOOTH(X,Y,0.3,'loess') uses the loess method where span is
%   30% of the data, i.e. span = ceil(0.3*length(Y)).
%
%   See also SPLINE.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.17.4.5 $  $Date: 2004/02/01 21:43:43 $

if nargin < 1
    error('curvefit:smooth:needMoreArgs', ...
        'SMOOTH needs at least one argument.');
end

if nargout > 1 % Called from the GUI cftool
    ws = warning('off', 'all'); % turn warning off and record the previous warning state.
    lw = lastwarn;
    lastwarn('');
else
    ws = warning('query','all'); % Leave warning state alone but save it so resets are no-ops.
end

% is x given as the first argument?
if nargin==1 || ( nargin > 1 && (length(varargin{2})==1 || ischar(varargin{2})) )
    % smooth(Y) | smooth(Y,span,...) | smooth(Y,method,...)
    is_x = 0; % x is not given
    y = varargin{1};
    y = y(:);
    x = (1:length(y))';
else % smooth(X,Y,...)
    is_x = 1;
    y = varargin{2};
    x = varargin{1};
    y = y(:);
    x = x(:);
end

% is span given?
span = [];
if nargin == 1+is_x || ischar(varargin{2+is_x})
    % smooth(Y), smooth(X,Y) || smooth(X,Y,method,..), smooth(Y,method)
    is_span = 0;
else
    % smooth(...,SPAN,...)
    is_span = 1;
    span = varargin{2+is_x};
end

% is method given?
method = [];
if nargin >= 2+is_x+is_span
    % smooth(...,Y,method,...) | smooth(...,Y,span,method,...)
    method = varargin{2+is_x+is_span};
end

if isempty(method)
    if abs(diff(diff(x))<eps)
        method = 'moving'; % uniformly distributed X.
    else
        method = 'lowess';
    end
end

t = length(y);
if length(x) ~= t
    warning(ws); % reset warn state before erroring
    error('curvefit:smooth:XYmustBeSameLength',...
        'X and Y must be the same length.');
end

% realize span
if span <= 0
    warning(ws); % reset warn state before erroring
    error('curvefit:smooth:spanMustBePositive', ...
        'SPAN must be positive.');
end
if span < 1, span = ceil(span*t); end % percent convention
if isempty(span), span = 5; end % smooth(Y,[],method)

idx = 1:t;

sortx = any(diff(isnan(x))<0);   % if NaNs not all at end
if sortx || any(diff(x)<0) % sort x
    [x,idx] = sort(x);
    y = y(idx);
end

c = repmat(NaN,size(y));
ok = ~isnan(x);
switch method
    case 'moving'
        c(ok) = moving(x(ok),y(ok),span);
    case {'lowess','loess','rlowess','rloess'}
        robust = 0;
        iter = 5;
        if method(1)=='r'
            robust = 1;
            method = method(2:end);
            if nargin >= 3+is_x+is_span
                iter = varargin{3+is_x+is_span};
            end
        end
        c(ok) = lowess(x(ok),y(ok),span, method,robust,iter,ws);
    case 'sgolay'
        if nargin >= 3+is_x+is_span
            degree = varargin{3+is_x+is_span};
        else
            degree = 2;
        end
        if degree < 0 || degree ~= floor(degree) || degree >= span
            warning(ws); % reset warn state before erroring
            error('curvefit:smooth:invalidDegree', ...
                'Degree must be an integer between 0 and span-1.');
        end
        c(ok) = sgolay(x(ok),y(ok),span,degree,ws);
    otherwise
        warning(ws); % reset warn state before erroring
        error('curvefit:smooth:unrecognizedMethod', ...
            'SMOOTH: Unrecognized method.');
end

c(idx) = c;

if nargout > 1
    ww = lastwarn;
    lastwarn(lw);
    warning(ws);  % turn warning back to the previous state.
end

%--------------------------------------------------------------------
function c = moving(x,y, span)
% moving average of the data.

ynan = isnan(y);
span = floor(span);
n = length(y);
span = min(span,n);
width = span-1+mod(span,2); % force it to be odd
xreps = any(diff(x)==0);
if width==1 && ~xreps && ~any(ynan), c = y; return; end
if ~xreps && ~any(ynan)
    % simplest method for most common case
    c = filter(ones(width,1)/width,1,y);
    cbegin = cumsum(y(1:width-2));
    cbegin = cbegin(1:2:end)./(1:2:(width-2))';
    cend = cumsum(y(n:-1:n-width+3));
    cend = cend(end:-2:1)./(width-2:-2:1)';
    c = [cbegin;c(width:end);cend];
elseif ~xreps
    % with no x repeats, can take ratio of two smoothed sequences
    c = repmat(NaN,n,1);
    yy = y;
    yy(ynan) = 0;
    nn = double(~ynan);
    ynum = moving(x,yy,span);
    yden = moving(x,nn,span);
    c = ynum ./ yden;
else
    % with some x repeats, loop
    notnan = ~ynan;
    yy = y;
    yy(ynan) = 0;
    c = zeros(n,1);
    for i=1:n
        if i>1 && x(i)==x(i-1)
            c(i) = c(i-1);
            continue;
        end
        R = i;                                 % find rightmost value with same x
        while(R<n && x(R+1)==x(R))
            R = R+1;
        end
        hf = ceil(max(0,(span - (R-i+1))/2));  % need this many more on each side
        hf = min(min(hf,(i-1)), (n-R));
        L = i-hf;                              % find leftmost point needed
        while(L>1 && x(L)==x(L-1))
            L = L-1;
        end
        R = R+hf;                              % find rightmost point needed
        while(R<n && x(R)==x(R+1))
            R = R+1;
        end
        c(i) = sum(yy(L:R)) / sum(notnan(L:R));
    end
end

%--------------------------------------------------------------------
function c = lowess(x,y, span, method, robust, iter, ws)
% LOWESS  Smooth data using Lowess or Loess method.
%
% The difference between LOWESS and LOESS is that LOWESS uses a
% linear model to do the local fitting whereas LOESS uses a
% quadratic model to do the local fitting. Some other software
% may not have LOWESS, instead, they use LOESS with order 1 or 2 to
% represent these two smoothing method.
% Reference: "Trimmed resistant weighted scatterplot smooth" by
% Matthew C Hutcheson.

n = length(y);
span = floor(span);
span = min(span,n);
if span <= 0
    warning(ws); % reset warn state before erroring
    error('curvefit:smooth:invalidSpan',...
        'Span must be an integer between 1 and length of x.');
end
if span == 1, c = y; return; end

c = zeros(size(y));

% pre-allocate space for lower and upper indices for each fit
lbound = [];
rbound = [];
dmaxv = [];
if robust
    lbound = zeros(n,1);
    rbound = zeros(n,1);
    dmaxv = zeros(n,1);
end

useLoess = false;
if isequal(method,'loess')
    useLoess = true;
end

% Turn off warnings when called from command line (already off if called from
% cftool).
ws = warning('off', 'all'); % save warning state
[lastwarnmsg,lastwarnid]=lastwarn;  % save last warning

ynan = isnan(y);
anyNans = any(ynan(:));
seps = sqrt(eps);
theDiffs = [1; diff(x);1];

for i=1:n
    % if x(i) and x(i-1) are equal we just use the old value.
    if theDiffs(i) == 0
        c(i) = c(i-1);
        if robust
            lbound(i) = lbound(i-1);
            rbound(i) = rbound(i-1);
            dmaxv(i) = dmaxv(i-1);
        end
        continue;
    end
    % calculate how far we have to look on either side
    left = max(1,i-span+1);
    right = min(n,i+span-1);
    % now see if we have any equal values that we need to take into account
    while left > 0 && theDiffs(left) == 0
        left = left-1;
    end
    while right <= n && theDiffs(right+1) == 0
        right = right+1;
    end

    mx = x(i);       % center around current point to improve conditioning
    % look at the span interval around x(i)
    d = abs(x(left:right)-mx);
    [dsort,idx] = sort(d);
    idx = idx +left-1;  % add back left value

    if anyNans
        idx = idx(dsort<=dsort(span) & ~ynan(idx));
    else
        idx = idx(dsort<=dsort(span));
    end

    if isempty(idx)
        c(i) = NaN;
        continue
    end
    x1 = x(idx)-mx;
    y1 = y(idx);
    dsort = d(idx-left+1);
    dmax = dsort(end);
    if dmax==0, dmax = 1; end
    if robust
        lbound(i) = min(idx);
        rbound(i) = max(idx);
        dmaxv(i) = dmax;
    end

    weight = (1 - (dsort/dmax).^3).^1.5; % tri-cubic weight
    if all(weight<seps)
        weight(:) = 1;    % if all weights are 0, just skip weighting
    end

    v = [ones(size(x1)) x1];
    if useLoess
        v = [v x1.*x1];
    end

    v = weight(:,ones(1,size(v,2))).*v;
    y1 = weight.*y1;
    if size(v,1)==size(v,2)
        % Square v may give infs in the \ solution, so force least squares
        b = [v;zeros(1,size(v,2))]\[y1;0];
    else
        b = v\y1;
    end
    c(i) = b(1);
end

% now that we have a non-robust fit, we can compute the residual and do
% the robust fit if required
maxabsyXeps = max(abs(y))*eps;
if robust
    for k = 1:iter
        r = y-c;
        for i=1:n
            if i>1 && x(i)==x(i-1)
                c(i) = c(i-1);
                continue;
            end
            if isnan(c(i)), continue; end
            idx = lbound(i):rbound(i);
            if anyNans
                idx = idx(~ynan(idx));
            end
            x1 = x(idx);
            mx = x(i);
            x1 = x1-mx;
            dsort = abs(x1);
            y1 = y(idx);
            r1 = r(idx);

            weight = (1 - (dsort/dmaxv(i)).^3).^1.5; % tri-cubic weight
            if all(weight<seps)
                weight(:) = 1;    % if all weights 0, just skip weighting
            end

            v = [ones(size(x1)) x1];
            if useLoess
                v = [v x1.*x1];
            end
            r1 = abs(r1-median(r1));
            mad = median(r1);
            if mad > maxabsyXeps
                rweight = r1./(6*mad);
                id = (rweight<=1);
                rweight(~id) = 0;
                rweight(id) = (1-rweight(id).*rweight(id));
                weight = weight.*rweight;
            end
            v = weight(:,ones(1,size(v,2))).*v;
            y1 = weight.*y1;
            if size(v,1)==size(v,2)
                % Square v may give infs in the \ solution, so force least squares
                b = [v;zeros(1,size(v,2))]\[y1;0];
            else
                b = v\y1;
            end
            c(i) = b(1);
        end
    end
end

lastwarn(lastwarnmsg,lastwarnid);
warning(ws);



%--------------------------------------------------------------------
function c=sgolay(x,y,f,k,ws)
% savitziki-golay smooth
% (x,y) are given data. f is the frame length to be taken, should
% be an odd number. k is the degree of polynomial filter. It should
% be less than f.

% Reference: Orfanidis, S.J., Introduction to Signal Processing,
% Prentice-Hall, Englewood Cliffs, NJ, 1996.

if k < 0 || floor(k) ~= k
    warning(ws); % reset warn state before erroring
    error('curvefit:smooth:degreeMustNonNeg', ...
        'Degree must be a non-negative integer.');
end
n = length(x);
f = floor(f);
f = min(f,n);
f = f-mod(f-1,2); % will substract 1 if frame is even.
diffx = diff(x);
notnan = ~isnan(y);
nomissing = all(notnan);
if f <= k && all(diffx>0) && nomissing, c = y; return; end
hf = (f-1)/2; % half frame length

idx = 1:n;
if any(diffx<0) % make sure x is monotonically increasing
    [x,idx]=sort(x);
    y = y(idx);
    notnan = notnan(idx);
    diffx = diff(x);
end
% note that x is sorted so max(abs(x)) must be abs(x(1)) or abs(x(end));
% already calculated diffx for monotonic case, so use it again. Only
% recalculate if we sort x.
% if all( abs(diff(diff(x))) <= eps*max(abs(x)) ) && nomissing
if nomissing && all(abs(diff(diffx)) <= eps*max(abs([x(1),x(end)])));
    v = ones(f,k+1);
    t=(-hf:hf)';
    for i=1:k
        v(:,i+1)=t.^i;
    end
    [q,r]=qr(v,0);
    ymid = filter(q*q(hf+1,:)',1,y);
    ybegin = q(1:hf,:)*q'*y(1:f);
    yend = q((hf+2):end,:)*q'*y(n-f+1:n);
    c = [ybegin;ymid(f:end);yend];
    return;
end

% non-uniformly distributed data
c = y;

% Turn off warnings when called from command line (already off if called from
% cftool).
ws = warning('off', 'all');
[lastwarnmsg,lastwarnid]=lastwarn;

for i = 1:n
    if i>1 && x(i)==x(i-1)
        c(i) = c(i-1);
        continue
    end
    L = i; R = i;                          % find leftmost and rightmost values
    while(R<n && x(R+1)==x(i))
        R = R+1;
    end
    while(L>1 && x(L-1)==x(i))
        L = L-1;
    end
    HF = ceil(max(0,(f - (R-L+1))/2));     % need this many more on each side

    L = min(n-f+1,max(1,L-HF));            % find leftmost point needed
    while(L>1 && x(L)==x(L-1))
        L = L-1;
    end
    R = min(n,max(R+HF,L+f-1));            % find rightmost point needed
    while(R<n && x(R)==x(R+1))
        R = R+1;
    end

    tidx = L:R;
    tidx = tidx(notnan(tidx));
    if isempty(tidx)
        c(i) = NaN;
        continue;
    end
    q = x(tidx) - x(i);   % center to improve conditioning
    vrank = 1 + sum(diff(q)>0);
    ncols = min(k+1, vrank);
    v = ones(length(q),ncols);
    for j = 1:ncols-1
        v(:,j+1) = q.^j;
    end
    if size(v,1)==size(v,2)
        % Square v may give infs in the \ solution, so force least squares
        d = [v;zeros(1,size(v,2))]\[y(tidx);0];
    else
        d = v\y(tidx);
    end
    c(i) = d(1);
end
c(idx) = c;

lastwarn(lastwarnmsg,lastwarnid);
warning(ws);

