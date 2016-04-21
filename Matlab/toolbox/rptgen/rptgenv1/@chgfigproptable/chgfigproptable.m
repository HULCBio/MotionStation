function c=chgfigproptable(varargin)
%   Figure Property Table
%   Creates a property-value table for Handle Graphics
%   figures.  The figure from which the table draws its
%   P-V pairs is specified in the Graphics Figure Loop.
%
%   See also CHGFIGLOOP, RPTPROPTABLE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:10 $

c=rptgenutil('EmptyComponentStructure','chgfigproptable');
c=class(c,c.comp.Class,rptcomponent,zhgmethods);
c=buildcomponent(c,varargin{:});




