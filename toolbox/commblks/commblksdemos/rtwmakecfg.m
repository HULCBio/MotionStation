%RTWMAKECFG adds include and source directories to rtw make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following field:
%     makeInfo.includePath - cell array containing additional include
%                            directories. Those directories will be
%                            expanded into include instructions of rtw
%                            generated make files.
%
%     makeInfo.sourcePath  - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.

%  Copyright 1996-2002 The MathWorks, Inc.
%  $Revision: 1.2 $ $Date: 2002/03/24 02:04:03 $

function makeInfo=rtwmakecfg()
  makeInfo.includePath = { ...
      fullfile(matlabroot,'toolbox','commblks','sim','export', 'include'), ...
      fullfile(matlabroot,'toolbox','dspblks','src','sim'), ...
      fullfile(matlabroot,'toolbox','dspblks','include') };
  makeInfo.sourcePath = { ...
      fullfile(matlabroot,'toolbox','commblks', 'commblksdemos') };

disp('### Include Communications Blockset Demo directory');
