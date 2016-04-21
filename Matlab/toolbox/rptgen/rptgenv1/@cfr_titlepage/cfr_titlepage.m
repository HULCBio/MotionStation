function c=cfr_titlepage(varargin)
%   Title Page
%   This component creates a title page at the beginning
%   of the report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:59 $

c=rptgenutil('EmptyComponentStructure','cfr_titlepage');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

