function c=cmlwhos(varargin)
%List of Current Variables
%   Creates a table which includes all variables in the
%   MATLAB workspace.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:43 $

c=rptgenutil('EmptyComponentStructure','cmlwhos');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});


