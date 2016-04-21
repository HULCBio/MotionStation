function c=clothen(varargin)
%<if> then
%   This component must be a child of an "if" component.
%
%   if
%     then
%     else
%
%   if
%     then
%     elseif
%     elseif
%     else
%
%   See also CLOIF, CLOELSEIF, CLOELSE, CLOFOR, CLO_WHILE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:15 $

c=rptgenutil('EmptyComponentStructure','clothen');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});


