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

%       Copyright 1994-2002 The MathWorks, Inc.
%       $Revision: 1.3 $
function makeInfo=rtwmakecfg()
  makeInfo.includePath = {};
  makeInfo.sourcePath = { ...
      fullfile(matlabroot,'toolbox','fuzzy','fuzzy','src') };
  disp('### Include Fuzzy Logic Toolbox directories');
