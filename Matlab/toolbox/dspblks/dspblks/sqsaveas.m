function sqsaveas(hFig)
%SAVEAS Save the file

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:20 $

% If a file isn't specified, bring up the dialog
ud=get(hFig,'UserData');
file = ud.FileName;
if isempty(file) file = '*.sqd'; end
[filename,pathname] = uiputfile(file,'Save SQ Design Session As...','Untitled.sqd');

% Don't save if filename is 0
if filename ~= 0,
    file = [pathname filename];
    [filename_tmp, ext] = strtok(filename, '.');
    if isempty(ext),
        file = [file '.sqd'];
    end
%   % Unix returns a path that sometimes includes two paths (the
% 	% current path followed by the path to the file) seperated by '//'.
% 	% Remove the first path.
% 	indx = findstr(file,[filesep,filesep]);
% 	if ~isempty(indx)
%         file = file(indx+1:end);
% 	end
    
    if strcmpi(filename_tmp, 'SQDTOOL')
        errordlg('File name cannot be sqdtool');
        return
    else 
       sqsaveorsaveas(hFig, file,'saveas');        
    end
end

% [EOF]
