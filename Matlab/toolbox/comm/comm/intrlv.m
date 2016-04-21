function intrlved = intrlv(data, elements)
%INTRLV Reorder sequence of symbols.
%   INTRLVED = INTRLV(DATA, ELEMENTS) rearranges the elements of DATA
%   without repeating or omitting any of its elements. If DATA contains N
%   elements, then ELEMENTS is a vector of length N that indicates the
%   indices, in order, of the elements that came from DATA. That is, for
%   each integer k between 1 and N, ELEMENTS must contain unique integers
%   between 1 and N. DATA can either be a matrix or a vector. 
%
%   See also DEINTRLV.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:00:45 $

% --- Checks if DATA is 1-D row vector
initial_width = size(data,1);
if (initial_width == 1)
    data = data(:);                            % Converts sequence in DATA to a column vector
end

% --- Initialize variables
data_size = size(data);
[elem_row, elem_col] = size(elements);
elem_ordered = 1:data_size(1);                      


% --- Error checking on input arguments
if ischar(elements)
    error('comm:intrlv:ElemIsNotAVector','ELEMENTS must be a vector of integers.')
end

if (elem_row >= 2 && elem_col >= 2)             % Checks if ELEMENTS is a matrix
    error('comm:intrlv:ElemIsNotAVector','ELEMENTS must be a vector of integers.')
end

if isempty(data) 
    error('comm:intrlv:DataIsEmpty','DATA cannot be empty.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:intrlv:DataIsNotNumeric','DATA must be numeric.');
end

if isempty(elements)
    error('comm:intrlv:ElemIsEmpty','ELEMENTS cannot be empty.')
end

if (length(elements) > data_size(1))
    error('comm:intrlv:InvalidElemLen','The length of ELEMENTS must equal the length of the sequence in DATA.')
end

if any(ismember(elem_ordered,elements) == 0)    % Checks if the indices specified are valid
    error('comm:intrlv:InvalidElemPerm','ELEMENTS must be a permutation of the indices of the elements in DATA.')
end

% --- Permutes sequence of symbols given in DATA
intrlved = data(elements(:),:);                    

% --- Restores the output to the original orientation if sequence in DATA is a column vector
if (initial_width == 1)
    intrlved = intrlved.';
end
% -- end of intrlv ---