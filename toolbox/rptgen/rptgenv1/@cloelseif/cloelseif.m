function c=cloelseif(varargin)
%<if> Else if
%   This component must be a child of an "if" component.
%
%   if
%     then
%     elseif
%     elseif
%     else
%
%   See also CLOIF CLOELSE CLOTHEN


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:52 $

c=rptgenutil('EmptyComponentStructure','cloelseif');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

