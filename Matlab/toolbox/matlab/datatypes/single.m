function [varargout] = single(varargin)
%SINGLE Convert to single precision.
%   Y = SINGLE(X) converts the vector X to single precision. X can be any
%   numeric object (such as a DOUBLE). If X is already single precision,
%   SINGLE has no effect.  Single precision quantities require less storage
%   than double precision quantities, but have less precision and a
%   smaller range. REALMAX('single') gives the uper bound for SINGLE while
%   REALMIN('single') is the smallest positive normalized SINGLE value.
%
%   Most operations that are defined on DOUBLE arrays are also defined for
%   SINGLE arrays. When SINGLE and DOUBLE arrays interact in arithmetic,
%   the type of the result is SINGLE.
%
%   You can define or overload your own methods for the SINGLE class (as you
%   can for any object) by placing the appropriately named method in an @single
%   directory within a directory on your path. 
%   See DATATYPES for the names of the methods you can overload.
%
%   A particularly efficient way to initialize a large SINGLE array is:
%
%       S = zeros(1000,1000,'single')
%
%   which creates a 1000x1000 element SINGLE array, all of whose entries are
%   zero. You can also use ONES and EYE in a similar manner.
%
%   Example:
%      X = pi * ones(5,6,'single')
%
%   See also DOUBLE, DATATYPES, UINT8, UINT16, UINT32, UINT64, INT8, INT16,
%   INT32, INT64, REALMIN, REALMAX, EYE, ONES, ZEROS, ISFLOAT, ISNUMERIC.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.4 $  $Date: 2004/03/08 02:02:07 $
%   Built-in function.

if nargout == 0
  builtin('single', varargin{:});
else
  [varargout{1:nargout}] = builtin('single', varargin{:});
end
