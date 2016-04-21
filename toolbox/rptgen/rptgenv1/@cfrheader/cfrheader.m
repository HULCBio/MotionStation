function c=cfrheader(varargin)
%   Header
%   Inserts a non-structural "BridgeHead" into the
%   report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:13 $

c=rptgenutil('EmptyComponentStructure','cfrheader');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});