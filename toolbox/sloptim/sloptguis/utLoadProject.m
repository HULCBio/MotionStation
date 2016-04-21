function [Proj,errmsg] = utLoadProject(SaveIn,SaveAs)
% Loads SRO project from workspace or MAT file.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/01/03 12:28:13 $
%   Copyright 1990-2003 The MathWorks, Inc. 
errmsg = '';
switch SaveIn
   case 'workspace'
      Proj = evalin('base',SaveAs,'[]');
      if isa(Proj,'srogui.SimProjectForm')
         Proj = copy(Proj);
      elseif isempty(Proj) || ~isNCDStruct(Proj)
         errmsg = sprintf('Workspace variable %s not found or does not contain valid settings.',SaveAs);
      end
   case 'MAT file'
      ws = warning('off'); lw = lastwarn;
      try
         s = load(SaveAs);
      catch
         s = struct;
      end
      warning(ws); lastwarn(lw)
      if isfield(s,'OptimProject') && isa(s.OptimProject,'srogui.SimProjectForm')
         Proj = s.OptimProject;
      elseif isfield(s,'ncdStruct') && isNCDStruct(s.ncdStruct)
         % For backward compatibility
         Proj = s.ncdStruct;
      else
         errmsg = sprintf('MAT file %s not found or does not contain valid settings.',SaveAs);
         Proj = [];
      end
end
