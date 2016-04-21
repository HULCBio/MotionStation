% Mu-Analysis and Synthesis Toolbox
% Version 3.0.8 (R14) 05-May-2004
%
% New Features.
%   Readme      - Important release information about the Mu-analysis and 
%                 Synthesis Toolbox (Type "whatsnew directoryname",
%                 i.e. "whatsnew mutools/commands" to display this file)
%
% Standard Operations/Basic Functions
%
%    abv       - Stack constant/varying/system matrices above one another
%    cjt       - Conjugate transpose of varying/system matrices
%    daug      - Diagonal augmentation of constant/varying/system matrices
%    madd      - Addition of constant/varying/system matrices
%    minv      - Inverse of constant/varying/system matrices
%    mmult     - Multiplication of constant/varying/system matrices
%    mscl      - Scale (by a scalar) a system or varying matrix
%    msub      - Subtraction of constant/varying/system matrices
%    sbs       - Stack matrices next to one another
%    sclin     - Scale system input
%    sclout    - Scale system output
%    sel       - Select rows/columns or outputs/inputs
%    starp     - Redheffer star product
%    transp    - Transpose of varying/system matrices
%
% Matrix Information, Display and Plotting
%
%    drawmag   - Interactive mouse-based sketch and fitting tool
%    minfo     - Information on a matrix
%    mprintf   - Formatted printing of a matrix
%    rifd      - Display real, imaginary, frequency and damping data
%    see       - Display varying/system matrices
%    seeiv     - Display independent variables of a varying matrix
%    seesys    - Formatted varying/system display
%    vplot     - Plot a varying matrix
%    vzoom     - Mouse driven axis selection of plot window
%    wsgui     - Graphical workspace manipulation tool
%
% Modeling Functions
%
%    fitsys    - Fit frequency response data with transfer function
%    nd2sys    - Convert a SISO transfer function into a system matrix
%    pck       - Create a system matrix from state-space data (A, B, C, D)
%    pss2sys   - Convert an [A B;C D] matrix into a mu-tools system matrix
%    sys2pss   - Extract state-space matrix [A B; C D] from a system matrix
%    sysic     - System interconnection program
%    unpck     - Extract state-space data (A,B,C,D) from a system matrix
%    zp2sys    - Convert transfer function poles and zeros to a system matrix
%
% System Matrix Functions
%
%    reordsys  - Reorder states in a system matrix
%    samhld    - Sample-hold approximation of a continuous system
%    spoles    - Poles of system matrix
%    statecc   - Apply a coordinate transformation to system matrices
%    strans    - Bidiagonal coordinate transformation of system matrices
%    sysrand   - Generate a random system matrix
%    szeros    - Transmission zeros of a system matrix
%    tustin    - Prewarped continuous to discrete system transformation
%
% Model Reduction Functions
%
%    hankmr    - Optimal Hankel norm approximation of a system
%    sdecomp   - Decompose a system matrix into two system matrices
%    sfrwtbal  - Frequency weighted balanced realization of a system matrix
%    sfrwtbld  - Stable frequency weighted realization of a system matrix
%    sncfbal   - Balanced realization of coprime factors of a system matrix
%    srelbal   - Stochastic balanced realization of a system matrix
%    sresid    - Residualize states of a system matrix
%    strunc    - Truncate states of a system matrix
%    sysbal    - Balanced realization of a system matrix
%
% System Response Functions
%
%    cos_tr    - Generate a cosine signal as a varying matrix
%    dtrsp     - Discrete time response of a linear system
%    frsp      - Frequency response of a system matrix
%    sin_tr    - Generate a sine signal as a varying matrix
%    sdtrsp    - Sample data time response of a linear system
%    siggen    - Generate a signal as a varying matrix
%    simgui    - Graphical linear system simulation tool
%    step_tr   - Generate a step signal as a varying matrix
%    trsp      - Time response of a linear system
%
% H_2 and H_infinity Analysis and Synthesis Functions
%
%    dhfsyn    - Discrete time H-infinity control design
%    dhfnorm   - Calculate discrete time infinity-norm of a stable system
%    emargin   - gap metric robust stability
%    gap       - Calculate the gap metric between systems
%    h2norm    - Calculate 2-norm of a stable, strictly proper system
%    h2syn     - H_2 control design
%    hinffi    - H_infinity full information control design
%    hinfnorm  - Calculate H_infinity norm of a stable, proper system
%    hinfsyn   - H_infinity control design
%    hinfsyne  - H_infinity, minimum entropy control design
%    linfnorm  - calculates L_infinity norm of proper system
%    ncfsyn    - H_infinity loopshaping control design
%    nugap     - Calculate the nu-gap metric between systems
%    pkvnorm   - Peak (across Independent variable) norm of varying matrix
%    sdhfsyn   - Sampled-data H_infinity (induced L_2 norm) control design
%    sdhfnorm  - Sampled-data H_infinity-norm (induced L_2) of stable system
%
% Structured Singular Value (mu) Analysis and Synthesis
%
%    blknorm   - Block norm of constant/varying matrices
%    cmmusyn   - Constant matrix, mu-synthesis
%    dkit      - Automated D-K iteration
%    dkitgui   - Graphical DK iteration Tool
%    dypert    - Create a rational perturbation from frequency mu data
%    fitmag    - Fit magnitude data with real, rational, transfer function
%    fitmaglp  - Fit magnitude data with real, rational, transfer function
%    genmu     - Upper bound for Generalized-Mu
%    genphase  - Generate a minimum phase frequency response to magnitude data
%    magfit    - Fit magnitude data with real, rational, transfer function
%    msf       - D-scale fitting for DK iteration
%    msfbatch  - Batch version of msf
%    mu        - mu-analysis of constant/varying matrices
%    muftbtch  - Batch D-scale fit routine (grandfathered - use msfbatch)
%    musynfit  - Interactive D-scale rational fit (grandfathered - use msf)
%    musynflp  - Interactive D-scale rational fit (grandfathered - use msf)
%    muunwrap  - extract data from mu calculation
%    randel    - Generate a random perturbation
%    sisorat   - First order, all-pass interpolation
%    unwrapd   - Construct D scaling from mu
%    unwrapp   - Construct Delta perturbation from mu
%    wcperf    - Worst-Case performance curves and perturbations
%
% Varying Matrix Manipulation
%
%    getiv     - Get the independent variable of a varying matrix
%    indvcmp   - Compare the independent variable data of two matrices
%    massign   - Assign elements of a matrix
%    scliv     - Scale the independent variable
%    sortiv    - Sort the independent variable
%    tackon    - String together varying matrices
%    var2con   - Convert a varying matrix to a constant matrix
%    varyrand  - Generate a random varying matrix
%    vpck      - Pack a varying matrix
%    vunpck    - Unpack a varying matrix
%    xtract    - Extract portions of a varying matrix
%    xtracti   - Extract portions of  a varying matrix
%
% Standard MATLAB Commands for Varying Matrices
%
%    vabs      - Absolute value of a constant/varying matrix
%    vceil     - Round elements of  constant/varying matrices towards infinity
%    vdet      - Determinant of constant/varying matrices
%    vdiag     - Diagonal of  constant/varying matrices
%    veig      - Eigenvalue decomposition of constant/varying matrices
%    vexpm     - Exponential of  constant/varying matrices
%    vfft      - FFT for varying matrices
%    vfloor    - Round elements of  constant/varying matrices towards -infinity
%    vifft     - Inverse FFT for varying matrices
%    vinv      - Inverse of a constant/varying matrix
%    vimag     - Imaginary part of a constant/varying matrix
%    vnorm     - Norm of varying/constant matrices
%    vpoly     - Characteristic polynomial of constant/varying matrices
%    vpinv     - Pseudoinverse of a constant/varying matrix
%    vrank     - Rank of a constant/varying matrix
%    vrcond    - Condition number of a constant/varying matrix
%    vreal     - Real part of a constant/varying matrix
%    vroots    - Polynomial roots of constant/varying matrices
%    vschur    - Schur form of a constant/varying matrix
%    vspect    - Signal Processing spectrum command for varying matrices
%    vsqrtm    - Matrix square root for constant/varying matrices
%    vsvd      - Singular value decomposition of a constant/varying matrix
%
% Additional Varying Matrix Functions
%
%    vcjt      - Conjugate transpose of constant/varying matrices
%    vcond     - Condition number of constant/varying matrices
%    vconj     - Complex conjugate of constant/varying matrices
%    vdcmate   - Decimate varying matrices
%    vebe      - Element-by-element operations on varying matrices
%    veberec   - Element-by-element reciprocal
%    veval     - Evaluate general functions of varying matrices
%    vveval    - Evaluate general functions of varying matrices
%    mveval    - Evaluate general functions of varying matrices
%    vfind     - Find across independent variable
%    vinterp   - Interpolate varying matrices
%    vldiv     - Left division of constant/varying matrices
%    vrdiv     - Right division of constant/varying matrices
%    vrho      - Spectral radius of a constant/varying matrix
%    vtp       - Transpose of constant/varying matrices
%    vtrace    - Trace of constant/varying matrices
%
% Utilities and Miscellaneous Functions
%
%    add_disk  - Adds unit disk to the Nyquist plot
%    cf2sys    - Create matrix from normalized coprime factors
%    clyap     - Continuous Lyapunov equation
%    crand     - Complex random matrix generator, uniform
%    crandn    - Complex random matrix generator, normalized
%    csord     - Order complex Schur form matrices
%    mfilter   - Create Butterworth, Bessel, RC filters
%    negangle  - Calculate angle of matrix elements between 0 and -2 pi
%    ric_eig   - Solve a Riccati equation via eigenvalue decomposition
%    ric_schr  - Solve a Riccati equation via real Schur decomposition
%    unum      - input dimension
%    xnum      - state dimension
%    ynum      - output dimension
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc. 

