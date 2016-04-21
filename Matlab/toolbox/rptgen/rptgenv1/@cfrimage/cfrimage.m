function c=cfrimage(varargin)
%   Image
%   Inserts a reference to an external image file into
%   the report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:20 $


c=rptgenutil('EmptyComponentStructure','cfrimage');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});