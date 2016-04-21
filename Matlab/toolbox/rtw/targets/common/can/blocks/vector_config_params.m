function [disabled] = ...
    vector_config_params(configblock)
%VECTOR_CONFIG_PARAMS calculates derived configuration parameters
%   Called from all blocks that need to access Vector CAN channel
%   configuration parameters
%
%   [disabled, channel_param_numeric, channel_display_name] =
%   VECTOR_CONFIG_PARAMS(configblock) returns the disabled status, and a number
%   indicating the selected channel.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $
%   $Date: 2004/04/19 01:20:18 $

channel_param = get_param(configblock,'channel_param'); 

%
% set default return values
%
disabled=0;

switch channel_param
 case 'None'
    disabled = 1;
end