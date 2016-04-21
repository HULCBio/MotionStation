function h = hdftool(filename)
% HDFTOOL Browse and import from HDF or HDF-EOS files
%   HDFTOOL is a graphical user interface to browse the contents of HDF
%   and HDF-EOS files and import data and subsets of data.  
%
%   HDFTOOL starts the tool with an open file dialog box. Select an HDF
%   or HDF-EOS file to launch HDFTOOL.
%
%   HDFTOOL(FILENAME) opens the HDF or HDF-EOS file FILENAME in the
%   HDFTOOL.  
%
%   H = HDFTOOL(...)  returns a handle H to the tool. DISPOSE(H)
%   and H.dispose both close the tool from the command line.
%
%   Only one instance of HDFTOOL is allowed during a MATLAB session.
%   Multiple files may be opened in HDFTOOL. By default HDF-EOS files are
%   viewed as HDF-EOS files.  HDF-EOS files may be viewed as HDF files by
%   changing the "View".  
%
%   Example
%   -------
%   hdftool('example.hdf');
%
%   See also HDFINFO, HDFREAD, HDF, UIIMPORT.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:57 $

msg = javachk('swing','HDFTOOL');
if (~isempty(msg))
    error('MATLAB:hdftool:javaSwingNotAvailable', '%s', msg);
end

error(nargchk(0, 1, nargin, 'struct'));

import java.awt.Cursor;

if nargin==0
  filename = getFilename;
  if isempty(filename)
    return;
  end
end

fid = fopen(filename, 'r');
if (fid == -1)
  error('MATLAB:hdftool:fileOpen', ...
        'Can''t open file "%s" for reading;\n it may not exist, or you may not have read permission.', ...
        filename);
else
  filename = fopen(fid);
  fclose(fid);
end

if ~hdfh('ishdf',filename)
  switch questdlg('This file is not in the HDF format. Use the Import Wizard to import data from this file?','','Yes','No','Yes') 
   case 'Yes'
    uiimport(filename);
    return;
   case 'No'
    if nargout
      h = [];
    end
    return;
  end
end

hdf = getToolFrame;
showTool(hdf);
%  Show the tool with a wait cursor while file is being read
%  so the user has something exciting to look at.
hdf.handle.setCursor(java.awt.Cursor.WAIT_CURSOR);

%  File has been selected by user and is in HDF format
%  Build the trees.
[HDFObjects, HDFEOSObjects] = buildHDFTree(filename);

%  Add file to the tool and reset cursor
if isempty(HDFEOSObjects)
  awtinvoke(hdf.handle, ...
            'addNewFile(Lcom/mathworks/toolbox/matlab/iofun/DataNode;)', ...
            HDFObjects)
else
  awtinvoke(hdf.handle, ...
            'addNewFile(Lcom/mathworks/toolbox/matlab/iofun/DataNode;Lcom/mathworks/toolbox/matlab/iofun/DataNode;)', ...
            HDFObjects, HDFEOSObjects)
end
hdf.handle.setCursor(java.awt.Cursor.DEFAULT_CURSOR);

if nargout
  h = hdf.handle;
end

showTool(hdf)

function hdf = getToolFrame
import com.mathworks.toolbox.matlab.iofun.*;
hdf.handle = Importer.getInstance;  

function showTool(hdf)
awtinvoke(hdf.handle, 'setVisible(Z)', true);


function filename = getFilename
import com.mathworks.toolbox.matlab.iofun.ImporterResourceBundle;

[filename pathname] = openhdf(com.mathworks.toolbox.matlab.iofun.Importer.getCurrentDir,...
                              char(ImporterResourceBundle.getString('dialog.openfile')));
if (isequal(filename,0) || isequal(pathname,0))
  filename = '';
else
  filename = fullfile(pathname,filename);
  com.mathworks.toolbox.matlab.iofun.Importer.setCurrentDir(pathname)

end

