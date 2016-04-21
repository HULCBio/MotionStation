
% Copyright 2003 The MathWorks, Inc.

srcDir = [matlabroot,filesep,'simulink',filesep,'src'];
makeCmd = ['make_rtw USER_INCLUDES="-I', srcDir, '" USER_SRCS="', ...
           srcDir, filesep, 'sfun_cppcount_cpp.cpp"'];
set_param(bdroot,'RTWMakeCommand', makeCmd);
