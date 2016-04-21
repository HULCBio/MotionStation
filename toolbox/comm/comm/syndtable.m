function table = syndtable(h)
%SYNDTABLE Produce syndrome decoding table.
%   T = SYNDTABLE(H) returns a binary matrix that represents the first column of
%   a standard array of a linear code having a parity-check matrix H.  T
%   consists of coset leaders ordered sequentially by the associated syndromes
%   such that the first row contains an error pattern with a syndrome equal to
%   0, and the last row contains an error pattern with a syndrome equal to
%   2^(number of rows in H)-1.
%
%   See also DECODE, HAMMGEN, GFCOSETS.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.7 $  $Date: 2002/03/27 00:04:38 $

if isempty(h)
    error('The parity check matrix cannot be empty.');
end

[n_k,n]=size(h);                    % n_k denotes n-k
if n_k >= n | ~isequal(size(size(h)),[1 2]),
    error('There must be more columns than rows in the parity check matrix.');
end

if ~isnumeric(h) | max(max(h < 0)) | max(max(h)) > 1 | (max(max(floor(h) ~= h))),
    error('The parity check matrix must contain only binary numbers.');
end

table = zeros(2^n_k,n);
emptyRows = [2:2^n_k]';

% Each row contains a single-error pattern
% (except last row which is all-zeros)
E = flipud([zeros(1, n); eye(n)]);

% Each row contains syndrome of a single-error pattern
% (except last row)
synSingleErr = bi2de(fliplr(mod(E*h',2)));

[a,b,c] = unique(synSingleErr);
table(synSingleErr(b)+1,:) = E(b,:);

% Update record of empty rows
emptyRows = setdiff(emptyRows,synSingleErr(b)+1);
if ~isempty(emptyRows)
    disp(['Single-error patterns loaded in decoding table.  ' num2str(length(emptyRows)) ' rows remaining.']);
end

% Go through all error patterns, starting from 2-bit patterns
% Stop when all rows are filled
b = 2;
while ~isempty(emptyRows) & b<=n,
    [table emptyRows]=comb_fill([1:n],b,table,emptyRows,h,1);
    disp([num2str(b) '-error patterns loaded.  ' num2str(length(emptyRows)) ' rows remaining.']);
    b = b+1;
end

%===========================================================================
function varargout = comb_fill(V,m,table,emptyRows,H,outmost)
%COMB_FILL  A nested function to go through all possible combinations of
%   choosing m elements from V.
%   When OUTMOST equals 1, it denotes the very first call to the nested function.
%
%   Each of these combinations is used as the positions of errors to build up
%   the error patterns.  If the syndrome of an error pattern corresponds to the
%   address of an unfilled row in TABLE, this row in TABLE will be filled with
%   the error pattern.
%
%   The procedure stops when every row in TABLE has been filled.

if isempty(emptyRows)
    if nargout == 3,
        varargout{1} = [];
        varargout{2} = table;
        varargout{3} = emptyRows;
    else
        varargout{1} = table;
        varargout{2} = emptyRows;
    end
    return;
end

V = V(:).';             % Make V a row vector.
n = length(V);
if n == m
    P = V;
elseif m == 1
    P = V.';
else
    P = [];
    if m < n & m > 1
        for k = 1:n-m+1   % k = position of 1st error bit

            % Fix 1st bit location, do combinations of remaining m-1 bits
            [Q table emptyRows] = comb_fill(V(k+1:n),m-1,table,emptyRows,H,0);
            pos = [V(ones(size(Q,1),1),k) Q];
            P = [P; pos];

            if outmost == 1,
                for ind = 1:size(pos,1)

                    % Build error patterns with current combination as error bit
                    % locations
                    mat = zeros(1,size(table,2));
                    mat(pos(ind,:)) = 1;

                    % Compute syndrome
                    s = mod(mat*H',2);
                    s_bin = bi2de(fliplr(s));

                    % Fill table if row corresponding to current syndrome
                    % is empty
                    if find(emptyRows == s_bin+1),
                        table(emptyRows(find(emptyRows == s_bin+1)),:) = mat;

                        % Update emptyRows
                        emptyRows = setdiff(emptyRows,s_bin+1);

                        % Return if all rows are filled
                        if isempty(emptyRows)
                            if nargout == 3,
                                varargout{1} = P;
                                varargout{2} = table;
                                varargout{3} = emptyRows;
                            else
                                varargout{1} = table;
                                varargout{2} = emptyRows;
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end

if nargout == 3,
	varargout{1} = P;
	varargout{2} = table;
	varargout{3} = emptyRows;
else
	varargout{1} = table;
	varargout{2} = emptyRows;
end

% [EOF]