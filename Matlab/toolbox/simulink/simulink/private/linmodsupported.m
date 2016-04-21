function errmsg = linmodsupported(model)
%LINMODSUPPORTED determines if a model is supported by linmod, dlinmod, trim ...
%   A string is returned.  If the string is empty, then the model is supported.
%   If the string is not empty, then the string explains why the model is
%   not supported.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.4 $

errmsg = '';

%
% models with fixed point blocks are NOT supported
%
followLinks = 1;
if fixpt_blks_in_mdl(model,followLinks)
  errmsg = 'This model is not suitable for linearization because it contains Fixed-Point Blocks.';
  return
end
