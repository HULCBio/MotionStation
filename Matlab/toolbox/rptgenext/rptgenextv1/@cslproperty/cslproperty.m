function c=cslproperty(varargin)
%Object Property
%   Inserts as text a single property-value pair for a
%   Simulink object.  The object to query can be specified
%   by the user or determined from context.
%
%   See also CSL_MDL_LOOP, CSL_SYS_LOOP, CSL_BLK_LOOP, CSL_SIG_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:29 $

c=rptgenutil('EmptyComponentStructure','cslproperty');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
