function varargout = linmod(model, varargin)
%  LINMOD Obtains linear models from systems of ord. diff. equations (ODEs).
%     [A,B,C,D]=LINMOD('SYS') obtains the state-space linear model of the
%     system of ordinary differential equations described in the
%     block diagram 'SYS' when the state variables and inputs are set
%     to the defaults specified in the block diagram.
%  
%     [A,B,C,D]=LINMOD('SYS',X,U) allows the state vector, X, and
%     input, U, to be specified. A linear model will then be obtained
%     at this operating point.
%  
%     [A,B,C,D]=LINMOD('SYS',X,U,PARA) allows a vector of parameters to
%     be set.  PARA(1) sets the perturbation level (obsolete in R12 unless
%     using the 'v5' option - see below). For systems that are functions of 
%     time PARA(2) may be set with the the value of t at which the linear 
%     model is to be obtained (default t=0). Set PARA(3)=1 to remove extra 
%     states associated with blocks that have no path from input to output.
%  
%     [A,B,C,D]=LINMOD('SYS',X,U,'v5') uses the full-model-perturbation 
%     algorithm that was found in MATLAB 5.x.  The current algorithm 
%     uses pre-programmed linearizations for some blocks, and should be more
%     accurate in most cases.  The new algorithm also allows for special
%     treatment of problematic blocks such as the Transport Delay and
%     the Quantizer.  See the mask dialog of these blocks for more
%     information and options.
% 
%     [A,B,C,D]=LINMOD('SYS',X,U,'v5',PARA,XPERT,UPERT) uses the 
%     full-model-perturbation algorithm that was found in MATLAB 5.x. 
%     If XPERT and UPER are not given, PARA(1) will set the perturbation level 
%     according to:
%        XPERT= PARA(1)+1e-3*PARA(1)*ABS(X)
%        UPERT= PARA(1)+1e-3*PARA(1)*ABS(U)
%     The default perturbation level is PARA(1)=1e-5.
%     If vectors XPERT and UPERT are given they will be used as the perturbation
%     level for the systems states and inputs.
%  
%  See also: LINMODV5, LINMOD2, DLINMOD, TRIM

%   S = LINMOD('SYS',...) returns a structure containing the state-space
%   matrices, state names, operating point, and other information about
%   the linearized model.
%
%   [A,B,C,D,J] = LINMOD('SYS',...) returns the sparse Jacobian structure
%   in addition to the state-space matrices.
%
%   See DLINMOD for details on the algorithm

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.45.2.2 $

Ts = 0;
Args = 'IgnoreDiscreteStates';

[varargout{1:max(1,nargout)}] = dlinmod(model, Ts, varargin{:}, Args);

