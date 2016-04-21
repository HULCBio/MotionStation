function [varargout] = cell2struct(varargin)
%CELL2STRUCT Convert cell array to structure array.
%   S = CELL2STRUCT(C,FIELDS,DIM) converts the cell array C into
%   the structure S by folding the dimension DIM of C into fields of
%   S.  SIZE(C,DIM) must match the number of field names in FIELDS.
%   FIELDS can be a character array or a cell array of strings.
%
%   Example:
%     c = {'tree',37.4,'birch'};
%     f = {'category','height','name'};
%     s = cell2struct(c,f,2);
%
%   See also STRUCT2CELL, FIELDNAMES.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/10 23:25:15 $
%   Built-in function.

if nargout == 0
  builtin('cell2struct', varargin{:});
else
  [varargout{1:nargout}] = builtin('cell2struct', varargin{:});
end
