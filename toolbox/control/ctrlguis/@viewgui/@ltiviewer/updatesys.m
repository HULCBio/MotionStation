function updatesys(this,oldSystems,newSystems)
%UPDATESYS   PreSet callback for change in Systems list.

%   Author(s) : Kamesh Subbarao 
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 2002/04/14 22:40:14 $

% Determine new set of I/O names (and I/O size)
newModels = get(newSystems,{'Model'});
if ~isempty(newModels)
   [this.InputNames,this.OutputNames] = mrgios(newModels{:});
else
   this.InputNames = {''};
   this.OutputNames = {''};
end
   
% Determine which systems are deleted, added, or kept unchanged.
[junk,ia,ib] = intersect(oldSystems,newSystems);
ia = sort(ia);  % watch for resorting
DelSys = oldSystems;  DelSys(ia,:)=[];
AddSys = newSystems;   AddSys(ib,:)=[];
KeepSys = oldSystems(ia);

% Assign names to added systems with unspecified names
setSystemNames(KeepSys,AddSys)

% Update system Styles (assign style to each added system)
StyleList = this.Styles(ia);
for ct = 1:length(AddSys)
   StyleList = [StyleList;this.StyleManager.dealstyle(StyleList)];
end
this.Styles = StyleList;

% Notify plots
senddata = struct(...
    'OutNames',  {this.OutputNames},...
    'InNames',   {this.InputNames},...
    'DelSys',    DelSys, ...
    'AddSys',    AddSys,...
    'AddSysStyle',  StyleList(length(ia)+1:end));
this.send('SystemChanged',...
        ctrluis.dataevent(this,'SystemChanged',senddata));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETSYSTEMNAMES resolves the system names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setSystemNames(Systems, AddSys)
%
% Resolves system names
% 
SysList = [Systems;AddSys];
for ct = 1:length(AddSys)
    if isempty(AddSys(ct).Name)
        % Assign untitled## name when name is unspecified
        Names = get(SysList,{'Name'});
        Names = [Names{:}];
        n = 1;
        while ~isempty(strfind(Names,sprintf('untitled%d',n)))
            n = n+1;
        end
        AddSys(ct).Name = sprintf('untitled%d',n);
    end
    SysList = [Systems;AddSys];
end