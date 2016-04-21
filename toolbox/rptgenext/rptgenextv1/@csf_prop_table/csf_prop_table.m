function c=csf_prop_table(varargin)
% Stateflow property table
%    This component inserts a property-value table for 
%    Stateflow objects.  It must be parented by a Stateflow 
%    object report. 
%
%    Different properties and preset tables are selectable 
%    depending on the context set by the parent.
%
%    See also RPTPROPTABLE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:22 $

c=rptgenutil('EmptyComponentStructure','csf_prop_table');
c=class(c,c.comp.Class,rptcomponent, zslmethods, zsfmethods);
c=buildcomponent(c,varargin{:});
