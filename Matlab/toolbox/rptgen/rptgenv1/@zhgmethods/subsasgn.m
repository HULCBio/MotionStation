function A=subsasgn(A,S,B)
%SUBSASGN subscripted assignment

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:48 $

hgData=rgstoredata(A);
if isempty(hgData)
   hgData=initialize(A);
end

hgData=builtin('subsasgn',hgData,S,B);
rgstoredata(A,hgData);