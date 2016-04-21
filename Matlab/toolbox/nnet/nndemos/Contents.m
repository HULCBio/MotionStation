% Neural Network Demonstrations.
%
% Neural Network Toolbox Demonstrations and Applications
% ------------------------------------------------------
%
% Perceptrons
%   demop1   - Classification with a 2-input perceptron.
%   demop4   - Outlier input vectors.
%   demop5   - Normalized perceptron rule
%   demop6   - Linearly non-separable vectors.
% 
% Adaptive Linear Filters
%   demolin1 - Pattern association showing error surface.
%   demolin2 - Training a linear neuron.
%   demolin4 - Linear fit of nonlinear problem.
%   demolin5 - Underdetermined problem.
%   demolin6 - Linearly dependent problem.
%   demolin7 - Too large a learning rate. 
%   demolin8 - Adaptive noise cancellation.
%
% Backpropagation - See Neural Network Design Demos below.
%
% Radial Basis Networks
%   demorb1  - Radial basis approximation.
%   demorb3  - Radial basis underlapping neurons.
%   demorb4  - Radial basis overlapping neurons.
%   demogrn1 - GRNN function approximation.
%   demopnn1 - PNN classification.
%
% Self-Organizing Maps
%   democ1   - Competitive learning.
%   demosm1  - One-dimensional self-organizing map.
%   demosm2  - Two-dimensional self-organizing map.
%
% Learning Vector Quantization
%   demolvq1 - Learning vector quantization.
%
% Recurrent Networks
%   demohop1 - Hopfield two neuron design.
%   demohop2 - Hopfield unstable equilibria.
%   demohop3 - Hopfield three neuron design.
%   demohop4 - Hopfield spurious stable points.
%
% Applications
%   applin1  - Linear design.
%   applin2  - Adaptive linear prediction.
%   appelm1  - Elman amplitude detection
%   appcr1   - Character recognition.
%
% Simulink
%   predcstr - Predictive control of a tank reactor.
%   narmamaglev - NARMA-L2 control of a magnet levitation system.
%   mrefrobotarm - Reference control of a robot arm.
%
%
% Neural Network Design Textbook Demonstrations.
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% Used by permission.
% ---------------------------------------------
% General
%   nnd      - Splash screen.
%   nndtoc   - Table of contents.
%   nnsound  - Turn Neural Network Design sounds on and off.
%
% Chapter 2, Neuron Model and Network Architectures
%   nnd2n1   - One-input neuron demonstration.
%   nnd2n2   - Two-input neuron demonstration.
%
% Chapter 3, An Illustrative Example
%   nnd3pc   - Perceptron classification demonstration.
%   nnd3hamc - Hamming classification demonstration.
%   nnd3hopc - Hopfield classification demonstration.
%
% Chapter 4, Perceptron Learning Rule
%   nnd4db   - Decision boundaries demonstration.+
%   nnd4pr   - Perceptron rule demonstration.+
%
% Chapter 5, Signal and Weight Vector Spaces
%   nnd5gs   - Gram-Schmidt demonstration.
%   nnd5rb   - Reciprocal basis demonstration.
%
% Chapter 6, Linear Transformations for Neural Networks
%   nnd6lt   - Linear transformations demonstration.
%   nnd6eg   - Eigenvector game.
%
% Chapter 7, Supervised Hebbian Learning
%   nnd7sh   - Supervised Hebb demonstration.
%
% Chapter 8, Performance Surfaces and Optimum Points
%   nnd8ts1  - Taylor series demonstration #1.
%   nnd8ts2  - Taylor series demonstration #2.
%   nnd8dd   - Directional derivatives demonstration.
%   nnd8qf   - Quadratic function demonstration.
%
% Chapter 9, Performance Optimization
%   nnd9sdq  - Steepest descent for quadratic function demonstration.
%   nnd9mc   - Method comparison demonstration.
%   nnd9nm   - Newton's method demonstration.
%   nnd9sd   - Steepest descent demonstration.
%
% Chapter 10, Widrow-Hoff Learning
%   nnd10nc  - Adaptive noise cancellation demonstration.
%   nnd10eeg - Electroencephelogram noise cancellation demonstration.
%   nnd10lc  - Linear pattern classification demonstration.
%
% Chapter 11, Backpropagation
%   nnd11nf  - Network function demonstration.
%   nnd11bc  - Backpropagation calculation demonstration.
%   nnd11fa  - Function approximation demonstration.
%   nnd11gn  - Generalization demonstration.
%
% Chapter 12, Variations on Backpropagation
%   nnd12sd1 - Steepest descent backpropagation demonstration #1.
%   nnd12sd2 - Steepest descent backpropagation demonstration #2.
%   nnd12mo  - Momentum backpropagation demonstration.
%   nnd12vl  - Variable learning rate backpropagation demonstration.
%   nnd12ls  - Conjugate gradient line search demonstration.
%   nnd12cg  - Conjugate gradient backpropagation demonstration.
%   nnd12ms  - Marquardt step demonstration.
%   nnd12m   - Marquardt backpropagation demonstration.
%  
% Chapter 13, Associative Learning
%   nnd13uh  - Unsupervised Hebb demonstration.
%   nnd13edr - Effects of decay rate demonstration.
%   nnd13hd  - Hebb with decay demonstration.
%   nnd13gis - Graphical instar demonstration.
%   nnd13is  - Instar demonstration.
%   nnd13os  - Outstar demonstration.
%
% Chapter 14, Competitive Networks
%   nnd14cc  - Competitive classification demonstration.
%   nnd14cl  - Competitive learning demonstration.
%   nnd14fm1 - 1-D Feature map demonstration.
%   nnd14fm2 - 2-D Feature map demonstration.
%   nnd14lv1 - LVQ1 demonstration.
%   nnd14lv2 - LVQ2 demonstration.
%
% Chapter 15, Grossberg Network
%   nnd15li  - Leaky integrator demonstration.
%   nnd15sn  - Shunting network demonstration.
%   nnd15gl1 - Grossberg layer 1 demonstration.
%   nnd15gl2 - Grossberg layer 2 demonstration.
%   nnd15aw  - Adaptive weights demonstration.
%
% Chapter 16, Adaptive Resonance Theory
%   nnd16al1 - ART1 layer 1 demonstration.
%   nnd16al2 - ART1 layer 2 demonstration.
%   nnd16os  - Orienting subsystem demonstration.
%   nnd16a1  - ART1 algorithm demonstration.
%
% Chapter 17, Stability
%   nnd17ds  - Dynamical system demonstration.
%
% Chapter 18, Hopfield Network
%   nnd18hn  - Hopfield network demonstration.
%
% Custom Functions
% ----------------
%
% Custom simulation functions.
%   mytf     - Example custom transfer function.
%   mydtf    - Example custom transfer derivative function of MYTF.
%   mynif    - Example custom net input function.
%   mydnif   - Example custom transfer derivative function of MYNIF.
%   mywf     - Example custom weight function.
%   mydwf    - Example custom weight derivative function of MYWF.
%
% Custom initialization functions.
%   mywbif   - Example custom weight and bias initialization function.
%
% Custom learning functions.
%   mypf     - Example custom performance function.
%   mydpf    - Example custom performance derivative function for MYPF.
%   mywblf   - Example custom weight and bias learning function.
%
% Custom self-organizing map functions.
%   mydistf  - Example custom distance function.
%   mytopf   - Example custom topology function.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.17 $ $Date: 2002/04/14 21:22:51 $
