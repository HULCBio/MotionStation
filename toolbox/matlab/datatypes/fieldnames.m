function [varargout] = fieldnames(varargin)
%FIELDNAMES Get structure field names.
%   NAMES = FIELDNAMES(S) returns a cell array of strings containing 
%   the structure field names associated with the structure s.
%
%   NAMES = FIELDNAMES(Obj) returns a cell array of strings containing 
%   the names of the public data fields associated with Obj, which 
%   is either a MATLAB or a Java object.
%
%   NAMES = FIELDNAMES(Obj, '-full') returns a cell array of strings 
%   containing the name, type, attributes, and inheritance of each 
%   field associated with Obj, which is either a MATLAB or a Java object.
%   
%   See also ISFIELD, GETFIELD, SETFIELD, ORDERFIELDS, RMFIELD.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $  $Date: 2004/04/10 23:25:16 $
%   Built-in function.

if nargout == 0
  builtin('fieldnames', varargin{:});
else
  [varargout{1:nargout}] = builtin('fieldnames', varargin{:});
end
