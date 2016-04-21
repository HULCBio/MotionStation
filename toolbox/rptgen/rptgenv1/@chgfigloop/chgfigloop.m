function c=chgfigloop(varargin)
%   Graphics Figure Loop
%   This component repeats its subcomponents several
%   times for each Handle Graphics figure selected by
%   the user.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:02 $

c=rptgenutil('EmptyComponentStructure','chgfigloop');
c=class(c,c.comp.Class,rptcomponent,zhgmethods);
c=buildcomponent(c,varargin{:});