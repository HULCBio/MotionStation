function sqsave(hFig)
%SAVE Save the current session

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:19 $

ud=get(hFig,'UserData');

filename = ud.FileName;  

[file, ext] = strtok(filename, '.');

if isempty(ext),
    filename = [file '.sqd'];
end

if ~ud.SaveOverwriteFlag%% ud.SaveOverwriteFlag== 0,
    sqsaveas(hFig);
elseif file ~= 0,
    sqSave2file(hFig, filename);
end  

% ------------------------------------------------------------
function sqSave2file(hFig, file)

% Unix returns a path that sometimes includes two paths (the
% current path followed by the path to the file) seperated by '//'.
% Remove the first path.
indx = findstr(file,[filesep,filesep]);
if ~isempty(indx)
    file = file(indx+1:end);
end

sqsaveorsaveas(hFig, file,'save');

% [EOF]
