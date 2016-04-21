function varargout = canlib_asap2_daq_utils(util,varargin)
% private utilities used for CCP DAQ list implementation

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $

switch lower(util)
    case 'normalbuild'
        varargout{1} = internal_normal_build;
    case 'originalhandle'
        varargout{1} = internal_original_handle;
    case 'totalnumodts'
        varargout{1} = internal_total_num_odts;
end

function total_num_odts = internal_total_num_odts
    tempVar = canlib.Signal;
    total_num_odts = tempVar.Configuration.total_num_odts;

function original_handle = internal_original_handle
    % get the original block handle - use this when we are 
    % right click building
    % rtwattic is a private function
    original_handle = rtwprivate('rtwattic','AtticData', 'OrigBlockHdl');

function normal_build = internal_normal_build 
% Right Click build UI invokes ssgencode, so we can check that arriving
% here came through ssgencode by looking at the execution stack.
normal_build = 1;
Context = dbstack;
for i = 1:length(Context)
    if strfind(Context(i).name,'ssgencode')
        normal_build = 0;
        return;
    end
end
