function [sccProjName, sccAuxPath] = getsccprj(localFolder)
% Get the source control project details for the given file.

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/03/23 02:53:34 $

if (nargin < 1 | isempty(localFolder))
  error('Invalid input');
end

import com.mathworks.services.*;
import java.io.*;
import java.util.*;
import java.lang.*;

sccProp      = Properties;

prefsFolder  = Prefs.getPropertyDirectory.concat(System.getProperty('file.separator'));
prefsFile    = prefsFolder.concat('mw.scc');
prefsFileObj = File(char(prefsFile));
if (prefsFileObj.exists)
  prefsIStream = FileInputStream(prefsFileObj);
  sccProp.load(prefsIStream);
  prefsIStream.close;
end

localFolder  = strrep(localFolder, ':', '.');
localFolder  = strrep(localFolder, '\', '/');
localFolder  = strrep(localFolder, ' ', '_');
localFolder  = lower(localFolder);
sccProjName  = char(sccProp.get([localFolder '.SccProjectName']));
sccAuxPath   = char(sccProp.get([localFolder '.SccAuxPath']));
