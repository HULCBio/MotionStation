function vqsave(hFig)
%SAVE Save the current session

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:18:04 $

ud=get(hFig,'UserData');

filename = ud.FileName;  

[file, ext] = strtok(filename, '.');

if isempty(ext),
    filename = [file '.vqd'];
end

if ~ud.SaveOverwriteFlag%% ud.SaveOverwriteFlag== 0,
    vqsaveas(hFig);
elseif file ~= 0,
    vqSave2file(hFig, filename);
end  

% ------------------------------------------------------------
function vqSave2file(hFig, file)

% Unix returns a path that sometimes includes two paths (the
% current path followed by the path to the file) seperated by '//'.
% Remove the first path.
indx = findstr(file,[filesep,filesep]);
if ~isempty(indx)
    file = file(indx+1:end);
end

vqsaveorsaveas(hFig, file,'save');

% [EOF]
