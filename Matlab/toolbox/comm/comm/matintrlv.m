function intrlved = matintrlv(data, Nrows, Ncols)
%MATINTRLV Permute symbols by filling a matrix by rows and emptying it by columns.
%   INTRLVED = MATINTRLV(DATA, Nrows, Ncols) rearranges the elements in
%   DATA by filling an internal matrix with the elements contained in DATA
%   row by row and returning the contents in INTRLVED column by column. 
%   NROWS and NCOLS are the dimensions of the internal matrix.
%
%   See also MATDEINTRLV.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:00:50 $

data_size = size(data);                        % Obtains size of DATA
orig_data = data;

% --- Checks if DATA is 1-D row vector
if (data_size(1) == 1)
    data = data(:);                            % Converts sequence in DATA to a column vector
    data_size = size(data); 
end

% --- Error checking on input arguments
if (isempty(data))
    error('comm:matintrlv:DataIsEmpty','DATA cannot be empty.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:matintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if (length(Nrows) ~= 1)
    error('comm:matintrlv:NrowsIsNotAScalar','NROWS must be a scalar integer value.')
end
if (length(Ncols) ~= 1)
    error('comm:matintrlv:NcolsIsNotAScalar','NCOLS must be a scalar integer value.')
end

if ~isnumeric(Nrows)
    error('comm:matintrlv:NrowsIsNotNumeric', 'NROWS must numeric.')
end

if ~isnumeric(Ncols)
    error('comm:matintrlv:NcolsIsNotNumeric', 'NCOLS must numeric.')
end

if ((Nrows*Ncols) ~= data_size(1))            
    error('comm:matintrlv:NrowsByNcolsIsInvalid',['The product of NROWS and NCOLS must equal\n' ...
        'the length of the sequence in DATA.'])
end

% --- Computes the new indices for DATA
int_table = reshape(reshape([1:Nrows*Ncols],Ncols,Nrows)',Nrows*Ncols,1);

% --- Rearranges sequence of symbols in DATA
intrlved = intrlv(orig_data, int_table);

% -- end of matintrlv ---
