function display(sys)
%DISPPROP  Creates display for LTI properties

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:23 $

% Display input Groups
Igroup = getgroup(sys.InputGroup);
Ogroup = getgroup(sys.OutputGroup);
disp(FormatGroup(Igroup,Ogroup));

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

