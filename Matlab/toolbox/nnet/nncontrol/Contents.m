% Neural Network Toolbox Control System Functions.
%
% Data files
%   ball1      - Data for training the magnetic levitation plant model
%   cstr1      - Data for training the continous stirred tank reactor model
%   cstr2      - Additional data for training the continous stirred tank reactor model
%   cstr3      - Additional data for training the continous stirred tank reactor model
%   robot1     - Data for training the robot arm model
%   robot2     - Additional data for training the robot arm model
%   robot1norm - Normalized data for training the robot arm model
%   robot2norm - Additional normalized data for training the robot arm model
%   robot3norm - Additional normalized data for training the robot arm model
%   robot1ref  - Data for training the robot arm model reference controller
%     
% Line search functions for predictive control optimization.
%   csrchbac - Backtracking search.
%   csrchbre - Brent's combination golden section/quadratic interpolation.
%   csrchcha - Charalambous' cubic interpolation.
%   csrchgol - Golden section search.
%   csrchhyb - Hybrid bisection/cubic search.
%
% Miscellaneous functions
%   nncontrolutil - Enables Simulink to access private functions.
%
% Plotting functions.
%   sfunxy2  - S-function that acts as an X-(double Y) scope.
%
% Predictive control functions
%   calcjjdjj - Calculate the cost function and the gradient of the cost function.
%   predopt   - Implements the predictive controller optimization.
%   dyduvar   - Calculates the partial derivative of Y w/respect to U.
%
% Simulink models
%   ballrepel0    - Model of the magnetic levitation system.
%   cstr          - Model of the continous stirred tank reactor.
%   mrefrobotarm  - Demonstration model of the reference control of a robot arm.
%   mrefrobotarm2 - Demonstration of model reference control with normalized data.
%   narmamaglev   - Demonstration of the NARMA-L2 control of a magnet levitation system.
%   predball      - Demonstration of the predictive control of a magnet levitation system.
%   predcstr      - Demonstration of the predictive control of a tank reactor.
%   ptest3sim2    - Neural network plant model used by predopt to predict future plant behavior.
%   robotarm      - Model of the robot arm.
%   robotref      - Reference model used in the model reference control demonstration mrefrobotarm and mrefrobotarm2.
%
% Training functions for Model Reference Control.
%   srchbacxc - Backtracking search for modified forward perturbation.
%   trainbfgc - BFGS quasi-Newton backpropagation for use in NN model Reference Adaptive Controller.
%
% Transfer function for NARMA-L2 controller neural network.
%   netinv   - Inverse transfer function (1/n).
%
% Transfer derivative function for NARMA-L2 controller neural network.
%   dnetinv  - Derivate of the inverse transfer function.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/04/14 21:12:26 $
