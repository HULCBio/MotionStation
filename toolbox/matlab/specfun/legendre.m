function y = legendre(n,x,normalize)
%LEGENDRE Associated Legendre function.
%   P = LEGENDRE(N,X) computes the associated Legendre functions 
%   of degree N and order M = 0, 1, ..., N, evaluated for each element
%   of X.  N must be a scalar integer and X must contain real values
%   between -1 <= X <= 1.  
%
%   If X is a vector, P is an (N+1)-by-L matrix, where L = length(X).
%   The P(M+1,i) entry corresponds to the associated Legendre function 
%   of degree N and order M evaluated at X(i). 
%
%   In general, the returned array has one more dimension than X.
%   Each element P(M+1,i,j,k,...) contains the associated Legendre
%   function of degree N and order M evaluated at X(i,j,k,...).
%
%   There are three possible normalizations, LEGENDRE(N,X,normalize)
%   where normalize is 'unnorm','sch' or 'norm'.
%
%   The default, unnormalized associated Legendre functions are:
% 
%       P(N,M;X) = (-1)^M * (1-X^2)^(M/2) * (d/dX)^M { P(N,X) },
%
%   where P(N,X) is the Legendre polynomial of degree N. Note that
%   the first row of P is the Legendre polynomial evaluated at X 
%   (the M == 0 case).
%
%   SP = LEGENDRE(N,X,'sch') computes the Schmidt semi-normalized
%   associated Legendre functions SP(N,M;X). These functions are 
%   related to the unnormalized associated Legendre functions 
%   P(N,M;X) by:
%               
%   SP(N,M;X) = P(N,X), M = 0
%             = (-1)^M * sqrt(2*(N-M)!/(N+M)!) * P(N,M;X), M > 0
%
%   NP = LEGENDRE(N,X,'norm') computes the fully-normalized
%   associated Legendre functions NP(N,M;X). These functions are 
%   normalized such that
%
%            /1
%           |
%           | [NP(N,M;X)]^2 dX = 1    ,
%           |
%           /-1
%
%   and are related to the unnormalized associated Legendre
%   functions P(N,M;X) by:
%               
%   NP(N,M;X) = (-1)^M * sqrt((N+1/2)*(N-M)!/(N+M)!) * P(N,M;X)
%
%   Examples: 
%     1. legendre(2, 0.0:0.1:0.2) returns the matrix:
% 
%              |    x = 0           x = 0.1         x = 0.2
%        ------|---------------------------------------------
%        m = 0 |   -0.5000         -0.4850         -0.4400
%        m = 1 |         0         -0.2985         -0.5879
%        m = 2 |    3.0000          2.9700          2.8800  
%
%     2. X = rand(2,4,5); N = 2; 
%        P = legendre(N,X); 
%
%     so that size(P) is 3x2x4x5 and 
%     P(:,1,2,3) is the same as legendre(N,X(1,2,3)). 

%   Acknowledgment:
%
%   This program is based on a Fortran program by Robert L. Parker,
%   Scripps Institution of Oceanography, Institute for Geophysics and 
%   Planetary Physics, UCSD. February 1993.
%
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.22.4.3 $  $Date: 2004/03/02 21:48:37 $
%
%   Reference:
%     [1] M. Abramowitz and I.A. Stegun, "Handbook of Mathematical
%         Functions", Dover Publications, 1965, Ch. 8.
%     [2] J. A. Jacobs, "Geomagnetism", Academic Press, 1987, Ch.4.
%
%   Note on Algorithm:
%
%   LEGENDRE uses a three-term backward recursion relationship in M.
%   This recursion is on a version of the Schmidt semi-normalized 
%   Associated Legendre functions SPc(n,m;x), which are complex 
%   spherical harmonics. These functions are related to the standard 
%   Abramowitz & Stegun functions P(n,m;x) by
%
%       P(n,m;x) = sqrt((n+m)!/(n-m)!) * SPc(n,m;x)
%   
%   They are related to the Schmidt form given previously by:
%
%       SP(n,m;x) = SPc(n,0;x), m = 0
%                 = (-1)^m * sqrt(2) * SPc(n,m;x), m > 0

if nargin < 2
    error('Not enough input arguments')
elseif nargin > 5
    error('Too many input arguments')    
end

if numel(n) > 1 || ~isreal(n) || n < 0 || n ~= round(n)
    error('N must be a positive scalar integer');
end

if ~isreal(x) | max(abs(x)) > 1 | ischar(x)
    error('X must be real and in the range (-1,1)')
end

% The n = 0 case
if n == 0 
    y = ones(size(x));
    if nargin > 2 && strcmp(normalize,'norm')
        y = y/sqrt(2);
    end
    return
end

% Convert x to a single row vector
sizex = size(x); 
x = x(:)';

rootn = sqrt(0:2*n);
s = sqrt(1-x.^2);
P = zeros(n+3,length(x));

% Calculate TWOCOT, separating out the x = -1,+1 cases first
twocot = x;

% Evaluate x = +/-1 first to avoid error messages for division by zero
k = find(x==-1);
twocot(k) = Inf;

k = find(x==1);
twocot(k) = -Inf;

k = find(s);
twocot(k) = -2*x(k)./s(k);

% Find values of x,s for which there will be underflow

sn = (-s).^n;
tol = sqrt(realmin);
ind = find(s>0 & abs(sn)<=tol);
if ~isempty(ind)
    % Approx solution of x*ln(x) = y 
    v = 9.2-log(tol)./(n*s(ind));
    w = 1./log(v);
    m1 = 1+n*s(ind).*v.*w.*(1.0058+ w.*(3.819 - w*12.173));
    m1 = min(n, floor(m1));

    % Column-by-column recursion
    for k = 1:length(m1)
        mm1 = m1(k);
        col = ind(k);
        P(mm1:n+1,col) = zeros(size(mm1:n+1))';

        % Start recursion with proper sign
        tstart = eps;
        P(mm1,col) = sign(rem(mm1,2)-0.5)*tstart;
        if x(col) < 0
            P(mm1,col) = sign(rem(n+1,2)-0.5)*tstart;
        end

        % Recur from m1 to m = 0, accumulating normalizing factor.
        sumsq = tol;
        for m = mm1-2:-1:0
            P(m+1,col) = ((m+1)*twocot(col)*P(m+2,col)- ...
                  rootn(n+m+3)*rootn(n-m)*P(m+3,col))/ ...
                  (rootn(n+m+2)*rootn(n-m+1));
            sumsq = P(m+1,col)^2 + sumsq;
        end
        scale = 1/sqrt(2*sumsq - P(1,col)^2);
        P(1:mm1+1,col) = scale*P(1:mm1+1,col);
    end     % FOR loop
end % small sine IF loop

% Find the values of x,s for which there is no underflow, and for
% which twocot is not infinite (x~=1).

nind = find(x~=1 & abs(sn)>=tol);
if ~isempty(nind)

    % Produce normalization constant for the m = n function
    d = 2:2:2*n;
    c = prod(1-1./d);

    % Use sn = (-s).^n (written above) to write the m = n function
    P(n+1,nind) = sqrt(c)*sn(nind);
    P(n,nind) = P(n+1,nind).*twocot(nind)*n./rootn(end);

    % Recur downwards to m = 0
    for m = n-2:-1:0
        P(m+1,nind) = (P(m+2,nind).*twocot(nind)*(m+1) ...
            -P(m+3,nind)*rootn(n+m+3)*rootn(n-m))/ ...
            (rootn(n+m+2)*rootn(n-m+1));
    end
end % IF loop

y = P(1:n+1,:);

% Polar argument   (x = +-1)
s0 = find(s == 0);
y(1,s0) = x(s0).^n;

if nargin < 3 || strcmp(normalize,'unnorm')
    % Calculate the standard A&S functions (i.e., unnormalized) by
    % multiplying each row by: sqrt((n+m)!/(n-m)!) = sqrt(prod(n-m+1:n+m))
    for m = 1:n-1
        y(m+1,:) = prod(rootn(n-m+2:n+m+1))*y(m+1,:);
    end
    % Last row (m = n) must be done separately to handle 0!.
    % NOTE: the coefficient for (m = n) overflows for n>150.
    y(n+1,:) = prod(rootn(2:end))*y(n+1,:);
elseif strcmp(normalize,'sch')
    % Calculate the standard Schmidt semi-normalized functions.
    % For m = 1,...,n, multiply by (-1)^m*sqrt(2)
    row1 = y(1,:);
    y = sqrt(2)*y;
    y(1,:) = row1;    % restore first row
    const1 = 1;
    for r = 2:n+1
        const1 = -const1;
        y(r,:) = const1*y(r,:);
    end
elseif strcmp(normalize,'norm')
    % Calculate the fully-normalized functions.
    % For m = 0,...,n, multiply by (-1)^m*sqrt(n+1/2)
    y = sqrt(n+1/2)*y;
    const1 = -1;
    for r = 1:n+1
        const1 = -const1;
        y(r,:) = const1*y(r,:);
    end 
else
    error(['Normalization option ''' normalize ''' not recognized'])
end

% Restore original dimensions.
if length(sizex) > 2 || min(sizex) > 1
    y = reshape(y,[n+1 sizex]);
end