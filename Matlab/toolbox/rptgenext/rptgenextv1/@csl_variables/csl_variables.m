function c=csl_variables(varargin)
%Model Variables
%   Creates a table listing all workspace variables used by
%   reported blocks in the current model.  The current
%   model and the systems in which reported blocks 
%   appear are specified in the Model Loop component.
%
%   See also CSL_MDL_LOOP, CSL_FUNCTIONS


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:01 $

c=rptgenutil('EmptyComponentStructure','csl_variables');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});

