function includePaths = getIncludePaths_DSPtarget(modelInfo, tgtType)
% return include paths for targeting

% $RCSfile: getIncludePaths_DSPtarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:28 $
% Copyright 2001-2003 The MathWorks, Inc.

mlroot = feval('matlabroot');
if exist('tmpTiMatlabRoot.m','file'),
    mlroot_ti_tmp = tmpTiMatlabRoot;
else
    mlroot_ti_tmp = mlroot;
end

switch tgtType
    case 'C6416DSK',
        rtlibInclude = '\toolbox\rtw\targets\tic6000\tic6000\rtlib\include\c64" ';
    otherwise,
        rtlibInclude = '\toolbox\rtw\targets\tic6000\tic6000\rtlib\include" ';
end

includePaths = ['-i"' mlroot '\simulink\include" '...
                '-i"' mlroot '\extern\include" '...
                '-i"' mlroot '\rtw\c\src" '...
                '-i"' mlroot '\rtw\c\libsrc" '...
                '-i"' mlroot '\toolbox\dspblks\include" '...
                '-i"' mlroot_ti_tmp '\toolbox\rtw\targets\tic6000\tic6000\include" '...
                '-i"' mlroot_ti_tmp rtlibInclude ...
                '-i"' mlroot '\toolbox\rtw\dspblks\c" '...
                '-i"." '...
                ];

% Add HIL Block items
hilBlocks = find_system(modelInfo.name,'FollowLinks','on','LookUnderMasks','on',...
    'MaskType','Hardware-in-the-Loop Function Call');
    
for k = 1:length(hilBlocks),
    blk = hilBlocks{k};
    UDATA = get_param(blk,'UserData');
    for f = 1:length(UDATA.includePaths),
        thisDir = UDATA.includePaths{k};
        if exist(thisDir,'dir')
            includePaths = [includePaths '-i"' ...
                thisDir '" '];
        else
            error(['Directory ' thisDir ' does not exist.']);
        end
    end
end

% [EOF] getIncludePaths_DSPtarget.m
