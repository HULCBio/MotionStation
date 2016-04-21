function m = cell2mat(c)
%CELL2MAT Convert the contents of a cell array into a single matrix.
%   M = CELL2MAT(C) converts a multidimensional cell array with contents of
%   the same data type into a single matrix. The contents of C must be able
%   to concatenate into a hyperrectangle. Moreover, for each pair of
%   neighboring cells, the dimensions of the cell's contents must match,
%   excluding the dimension in which the cells are neighbors. This constraint
%   must hold true for neighboring cells along all of the cell array's
%   dimensions.
%
%   The dimensionality of M, i.e. the number of dimensions of M, will match
%   the highest dimensionality contained in the cell array.
%
%   CELL2MAT is not supported for cell arrays containing cell arrays or
%   objects.
%
%	Example:
%	   C = {[1] [2 3 4]; [5; 9] [6 7 8; 10 11 12]};
%	   M = cell2mat(C)
%
%	See also MAT2CELL, NUM2CELL

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.10.4.2 $  $Date: 2004/04/10 23:25:14 $

% Error out if there is no input argument
if nargin==0
    error('MATLAB:cell2mat:NoInputs',['No input argument specified. ' ...
        'There should be exactly one input argument.'])
end
% short circuit for simplest case
elements = numel(c);
if elements == 0
    m = [];
    return
end
if elements == 1
    if isnumeric(c{1}) || ischar(c{1}) || islogical(c{1})
        m = c{1};
        return
    end
end
% Error out if cell array contains any cell arrays or objects
ciscell = cellfun('isclass',c,'cell');
if isempty(c)
    cisobj = 0;
else
    cisobj = isobject(c{1});
end
if cisobj || any(ciscell(:))
    error('MATLAB:cell2mat:UnsupportedCellContent',['Cannot support cell ' ...
        'arrays containing cell arrays or objects.']);
end

% If the cell array has one element we can finish
%   up the conversion quickly

if elements == 1
    m = c{1};
    return
end

csize = size(c);
% Error out if cell array contains mixed data types
cellclass = class(c{1});
ciscellclass = cellfun('isclass',c,cellclass);
if ~all(ciscellclass(:))
    error('MATLAB:cell2mat:MixedDataTypes', ...
        'All contents of the input cell array must be of the same data type.');
end

% If cell array of structures, make sure the field names are all the same
if isstruct(c{1})
    cfields = cell(elements,1);
    for n=1:elements
        cfields{n} = fieldnames(c{n});
    end
    % Perform the actual field name equality test
    if ~isequal(cfields{:})
        error('MATLAB:cell2mat:InconsistentFieldNames', ...
            ['The field names of each cell array element must be consistent ' ...
            'and in consistent order.'])
    end
end

% If cell array is 2-D, execute 2-D code for speed efficiency
if ndims(c) == 2
    rows = size(c,1);
    m = cell(rows,1);
    % Concatenate each row first
    for n=1:rows
        m{n} = cat(2,c{n,:});
    end
    % Now concatenate the single column of cells into a matrix
    m = cat(1,m{:});
    return
end


% Treat 3+ dimension arrays

% Construct the matrix by concatenating each dimension of the cell array into
%   a temporary cell array, CT
% The exterior loop iterates one time less than the number of dimensions,
%   and the final dimension (dimension 1) concatenation occurs after the loops

% Loop through the cell array dimensions in reverse order to perform the
%   sequential concatenations
for cdim=(length(csize)-1):-1:1
    % Pre-calculated outside the next loop for efficiency
    ct = cell([csize(1:cdim) 1]);
    cts = size(ct);
    ctsl = length(cts);
    mref = {};

    % Concatenate the dimension, (CDIM+1), at each element in the temporary cell
    %   array, CT
    for mind=1:prod(cts)
        [mref{1:ctsl}] = ind2sub(cts,mind);
        % Treat a size [N 1] array as size [N], since this is how the indices
        %   are found to calculate CT
        if ctsl==2 && cts(2)==1
            mref = {mref{1}};
        end
        % Perform the concatenation along the (CDIM+1) dimension
        ct{mref{:}} = cat(cdim+1,c{mref{:},:});
    end
    % Replace M with the new temporarily concatenated cell array, CT
    c = ct;
end

% Finally, concatenate the final rows of cells into a matrix
m = cat(1,c{:});