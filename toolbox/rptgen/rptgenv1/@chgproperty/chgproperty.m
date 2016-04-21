function c=chgproperty(varargin)
%   Handle Graphics Property
%   Inserts a single property/value pair from a Handle Graphics
%   figure, axis, or other object.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:31 $

c=rptgenutil('EmptyComponentStructure','chgproperty');
c=class(c,c.comp.Class,rptcomponent,zhgmethods);
c=buildcomponent(c,varargin{:});