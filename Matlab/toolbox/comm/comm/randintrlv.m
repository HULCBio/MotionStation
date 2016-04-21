function intrlved = randintrlv(data, state)
%RANDINTRLV Reorder symbols using a random permutation.
%   INTRLVED = RANDINTRLV(DATA, STATE) rearranges the elements of DATA
%   using a random permutation. The STATE value initializes the random
%   number generator that the function uses to determine the permutation.
%   The function is predictable for a given seed, but different seeds
%   produce different permutations.
%
%   See also RANDDEINTRLV.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:01:16 $

data_size = size(data);          % Obtains size of DATA
orig_data = data;
len = length(state);             % Obtains length of STATE

% --- Checks if DATA is 1-D row vector
if (data_size(1) == 1)
    data = data(:);              % Converts sequence in DATA to a column vector
    data_size = size(data);
end

% --- Error checking on input arguments
if isempty(data)
    error('comm:randintrlv:DataIsEmpty','DATA cannot be empty.')  
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:randintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if isempty(state)
    error('comm:randintrlv:StateIsEmpty','STATE cannot be empty.')  
end

if ~isnumeric(state)
    error('comm:randintrlv:StateIsNotNumeric','STATE must be numeric.')
end

if ((len ~= 1) || (len > 35))
    error('comm:randintrlv:InvalidState','STATE must be scalar or 35-by-1.')
end

rand('state',state);                    % Sets the current state of the uniform generator
int_vec = (randperm(data_size(1)));     % Returns a random permutation of the integers 1:data_size(2)

% --- Reorders sequence of symbols
intrlved = intrlv(orig_data,int_vec);

% -- end of randintrlv ---