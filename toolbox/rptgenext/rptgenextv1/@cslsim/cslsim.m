function c=cslsim(varargin)
%Model Simulate
%   Runs the current model using the simulation parameters
%   specified in the component.  Current model is defined by
%   the Model Loop component.
%
%   See also CSL_MDL_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:43 $

c=rptgenutil('EmptyComponentStructure','cslsim');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
