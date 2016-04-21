function c=csflinktarget(varargin)
%Object Linking Anchor
%   This component designates the location to which
%   other links point. Certain components which list
%   Stateflow objects will automatically link to 
%   this location if the link target is inserted.
%
%   This component must be parented by Chart Loop,
%   Stateflow Loop or Object Report component.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:51 $

c=rptgenutil('EmptyComponentStructure','csflinktarget');
c=class(c,c.comp.Class,rptcomponent,zslmethods, zsfmethods);
c=buildcomponent(c,varargin{:});


