function varargout = power_init(varargin)
% POWER_INIT  Set the initial states values for a model built with 
%    SimPowerSystems.
%
%    POWER_INIT(SYSTEM,'look') displays the current initial states of SYSTEM.
%
%    POWER_INIT(SYSTEM,'reset') resets the initial states of SYSTEM to zero.
%
%    POWER_INIT(SYSTEM,'steady') sets the initial states of SYSTEM to simulate 
%    in the steady state.
%
%    POWER_INIT(SYSTEM,'set',P) sets the initial state values equal to the 
%    specified vector P. The ordering of the states variables is given by 
%    the POWER_INIT(SYSTEM,'look') command.
%
%    POWER_INIT(SYSTEM,'setb',STATE,VALUE) sets the initial state variable 
%    STATE to VALUE. The names of the state variables are given by the 
%    POWER_INIT(SYSTEM,'look') command.
%
%    See also POWERGUI

%   Patrice Brunelle (TEQSIM) 26-02-97, 08-05-2001
%   Copyright 1997-2004 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

if nargout == 0,
  power_init_pr(varargin{:});
else
  [varargout{1:nargout}] = power_init_pr(varargin{:});
end