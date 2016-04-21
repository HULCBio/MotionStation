function a = struct2array(s)
%STRUCT2ARRAY Convert structure with doubles to an array.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:50:27 $

error(nargchk(1,1,nargin));

% Convert structure to cell
c = struct2cell(s);

% Construct an array
a = [c{:}];

