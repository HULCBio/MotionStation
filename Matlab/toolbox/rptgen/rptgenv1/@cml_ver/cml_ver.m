function c=cml_ver(varargin)
%List of Program Versions
%   Creates a table which includes all registered
%   MATLAB programs and their version number.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:22 $

c=rptgenutil('EmptyComponentStructure','cml_ver');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});


