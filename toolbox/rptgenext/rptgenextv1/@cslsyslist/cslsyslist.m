function c=cslsyslist(varargin)
%System Hierarchy
%   Creates a nested list which shows the hierarchy of
%   systems.  The list can display all systems in a model
%   or it can show the immediate parents and children of
%   the current system.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:05 $

c=rptgenutil('EmptyComponentStructure','cslsyslist');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});