function makeInfo = rtwmakecfg
% RTWMAKECFG Add include and source directories to RTW make files. % makeInfo = RTWMAKECFG returns a structured array containing % following fields: %
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
%     makeInfo.library     - structure containing additional runtime library
%                            names and module objects.  This information
%                            will be expanded into rules of rtw generated make
%                            files.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/02/06 00:25:24 $

makeInfo.includePath = { ...
    fullfile( matlabroot,'toolbox','mpc','mpcutils','src') };

makeInfo.sourcePath  = { ...
    fullfile( matlabroot,'toolbox','mpc','mpcutils','src') };

makeInfo.library     = { };

