function Warn = load(this,Proj,SilentFlag)
% Import settings from another project (R14 only)

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:45:02 $
%   Copyright 1986-2004 The MathWorks, Inc.
Warn = '';
if isa(Proj,'struct')
   % old ncdStruct
   this.loadNCDStruct(Proj)
else
   % Check model name consistency (in case model has been renamed)
   if ~strcmp(this.Model,Proj.Model)
      s1 = sprintf('Loaded optimization project was created for a different model (%s)',Proj.Model);
      s2 = 'Proceed anyway?';
      s3 = 'Note: Resave your project to eliminate this warning.';
      Q = sprintf('%s. %s\n\n%s',s1,s2,s3);
      if nargin==3 || strcmp(questdlg(Q,'Load Warning'),'Yes')
         % RE: Always go ahead at model load time
         Proj.renameModel(this.Model)
      else
         return
      end
   end
   this.Parameters = Proj.Parameters;
   this.OptimOptions = Proj.OptimOptions;
   % Create uncertainty test if necessary
   if length(Proj.Tests)>length(this.Tests)
      t = copy(this.Tests(1));
      t.Specs = this.Tests(1).Specs;
      this.Tests(2,1) = t;
   end
   for ct=1:length(this.Tests)
      this.Tests(ct).Enable = Proj.Tests(ct).Enable;
      this.Tests(ct).Optimized = Proj.Tests(ct).Optimized;
      this.Tests(ct).Runs = Proj.Tests(ct).Runs;
   end
   % REVISIT: Current options dialog requires shared sim options
   set(this.Tests,'SimOptions',Proj.Tests(1).SimOptions)

   % Loop over each constraint/block in current project
   % and look for loaded constraint with matching path
   Warn = cell(0,1);
   CurrentC = this.Tests(1).Specs;
   for ct=1:length(CurrentC)
      % Find matching loaded constraint
      C = Proj.Tests(1).findspec(CurrentC(ct).SignalSource.LogID);
      if isempty(C)
         % No matching constraint in loaded project
         BlockName = find_system(this.Model,'FollowLinks','on','LookUnderMasks','all',...
            'BlockType','SubSystem','LogID',CurrentC(ct).SignalSource.LogID);
         BlockName = BlockName{1};
         idx = findstr(BlockName,'/');
         BlockName = BlockName(idx(end)+1:end);
         Warn = [Warn;{sprintf('Loaded optimization project does not contain settings for block "%s."',BlockName)}];
      else
         CurrentC(ct) = C;
      end
   end
   set(this.Tests,'Specs',CurrentC)
   Warn = char(Warn);
end


