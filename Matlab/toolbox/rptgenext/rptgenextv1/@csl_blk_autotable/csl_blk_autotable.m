function c=csl_blk_autotable(varargin)
%Block Automatic Property Table
%   Creates a two-column property name/property value table.
%   In this table,  the property names are chosen automatically.
%   If the reported block is a "SubSystem" block, the table will
%   contain the MaskDialogParameters.  Otherwise, the 
%   table will contain the block's DialogParameters.  This is 
%   similar to the effect of %<SplitDialogParameters> in 
%   the Block Property Table.
%
%   See also CSL_BLK_LOOP, CSL_BLK_PROPTABLE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:05 $

c=rptgenutil('EmptyComponentStructure','csl_blk_autotable');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
