function makeInfo = rtwmakecfg()

% This xPC-specific rtwmakecfg is used to customize the makefile include path for
% blocks which require e.g. special libraries. The need for special treatment is
% signalled by the presence of appropriate substrings in the xpc_rtwmakecfg_data
% parameter of the model being compiled. This parameter is created and updated by 
% the InitFcns of the blocks that require such treatment. It is deleted after use by
% the present procedure.

% Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/08 21:03:21 $

makeInfo.includePath = {};
makeInfo.sourcePath = {};

try
    data = get_param(bdroot, 'xpc_rtwmakecfg_data');
catch
    return;
end

k = 0;

if strfind(data, '_xpcuei_')
    makeInfo.precompile = 1;
    makeInfo.sourcePath = { fullfile(xpcroot,'target','build','xpcblocks') };
    
    k = k+1;
    makeInfo.library(k).Name     = 'xpcuei';
    makeInfo.library(k).Location = fullfile(xpcroot,'target','build','xpcblocks','lib');
    makeInfo.library(k).Modules  = {'pdfw_lib'};
end

if strfind(data, '_xpcaudpmc_')
    makeInfo.precompile = 1;
    
    k = k+1;
    makeInfo.library(k).Name     = 'audpmc';
    makeInfo.library(k).Location = fullfile(xpcroot,'target','build','xpcblocks','lib');
    makeInfo.library(k).Modules  = {'dummy'};
end

delete_param(bdroot, 'xpc_rtwmakecfg_data');

% [EOF] rtwmakecfg.m
