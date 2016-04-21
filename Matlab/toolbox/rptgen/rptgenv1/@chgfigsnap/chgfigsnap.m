function c=chgfigsnap(varargin)
%   Figure Snapshot
%   Inserts an image of a figure window into the report.  The
%   figure window which is inserted is defined in the Figure
%   Loop.
%
%   See also CHGFIGLOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:18 $

c=rptgenutil('EmptyComponentStructure','chgfigsnap');
c=class(c,c.comp.Class,rptcomponent,zhgmethods);
c=buildcomponent(c,varargin{:});