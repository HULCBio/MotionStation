function c=cslblockcount(varargin)
%Block Count
%   Counts the number of occurrences of each blocktype in the
%   current model or system.
%
%   See also CSL_MDL_LOOP, CSL_SYS_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:08 $

c=rptgenutil('EmptyComponentStructure','cslblockcount');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});


