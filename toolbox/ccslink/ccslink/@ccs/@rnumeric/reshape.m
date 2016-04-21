function rr = reshape(rr,size)
%RESHAPE Change the SIZE property of a REGISTEROBJ object.
% 	RESHAPE(RR,SIZE) Changes the dimension or/and dimension size of RR.
% 	
% 	RESHAPE(RR,[]) does not change the existing SIZE property of RR.
% 	
% 	NOTE: For a registerobj, the SIZE property is always equal to 1.
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:11:45 $


error(nargchk(2,2,nargin));
if ~ishandle(rr),
    error('First Parameter must be a RNUMERIC Handle.');
end
if ~isnumeric(size),
    error('SIZE must be a numeric.');
elseif prod(size)>1
    error('Cannot reshape. SIZE of a Register Object is always a scalar.');
end

if ~isempty(size),
    rr.size = size;
    % else, use existing size info
end

% [EOF] reshape.m
