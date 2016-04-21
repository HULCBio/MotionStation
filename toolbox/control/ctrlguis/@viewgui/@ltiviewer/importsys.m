function importsys(this,ImportSysNames,ImportSysValues)
%IMPORTSYS  Imports LTI systems into the LTI Viewer.

%   Author: Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/05/04 02:08:53 $

%% Convert to a cell array if needed
if ~iscell(ImportSysNames)
    ImportSysNames = {ImportSysNames};
end
if ~iscell(ImportSysValues)
    ImportSysValues = {ImportSysValues};
end
Systems = this.Systems;

% Optimization to prevent multiple limit updates during refresh
ActiveViews = getCurrentViews(this);
AxGrids = get(find(ActiveViews,'-isa','wrfc.plot'),{'AxesGrid'});
AxGrids = cat(1,AxGrids{:});
set(AxGrids,'LimitManager','off')

% Determine which systems are added and which systems are refreshed
[junk,ia,ib] = intersect(get(Systems,{'Name'}),ImportSysNames);
[ia,is] = sort(ia);  ib = ib(is);  % watch for resorting
addSysName = ImportSysNames;  addSysName(ib) = []; %% Systems to be added
addSysVal = ImportSysValues;  addSysVal(ib) = [];  
refreshSys  = Systems(ia);   %% Systems to be refreshed
refreshSysVal = ImportSysValues(ib); 

% First refresh existing systems
if ~isempty(refreshSys)
   indDelSys = [];
   resizedSys = [];
   for ct = 1:length(refreshSys)
      if isequal(size(refreshSysVal{ct}),size(refreshSys(ct).Model))
         % Same-size update: modify source model
         refreshSys(ct).Model = refreshSysVal{ct};
      else
         % I/O size or number of models changes: delete existing source
         % and create new one
         indDelSys = [indDelSys ; ia(ct)];
         resizedSys = [resizedSys ; ...
               resppack.ltisource(refreshSysVal{ct},'Name',refreshSys(ct).Name)];
      end
   end
   Systems(indDelSys) = [];
   Systems = [Systems;resizedSys];
end

% Add new systems
addSys = [];
for ct = 1:length(addSysName)
   addSys = [addSys ; resppack.ltisource(addSysVal{ct},'Name',addSysName{ct})]; 
end
Systems = [Systems;addSys];

% Turn limit managers back on
set(AxGrids,'LimitManager','on')
if isequal(this.Systems,Systems) & ~isempty(ImportSysNames)
   % Force update
   for ax=AxGrids'
      ax.send('ViewChanged')
   end
end

% Update Systems (triggers plot update)
this.Systems = Systems;

% Notify plots (e.g., to issue a warning when some models cannot be plotted)
if ~isempty(ImportSysNames)
   this.send('ModelImport',...
      ctrluis.dataevent(this,'ModelImport',[addSys;refreshSys]));
end
