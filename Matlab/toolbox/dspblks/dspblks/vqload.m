function vqload(hFig, file, force)
%LOAD Load a saved session into VQDTool

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:17:59 $

if nargin < 3, force = 'noforce'; end
ud=get(hFig,'UserData');

% Don't load if GUI is dirty.
if strcmpi(force, 'force') | vqsave_if_dirty(hFig,'loading'),
        
    if nargin == 1,
        
        % Change to the directory where the current session lives.
        old_pwd = pwd;
        
        [path,name,ext] = fileparts(ud.FileName);
        if ~isempty(path); cd(path); end
        
        % Load the file.
        [filename,pathname] = uigetfile('*.vqd','Load VQ Design Session');
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
% Do not allow user to open vqdtool from here. Saving as vqdtool is also prohobited
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
if strcmpi(filename_tmp, 'VQDTOOL')
    set(ud.hTextStatus,'ForeGroundColor','Red');
    set(ud.hTextStatus,'String', 'Error loading: File name cannot be vqdtool'); 
    successflag = 0; 
    return
end  
%%%%%%%% 
try
    % Load session file: loads savedUDforVQDTool
     load(file,'-mat');
catch
     set(ud.hTextStatus,'ForeGroundColor','Red');
     set(ud.hTextStatus,'String', 'Error loading: Unable to open the session'); 
     successflag = 0; 
     return
end 

%%%%%%%% 
try
    if (savedUDforVQDTool.VQDTOOLidentifier)
    %%%
    end
catch
    set(ud.hTextStatus,'ForeGroundColor','Red');
    set(ud.hTextStatus,'String', 'Error loading: This is not a valid VQDTOOL session'); 
    successflag = 0; 
    return
end 

% Update the existing figure with the new setting
    update_successflag = update_figure_for_load (savedUDforVQDTool, hFig, file);
    successflag = update_successflag;
    
%--------------------------------------------------------------------------------------
function update_successflag = update_figure_for_load (savedUDforVQDTool, hFig, file)
ud=get(hFig,'UserData');
try 
  %store setting of vqdtool GUI : step-1 (edit box strings)
    handles = guidata(hFig);
    if ~strcmp(get(handles.editTS,'String'),savedUDforVQDTool.TSstring)
       set(handles.editTS,'String', savedUDforVQDTool.TSstring)
    end       
    if ~strcmp(get(handles.editNumLevel,'String'),savedUDforVQDTool.numLevelString)
       set(handles.editNumLevel,'String', savedUDforVQDTool.numLevelString);
    end 
    if ~strcmp(get(handles.editInitCB,'String'),savedUDforVQDTool.initCBString)
       set(handles.editInitCB,'String', savedUDforVQDTool.initCBString);
    end 
    if ~strcmp(get(handles.editWgtFactor,'String'),savedUDforVQDTool.weightString)
       set(handles.editWgtFactor,'String', savedUDforVQDTool.weightString);
    end 
    if ~strcmp(get(handles.editRelTh,'String'),savedUDforVQDTool.RelThString)
       set(handles.editRelTh,'String', savedUDforVQDTool.RelThString);
    end 
    if ~strcmp(get(handles.editMaxIter,'String'),savedUDforVQDTool.maxIterString)
       set(handles.editMaxIter,'String', savedUDforVQDTool.maxIterString);
    end 
    if ~strcmp(get(handles.editEncBlkName,'String'),savedUDforVQDTool.EncBlkNameString)
       set(handles.editEncBlkName,'String', savedUDforVQDTool.EncBlkNameString);
    end 
    if ~strcmp(get(handles.editDecBlkName,'String'),savedUDforVQDTool.DecBlkNameString)
       set(handles.editDecBlkName,'String', savedUDforVQDTool.DecBlkNameString);
    end 

  % make GUI items enable/disable: initCB spec 
     if (ud.popupInitCBSource ~= savedUDforVQDTool.popupInitCBSource)
        set( handles.popupInitCBSource,'Value',savedUDforVQDTool.popupInitCBSource);
		if (savedUDforVQDTool.popupInitCBSource==1)%% auto-generate initCB
			setenableprop([handles.textNumLevel   handles.editNumLevel],    'on');
            setenableprop([handles.textInitCB     handles.editInitCB],      'off');
		else%% user-defined initCB
			setenableprop([handles.textNumLevel   handles.editNumLevel],    'off');
			setenableprop([handles.textInitCB     handles.editInitCB],      'on');
		end   
    end
  % set it independent of the choice for popupInitCBSource
    if (ud.popupDistMeasure ~= savedUDforVQDTool.popupDistMeasure)
        set( handles.popupDistMeasure,'Value',savedUDforVQDTool.popupDistMeasure);
        if (savedUDforVQDTool.popupDistMeasure==1) %% Squared error
		    setenableprop([handles.textWgtFactor   handles.editWgtFactor],  'off');
            setenableprop([handles.textCBupdateMeth   handles.popupCBupdateMeth], 'off');
        else %%Weighted squared error
		    setenableprop([handles.textWgtFactor   handles.editWgtFactor],  'on');
            setenableprop([handles.textCBupdateMeth   handles.popupCBupdateMeth], 'on');
        end 
    end        

  % make GUI items enable/disable: stop-criteria
    if (ud.popupStopCri ~= savedUDforVQDTool.popupStopCri)
        set( handles.popupStopCri,'Value',savedUDforVQDTool.popupStopCri);
		if (savedUDforVQDTool.popupStopCri==1)%% stop-criteria: Threshold
            setenableprop([handles.textRelTh     handles.editRelTh],    'on');
            setenableprop([handles.textMaxIter   handles.editMaxIter],    'off');
		elseif (savedUDforVQDTool.popupStopCri==2)%% stop-criteria: MaxIter 
			setenableprop([handles.textRelTh     handles.editRelTh],    'off');
            setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
		else%% stop-criteria: Threshold || MaxIter 
			setenableprop([handles.textRelTh     handles.editRelTh],    'on');
            setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
		end   
    end
    
  % make GUI items enable/disable: tie-break rule, CB update method, overwriteblock checkbox
    if (ud.popupTieBreakRule ~= savedUDforVQDTool.popupTieBreakRule)
	   set(handles.popupTieBreakRule,'Value', savedUDforVQDTool.popupTieBreakRule);
    end 
    if (ud.popupCBupdateMeth ~= savedUDforVQDTool.popupCBupdateMeth)
	   set(handles.popupCBupdateMeth,'Value', savedUDforVQDTool.popupCBupdateMeth);
    end 
    if (ud.popupDestMdl ~= savedUDforVQDTool.popupDestMdl)
	   set(handles.popupDestMdl,'Value', savedUDforVQDTool.popupDestMdl);
       % set enable/disable property of checkbox
       if (savedUDforVQDTool.popupDestMdl==1)%% current model
	       setenableprop(handles.chkboxOverwriteBlock,  'on');
       else%%  new model
	       setenableprop(handles.chkboxOverwriteBlock,  'off');
       end  
    end 
    if (ud.popupBlockType ~= savedUDforVQDTool.popupBlockType)
	   set(handles.popupBlockType,'Value', savedUDforVQDTool.popupBlockType);
       % set enable/disable property of block name texts and edit boxes
       if (savedUDforVQDTool.popupBlockType==1)%% Encoder
            setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'on');
			setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'off');
	   elseif (savedUDforVQDTool.popupBlockType==2)%% Decoder
			setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'off');
			setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'on');
	   else%% Both
			setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'on');
			setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'on');   
	   end    
       
    end
    % set saved value of check box
    if (ud.chkboxOverwriteBlock ~= savedUDforVQDTool.chkboxOverwriteBlock)
	   set(handles.chkboxOverwriteBlock,'Value', savedUDforVQDTool.chkboxOverwriteBlock);  
    end 
  % update plots      
     if ~isequal(ud.errorArray, savedUDforVQDTool.errorArray)
        vqplot_error(handles.plotErrIter, savedUDforVQDTool.errorArray);
        %set num of iterations
        set(handles.editTotalIter,'String',num2str(length(savedUDforVQDTool.errorArray)));
     end       
     if ~isequal(ud.entropyArray, savedUDforVQDTool.entropyArray)
        vqplot_entropy(handles.plotEntropyIter, savedUDforVQDTool.entropyArray);
        %set num of iterations
        %set(handles.editTotalIter,'String',num2str(length(savedUDforVQDTool.entropyArray)));
     end    
  
  %store loaded data 'savedUDforVQDTool' in ud
    ud.finalCodebook  = savedUDforVQDTool.finalCodebook;
    ud.errorArray     = savedUDforVQDTool.errorArray;
    ud.entropyArray   = savedUDforVQDTool.entropyArray;
    %store setting of vqdtool GUI : step-2 (pop-ups, checkboxes values)
    ud.popupInitCBSource    = savedUDforVQDTool.popupInitCBSource;
    ud.popupDistMeasure     = savedUDforVQDTool.popupDistMeasure;
    ud.popupStopCri         = savedUDforVQDTool.popupStopCri;
    ud.popupTieBreakRule    = savedUDforVQDTool.popupTieBreakRule;
    ud.popupCBupdateMeth    = savedUDforVQDTool.popupCBupdateMeth;
    ud.popupDestMdl         = savedUDforVQDTool.popupDestMdl;
    ud.popupBlockType       = savedUDforVQDTool.popupBlockType; 
    ud.chkboxOverwriteBlock = savedUDforVQDTool.chkboxOverwriteBlock;
    
    %for realize model, store the pop-up values corresponding to current plots.
    ud.popupTieBreakRuleForCurrentFig = savedUDforVQDTool.popupTieBreakRuleForCurrentFig;
    
    %store setting of vqexport GUI : no way to directly access that(save from ud)
    ud.exportTOpopup   = savedUDforVQDTool.exportTOpopup;
    ud.outputVarName   = savedUDforVQDTool.outputVarName;
    ud.exportOverwrite = savedUDforVQDTool.exportOverwrite;
    
    %set overwrite flag to 1 (since opening vqdtool is not allowed, so opened session can
    %always be overwritten
    ud.SaveOverwriteFlag=1;
    ud.FileName = file;
  set(hFig,'UserData',ud);
	% set name (title) 
	FigTitle = strcat(['VQ Design Tool - ['], file,']');
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
