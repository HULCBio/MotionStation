function c=cloif(varargin)
%Logical IF
%
%   if
%     then
%     elseif
%     elseif
%     else
%
%   See also CLOELSE, CLOELSEIF, CLOTHEN, CLOFOR, CLO_WHILE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:07 $

c=rptgenutil('EmptyComponentStructure','cloif');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

