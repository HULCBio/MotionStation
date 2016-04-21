function c=csl_blk_proptable(varargin)
%Block Property Table
%   This component inserts a property-value pair table 
%   for the block defined by the Block Loop component.
%
%   See also RPTPROPTABLE, CSL_BLK_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:41 $

c=rptgenutil('EmptyComponentStructure','csl_blk_proptable');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
