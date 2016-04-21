function c=csl_mdl_proptable(varargin)
%Model Property Table
%   Inserts a property-value table for the model specified by
%   the Model Loop component.
%
%   See also CSL_MDL_LOOP, RPTPROPTABLE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:14 $

c=rptgenutil('EmptyComponentStructure','csl_mdl_proptable');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});