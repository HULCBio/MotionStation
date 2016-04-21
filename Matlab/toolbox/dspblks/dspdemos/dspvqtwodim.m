function varargout = dspvqtwodim(varargin)
% DSPVQTWODIM demo illustrates Vector Quantizer Design process using
%      Generalized Lloyd Algorithm (GLA) for two dimensional input.
%
%      DSPVQTWODIM displays two-dimensional codebook and the corresponding
%      voronoi cells in the upper plot.  The training set is also shown.
%
%      The lower plot shows the number of training vectors belonging to
%      each cell.
%
%      To run the GLA, you need to specify training set and number of 
%      levels. In this case, the initial codebook is internally generated.
%      Instead of specifying number of levels, you can specify the initial
%      codebook either from mask or from plot. To alter the data in plot, 
%      you can move any codeword by left clicking on it and dragging it. 
%      The demo updates the voronoi cell boundary based on the new codebook.
%
%      You can view data corresponding to each codeword by right clicking 
%      on the codeword. Right click on a bar plot and you can see the 
%      corresponding data.
%
% See also: SQDTOOL, VQDTOOL.

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/06 15:22:12 $

%for testing:
% h=dspvqtwodim;
% set(h,'tag','testing');% default tag 'dspvqtwodim'
% then press start GLA button;

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dspvqtwodim_OpeningFcn, ...
                   'gui_OutputFcn',  @dspvqtwodim_OutputFcn, ...
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
function dspvqtwodim_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for dspvqtwodim
handles.output = hObject;

set(handles.output, 'DoubleBuffer', 'On');

% Update handles structure
guidata(hObject, handles);
movegui(hObject, 'center');

% Render menus
render_menus(hObject); 

% Render toolbar
set(hObject, 'Toolbar', 'none');
set(handles.edit16,'backgroundcolor', get(handles.textStatus,'backgroundcolor'));
%set user data (ud)
ud=get(hObject,'UserData');
  ud.version = 1;
   ud.TS = randn(2,10000);;
   CB_x =[-0.3774    1.0338   -0.3576    2.3654    0.6418    0.2877    1.0866   -1.2689    0.4028   -1.7802 ...
          -0.9080   -0.6327    0.0847   -1.6606    1.6307   -0.1997   -0.9853   -1.9864    0.7537    1.9859 ...
           0.2020   -0.5090    1.1291    0.2112   -1.5380    1.2594   -0.9385    0.8127   -0.4684   -0.2390 ...
           1.6321   -2.1761 ];
    
   CB_y =[ 0.0600   -2.0946   -0.9868    0.9392   -0.5748   -0.0337   -0.2058   -0.1478    1.2481    1.5310 ...   
          -1.2691   -2.1546    0.5156    0.4455    0.2655   -0.3833    1.0266   -1.2987    0.4641   -0.8479 ...    
          -0.7454    1.9331   -1.0640   -1.5112   -0.6209    1.1847    0.3026    2.1779    0.5852    1.1654 ...
           2.2134    0.1934 ];
  ud.initCB = [CB_x;CB_y] ;
  ud.NumLevel = 32;

  ud.RelTh  =1e-7;
  ud.MaxIter=double(int32(inf));
  
  ud.TS_str= 'randn(2,10000)';
  ud.NumLevel_str = '32';
  ud.initCB_str=  'randn(2,32)';
  ud.RelTh_str  ='1e-7';
  ud.MaxIter_str='100';
  ud.leftButtonDownOnVorPlot = 0;
  ud.rightButtonDownOnVorPlot = 0;
  ud.rightButtonDownOnHistPlot = 0;
  ud.CWidxHighlighted = 0;% index starts with 1
  ud.BARidxHighlighted = 0;% index starts with 1
  ud.stopButtonPressed = 0;
  ud.pauseButtonPressed = 0;
  ud.resumeButtonPressed = 0;
  %% for pause/resume button save intermediate data
  ud.ith_initCodebook  = [];
  ud.ith_initIterValue = []; 
  ud.ith_PrevErr       = [];
  ud.ith_PrevErrArray  = [];
  % to save handle enable property to 'inactive'
  ud.neededHandles = [handles.editTS      handles.popupInitCBSource handles.editNumLevel ...
                      handles.editInitCB  handles.popupStopCri      handles.editRelTh  handles.editMaxIter];
  ud.enableHandleInfo = [];
  
set(hObject,'UserData',ud);   

if strcmp(get(hObject,'Visible'),'off')    
    hfig1=handles.plotVoronoi;  
    hfig2=handles.plotHistogram;   

  % set font size
  if ~ispc,
      hall = convert2vector(handles);
      set(hall(isprop(hall, 'fontsize')), 'fontsize', 9);
      hplots = [hfig1 hfig2];
      set(hplots(isprop(hplots, 'fontsize')), 'fontsize', 9);
      pos1=get(handles.textRightClickVorPlot,'position');
      pos1(3) = 0.222;
      set(handles.textRightClickVorPlot,'position',pos1);
      pos2=get(handles.textRightClickHistPlot,'position');
      pos2(3) = 0.222;
      set(handles.textRightClickHistPlot,'position',pos2);
  else
      set(handles.textRightClickVorPlot,'fontsize',8);
      set(handles.textRightClickHistPlot,'fontsize',8);
  end     
   
   % set Default enable/disable
   setenableprop([handles.textInitCB   handles.editInitCB],  'off');
   setenableprop([handles.textMaxIter  handles.editMaxIter], 'off');
   setenableprop([handles.pushbutnStop], 'off');
   setenableprop([handles.pushbutnPause], 'off');
   
   setenableprop([handles.pushbutnResume],  'off');
   
   %Draw default figures.
   %% draw default Voronoi diagarm %% 
   axes(hfig1);
   vqplot_training(handles, ud.TS, 1); hold on;
   set(hfig1,'linewidth',0.1);%gca=hfig1   
   vqplot_voronoi(handles,ud.initCB,1); % 1 = FirstTime
   
   %% draw default histogram %% 
   axes(hfig2);
   [finalCB, Err, countTSinCells]= dspvqdemomex(ud.TS, ud.initCB);% get countTSinCells
   vqplot_histogram(handles, countTSinCells); 
end

function [xleft, xright, yleft, yright] = getAxisLimit (TS)
	% for lsf
    minTS = min(min(TS));
    maxTS = max(max(TS));
    if minTS >=0 & maxTS <= 1 % for rand(2,1000)
        xleft = 0;  xright =1;
        yleft = 0;  yright =1;
    elseif minTS >=-1 & maxTS <= 1 % for lsf (-1 to 1) or 
        xleft = -1;  xright =1;
        yleft = -1;  yright =1;      
    elseif minTS >=-2 & maxTS <= 2 % for lsf (-1 to 1) or 
        xleft = -2;  xright =2;
        yleft = -2;  yright =2;         
    elseif minTS >=-3 & maxTS <= 3 % for lsf (-1 to 1) or 
        xleft = -3;  xright =3;
        yleft = -3;  yright =3; 
    else
        TSxOutRange = find(TS(1,:)<-3 | TS(1,:)>3);
	    TSyOutRange = find(TS(2,:)<-3 | TS(2,:)>3);
	    TSOutRange = unique([TSxOutRange TSyOutRange]);
	    NumTSOutRange = length(TSOutRange);
        if NumTSOutRange <= 0.05*length(TS(1,:))% 5 percent outliers acceptable
            xleft = -3;  xright =3;
            yleft = -3;  yright =3; 
        else 
           xleft = min(TS(1,:));  xright =max(TS(1,:));
           yleft = min(TS(2,:));  yright =max(TS(2,:));  
       end
    end       

% --------------------------------------------------------------------
function vqplot_training(handles, TS, FirstTime) 
    if nargin == 2, FirstTime =0; end

    if FirstTime, 
        % since at the beginning, this callback is called first (before plotOVronoi)
        % so it is guaranteed that TS plot will always be 'Back' (wrt Voronoi cell line)
		hplotTS = plot(TS(1,:), TS(2,:),'g.','MarkerSize',0.5, 'Tag', 'TSdata');% yellow and only dot; smallest marker size
		xlabel('X-value');              
		ylabel('Y-value');
		[xleft xright yleft yright] = getAxisLimit (TS);
        axis([xleft xright yleft yright]); %[-3 3 -3 3]
		grid off;
        % at first we do not want to generate any out_of_range_TSdata message
    else     
        hTS = flipud(findobj(handles.plotVoronoi,'Tag','TSdata'));
        if (~isempty(hTS)), 
            set(hTS, 'XData',[], 'YData',[]); 
            set(hTS, 'XData',TS(1,:), 'YData',TS(2,:)); 
       		[xleft xright yleft yright] = getAxisLimit (TS);
            axis([xleft xright yleft yright]); %[-3 3 -3 3]

        end
        %generate message for out_of_range_TSdata
        hVoronoi = handles.plotVoronoi;
        plotRangeX = get(hVoronoi,'XLim'); 
        plotRangeY = get(hVoronoi,'YLim'); 
        TSxOutRange = find(TS(1,:)<plotRangeX(1) | TS(1,:)>plotRangeX(2));
        TSyOutRange = find(TS(2,:)<plotRangeY(1) | TS(2,:)>plotRangeY(2));
        TSOutRange = unique([TSxOutRange TSyOutRange]);
        NumTSOutRange = length(TSOutRange);
        if (NumTSOutRange>0)
         TextMsg = sprintf('%d Training Vector(s) out of visible area of the plot.',NumTSOutRange);
         set(handles.textStatus,'String',TextMsg);
        else
         set(handles.textStatus,'String','Ready');        
        end 
    end
% --------------------------------------------------------------------
function vqplot_voronoi(handles, codebook, FirstTime, NumCodewordChanged) 
% plots error data, sets grid, markers, labels
     % FirstTime =1, mean called from dspvqtwodim_OpeningFcn
     % FirstTime =0, mean called from somewhere else
     % if the function is called from editNumlevel or editInitCB
     if nargin == 3, NumCodewordChanged = 0; end

     DBl_MAX = 100000;
     xFar= [DBl_MAX -DBl_MAX -DBl_MAX  DBl_MAX];
     yFar= [DBl_MAX  DBl_MAX -DBl_MAX -DBl_MAX]; 
     xorg=codebook(1,:);
     yorg=codebook(2,:); 

     xtemp = xorg;
     ytemp = yorg;
     % if xorg or yorg has more than 1 same values, then add a random displacement
     % to draw voronoi cell
     for i=1:length(xtemp)-1
         idx_x = [];
         idx_y = [];
         idx_x = find( xtemp== xtemp(i));
         idx_y = find( ytemp== ytemp(i));
         for j=1:length(idx_x)
             %rand('state',sum(100*clock));
             xtemp(idx_x(j)) = xtemp(idx_x(j)) + 1e-3*rand(1,1);
         end    
         for j=1:length(idx_y)
             %rand('state',sum(100*clock));
             ytemp(idx_y(j)) = ytemp(idx_y(j)) + 1e-3*rand(1,1);
         end 
     end    
     x=[xtemp xFar];
     y=[ytemp yFar]; 

     [vx, vy]=voronoi(x,y);
     % set(gca, 'visible', 'off')
     if FirstTime,
        hold on;
        hv = plot(vx,vy,'b-', 'Tag', 'VorCell');
        hc = scatter('v6',xorg,yorg,5,'r'); set(hc,'Tag', 'Codebook');
        set(hv,'LineWidth',0.5);
        set(hc,'LineWidth',0.5);
        hold off;
        %no need to set axis range and grid here (already set for TS)
     else
       % it is not guaranteed that for the same number of x,y
       % Voronoi returns a fixed sized vx, vy; so number of handles
       % is not fixed. That's why it is better to delete the previous 
       % diagram and redraw it again for (vx,vy).
       hold on;
       hVcell = flipud(findobj(handles.plotVoronoi,'Tag','VorCell'));
       delete(hVcell);
       hv = plot(vx,vy,'b-', 'Tag', 'VorCell');
       set(hv,'LineWidth',0.5);
       
       if (NumCodewordChanged)
           %delete previous lines and dots as number of handles would change           
           hCB = flipud(findobj(handles.plotVoronoi,'Tag','Codebook'));   
           delete(hCB);
           hc = scatter('v6',xorg,yorg,5,'r'); set(hc,'Tag', 'Codebook');
           set(hc,'LineWidth',0.5);
           hold off;
           %set(hfig,'UserData',ud);
        else    
                hCB = flipud(findobj(handles.plotVoronoi,'Tag','Codebook'));
                if (~isempty(hCB)), 
                    set(hCB, 'XData',[], 'YData',[]); 
                      % set(ud.hplotCodebook, 'XData',xorg, 'YData',yorg);
                      % the above line - gives two codeword from 1 codeword
                    for(i=1:length(hCB))
                        set(hCB(i), 'XData',xorg(i), 'YData',yorg(i)); 
                    end  
                end  
        end
     end   
    title('Training set, Voronoi cells, codebook','FontWeight','bold');
    %generate message for status bar
    hVoronoi = handles.plotVoronoi;
    plotRangeX = get(hVoronoi,'XLim'); 
    plotRangeY = get(hVoronoi,'YLim'); 
    CWxOutRange = find(codebook(1,:)<plotRangeX(1) | codebook(1,:)>plotRangeX(2));
    CWyOutRange = find(codebook(2,:)<plotRangeY(1) | codebook(2,:)>plotRangeY(2));
    CWOutRange = unique([CWxOutRange CWyOutRange]);
    NumCWOutRange = length(CWOutRange);
    if (NumCWOutRange>0)
     TextMsg = sprintf('%d Codeword(s) out of visible area of the plot.',NumCWOutRange);
     set(handles.textStatus,'String',TextMsg);
    else
         set(handles.textStatus,'String','Ready');         
    end 
     
% --------------------------------------------------------------------
function vqplot_histogram(handles, countTSinCells) 
     hHist = handles.plotHistogram;
     len = length(countTSinCells);
     h_bar(1:len)=zeros(1,len);
	 for i=1:len % bar returns one handle; but to use mouse down fcn
                 % we need handle of each bar
        h_bar(i)=bar('v6',i,countTSinCells(i),0.98);% 0.98 = Barwidth 
        hold on;
	 end  
     set(h_bar,'LineWidth',0.5);
	 hold off;

     set(h_bar,'Tag','Bar');
     colormap([0.9398  0.7421   0.4719]);
     %set(h_bar,'visible','off');
     xlabel('Codeword index (1-based)');
     ylabel('Number of training vectors');
     title('Number of training vectors in each cell','FontWeight','bold');

     lenCount = length(countTSinCells);
     axis([0 (lenCount+1) 0  max(countTSinCells)*1.03]);  %make 3percent free space
     if lenCount<=32
         step = 2;
     elseif lenCount<=128    
         step = 4;
     elseif lenCount<=256    
         step = 8;  
     else
         step = 16;  
     end         
     set(hHist,'xtick',[1:step:lenCount]);
     set(hHist,'xticklabel',[1:step:lenCount]);
     
     grid off;   

% --------------------------------------------------------------------
function render_menus(fig)

% Render the "File" menu
hmenus.hfile = render_filemenu(fig,1);

% Render the "Window" menu
hmenus.hwindow = render_sptwindowmenu(fig,2);

% Render the "Help" menu
hmenus.hhelp = render_helpmenu(fig);  

% --------------------------------------------------------------------
function hfile = render_filemenu(hFig, pos)
%RENDER_FILEMENU Render the File menu of the VQ DESIGN (GLA) GUI
strs = {xlate('&File'), ...
    xlate('Print Setup...'), ...
    xlate('Print Preview...'), ...
    xlate('Print...'), ...
    xlate('Full View Analysis'), ...
    xlate('Close')
    };
cb = fmenu_callbacks(hFig);
cbs = {'', ...
    cb.printsetup, ... 
    cb.printpreview, ...
    cb.print, ...
    cb.fullview, ...
    cb.close
     };
tags = {'file', ...
    'printsetup', ...
    'printpreview', ...
    'print', ...
    'fullview',...
    'close'
    };
sep = {'off', ...
    'off', ...
    'off', ...
    'off', ...
    'on', ...
    'on'};
accel = {'', ...
    '', ...
    '', ...
    'P', ...
    '', ...
    'W'
       }; 
hfile = addmenu(hFig,pos,strs,cbs,tags,sep,accel);

% --------------------------------------------------------------------
function cbs = fmenu_callbacks(hMainFig)

cbs.close        = {@close_cbs, hMainFig};
cbs.printsetup   = {@printsetup_cbs,hMainFig};
cbs.printpreview = {@printpreview_cbs,hMainFig};
cbs.print        = {@print_cbs,hMainFig};
cbs.fullview     = {@fullview_cbs, hMainFig};

% --------------------------------------------------------------------
function close_cbs(hcbo, eventstruct, hMainFig)

set(hMainFig, 'Visible', 'Off');
delete(hMainFig);
clear hMainFig;

% --------------------------------------------------------------------
function printsetup_cbs(hcbo, eventstruct,hMainFig)

hFig_printprev = copyaxes(hMainFig);
printdlg('-setup', hFig_printprev);
delete(hFig_printprev);

% --------------------------------------------------------------------
function printpreview_cbs(hcbo, eventstruct,hMainFig)

hFig_printprev = copyaxes(hMainFig);

hWin_printprev = printpreview(hFig_printprev);
uiwait(hWin_printprev);
delete(hFig_printprev);

% --------------------------------------------------------------------
function print_cbs(hcbo, eventstruct,hMainFig)

hFig_printprev = copyaxes(hMainFig);
printdlg(hFig_printprev);
delete(hFig_printprev);

% --------------------------------------------------------------------
function fullview_cbs(hcbo, eventstruct, hMainFig)
% Full view analysis

hFig_printprev = copyaxes(hMainFig);
set(hFig_printprev, 'Visible', 'on');

% --------------------------------------------------------------------
function hFig_printprev = copyaxes(hMainFig)
% COPY the axes of both the figures.

	h = guidata(hMainFig);
	hFig_printprev = figure('Number','off',...
                            'visible','off');
                        
	hax1 = subplot(2,1,1);
	haxc1 = copyobj(h.plotVoronoi, hFig_printprev);
	set(haxc1, 'units', get(hax1, 'units'), 'position', get(hax1, 'position'));
    delete(hax1);
	
    hax2 = subplot(2,1,2);
    haxc2 = copyobj(h.plotHistogram, hFig_printprev);
    set(haxc2, 'units', get(hax2, 'units'), 'position', get(hax2, 'position'));
    delete(hax2);

% --------------------------------------------------------------------
function hhelp = render_helpmenu(fig)

[hhelpmenu, hhelpmenuitems] = render_vqhelpmenu(fig,3);

strs  = 'VQ Demo Help';
cbs   = @help_Callback;
tags  = 'helpdemo'; 
sep   = 'off';
accel = '';
hwhatsthis = addmenu(fig,[3 1],strs,cbs,tags,sep,accel);

hhelp = [hhelpmenu, hhelpmenuitems(1), hwhatsthis, hhelpmenuitems(2:end)];

% --------------------------------------------------------------------
function varargout = help_Callback(h, eventdata, handles, varargin)
% Launch help for the demo

helpwin(mfilename);

% --------------------------------------------------------------------
function varargout = dspvqtwodim_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function editRelTh_Callback(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
[val, errStr] = evaluatevars(get(hObject, 'String'));

usePrevVal = 1;
if isempty(errStr), 
    val=double(val);
    if ~isreal(val)
        uiwait(errordlg('The RELATIVE THRESHOLD must be non-complex.','VQ Demo','modal'));
    elseif (length(val)>1 || val>=1 || val<0),% Valid values: 0 <= RelTh < 1
        uiwait(errordlg('The RELATIVE THRESHOLD must be a scalar - greater than or equal to 0 and less than 1.','VQ Demo','modal'));
    else
		% Update userdata
        usePrevVal = 0;
        ud.RelTh = val;
        ud.RelTh_str = get(hObject, 'String');
    end 
else
    errStr = strcat(errStr,' (Error from RELATIVE THRESHOLD edit box.)');
    uiwait(errordlg(errStr,'VQ Demo','modal'));
end
if (usePrevVal == 1)
    set(hObject,'String',ud.RelTh_str);
end 
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function editMaxIter_Callback(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData'); 

[val, errStr] = evaluatevars(get(hObject, 'String'));
usePrevVal = 1;

if isempty(errStr),    
    val=double(val);
    if ~isreal(val)
        uiwait(errordlg('The MAXIMUM ITERATION must be non-complex.','VQ Demo','modal'));
    elseif (length(val)>1  || val <=1 || (val-floor(val)~=0)), 
        uiwait(errordlg('The MAXIMUM ITERATION must be a positive scalar integer greater than 1.','VQ Demo','modal'));
    else
		% Update userdata
        usePrevVal = 0;
	    ud.MaxIter = val;
        ud.MaxIter_str = get(hObject, 'String');
    end
else
    errStr = strcat(errStr,' (Error from MAXIMUM ITERATION edit box.)');
    uiwait(errordlg(errStr,'VQ Demo','modal'));
end
if (usePrevVal == 1)
    set(hObject,'String',ud.MaxIter_str);
end 
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function popupInitCBSource_Callback(hObject, eventdata, handles)

val = get(hObject,'Value');  
if (val==1)%% auto-generate initCB
	setenableprop([handles.textNumLevel   handles.editNumLevel],    'on');
    editNumLevel_Callback(handles.editNumLevel, eventdata, handles);% update ud.NumLevel 
    setenableprop([handles.textInitCB     handles.editInitCB],      'off');
elseif (val==2)%% user-defined initCB
	setenableprop([handles.textNumLevel   handles.editNumLevel],    'off');
	setenableprop([handles.textInitCB     handles.editInitCB],      'on');
    editInitCB_Callback(handles.editInitCB, eventdata, handles);% update ud.initCB 
else%% From graph
	setenableprop([handles.textNumLevel   handles.editNumLevel],    'off');
	setenableprop([handles.textInitCB     handles.editInitCB],      'off');
    % do nothing (tie-break always low (1))
end   

% --------------------------------------------------------------------
function editNumLevel_Callback(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');

[val, errStr] = evaluatevars(get(hObject, 'String'));

usePrevVal = 1;
if isempty(errStr), 
    val=double(val);
    size_val = size(val);
    if ~isreal(val)
        uiwait(errordlg('The NUMBER OF LEVELS must be non-complex.','VQ Demo','modal'));
    elseif (length(val)>1  || val < 2 || val > 256 || (val-floor(val)~=0)),
        uiwait(errordlg('The NUMBER OF LEVELS must be a positive scalar integer (greater than 1, less than 257).','VQ Demo','modal'));
    else  
		usePrevVal = 0;
        LastValidNumLevel = ud.NumLevel;
        NumCodewordChanged = ( LastValidNumLevel ~= val);
		ud.NumLevel = val; 
		ud.NumLevel_str = get(hObject, 'String');
		%setting initCB too
        ud.initCB = getInitCodebook(ud.TS,ud.NumLevel);
        ud.initCB_str = num2str(ud.initCB);
        %updating Voronoicells and codewords plot
        axes(handles.plotVoronoi);
		vqplot_voronoi(handles, ud.initCB, 0, NumCodewordChanged );% 0 for NOT firstTime
		
        %to find Count for each initCodeWord call mex
        [finCB, Err, countTSinCells] = dspvqdemomex(ud.TS, ud.initCB);% get countTSinCells
		set(hfig, 'CurrentAxes', handles.plotHistogram);  
		vqplot_histogram(handles, countTSinCells);
    end
else
    errStr = strcat(errStr,' (Error from NUMBER OF LEVELS edit box.)');
    uiwait(errordlg(errStr,'VQ Demo','modal'));
end    
if (usePrevVal == 1)
    set(hObject,'String',ud.NumLevel_str);
end    
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function editInitCB_Callback(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
[val, errStr] = evaluatevars(get(hObject, 'String'));
usePrevVal = 1;

if isempty(errStr),
    val=double(val);
    [m n] = size(val);
    size_TS = size(ud.TS);
    if ~isreal(val)
        uiwait(errordlg('The INITIAL CODEBOOK must be non-complex.','VQ Demo','modal'));
    elseif  m ~=size_TS(1)
        uiwait(errordlg('The number of rows in INITIAL CODEBOOK must be equal to that of TRAINING SET.','VQ Demo','modal'));
    elseif n<2, % min size=1x2
        uiwait(errordlg('The INITIAL CODEBOOK must have at least two codewords.','VQ Demo','modal'));
    else
       % Update userdata
       usePrevVal = 0;
       LastValidNumLevel = ud.NumLevel;
       NumCodewordChanged = ( LastValidNumLevel ~= size(val,2));
       ud.initCB = val;%always store sorted initCB
       ud.initCB_str = get(hObject, 'String');
       %setting numlevel too
       ud.NumLevel = size(val,2);
       ud.NumLevel_str = num2str(ud.NumLevel);
       %updating Voronoicells and codewords plot
        set(hfig, 'CurrentAxes', handles.plotVoronoi);  
		vqplot_voronoi(handles, ud.initCB, 0, NumCodewordChanged );% 0 for NOT firstTime
		
		%to find Count for each initCodeWord call mex
        [finCB, Err, countTSinCells] = dspvqdemomex(ud.TS, ud.initCB);%get countTSinCells
		axes(handles.plotHistogram);
		vqplot_histogram(handles, countTSinCells);
    end    
else
    uiwait(errordlg([errStr,' (Error from INITIAL CODEBOOK edit box.)'],'VQ Demo','modal'));
end
if (usePrevVal == 1)
    set(hObject,'String',ud.initCB_str);
end 
set(hfig,'UserData',ud);

% --------------------------------------------------------------------
function pushbutnStart_Callback(hObject, eventdata, handles)

setenableprop([hObject], 'off');
setenableprop([handles.pushbutnStop], 'on');
setenableprop([handles.pushbutnPause],  'on');

InitCBfromPlot  = (get(handles.popupInitCBSource,'Value')==3);

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData'); 
    EnaDis = get(ud.neededHandles, 'enable');
    % reset all
    ud.enableHandleInfo = EnaDis;
    ud.stopButtonPressed   = 0;
    ud.pauseButtonPressed  = 0;
    ud.resumeButtonPressed = 0;
set(hfig,'UserData',ud); 
set (ud.neededHandles, 'enable', 'inactive');

if (InitCBfromPlot)  
    %no need to update userdata (initCb, numlevel)
    %no need to update plots (already updated)
    hCB = flipud(findobj(handles.plotVoronoi,'Tag','Codebook'));
    [X_cb, Y_cb] = getCurrentCodebookOnGraph(hCB);
    CBonPlot = [X_cb'; Y_cb'];   
end

%run GLA (call c-mex at each iteration)
initIterValue=0;

PrevErr = 1.7976931348623158e+308;% double_max
PrevErrArray = [];

if (InitCBfromPlot) 
  initCodebook = CBonPlot;
else
  initCodebook = ud.initCB;
end  
%before running GLA update the figure with the initial codebook
	hfig1=handles.plotVoronoi;  
	hfig2=handles.plotHistogram; 
	axes(hfig1);
	vqplot_voronoi(handles, initCodebook, 0);% 0 for NOT firstTime
    title('Training set, Voronoi cells, initial codebook','FontWeight','bold');
	
	[temp1, temp2, countTSinCells]= dspvqdemomex(ud.TS, initCodebook);
    axes(hfig2);
	vqplot_histogram(handles, countTSinCells);
    title('Number of training vectors in each cell','FontWeight','bold');
    pause(1);

GLAandUpdatePlots(handles, initCodebook, initIterValue , PrevErr, PrevErrArray);

% --------------------------------------------------------------------
function GLAandUpdatePlots(handles, initCodebook, initIterValue, PrevErr, PrevErrArray)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');  
tempPauseButnPressed = 0;
tempStopButnPressed = 0;
StopCriteriaRelTh   = (get(handles.popupStopCri,'Value')==1);
StopCriteriaMaxIter = (get(handles.popupStopCri,'Value')==2);

if (StopCriteriaRelTh) %% RelTh only, DEFAULT MaxIter = inf
  % ud.MaxIter = inf <-- in this case c-mex gives '0' !
  ud.MaxIter = double(int32(inf));
elseif (StopCriteriaMaxIter)%% MaxIter only, DEFAULT RelTh = 0
  ud.RelTh = 0;
end   

%%%%%%%%%%%%%%%%%%%%BEGIN: ONLY FOR TESTING(1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for testing:
% h=dspvqtwodim;
% set(h,'tag','testing');% default tag 'dspvqtwodim'
% then press start GLA button;

testingvq =strcmp(get(hfig,'tag'),'testing');
if (testingvq)
[finalCBmex, ErrArraymex, Entropymex]= ...
sdspvqdesignmex(ud.TS, initCodebook, 0, 1, ud.RelTh,ud.MaxIter, 1);
end
%%%%%%%%%%%%%%%%%%%%END: ONLY FOR TESTING(1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iter = initIterValue;
Err = PrevErr;
halt = false;
oldErr =[];
diffErr =[];
ErrArray = PrevErrArray;
try    
while (~halt) 
    oldErr = Err;
    [finalCB, Err, countTSinCells]= dspvqdemomex(ud.TS, initCodebook);
    if iter==10
        ss=1;
    end    
    initCodebook = finalCB;
	ErrArray = [ErrArray Err];
	iter = iter + 1;
    if (Err == 0.0) 
       halt = true;
    else
       diffErr = oldErr - Err;
       if ( (diffErr/oldErr < ud.RelTh)  | (iter == ud.MaxIter) )
                  halt = true;
       end                  
    end    
    %%%%%%%%%%%%%%%%%%%%BEGIN: ONLY FOR TESTING(2) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (~testingvq)
    %%%%%%%%%%%%%%%%%%%%END: ONLY FOR TESTING(2) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %%%%%%%% Update graphs at each iteration by the final codebook
        % vqplot_training(handles, ud.TS); <-- no need
		hfig1=handles.plotVoronoi;  
		hfig2=handles.plotHistogram; 
		axes(hfig1);
		vqplot_voronoi(handles, finalCB, 0);% 0 for NOT firstTime
        VorTitle=sprintf('Training set, Voronoi cells, updated codebook at iteration %d', iter);
        title(VorTitle,'FontWeight','bold');
		
		axes(hfig2);
		vqplot_histogram(handles, countTSinCells);
        HistTitle = sprintf('Number of training vectors in each cell at iteration %d', iter);
        title(HistTitle,'FontWeight','bold');
        pause(1);
        %check if stop/pause/resume button is pressed
        ud2=get(hfig,'UserData'); 
        % check if stop button is pressed
        if (ud2.stopButtonPressed)
           %dynamics controlled in stopbutn callback
           ud2.stopButtonPressed = 0;%reset
           tempStopButnPressed = 1;
           tempPauseButnPressed = 0;%reset
           set(hfig,'UserData',ud2);           
           break;
       elseif (ud2.pauseButtonPressed)      % check if pause button is pressed        
           %dynamics controlled in pausebutn callback
           ud2.pauseButtonPressed = 0; 
           tempPauseButnPressed = 1;
           tempStopButnPressed = 0;%reset
           %% save intermediate data
           ud2.ith_initCodebook = finalCB;
           ud2.ith_initIterValue = iter; 
           ud2.ith_PrevErr       =  Err;
           ud2.ith_PrevErrArray  = ErrArray;
           set(hfig,'UserData',ud2);
           
           break;
        end
    %%%%%%%%%%%%%%%%%%%%BEGIN: ONLY FOR TESTING(3) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    end 
    %%%%%%%%%%%%%%%%%%%%END: ONLY FOR TESTING(3) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
end % end of while  

%%%%%%%%%%%%%%%%%%%%BEGIN: ONLY FOR TESTING(4-end) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (testingvq)
	if ~isequal(finalCB, finalCBmex)
        errordlg('test failure finalCB');
    else
        disp('same finalCB');
    end    
	if ~isequal(ErrArraymex, ErrArray')
        errordlg('test failure ErrArray');
    else
        disp('same ErrArray');    
	end
end
%%%%%%%%%%%%%%%%%%%%END: ONLY FOR TESTING(4-end) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~tempPauseButnPressed )% GLA has completed all the iterations
	setenableprop([handles.pushbutnStart], 'on');
    setenableprop([handles.pushbutnStop], 'off');
    setenableprop([handles.pushbutnPause],  'off');
    setenableprop([handles.pushbutnResume],  'off');
    for i=1:length(ud2.neededHandles)
      set (ud.neededHandles(i), 'enable', ud2.enableHandleInfo{i}); 
    end   
end  
catch
    disp('GUI closed in the middle of GLA.');
end %try
    
% --------------------------------------------------------------------
function initCB = getInitCodebook(TS,NumLevel);
     size_TS  = size(TS);
     numTSvector = size_TS(2);
     rand_idx = double(int32(numTSvector*rand(1,NumLevel)));
     zero_idx = find(rand_idx==0);
     if (~isempty(zero_idx)),
         rand_idx(zero_idx) = 1;
     end    
     initCB = TS(:,rand_idx);

% --------------------------------------------------------------------
function editTS_Callback(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');

[val, errStr] = evaluatevars(get(hObject, 'String'));

usePrevVal = 1;
if isempty(errStr), 
    val=double(val);
    size_val = size(val);
    if ~isreal(val)
        uiwait(errordlg('The TRAINING SET must be non-complex.','VQ Demo','modal'));
    elseif size_val(1)~=2 || size_val(2)<2, % min size=1x2
        uiwait(errordlg('The TRAINING SET must have two rows and at least two columns.','VQ Demo','modal'));
    else  
       usePrevVal = 0;
       ud.TS = [];ud.TS = val;        
       ud.TS_str = get(hObject, 'String');
       axes(handles.plotVoronoi);  
       vqplot_training(handles, val); 
      
       %to find Count for each initCodeWord call mex
        [finCB, Err, countTSinCells] = dspvqdemomex(ud.TS, ud.initCB);% get countTSinCells
		axes(handles.plotHistogram);
		vqplot_histogram(handles, countTSinCells);

    end
else
    errStr = strcat(errStr,' (Error from TRAINING SET edit box.)');
    uiwait(errordlg(errStr,'VQ Demo','modal'));
end    
if (usePrevVal == 1)
    set(hObject,'String',ud.TS_str);
end    
set(hfig,'UserData',ud);


% --------------------------------------------------------------------
function popupStopCri_Callback(hObject, eventdata, handles)

val = get(hObject,'Value');
if (val==1)%% stop-criteria: Threshold
	setenableprop([handles.textMaxIter   handles.editMaxIter],    'off');
    setenableprop([handles.textRelTh     handles.editRelTh],    'on');
    editRelTh_Callback(handles.editRelTh, eventdata, handles);% update ud.MaxIter   
elseif (val==2)%% stop-criteria: MaxIter 
	setenableprop([handles.textRelTh     handles.editRelTh],    'off');
    setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
    editMaxIter_Callback(handles.editMaxIter, eventdata, handles);% update ud.MaxIter       
else%% stop-criteria: Threshold || MaxIter 
	setenableprop([handles.textRelTh     handles.editRelTh],    'on');
    editRelTh_Callback(handles.editRelTh, eventdata, handles);% update ud.MaxIter  
    setenableprop([handles.textMaxIter   handles.editMaxIter],    'on');
    editMaxIter_Callback(handles.editMaxIter, eventdata, handles);% update ud.MaxIter 
end   

% --------------------------------------------------------------------
function dspvqtwodim_WindowButtonDownFcn(hObject, eventdata, handles)

if ~strcmp(get(handles.editTS,'enable'), 'inactive')
hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
ud.leftButtonDownOnVorPlot  = 0;
ud.rightButtonDownOnVorPlot = 0;
ud.CWidxHighlighted = 0;

x_yMouse =get(hObject,'currentpoint');
xMouse=x_yMouse(1);yMouse=x_yMouse(2);
VorPos  = get(handles.plotVoronoi,'position'); 
HistPos = get(handles.plotHistogram,'position'); 

% Do nothing if we're not within the axes
if  (xMouse>=VorPos(1) & xMouse<= VorPos(1)+VorPos(3) & ...
     yMouse>=VorPos(2) & yMouse<= VorPos(2)+VorPos(4) ), 
			hVoronoi = handles.plotVoronoi;
            hCB = flipud(findobj(hVoronoi,'Tag','Codebook'));
			[X_cb, Y_cb] = getCurrentCodebookOnGraph(hCB);
			
			% find the nearest codeword closest to (by +-0.1 unit) mouse pointer (for tie take lower)
			[xMouseWRTplot, yMouseWRTplot] = getMousePositionWRTplot(x_yMouse, hVoronoi);
			
			d = abs(X_cb-xMouseWRTplot) + abs(Y_cb-yMouseWRTplot);
			[dmin,j] = min(d);;% min function obeys 'lower' tie-break rule
			if (dmin < 0.2) % 0.2 should depend on range
                ud.CWidxHighlighted = j;
                btype = get(hObject,'SelectionType');
                set(hCB(j), 'LineWidth', 2);
                
                if (isequal(btype,'alt')) % mouse right button pressed
					ud.rightButtonDownOnVorPlot = 1;
                    %%%
                    hHist = handles.plotHistogram;
                    hBar = flipud(findobj(hHist,'Tag','Bar'));
                    set(hBar(j), 'LineWidth', 2);
                    %%%
					plotRangeX = get(hVoronoi,'XLim'); dx = diff(plotRangeX);
					plotRangeY = get(hVoronoi,'YLim'); dy = diff(plotRangeY);
					% show the text
					hText=handles.textRightClickVorPlot;
					txt = sprintf('Codeword = [%1.2f,%1.2f]\nCodeword Index# %d', X_cb(j),Y_cb(j),j);
					pos= get(hText,'position');
					pos(1) = xMouse; pos(2) =  yMouse-pos(4);
					if pos(2) < VorPos(2), pos(2) = pos(2) + pos(4); end
					if pos(1) + pos(3) > VorPos(1) + VorPos(3), pos(1) = pos(1) - pos(3); end
					set(hText,'position',pos,'string',txt,'visible','on'); 
                else        
                    ud.leftButtonDownOnVorPlot = 1;
                end
			end  
elseif  (xMouse>=HistPos(1) & xMouse<= HistPos(1)+HistPos(3) & ...
         yMouse>=HistPos(2) & yMouse<= HistPos(2)+HistPos(4) ),   

      btype = get(hObject,'SelectionType');
      if (isequal(btype,'alt')) % mouse right button pressed 
      	    hHist = handles.plotHistogram;
            hBar = flipud(findobj(hHist,'Tag','Bar'));
			[X_hist, Y_hist] = getCurrentCountOnHistGraph(hBar);
			
			% find the nearest codeword closest to (by +-0.1 unit) mouse pointer (for tie take lower)
			[xMouseWRTplot, yMouseWRTplot] = getMousePositionWRTplot(x_yMouse, hHist);
			% a codeword having index 9 and count 56: bar at 8.5 to 9.5 and bar height 56
            % a mouse having  8.5<= x < 9.5 (half BW=0.5) and y<=56 + 3percent of max count, is considered
			d = abs(X_hist-xMouseWRTplot);% + abs(Y_cb-yMouseWRTplot);
			[dmin,j] = min(d);% min function obeys 'lower' tie-break rule
            MouseIsForJthBar = dmin < 0.5  & (yMouseWRTplot <= Y_hist(j) + 0.03*max(Y_hist));
			if (MouseIsForJthBar) % 0.5 should depend on range
				ud.BARidxHighlighted = j;
				set(hBar(j), 'LineWidth', 2);
				ud.rightButtonDownOnHistPlot = 1;
				plotRangeX = get(hHist,'XLim'); dx = diff(plotRangeX);
				plotRangeY = get(hHist,'YLim'); dy = diff(plotRangeY);
				% show the text
				hVoronoi = handles.plotVoronoi;
				hCB = flipud(findobj(hVoronoi,'Tag','Codebook'));
                %%%
                set(hCB(j), 'LineWidth', 2);
                %%%
				[X_cb, Y_cb] = getCurrentCodebookOnGraph(hCB);
				hText=handles.textRightClickHistPlot;
				txt = sprintf('# of TS vectors = %d\nCodeword = [%1.2f,%1.2f]\nCodeword Index# %d', Y_hist(j), X_cb(j),Y_cb(j),j);
				pos= get(hText,'position');
				pos(1) = xMouse; pos(2) =  yMouse-pos(4);
				if pos(2) < HistPos(2), pos(2) = pos(2) + pos(4); end
				if pos(1) + pos(3) > HistPos(1) + HistPos(3), pos(1) = pos(1) - pos(3); end
				set(hText,'position',pos,'string',txt,'visible','on'); 
			end  
         end
end     
set(hfig,'UserData',ud);
end

% --------------------------------------------------------------------
function dspvqtwodim_WindowButtonMotionFcn(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
if (ud.leftButtonDownOnVorPlot)% nothing to do for ud.rightButtonDownOnVorPlot==1
    % ud.leftButtonDownOnVorPlot==0 <-- do not reset here
    hVoronoi = handles.plotVoronoi;
    hCB = flipud(findobj(hVoronoi,'Tag','Codebook'));
    x_yMouse =get(hObject,'currentpoint');
    [xMouseWRTplot, yMouseWRTplot] = getMousePositionWRTplot(x_yMouse, hVoronoi);
    plotRangeX = get(hVoronoi,'XLim'); 
    plotRangeY = get(hVoronoi,'YLim'); 
    set(hCB(ud.CWidxHighlighted), 'XData',min(plotRangeX(2),max(plotRangeX(1),xMouseWRTplot)), ...
                                  'YData',min(plotRangeY(2),max(plotRangeY(1),yMouseWRTplot)));
end    

% --------------------------------------------------------------------
function dspvqtwodim_WindowButtonUpFcn(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
hCB = flipud(findobj(handles.plotVoronoi,'Tag','Codebook'));
if (ud.leftButtonDownOnVorPlot)
    set(hCB(ud.CWidxHighlighted), 'LineWidth', 1);%restore original line width of the codeword
    ud.leftButtonDownOnVorPlot = 0;
    set(hfig,'UserData',ud);
    % update Voronoi cells
    [X_cb, Y_cb] = getCurrentCodebookOnGraph(hCB);
    codebook = [X_cb'; Y_cb'];
    %we should update ud.initCB and ud.numLevel here and use option 'from graph' for initCB
    vqplot_voronoi(handles, codebook, 0);% 0 for NOT firstTime
    %update the histogram
	%to find Count for each initCodeWord call mex
    [finCB, Err, countTSinCells] = dspvqdemomex(ud.TS, codebook);
	set(hfig, 'CurrentAxes', handles.plotHistogram); %axes(handles.plotHistogram);
	vqplot_histogram(handles, countTSinCells);
elseif (ud.rightButtonDownOnVorPlot)  
    set(hCB(ud.CWidxHighlighted), 'LineWidth', 1);
    %%%
    hHist = handles.plotHistogram;
    hBar = flipud(findobj(hHist,'Tag','Bar'));
    set(hBar(ud.CWidxHighlighted), 'LineWidth', 1);
    %%%
    ud.rightButtonDownOnVorPlot = 0;
    set(hfig,'UserData',ud);
    hText=handles.textRightClickVorPlot;
    set(hText,'visible','off'); 
end   
if(ud.rightButtonDownOnHistPlot)
    hHist = handles.plotHistogram;
    hBar = flipud(findobj(hHist,'Tag','Bar'));    
    set(hBar(ud.BARidxHighlighted), 'LineWidth', 1);
    %%%
    set(hCB(ud.BARidxHighlighted), 'LineWidth', 1);
    %%%
    ud.rightButtonDownOnHistPlot = 0;
    set(hfig,'UserData',ud);
    hText=handles.textRightClickHistPlot;
    set(hText,'visible','off');     
end    

% --------------------------------------------------------------------
function [x,y] = getCurrentCodebookOnGraph(hVoronoi)

x = get(hVoronoi,'XData');
x = cat(1,x{:});
y = get(hVoronoi,'YData');
y = cat(1,y{:});

% --------------------------------------------------------------------
function [x,y] = getCurrentCountOnHistGraph(hHist)

y = get(hHist,'YData');
if length(y{1})>1
 y=cat(2,y{:});
 y=y(2,:);
else 
 y=cat(1,y{:});
 y=reshape(y,1,length(y));
end
 x=1:length(y);

% --------------------------------------------------------------------
function [xMouseWRTplot, yMouseWRTplot] = getMousePositionWRTplot(x_yMouse, hObject)

xMouse=x_yMouse(1);yMouse=x_yMouse(2);
PlotPos = get(hObject,'position');
plotRangeX = get(hObject,'XLim'); dx = diff(plotRangeX);
plotRangeY = get(hObject,'YLim'); dy = diff(plotRangeY);

%convert xMouse, yMouse to PlotPos's unit
% xMouse, yMouse have the unit of PlotPos;
% PlotPos(3) corresponds to plotRangeX; 
% so, xMouse-PlotPos(1)   corresponds to, plotRangeX*(xMouse-PlotPos(1))/PlotPos(3);
xMouseWRTplot = plotRangeX(1) + dx*(xMouse-PlotPos(1))/PlotPos(3);
yMouseWRTplot = plotRangeY(1) + dy*(yMouse-PlotPos(2))/PlotPos(4);

% --------------------------------------------------------------------
function pushbutnStop_Callback(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
ud.stopButtonPressed = 1;
ud.pauseButtonPressed = 0; %reset it
set(hfig,'UserData',ud);
setenableprop([handles.pushbutnStart], 'on');
setenableprop([handles.pushbutnPause],  'off');
setenableprop([handles.pushbutnResume],  'off');

setenableprop([hObject], 'off');

setenableprop([handles.pushbutnStart], 'on');
setenableprop([handles.pushbutnPause],  'off');
setenableprop([handles.pushbutnResume],  'off');
for i=1:length(ud.neededHandles)
  set (ud.neededHandles(i), 'enable', ud.enableHandleInfo{i}); 
end   

% --------------------------------------------------------------------
function pushbutnPause_Callback(hObject, eventdata, handles)

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
ud.pauseButtonPressed = 1;
ud.stopButtonPressed = 0; %reset it
set(hfig,'UserData',ud);
setenableprop([hObject],  'off');
setenableprop([handles.pushbutnResume],  'on');

% --------------------------------------------------------------------
function pushbutnResume_Callback(hObject, eventdata, handles)

setenableprop([hObject],  'off');
setenableprop([handles.pushbutnPause],  'on');

hfig=handles.dspvqtwodim;
ud=get(hfig,'UserData');
    ud.pauseButtonPressed = 0; %reset it
    ud.stopButtonPressed = 0; %reset it
set(hfig,'UserData',ud);   
GLAandUpdatePlots(handles, ud.ith_initCodebook, ud.ith_initIterValue, ud.ith_PrevErr, ud.ith_PrevErrArray);

