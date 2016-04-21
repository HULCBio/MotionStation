function out = isequal(varargin)
%ISEQUAL True if instrument object arrays are equal.
%
%   ISEQUAL(A,B) is 1 if the two instrument object arrays are the same
%   size and are equal, and 0 otherwise.
%
%   ISEQUAL(A,B,C,...) is 1 if all the instrument object arrays are the
%   same size and are equal, and 0 otherwise.
% 

%   MP 9-15-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.6.2.3 $  $Date: 2004/01/16 20:01:05 $

% Error checking.
if nargin == 1
    error('instrument:isequal:minrhs', 'Not enough input arguments.');
end

% Loop through all the input arguments and compare to each other.
for i=1:nargin-1
    obj1 = varargin{i};
    obj2 = varargin{i+1};
    
    % Return 0 if either arguments are empty.
    if isempty(obj1) || isempty(obj2)
        out = logical(0);
        return;
    end
    
    % Inputs must be the same size.
    if ~(all(size(obj1) == size(obj2))) 
        out = logical(0);
        return;
    end
    
    % Call @instrument\eq.
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