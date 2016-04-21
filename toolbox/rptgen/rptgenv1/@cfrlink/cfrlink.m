function c=cfrlink(varargin)
%   Link
%   Inserts linking anchors or pointers into the report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:26 $

c=rptgenutil('EmptyComponentStructure','cfrlink');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});