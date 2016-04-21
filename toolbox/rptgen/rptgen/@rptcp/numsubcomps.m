function nsc=numsubcomps(p)
%NUMSUBCOMPS returns the number of subcomponents the component has

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:53 $

nsc=length(get(p.h,'Children'));