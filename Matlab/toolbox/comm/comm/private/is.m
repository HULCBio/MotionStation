function out = is(a, varargin)
%IS Logical test.
%   is(a, 'scalar') returns true if a is a scalar. A scalar is defined as a
%   Matlab array without any dimension larger than 1.
%
%   is(a, 'vector') returns true if a is a vector. A vector is defined as a
%   Matlab array with at most 1 dimension longer than 1.
%
%   is(a, 'real') returns true if all elements of a are real numbers.
%
%   is(a, 'positive') returns true if all elements of a are positive
%   numbers.
%
%   is(a, 'nonnegative') returns true if all elements of a are nonnegative
%   numbers. You can also spell non-negative.
%
%   is(a, 'integer') returns true if all elements of a are integers.
%
%   is(a, 'positive integer') returns true if all elements of a are
%   positive integers.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:40:14 $

if (nargin < 2)
    error('IS requires at least 2 arguments.')
end
switch lower(varargin{1})
    case 'scalar'
        out = length(a)<=1;
    case 'vector'
        out = sum(size(a)>1)<=1;
    case 'real'
        out = isnumeric(a) && isreal(a);
    case 'positive'
        out = is(a, 'real') && all(a>0);
    case {'nonnegative', 'non-negative'}
        out = is(a, 'real') && all(a>=0);
    case 'integer'
        out = is(a, 'real') && all(a==round(a));
    case 'positive integer'
        out = is(a, 'positive') && is(a, 'integer');
    otherwise
        error('Unsupported test.')
end
