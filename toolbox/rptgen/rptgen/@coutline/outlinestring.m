function strout=outlinestring(c)
%OUTLINESTRING displays a single-line outline representation of the component
%   STRING=OUTLINESTRING(COUTLINE)
%
%   See also GETINFO, ATTRIBUTE, EXECUTE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:27 $

%strout='Report Outline';

[sPath sFile sExt sVer]=fileparts(c.rptcomponent.SetfilePath);
if isempty(sFile)
   sFile='Unnamed';
end
if isempty(sExt)
   sExt='.rpt';
end

strout=sprintf('Report - %s%s', sFile, sExt);