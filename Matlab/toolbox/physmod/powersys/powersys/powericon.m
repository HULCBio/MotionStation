function varargout=powericon(varargin);
% POWERICON Gateway function to the private directory of SimPowerSystems.

%   Patrice Brunelle (TEQSIM) 15-09-97, 01-dec-2003.
%   Copyright 1997-2003 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.5 $

if nargin==0
    error('POWERICON is a gateway function used by SimPowerSystems to access its private directory.');
end

switch varargin{1}
    
    % Icons for powerlib and powerlib_extras blocks:
case {'Series RLC Branch','Series RLC Load','Parallel RLC Branch','Parallel RLC Load',...
        'Mutual Inductance','Linear Transformer','Saturable Transformer','PM Synchronous Machine',...
        'Asynchronous Machine','Distributed Parameters Line','Breaker','PowerSwitch','Bus Bar',...
        '3-phase inductive source - Ungrounded neutral','3-phase RL  positive & zero-sequence impedance',...
        '3-phase RLC series element','3-phase parallel RLC element','3-phase series RLC load',...
        '3-phase parallel RLC load','Three-phase Linear Transformer 12-terminals','Three-Phase Fault',...
        'Three-Phase Breaker','Three-phase transmission line pi-section'}
    [varargout{1:nargout}] = blocicon(varargin);
    return
    %   
case 'STG Model'
    [varargout{1:nargout}] = psbstginit(varargin{2:12});
    return
    %
case 'Machines Demux Model'
    varargout{1} = 0;
    psbcbmachdemux(varargin{2});
    return
    %
case 'Distributed Parameter Line Model'
    [varargout{1:nargout}] = blmodlin(varargin{2:6});
    return
    %
case 'testlink'
    action=['[varargout{1:nargout}]=' varargin{2} '(varargin{3:end});'];
    eval(action);
    return
    %
case {'ThreePhaseTransformer2Init','SynchronousMachineInit',...
        'SynchronousMachineConvert'}   
    % Do not evaluate these callback functions when we are loading the model.
    if strcmp('stopped',get_param(bdroot,'SimulationStatus'))
        return
    end
    %
    
    
    
    %%% WARNING ! the following CASE sections below this line should be
    %%% removed for R15 where the SPS2.3 demos will be obsolete !!
    
        case 'checksum'
            varargout{1} = 0;
            psbchecksum(varargin{2});
            return
    
    
    
end

% FEVAL switchyard
try
    [varargout{1:nargout}] = feval(varargin{:}); 
catch
    disp(lasterr);
end