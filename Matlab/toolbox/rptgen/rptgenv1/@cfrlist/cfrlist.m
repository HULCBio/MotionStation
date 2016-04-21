function c=cfrlist(varargin)
%   List
%   Inserts a list into the report.  The list can be
%   taken from a cell array or built from subcomponents.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:33 $

c=rptgenutil('EmptyComponentStructure','cfrlist');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

