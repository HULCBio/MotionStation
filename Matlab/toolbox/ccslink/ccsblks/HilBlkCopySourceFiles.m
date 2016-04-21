function success = HilBlkCopySourceFiles(blk)

success = false;  % set to true at end

disp('### Copying source files for HIL Function Call block')

UDATA = get_param(blk,'UserData');
fileList = UDATA.sourceFiles;

if isempty(fileList),
    % Handle error specially since we are called from TLC
    msg = 'Source file list is empty.';
    disp(['Error:  ' msg])
    error(msg)  % success = false
end

% Ensure files exist

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:20 $
for k = 1:length(fileList),
    if ~exist(fileList{k},'file'),
        msg = ['Could not find file ' fileList{k} ...
                ' in specified directory list.'];
        disp(msg)
        error(msg)  % success = false
    end
end

codegenDir = fullfile(pwd, [get_param(gcs,'name') '_c6000_rtw']);
if ~exist(codegenDir,'dir'),
    msg = ['Could not find codegen directory ' codegenDir ...
            '; you must add the source files ' ...
            'manually to the project.'];
    warning(msg);
else
    for k = 1:length(fileList),
        file1 = fileList{k};
        try
            eval(['dos(''copy ' file1 ' "' codegenDir '"'');'])
        catch
            disp(lasterr)
            msg = ['There was a problem copying ' ...
                    'the HIL Block source file ' file1 '. ' ...
                    'You must add the source file manually ' ...
                    'to the project.'];
            disp(msg)
            error(msg)  % success = false
        end
    end
end

success = true;
