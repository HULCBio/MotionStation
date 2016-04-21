function c=csllinktarget(varargin)
%Object Linking Anchor
%   This component designates the location to which
%   other links point. Certain components which list
%   subsystems, models, blocks, or signals will
%   automatically link to this location if the link
%   target is inserted.
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:22 $

c=rptgenutil('EmptyComponentStructure','csllinktarget');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});


