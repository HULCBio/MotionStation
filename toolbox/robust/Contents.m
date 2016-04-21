% Robust Control Toolbox
% Version 2.0.10 (R14) 05-May-2004
%
% New Features.
%   Readme      - Important release information about the Robust Toolbox
%                 (Type "whatsnew directoryname",
%                  i.e. "whatsnew robust" to display this file).
%
% Optional System Data Structure.
%    branch    - extract branches from a tree.
%    graft     - add a branch to a tree.
%    issystem  - identify a system variable.
%    istree    - identify a tree variable.
%    mksys     - build tree variable for system.
%    tree      - build a tree variable.
%    vrsys     - returns standard system variable names.
%
% Model Building.
%    augss     - plant augmentation (for state space models).
%    augtf     - plant augmentation (for transfer functions).
%    interc    - general multivariable interconnected system.
%
% Model Conversions.
%    bilin     - multivariable bilinear transformation.
%    des2ss    - convert descriptor system to system state space via SVD.
%    lftf      - linear fractional transformation.
%    sectf     - sector transformation.
%    stabproj  - stable/antistable projection.
%    slowfast  - slow/fast decomposition.
%    tfm2ss    - convert transfer functions to state-space models.
%
% Utility.
%    aresolv   - generalized continuous time Riccati solver.
%    daresolv  - generalized discrete time Riccati solver.
%    riccond   - continuous time Riccati equation condition number.
%    driccond  - discrete time Riccati equation condition number.
%    blkrsch   - block ordered real Schur form via cschur.
%    cschur    - ordered complex Schur form via complex Givens rotation.
%
% Multivariable Bode Plot.
%    cgloci    - continuous characteristic gain loci.
%    dcgloci   - discrete characteristic gain loci.
%    dsigma    - discrete singular-value Bode plot.
%    muopt     - SSV upper bound for system with mixed real/complex uncertainty.
%                (Michael Fan's MUSOL4)
%    osborne   - SSV upper bound via Osborne method.
%    perron    - Perron eigenstructure SSV.
%    psv       - Perron eigenstructure SSV.
%    sigma     - continuous singular-value Bode plot.
%    ssv       - structure singular value Bode plot.
%
% Factorization Techniques.
%    iofc      - inner-outer factorization (column type).
%    iofr      - inner-outer factorization (row type).
%    sfl       - left spectral factorization.
%    sfr       - right spectral factorization.
%
% Model Reduction Methods.
%    balmr     - truncated balanced model reduction.
%    bstschml  - relative error Schur model reduction.
%    bstschmr  - relative error Schur model reduction.
%    imp2ss    - impulse response to state-space realization.
%    obalreal  - ordered balanced realization.
%    ohklmr    - optimal Hankel minimum degree approximation.
%    schmr     - Schur model reduction.
%
% Robust Control Synthesis Methods.
%    h2lqg     - continuous time H_2 synthesis.
%    dh2lqg    - discrete time H_2 synthesis.
%    hinf      - continuous time H_infinity synthesis.
%    dhinf     - discrete time H_infinity synthesis.
%    hinfopt   - gamma-iteration of H_infinity synthesis.
%    normh2    - calculate H_2 norm.
%    normhinf  - calculate H_infinity norm.
%    lqg       - LQG optimal control synthesis.
%    ltru      - LQG loop transfer recovery.
%    ltry      - LQG loop transfer recovery.
%    youla     - Youla parameterization.
%
% Demonstration.
%    accdemo   - spring-mass benchmark problem.
%    dintdemo  - H_infinity design for double-integrator plant.
%    hinfdemo  - H_2 & H_infinity design examples.
%                   fighter & large space structure.
%    ltrdemo   - LQG/LTR design examples -fighter.
%    mudemo    - mu-synthesis examples.
%    mudemo1   - mu-synthesis examples.
%    mrdemo    - robust model reduction examples.
%    rctdemo   - robust control toolbox demo - main menu.
%    musldemo  - MUSOL4 demo.

% Copyright 1988-2004 The MathWorks, Inc.
