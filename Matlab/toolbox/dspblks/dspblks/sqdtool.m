function varargout = sqdtool(varargin)
% SQDTOOL Scalar quantizer Design & Analysis Tool.
%      SQDTOOL is a Graphical User Interface (GUI) that allows 
%      you to design and analyze scalar quantizer using Lloyd algorithm.
%      
%      If the Signal Processing Blockset is installed, SQDTOOL realizes 
%      a model with the scalar quantizer block and the design parameters 
%      (FINAL CODEBOOK, FINAL BOUNDARY POINTS, SEARCHING METHOD, and 
%      TIE-BREAKING RULE). FINAL CODEBOOK, FINAL BOUNDARY POINTS and mean
%      square ERROR at each iteration can also be exported to workspace, 
%      text file or mat file (shortcut key: ctrl + E)
%
% See also: VQDTOOL

% Edit the above text to modify the response to help sqdtool

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2004/04/12 23:05:33 $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ... 
                   'gui_OpeningFcn', @sqdtool_OpeningFcn, ...
                   'gui_OutputFcn',  @sqdtool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --------------------------------------------------------------------
function sqdtool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure (sqdtool.fig)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sqdtool (see VARARGIN)

% Choose default command line output for sqdtool
handles.output = hObject; %

% Update handles structure
guidata(hObject, handles);
movegui(hObject, 'center');

% Set deafult title
set(handles.textStatus,'String','Initializing Scalar Quantizer Design Tool ...');

% Render menus
render_menus(hObject); 

% Render toolbar
set(hObject, 'Toolbar', 'none');
render_toolbar(hObject);

%set user data (ud)
ud=get(hObject,'UserData');
  ud.version = 2.0;% for backward compatibilty
  ud.SQDTOOLidentifier = 1;
 
  ud.FileName='Untitled.sqd';% with path, Name and Extension
  ud.SaveOverwriteFlag=0;% first time - clicking save, calls saveas function
  ud.hTextStatus = handles.textStatus;% for export and realize block status change

  % ud for input to mex function
  ud.TS= 1:10; %randn(10000,1);
  ud.NumLevel=3;
  ud.initCB= [1 2 3]; 
  ud.initPT=[1.5 2.5];
  ud.RelTh  =1e-7;
  ud.MaxIter=double(int32(inf));
  
  %pop-up values
  ud.popupSQSource        = 1;
  ud.popupInitPTSource    = 1;
  ud.popupStopCri         = 1;
  ud.popupSearchMeth      = 2; 
  ud.popupTieBreakRule    = 1;
  ud.popupDestMdl         = 1;
  ud.popupBlockType       = 1;% after version 2
  ud.chkboxOverwriteBlock = 0;   
  
  %for realize block, store the pop-up values corresponding to current plots.
  ud.popupSearchMethForCurrentFig   = ud.popupSearchMeth; 
  ud.popupTieBreakRuleForCurrentFig = ud.popupTieBreakRule;
  
  %change flags
  ud.TSchanged       = 0;
  ud.NumLevelchanged = 0;
  ud.initCBchanged   = 0;
  ud.initPTchanged   = 0;  
  ud.RelThchanged    = 0;
  ud.MaxIterchanged  = 0;
  
  ud.SQSourcechanged     = 0;
  ud.InitPTSourcechanged = 0;
  ud.StopCrichanged      = 0;
  ud.SearchMethchanged   = 0;
  ud.TieBreakRulechanged = 0; 
  
  % ud for error flag (to check if edit box entries are good)
  ud.errFlag_editTS       = 0;
  ud.errFlag_editNumLevel = 0;
  ud.errFlag_editInitCB   = 0;
  ud.errFlag_editInitPT   = 0;
  ud.errFlag_editRelTh    = 0;
  ud.errFlag_editMaxIter  = 0;
  
  % ud for storing outputs for 'Export'
  ud.finalCodebook= [-2.4520   -1.6422   -1.1864   -0.8196   -0.4923   -0.1728    0.0936    0.2977    0.4954    0.6928    0.9485 ...
                      1.2114    1.5586    1.9516    2.5323];
  ud.finalPartition=[ -2.0471   -1.4143   -1.0030   -0.6559   -0.3325   -0.0396    0.1957    0.3966    0.5941    0.8206 ...
                       1.0799    1.3850    1.7551    2.2420];
  ud.errorArray=[0.6238    0.1781    0.1129    0.0860    0.0704    0.0582    0.0502    0.0449    0.0413 ...
                 0.0385    0.0362    0.0338    0.0317    0.0304    0.0293    0.0283    0.0265    0.0241 ...
                 0.0224    0.0212    0.0204    0.0196    0.0186    0.0176    0.0171    0.0165    0.0158 ...
                 0.0153    0.0150    0.0148    0.0146    0.0145    0.0143    0.0142    0.0142    0.0141 ...
                 0.0140    0.0139    0.0138    0.0137    0.0137    0.0136    0.0134    0.0132    0.0130 ...
                 0.0128    0.0125    0.0123    0.0122    0.0119    0.0118    0.0118    0.0118    0.0117 ...
                 0.0117    0.0116    0.0116    0.0116    0.0116    0.0116    0.0115    0.0115    0.0115 ...
                 0.0115    0.0115    0.0115    0.0115    0.0115    0.0115    0.0115    0.0115    0.0115 ...
                 0.0115    0.0115    0.0115];%size=1x75
  
 % To save export window's values
  ud.exportTOpopup   = 1;%1/2/3
  ud.outputVarName   = {'finalCB','finalBP','Err'};
  ud.exportOverwrite = 0;%0=unchecked
  
set(hObject,'UserData',ud);  

if strcmp(get(hObject,'Visible'),'off')    
   % set Default enable/disable
   setenableprop([handles.textInitCB handles.editInitCB], 'off');
   setenableprop([handles.textInitPTSource handles.popupInitPTSource], 'off');
   setenableprop([handles.textInitPT handles.editInitPT], 'off');
   setenableprop([handles.textMaxIter handles.editMaxIter], 'off');
   setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'off');
   set(handles.popupSearchMeth,'Value',2);
	
   % set color only for axes
   default_grey_color = get(hObject,'Color');
   
   % set font size
   hfig1=handles.plotErrIter;  
   hfig2=handles.plotStepFcn;  

   if ~ispc,
      hall = convert2vector(handles);
      set(hall(isprop(hall, 'fontsize')), 'fontsize', 10);
      hplots = [hfig1 hfig2];
      set(hplots(isprop(hplots, 'fontsize')), 'fontsize', 10);
   end
   
   %set tooltip string
   tooltipStrPushbutnRealMdl = sprintf('Generate model with the data\ncorresponding to the current figures');
   set(handles.pushbutnRealzMdl,'TooltipString',tooltipStrPushbutnRealMdl);
   tooltipStrPushbutnExport  = sprintf('Export data corresponding\nto the current figures');
   set(handles.pushbutnExport,'TooltipString',tooltipStrPushbutnExport);
   tooltipStrPushbutnPlot    = sprintf('Design the scalar quantizer\nand update the figures');
   set(handles.pushbutnPlotFig,'TooltipString',tooltipStrPushbutnPlot);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%% Plot error%%%%%%%%%%%%%%%%%%%%
   axes(hfig1);
   e=ud.errorArray;
  
   h_line=plot(e);
   xlabel('Number of Iterations');
   ylabel('Mean Square Error');
   set(h_line,'ButtonDownFcn',@sqsetdatamarkers);% always call after setting axes, xlabel and ylabel, and plot command
   grid on;
   %%%%%%%%%%%%%%%%%% Plot step function %%%%%%%%%%%%%%%%%%%
   axes(hfig2);
   p_new =[-3.3128   -2.6800   ud.finalPartition    2.2420    2.7289    3.2157];
   c_new =[-2.4520   ud.finalCodebook    2.5323    2.5323    2.5323];
   c_LowLimit =  -3.2619;
   c_UpLimit  =   3.1131;
   p_LowLimit =  -3.3128;
   p_UpLimit  =   3.2157;
   h_line=stairs(p_new, c_new);
   set(hfig2,'YLim',[c_LowLimit c_UpLimit]);
   set(hfig2,'XLim',[p_LowLimit p_UpLimit]);
  
   xlabel('Final Boundary Points (theoretical bounds are -inf & +inf)');
   ylabel('Final Codewords');
   set(h_line,'ButtonDownFcn',@sqsetdatamarkers);% always call after setting axes, xlabel and ylabel, and plot command
   grid on;
   set(handles.textStatus,'String','Ready');
end

% --------------------------------------------------------------------
function render_menus(fig)

% Render the "File" menu
%hmenus.hfile = render_sptfilemenu(fig);
hmenus.hfile = render_sqfilemenu(fig, 1);
% Render the "Edit" menu
hmenus.hedit = render_spteditmenu(fig);
% Render the "Insert" menu
hmenus.hinsert = render_sptinsertmenu(fig,3);
% Render the "Tools" menu
hmenus.htools = render_spttoolsmenu(fig,4);
% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(fig,5);
% Render the "Help" menu
hmenus.hhelp = render_sqhelpmenu(fig, 6);


%-------------------------------------------------------------------
function render_toolbar(fig)

htoolbar.htoolbar = uitoolbar('Parent',fig);

% Render the print buttons (New, open, save, Print, Prinpreview)
htoolbar.hprintbtns = render_sqprintbtns(htoolbar.htoolbar, fig);

% Render the annotation buttons (Edit Plot, Insert Text,Insert Arrow, Insert Line)
htoolbar.hscribebtns = render_sptscribebtns(htoolbar.htoolbar);

% Render the zoom buttons (Zoom In, Zoom Out)
htoolbar.hzoombtns = render_zoombtns(fig);

%-------------------------------------------------------------------
function varargout = sqdtool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function pushbutnPlotFig_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnPlotFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  localStartEndProcessing (handles,'off',['Pre-processing ...'], 'Arrow');

% The following function checks if the ud has changed (it doesn't evaluate
% edit box entries). So it doesn't catch the changes made in workspace.
  need_newQuantizer_before = sqDataChanged(handles);

% need to verify user-defined initPT with respect to user-defined initCB
% If the user gives valid initPT (the callback validates it against iniCB)
% Now if the user changes initCB (its callback doesn't validate it
% against initPT), no way to chatch the error from initCB callback. 
% So check it here
  sqCallAllCallbacks(handles); %updates ud, so catches changes made in workspace

% If there is no changes in workspace data, then the above call sets all changes to zero
% so for no workspace changes  need_newQuantizer_after = 0 always
  need_newQuantizer_after = sqDataChanged(handles);

% check if any of FINAL edit box entry is invalid (including workspace changes)
  [errorStatus, errorString] = sqgeterrorstatusandstring(handles);
  

 if (errorStatus)
     errordlg(errorString);
     localStartEndProcessing (handles,'on','Ready', 'Arrow');
     return
 else
      % get autogenerated initCB (with numLevel), autogenerated initPT, RelTh, MaxIter
      % for user defined case, do nothing
      sqResetChangeFlags(handles);% this function resets ud's change flags to zero
      AutoGenerateInitCB  = (get(handles.popupSQSource,'Value')==1);
      AutoGenerateInitPT  = (~AutoGenerateInitCB)&&(get(handles.popupInitPTSource,'Value')==1);

      sqcalculateandsetundefined_ud(handles);% this function updates the user data
      hfig=handles.sqdtool;
      ud=get(hfig,'UserData');
      if (~(need_newQuantizer_before||need_newQuantizer_after))
          ButtonName=questdlg(['The input parameters for the scalar quantizer have not been updated. Do you want to design it again?']);
          if ~strcmpi(ButtonName,'Yes')
            localStartEndProcessing (handles,'on','Ready', 'Arrow');
            return
          end  
      end
      localStartEndProcessing (handles,'off','Processing ...', 'Watch');
     % call mex file
     finalCB=[]; 
     finalPT=[];
     ErrArray=[];
     %ud.popupSearchMeth, ud.popupTieBreakRule <-- values 1 or 2
     [finalCB finalPT ErrArray]=dspsqdesignmex(ud.TS, ud.initCB, ud.initPT, ud.RelTh, ud.MaxIter, ud.popupSearchMeth, ud.popupTieBreakRule);
     hMainFig=handles.sqdtool;
     ud2=get(hMainFig,'UserData');
       ud2.finalCodebook  = finalCB;
       ud2.finalPartition = finalPT;
       ud2.errorArray     = ErrArray;
       ud2.popupSearchMethForCurrentFig   = ud.popupSearchMeth; 
       ud2.popupTieBreakRuleForCurrentFig = ud.popupTieBreakRule;
     set(hMainFig,'UserData',ud2);
     
     % update the export dialog, if it exists
     if isappdata(hMainFig,'sqExportDialog')
         hXP = getappdata(hMainFig,'sqExportDialog');
         set(hXP,'Data',{finalCB(:) finalPT(:) ErrArray(:)});
     end
     
     % every time you update plot, you make it dirty.
     sqmake_fig_dirty(hMainFig);
     
     % update Total number of iterations Text
     h_editTotalIter=handles.editTotalIter;
     set(h_editTotalIter,'String',num2str(length(ErrArray)));
    
     %%%%%%%%%%%%%%% PLOT ERROR %%%%%%%%%%%%%%%%%%%%%
     sqplot_error(handles.plotErrIter, ErrArray);    
    
     %%%%%%%%%%%%%%% PLOT STEP FUNCTION %%%%%%%%%%%%%%%%%%%%%
     sqplot_stairs (handles.plotStepFcn, finalCB, finalPT);
     
     localStartEndProcessing (handles,'on','Ready', 'Arrow');
 end
 
% --------------------------------------------------------------------
function need_newQuantizer = sqDataChanged(handles)

 ud=get(handles.sqdtool,'UserData');
  AutoGenerateInitCB  = (get(handles.popupSQSource,'Value')==1);
  AutoGenerateInitPT  = (~AutoGenerateInitCB)&&(get(handles.popupInitPTSource,'Value')==1);
  StopCriteriaRelTh   = (get(handles.popupStopCri,'Value')==1);
  StopCriteriaMaxIter = (get(handles.popupStopCri,'Value')==2);

 need_newQuantizer = (ud.TSchanged                                                  || ...
                     ud.SQSourcechanged                                             || ...
                     (AutoGenerateInitCB)* ud.NumLevelchanged                       || ...
                     (~AutoGenerateInitCB)* ud.initCBchanged                        || ...
                     (~AutoGenerateInitCB)* ud.InitPTSourcechanged                  || ...
                     (~AutoGenerateInitCB && ~AutoGenerateInitPT)* ud.initPTchanged || ... 
                     ud.StopCrichanged                                              || ...
                     (~StopCriteriaMaxIter)*  ud.RelThchanged                       || ...
                     (~StopCriteriaRelTh)*  ud.MaxIterchanged                       || ...
                     ud.TieBreakRulechanged                                         || ...
                     ud.SearchMethchanged                                           ||...
                     (ud.popupSearchMethForCurrentFig   ~= ud.popupSearchMeth )     ||...
                     (ud.popupTieBreakRuleForCurrentFig ~= ud.popupTieBreakRule)     );

% --------------------------------------------------------------------
function sqResetChangeFlags(handles)

    hFig = handles.sqdtool;
    ud=get(hFig,'UserData');
		ud.TSchanged           = 0;
		ud.SQSourcechanged     = 0;
		ud.NumLevelchanged     = 0;
		ud.initCBchanged       = 0;
		ud.InitPTSourcechanged = 0;
		ud.initPTchanged       = 0;
		ud.StopCrichanged      = 0;
		ud.RelThchanged        = 0;
		ud.MaxIterchanged      = 0;
		ud.TieBreakRulechanged = 0;
		ud.SearchMethchanged   = 0; 
	set(hFig,'UserData',ud);               

% --------------------------------------------------------------------
function localStartEndProcessing (handles, EnableState, StatusText, MouserPointer)

 %EnableState = 'on' or 'off'
 %StatusText = 'Ready' or 'Processing ...' 
 %MouserPointer = 'Arror' or 'Watch'
 set(handles.pushbutnPlotFig,'Enable',EnableState);% disbale the pushbutnPlotFig
 set(handles.textStatus,'ForeGroundColor','Black');
 set(handles.textStatus, 'String',StatusText); %change the status text
 setptr(handles.sqdtool, MouserPointer); % set mouse pointer to hourglass

% --------------------------------------------------------------------
function flag = TSminmaxSame(TSval)
  size_val = size(TSval);
  TSisMatrix = (size_val(1)>1 && size_val(2)>1);
  if (TSisMatrix)
      minTS = min(min(TSval));
      maxTS = max(max(TSval));
  else
      minTS = min(TSval);
      maxTS = max(TSval);
  end
  flag = (minTS == maxTS);
 
% --------------------------------------------------------------------
function editTS_Callback(hObject, eventdata, handles)

% hObject    handle to editTS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.sqdtool;
if (isempty(eventdata)), 
    sqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end% make fig dirty
ud=get(hfig,'UserData');

[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr), 
    val=double(val);
    size_val = size(val);
    width_val = size_val(1)*size_val(2);
    if ~isreal(val)
        if (isempty(eventdata)), errordlg('The TRAINING SET must be non-complex.'); end
        ud.errFlag_editTS = 1;
    elseif width_val<2,
        if (isempty(eventdata)), errordlg('The TRAINING SET must have length greater than one.'); end
        ud.errFlag_editTS = 1;
    elseif TSminmaxSame(val),
        if (isempty(eventdata)), errordlg('The TRAINING SET must have at least two unique elements.'); end
        ud.errFlag_editTS = 1;        
    else        
       %set changeFlag only if TS is valid and different from the previous entry
       ud.TSchanged = 0;
       if ~isequal(ud.TS,val)     
           ud.TSchanged = 1; 
       end
       % Update userdata
       ud.errFlag_editTS = 0; 
       ud.TS = val;% save edit box entry in ud
    end
else
    ud.errFlag_editTS = 1;
    errStr = strcat(errStr,' (Error from TRAINING SET edit box.)');
    if (isempty(eventdata)), errordlg(errStr); end
end
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function popupSQSource_Callback(hObject, eventdata, handles)
% hObject    handle to popupSQSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');  
if (val==1)%% auto-generate initCB
	setenableprop([handles.textNumLevel   handles.editNumLevel],    'on');
    editNumLevel_Callback(handles.editNumLevel, eventdata, handles);% update ud.NumLevel, makes fig dirty
    setenableprop([handles.textInitCB     handles.editInitCB],      'off');
	setenableprop([handles.textInitPTSource handles.popupInitPTSource], 'off');
	setenableprop([handles.textInitPT     handles.editInitPT],      'off');
else%% user-defined initCB
	setenableprop([handles.textNumLevel   handles.editNumLevel],    'off');
	setenableprop([handles.textInitCB     handles.editInitCB],      'on');
    editInitCB_Callback(handles.editInitCB, eventdata, handles);% update ud.initCB, makes fig dirty
    setenableprop([handles.textInitPTSource handles.popupInitPTSource], 'on');
    popupInitPTSource_Callback(handles.popupInitPTSource, eventdata, handles);% update ud.popupInitPTSource
end   

hfig=handles.sqdtool;
ud=get(hfig,'UserData');

ud.SQSourcechanged = 0;
if ud.popupSQSource ~= val
     ud.SQSourcechanged = 1;
end

ud.popupSQSource = val;
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function editNumLevel_Callback(hObject, eventdata, handles)
% hObject    handle to editNumLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.sqdtool;
if (isempty(eventdata)), 
    sqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end% make fig dirty
ud=get(hfig,'UserData'); 

[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr),
    val=double(val);
    if ~isreal(val)   
        if (isempty(eventdata)), errordlg('The NUMBER OF LEVELS must be non-complex.'); end
        ud.errFlag_editNumLevel = 1;
    elseif (length(val)>1  || val < 2 || (val-floor(val)~=0)),
        if (isempty(eventdata)), errordlg('The NUMBER OF LEVELS must be a positive scalar integer (greater than 1).'); end
        ud.errFlag_editNumLevel = 1;
    else
        ud.NumLevelchanged = 0;
        %set changeFlag only if NumLevel is valid and different from the previous entry
        if ud.NumLevel~= val
            ud.NumLevelchanged = 1; 
        end
        ud.errFlag_editNumLevel = 0;
        ud.NumLevel = val;
    end 
else
    errStr = strcat(errStr,' (Error from NUMBER OF LEVELS edit box.)');
    if (isempty(eventdata)), errordlg(errStr); end
    ud.errFlag_editNumLevel = 1;
end
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function editInitCB_Callback(hObject, eventdata, handles)
% hObject    handle to editInitCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.sqdtool;
if (isempty(eventdata)), 
    sqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end% make fig dirty
ud=get(hfig,'UserData');
[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr),
    val=double(val);
    [m n] = size(val);
    isCBmatrix = (m>1 && n>1);
    if ~isreal(val)
        if (isempty(eventdata)), errordlg('The INITIAL CODEBOOK must be non-complex.'); end
        ud.errFlag_editInitCB = 1;   
    elseif  isCBmatrix
        if (isempty(eventdata)), errordlg('The INITIAL CODEBOOK must be a vector.'); end
        ud.errFlag_editInitCB = 1;
    elseif length(val)<2,
        if (isempty(eventdata)), errordlg('The INITIAL CODEBOOK set must have length greater than one.'); end
        ud.errFlag_editInitCB = 1;
    else
       %set changeFlag only if initCB is valid and different from the previous entry
       val=sort(val);% get SORTED initCB
       ud.initCBchanged = 0;
       if ~isequal(ud.initCB, val)
           ud.initCBchanged = 1; 
       end
       % Update userdata
       ud.initCB = val;%always store sorted initCB
       ud.errFlag_editInitCB = 0;
    end    
else
    if (isempty(eventdata)), errordlg([errStr,' (Error from INITIAL CODEBOOK edit box.)']); end
    ud.errFlag_editInitCB = 1;
end
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function editInitPT_Callback(hObject, eventdata, handles)
% hObject    handle to editInitPT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.sqdtool;
if (isempty(eventdata)), 
    sqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end% make fig dirty
ud=get(hfig,'UserData');

[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr),
    val=double(val);
    [m n] = size(val);
    isPTmatrix = (m>1 && n>1);
    if ~isreal(val)
        if (isempty(eventdata)), errordlg('The INITIAL BOUNDARY POINTS must be non-complex.'); end
        ud.errFlag_editInitPT = 1;    
    elseif  isPTmatrix
        if (isempty(eventdata)), errordlg('The INITIAL BOUNDARY POINTS must be a vector.'); end
        ud.errFlag_editInitPT = 1;
    elseif (length(val)~= (length(ud.initCB)-1)),
        if (isempty(eventdata)), errordlg('The INITIAL BOUNDARY POINTS vector length must be one less than the INITIAL CODEBOOK length.'); end
        ud.errFlag_editInitPT = 1;
    else
       if (ud.errFlag_editInitCB)
           if (isempty(eventdata)), errordlg('Invalid INITIAL CODEBOOK'); end
       else           
           errFlagRegularSQ = InitCBandInitPTforRegularSQ(handles.editInitCB, handles.editInitPT);
           % this requires that initCB, initPT must be sorted and interleaved
            if (errFlagRegularSQ)%InitCBandInitPTforRegularSQ(h_editInitCB, h_initPT)
                str1 = 'If INITIAL BOUNDARY POINTS = [p(1) p(2) p(3) ... p(N-1)] and INITIAL CODEBOOK = [c(1) c(2) c(3) ... C(N)] ';
                str2 = ' then for a regular quantizer c(1) < p(1) < c(2) < p(2) ...p(N-2) < c(N-1) < p(N-1) < c(N).';
                if (isempty(eventdata)), errordlg(strcat(str1,str2)); end
                ud.errFlag_editInitPT = 1;
            else
                %set changeFlag only if initCB is valid and different from the previous entry
                ud.initPTchanged = 0;
                if ~isequal(ud.initPT, val)
                    ud.initPTchanged = 1; 
                end
                % Update userdata 
                ud.initPT = val;%sortedVal;        
                ud.errFlag_editInitPT = 0;
            end
        end            
    end
else
    errStr = strcat(errStr,' (Error from INITIAL BOUNDARY POINTS edit box.)');
    if (isempty(eventdata)), errordlg(errStr); end 
    ud.errFlag_editInitPT = 1;
end
set(hfig,'UserData',ud);


% --------------------------------------------------------------------
function popupInitPTSource_Callback(hObject, eventdata, handles)
% hObject    handle to popupInitPTSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');
hfig=handles.sqdtool;
if (val==1) %% auto-generate initPT
	setenableprop([handles.textInitPT   handles.editInitPT],    'off');
    sqmake_fig_dirty(hfig); 
else %%user-defined initPT
	setenableprop([handles.textInitPT   handles.editInitPT],    'on');
    editInitPT_Callback(handles.editInitPT, 1, handles);% make_fig_dirty
end   

ud=get(hfig,'UserData');

ud.InitPTSourcechanged = 0;
if ud.popupInitPTSource ~= val
     ud.InitPTSourcechanged = 1;
end

ud.popupInitPTSource = val;    
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function popupStopCri_Callback(hObject, eventdata, handles)
% hObject    handle to popupStopCri (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');
if (val==1)%% stop-criteria: Threshold
	setenableprop([handles.textMaxIter   handles.editMaxIter],    'off');
    setenableprop([handles.textRelTh     handles.editRelTh],    'on');
    editRelTh_Callback(handles.editRelTh, eventdata, handles);% update ud.MaxIter, makes fig dirty  
elseif (val==2)%% stop-criteria: MaxIter 
	setenableprop([handles.textRelTh     handles.editRelTh],    'off');
    setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
    editMaxIter_Callback(handles.editMaxIter, eventdata, handles);% update ud.MaxIter, makes fig dirty      
else%% stop-criteria: Threshold || MaxIter 
	setenableprop([handles.textRelTh     handles.editRelTh],    'on');
    editRelTh_Callback(handles.editRelTh, eventdata, handles);% update ud.MaxIter, makes fig dirty 
    setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
    editMaxIter_Callback(handles.editMaxIter, eventdata, handles);% update ud.MaxIter, makes fig dirty  
end   

hfig=handles.sqdtool;
ud=get(hfig,'UserData');

ud.StopCrichanged = 0;
if ud.popupStopCri ~= val
     ud.StopCrichanged = 1;
end

ud.popupStopCri = val;    
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function editRelTh_Callback(hObject, eventdata, handles)
% hObject    handle to editRelTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.sqdtool;
if (isempty(eventdata)), 
    sqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end% make fig dirty
ud=get(hfig,'UserData');

[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr), 
    val=double(val);
    if ~isreal(val)
        if (isempty(eventdata)), errordlg('The RELATIVE THRESHOLD must be non-complex.'); end
        ud.errFlag_editRelTh = 1;
    elseif (length(val)>1 || val>=1 || val<0),% Valid values: 0 <= RelTh < 1
        if (isempty(eventdata)), errordlg('The RELATIVE THRESHOLD must be a scalar - greater than or equal to 0 and less than 1.'); end
        ud.errFlag_editRelTh = 1;    
    else
        ud.RelThchanged = 0;
        %set changeFlag only if RelTh is valid and different from the previous entry
        if ud.RelTh~= val
            ud.RelThchanged = 1; 
        end
		% Update userdata
        ud.RelTh = val;
        ud.errFlag_editRelTh = 0;
    end 
else
    errStr = strcat(errStr,' (Error from RELATIVE THRESHOLD edit box.)');
    if (isempty(eventdata)), errordlg(errStr); end
    ud.errFlag_editRelTh = 1;
end
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function editMaxIter_Callback(hObject, eventdata, handles)
% hObject    handle to editMaxIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.sqdtool;
if (isempty(eventdata)), 
    sqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end;% make fig dirty
ud=get(hfig,'UserData'); 

[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr),    
    val=double(val);
    if ~isreal(val)
        if (isempty(eventdata)), errordlg('The MAXIMUM ITERATION must be non-complex.'); end
        ud.errFlag_editMaxIter = 1;
    elseif (length(val)>1  || val <=1 || (val-floor(val)~=0)), 
        if (isempty(eventdata)), errordlg('The MAXIMUM ITERATION must be a positive scalar integer greater than 1.'); end
        ud.errFlag_editMaxIter = 1;    
    else
        ud.MaxIterchanged = 0;
        %set changeFlag only if RelTh is valid and different from the previous entry
        if ud.MaxIter~= val
            ud.MaxIterchanged = 1; 
        end
		% Update userdata
	    ud.MaxIter = val;
	    ud.errFlag_editMaxIter = 0; 
    end
else
    errStr = strcat(errStr,' (Error from MAXIMUM ITERATION edit box.)');
    if (isempty(eventdata)), errordlg(errStr); end
    ud.errFlag_editMaxIter = 1;
end
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function popupSearchMeth_Callback(hObject, eventdata, handles)
% hObject    handle to popupSearchMeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');

hfig=handles.sqdtool;
sqmake_fig_dirty(hfig);
ud=get(hfig,'UserData');

ud.SearchMethchanged = 0;
if ud.popupTieBreakRule ~= val
     ud.SearchMethchanged = 1;
end

ud.popupSearchMeth = val;    
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function popupTieBreakRule_Callback(hObject, eventdata, handles)
% hObject    handle to popupTieBreakRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');

hfig=handles.sqdtool;
sqmake_fig_dirty(hfig); 
ud=get(hfig,'UserData');

ud.TieBreakRulechanged = 0;
if ud.popupTieBreakRule ~= val
     ud.TieBreakRulechanged = 1;
end

ud.popupTieBreakRule = val;    
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function pushbutnRealzMdl_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnRealzMdl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  hfig=handles.sqdtool;
  ud=get(hfig,'UserData');
  UD.finalCodebook    = ud.finalCodebook;
  UD.finalPartition   = ud.finalPartition;
  UD.errorArray       = ud.errorArray;
  UD.destinationMdl   = get(handles.popupDestMdl,'Value');% 1=current, 2=new
  UD.SearchMethod     = ud.popupSearchMethForCurrentFig; 
  UD.TieBreakingRule  = ud.popupTieBreakRuleForCurrentFig;
  UD.system           = '';
  UD.overwriteFlag    = get(handles.chkboxOverwriteBlock, 'Value');% 0/1 
  UD.hTextStatus      = ud.hTextStatus;

  if (ud.version==1.0)% no pop-up to choose encoder or decoder; so set it to both
      UD.blockName        = get(handles.editBlockName, 'String');
      UD.blockType        = 3;% 1=encoder, 2=decoder, 3=both  
      if (UD.blockType ~=2)%encoder(1) OR both(3)
          UD.blockName  = [UD.blockName '_encoder'];
          UD.whichBlock = 1; %encoder
          sqrealizemdl(UD);% this sets status to ready
      end      
      if (UD.blockType~=1)%decoder(2) OR both(3)
          if (UD.blockType==3) UD.destinationMdl=1; end %1=current
          UD.blockName  = [UD.blockName '_decoder'];
          UD.whichBlock = 2; %decoder
          sqrealizemdl(UD);% this sets status to ready
      end
  else % ud.version==2.0    
      UD.blockType        = get(handles.popupBlockType,'Value');% 1=encoder, 2=decoder, 3=both  
      if (UD.blockType ~=2)%encoder(1) OR both(3)
          UD.blockName  = get(handles.editEncBlkName, 'String');
          UD.whichBlock = 1; %encoder
          sqrealizemdl(UD);% this sets status to ready
      end      
      if (UD.blockType~=1)%decoder(2) OR both(3)
          if (UD.blockType==3) UD.destinationMdl=1; end %1=current
          UD.blockName  = get(handles.editDecBlkName, 'String');
          UD.whichBlock = 2; %decoder
          sqrealizemdl(UD);% this sets status to ready
      end
  end    
  
% --------------------------------------------------------------------
function errFlagRegularSQ = InitCBandInitPTforRegularSQ(h_editInitCB, h_editInitPT)
 initCB = evaluatevars(get(h_editInitCB, 'String'));
 initPT = evaluatevars(get(h_editInitPT, 'String'));
 errFlagRegularSQ = 0;
 for i= 1:length(initCB)-1,
  if initCB(i)>=initPT(i) || ...
     initPT(i)>= initCB(i+1), 
      %%'If INITIAL BOUNDARY POINTS = [p(1) p(2) p(3) ... p(N-1)] and INITIAL CODEBOOK = [c(1) c(2) c(3) ... C(N)] ';
      %%' then for a regular quantizer c(1) < p(1) < c(2) < p(2) ...p(N-2) < c(N-1) < p(N-1) < c(N).';
      errFlagRegularSQ  = 1; 
      break;
  end
end

% --------------------------------------------------------------------
function popupDestMdl_Callback(hObject, eventdata, handles)
% hObject    handle to popupDestMdl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');  
if (val==1)%% auto-generate initCB
	setenableprop(handles.chkboxOverwriteBlock,  'on');
else%% user-defined initCB
	setenableprop(handles.chkboxOverwriteBlock,  'off');
end   
hfig=handles.sqdtool;
sqmake_fig_dirty(hfig);
ud=get(hfig,'UserData');
ud.popupDestMdl = val;
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function editBlockName_Callback(hObject, eventdata, handles)
% hObject    handle to editBlockName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% this function is for version number: 1 (not used in version number 2)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
hfig=handles.sqdtool;
sqmake_fig_dirty(hfig); 

% --------------------------------------------------------------------
function chkboxOverwriteBlock_Callback(hObject, eventdata, handles)
% hObject    handle to chkboxOverwriteBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
hfig=handles.sqdtool;
sqmake_fig_dirty(hfig);
ud=get(hfig,'UserData');
ud.chkboxOverwriteBlock = get(hObject,'Value');
set(hfig,'UserData',ud);

%--------------------------------------------------------------------------
function pushbutnExport_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sqexport(handles.sqdtool);% This sets status to ready

%--------------------------------------------------------------------------
function sqCallAllCallbacks(handles)
  % User Data are not updated here (no SET)
  AutoGenerateInitCB  = (get(handles.popupSQSource,'Value')==1);
  AutoGenerateInitPT  = (~AutoGenerateInitCB)&&(get(handles.popupInitPTSource,'Value')==1);
  StopCriteriaRelTh   = (get(handles.popupStopCri,'Value')==1);
  StopCriteriaMaxIter = (get(handles.popupStopCri,'Value')==2);
  
  editTS_Callback(handles.editTS, 1, handles);
  if (AutoGenerateInitCB)
      editNumLevel_Callback(handles.editNumLevel, 1, handles);
  else
      editInitCB_Callback(handles.editInitCB, 1, handles);
      if (~AutoGenerateInitPT)   
          editInitPT_Callback(handles.editInitPT, 1, handles);
      end
  end
  if (~StopCriteriaMaxIter)
      editRelTh_Callback(handles.editRelTh, 1, handles);
  end
  if (~StopCriteriaRelTh)
      editMaxIter_Callback(handles.editMaxIter, 1, handles);
  end   
  
% --------------------------------------------------------------------
function updateWarningError(hObject, eventdata, handles,str)
set(handles.textStatus,'ForegroundColor','Red','String',str)

% --------------------------------------------------------------------
function updateStatus(hObject, eventdata, handles,str)
set(handles.textStatus,'ForegroundColor','Black','String',str)  

% --------------------------------------------------------------------
function sqdtool_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to sqdtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isappdata(hObject,'sqExportDialog')
    hXP = getappdata(hObject,'sqExportDialog');
    close(hXP);
end

sqclose(hObject);

% --------------------------------------------------------------------------
function editDecBlkName_Callback(hObject, eventdata, handles)
% hObject    handle to editDecBlkName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% for version: 2

set(handles.textStatus,'ForeGroundColor','Black');  
set(handles.textStatus,'String','Ready');
hfig=handles.sqdtool;
sqmake_fig_dirty(hfig); 

% --------------------------------------------------------------------------
function editEncBlkName_Callback(hObject, eventdata, handles)
% hObject    handle to editEncBlkName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% for version: 2

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
hfig=handles.sqdtool;
sqmake_fig_dirty(hfig); 

% --------------------------------------------------------------------------
function popupBlockType_Callback(hObject, eventdata, handles)
% hObject    handle to popupBlockType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% for version: 2

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');  
if (val==1)%% Encoder
    setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'on');
	setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'off');
elseif (val==2)%% Decoder
	setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'off');
	setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'on');
else%% Both
	setenableprop([handles.textEncBlkName   handles.editEncBlkName],    'on');
	setenableprop([handles.textDecBlkName   handles.editDecBlkName],    'on');   
end     
hfig=handles.sqdtool;
sqmake_fig_dirty(hfig);
ud=get(hfig,'UserData');
ud.popupBlockType = val;  
set(hfig,'UserData',ud);
if nargin>3, return; end

% [EOF] sqdtool.m


