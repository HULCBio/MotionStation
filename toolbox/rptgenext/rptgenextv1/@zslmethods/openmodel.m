function handle=openmodel(m,handle,visible)
%OPENMODEL opens a Simulink model

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:45 $

if nargin<3
   visible=logical(0);
end


if isempty(find_system('SearchDepth',0,...
      'Name',handle)) & ~isempty(handle)
   try
      evalin('base',LocLoadStr(handle,visible));
   catch
      try
         evalin('base',LocLoadStr(handle,visible));
         handle='simulink';
      catch
         handle='';
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lStr=LocLoadStr(mdlName,visible)

if visible
   lStr=['open_system(''' mdlName ''');'];
else
   lStr=[mdlName '('''','''','''',''load'');'];
end
