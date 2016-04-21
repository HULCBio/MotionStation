function B=subsref(A,S)
%SUBSREF  subscripted reference

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:25 $


d = rgstoredata(A);

if isempty(d)
    d = rgstoredata(A,'','initialize');
end

B=subsref(d,S);


