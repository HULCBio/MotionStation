function c=cfrcelltable(varargin)
%   Cell Table
%   This component converts a cell array into a table
%   in the report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:06 $

c=rptgenutil('EmptyComponentStructure','cfrcelltable');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

