function A=subsasgn(A,S,B)
%SUBSASGN subscripted assignment

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:20 $

RPTGENDATA=rgstoredata(A);
RPTGENDATA=builtin('subsasgn',RPTGENDATA,S,B);
rgstoredata(A,RPTGENDATA);
