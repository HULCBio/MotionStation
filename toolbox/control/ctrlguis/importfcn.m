function varargout = importfcn(action,ImportFig)
%IMPORTFCN contains functions standard to all CODA Import windows
%
%   DATA = IMPORTFCN(ACTION,ImportFig) performs the action specified by 
%   the string ACTION on the Import figure with handle ImportFig. The  
%   output returned in DATA depends on which action is entered.  

%   Possible ACTIONS:
%   1) browsesim, broswemat: Opens a standard MATLAB browser for locating a 
%                            Simulink diagram or MAT-file
%   2) arrowcallback: Performs the actions for the arrow buttons
%   3) editcallback: Performs the actions for the P,F,H,C edit boxes
%   4) radiocallback: Performs the actions for the radio buttons
%   5) matfile: Performs the actions for the MAT-file radio button
%   6) namecallback: Performs the actions for the Name edit boxes
%   7) simulink: Performs the actions for the Simulink radio button
%   8) workspace: Performs the actions for the Workspace radio button

%   Karen D. Gondoly
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.28 $  $Date: 2002/04/10 04:42:34 $

action = lower(action);
if ~ishandle(ImportFig), 
   error('The second input argument must be a valid figure handle.'); 
end 
ImportDB = get(ImportFig,'UserData');  % Database for Import dialog 

switch action
   
case {'browsesim','browsemat'}

   switch action
   case 'browsesim',
      filterspec = '*.mdl';
   case 'browsemat',
      filterspec = '*.mat';
   end
   udFileEdit = get(ImportDB.Handles.FileNameEdit,'UserData');
   LastPath = udFileEdit.PathName;
   CurrentPath=pwd;
   if ~isempty(LastPath),
      cd(LastPath);
   end
   [filename,pathname] = uigetfile(filterspec,'Import file:');
   if ~isempty(LastPath),
      cd(CurrentPath);
   end

   if filename,
      if ~strcmpi(pathname(1:end-1),CurrentPath)
         ImportStr = [pathname,filename(1:end-4)];
      else
         ImportStr = filename(1:end-4);
      end
      set(ImportDB.Handles.FileNameEdit,'String',ImportStr);
      switch action
      case 'browsesim',
         importfcn('simulink',ImportFig);
      case 'browsemat',
         importfcn('matfile',ImportFig);
      end
   end
   
case 'arrowcallback',
   %---Callback for the Arrow Buttons

   ord = find(ImportDB.Handles.ArrowButton == gcbo);
   EditBox = ImportDB.Handles.ModelEdit(ord);
   AllNames = get(ImportDB.Handles.ModelList,'String');
   if ~isempty(AllNames), % Make sure these is something in the list
      SelectedName = get(ImportDB.Handles.ModelList,'Value');
      ImportDB.ImportedModel{ord} = ImportDB.ListData.Models{SelectedName};
      ImportDB.ImportedModelNames{ord} = ImportDB.ListData.Names{SelectedName};
      set(EditBox,'String',AllNames{SelectedName});
      % Enable OK
      set(ImportDB.Handles.OKButton,'Enable','on')
      set(ImportFig,'UserData',ImportDB); 
   end
   
case 'changeconfig',
   %---Next button callback
   udButton = get(gcbo,'UserData');
   IndCurrent = find(udButton.Current==udButton.Available);
   if isequal(IndCurrent,length(udButton.Available)),
      IndNext=1;
   else
      IndNext = IndCurrent+1;
   end
   
   ImportDB.Handles.Configuration = ...
       loopstruct(IndNext,ImportDB.Handles.ConfigurationAxes);
   ImportDB.ModelData.Configuration = IndNext;
   udButton.Current = IndNext;
   set(gcbo,'UserData',udButton)
   set(ImportFig,'UserData',ImportDB);
   
case 'clearpath',
   %---Callback for the FileNameEdit box
   %    Whenever a new name is entered, update the Userdata
   NewName = get(gcbo,'String');
   indDot = findstr(NewName,'.');
   if ~isempty(indDot),
      NewName=NewName(1:indDot(end)-1);
      set(ImportDB.Handles.FileNameEdit,'String',NewName)   
   end
      
case 'editcallback',
   %---Callback for the Plant, Sensor, Filter, Compensator Edit boxes
   %---These boxes should contain an index into the List Box string
   %---The Index should be zero when a scalar or LTI constructor is entered
   CBObj = gcbo;
   TryString = get(CBObj,'String');
   ord = find(ImportDB.Handles.ModelEdit == CBObj);
   IndList = find(strcmp(TryString,ImportDB.ListData.Names));
   if isempty(IndList),
      % Evaluate in base
      if length(TryString)
         tempval = evalin('base',TryString,'[]');
      else
         tempval = [];
      end
      % See if a scalar real or LTI object was entered
      if isequal(size(tempval),[1 1]) & (isa(tempval,'lti') | isreal(tempval))
         ImportDB.ImportedModel{ord} = tempval;
         if evalin('base',['exist(''' TryString ''')'],'false') %valid LTI model in wspace
            ImportDB.ImportedModelNames{ord} = TryString;
         else
            ImportDB.ImportedModelNames{ord} = ''; %expression (eg rss(2)) or scalar
         end
         ImportDB.ImportExpression{ord} = TryString;
      else 
         % Revert to last valid entry

         lastValidString = ImportDB.ImportExpression{ord};
         if isempty(lastValidString)
             switch ord
             case 1
               set(CBObj,'String',LocalGetName(ImportDB.ModelData.Plant,0));
             case 2
               set(CBObj,'String',LocalGetName(ImportDB.ModelData.Sensor,0));
             case 3
               set(CBObj,'String',LocalGetName(ImportDB.ModelData.Filter,1));
             case 4
               set(CBObj,'String',LocalGetName(ImportDB.ModelData.Compensator,1));
             end
         else
             set(CBObj,'String',lastValidString);
         end
         
         WarnStr = 'You must enter a valid SISO LTI model or a scalar.';
         warndlg(WarnStr,'Import Warning','modal');
         return
      end 
   else % store selected model in list
      ImportDB.ImportedModel{ord} = ImportDB.ListData.Models{IndList};
      ImportDB.ImportedModelNames{ord} = ImportDB.ListData.Names{IndList};
   end % if/else isempty(IndList);
   % Enable OK
   set(ImportDB.Handles.OKButton,'Enable','on')
   set(ImportFig,'UserData',ImportDB);
case 'matfile',
   set(ImportDB.Handles.ModelText,'string','SISO Models');
   set([ImportDB.Handles.FileNameText,...
         ImportDB.Handles.FileNameEdit,...
         ImportDB.Handles.BrowseButton],'enable','on');
   set(ImportDB.Handles.FileNameText,'String','MAT-file name:');
   set(ImportDB.Handles.BrowseButton,'Callback','importfcn(''browsemat'',gcbf);');
   set(ImportDB.Handles.FileNameEdit,...
      'Callback','importfcn(''clearpath'',gcbf);importfcn(''matfile'',gcbf);');
   
   FileName = get(ImportDB.Handles.FileNameEdit,'String');   
   if isempty(FileName),
      Data=struct('Names','','Models',[]);
   else
      try
         load(FileName);
         WorkspaceVars=whos;
         sysvar=cell(size(WorkspaceVars));
         s=0;
         for ct=1:size(WorkspaceVars,1),
            VarClass=WorkspaceVars(ct).class;
            if any(strcmp(VarClass,{'tf','ss','zpk'})) & isequal(WorkspaceVars(ct).size,[1 1])
               % Only look for Non-array (TF, SS, and ZPK) LTI Models
               s=s+1;
               sysvar(s)={WorkspaceVars(ct).name};
            end % if isa
         end % for ct
         sysvar=sysvar(1:s);
         
         DataModels = cell(s,1);
         for ctud=1:s,
            DataModels{ctud} = eval(sysvar{ctud});
         end % for
         Data = struct('Names',{sysvar},'Models',{DataModels});
         
      catch
         warndlg(lasterr,'Import Warning'); 
         set(ImportDB.Handles.FileNameEdit,'String','');
         FileName='';
         Data=struct('Names','','Models',[]);
      end % try/catch
   end % if/else check on FileName
   
   LocalFinishLoad(ImportFig,ImportDB,FileName,Data)
   
case 'namecallback',
   %---Callback for the Name Edit field
   newname = deblank(get(gcbo,'String'));
   if isempty(newname) | ... % New name is empty
           ~isnan(str2double(newname(1)))   % New name starts with a number
       set(gcbo,'String',get(gcbo,'UserData'));
   else
       newname = fliplr(deblank(fliplr(newname)));
       set(gcbo,'String',newname,'UserData',newname);
   end
   
case 'radiocallback',
   CBObj = gcbo;
   val = get(CBObj,'Value');
   sibs = get(CBObj,'UserData');
   
   if ~val,
      set(CBObj,'Value',1);
   elseif val==1,
      set(sibs,'Value',0);
      set(ImportDB.Handles.FileNameEdit,'String','', ...
         'UserData',struct('FileName',[],'PathName',[]));
   end % if/else val
   
case 'simulink',
   set(ImportDB.Handles.ModelText,'string','SISO LTI Blocks');
   set([ImportDB.Handles.FileNameText,...
         ImportDB.Handles.FileNameEdit,...
         ImportDB.Handles.BrowseButton],'enable','on');
   set(ImportDB.Handles.FileNameText,'String','Simulink Diagram:');
   set(ImportDB.Handles.BrowseButton,'Callback','importfcn(''browsesim'',gcbf);');
   set(ImportDB.Handles.FileNameEdit,...
      'Callback','importfcn(''clearpath'',gcbf);importfcn(''simulink'',gcbf);');
   
   FullName = get(ImportDB.Handles.FileNameEdit,'String');   
   
   [PathName,FileName]=fileparts(FullName);
   %---First, see if a model with the same name is already open.
   AllDiags = find_system('Type','block_diagram');
   indOpen = find(strcmpi(FileName,AllDiags));
   if ~isempty(indOpen),
      switch questdlg({'A Simulink model with the same name is already open.'; ...
               ''; ...
               'Do you want to replace the open model with the specified model?'}, ...
            'Import Warning','Yes','No','Cancel','Yes');
      case 'Cancel',
         %---Reset FileNameEdit Box to previous string
         udNames = get(ImportDB.Handles.FileNameEdit,'UserData');
         if ~strcmpi(udNames.PathName(1:end-1),pwd)
            ImportStr = [udNames.PathName,udNames.FileName];
         else
            ImportStr = udNames.FileName;
         end
         set(ImportDB.Handles.FileNameEdit,'String',ImportStr);
         FullName='';
      case 'Yes',
         switch get_param(AllDiags{indOpen},'dirty'),
         case 'on',
            switch questdlg(sprintf('Save %s before closing?',AllDiags{indOpen}),... 
                  sprintf('Closing %s',AllDiags{indOpen}),'Yes','No','Cancel','Yes'), 
            case 'Yes',
               SaveFlag = 1;
            case 'No',
               SaveFlag = 0;
            case 'Cancel',
               return
            end % switch questdlg
            case 'off',
               SaveFlag = 0;
         end % switch dirty
         close_system(AllDiags{indOpen},SaveFlag);
      case 'No',
         %---Reset FileNameEdit Box to previous string
         set(ImportDB.Handles.FileNameEdit,'String',FileName);
         FullName=FileName;
      end
   end % if ~isempty(indOpen)
   
   if isempty(FullName),
      Data=struct('Names','','Models',[]);
   else
      try,
         %---Open the model, or catch a bad model name
         Data=struct('Names','','Models',[]);
         evalc('open_system(FullName)');
         
         %---Read all LTI blocks out of the Simulink diagram
         LTIblocks = find_system(FileName,'MaskType','LTI Block');
         DataNames = char(LTIblocks);
         
         %---Remove newline and carriage returns
         AsciiVals = real(DataNames);
         if ~isempty(DataNames),
            DataNames(find(AsciiVals==10 | AsciiVals==13))='_';
            DataNames = cellstr(DataNames(:,length(FileName)+2:end));
         end
         
         DataModels = cell(length(LTIblocks),1);
         MaskStrs = get_param(LTIblocks,'MaskValueString');
         SISOFlag = logical(zeros(length(LTIblocks),1));
         
         BadBlockFlag = 0;
         for ct=1:length(LTIblocks)
             BarInd = findstr(MaskStrs{ct},'|');
             LTIModel = evalin('base',MaskStrs{ct}(1:BarInd-1),'[]');
             if isempty(LTIModel),
                 warndlg('One of the LTI Blocks contains an invalid LTI Object.',...
                     'Import Warning');
                 BadBlockFlag = 1;
             else
                 DataModels{ct} = LTIModel;
                 SISOFlag(ct) = isequal(size(LTIModel),[1 1]);
             end
         end % for ct
         
         if ~BadBlockFlag,
             % Weed out non SISO blocks
             Data.Names = DataNames(SISOFlag);
             Data.Models = DataModels(SISOFlag);
         end
         
     catch
         warndlg(lasterr,'Import Warning');
         set(ImportDB.Handles.FileNameEdit,'String','');
         Data=struct('Names','','Models',[]);
      end, % try/catch
   end % if ~isempty(FileName)

   LocalFinishLoad(ImportFig,ImportDB,FullName,Data)
   
   
case 'workspace',
   set(ImportDB.Handles.ModelText,'string','SISO Models');
   set([ImportDB.Handles.FileNameText,...
         ImportDB.Handles.FileNameEdit,...
         ImportDB.Handles.BrowseButton],'enable','off');
   
   %----Look for all workspace variables that are SISO models
   WorkspaceVars=evalin('base','whos');
   Nvars = length(WorkspaceVars);
   isSisoModel = logical(zeros(Nvars,1));
   for ct=1:Nvars,
      isSisoModel(ct) = logical(feval(ImportDB.Filter,WorkspaceVars(ct)));
   end
   sysvar = {WorkspaceVars(isSisoModel).name}.';

   Nsys = length(sysvar);
   DataModels = cell(Nsys,1);
   for ctud=1:Nsys,
      DataModels(ctud) = {evalin('base',sysvar{ctud})};
   end
   
   Data = struct('Names',{sysvar},'Models',{DataModels});
   set(ImportDB.Handles.ModelList,'String',sysvar)
   
   %---Update the Import Figure Userdata
   ImportDB.ListData=Data;
   set(ImportFig,'UserData',ImportDB);
      
case 'help'
    % Callback for Help button
    set(ImportFig,'WindowStyle','normal');
    
end


%-----------------------------Internal Functions--------------------------
%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalFinishLoad %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalFinishLoad(ImportFig,ImportDB,FileName,Data)

%---Update the FileNameEdit Userdata
[P,F]=fileparts(FileName);
udNames = get(ImportDB.Handles.FileNameEdit,'UserData');
udNames.PathName=P; 
udNames.FileName=F;
set(ImportDB.Handles.FileNameEdit,'UserData',udNames)

%---Update the Import Figure Userdata
set(ImportDB.Handles.ModelList,'value',1);
set(ImportDB.Handles.ModelList,'String',Data.Names)
ImportDB.ListData=Data;
set(ImportFig,'UserData',ImportDB);


%%%%%%%%%%%%%%%%%%%%
%%% LocalGetName %%%
%%%%%%%%%%%%%%%%%%%%
function ModelName = LocalGetName(ModelData,ProtectFlag)
% Get model name to display in edit boxes
[z,p,k] = zpkdata(ModelData.Model,'v');

if isempty(z) & isempty(p) & abs(k)==1,
    % Model is 1 or -1
    ModelName = sprintf('%d',k);
else
    % Use model name
    ModelName = ModelData.Name;
    if ProtectFlag,
       % RE: Protect against overwriting changes to imported compensator
       ModelName = sprintf('(edited) %s',ModelName);
   end
end
