function c=csl_functions(varargin)
%Model Functions
%   Creates a table listing all functions used by
%   reported blocks in the current model.  The current
%   model and the systems in which reported blocks 
%   appear are specified in the Model Loop component.
%
%   See also CSL_MDL_LOOP, CSL_VARIABLES

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:49 $

c=rptgenutil('EmptyComponentStructure','csl_functions');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
