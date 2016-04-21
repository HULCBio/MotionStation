function [srcBlks, curBlks, data] = slmdldisc(sys, libName, varargin)
%entry function for model discretizer GUI
%libName - the library name for storing configurable subsystem blocks
%sys - model (handle);

% $Revision: 1.4 $ $Date: 2002/03/30 16:10:28 $
% Copyright 1990-2002 The MathWorks, Inc.

if nargin < 3
    error(sprintf('At least one block should be provided!\n'));
end

import java.lang.*;
try
    sys = get_param(bdroot(sys),'name');
catch
    srcBlks = String('error');
    curBlks = String('error');
    data = String('error');
    return;
end


tmpargin = varargin{1};
n = length(tmpargin);

data = javaArray('java.lang.Object', n);

for k = 1:n,
    tmp = tmpargin{k};
    srcBlk = tmp{1};
    curBlk = tmp{2};
    curBlkFullName = getfullname(curBlk);
    sampleTime = tmp{3};
    offset = tmp{4};
    method = tmp{5};
    cf = tmp{6};
    replaceWith = tmp{7};
    putInto = tmp{8};
    if length(tmp) == 9 & (strcmpi(putInto, 'replace') | strcmpi(putInto, 'delete'))
        whichChoice = tmp{9};
        confOption = {putInto, 'off', libName, whichChoice};
    else
        confOption = {putInto, 'off', libName};
    end

    isconf = isconfigurable(libName, curBlk);
    if isconf | strcmpi(putInto, 'new')
        option = {srcBlk, replaceWith, 'configurable','off'};
    else
        option = {curBlk, replaceWith, 'current', 'off'};
    end

    if ischar(sampleTime) & ischar(offset)
        strstoffset = {sampleTime, offset};
    else
        strstoffset = [sampleTime, offset];
    end

    if isconf | strcmpi(putInto, 'new')
        if strcmp(method, 'prewarp')
            [origBlk, newBlk] = sldiscmdl(sys, strstoffset, method, cf, ...
                option, curBlk, confOption);
        else
            [origBlk, newBlk] = sldiscmdl(sys, strstoffset, method, ...
                option, curBlk, confOption);
        end
        srcBlks{k} = origBlk;
        curBlks{k} = newBlk;
        tmparray = javaArray('java.lang.Object',3);
        if ~strcmpi(putInto, 'hardcode')
            tmparray(1) = String(get_param(newBlk,'blockchoice'));
            tmparray(2) = String(get_param(newBlk,'memberblocks'));
        else
            tmparray(1) = String('none');
            tmparray(2) = String('none');
        end
        tmparray(3) = String(get_param(sys, 'disc_configurable_lib'));
        libName = get_param(sys, 'disc_configurable_lib');
        data(k) = tmparray;
    else
        if get_param(srcBlk,'handle') ~= get_param(curBlk,'handle')
            replace_block(sys, 'handle', get_param(curBlk,'handle'), srcBlk, 'noprompt');
        end
        if strcmp(method, 'prewarp')
            [origBlk, newBlk] = sldiscmdl(sys, strstoffset, method, cf, option);
        else
            [origBlk, newBlk] = sldiscmdl(sys, strstoffset, method, option);
        end
        if strcmp(origBlk{1},curBlkFullName)
            srcBlks{k} = srcBlk;
            curBlks{k} = newBlk{1};
        else
            srcBlks{k} = srcBlk;
            curBlks{k} = curBlk;
        end
        tmparray = javaArray('java.lang.Object',3);
        tmparray(1) = String('none');
        tmparray(2) = String('none');
        tmparray(3) = String('none');
        data(k) = tmparray;        
    end
end

srctmp = javaArray('java.lang.Object', length(srcBlks));
curtmp = javaArray('java.lang.Object', length(curBlks));
for k=1:length(srctmp),
    srctmp(k) = String(srcBlks{k});
    curtmp(k) = String(curBlks{k});
end
srcBlks = srctmp;
curBlks = curtmp;

%end slmdldisc


%[EOF] slmdldisc.m