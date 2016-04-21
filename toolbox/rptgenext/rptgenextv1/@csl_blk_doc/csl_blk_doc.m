function c=csl_blk_lookup(varargin)
%Block Type: Lookup Table
%   This component will report on 1-D and 2-D lookup table
%   blocks.  The component will insert a figure and/or a
%   table into the report.  The table contains numeric values
%   and the figure plots the data graphically.
%   

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:19 $

c=rptgenutil('EmptyComponentStructure','csl_blk_doc');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
