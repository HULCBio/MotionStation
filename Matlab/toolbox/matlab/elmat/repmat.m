function B = repmat(A,M,N)
%REPMAT Replicate and tile an array.
%   B = repmat(A,M,N) creates a large matrix B consisting of an M-by-N
%   tiling of copies of A.
%   
%   B = REPMAT(A,[M N]) accomplishes the same result as repmat(A,M,N).
%
%   B = REPMAT(A,[M N P ...]) tiles the array A to produce a
%   M-by-N-by-P-by-... block array.  A can be N-D.
%
%   REPMAT(A,M,N) when A is a scalar is commonly used to produce
%   an M-by-N matrix filled with A's value.
%   
%   Example:
%       repmat(magic(2), 2, 3)
%       repmat(NaN, 2, 3)
%       repmat(uint8(5), 2, 3)
%
%   See also MESHGRID.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.17.4.5 $  $Date: 2004/04/10 23:26:03 $

if nargin < 2
    error('MATLAB:repmat:NotEnoughInputs', 'Requires at least 2 inputs.')
end

if nargin == 2
    if isscalar(M)
        siz = [M M];
    else
        siz = M;
    end
else
    siz = [M N];
end

if isscalar(A)
    nelems = prod(siz);
    if nelems>0
        % Since B doesn't exist, the first statement creates a B with
        % the right size and type.  Then use scalar expansion to
        % fill the array. Finally reshape to the specified size.
        B(nelems) = A;
        if ~isequal(B(1), B(nelems)) || ~(isnumeric(A) || islogical(A))
            % if B(1) is the same as B(nelems), then the default value filled in for
            % B(1:end-1) is already A, so we don't need to waste time redoing
            % this operation. (This optimizes the case that A is a scalar zero of
            % some class.)
            B(:) = A;
        end
        B = reshape(B,siz);
    else
        B = A(ones(siz));
    end
elseif ndims(A) == 2 && numel(siz) == 2
    [m,n] = size(A);
    
    if (m == 1 && siz(2) == 1)
        B = A(ones(siz(1), 1), :);
    elseif (n == 1 && siz(1) == 1)
        B = A(:, ones(siz(2), 1));
    else
        mind = (1:m)';
        nind = (1:n)';
        mind = mind(:,ones(1,siz(1)));
        nind = nind(:,ones(1,siz(2)));
        B = A(mind,nind);
    end
else
    Asiz = size(A);
    Asiz = [Asiz ones(1,length(siz)-length(Asiz))];
    siz = [siz ones(1,length(Asiz)-length(siz))];
    for i=length(Asiz):-1:1
        ind = (1:Asiz(i))';
        subs{i} = ind(:,ones(1,siz(i)));
    end
    B = A(subs{:});
end
