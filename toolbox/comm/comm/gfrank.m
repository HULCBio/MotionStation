function rk = gfrank(a, p)
%GFRANK Compute the rank of a matrix over a Galois field.
%   RK = GFRANK(A) calculates the rank of matrix A in GF(2).
%
%   RK = GFRANK(A, P) calculates the rank of matrix in GF(P).
%
%   See also GFLINEQ.

%   The method use here is similar to the Gaussian elimination.
%   The algorithm has taken the advantage of the binary computation
%   double sided elimination has been used.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2002/03/27 00:08:05 $

if nargin < 1
    error('Not enough input variables.')
elseif nargin < 2
    p = 2;
end;
vld = 0;

% make matrix A into a long matrix.
[n, m] = size(a);
if n < m
    a = a';
end;

x = a(:);
if ((max(x) >=p) | (min(x) < 0) | ~isempty(find(floor(x) ~= x)))
    error('Elements in A and B must be nonnegative integers between 0 and P-1.')
end;
[n, m] = size(a);
k = 1;
i = 1;
ii = [];
kk = [];

% forward major element selection
while (i <= n) & (k <= m)
    % make the diagonal element into 1, or jump one line.
    while (a(i,k) == 0) & (k < m)
        ind = find(a(i:n, k) ~= 0);
        if isempty(ind)
            k = k + 1;
        else
            indx = find(a(i:n, k) == 1);
            if isempty(indx)
               ind_major = ind(1);
            else
               ind_major = indx(1);
            end;
            j = i + ind_major - 1;
            tmp = a(i, :);
            a(i,:) = a(j, :);
            a(j, :) = tmp;
        end;
    end;

    % clear all nonzero elements in the column except the major element.
    if (a(i,k) ~= 0)
     % to make major element into 1
        if (a(i,k) ~= 1)
           a(i,:) = rem(a(i,k)^(p-2) * a(i,:), p);
        end;
        ind = find(a(:,k) ~= 0)';
        ii = [ii i];
        kk = [kk k];
        vec = [k:m];
        for j = ind
            if j > i
                % to make sure the column will be zero except the major element.
                a(j, vec) = rem(a(j, vec) + a(i, vec) * (p - a(j, k)), p);
            end;
        end;
        k = k + 1;
    end;
    i = i + 1;
end;

rk = max( find( sum( a') > 0));

% --- end of GFRANK.M--

