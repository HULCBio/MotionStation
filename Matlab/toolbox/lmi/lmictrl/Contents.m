% LMI Control Toolbox
% Version 1.0.9 (R14) 05-May-2004
%
%             A. Analysis and Design Tools
%             ----------------------------
%
% Nominal performance measures.
%    norminf     - RMS/Hinf gain in continuous time.
%    dnorminf    - RMS/Hinf gain in discrete time.
%    norm2       - H2-norm of continuous-time systems.
%
% Robustness analysis.
%    quadstab    - Quadratic stability.
%    quadperf    - Quadratic Hinf performance.
%    pdlstab     - Robust stability via parametric Lyapunov functions.
%    popov       - Popov criterion for robust stability.
%    decay       - Quadratic decay rate.
%    mubnd       - Upper bound on the structured singular value.
%    mustab      - Robust stability margin (mu).
%    muperf      - Robust Hinf performance (mu).
%
% Hinf design - continuous time.
%    msfsyn      - Multi-objective state-feedback design.
%    hinflmi     - LMI-based Hinf design.
%    hinfmix     - Mixed H2/Hinf design with pole placement.
%    lmireg      - Specification of LMI regions for pole placement.
%    hinfric     - Riccati-based Hinf design.
%
% Hinf design - discrete time.
%    dhinflmi    - LMI-based Hinf design.
%    dhinfric    - Riccati-based Hinf design.
%
% Loop shaping
%    magshape    - GUI for shaping filter specification.
%    sconnect    - Specification of general control loops.
%    frfit       - Rational fit of frequency response data.
%
% Gain scheduling
%    hinfgs      - Gain-scheduled Hinf design.
%    pdsimul     - Time response along a given parameter trajectory.
%
% Demos
%    sateldem    - State-feedback control of a satellite attitude.
%    radardem    - Loop-shaping design for a radar antenna.
%    misldem     - Gain-scheduled control of a missile autopilot.
%
%
%          B. Manipulation of Uncertain Linear Systems
%          -------------------------------------------
%
% Linear time-invariant systems.
%    ltisys      - Store a state-space model as a SYSTEM matrix.
%    ltiss       - Extract state-space data from a SYSTEM matrix.
%    ltitf       - Compute the transfer function of a SISO system.
%    islsys      - Test if input is a SYSTEM matrix.
%    sinfo       - System characteristics.
%    sresp       - Frequency response of a system.
%    spol        - Get system poles.
%    ssub        - Extract a subsystem.
%    sinv        - Compute the inverse of a system.
%    sbalanc     - Numerically balance a state-space realization.
%    splot       - Plot time and frequency responses.
%
% Polytopic or parameter-dependent systems (P-systems).
%    psys        - Specify a P-system.
%    psinfo      - Inquire about a P-system.
%    ispsys      - Test if input is a P-system.
%    pvec        - Specify a vector of uncertain or time-varying parameters.
%    pvinfo      - Read a parameter vector description.
%    polydec     - Polytopic coordinates wrt. the parameter box corners.
%    aff2pol     - Conversion affine/polytopic for P-systems.
%    pdsimul     - Simulation of P-systems along parameter trajectories.
%
% Dynamical uncertainty.
%    ublock      - Specify an uncertainty block.
%    udiag       - Specify block-diagonal uncertainty.
%    uinfo       - Display block-diagonal uncertainty descriptions.
%    aff2lft     - Linear-fractional representation of affine P-systems.
%
% Interconnection of systems.
%    sdiag       - Append linear systems.
%    sderiv      - Applies proportional-derivative action.
%    sadd        - Parallel interconnection of systems.
%    smult       - Series interconnection of systems.
%    sloop       - Elementary feedback loop.
%    slft        - Linear-fractional feedback interconnections.
%    sconnect    - Specification of general control loops.
%

% Auxilliary functions.
%    care        - Solver for continuous-time Riccati equations
%    dare        - Solver for discrete-time Riccati equations
%    hinfpar     - Extract A,B1,B2,... from the plant SYSTEM matrix
%    (d)goptric  - Gamma-iterations (Riccati-based)
%    (d)goptlmi  - Hinf optimization (LMI-based)
%    kric        - Central Hinf controller (Riccati-based)
%    klmi        - Central Hinf controller (LMI-based)
%    dkcen       - Central Hinf controller (discrete-time)
%    parrott     - Static Hinf - Parrott problem
%    ricpen      - Generalized Riccati solver (continuous-time)
%    dricpen     - Generalized Riccati solver (discrete-time)
%    schrcomp    - Schur complement of a symmetric matrix
%    lnull       - Left null space
%    rnull       - Right null space
%    mdiag       - Form block-diagonal matrices

% Copyright 1995-2004 The MathWorks, Inc. 
