function c=cfp_blk_proptable(varargin)
%Block Property Table
%   This component inserts a property-value pair table 
%   which reports on Fixed-Point blocks.
%
%   See also RPTPROPTABLE, CFP_BLK_LOOP

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:55:27 $

c=rptgenutil('EmptyComponentStructure','cfp_blk_proptable');
c=class(c,c.comp.Class,rptcomponent,rptfpmethods);
c=buildcomponent(c,varargin{:});
