function [varargout] = ge(varargin)
%>=  Greater than or equal.
%   A >= B does element by element comparisons between A and B
%   and returns a matrix of the same size with elements set to one
%   where the relation is true and elements set to zero where it is
%   not.  A and B must have the same dimensions unless one is a
%   scalar. A scalar can be compared with anything.
%
%   C = GE(A,B) is called for the syntax 'A >= B' when A or B is an
%   object.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:07:45 $

if nargout == 0
  builtin('ge', varargin{:});
else
  [varargout{1:nargout}] = builtin('ge', varargin{:});
end
