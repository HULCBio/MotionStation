function open_rtwinlib
%WINLIB Opens the RTWINLIB library.
% RTWINLIB is the library for Real-Time Windows Target
% which is an optional product.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.9 $

% Attempt to open Real-Time Windows Target library

lib = ['rtwinlib'];

if ~strcmp(computer,'PCWIN')
  errordlg(['Real-Time Windows Target is only supported on MS-Windows']);
elseif exist(lib) ~= 4
  errordlg(['Real-Time Windows Target is not installed on your system']);
else
  open_system(lib);
end

% end of open_rtwwinlib.m
