function A=subsasgn(A,S,B)
%SUBSASGN subscripted assignment

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:53 $

d=rgstoredata(A);
if isempty(d)
   d=initialize(A,'-noinitialize');
end

d=subsasgn(d,S,B);
rgstoredata(A,d);