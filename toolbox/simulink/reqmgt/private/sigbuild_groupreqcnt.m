function groupReqCnt = sigbuild_groupreqcnt(blockH)
%SIGBUILD_GROUPREQCNT - Determine the number of requirements in each group

% Copyright 2004 The MathWorks, Inc.

    blkInfo = sigb_get_info(blockH);

    if (~isfield(blkInfo,'groupReqCnt') || isempty(blkInfo.groupReqCnt))
        groupReqCnt = [];
    else
        groupReqCnt = blkInfo.groupReqCnt;
    end


function blkInfo = sigb_get_info(blkHandle)
    fromWsH = find_system(blkHandle,  'FollowLinks',         'off' ...
                                     ,'LookUnderMasks',      'all' ...
                                     ,'BlockType',           'FromWorkspace');
    blkInfo = get_param(fromWsH,'VnvData');    
    
