function mgr = mech_stateVectorMgr(sys)
% MECH_STATEVECTORMGR  Construct an instance of the MECH.StateVectorMgr class
%   MACHINESTATE = MECH_STATEVECTORMGR(GCB) or MECH_STATEVECTORMGR(GCBH) 
%   constructs a state vector manager object for SimMechanics machine models.
%   Select a SimMechanics block in the Simulink model window first, then
%   enter the command. A Machine state object is returned for the machine
%   containing that SimMechanics block.
%
%   You can substitute the name or handle of a SimMechanics block for
%   the argument GCB or GCBH.
%
%   The N components of the machine state are counted as follows:
%
%      2 components (position, velocity) for each prismatic and revolute primitive
%      8 components (quaternion, quaternion derivative) for each spherical primitive
%      1 component (curve parameter derivative) for each Point-Curve Constraint block
%
%   Weld primitives and motion-actuated joint primitives are not counted.
%
%   The output object MACHINESTATE has these properties:
%
%      MACHINESTATE.MachineName: string 'modelname/rootgroundblock', where
%                                'rootgroundblock' is the Ground block in the machine
%                                'modelname' that serves as the machine's root
%
%      MACHINESTATE.X:           1 x N real array indicating number of state vector
%                                components (not actual machine state)
%
%      MACHINESTATE.BlockStates: array of N block state managers for each
%                                prismatic, revolute, and spherical, and
%                                each Point-Curve Constraint
%
%      MACHINESTATE.StateNames:  array of N strings = names of all primitives
%                                and Point-Curve Constraints
%
%   Example
%     Open Demo Library model SPEN.MDL, select a SimMechanics block, and
%     enter STATEVECTORMGR command, which returns:
%
%         MECH.StateVectorMgr
%
%         MachineName: 'spen/Ground'
%                   X: [0 0]
%         BlockStates: [1x1 MECH.RPJointStateMgr]
%          StateNames: {2x1 cell}
%
%     Query object properties such as MACHINESTATE.MACHINENAME, MACHINESTATE.X, etc.
%
%   See also GCB, GCBH, GCS

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2004/04/16 22:16:56 $

  ;
  %
  % check the argument, supply default if necessary
  %
  if (nargin < 1)
    hdl = gcbh;
  else
    hdl = get_param(sys, 'Handle');
  end

  cs = mech_cleanup;
  try,
    mgr = state_vector_mgr(hdl);
  catch
    %
    % handle any errors by stripping of any stack
    % and throwing a new error
    %
    cs();
    rethrow(lasterror);
  end
  cs();
  
% [EOF] mech_stateVectorMgr.m
