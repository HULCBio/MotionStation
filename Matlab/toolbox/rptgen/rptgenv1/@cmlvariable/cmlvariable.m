function c=cmlvariable(varargin)
%Insert Variable in Report
%   This component draws a variable from the base
%   workspace and inserts it into the report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:36 $

c=rptgenutil('EmptyComponentStructure','cmlvariable');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

