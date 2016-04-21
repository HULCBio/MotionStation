function items = strfind(str,pat)
%STRFIND Find pattern in a cell array of strings.
%   [ITEMS]=STRFIND(STR,PAT)
%   Implementation of STRFIND for cell arrays of strings.  Returns a cell array,
%   ITEMS, of the same shape as STR, containing all starting positions of PAT
%   in each cell of STR.
%
%   INPUT PARAMETERS:
%       STR:  cell array of strings.
%       PAT:  char vector
%
%   RETURN PARAMETERS:
%       ITEMS: cell array of double arrays, of size of STR. 
%
%   See STRFIND for more information.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%------------------------------------------------------------------------------
% initialise variables
items = cell(0);

% handle input
% verify number of input arguments
if ~isempty (nargchk(2,2,nargin))
    error('MATLAB:strfind:Nargin',nargchk(2,2,nargin));
end
% check empty input arguments
if isempty(str)
    return; 
end

% check input class
if ~(iscellstr(str) && ischar(pat))
  error('MATLAB:strfind:InputClass',...
      ['If any of the input arguments are cell arrays, the first must be\n'...
	  'a cell array of strings and the second must be a character array.'])
end

% reserve memory for output parameter
items = cell(size(str));
% iteratively find string in cell array
for i = 1:numel(str)
    items{i} = strfind(str{i},pat);
end
%------------------------------------------------------------------------------