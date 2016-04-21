function obj = addContents( obj,contents )

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:29 $
% Copyright 1984-2003 The MathWorks, Inc.

if ~isa(contents,'char');
    try
        contents = mat2str(contents);
    catch
        error(['Can''t convert data of type ' class(contents) ' to a char using MAT2STR.']);
    end
end

obj.contents = [obj.contents, {contents}];

