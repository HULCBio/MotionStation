function B = changem(A, newval, oldval)

%CHANGEM  Substitute values in a data array.
%
%   B = CHANGEM(A,NEWVAL), for scalar NEWVAL, replaces all zero-valued
%   entries in A with NEWVAL.
%
%   B = CHANGEM(A,NEWVAL,OLDVAL) replaces all occurrences of NEWVAL(k) in A
%   with OLDVAL(k).  NEWVAL and OLDVAL must match in size.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $    $Date: 2003/12/13 02:50:11 $

if nargin <= 1
     error('Incorrect number of input arguments')
elseif nargin == 2
     oldval = zeros(size(newval));  % Probably should throw a warning here.
end

%  Test that old and new value arrays have the same number of elements.
if numel(newval) ~= numel(oldval)
    error('Inconsistent sizes for old and new code inputs')
end

B = A;
for k = 1:numel(newval)
    B(A == oldval(k)) = newval(k);
end
