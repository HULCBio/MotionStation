function out = isequal(varargin)
%ISEQUAL True if data acquisiton object arrays are valid and equal.
%
%    ISEQUAL(A,B) is 1 if the data acquisition objects are the same 
%    size and are equal, and 0 otherwise.
% 
%    ISEQUAL(A,B,C,...) is 1 if all the input arguments are equal.
%    
%    See also ISEQUAL.

%    DK 02-05-02
%    Copyright 1998-2003 The MathWorks, Inc. 
%    $Revision: 1.2.2.4 $  $Date: 2003/08/29 04:40:25 $

% Verify that more than one argument is passed in
if nargin == 1
    error('daq:isequal:argcheck', 'Not enough input arguments.');
end

% Loop through all the input arguments and compare to each other.
for i=1:nargin-1
	obj1 = varargin{i};
	obj2 = varargin{i+1};
	
	% Return False if either input arguments are empty. 
	if (any(isempty(obj1)) || any(isempty(obj2)))
		out = logical(0);
		return;
	end
	
	% Return FALSE if either input arguments is not valid.
	if (any(~isvalid(obj1)) || any(~isvalid(obj2)))
		out = logical(0);
		return;
	end
	
	% Return False if Inputs are not the same size.
	if ~all((size(obj1) == size(obj2)))
		out = logical(0);
		return;
	end
	
	% Call @daqchild\eq.
	out = eq(obj1, obj2);
	
	% If not equal, return 0 otherwise loop and compare obj2 with 
	% the next object in the list.
	if (all(out) == 0)
		out = logical(0);
		return;
	end
end

% Return just a 1 or 0.  
% Ex. isequal(obj, obj)  where obj = [s s s]
% eq returns [1 1 1] isequal returns 1.
out = all(out);