function sqload(hFig, file, force)
%LOAD Load a saved session into SQDTool

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/07/10 19:48:04 $

if nargin < 3, force = 'noforce'; end
ud=get(hFig,'UserData');

% Don't load if GUI is dirty.
if strcmpi(force, 'force') | sqsave_if_dirty(hFig,'loading'),
    if nargin == 1,
        % Change to the directory where the current session lives.
        old_pwd = pwd;
        
        [path,name,ext] = fileparts(ud.FileName);
        if ~isempty(path); cd(path); end
        
        % Load the file.
        [filename,pathname] = uigetfile('*.sqd','Load SQ Design Session');
        file = [pathname filename];
        
        % Return to old pwd ASAP after loading the file.
        cd(old_pwd);
    end
    
    % Skip loading if Cancel button is pressed on save dialog.
    if file ~= 0,
        set(ud.hTextStatus,'ForeGroundColor','Black');
        set(ud.hTextStatus,'String', 'Loading session file ...'); 
        load_exec(hFig, file, filename);
        %set(ud.hTextStatus,'String',strcat(str,'done.'));
    end
end

%--------------------------------------------------------------------
function load_exec(hFig,file, filename)

% Turning warning off in case the load warns
w = warning('off'); % cache warning state
[successflag] = loadandcheckforcorruptfile(file,hFig, filename);
warning(w); % Reset the warning state

%----------------------------------------------------------------
function [successflag] = loadandcheckforcorruptfile(file,hFig, filename)

ud=get(hFig,'UserData');
%%%%%%%% 
% Do not allow user to open sqdtool from here. Saving as sqdtool is also prohobited
if filename ~= 0,
    [filename_tmp, ext] = strtok(filename, '.');
end    
%   % Unix returns a path that sometimes includes two paths (the
% 	% current path followed by the path to the file) seperated by '//'.
% 	% Remove the first path.
% 	indx = findstr(file,[filesep,filesep]);
% 	if ~isempty(indx)
%         file = file(indx+1:end);
% 	end
if strcmpi(filename_tmp, 'SQDTOOL')
    set(ud.hTextStatus,'ForeGroundColor','Red');
    set(ud.hTextStatus,'String', 'Error loading: File name cannot be sqdtool'); 
    successflag = 0; 
    return
end  
%%%%%%%% 
try
    % Load session file: loads savedUDforSQDTool
     load(file,'-mat');
catch
     set(ud.hTextStatus,'ForeGroundColor','Red');
     set(ud.hTextStatus,'String', 'Error loading: Unable to open the session'); 
     successflag = 0; 
     return
end 

%%%%%%%% 
try
    if (savedUDforSQDTool.SQDTOOLidentifier)
    %%%
    end
catch
    set(ud.hTextStatus,'ForeGroundColor','Red');
    set(ud.hTextStatus,'String', 'Error loading: This is not a valid SQDTOOL session'); 
    successflag = 0; 
    return
end 

% Update the existing figure with the new setting
    update_successflag = update_figure_for_load (savedUDforSQDTool, hFig, file);
    successflag = update_successflag;
    
%--------------------------------------------------------------------------------------
function update_successflag = update_figure_for_load (savedUDforSQDTool, hFig, file)
ud=get(hFig,'UserData');
try 
  %store setting of sqdtool GUI : step-1 (edit box strings)
    handles = guidata(hFig);
    if ~strcmp(get(handles.editTS,'String'),savedUDforSQDTool.TSstring)
       set(handles.editTS,'String', savedUDforSQDTool.TSstring)
    end       
    if ~strcmp(get(handles.editNumLevel,'String'),savedUDforSQDTool.numLevelString)
       set(handles.editNumLevel,'String', savedUDforSQDTool.numLevelString);
    end 
    if ~strcmp(get(handles.editInitCB,'String'),savedUDforSQDTool.initCBString)
       set(handles.editInitCB,'String', savedUDforSQDTool.initCBString);
    end 
    if ~strcmp(get(handles.editInitPT,'String'),savedUDforSQDTool.initPTString)
       set(handles.editInitPT,'String', savedUDforSQDTool.initPTString);
    end 
    if ~strcmp(get(handles.editRelTh,'String'),savedUDforSQDTool.RelThString)
       set(handles.editRelTh,'String', savedUDforSQDTool.RelThString);
    end 
    if ~strcmp(get(handles.editMaxIter,'String'),savedUDforSQDTool.maxIterString)
       set(handles.editMaxIter,'String', savedUDforSQDTool.maxIterString);
    end 
    if (savedUDforSQDTool.version ==1)
           % using the existing values 
    else% (ud.version ==2)
            if ~strcmp(get(handles.editEncBlkName,'String'),savedUDforSQDTool.EncBlkNameString)
               set(handles.editEncBlkName,'String', savedUDforSQDTool.EncBlkNameString);
            end 
            if ~strcmp(get(handles.editDecBlkName,'String'),savedUDforSQDTool.DecBlkNameString)
               set(handles.editDecBlkName,'String', savedUDforSQDTool.DecBlkNameString);
            end 
    end
    
  % make GUI items enable/disable: initCB spec, initPT spec 
     if (ud.popupSQSource ~= savedUDforSQDTool.popupSQSource)
        set( handles.popupSQSource,'Value',savedUDforSQDTool.popupSQSource);
		if (savedUDforSQDTool.popupSQSource==1)%% auto-generate initCB
			setenableprop([handles.textNumLevel   handles.editNumLevel],    'on');
            setenableprop([handles.textInitCB     handles.editInitCB],      'off');
			setenableprop([handles.textInitPTSource handles.popupInitPTSource], 'off');
			setenableprop([handles.textInitPT     handles.editInitPT],      'off');
		else%% user-defined initCB
			setenableprop([handles.textNumLevel   handles.editNumLevel],    'off');
			setenableprop([handles.textInitCB     handles.editInitCB],      'on');
            setenableprop([handles.textInitPTSource handles.popupInitPTSource], 'on');
            if (ud.popupInitPTSource ~= savedUDforSQDTool.popupInitPTSource)
                %%set( handles.popupInitPTSource,'Value',savedUDforSQDTool.popupInitPTSource);
                %%see below
                if (savedUDforSQDTool.popupInitPTSource==1) %% auto-generate initPT
				    setenableprop([handles.textInitPT   handles.editInitPT],    'off');
                else %%user-defined initPT
				    setenableprop([handles.textInitPT   handles.editInitPT],    'on');
                end 
           end                
		end   
    end
  % set it independent of the choice for popupSQSource
    if (ud.popupInitPTSource ~= savedUDforSQDTool.popupInitPTSource)
        set( handles.popupInitPTSource,'Value',savedUDforSQDTool.popupInitPTSource);
    end        

  % make GUI items enable/dosable: stop-criteria
    if (ud.popupStopCri ~= savedUDforSQDTool.popupStopCri)
        set( handles.popupStopCri,'Value',savedUDforSQDTool.popupStopCri);
		if (savedUDforSQDTool.popupStopCri==1)%% stop-criteria: Threshold
			setenableprop([handles.textMaxIter   handles.editMaxIter],    'off');
            setenableprop([handles.textRelTh     handles.editRelTh],    'on');
		elseif (savedUDforSQDTool.popupStopCri==2)%% stop-criteria: MaxIter 
			setenableprop([handles.textRelTh     handles.editRelTh],    'off');
            setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
		else%% stop-criteria: Threshold || MaxIter 
			setenableprop([handles.textRelTh     handles.editRelTh],    'on');
            setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
		end   
    end
    
  % make GUI items enable/dosable: search method, tie-break rule, overwriteblock checkbox
    if (ud.popupSearchMeth ~= savedUDforSQDTool.popupSearchMeth)
	   set(handles.popupSearchMeth,'Value', savedUDforSQDTool.popupSearchMeth);
    end 
    if (ud.popupTieBreakRule ~= savedUDforSQDTool.popupTieBreakRule)
	   set(handles.popupTieBreakRule,'Value', savedUDforSQDTool.popupTieBreakRule);
    end 
    if (ud.popupDestMdl ~= savedUDforSQDTool.popupDestMdl)
	   set(handles.popupDestMdl,'Value', savedUDforSQDTool.popupDestMdl);
       % set enable/disable property of checkbox
       if (savedUDforSQDTool.popupDestMdl==1)%% current model
	       setenableprop(handles.chkboxOverwriteBlock,  'on');
       else%%  new model
	       setenableprop(handles.chkboxOverwriteBlock,  'off');
       end  
    end 
    if (savedUDforSQDTool.version ==1)
        savedUDforSQDTool.popupBlockType = 3; % both
    end    
        
    if (ud.popupBlockType ~= savedUDforSQDTool.popupBlockType)
	   set(handles.popupBlockType,'Value', savedUDforSQDTool.popupBlockType);
       % set enable/disable property of block name texts and edit boxes
       if (savedUDforSQDTool.popupBlockType==1)%% Encoder
            setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'on');
			setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'off');
	   elseif (savedUDforSQDTool.popupBlockType==2)%% Decoder
			setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'off');
			setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'on');
	   else%% Both
			setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'on');
			setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'on');   
	   end    
       
    end

    % set saved value of check box
    if (ud.chkboxOverwriteBlock ~= savedUDforSQDTool.chkboxOverwriteBlock)
	   set(handles.chkboxOverwriteBlock,'Value', savedUDforSQDTool.chkboxOverwriteBlock);  
    end 
  % update plots      
     if ~isequal(ud.errorArray, savedUDforSQDTool.errorArray)
        sqplot_error(handles.plotErrIter, savedUDforSQDTool.errorArray);
        %set num of iterations
        set(handles.editTotalIter,'String',num2str(length(savedUDforSQDTool.errorArray)));
     end       
     if (~isequal(ud.finalCodebook, savedUDforSQDTool.finalCodebook)) ||...
        (~isequal(ud.finalPartition, savedUDforSQDTool.finalPartition))  
        sqplot_stairs (handles.plotStepFcn, savedUDforSQDTool.finalCodebook, savedUDforSQDTool.finalPartition);
     end
    
  
  %store loaded data 'savedUDforSQDTool' in ud
    ud.finalCodebook  = savedUDforSQDTool.finalCodebook;
    ud.finalPartition = savedUDforSQDTool.finalPartition;
    ud.errorArray     = savedUDforSQDTool.errorArray;
    %store setting of sqdtool GUI : step-1 (pop-ups, checkboxes values)
    ud.popupSQSource        = savedUDforSQDTool.popupSQSource;
    ud.popupInitPTSource    = savedUDforSQDTool.popupInitPTSource;
    ud.popupStopCri         = savedUDforSQDTool.popupStopCri;
    ud.popupSearchMeth      = savedUDforSQDTool.popupSearchMeth;
    ud.popupTieBreakRule    = savedUDforSQDTool.popupTieBreakRule;
    ud.popupDestMdl         = savedUDforSQDTool.popupDestMdl;
    ud.popupBlockType       = savedUDforSQDTool.popupBlockType;  
    ud.chkboxOverwriteBlock = savedUDforSQDTool.chkboxOverwriteBlock;
    
    %for realize model, store the pop-up values corresponding to current plots.
    ud.popupSearchMethForCurrentFig   = savedUDforSQDTool.popupSearchMethForCurrentFig; 
    ud.popupTieBreakRuleForCurrentFig = savedUDforSQDTool.popupTieBreakRuleForCurrentFig;
    
    %store setting of sqexport GUI : no way to directly access that(save from ud)
    ud.exportTOpopup   = savedUDforSQDTool.exportTOpopup;
    ud.outputVarName   = savedUDforSQDTool.outputVarName;
    ud.exportOverwrite = savedUDforSQDTool.exportOverwrite;
    
    %set overwrite flag to 1 (since opening sqdtool is not allowed, so opened session can
    %always be overwritten
    ud.SaveOverwriteFlag=1;
    ud.FileName = file;
  set(hFig,'UserData',ud);
	% set name (title) 
	FigTitle = strcat(['SQ Design Tool - ['], file,']');
	set(hFig,'Name',FigTitle);
	
    
	
	update_successflag  = 1;
    set(ud.hTextStatus,'ForeGroundColor','Black');
    set(ud.hTextStatus,'String', 'Loading session file ...done'); 

catch
    update_successflag = 0;
    set(ud.hTextStatus,'ForeGroundColor','Red');
    set(ud.hTextStatus,'String', 'Error loading: Unable to load the session'); 
    return;
end    

% [EOF]
