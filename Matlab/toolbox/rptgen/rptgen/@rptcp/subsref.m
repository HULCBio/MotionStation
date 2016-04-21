function B=subsref(A,S)
%SUBSREF subscripted reference
%   RPTCP can be accessed in a variety of ways
%   p.h gives the pointer list
%   p.h(i) gives handle i in the pointer list
%   p.ref    allows direct access to component 1
%   p(i).ref allows direct access to component i
%
%   Note that p{i} no longer works.  Use subset(p,i)
%   instead.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:04 $

if ischar(S(1).subs) & S(1).subs(1)=='h'
   if length(S)>1
      B=builtin('subsref',A.h,S(2:end));
   else 
      B=A.h;
   end
elseif strcmp(S(1).type,'{}')
    S(1).type='()';
    B=rptcp(builtin('subsref',A.h,S));
else
    if strcmp(S(1).type,'.')
        subsIndex=1;
    else
        subsIndex=S(1).subs{1};
        S=S(2:end);
    end
    B=get(A.h(subsIndex),'UserData');
    if ~isempty(S)
        B=subsref(B,S);   
    end      
end