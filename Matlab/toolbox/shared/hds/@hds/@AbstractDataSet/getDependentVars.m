function dv = getDependentVars(this)
% Gets list of dependent variables (all variables visible through data
% links.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:03 $
if isempty(this.Children_)
   dv = [];
else
   dv = get(this.Children_,{'LinkedVariables'});
   % REVISIT: workaround empty handles being [0x1] double
   dv = dv(cellfun('length',dv)>0);
   dv = cat(1,dv{:});
end