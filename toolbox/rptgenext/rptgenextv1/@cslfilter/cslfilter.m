function c=cslfilter(varargin)
%System Filter
%   The System Filter component runs its subcomponents
%   only if certain conditions are met by the current
%   system.
%
%   See also CSL_SYS_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:15 $

c=rptgenutil('EmptyComponentStructure','cslfilter');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});