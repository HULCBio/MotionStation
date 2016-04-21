function dispprop(L,StaticFlag)
%DISPPROP  Creates display for LTI properties

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2003/01/07 19:32:00 $

% Display input Groups
Igroup = getgroup(L.InputGroup);
Ogroup = getgroup(L.OutputGroup);
disp(FormatGroup(Igroup,Ogroup));

% Display sample time (for discrete-time models only)
if ~StaticFlag,
   if L.Ts<0,
      disp('Sampling time: unspecified')
   elseif L.Ts>0,
      disp(sprintf('Sampling time: %0.5g',L.Ts))
   end
end


% Subfunction FORMATGROUP
%%%%%%%%%%%%%%%%%%%%%%%%%
function Display = FormatGroup(Igroup,Ogroup);

Display = [];
Blank = ' ';

% Input groups
Names = fieldnames(Igroup);
ng = length(Names);
if ng>0
   Channels = cell(ng,1);
   for i=1:ng,
      str = sprintf('%d,',Igroup.(Names{i}));
      Channels{i} = str(1:end-1);
   end
   Names = strjust(strvcat('Name',char(Names)),'center');
   Channels = strjust(strvcat('Channels',char(Channels)),'center');
   Display = strvcat(Display,'Input groups:',...
      [Blank(ones(ng+1,4)) , Names , ...
         Blank(ones(ng+1,4)) , Channels],' ');
end

% Input groups
Names = fieldnames(Ogroup);
ng = length(Names);
if ng>0
   Channels = cell(ng,1);
   for i=1:ng,
      str = sprintf('%d,',Ogroup.(Names{i}));
      Channels{i} = str(1:end-1);
   end
   Names = strjust(strvcat('Name',char(Names)),'center');
   Channels = strjust(strvcat('Channels',char(Channels)),'center');
   Display = strvcat(Display,'Output groups:',...
      [Blank(ones(ng+1,4)) , Names , ...
         Blank(ones(ng+1,4)) , Channels],' ');
end

