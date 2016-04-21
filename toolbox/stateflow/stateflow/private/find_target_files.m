function targetFileList = find_target_files(name)
% find valid sf target files on path

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/15 00:57:47 $
    targetFileList = [];

    % For each sftarget directory on the path...
    targetDirList = what('sftarget');
    for i = 1:length(targetDirList)
        targetDir = targetDirList(i);

        % For each candidate file in the directories...
        targetFileCandidates = [targetDir.m targetDir.p];
        for j = 1:length(targetFileCandidates)
            [pathStr, targetFcn] = fileparts(targetFileCandidates{j});
            [prevErrMsg, prevErrId] = lasterr;
    		try
                % We judge a target file to be valid if
                % it has a working 'name' method that returns
                % a non-empty string.
				targetName = feval(targetFcn,'name',0);
                if ~isempty(targetName) & ischar(targetName)
                    % nargin == 1 means we are looking for one specific target;
                    if nargin == 0
                        % collect everything valid
                        targetFileList(end+1).name = targetName;
                        targetFileList(end).fcn = targetFcn;
                    elseif strcmp(targetName,name)
                        % we'll return the first match we find
                        targetFileList.name = targetName;
                        targetFileList.fcn = targetFcn;
                        return;
                    end
                end
			catch
			    lasterr(prevErrMsg, prevErrId);
			end
        end
    end
