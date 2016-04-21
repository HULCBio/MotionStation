function deintrlved = randdeintrlv(data, state)
%RANDDEINTRLV Restore ordering of symbols using a random permutation.
%   DEINTRLVED = RANDDEINTRLV(DATA, STATE) rearranges the elements of DATA
%   using a random permutation. The STATE parameter initializes the random
%   number generator that the function uses to determine the permutation.
%   The function is predictable for a given seed, but different seeds
%   produce different permutations. 
%
%   See also RANDINTRLV.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:01:15 $
 
data_size = size(data);          % Obtains size of DATA
orig_data = data;
len = length(state);             % Obtains length of STATE

% --- Checks if DATA is 1-D column vector
if (data_size(1) == 1)
    data = data(:);              % Converts sequence in DATA to a column vector
    data_size = size(data);
end

% --- Error checking on input arguments
if isempty(data)
    error('comm:randdeintrlv:DataIsEmpty','DATA cannot be empty.')  
end

if (~isnumeric(data) && ~isa(data,'gf'))
    error('comm:randdeintrlv:DataIsNotNumeric','DATA must be numeric.');
end

if isempty(state)
    error('comm:randdeintrlv:StateIsEmpty','STATE cannot be empty.')  
end

if ~isnumeric(state)
    error('comm:randdeintrlv:StateIsNotNumeric','STATE must be numeric.')
end

if ((len ~= 1) || (len > 35))
    error('comm:randdeintrlv:InvalidState','STATE must be scalar or 35-by-1.')
end

rand('state',state);                    % Sets the current state of the uniform generator
int_vec = (randperm(data_size(1)));     % Returns a random permutation of the integers 1:data_size(2)

% --- Rearrange sequence of symbols
deintrlved = deintrlv(orig_data,int_vec);

% -- end of randdeintrlv ---