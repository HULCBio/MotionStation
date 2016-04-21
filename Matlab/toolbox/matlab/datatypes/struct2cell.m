function [varargout] = struct2cell(varargin)
%STRUCT2CELL Convert structure array to cell array.
%   C = STRUCT2CELL(S) converts the M-by-N structure S (with P fields)
%   into a P-by-M-by-N cell array C.
%
%   If S is N-D, C will have size [P SIZE(S)].
%
%   Example:
%     clear s, s.category = 'tree'; s.height = 37.4; s.name = 'birch';
%     c = struct2cell(s); f = fieldnames(s);
%
%   See also CELL2STRUCT, FIELDNAMES.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/10 23:25:35 $
%   Built-in function.

if nargout == 0
  builtin('struct2cell', varargin{:});
else
  [varargout{1:nargout}] = builtin('struct2cell', varargin{:});
end
