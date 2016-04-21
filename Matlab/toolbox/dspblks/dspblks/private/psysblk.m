function [sysname,blkname]=psysblk(p)
%PSYSBLK [S,B]=PSYSBLK(P) parses a Simulink path into individual system
%        name, S, and block name, B, components.  If no path separator
%        is found, the input is returned as the system name with an
%        empty block name.

%    May 1996
%    Copyright 1995-2002 The MathWorks, Inc.
%    $Revision: 1.8 $  $Date: 2002/04/14 20:51:38 $

i=find(p=='/');
if isempty(i),
  sysname=p;
  blkname='';
else
  i=i(end);  % Get last separator in path
  sysname=p(1:i-1);
  blkname=p(i+1:end);
end

% end of psysblk.m
