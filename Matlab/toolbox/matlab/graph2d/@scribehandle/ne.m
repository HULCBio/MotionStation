function val = ne(a,b)
%SCRIBEHANDLE/NE Test inequality for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:13:12 $

S.type = '.';
S.subs = 'HGHandle';

if iscell(a) | length(a)>1
   aH = subsref(a,S);
   aH = [aH{:}];
elseif ~isempty(a)
   if isa(a,'scribehandle')
      aH = a.HGHandle;
   else
      aH = a;
   end
else
   aH = [];
end
if iscell(b) | length(b)>1
   bH = subsref(b,S);
   bH = [bH{:}];
elseif ~isempty(b)
   if isa(b,'scribehandle')
      bH = b.HGHandle;
   else
      bH = b;
   end
else
   bH = [];
end

val = aH ~= bH;

