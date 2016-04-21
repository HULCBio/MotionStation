% Examples and demonstrations.
%
%   Type 'demo' at the command line to browse more demos of
%   MATLAB, the Toolboxes, and Simulink.
%
%   demo              - Run demonstrations. 
% 
% Mathematics.
%   intro             - Basic Matrix Operations
%   inverter          - Inverses of Matrices
%   buckydem          - Graphs and Matrices
%   sparsity          - Sparse Matrices
%   matmanip          - Matrix Manipulation
%   integerMath       - Integer Arithmetic Examples
%   singleMath        - Single Precision Arithmetic, Linear Algebra Examples, and Working with Nondouble Datatypes
%   eigmovie          - Symmetric eigenvalue movie.
%   rrefmovie         - Movie of the computation of the reduced row echelon form.
%   delsqdemo         - Finite Difference Laplacian
%   sepdemo           - Orderings and Separators for a Finite Element Mesh
%   airfoil           - Graphical Representation of Sparse Matrices
%   eigshow           - Graphical demonstration of eigenvalues and singular values.
%   odedemo           - Differential Equations in MATLAB
%   odeexamples       - Browse ODE/DAE/IDE/BVP/PDE examples.
%   hndlgraf          - Demonstrates Handle Graphics for line plots in MATLAB.
%   fitdemo           - Optimal Fit of a Non-linear Function
%   sunspots          - Using FFT in MATLAB
%   e2pi              - Graphical Approach to Solving Inequalities
%   bench             - MATLAB Benchmark
%   fftdemo           - FFT for Spectral Analysis
%   census            - Predicting the US Population 
%   spline2d          - Splines in Two Dimensions
%   lotkademo         - Numerical Integration of Differential Equations
%   quake             - Loma Prieta Earthquake
%   qhulldemo         - Tessellation and Interpolation of Scattered Data
%   expmdemo          - Matrix Exponentials
%   expmdemo1         - Matrix exponential via Pade approximation.
%   expmdemo2         - Matrix exponential via Taylor series.
%   expmdemo3         - Matrix exponential via eigenvalues and eigenvectors.
%
% Programming.
%   funfuns           - Function Functions
%   nesteddemo        - Nested Function Examples
%   anondemo          - Anonymous Function Examples
%   textscanDemo      - Reading Arbitrary Format Text Files with textscan
%   nddemo            - Manipulating Multidimensional Arrays
%   strucdem          - Structures
%
% Graphics.
%   graf2d            - XY plots in MATLAB.
%   graf2d2           - XYZ plots in MATLAB.
%   graf3d            - Demonstrate Handle Graphics for surface plots in MATLAB.
%   hndlaxis          - Demonstrates Handle Graphics for axes in MATLAB.
%   lorenz            - Plot the orbit around the Lorenz chaotic attractor.
%   imageext          - Examples of images with a variety of colormaps
%   vibes             - Vibrating L-shaped membrane.
%   xpsound           - Demonstrate MATLAB's sound capability.
%   imagedemo         - Images and Matrices
%   penny             - Viewing a Penny
%   earthmap          - Earth's Topography
%   xfourier          - Square Wave from Sine Waves
%   cplxdemo          - Functions of Complex Variables
%   ardemo            - Interactive axes properties demonstration
%
% 3-D Visualization.
%   xpklein           - Klein bottle
%   teapotdemo        - A demo that uses the famous Newell teapot
%   transpdemo        - Changing Transparency
%   volvec            - Volume Visualization in MATLAB.
%
% Gallery.
%   modes             - Modes
%   logo              - Logo
%   wernerboy         - Werner Boy's Surface
%   knot              - Three-Dimensional Knot
%   quivdemo          - Quiver
%   klein1            - Klein Bottle
%   cruller           - Cruller
%   tori4             - Four Linked Tori
%   spharm2           - Spherical Surface Harmonic 
%
% Other Demos.
%   fifteen           - A sliding puzzle of fifteen squares and sixteen slots.
%   xpbombs           - Play the minesweeper game.
%   life              - MATLAB's version of Conway's Game of Life.
%   soma              - display precomputed solutions to Piet Hein's soma cube
%   truss             - Animation of a bending bridge truss.
%   travel            - Traveling salesman problem demonstration.
%   xpquad            - Superquadrics plotting demonstration.
%   codec             - Coder/Decoder
%   makevase          - Generate and plot a surface of revolution.
%   wrldtrv           - Show great circle flight routes around the globe.
%   quatdemo          - Quaternion demonstration.
%   superquad         - Barr's "superquadrics" ellipsoid.
%   mlcomiface        - Programming with COM


% Demo infrastructure
%   demos             - Start DEMO.
%   demowin           - Display demo information in the Help window
%   indexhelper       - A helper function for the demos index page.
%   convertdemostodom - returns the contents of all demos.m files as DOMs.
%   finddemo          - Search for paths containing Demos.m, Demos.mat and set
%   playbackdemo      - Launch demo playback device
%   evalmcw           - Evaluates a list of functions in a editable text uicontrol.
%   makeshow          - Make slideshow demo.
%   playshow          - Plays a slideshow-style demo.
%   ssdisp            - Display text from the Slide Show format.
%   sshow             - A slide show shell.
%   ssinit            - Initialize the Slide Show figure
%   sspause           - Pause function for the Slide Show format.
%   cmdlnbgn          - Sets up for calling command line demos from DEMO.
%   cmdlnend          - Cleans up after command line demos called after CMDLNBGN.
%   cmdlnwin          - A demo gateway routine for playing command line demos.
%   xppage            - A function for setting up a page of text.
%   xpsubplt          - Create axes in tiled positions.
%   xptext            - An EXPO helper function to create text in figure windows.
%   watchoff          - Sets the current figure pointer to the arrow.
%   watchon           - Sets the current figure pointer to the watch.
%
% Helper functions.
%   peaks             - A sample function of two variables.
%   humps             - A function used by QUADDEMO, ZERODEMO and FPLOTDEMO.
%   membrane          - Generates the MATLAB logo.
%   bucky             - Connectivity graph of the Buckminster Fuller geodesic dome.
%   xycrull           - Function that returns the coordinate functions
%   xyklein           - Coordinate functions for the figure-8 that
%   tube              - Generating function for Edward's parametric curves.
%   inside            - Points inside a polygonal region in the plane.
%   lotka             - Lotka-Volterra predator-prey model.
%   cplxgrid          - Polar coordinate complex grid.
%   cplxmap           - Plot a function of a complex variable.
%   cplxroot          - Riemann surface for the n-th root.
%   delsq             - Construct five-point finite difference Laplacian.
%   e_handler         - Copyright 1984-2002 The MathWorks, Inc.
%   strucdem_helper   - Draws pictures for STRUCDEM.
%   fitfun            - Used by FITDEMO.
%   flow              - A simple function of 3 variables.
%   imtext            - Place possibly multi-line text as xlabel.
%   fibodemo          - Used by SINGLEMATH demo.
%   makecounter       - Used by NESTEDDEMO.
%   taxDemo           - Used by NESTEDDEMO.
%   makefcn           - Used by NESTEDDEMO.
%   nestdiss          - Recursive function used by NESTED.
%   nested            - Nested dissection ordering.
%   numgrid           - Number the grid points in a two dimensional region.
%   sepplot           - Used by SEPDEMO to show the separators.
%   somasols          - Solutions to the SOMA cube.
%   spiral            - (n) is an n-by-n matrix with elements ranging
%   spypart           - Spy plot with partitioning.
%
% ODEs
%   vanderpoldemo     - Defines the van der Pol equation for ODEDEMO.
%   vdp1              - Evaluate the van der Pol ODEs for mu = 1
%   vdp1000           - Evaluate the van der Pol ODEs for mu = 1000.
%   weissinger        - Evaluate the residual of the Weissinger implicit ODE
%   ballode           - Run a demo of a bouncing ball.  
%   batonode          - Simulate the motion of a thrown baton.
%   brussode          - Stiff problem modelling a chemical reaction (the Brusselator).
%   burgersode        - Burgers' equation solved using a moving mesh technique.
%   fem1ode           - Stiff problem with a time-dependent mass matrix, M(t)*y' = f(t,y).
%   fem2ode           - Stiff problem with a constant mass matrix, M*y' = f(t,y).
%   hb1ode            - Stiff problem 1 of Hindmarsh and Byrne.
%   orbitode          - Restricted three body problem.
%   rigidode          - Euler equations of a rigid body without external forces.
%   vdpode            - Parameterizable van der Pol equation (stiff for large MU).
%   twobc             - Evaluate the residual in the boundary conditions for TWOBVP. 
%   twoode            - Evaluate the differential equations for TWOBVP. 
%
% DAEs
%   hb1dae            - Stiff differential-algebraic equation (DAE) from a conservation law.
%   amp1dae           - Stiff differential-algebraic equation (DAE) from electrical circuit.
%
% Fully Implicit Differential Equations
%   iburgersode       - Burgers' equation solved as implicit ODE system
%   ihb1dae           - Stiff differential-algebraic equation (DAE) from a conservation law.
%
% DDEs
%   ddex1             - Example 1 for DDE23.
%   ddex2             - Example 2 for DDE23.
%   ddex1de           - Example of delay differential equations for solving with DDE23.
%   ddex1hist         - A history function for using with DDEX1DE.
%
% BVPs   
%   twobvp            - Solve a BVP that has exactly two solutions.
%   mat4bvp           - Find the fourth eigenvalue of the Mathieu's equation.
%   shockbvp          - The solution has a shock layer near x = 0
%   fsbvp             - Continuation by varying an end point.
%   emdenbvp          - Solve BVP with singular term.
%   threebvp          - Three-point boundary value problem
%
% PDEs   
%   pdex1             - Example 1 for PDEPE
%   pdex2             - Example 2 for PDEPE
%   pdex3             - Example 3 for PDEPE
%   pdex4             - Example 4 for PDEPE
%   pdex5             - Example 5 for PDEPE
%   pde               - Copyright 1984-2002 The MathWorks, Inc.
%   pdex1bc           - Evaluate the boundary conditions for the problem coded in PDEX1.
%   pdex1ic           - Evaluate the initial conditions for the problem coded in PDEX1.
%   pdex1pde          - Evaluate the differential equations components for the PDEX1 problem.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.29.4.6 $  $Date: 2004/03/22 23:53:48 $ 
