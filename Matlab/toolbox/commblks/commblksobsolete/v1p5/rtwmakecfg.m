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
%

%       Copyright 1996-2003 The MathWorks, Inc.
%       $Revision: 1.1.8.2 $
function makeInfo=rtwmakecfg()
  makeInfo.includePath = { ...
	  fullfile(matlabroot,'toolbox','commblks','sim', 'export', 'include'), ...
  	  fullfile(matlabroot,'toolbox','commblks','commblksobsolete', 'v1p5', 'src', 'include'), ...
      fullfile(matlabroot,'toolbox','dspblks','src','sim'), ...
      fullfile(matlabroot,'toolbox','dspblks','include') };
  makeInfo.sourcePath = { ...
	  fullfile(matlabroot,'toolbox','commblks','commblksobsolete', 'v1p5', 'src') };

disp('### Include Communications Blockset v1p5 directories');
