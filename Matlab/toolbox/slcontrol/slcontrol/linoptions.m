function opt = linoptions(varargin)
%LINOPTIONS Set options for finding operating points and linearization
%
% OPT=LINOPTIONS creates a linearization options object with the default 
% settings. The variable, OPT, is passed to the functions FINDOP and 
% LINEARIZE to specify options for finding operating points and 
% linearization. 
%
% OPT=LINOPTINS('Property1','Value1','Property2','Value2',...) creates a 
% linearization options object, OPT, in which the option given by 
% Property1 is set to the value given in Value1, the option given by 
% Property2 is set to the value given in Value2, etc. 
% 
% The following options can be set with linoptions:
%   LinearizationAlgorithm Set to 'numericalpert' (default is 'blockbyblock') 
%   to enable numerical-perturbation linearization (as in MATLAB 5) where 
%   root level inports and states are numerically perturbed. Linearization 
%   annotations are ignored and root level inports and outports are used 
%   instead.
%
%   'blockbyblock' algorithm options:
%
%       BlockReduction - Set to 'on' (default) to eliminate from the linearized 
%       model, blocks that are not in the path of the linearization, as in the 
%       following figure. Set to 'off' to include these blocks in the linearized 
%       model.
%
%       IgnoreDiscreteStates - Set to 'on' to remove any discrete states from the 
%       linearization. Set to 'off' (default) to include discrete 
%       states.
%
%       SampleTime - The time at which the signal is sampled. Nonzero for 
%       discrete systems, 0 for continuous systems, -1 (default) to use the 
%       longest sample time that contributes to the linearized model.
%
%    'numericalpert' algorithm options:
%
%       NumericalPertRel - Set the perturbation level for obtaining the linear 
%       model (default 1e-5) according to:
%               NumericalXPert = NumericalPertRel+1e-3*NumericalPertRel*ABS(X)
%               NumericalUPert = NumericalPertRel+1e-3*NumericalPertRel*ABS(U)
%     
%       NumericalXPert - Individually set the perturbation levels for the system's 
%       states.
%
%       NumericalXPert - Individually set the perturbation levels for the system's 
%       inputs.
%
%   OptimizerType - Set optimizer type to be used by trim optimization if the 
%   Optimization Toolbox is installed. The available optimizer types are:
%
%       'graddescent_elim', the default optimizer, enforces an equality constraint to 
%       force time derivatives of states to be zero (dx/dt=0, x(k+1) = x(k)) and
%       contraints on output signals. This optimizer fixes states, x, and 
%       inputs, u, by not allowing these variables to be optimized.
%
%       'graddescent', enforces an equality constraint to force time 
%       derivatives of states to be zero (dx/dt=0, xk+1 = xk) and contraints 
%       on output signals. Minimize the error between the desired (known) 
%       values of states, x, inputs, u, and outputs, y. If there are 
%       no constraints on x, u, or y, FINDOP will attempt to minimize the 
%       deviation between the initial guesses for x and u and the trimmed values. 
% 
%       'lsqnonlin' fixes states, x, and inputs, u, by not allowing these 
%       variables to be optimized. The algorithm then tries to minimize the 
%       error in (dx/dt and x(k+1)=x(k)) and outputs, y. 
%  
%       'simplex' uses the same cost function as 'lsqnonlin' with the 
%       direct search optimization routine found in FMINSEARCH. 
% 
%   See the Optimization Toolbox documentation for more information on these 
%   algorithms. If you do not have the Optimization Toolbox, you can access 
%   the documentation at www.mathworks.com/support/.
%
%   OptimizationOptions - Set options for use with the optimization algorithms. 
%   These options are the same as those set with OPTIMSET. See the 
%   Optimization Toolbox documentation for more information on these 
%   algorithms. 
%
%   DisplayReport - Set to 'on' to display the operating point summary report 
%   when running FINDOP. Set to 'off' to suppress the display of this
%   report. Set to 'iter' to display an iterative update of the
%   optimization progress.
%
%   See also FINDOP, LINEARIZE

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/19 01:32:12 $

%% Create the object
opt = LinearizationObjects.linoptions;

%% Set the user defined properties
for ct = 1:(nargin/2) 
    opt.(varargin{2*ct-1}) = varargin{2*ct};
end
