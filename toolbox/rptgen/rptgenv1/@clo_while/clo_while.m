function c=clo_while(varargin)
%WHILE Loop
%   This component runs its subcomponents until its
%   "conditional string" is true.  The number of repetitions
%   can be limited to prevent infinite loops.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:38 $

c=rptgenutil('EmptyComponentStructure','clo_while');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});