function vqsaveorsaveas(hFig, file,str)
% str = 'save' and 'saveas'
% file = Path, name, ext
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:18:07 $
    
	ud=get(hFig,'UserData');
        %store special tag
        savedUDforVQDTool.version = 1;
        savedUDforVQDTool.VQDTOOLidentifier = 1;
        %store output result
        savedUDforVQDTool.finalCodebook  = ud.finalCodebook;
        savedUDforVQDTool.errorArray     = ud.errorArray;
	    savedUDforVQDTool.entropyArray   = ud.entropyArray;
        %store setting of vqdtool GUI : step-1 (edit box strings)
        handles = guidata(hFig);
        savedUDforVQDTool.TSstring        = get(handles.editTS,'String');        
        savedUDforVQDTool.numLevelString  = get(handles.editNumLevel,'String');
        savedUDforVQDTool.initCBString    = get(handles.editInitCB,'String');
        savedUDforVQDTool.weightString    = get(handles.editWgtFactor,'String');
        savedUDforVQDTool.RelThString     = get(handles.editRelTh,'String');
        savedUDforVQDTool.maxIterString   = get(handles.editMaxIter,'String');
        savedUDforVQDTool.EncBlkNameString = get(handles.editEncBlkName,'String'); 
        savedUDforVQDTool.DecBlkNameString = get(handles.editDecBlkName,'String'); 
        %store setting of vqdtool GUI : step-2 (pop-ups, checkboxes values)
        savedUDforVQDTool.popupInitCBSource   = ud.popupInitCBSource;
        savedUDforVQDTool.popupDistMeasure    = ud.popupDistMeasure;
        savedUDforVQDTool.popupStopCri        = ud.popupStopCri;
        savedUDforVQDTool.popupTieBreakRule   = ud.popupTieBreakRule;
        savedUDforVQDTool.popupCBupdateMeth   = ud.popupCBupdateMeth;
        savedUDforVQDTool.popupDestMdl        = ud.popupDestMdl;                      
        savedUDforVQDTool.popupBlockType      = ud.popupBlockType; 
        savedUDforVQDTool.chkboxOverwriteBlock= ud.chkboxOverwriteBlock;%0,1
        %for realize model, store the pop-up values corresponding to current plots.
        savedUDforVQDTool.popupTieBreakRuleForCurrentFig = ud.popupTieBreakRuleForCurrentFig;
        %store setting of vqexport GUI : no way to directly access that(save from ud)
        savedUDforVQDTool.exportTOpopup   = ud.exportTOpopup ;
        savedUDforVQDTool.outputVarName   = ud.outputVarName ;
        savedUDforVQDTool.exportOverwrite = ud.exportOverwrite ;
        %reset changed flag (do that when you want to load)
        %>>>>>>> Nothing to do for resetting here
        try
            %save this data
            save(file,'savedUDforVQDTool','-mat');
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
        FigTitle = strcat(['VQ Design Tool - ['], file,']');
        set(hFig,'Name',FigTitle);
	

% [EOF]
