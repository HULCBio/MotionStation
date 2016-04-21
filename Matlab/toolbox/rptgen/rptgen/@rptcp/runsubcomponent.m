function out=runsubcomponent(p,GenStatusRank)
%RUNSUBCOMPONENT run components during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:58 $

if nargin<2
   GenStatusRank=5;
end

out=runcomponent(p);
delete(p);