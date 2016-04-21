function c=crgempty(varargin)
%Empty Component
%   This component does not insert anything into the report
%   and can contain children.  It can be used to group components
%   together for easy moving and deactivation.  It can also be
%   used as a blank space in a list.
%
%   If the Report Generator does not recognize a component when
%   loading a setup file, it will replace the unrecognized
%   component with the empty component.  This component will appear
%   in the outline as
%      [-] <Empty> - was "componentname"

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:11 $

c=rptgenutil('EmptyComponentStructure','crgempty');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

