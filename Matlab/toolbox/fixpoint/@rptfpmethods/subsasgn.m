function A=subsasgn(A,S,B)
%SUBSASGN

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:16 $

d=rgstoredata(A);
if isempty(d)
   d=initialize(A);
end

d=subsasgn(d,S,B);
rgstoredata(A,d);