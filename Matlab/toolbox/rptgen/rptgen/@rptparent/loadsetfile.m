function [s,ok]=loadsetfile(r,filename)
%LOADSETFILE imports a setup file
%   S=LOADSETFILE(R,'filename')

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:19 $


[path name ext ver]=fileparts(filename);
if isempty(ext)
   ext='.rpt';
end

if isempty(path)
   filename=which([name ext]);
else   
   filename=fullfile(path,[name ext ver]);
end

ok=logical(0);
%oldVals=nenw(r);
if ~isempty(filename)
   try
      s=hgload(filename);
      ok=logical(1);
   catch
      s=[];
   end
   ud=get(s,'UserData');
   ud.ref=struct('ID',s,...
      'Path',filename);
else
   ud.ref.Path=fullfile(pwd,[name ext ver]);
end
%nenw(r,oldVals);

s=rptsetupfile(ud);

