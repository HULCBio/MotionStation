function [y,ndx] = sortrows(x,col)
%SORTROWS Sort rows in ascending order.
%   Y = SORTROWS(X) sorts the rows of the matrix X in ascending order as a
%   group.  X is a 2-D numeric or char matrix.  For a char matrix containing
%   strings in each row, this is the familiar dictionary sort.  When X is
%   complex, the elements are sorted by ABS(X). Complex matches are further
%   sorted by ANGLE(X).  X can be any numeric or char class.  Y is the same
%   size and class as X.
%
%   SORTROWS(X,COL) sorts the matrix based on the columns specified in the
%   vector COL.  If an element of COL is positive, the corresponding column
%   in X will be sorted in ascending order; if an element of COL is negative,
%   the corresponding column in X will be sorted in descending order.  For 
%   example, SORTROWS(X,[2 -3]) sorts the rows of X first in ascending order 
%   for the second column, and then by descending order for the third
%   column.
%
%   [Y,I] = SORTROWS(X) also returns an index matrix I such that Y = X(I,:).
%
%   Notes
%   -----
%   SORTROWS uses a stable version of quicksort.  NaN values are sorted
%   as if they are higher than all other values, including +Inf.
%
%   Class support for input X:
%      numeric, logical, char
%
%   See also SORT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.19.4.4 $  $Date: 2004/03/09 16:16:29 $

% I/O details
% -----------
% X    - 2-D matrix of any type for which SORT works.
%
% COL  - Vector.  Must contain integers whose magnitude is between 1 and size(X,2).
%        May be any numeric class.
%
% Y    - 2-D matrix. Same size and class as X.
%
% NDX  - Column vector of size M-by-1, where M is size(X,1).  Double.
%        Contains row indices into X.

error(nargchk(1,2,nargin))
if ndims(x) > 2
    error('MATLAB:SORTROWS:inputDimensionMismatch','X must be a 2-D matrix.');
end

[m,n] = size(x);

% initialize variable to hold location of negative column indices
dec_idx = []; 

if nargin < 2
    x_sub = x;
else
    if isnumeric(col)
        col = double(col);
        % Find the column numbers to be sorted in decreasing order.
        dec_idx = find(col < 0); 
    else
        error('MATLAB:sortrows:COLnotNumeric', 'COL must be numeric.');
    end
    if ( ( numel(col) ~= length(col) )|| ... 
         ( any(floor(col) ~= col) ) || ...
         ( any(col > size(x,2)) ) )
        error('MATLAB:sortrows:COLmismatchX',...
              'COL must be a vector of column indices into X.');
    end
    
    if dec_idx         
        % Negate the values in those columns so that when sorted in increasing     
        % order will have the same effect as sorting in decreasing order.
        if isreal(x) 
            x(:,abs(col(dec_idx))) = -x(:,abs(col(dec_idx))); 
        end
        x_sub = x(:,abs(col)); 
    else
        x_sub = x(:,col);    
    end 
end

if isreal(x) && ~issparse(x) && n > 3
    % Call MEX-file to do the hard work for non-sparse real
    % and character arrays.  Only called if at least 4 elements per row.
    ndx = sortrowsc(x_sub);
elseif isnumeric(x) && ~isreal(x) && ~issparse(x)
    % sort_complex implements the specified behavior of using ABS(X) as
    % the primary key and ANGLE(X) as the secondary key.
    if dec_idx,
        ndx = sort_complex(x_sub,col);
    else
        ndx = sort_complex(x_sub);
    end
else
    % For sparse arrays, cell arrays, and anything else for which the
    % sortrows worked MATLAB 6.0 or earlier, use the old MATLAB 6.0
    % algorithm.  Also called if 3 or fewer elements per row.
    ndx = sort_back_to_front(x_sub);
end

% Re-negate the negated values so that the matrix regains the original     
% values. 
if dec_idx & isreal(x)
    x(:,abs(col(dec_idx))) = -x(:,abs(col(dec_idx)));
end 

% Rearrange input rows according to the output of the sort algorithm.
y = x(ndx,:);

% If input is 0-by-0, make sure output is also 0-by-0.
if isequal(size(x),[0 0])
    y = reshape(y,[0 0]);
    ndx = reshape(ndx,[0 0]);
end

%--------------------------------------------------
function ndx = sort_back_to_front(x)
% NDX = SORT_BACK_TO_FRONT(X) sorts the rows of X by sorting each column
% from back to front.  This is the sortrows algorithm used in MATLAB 6.0
% and earlier.

[m,n] = size(x);
ndx = (1:m)';

if isreal(x)
  for k = n:-1:1
    [v,ind] = sort(double(x(ndx,k)));
    ndx = ndx(ind);
  end
else
  for k = n:-1:1
    [v,ind] = sort(x(ndx,k));
    ndx = ndx(ind);
  end
end

%--------------------------------------------------
function ndx = sort_complex(x,col)
% NDX = SORT_COMPLEX(X) sorts the rows of the complex-valued matrix X. 
% Individual elements are sorted first by ABS() and then by ANGLE().

[m,n] = size(x);
xx = zeros(m,2*n);
if nargin == 1,
    xx(:,1:2:end) = abs(x);
    xx(:,2:2:end) = angle(x);
else
    xx(:,1:2:end) = abs(x) .* repmat(sign(col),m,1);
    xx(:,2:2:end) = angle(x) .* repmat(sign(col),m,1);
end
    
ndx = sortrowsc(xx);
