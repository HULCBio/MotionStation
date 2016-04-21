function default=mpc_default;
%MPC_DEFAULTS Default values for MPC Object fields

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2004/04/10 23:39:12 $   

default.weight.manipulatedvariables=0;
default.weight.manipulatedvariablesrate=0.1;
default.weight.outputvariables=1;
default.weight.ecr=1e5; % The default weight for ECR is 1e5*max(u/du/y-weight)

default.u.target='nominal'; % Inherited from Model.Nominal

default.deltaumin=-10;     % Default lower bound for unbounded input rates when using QP
default.bigdeltaumin=-1e5; % Maximum allowed lower bound for unbounded input rates when using QP

default.u.min=-Inf;
default.u.ratemin=-Inf; 
default.y.min=-Inf;

default.u.max=Inf;
default.u.ratemax=Inf;
default.y.max=Inf;

default.u.minecr=0;
default.u.maxecr=0;
default.u.rateminecr=0;
default.u.ratemaxecr=0;
default.y.minecr=1;
default.y.maxecr=1;

%default.u.zero=0;
%default.u.span=1;
default.u.units='';
%default.y.zero=0;
%default.y.span=1;
default.y.units='';
default.y.integrator=[];
default.d.units='';

default.p=10; % default p=10+max(delay)
default.m=2;

default.MVcovmat=1;
default.UMDcovmat=1;
default.MNcovmat=1;

default.optimizer.trace='off';
default.optimizer.maxiter=200;
default.optimizer.minoutputecr=1e-10;
default.optimizer.solver='ActiveSet';

default.verbosity='on';
