function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:46 $

if strcmp(c.att.Source,'MATFILE')
   autoName=sprintf('File %s', c.att.Filename); 
else
   autoName='MATLAB Workspace';
end

strout=sprintf('Variable Table - %s', autoName);