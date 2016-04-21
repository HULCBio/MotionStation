function c=csfobjname(varargin)
%Object Name
%   This component allows the user to insert the name
%   of the Stateflow object being reported. It must be
%   parented by Stateflow Hierarchy or Chart Loop or 
%   Stateflow Object Report component.
%
%   This component is commonly used as the first 
%   subcomponent of a "Section" component, allowing the
%   section title to be drawn from the current Stateflow
%   object
%
%   See also CSF_HIER_LOOP, CFRSECTION

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:58 $

c=rptgenutil('EmptyComponentStructure','csfobjname');
c=class(c,c.comp.Class,rptcomponent,zslmethods, zsfmethods);
c=buildcomponent(c,varargin{:});