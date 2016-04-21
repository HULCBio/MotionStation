function A = subsasgn(A,S,B)
%SCRIBEHGOBJ/SUBSASGN Subscripted assignment for scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:13:32 $

switch S.type
case '.'
   switch S.subs
   case 'HGHandle'
      A.HGHandle = B;
   case 'IsSelected'
      A.ObjSelected = B;
   otherwise
      A = set(A,S.subs,B);
   end
case '()'
   % I don't think this works...
   structA = struct(A);
   structA(S.subs{:}) = struct(B);
   A = class(A,'scribehgobj');
end

