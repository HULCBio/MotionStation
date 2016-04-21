function c=cloelse(varargin)
%<if> Else
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
%   See also CLOIF CLOELSEIF CLOTHEN


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:45 $

c=rptgenutil('EmptyComponentStructure','cloelse');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

