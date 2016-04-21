function [filename,pathname] = openhdf(path,dialog)
%OPENHDF is called by the HDFTOOL Open file menu.

%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:52 $

import com.mathworks.mwswing.MJFileChooser;
import com.mathworks.mwswing.FileExtensionFilter;

currentDirectory = pwd;
if strcmp(path,'.')
  path = pwd;
end
fileChooser = MJFileChooser(path);
fileChooser.setDialogTitle(dialog);

% Put accept all files at end
acceptAllFilter = fileChooser.getAcceptAllFileFilter;
fileChooser.removeChoosableFileFilter(acceptAllFilter);
fileChooser.addChoosableFileFilter(acceptAllFilter);

fileFilter = FileExtensionFilter('HDF Files','hdf',true);
fileChooser.addChoosableFileFilter(fileFilter);

returnVal = fileChooser.showOpenDialog(com.mathworks.mwswing.MJFrame);    
if (returnVal == MJFileChooser.APPROVE_OPTION)
  fullfile = char(fileChooser.getSelectedFile.getPath);
  [pathname,filename,ext] = fileparts(fullfile);
  pathname = [pathname '/'];
  filename = [filename ext];
else
  % Mimic the behavior of UIGETFILE
  filename = 0;
  pathname = 0;
end

cd(currentDirectory);


