function d = diag(v,k)
% Embedded MATLAB Library function.
%
% Limitations:
%    1) K-th diagonal argument must have an integer value. In other words
%       K can not be a complex number, and its real value must be rounded
%       towards zero before passing it as an argument to DIAG(V,K).

% $INCLUDE(DOC) toolbox/eml/lib/matlab/@double/diag.m $
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/03/21 22:07:36 $

eml_assert(nargin>=1, ...
    'error','Not enough input arguments.');

eml_ignore('kth = 0;'); % used for regression testing against MATLAB
if nargin>1
    % k-th diagonal argument must be a scalar
    eml_assert(nargin<2 || ...
      (length(k)==1 && isreal(k)), ...
      'error','K-th (diagnoal) input argument must be an integer scalar.');
    eml_ignore('kth = k;'); % preserve value of k testing against MATLAB
    % WISH EMM 1/1/04 : get the following working to remove current
    % limitations
    eml_ignore('k = fix(real(kth));'); % integer round k towards zero, works with complex k
end

[mV,nV] = size(v);

% for the degenerate case return an empty matrix or zeros(k)
if (mV==0 || nV==0)
    if ((mV==1 || nV==1) && nargin>1)
        if k>=0
            d = zeros(k,class(v));
        else
            d = zeros(-k,class(v));
        end
    else
        d = [];
    end
    eml_ignore(eml_assert(isequal(d,builtin('diag',v,kth))));
    return;
end

% when V is a vector return a diagonal matrix created from V
if (mV==1 || nV==1) % V is a vector
    n = length(v); % length of vector V
    if nargin<2 % => k=0
        m = n;
        d = czeros(m,m,v);
        for i=1:n
            d(i,i) = v(i);
        end
    elseif k>=0  % k-th diagonal starts at column k+1
        m = n+k; % size of square return-matrix D
        d = czeros(m,m,v);
        for i=1:n
            d(i,i+k) = v(i);
        end
    else % -ve k => k-th diagonal starts at row k+1
        m = n-k; % size of square return-matrix D
        d = czeros(m,m,v);
        for i=1:n
            d(i-k,i) = v(i);
        end
    end
    eml_ignore(eml_assert(isequal(d,builtin('diag',v,kth))));
    return;
end

% when V is a matrix return the k-th diagonal of V
if nargin<2 % => k=0
    if nV<=mV
        m = nV;
        d = czeros(m,1,v);
    else
        m = mV;
        d = czeros(m,1,v);
    end
    for i=1:m
        d(i) = v(i,i);
    end
elseif k>=0 % k-th diagonal starts at column k
    n = nV-k;
    if n <= 0
        % kth diagonal does not exist
        d = zeros(0,1,class(v));
    else
        if n <= mV
            m = n;
            d = czeros(m,1,v);
        else
            m = mV;
            d = czeros(m,1,v);
        end
        for i=1:m
            d(i) = v(i,k+i);
        end
    end
else % -ve k => k-th diagonal starts at row k
    m = mV+k;
    if m <= 0
        % -kth diagonal does not exist
        d = zeros(0,1,class(v));
    else
        if nV <= m
            n = nV;
            d = czeros(n,1,v);
        else
            n = m;
            d = czeros(n,1,v);
        end
        for i=1:n
            d(i) = v(i-k,i);
        end
    end
end
eml_ignore(eml_assert(isequal(d,builtin('diag',v,kth))));
return;


%%%%%%%%
function d = czeros(m,n,v)
if isreal(v), d = zeros(m,n,class(v));
else          d = complex(zeros(m,n,class(v)));
end
return;
