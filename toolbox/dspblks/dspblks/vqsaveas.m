function vqsaveas(hFig)
%SAVEAS Save the file

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:18:06 $

% If a file isn't specified, bring up the dialog
ud=get(hFig,'UserData');
file = ud.FileName;
if isempty(file) file = '*.vqd'; end
[filename,pathname] = uiputfile(file,'Save VQ Design Session As...','Untitled.vqd');

% Don't save if filename is 0
if filename ~= 0,
    file = [pathname filename];
    [filename_tmp, ext] = strtok(filename, '.');
    if isempty(ext),
        file = [file '.vqd'];
    end
%   % Unix returns a path that sometimes includes two paths (the
% 	% current path followed by the path to the file) seperated by '//'.
% 	% Remove the first path.
% 	indx = findstr(file,[filesep,filesep]);
% 	if ~isempty(indx)
%         file = file(indx+1:end);
% 	end
    
    if strcmpi(filename_tmp, 'VQDTOOL')
        errordlg('File name cannot be vqdtool');
        return
    else 
       vqsaveorsaveas(hFig, file,'saveas');        
    end
end

% [EOF]
