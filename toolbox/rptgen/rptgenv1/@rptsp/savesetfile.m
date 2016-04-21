function ok=savesetfile(p,filename)
%SAVESETFILE saves the setup file
%   if called as savesetfile(s), just saves according to 
%   the pre-set Path and FileName.
%   can also be called with savesetfile(s,FILENAME)
%   SAVESETFILE returns empty if the file was not saved
%   properly

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:29 $


s=get(p.h,'UserData');
if nargin>1;   
   s.ref.Path=filename;
   set(p.h,'UserData',s);
else
   filename=s.ref.Path;
end

tempFile=rptsp(copyobj(p.h,0));

strip(tempFile);

try
   %we have to use s.ref.Path here because
   %we cleared out the .ref structure in STRIP
   hgsave(tempFile.h,filename);
   ok=logical(1);
catch
   %warning('Warning: Setup file not saved');
   ok=logical(0);
end

delete(tempFile);