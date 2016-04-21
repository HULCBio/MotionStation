function dummy = disp(rin)
%DISP Display RTDX(tm) channel properties.
%   DISP(RIN) displays the channel properties of RTDX object RIN.

% Copyright 2000-2003 The MathWorks, Inc.
% $Revision: 1.19.4.2 $ $Date: 2004/04/08 20:46:50 $

numEle = prod(size(rin));
if rin.numChannels > 0,
    for i=1:numEle,
        r = rin(i);
        
        fprintf('RTDX Object:\n');
        fprintf('  Default timeout  :%6.2f secs\n', r.timeout);
        fprintf('  Open channels    : %d\n\n', r.numChannels);
        
        nChans = r.numChannels;
        if nChans > 0,
            fprintf('  %3s %-16s %s\n', 'Ch', 'Name', 'Mode');
            fprintf('  %3s %-16s %s\n', '--', '----', '----');
            for i = 1:nChans,
                chName  = r.RtdxChannel{i,1};
                if length(chName) > 16,
                    chName = [chName(1:13) '...'];
                end
                if r.isreadable(chName),
                    modeStr = 'read';
                else
                    modeStr = 'write';
                end
                fprintf('  %3d %-16s %-5s\n', i, chName, modeStr);
            end
        end
        if (length(rin)>1),
            fprintf('\n');
        end
    end
else
    fprintf('  RTDX channels    : %d\n', rin.numChannels);
end

% EOF disp.m
