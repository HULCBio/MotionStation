function deintrlved = deintrlv(data, elements)
% DEINTRLV Restore ordering of symbols.
%   DEINTRLVD = DEINTRLV(DATA,ELEMENTS) restores the original ordering of
%   the elements of DATA by acting as an inverse of INTRLV. If DATA is a
%   length-N vector or an N-row matrix, then ELEMENTS is a length-N vector
%   that permutes the integers from 1 to N. To use this function as an
%   inverse of the INTRLV function, use the same ELEMENTS input in both
%   functions. In that case, the two functions are inverses in the sense
%   that applying INTRLV followed by DEINTRLV leaves DATA unchanged.
%
%   See also INTRLV.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/03/24 20:32:41 $
   
% --- Checks if DATA is 1-D row vector
initial_width = size(data,1);
if (initial_width == 1)
    data = data(:);                            % Converts sequence in DATA to a column vector
end

% --- Initialize parameters
[data_size] = size(data);
[elem_row, elem_col] = size(elements);
elem_ordered = 1:data_size(1);                      


% --- Error checking on input arguments
if ischar(elements)
    error('comm:deintrlv:ElemIsNotAVector','ELEMENTS must be a vector of integers.')
end
if (elem_row >= 2 && elem_col >= 2)             % Checks if ELEMENTS is a matrix
    error('comm:deintrlv:ElemIsNotAVector','ELEMENTS must be a vector of integers.')
end

if isempty(data)
    error('comm:deintrlv:DataIsEmpty','DATA cannot be empty.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:deintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if isempty(elements)
    error('comm:deintrlv:ElemIsEmpty','ELEMENTS cannot be empty.')
end

if (length(elements) > data_size(1))
    error('comm:deintrlv:InvalidElemLen','The length of ELEMENTS must equal the length of the sequence in DATA.')
end

if any(ismember(elem_ordered,elements) == 0)    % Checks if the indices specified are valid
    error('comm:deintrlv:InvalidElemPerm','ELEMENTS must be a permutation of the indices of the elements in DATA.')
end

input_data = data;           % Store original DATA

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:deintrlv:DataIsNotNumeric','DATA must be numeric.');
elseif isa(data,'gf')
    data = double(input_data.x);        % Obtain data values from Galois array, and conver to double
    gf_order = input_data.m;
    gf_primpoly = input_data.prim_poly;
end

% --- Restore ordering of symbols using ELEMENTS
deintrlved = zeros(size(data));                    % Preallocates the output   
deintrlved(elements(:),:) = data;  

% --- Returns output as a Galois field array
if isa(input_data,'gf')     % Convert outputs back to Galois object
    deintrlved = gf(deintrlved,gf_order,gf_primpoly);
end

% --- Restores the output to the original orientation if sequence in DATA is a column vector
if (initial_width == 1)
    deintrlved = deintrlved.';
end
% -- end of deintrlv ---