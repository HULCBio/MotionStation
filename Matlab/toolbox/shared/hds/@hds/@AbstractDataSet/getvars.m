function [v,dv] = getvars(this)
%GETVARS  Gathers data-holding variables.
%
%   [ROOTVARS,DEPENDVARS] = GETVARS(D) returns the list ROOTVARS of 
%   variables in the root node D, and the list DEPENDVARS of all 
%   variables in dependent data sets linked to D.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:11 $

% Root node variables
v = get(this.Data_,{'Variable'});
v = cat(1,v{:});

% Dependent variables
if nargout>1
   dv = get(this.Children_,{'LinkedVariables'});
   % REVISIT: workaround empty handles being [0x1] double
   dv = dv(cellfun('length',dv)>0);
   dv = cat(1,dv{:});
end