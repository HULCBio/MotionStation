function r = horner(p)
%HORNER Horner polynomial representation.
%   HORNER(P) transforms the symbolic polynomial P into its Horner,
%   or nested, representation.
%
%   Example:
%       horner(x^3-6*x^2+11*x-6) returns
%           x*(x*(x-6)+11)-6

%   See Also SIMPLIFY, SIMPLE, FACTOR, COLLECT.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 03:09:09 $

r = maple('map','convert',p,'horner');
