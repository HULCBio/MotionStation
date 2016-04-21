function c=cslsysname(varargin)
%Object Name
%   This component allows the user to insert the name
%   of a Simulink object object.  The name of the 
%   current model, system, block, or signal can be
%   inserted into the report.  The object type to
%   insert can also be determined from context.
%
%   This component is commonly used as the first 
%   subcomponent of a "Section" component, allowing the
%   section title to be drawn from the current model
%   or system.
%
%   See also CSL_MDL_LOOP, CSL_SYS_LOOP, CFRSECTION

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:11 $

c=rptgenutil('EmptyComponentStructure','cslsysname');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});