function sqsaveorsaveas(hFig, file,str)
% str = 'save' and 'saveas'
% file = Path, name, ext
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/07/10 19:48:06 $
    
	ud=get(hFig,'UserData');
        %store special tag
        savedUDforSQDTool.version = ud.version;
        savedUDforSQDTool.SQDTOOLidentifier = 1;
        %store output result
        savedUDforSQDTool.finalCodebook  = ud.finalCodebook;
        savedUDforSQDTool.finalPartition = ud.finalPartition;
        savedUDforSQDTool.errorArray     = ud.errorArray;
        %store setting of sqdtool GUI : step-1 (edit box strings)
        handles = guidata(hFig);
        savedUDforSQDTool.TSstring        = get(handles.editTS,'String');        
        savedUDforSQDTool.numLevelString  = get(handles.editNumLevel,'String');
        savedUDforSQDTool.initCBString    = get(handles.editInitCB,'String');
        savedUDforSQDTool.initPTString    = get(handles.editInitPT,'String');
        savedUDforSQDTool.RelThString     = get(handles.editRelTh,'String');
        savedUDforSQDTool.maxIterString   = get(handles.editMaxIter,'String');
        if(ud.version == 1)
           savedUDforSQDTool.BlockNameString = get(handles.editBlockName,'String');
        else  
           savedUDforSQDTool.EncBlkNameString = get(handles.editEncBlkName,'String'); 
           savedUDforSQDTool.DecBlkNameString = get(handles.editDecBlkName,'String'); 
        end       
        %store setting of sqdtool GUI : step-1 (pop-ups, checkboxes values)
        savedUDforSQDTool.popupSQSource       = ud.popupSQSource;
        savedUDforSQDTool.popupInitPTSource   = ud.popupInitPTSource;
        savedUDforSQDTool.popupStopCri        = ud.popupStopCri;
        savedUDforSQDTool.popupSearchMeth     = ud.popupSearchMeth;
        savedUDforSQDTool.popupTieBreakRule   = ud.popupTieBreakRule;
        savedUDforSQDTool.popupDestMdl        = ud.popupDestMdl;  
        if(ud.version ~= 1)
           savedUDforSQDTool.popupBlockType      = ud.popupBlockType;            
        end   
        savedUDforSQDTool.chkboxOverwriteBlock= ud.chkboxOverwriteBlock;%0,1
        %for realize model, store the pop-up values corresponding to current plots.
        savedUDforSQDTool.popupSearchMethForCurrentFig   = ud.popupSearchMethForCurrentFig;
        savedUDforSQDTool.popupTieBreakRuleForCurrentFig = ud.popupTieBreakRuleForCurrentFig;
        %store setting of sqexport GUI : no way to directly access that(save from ud)
        savedUDforSQDTool.exportTOpopup = ud.exportTOpopup ;
        savedUDforSQDTool.outputVarName = ud.outputVarName ;
        savedUDforSQDTool.exportOverwrite = ud.exportOverwrite ;
        %reset changed flag (do that when you want to load)
        %>>>>>>> Nothing to do for resetting here
        try
            %save this data
            save(file,'savedUDforSQDTool','-mat');
        catch
            errStr = ['An error occurred while saving the session file.  ',...
                'Make sure the file is not Read-only and you have ',...
                'permission to write to that directory.'];
            %set(ud.hTextStatus,'ForeGroundColor','Red');  set(ud.hTextStatus,'String',errStr);
            errordlg(errStr);
            return
        end            
        % update the current figure to the setting (DON'T do this before the above catch)
        ud.SaveOverwriteFlag = 1;
        ud.FileName = file;
        set(hFig,'UserData',ud);
        FigTitle = strcat(['SQ Design Tool - ['], file,']');
        set(hFig,'Name',FigTitle);
	

% [EOF]
