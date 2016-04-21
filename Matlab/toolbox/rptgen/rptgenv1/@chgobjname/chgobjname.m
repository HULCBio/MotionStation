function c=chgobjname(varargin)
%   Graphics Object Name
%   Inserts the name of a graphics object into the report
%   as text.  This component is useful in defining section
%   title names based on the current figure.
%
%   Names can be inserted from:
%     Figures - "name" property
%     Axes - title
%     Other Objects - strings (where available) or tags
%
%   See also CHGFIGLOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:24 $

c=rptgenutil('EmptyComponentStructure','chgobjname');
c=class(c,c.comp.Class,rptcomponent,zhgmethods);
c=buildcomponent(c,varargin{:});


