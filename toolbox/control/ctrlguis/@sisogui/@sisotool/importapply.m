function importapply(sisodb,ImportFig)
%IMPORTAPPLY  OK Callback for Import dialog.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/05/04 02:11:11 $

ImportUd = get(ImportFig,'UserData');
LoopData = sisodb.LoopData;
HG = sisodb.HG;

% Get values of specified models
ModelData = ImportUd.ModelData;        % initial data 
NewP = LocalGetModel(ImportUd,1,ModelData.Plant,'untitledG');
NewH = LocalGetModel(ImportUd,2,ModelData.Sensor,'untitledH');
NewF = LocalGetModel(ImportUd,3,ModelData.Filter,'untitledF');
NewC = LocalGetModel(ImportUd,4,ModelData.Compensator,'untitledC');

% Start import transaction
% RE: Beware that IMPORTDATA may throw an error if data is invalid
try
    % Create transaction
    T = ctrluis.transaction(LoopData,'Name','Import',...
        'OperationStore','on','InverseOperationStore','on');

    % Import data to LoopData (may error out)
    set(ImportFig,'Pointer','watch');
    LoopData.importdata(NewP,NewH,NewF,NewC);
    
    % Updated system name, feedback sign, and loop configuration
    LoopData.SystemName = get(ImportUd.Handles.SystemNameEdit,'String');
    LoopData.FeedbackSign = ModelData.FeedbackSign;
    LoopData.Configuration = ModelData.Configuration;
    
    % Commit and store transaction
    sisodb.EventManager.record(T);
    
    % Notify peers of data change
    LoopData.dataevent('all');
catch
    % Invalid data: abort
    delete(T)
    % Parse error message and remove leading "Error..."
    errmsg = lasterr;
    idx = findstr('Error',errmsg);
    if ~isempty(idx)
        [junk,errmsg] = strtok(errmsg(idx(end):end),sprintf('\n'));
    end
    % Pop up error dialog and abort apply
    errordlg(strtok(errmsg,sprintf('\n')),'Import Error')
    % resetting figure pointer to arrow.
    set(ImportFig,'Pointer','arrow');
    return
end


% Close system data view if open
% REVISIT: should update
DataViews = sisodb.DataViews;
delete(findobj(DataViews(ishandle(DataViews)),'flat','Tag','SystemView'))

% Update status bar and history
sisodb.EventManager.newstatus('Imported model data. Right-click on the plots for design options.');
sisodb.EventManager.recordtxt('history','Imported new system/compensator models.');

% Close import figure
close(ImportFig)


%--------------------------Local Functions------------------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalGetModel %%%
%%%%%%%%%%%%%%%%%%%%%
function NewModel = LocalGetModel(ImportDB,ord,CurrentModel,DefaultName)
% Returns the new model based on the user input in the given edit box

% Update model using user input
NewModel = CurrentModel;
thisModel = ImportDB.ImportedModel{ord};
if ~isempty(thisModel)
   NewModel.Model = thisModel;
   thisName = ImportDB.ImportedModelNames{ord};
   if isempty(thisName)
      NewModel.Name = DefaultName;
   else
      NewModel.Name = thisName;
   end
end
