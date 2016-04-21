function Q = marcumq(varargin)
%MARCUMQ Generalized Marcum Q function.
%   MARCUMQ(A,B,M) is the generalized Marcum Q function,
%   defined as
%
%      Q_m(a,b) = 1/a^(m-1) * integral from b to inf of
%                 [x^m * exp(-(x^2+a^2)/2) * I_(m-1)(ax)] dx.
%
%   a,b and m must be real and nonnegative.  m must be an integer.
%
%   MARCUMQ(A,B) is the special case for M=1, originally tabulated
%   by Marcum and often written without the subscript, Q(a,b).
%
%   See also BESSELI.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/12 23:00:47 $

%   References:
%     [1] J. I. Marcum, "A Statistical Theory of Target Detection
%         by Pulsed Radar:  Mathematical Appendix", RAND Corporation,
%         Santa Monica, CA, Research Memorandum RM-753, 1 July 1948.
%         Reprinted in IRE Transactions on Information Theory, 
%         vol. IT-6, pp. 59-267, April 1960.
%     [2] W. F. McGee, "Another Recursive Method of Computing the Q
%         Function", IEEE Transactions on Information Theory,
%         vol. IT-16, pp. 500-501, July 1970.
%     [3] P. E. Cantrell and A. K. Ojha, "Comparison of Generalized
%         Q-Function Algorithms", IEEE Transactions on Information 
%         Theory, vol. IT-33, pp. 591-596, July 1987.

if nargin<2, error('Not enough input arguments.'); end
if nargin==2, a = varargin{1}; b = varargin{2}; m=1; end
if nargin==3, a = varargin{1}; b = varargin{2}; m=varargin{3}; end
if nargin>3, error('Too many input arguments.'); end

if (any(~isreal(a))|any(~isreal(b))|any(~isreal(m)))
    error('Arguments must be real.');
end

if (any(a<0)|any(b<0))
    error('Arguments must be nonnegative.');
end

if (length(a)==1)
    a = repmat(a,size(b));
elseif (length(b)==1)
    b = repmat(b,size(a));
elseif (~isequal(size(a),size(b)))
    error('Dimensions of first two arguments do not match.')
end

if (length(m)~=1)
    error('Third argument must be a scalar.')
end

if (m<1)
    error('Third argument must be positive.')
end

if ((m/floor(m))~=1)
    error('Third argument must be an integer.')
end

Q = repmat(NaN, size(a));
if(m==1)
    Q(a~=Inf & b==0) = 1;
    Q(a~=Inf & b==Inf) = 0;
    Q(a==Inf & b~=Inf) = 1;
    z = (isnan(Q) & a==0 & b~=Inf);
    if (any(z))
        Q(z) = exp((-b(z).^2)./2);
    end
end

z = isnan(Q) & ~isnan(a) & ~isnan(b);
if (any(z(:)))
    aa = (a(z).^2)./2;
    bb = (b(z).^2)./2;
    d = exp(-aa);
    h = d;
    f = (bb.^m).*exp(-bb)./factorial(m);
    f_err = exp(-bb);
    errbnd = 1-f_err;
    k = 1;
    delta = f .* h;
    sum = delta;
    j = (errbnd > 4*eps) & ((1-sum)>8*eps);
    while (any(j)|(k<=m))
        d = aa.*d/k;
        h = h + d;
        f = bb.*f/(k+m);
        delta = f .* h;
        sum(j) = sum(j) + delta(j);
        f_err = f_err.*bb/k;
        errbnd = errbnd - f_err;
        j = (errbnd > 4*eps) & ((1-sum)>8*eps);
        k = k + 1;
        if(k>100000)
            j = j & (delta > eps*(1-sum));
        end
    end
    if(k>100000)
        warning('comm:marcumq:noConvergence', ...
                'The algorithm failed to converge.  Results may be incorrect.');
    end
    Q(z) = 1 - sum;
end
