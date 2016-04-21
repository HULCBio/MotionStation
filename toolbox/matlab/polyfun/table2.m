function z = table2(tab,x0,y0)
%TABLE2 2-D table look-up.
%   Z = TABLE2(TAB,X0,Y0) returns a linearly interpolated
%   intersection from 2-D table TAB, looking up X0 in the first
%   column and Y0 in the first row of TAB.  TAB is a matrix that
%   contains key values in the first row and column and the data in
%   remaining block of the matrix.  The first row and column must be
%   monotonic.  The key at TAB(1,1) is ignored.
%
%   Example:
%      tab = [NaN 1:4; (1:4)' magic(4)];
%      y = table2(tab,1:4,1:4)
%   is an expensive way to produce y = magic(4).
%
%   The TABLE2 function is OBSOLETE, use INTERP2 instead.
%
%   See also INTERP2, TABLE1.

%   Paul Travers 7-14-87
%   Revised JNL 3-15-89
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.12 $  $Date: 2002/04/15 04:25:03 $

warning('MATLAB:table2:ObsoleteFunction',['TABLE2 is obsolete and ' ...
        'will be removed in future versions.  Use INTERP2 instead.'])

if (nargin ~= 3), error('Must be used with three input arguments.'), end

[m,n] = size(tab);
a = table1(tab(2:m,:),x0);
tab2 = [tab(1,2:n).' a.'];
z = table1(tab2,y0).';
