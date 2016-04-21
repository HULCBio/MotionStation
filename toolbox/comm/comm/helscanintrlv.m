function intrlved = helscanintrlv(data,Nrows,Ncols,Hstep)
%HELSCANINTRLV Permute symbols in a helical pattern.
%   INTRLVED = HELSCANINTRLV(DATA, NROWS, NCOLS, HSTEP) reorders the
%   symbols in DATA by filling an array with the elements in DATA row by
%   row and then reading them out by scanning along the diagonals of this
%   array.  NROWS and NCOLS are the dimensions of the array the function
%   uses for its internal computations. The array step size, HSTEP, is the
%   slope of the diagonal, and must be a nonnegative integer less than the
%   specified number of rows. The product of NROWS and NCOLS must match the
%   length of the sequence in DATA.
%
%   See also HELSCANDEINTRLV.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:00:43 $

data_size = size(data);                 % Obtains size of DATA
orig_data = data;

% --- Checks if DATA is 1-D row vector
if (data_size(1) == 1)
    data = data(:);                     % Converts sequence in DATA to a column vector
    data_size = size(data);
end

% --- Error checking on input arguments
if isempty(data)
    error('comm:helscanintrlv:DataIsEmpty','DATA cannot be empty.')
end

if(Nrows <= 0)
   error('comm:helscanintrlv:NrowsIsNotAPositiveInt','The number of rows must be a nonnegative integer.');
end

if(Ncols <= 0)
   error('comm:helscanintrlv:NcolsIsNotAPositiveInt','The number of columns must be a nonnegative integer.');
end

if ((Nrows*Ncols) ~= data_size(1))             
    error('comm:helscanintrlv:NrowsByNcolsIsInvalid', ['The product of NROWS and NCOLS must equal the length of\n'...
        'the sequence(s) in DATA.'])
end

if (Hstep >= Nrows || Hstep<0)
    error('comm:helscanintrlv:InvalidHstep', ['The array step size must be a nonnegative integer less than\n'... 
            'the specified number of rows.']);
end

% --- Computes the new indices for DATA
int_table = zeros(Nrows*Ncols,1);
for i=1:Nrows
 j=1:Ncols;
 int_table((i-1)*Ncols+j)=mod(i-1+Hstep*(j-1),Nrows)*Ncols+j;
end

% --- Reorders sequence of symbols in DATA
intrlved = intrlv(orig_data,int_table);

% -- end of helscanintrlv ---
