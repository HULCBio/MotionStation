function deintrlved = matdeintrlv(data, Nrows, Ncols)
%MATDEINTRLV Reorder symbols by filling a matrix by columns and emptying it by rows.
%   DEINTRLVED = MATDEINTRLV(DATA, Nrows, Ncols) reorders the elements in
%   DATA by filling an internal matrix with the elements contained in DATA
%   column by column and returning the contents in DEINTRLVED row by row. 
%   NROWS and NCOLS are the dimensions of the internal matrix.
%
%   See also MATINTRLV.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:00:49 $

data_size = size(data);                        % Obtain size of DATA
orig_data = data;

% --- Checks if DATA is 1-D row vector
if (data_size(1) == 1)
    data = data(:);                            % Converts sequence in DATA to a column vector
    data_size = size(data); 
end

% --- Error checking on input arguments
if (isempty(data))
    error('comm:matdeintrlv:DataIsEmpty','DATA cannot be empty.')
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:matdeintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if (length(Nrows) ~= 1)
    error('comm:matdeintrlv:NrowsIsNotAScalar','NROWS must be a scalar integer value.')
end
if (length(Ncols) ~= 1)
    error('comm:matdeintrlv:NcolsIsNotAScalar','NCOLS must be a scalar integer value.')
end

if ~isnumeric(Nrows)
    error('comm:matdeintrlv:NrowsIsNotNumeric', 'NROWS must numeric.')
end

if ~isnumeric(Ncols)
    error('comm:matdeintrlv:NcolsIsNotNumeric', 'NCOLS must numeric.')
end

if ((Nrows*Ncols) ~= data_size(1))            
    error('comm:matdeintrlv:NrowsByNcolsIsInvalid',['The product of NROWS and NCOLS must equal\n' ...
        'the length of the sequence in DATA.'])
end

% --- Computes the new indices for DATA
int_table = reshape(reshape([1:Nrows*Ncols],Ncols,Nrows)',Nrows*Ncols,1);

% --- Reorders sequence of symbols in DATA
deintrlved = deintrlv(orig_data, int_table);

% -- end of matdeintrlv ---