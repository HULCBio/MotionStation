function obj = addAttribute(obj,name,value)

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:27 $
% Copyright 1984-2003 The MathWorks, Inc.

obj.attributes = [obj.attributes {{name,value}}];