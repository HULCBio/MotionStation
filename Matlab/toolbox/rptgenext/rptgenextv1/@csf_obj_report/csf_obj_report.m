function c=csf_obj_report(varargin)
% Stateflow object report
%    This component passes the thread of execution to the 
%    children only if the object currently being reported
%    is of a certain type (which is set on the attribute
%    page). This component must be a child of the Stateflow 
%    Loop.
%
%    Attribute page parameters:    
%          object type
%          minimal number of children required for report
%


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:15 $

c=rptgenutil('EmptyComponentStructure','csf_obj_report');
c=class(c,c.comp.Class,rptcomponent,zslmethods,zsfmethods);
c=buildcomponent(c,varargin{:});