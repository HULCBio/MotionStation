function makeInfo=rtwmakecfg()
%RTWMAKECFG Add include and source directories to RTW make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following fields:
%
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

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.3.6.3 $ $Date: 2004/04/19 01:19:31 $

% Get hold of the fullpath to this file, without the filename itself
rootpath = fileparts(mfilename('fullpath')); 

% CAN blocks rely on the CAN_FRAME struct defined in can_msg.h
makeInfo.includePath{1} = fullfile(matlabroot,'toolbox','rtw','targets',...
                         'common', 'can','datatypes');

% CCP block needs include path for ccp_utils.h
makeInfo.includePath{2} = fullfile(matlabroot,'toolbox','rtw','targets',...
                         'common', 'can','blocks', 'tlc_c');


% CCP block source path for ccp_utils.c
makeInfo.sourcePath{1} = fullfile(matlabroot,'toolbox','rtw','targets',...
                         'common', 'can','blocks', 'tlc_c');

if vector_code_generation(bdroot)                     
   % Vector blocks rely on the Vector CAN Library C API during 
   % Code Generation
   makeInfo.includePath{2} = fullfile(rootpath, 'mex', 'vector');
   
   % Vector blocks reference the following precompiled library
   makeInfo.precompile = 1; 

   makeInfo.library(1).Name = 'vector_can_library_standalone';
   makeInfo.library(1).Location = rootpath;
   % Note: the 'dummy' module must be specified for the process to 
   % work correctly - the library will not be rebuilt
   makeInfo.library(1).Modules = { 'dummy' };
end;
