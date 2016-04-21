% Contents of the previous (obsolete) version of the MPC Toolbox
%
% Identification
%  autosc   - Automatically scales a matrix by its mean and standard deviation.
%  imp2step - Combines MISO impulse response models to form
%               MIMO models in MPC step format.
%  mlr      - Calculates MISO impulse response model via
%               multivariable linear regression.
%  plsr     - Calculates MISO impulse response model via
%               partial least squares regression.
%  rescal   - Converts scaled data back to its original form.
%  scal     - Scale a matrix by specified means and standard deviations.
%  validmod - Validate a MISO impulse response model using new data.
%  wrtreg   - Writes data matrices used for regression.
%
% Model Conversions
%  mod2mod  - Changes sampling period of a model in MPC mod format.
%  mod2ss   - Converts a model in MPC mod format to a state-space model.
%  mod2step - Converts a model in MPC mod format to MPC step format.
%  poly2tfd - Converts a transfer function in poly format to MPC tf format.
%  ss2mod   - Converts a state-space model to MPC mod format.
%  ss2step  - Converts a state-space model to MPC step format.
%  tfd2mod  - Converts a model in MPC tf format to MPC mod format.
%  tfd2step - Converts a  model in MPC tf format to MPC step format.
%  th2mod   - Converts a model in the theta format (Identification Toolbox)
%		into MPC mod format.
%
% Model Building - MPC mod format
%  addmod   - Combines two models such that the output of one adds to the
%               input of the other.
%  addmd    - Adds one or more measured disturbances to a plant model.
%  addumd   - Adds one or more unmeasured disturbances to a plant model.
%  appmod   - Appends two models in an unconnected, parallel structure.
%  paramod  - Puts two models in parallel such that they share a common output.
%  sermod   - Puts two models in series.
%
% Controller Design and Simulation - MPC step format
%  cmpc     - Solves the quadratic programming problem to simulate performance
%		of a closed-loop system with input and output constraints.
%  mpccl    - Creates a model in MPC mod format of a closed-loop system with
%		an unconstrained MPC controller.
%  mpccon   - Calculates the unconstrained controller gain matrix for MPC.
%  mpcsim   - Simulates a closed-loop system with optional saturation
%		constraints on the manipulated variables.
%  nlcmpc   - S-function for masked block nlcmpc
%  nlmpclib - library which contains masked blocks nlcmpc and nlmpcsim
%  nlmpcsim - S-function for masked block nlmpcsim
%
% Controller Design and Simulation - MPC mod format
%  scmpc    - Solves the quadratic programming problem to simulate performance
%		of a closed-loop system with input and output constraints.
%  smpccl   - Creates a model in MPC mod format of a closed-loop system with
%		an unconstrained MPC controller.
%  smpccon  - Calculates the unconstrained controller gain matrix for MPC.
%  smpcest  - Designs a state estimator for use in MPC.
%  smpcsim  - Simulates a closed-loop system with optional saturation
%		constraints on the manipulated variables.
%
% Analysis
%  mod2frsp - Calculates frequency response for a system in MPC mod format.
%  smpcgain - Calculates steady-state gain matrix of a system in MPC mod format.
%  smpcpole - Calculates poles of a system in MPC mod format.
%  svdfrsp  - Calculates singular values of a frequency response.
%
% Plotting and Matrix Information
%  mpcinfo  - Outputs matrix type and attributes of system representation.
%  plotall  - Plots outputs and inputs from a simulation run on one graph.
%  plotfrsp - Plots the frequency response of a system as a Bode plot.
%  ploteach - Makes separate plots of outputs and/or inputs from a simulation
%		run.
%  plotstep - Plots the coefficients of a model in MPC step form.
%
% Utility Functions
%  abcdchkm - Checks dimensional consistency of A,B,C,D matrices.
%  cp2dp    - Converts from a continuous to a discrete transfer function in
%		poly format.
%  c2dmp    - Discretize continuous systems.
%  dantzgmp - Solves quadratic programs.
%  dareiter - Solves discrete Riccati equation by an iterative method.
%  dimpulsm - Generates impulse response of discrete system.
%  dlqe2    - Calculates state-estimator gain matrix for discrete systems.
%  dlsimm   - Simulates discrete systems.
%  d2cmp    - Converts discrete systems to continuous systems.
%  mpcaugss - Augments a state-space model with its outputs.
%  mpcparal - Puts two state-space models in parallel.
%  mpcstair - Creates the `stairstep' format used to plot manipulated variables.
%  parpart  - Partition parameters for nlmpcssim and nlcmpc.
%  ss2tf2   - Convert state-space models to transfer functions.
%  tf2ssm   - Convert transfer functions to state-space models.
%

%     Copyright 1994-2004 The MathWorks, Inc.

