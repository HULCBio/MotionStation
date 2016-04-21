function c=csf_truthtable(varargin)
%Truth Table
%  Inserts truth table contents into the report

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:44 $


c=rptgenutil('EmptyComponentStructure','csf_truthtable');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
