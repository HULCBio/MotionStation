function varargout = vqdtool(varargin)
% VQDTOOL Vector Quantizer Design & Analysis Tool.
%      VQDTOOL is a Graphical User Interface (GUI) that allows you to design
%      a vector quantizer using the Generalized Lloyd algorithm. This GUI 
%      lets you examine, in each design iteration, important attributes of the
%      vector quantizer including the mean square ERROR and the ENTROPY of the
%      training data as it is quantized by the vector quantizer.
% 
%      You can also generate a model containing a Vector Quantizer block with
%      design parameters such as FINAL CODEBOOK and TIE-BREAKING RULE.
% 
%      The FINAL CODEBOOK , mean square ERROR, and ENTROPY at each iteration
%      can be exported to the MATLAB workspace, as a text file, or a MAT-file.
%      (shortcut key: ctrl + E)
%
% See also: SQDTOOL

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/06 15:23:14 $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ... 
                   'gui_OpeningFcn', @vqdtool_OpeningFcn, ...
                   'gui_OutputFcn',  @vqdtool_OutputFcn, ...
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

%%%%%%%%%%INITIALIZATION FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function vqdtool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure (vqdtool.fig)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vqdtool (see VARARGIN)

% Choose default command line output for vqdtool
handles.output = hObject; %

% Update handles structure
guidata(hObject, handles);
movegui(hObject, 'center');

% Set deafult title
set(handles.textStatus,'String','Initializing Vector Quantizer Design Tool ...');

% Render menus
render_menus(hObject); 

% Render toolbar
set(hObject, 'Toolbar', 'none');
render_toolbar(hObject);

%set user data (ud)
ud=get(hObject,'UserData');
  ud.version = 1.0;% for backward compatibilty
  ud.VQDTOOLidentifier = 1;
 
  ud.FileName='Untitled.vqd';% with path, Name and Extension
  ud.SaveOverwriteFlag=0;% first time - clicking save, calls saveas function
  ud.hTextStatus = handles.textStatus;% for export and realize block status change

  % ud for input to mex function
  ud.TS= randn(10,1000);
  ud.NumLevel=16;
  ud.initCB= [1 2 3]; 
  ud.weight=[1];
  ud.RelTh  =1e-7;
  ud.MaxIter=double(int32(inf));
  
  %pop-up values + one check box
  ud.popupInitCBSource    = 1;
  ud.popupDistMeasure     = 1;
  ud.popupStopCri         = 1;
  ud.popupTieBreakRule    = 1;
  ud.popupCBupdateMeth    = 1;
  ud.popupDestMdl         = 1;
  ud.popupBlockType       = 1;
  ud.chkboxOverwriteBlock = 0;   
  
  %for realize block, store the pop-up values corresponding to current plots.
  % this parameters affect the algorithm
  ud.popupTieBreakRuleForCurrentFig = ud.popupTieBreakRule;
  %no need to store popupCBupdateMeth.., as we do not have this parameter in VQ blocks
  
  %change flags - edit boxes (used to find NeedNewQuantizer)
  ud.TSchanged       = 0;
  ud.NumLevelchanged = 0;
  ud.initCBchanged   = 0;
  ud.weightchanged   = 0;  
  ud.RelThchanged    = 0;
  ud.MaxIterchanged  = 0;
  
  %change flags - popup entries (used to find NeedNewQuantizer)
  ud.InitCBSourcechanged = 0;
  ud.DistMeasChanged     = 0;
  ud.StopCrichanged      = 0;
  ud.TieBreakRulechanged = 0; 
  ud.CBupdateMethchanged = 0;
  %ud.DestMdlchanged <-- no need (no affect on Quantizer design)
  
  % ud for error flag (to check if edit box entries are good)
  ud.errFlag_editTS         = 0;
  ud.errFlag_editNumLevel   = 0;
  ud.errFlag_editInitCB     = 0;
  ud.errFlag_editWgtFactor  = 0;
  ud.errFlag_editRelTh      = 0;
  ud.errFlag_editMaxIter    = 0;
  %ud.errFlag_editEncBlkName <-- no need (any name is valid)
  %ud.errFlag_editDecBlkName <-- no need (any name is valid)
  
  % ud for storing outputs for 'Export'
  ud.finalCodebook= [ -0.3099   -1.2028   -0.2297    0.6301   -0.4105    0.1348    1.1269    0.9364   -0.1928   -0.4088   -0.3094   -0.4163    1.0273   -0.7977   -0.1809    0.2411; ...
                       0.5716   -0.0554    1.2064    0.8374   -0.1038   -0.5461   -0.2243   -0.1646    0.0859   -1.2552    0.0350    0.0388   -0.0687    0.0265   -0.3272    0.8280; ...
                       0.2643   -0.6234   -0.2592    0.5437    0.1645    0.2911    0.5703    0.6588   -0.0139    0.6929    0.8469   -0.2375   -1.4045   -0.6533   -0.6947    0.5521; ...
                      -0.1475    0.4473    0.1968    0.1394    1.2163   -0.3868    0.6775   -0.7417   -1.4958   -0.0659   -0.3929    0.3118   -0.1145   -0.6443    0.7745    0.8423; ...
                      -0.6096   -0.8372   -0.2116   -0.5864    0.9871   -1.2317   -0.2521    0.6854   -0.0123   -0.1072    0.8682   -0.1254   -0.0488    0.8114    0.6447   -0.2336; ...
                      -1.2922   -0.4480    0.3546    0.1002    0.2589    0.1937    0.0109    0.9101   -0.2636   -0.2930   -0.2821    0.8964    0.3958    0.6575   -0.5861   -0.4625; ...
                       1.0150   -0.4350    0.4450   -0.5041   -1.0076   -0.7768    0.7414   -0.2524   -0.3044    0.5713    0.8573    0.5142    0.1442   -0.6852    0.4278   -0.4546; ...
                      -0.2743   -0.6242    0.8452   -1.0909   -0.1426    0.6375   -0.3076   -0.0337    0.0722    0.5772   -0.8069   -1.1126   -0.0013    0.6425    0.6966    0.8690; ...
                       0.4547   -0.4685   -0.9962   -0.1182   -0.2294   -0.1351   -0.8096    0.4304   -0.3042   -0.0641   -0.7211    0.8653   -0.1343    0.7620    0.9816    0.3431; ...
                       0.8201   -0.7554    0.6773   -0.4934    0.3730    0.5268    0.9867   -0.0329   -1.0255   -0.3698   -0.1749    0.3979   -0.0200    0.4930   -0.6989   -0.5346];

  ud.errorArray=       [9.1736    6.8916    6.6772    6.5489    6.4801    6.4489    6.4223    6.3972    6.3804 ...
                        6.3678    6.3553    6.3406    6.3322    6.3262    6.3189    6.3081    6.3029    6.3017 ...
                        6.3009    6.2997    6.2988    6.2982    6.2963    6.2923    6.2901    6.2888    6.2866 ...
                        6.2852    6.2845    6.2836    6.2834    6.2830    6.2824    6.2821    6.2819    6.2819];%size=1x36
  ud.entropyArray=    [ 3.5291    3.8459    3.9414    3.9748    3.9827    3.9848    3.9863    3.9866    3.9864 ...
                        3.9866    3.9846    3.9855    3.9867    3.9880    3.9877    3.9903    3.9894    3.9897 ...
                        3.9907    3.9906    3.9899    3.9895    3.9888    3.9895    3.9899    3.9904    3.9913 ...
                        3.9911    3.9912    3.9914    3.9915    3.9917    3.9915    3.9916    3.9916    3.9916];%size=1x36
  
 % To save export window's values
  ud.exportTOpopup   = 1;%1/2/3
  ud.outputVarName   = {'finalCB','Err', 'Entropy'};
  ud.exportOverwrite = 0;%0=unchecked
  
set(hObject,'UserData',ud);  

if strcmp(get(hObject,'Visible'),'off')    
   % set Default enable/disable
   setenableprop([handles.textInitCB         handles.editInitCB],        'off');
   setenableprop([handles.textWgtFactor      handles.editWgtFactor],     'off');
   setenableprop([handles.textMaxIter        handles.editMaxIter],       'off');
   setenableprop([handles.textCBupdateMeth   handles.popupCBupdateMeth], 'off');
   setenableprop([handles.textDecBlkName     handles.editDecBlkName],    'off');
	
   % set color only for axes
   %default_grey_color = get(hObject,'Color');
   %set(handles.axes11,'Color',default_grey_color);
   %set(handles.axes10,'Color',default_grey_color);
   
   % set font size
   hfig1=handles.plotErrIter;  
   hfig2=handles.plotEntropyIter;  

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
   tooltipStrPushbutnPlot    = sprintf('Design the vector quantizer\nand update the figures');
   set(handles.pushbutnPlotFig,'TooltipString',tooltipStrPushbutnPlot);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%% Plot error%%%%%%%%%%%%%%%%%%%%
   axes(hfig1);
   e=ud.errorArray;
  
   h_line=plot(e);
   xlabel('Number of Iterations');
   ylabel('Mean Square Error');
   set(h_line,'ButtonDownFcn',@setdatamarkers);% always call after setting axes, xlabel and ylabel, and plot command
   grid on;
    %%%%%%%%%%%%%%%%%% Plot entropy %%%%%%%%%%%%%%%%%%%
   axes(hfig2);
   en=ud.entropyArray;
  
   h_line=plot(en);
   xlabel('Number of Iterations');
   ylabel('Entropy');
   set(h_line,'ButtonDownFcn',@setdatamarkers);% always call after setting axes, xlabel and ylabel, and plot command
   grid on;

   set(handles.textStatus,'String','Ready');
end

% --------------------------------------------------------------------
function render_menus(fig)

% Render the "File" menu
%hmenus.hfile = render_sptfilemenu(fig);
hmenus.hfile = render_vqfilemenu(fig, 1);
% Render the "Edit" menu
hmenus.hedit = render_spteditmenu(fig);
% Render the "Insert" menu
hmenus.hinsert = render_sptinsertmenu(fig,3);
% Render the "Tools" menu
hmenus.htools = render_spttoolsmenu(fig,4);
% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(fig,5);
% Render the "Help" menu
hmenus.hhelp = render_vqhelpmenu(fig, 6);


%-------------------------------------------------------------------
function render_toolbar(fig)

htoolbar.htoolbar = uitoolbar('Parent',fig);

% Render the print buttons (New, open, save, Print, Prinpreview)
htoolbar.hprintbtns = render_vqprintbtns(htoolbar.htoolbar, fig);

% Render the annotation buttons (Edit Plot, Insert Text,Insert Arrow, Insert Line)
htoolbar.hscribebtns = render_sptscribebtns(htoolbar.htoolbar);

% Render the zoom buttons (Zoom In, Zoom Out)
htoolbar.hzoombtns = render_zoombtns(fig);

%-------------------------------------------------------------------
function varargout = vqdtool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
%%%%%%%%%%%%%%PLOT FIGURE PUSH BUTTON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pushbutnPlotFig_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnPlotFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  localStartEndProcessing (handles,'off',['Pre-processing ...'], 'Arrow');

% The following function checks if the ud has changed (it doesn't revaluate
% edit box entries). So it doesn't catch the changes made in workspace.
  need_newQuantizer_before = vqDataChanged(handles);

% If the user changes variable values (for edit box) in workspace
  vqCallAllCallbacks(handles); %updates ud, so catches changes made in workspace

% If there is no changes in workspace data, then the above call sets all changes to zero
% so for no workspace changes  need_newQuantizer_after = 0 always
  need_newQuantizer_after = vqDataChanged(handles);

% check if any of FINAL edit box entry is invalid (including workspace changes)
  [errorStatus, errorString] = vqgeterrorstatusandstring(handles);
  

 if (errorStatus)
     errordlg(errorString);
     localStartEndProcessing (handles,'on','Ready', 'Arrow');
     return
 else
      % get autogenerated initCB (with numLevel), RelTh, MaxIter
      % for user defined case, do nothing
      vqResetChangeFlags(handles);% this function resets ud's change flags to zero

      vqcalculateandsetundefined_ud(handles);% this function updates the user data
      hfig=handles.vqdtool;
      ud=get(hfig,'UserData');
      if (~(need_newQuantizer_before||need_newQuantizer_after))
          ButtonName=questdlg(['The input parameters for the vector quantizer have not been updated. Do you want to design it again?']);
          if ~strcmpi(ButtonName,'Yes')
            localStartEndProcessing (handles,'on','Ready', 'Arrow');
            return
          end  
      end
      localStartEndProcessing (handles,'off','Processing ...', 'Watch');
     % call mex file
     finalCB=[]; 
     ErrArray=[];
     EntropyArray =[];
     %ud.popupTieBreakRule <-- values 1 or 2
     % if NumLevel given, get initial codebook
     NeedWeight = double(get(handles.popupDistMeasure,'Value')==2);
     if (NeedWeight)
       [finalCB ErrArray EntropyArray]=dspvqdesignmex(ud.TS, ud.initCB, NeedWeight, ud.popupCBupdateMeth, ud.RelTh, ud.MaxIter, ud.popupTieBreakRule,ud.weight);
     else
       [finalCB ErrArray EntropyArray]=dspvqdesignmex(ud.TS, ud.initCB, NeedWeight, ud.popupCBupdateMeth, ud.RelTh, ud.MaxIter, ud.popupTieBreakRule);
     end       
     hMainFig=handles.vqdtool;
     ud2=get(hMainFig,'UserData');
       ud2.finalCodebook  = finalCB;
       ud2.errorArray     = ErrArray;
       ud2.entropyArray   = EntropyArray;
       ud2.popupTieBreakRuleForCurrentFig = ud.popupTieBreakRule;
     set(hMainFig,'UserData',ud2);
     
     % every time you update plot, you make it dirty.
     vqmake_fig_dirty(hMainFig);
     
     % update Total number of iterations Text
     h_editTotalIter=handles.editTotalIter;
     set(h_editTotalIter,'String',num2str(length(ErrArray)));
    
     %% PLOT ERROR %%
     vqplot_error(handles.plotErrIter, ErrArray);    
    
     %% PLOT ENTROPY %%
     vqplot_entropy (handles.plotEntropyIter, EntropyArray);
     
     localStartEndProcessing (handles,'on','Ready', 'Arrow');
 end
 
% --------------------------------------------------------------------
function need_newQuantizer = vqDataChanged(handles)

 ud=get(handles.vqdtool,'UserData');
  AutoGenerateInitCB  = (get(handles.popupInitCBSource,'Value')==1);
  NoWeighting         = get(handles.popupDistMeasure,'Value')==1;
  StopCriteriaRelTh   = (get(handles.popupStopCri,'Value')==1);
  StopCriteriaMaxIter = (get(handles.popupStopCri,'Value')==2);

 need_newQuantizer = (ud.TSchanged                                                  || ...
                     ud.InitCBSourcechanged                                         || ...
                     (AutoGenerateInitCB)* ud.NumLevelchanged                       || ...
                     (~AutoGenerateInitCB)* ud.initCBchanged                        || ...
                     ud.DistMeasChanged                                             || ...
                     (~NoWeighting)* ud.weightchanged                               || ... 
                     ud.StopCrichanged                                              || ...
                     (~StopCriteriaMaxIter)*  ud.RelThchanged                       || ...
                     (~StopCriteriaRelTh)*  ud.MaxIterchanged                       || ...
                     ud.TieBreakRulechanged                                         || ...
                     (~NoWeighting)* ud.CBupdateMethchanged                         || ... 
                     (ud.popupTieBreakRuleForCurrentFig ~= ud.popupTieBreakRule)     );

% --------------------------------------------------------------------
function vqResetChangeFlags(handles)

    hFig = handles.vqdtool;
    ud=get(hFig,'UserData');
		ud.TSchanged           = 0;
		ud.InitCBSourcechanged = 0;
		ud.NumLevelchanged     = 0;
		ud.initCBchanged       = 0;
		ud.DistMeasChanged     = 0;
		ud.weightchanged       = 0;
		ud.StopCrichanged      = 0;
		ud.RelThchanged        = 0;
		ud.MaxIterchanged      = 0;
		ud.TieBreakRulechanged = 0;
        ud.CBupdateMethchanged = 0;
	set(hFig,'UserData',ud);               

% --------------------------------------------------------------------
function localStartEndProcessing (handles, EnableState, StatusText, MouserPointer)

 %EnableState = 'on' or 'off'
 %StatusText = 'Ready' or 'Processing ...' 
 %MouserPointer = 'Arrow' or 'Watch'
 set(handles.pushbutnPlotFig,'Enable',EnableState);% disbale the pushbutnPlotFig
 set(handles.textStatus,'ForeGroundColor','Black');
 set(handles.textStatus, 'String',StatusText); %change the status text
 setptr(handles.vqdtool, MouserPointer); % set mouse pointer to hourglass
 
% --------------------------------------------------------------------
function editTS_Callback(hObject, eventdata, handles)

% hObject    handle to editTS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.vqdtool;
if (isempty(eventdata)), 
    vqmake_fig_dirty(hfig); 
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
    elseif size_val(2)<2, % min size=1x2
        if (isempty(eventdata)), errordlg('The TRAINING SET must have at least two columns.'); end
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
function popupInitCBSource_Callback(hObject, eventdata, handles)
% hObject    handle to popupInitCBSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');  
if (val==1)%% auto-generate initCB
	setenableprop([handles.textNumLevel   handles.editNumLevel],    'on');
    editNumLevel_Callback(handles.editNumLevel, eventdata, handles);% update ud.NumLevel, makes fig dirty
    setenableprop([handles.textInitCB     handles.editInitCB],      'off');
else%% user-defined initCB
	setenableprop([handles.textNumLevel   handles.editNumLevel],    'off');
	setenableprop([handles.textInitCB     handles.editInitCB],      'on');
    editInitCB_Callback(handles.editInitCB, eventdata, handles);% update ud.initCB, makes fig dirty
end   

hfig=handles.vqdtool;
ud=get(hfig,'UserData');

ud.InitCBSourcechanged = 0;
if ud.popupInitCBSource ~= val
     ud.InitCBSourcechanged = 1;
end

ud.popupInitCBSource = val;
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function editNumLevel_Callback(hObject, eventdata, handles)
% hObject    handle to editNumLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.vqdtool;
if (isempty(eventdata)), 
    vqmake_fig_dirty(hfig); 
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
hfig=handles.vqdtool;
if (isempty(eventdata)), 
    vqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end% make fig dirty
ud=get(hfig,'UserData');
[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr),
    val=double(val);
    [m n] = size(val);
    size_TS = size(ud.TS);
    if ~isreal(val)
        if (isempty(eventdata)), errordlg('The INITIAL CODEBOOK must be non-complex.'); end
        ud.errFlag_editInitCB = 1;   
    elseif  m ~=size_TS(1)
        if (isempty(eventdata)), errordlg('The number of rows in INITIAL CODEBOOK must be equal to that of TRAINING SET.'); end
        ud.errFlag_editInitCB = 1;
    elseif n<2, % min size=1x2
        if (isempty(eventdata)), errordlg('The INITIAL CODEBOOK must have at least two codewords.'); end
        ud.errFlag_editInitCB = 1;
    else
       %set changeFlag only if initCB is valid and different from the previous entry
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
function editWgtFactor_Callback(hObject, eventdata, handles)
% hObject    handle to editWgtFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if nargin>3, return; end
hfig=handles.vqdtool;
if (isempty(eventdata)), 
    vqmake_fig_dirty(hfig); 
    set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
end% make fig dirty
ud=get(hfig,'UserData');

[val, errStr] = evaluatevars(get(hObject, 'String'));

if isempty(errStr),
    val=double(val);
    [m n] = size(val);
    size_TS = size(ud.TS);
    WdimSameAsTS = (m==size_TS(1) && n==size_TS(2));
    WisVecAndLenEQrowsTS = (m==1 || n==1)&&(m*n==size_TS(1));
    AnyColElePositive = any(val);%any(val_eachColumn_ele>0)
    WallZeros = isempty(find(AnyColElePositive ==1));
    if ~isreal(val)
        if (isempty(eventdata)), errordlg('The WEIGHTING FACTOR must be non-complex.'); end
        ud.errFlag_editWgtFactor = 1;    
    elseif  (~WdimSameAsTS && ~WisVecAndLenEQrowsTS)
        if (isempty(eventdata)), errordlg('The WEIGHTING FACTOR must have the same size as TRAINING SET or its length must be equal to the number of rows in TRAINING SET.'); end
        ud.errFlag_editWgtFactor = 1;
    elseif  ~isempty(find(val<0))  
        if (isempty(eventdata)), errordlg('The WEIGHTING FACTOR cannot be negative.'); end
        ud.errFlag_editWgtFactor = 1;
    elseif  WallZeros  
        if (isempty(eventdata)), errordlg('The WEIGHTING FACTOR cannot be zeros.'); end
        ud.errFlag_editWgtFactor = 1;        
%     elseif (length(val)~= (length(ud.initCB)-1)),
%         if (isempty(eventdata)), errordlg('The WEIGHTING FACTOR vector length must be one less than the INITIAL CODEBOOK length.'); end
%         ud.errFlag_editWgtFactor = 1;
    else
        ud.weightchanged = 0;
        if ~isequal(ud.weight, val)
            ud.weightchanged = 1; 
        end
        % Update userdata 
        ud.weight = val;%sortedVal;        
        ud.errFlag_editWgtFactor = 0;
    end
else
    errStr = strcat(errStr,' (Error from WEIGHTING FACTOR edit box.)');
    if (isempty(eventdata)), errordlg(errStr); end 
    ud.errFlag_editWgtFactor = 1;
end
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function popupDistMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to popupDistMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');
hfig=handles.vqdtool;
if (val==1) %% Squared weight
	setenableprop([handles.textWgtFactor      handles.editWgtFactor],     'off');
    setenableprop([handles.textCBupdateMeth   handles.popupCBupdateMeth], 'off');
    vqmake_fig_dirty(hfig); 
else %%Weighted squared weight
	setenableprop([handles.textWgtFactor   handles.editWgtFactor],        'on');
    setenableprop([handles.textCBupdateMeth   handles.popupCBupdateMeth], 'on');
    editWgtFactor_Callback(handles.editWgtFactor, eventdata, handles);% make_fig_dirty
end   

ud=get(hfig,'UserData');

ud.DistMeasChanged = 0;
if ud.popupDistMeasure ~= val
     ud.DistMeasChanged = 1;
end

ud.popupDistMeasure = val;    
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

hfig=handles.vqdtool;
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
hfig=handles.vqdtool;
if (isempty(eventdata)), 
    vqmake_fig_dirty(hfig); 
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
hfig=handles.vqdtool;
if (isempty(eventdata)), 
    vqmake_fig_dirty(hfig); 
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
function popupTieBreakRule_Callback(hObject, eventdata, handles)
% hObject    handle to popupTieBreakRule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');

hfig=handles.vqdtool;
vqmake_fig_dirty(hfig); 
ud=get(hfig,'UserData');

ud.TieBreakRulechanged = 0;
if ud.popupTieBreakRule ~= val
     ud.TieBreakRulechanged = 1;
end

ud.popupTieBreakRule = val;    
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function popupCBupdateMeth_Callback(hObject, eventdata, handles)
% hObject    handle to popupCBupdateMeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupCBupdateMeth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupCBupdateMeth
set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
val = get(hObject,'Value');

hfig=handles.vqdtool;
vqmake_fig_dirty(hfig); 
ud=get(hfig,'UserData');

ud.CBupdateMethchanged = 0;
if ud.popupCBupdateMeth ~= val
     ud.CBupdateMethchanged = 1;
end

ud.popupCBupdateMeth = val;    
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function pushbutnRealzMdl_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnRealzMdl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  hfig=handles.vqdtool;
  ud=get(hfig,'UserData');
  UD.system           = '';
  UD.finalCodebook    = ud.finalCodebook;
  %UD.errorArray       = ud.errorArray;
  %UD.entropyArray     = ud.entropyArray;
  UD.TieBreakingRule  = ud.popupTieBreakRuleForCurrentFig;
  UD.destinationMdl   = get(handles.popupDestMdl,'Value');% 1=current, 2=new
  UD.blockType        = get(handles.popupBlockType,'Value');% 1=encoder, 2=decoder, 3=both  
  %UD.EncBlockName        = get(handles.editEncBlkName, 'String');
  %UD.DecBlockName        = get(handles.editDecBlkName, 'String');
  UD.overwriteFlag    = get(handles.chkboxOverwriteBlock, 'Value');% 0/1 
  UD.hTextStatus      = ud.hTextStatus;
  if (UD.blockType ~=2)%encoder(1) OR both(3)
      UD.blockName  = get(handles.editEncBlkName, 'String');
      UD.whichBlock = 1; %encoder
      vqrealizemdl(UD);% this sets status to ready
  end      
  if (UD.blockType~=1)%decoder(2) OR both(3)
      if (UD.blockType==3) UD.destinationMdl=1; end %1=current
      UD.blockName  = get(handles.editDecBlkName, 'String');
      UD.whichBlock = 2; %decoder
      vqrealizemdl(UD);% this sets status to ready
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
hfig=handles.vqdtool;
vqmake_fig_dirty(hfig);
ud=get(hfig,'UserData');
ud.popupDestMdl = val;
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function popupBlockType_Callback(hObject, eventdata, handles)
% hObject    handle to popupBlockType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupBlockType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupBlockType
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
hfig=handles.vqdtool;
vqmake_fig_dirty(hfig);
ud=get(hfig,'UserData');
ud.popupBlockType = val;  
set(hfig,'UserData',ud);
if nargin>3, return; end

% --------------------------------------------------------------------
function editDecBlkName_Callback(hObject, eventdata, handles)
% hObject    handle to editDecBlkName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDecBlkName as text
%        str2double(get(hObject,'String')) returns contents of editDecBlkName as a double
set(handles.textStatus,'ForeGroundColor','Black');  
set(handles.textStatus,'String','Ready');
hfig=handles.vqdtool;
vqmake_fig_dirty(hfig); 

% --------------------------------------------------------------------
function editEncBlkName_Callback(hObject, eventdata, handles)
% hObject    handle to editEncBlkName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
hfig=handles.vqdtool;
vqmake_fig_dirty(hfig); 

% --------------------------------------------------------------------
function chkboxOverwriteBlock_Callback(hObject, eventdata, handles)
% hObject    handle to chkboxOverwriteBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.textStatus,'ForeGroundColor','Black');  set(handles.textStatus,'String','Ready');
hfig=handles.vqdtool;
vqmake_fig_dirty(hfig);
ud=get(hfig,'UserData');
ud.chkboxOverwriteBlock = get(hObject,'Value');
set(hfig,'UserData',ud);

%--------------------------------------------------------------------------
function pushbutnExport_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutnExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vqexport(handles.vqdtool);% This sets status to ready

%--------------------------------------------------------------------------
function vqCallAllCallbacks(handles)
  % User Data are not updated here (no SET)
  AutoGenerateInitCB  = (get(handles.popupInitCBSource,'Value')==1);
  NoWeighting         =  get(handles.popupDistMeasure,'Value')==1;
  StopCriteriaRelTh   = (get(handles.popupStopCri,'Value')==1);
  StopCriteriaMaxIter = (get(handles.popupStopCri,'Value')==2);
  
  editTS_Callback(handles.editTS, 1, handles);
  if (AutoGenerateInitCB)
      editNumLevel_Callback(handles.editNumLevel, 1, handles);
  else
      editInitCB_Callback(handles.editInitCB, 1, handles);
  end
  if (~NoWeighting)   
      editWgtFactor_Callback(handles.editWgtFactor, 1, handles);
  end

  if (~StopCriteriaMaxIter)
      editRelTh_Callback(handles.editRelTh, 1, handles);
  end
  if (~StopCriteriaRelTh)
      editMaxIter_Callback(handles.editMaxIter, 1, handles);
  end   

% --------------------------------------------------------------------
function vqdtool_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to vqdtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

vqclose(hObject);

% [EOF] vqdtool.m



