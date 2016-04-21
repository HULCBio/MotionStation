function display(S)
% DISPLAY  Display partition information
%
% See also SMPARTITION

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:39 $
nS = numel(S);
if nS == 1,
    disp(' Shared-Memory partition');
    disp(['  Total Bytes in partition = ' num2str(sizeof(S))]);
    disp(['  Starting Address = ' base(S,'char')]);
    disp(['  Number of segments = ' num2str(numseg(S))]);
else
    disp(' Shared-Memory partitions');
    disp(['  Number of partitions = ' num2str(nS)]);    
    disp(['  Bytes per partitions = ' num2str(sizeof(S))]);
    msgAdd = '  Starting Addresses = ';
    msgSeg = '  Number of segments = ';
    for inxS = 1:nS,
        msgAdd = [msgAdd ' ' base(S(inxS),'char')];
        msgSeg = [msgSeg ' ' num2str(numseg(S(inxS)))];
    end
    disp(msgAdd);
    disp(msgSeg);
end
