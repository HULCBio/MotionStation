function added = mech_addenvblock(sys)
% MECH_ADDENVBLOCK  Add Machine Environment block(s) to an existing SimMechanics model. 
%   HANDLES = MECH_ADDENVBLOCK(GCS) or MECH_ADDENVBLOCK('MODELNAME')
%   adds the one or more necessary Machine Environment blocks to an
%   existing SimMechanics model without them. The added Machine
%   Environment blocks inherit mechanical environment data from the model's
%   old Mechanical Environment Settings dialog.
%
%   Each topologically distinct machine in a SimMechanics model requires
%   exactly one Machine Environment block attached to one of that
%   machine's Ground blocks. This command locates a Ground in each machine
%   in a model, enables the Machine Environment port for that Ground,
%   inserts a Machine Environment block, and connects it to the Ground.
%
%   If a machine already has the necessary Machine Environment block,
%   this command skips over it. If the model has no SimMechanics blocks,
%   no blocks are added.
%
%   HANDLES is a returned vector whose components are the block handles of
%   the new Machine Environment blocks.  If no Machine Environment blocks are 
%   added, HANDLES is empty.

% Copyright 1998-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/16 22:16:11 $ $Author: batserve $

  added = [];
  error(nargchk(1, 1, nargin, 'struct'));
  sys = get_param(sys, 'Handle');
  try
    added = mech_add_env_block_impl(sys);
  catch
    rethrow(lasterror);
  end
  
% [EOF] mech_addenvblock.m