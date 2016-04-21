function mech_register_cg_target(targetfile, fcn)
%MECH_REGISTER_CG_TARGET - Register a code generation target file with SimMechanics
%  MECH_REGISTER_CG_TARGET(TARGETFILE) registers TARGETFILE as a supported target
%  for SimMechanics.
%
%  MECH_REGISTER_CG_TARGET(TARGETFILE, FCN) registers TARGETFILE as a supported
%  target for SimMechanics.  Call FCN passes the model name when generating code
%  for TARGETFILE.
  
% $Revision: 1.1.6.2 $ $Date: 2003/04/10 05:16:07 $ $Author: batserve $
% Copyright 2003 The MathWorks, Inc.
  ;
  error(nargchk(1, 2, nargin, 'struct'));
  if (nargin < 2)
    fcn = [];
  end
  
  mech_target_manager('register', targetfile, fcn);
  
% [EOF] mech_register_cg_target.m
