function ext=extent(txtobj)
%EXTENT Obtains platform independent text extent property.
%   EXT = EXTENT(TXTOBJ) returns the four element vector representing
%   the size of the smallest rectangle encompassing the given text
%   object.
%
%   This function is OBSOLETE and may be removed in future versions.
%
%   See also GET and TEXT.

%   P. Barnard 2-6-96
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:24:43 $

% Error checking.
if nargin < 1
   error('Text object handle must be supplied.')
end

if ~strcmp(get(txtobj, 'type'), 'text')
   error('Argument must be a text object.')
end

% Return the extent of the given text object.
ext = get(txtobj,'extent');

