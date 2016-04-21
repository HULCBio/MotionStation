function varargout = eigs2(A,n,B,k,whch,sigma,cholB,varargin)
%EIGS2  EIGS helper function.
%   EIGS2 computes a few eigenvalues and eigenvectors when EIGS cannot.
%   Namely, when k>n-2 (complex and nonsymmetric) k>n-1 (real symmetric).
%
%   See also EIGS, EIG.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 04:14:07 $

if cholB
    B = B'*B;
end
if issparse(B)
    B = full(B);
end
if isa(A,'double')
    if issparse(A);
        A = full(A);
    end
else % form A by applying function to columns of n-by-n identity
    if (sigma == 0) % A is a function multiplying A*x
        In = eye(n);
        AA = zeros(n,n);
        for i = 1:n
            AA(:,i) = feval(A,In(:,i),varargin{:});
        end
        A = AA;
    else % A is a function solving (A-sigma*B)\x
        sB = sigma*B;
        U = zeros(n,n);
        for i = 1:n
            U(:,i) = feval(A,sB(:,i),varargin{:});
        end
        A = sB*(U+eye(n)) / U;
    end
end
if (nargout <= 1)
    if isempty(B)
        d = eig(A);
    else
        d = eig(A,B);
    end
else
    if isempty(B)
        [V,D] = eig(A);
    else
        [V,D] = eig(A,B);
    end
    d = diag(D);
end

if (sigma ~= 0)
    [dum,ind] = sort(abs(d-sigma));
    if (nargout <= 1)
        varargout{1} = d(ind(1:k));
    else
        varargout{1} = V(:,ind(1:k));
        varargout{2} = D(ind(1:k),ind(1:k));
    end
else
    switch whch
    case 'LM'
        [dum,ind] = sort(abs(d));
        if (nargout <= 1)
            varargout{1} = d(ind(end:-1:end-k+1));
        else
            varargout{1} = V(:,ind(end:-1:end-k+1));
            varargout{2} = D(ind(end:-1:end-k+1),ind(end:-1:end-k+1));
        end
    case 'SM'
        [dum,ind] = sort(abs(d));
        if (nargout <= 1)
            varargout{1} = d(ind(1:k));
        else
            varargout{1} = V(:,ind(1:k));
            varargout{2} = D(ind(1:k),ind(1:k));
        end
    case 'LA'
        [dum,ind] = sort(d);
        if (nargout <= 1)
            varargout{1} = d(ind(end:-1:end-k+1));
        else
            varargout{1} = V(:,ind(end:-1:end-k+1));
            varargout{2} = D(ind(end:-1:end-k+1),ind(end:-1:end-k+1));
        end
    case 'SA'
        [dum,ind] = sort(d);
        if (nargout <= 1)
            varargout{1} = d(ind(1:k));
        else
            varargout{1} = V(:,ind(1:k));
            varargout{2} = D(ind(1:k),ind(1:k));
        end
    case 'LR'
        [dum,ind] = sort(abs(real(d)));
        if (nargout <= 1)
            varargout{1} = d(ind(end:-1:end-k+1));
        else
            varargout{1} = V(:,ind(end:-1:end-k+1));
            varargout{2} = D(ind(end:-1:end-k+1),ind(end:-1:end-k+1));
        end
    case 'SR'
        [dum,ind] = sort(abs(real(d)));
        if (nargout <= 1)
            varargout{1} = d(ind(1:k));
        else
            varargout{1} = V(:,ind(1:k));
            varargout{2} = D(ind(1:k),ind(1:k));
        end
    case 'LI'
        [dum,ind] = sort(abs(imag(d)));
        if (nargout <= 1)
            varargout{1} = d(ind(end:-1:end-k+1));
        else
            varargout{1} = V(:,ind(end:-1:end-k+1));
            varargout{2} = D(ind(end:-1:end-k+1),ind(end:-1:end-k+1));
        end
    case 'SI'
        [dum,ind] = sort(abs(imag(d)));
        if (nargout <= 1)
            varargout{1} = d(ind(1:k));
        else
            varargout{1} = V(:,ind(1:k));
            varargout{2} = D(ind(1:k),ind(1:k));
        end
    case 'BE'
        [dum,ind] = sort(abs(d));
        range = [1:floor(k/2), n-ceil(k/2)+1:n];
        if (nargout <= 1)
            varargout{1} = d(ind(range));
        else
            varargout{1} = V(:,ind(range));
            varargout{2} = D(ind(range),ind(range));
        end
    end
end
