function mm = reshape(mm,size)
% RESHAPE(MM,SIZE) Changes the dimension or/and dimension size of MM.
% 
% RESHAPE(MM,[]) does not change the existing SIZE property of MM.
% 
% Example: If 'x' is an embedded symbol,
%          mm = symobj(cc,'x')
%          and if 'mm.read' gives [4 5]
%          reshape(mm,[2 2]) will give
%          [4 5; 2 3]
% 
%   Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:10:10 $

error(nargchk(2,2,nargin));
if ~ishandle(mm),
    error('First Parameter must be a NUMERIC Handle.');
end
if ~isnumeric(size),
    error('SIZE must be a numeric.');
end

if ~isempty(size),
    mm.size = size;
    % else, use existing size info
end

% [EOF] reshape.m