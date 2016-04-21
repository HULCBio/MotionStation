function c=csl_sys_proptable(varargin)
%System Property Table
%   This component creates a property-value pair table
%   for the system defined in the System Loop component.
%
%   See also CSL_SYS_LOOP, RPTPROPTABLE


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:53 $

c=rptgenutil('EmptyComponentStructure','csl_sys_proptable');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});

