function out=runcomponent(c,arg2)
%RUNCOMPONENT  Executes a Report Generator component
%   RUNCOMPONENT(N,C) runs subcomponent N of component C
%   RUNCOMPONENT(C) runs component C.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:17 $

if nargin<2
   arg2=[];
end

if isa(c,'double') & isa(arg2,'rptcomponent')
   myChild=children(arg2);
   out=runcomponent(myChild{c});
elseif isa(c,'rptcomponent')
   out=runcomponent(rptcp(c));
else
   error('Error - bad syntax for runcomponent')
end