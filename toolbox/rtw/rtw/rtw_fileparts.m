function value = rtw_fileparts(fname)
% Wrapper for MATLAB fileparts to return information
% in a form that can be used in TLC environment.
  
% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

  [pathstr,filestr,extstr] = fileparts(fname);
  value.Path = pathstr;
  value.File = filestr;
  value.Ext  = extstr;
  
