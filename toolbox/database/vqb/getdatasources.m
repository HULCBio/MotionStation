function d = getdatasources()
%GETDATASOURCES Return valid data sources on system.
%   D = GETDATASOURCES returns the valid data sources on the system.
%   If D is empty, the ODBC.INI file is valid but no data sources have been 
%   defined.  If D equals -1, the ODBC.INI file could not be opened.
%   D is returned as a cell array of strings containing the data source names
%   if any are present on the system.

%   Author(s): C.F.Garvin, 05-01-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2002/12/08 21:04:35 $

d = [];

%UNIX data sources
if isunix
  try
    load datasource
    d = srcs(:,1);
  catch
    d = [];
  end
  return
end

%Sources being read from ODBC.INI file, find it
windir = getenv('WINDIR');
fid = fopen([windir(1:length(windir)) '\odbc.ini']); 
if fid == -1
  d = fid;
  return
end

%Parse file line by line searching for string ODBC 32 bit [Data Sources]
hdr = '';
while ~strcmp(upper(hdr),'[ODBC 32 BIT DATA SOURCES]')
  hdr = fgetl(fid);
end

%Found data sources, parse them
tmp = fgetl(fid);
i = 1;
while ~isempty(tmp) & (~strcmp(tmp(1),'[') & ~isempty(findstr(tmp,'=')))
  j = find(tmp == '=');  %Find = that end of source name
  d{i} = tmp(1:j-1);     %Store source name
  tmp = fgetl(fid);      %Read next line of file
  i = i+1;
end

%Close ODBC.INI
fclose(fid);
