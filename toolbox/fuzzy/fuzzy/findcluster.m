function findcluster(action);
% FINDCLUSTER  Cluster interface.
%   FINDCLUSTER lets you use two clustering algorithms interactively.
%   It contains subtractive clustering and fuzzy c-means clustering.
%   FINDCLUSTER is a GUI tool which implements fcm and subcluster
%   along with all of their options on a user interface. Data is entered using 
%   the Load Data button, and Save will save the cluster center.
%   This tool works on multi-dimensional data sets, but only displays on two
%   dimensions. Use the pulldown tabs under X-axis and Y-axis to select which 
%   data dimension you want to view.                              
%
%    See also SUBCLUST, FCM.

%   Kelly Liu, Feb. 97
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.15.2.2 $  $Date: 2004/04/10 23:15:24 $

filename='';
if nargin<1,
    action='initialize';
else
   if ~strcmp(action(1), '#') 
    filename=action;
    action='initialize';
   else
    action=action(2:end);
   end;
end;

switch action
 case 'initialize',
    figNumber=figure( ...
         'Name','Clustering', ...
         'NumberTitle','off', ...
         'DockControls', 'off');          %, ...
%         'HandleVisibility','callback');
   axHndl=axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.25 0.65 0.7],...
        'Tag', 'mainaxes');
   set(get(axHndl, 'Xlabel'), 'String', 'X');
   set(get(axHndl, 'Ylabel'), 'String', 'Y');
%    rotate3d on;

    %===================================    
    right=0.75;
    bottom=0.05;
    labelHt=0.03;
    spacing=0.005;
    frmBorder=0.012;

   %====================================
    % Information for all buttons    
    left=0.80;
    btnWid=0.15;
    top=.5;

    %=========The Panel frame============
    frmBorder=0.02;
    yPos=0.05-frmBorder;
    frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
    frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', '');

    %=========The Slide frame=============
    frmBorder=0.02;
    btnHt=0.05;
    yPos=top+.4;
 
    %=========The display dimesion============
     btnPos=[.11 .095 .1 .05];
     dimsHndl=LocalBuildUi(btnPos, 'text', '',...
                           'X-axis', 'dimXLabel');
     set(dimsHndl, 'BackGroundColor', [.8 .8 .8]);

     btnPos=[.46 .095 .1 .05];
     dimsHndl=LocalBuildUi(btnPos, 'text','',...
                           'Y-axis', 'dimYLabel');
     set(dimsHndl, 'BackGroundColor', [.8 .8 .8]);
%     btnPos=[.5 .14 .1 .05];
%     dimsHndl=LocalBuildUi(btnPos, 'text', '',...
%                           'Z axes', 'dimZLabel');
%     set(dimsHndl, 'BackGroundColor', [.7 .7 .7]);
    
     btnPos=[.2 .1 .15 .05];
     dimsHndl=LocalBuildUi(btnPos, 'popupmenu', 'findcluster #dispdim', 'data_1', 'dimX');
     btnPos=[.55 .1 .15 .05];
     dimsHndl=LocalBuildUi(btnPos, 'popupmenu', 'findcluster #dispdim', 'data_1', 'dimY');
%     btnPos=[.6 .14 .1 .05];
%     dimsHndl=LocalBuildUi(btnPos, 'popup', 'findcluster #dispdim', 'x1', 'dimZ');
     btnPos=[.1 .02 .65 .07];
     dimsHndl=LocalBuildFrmTxt(btnPos, '', 'frame', '');
     btnPos=[.11 .03 .63 .05];
     dimsHndl=LocalBuildUi(btnPos, 'text', '', 'ready', 'status');
     set(dimsHndl, 'BackgroundColor', [.8 .8 .8]);
    %======The start button=============
    delHndl=LocalBuildBtns( 'Pushbutton', 10,'Start', 'findcluster #start', 'start');
    set(delHndl, 'Enable', 'off');
    
    %=======The Open button==============
    addHndl=LocalBuildBtns( 'Pushbutton', 1, 'Load Data...', 'findcluster #open', 'open');
    
    %======The Method=============
    btnPos=[left yPos-.05 btnWid btnHt];
    dimDHndl=LocalBuildBtns('text', 2, 'Methods', '', 'methodlabel');
    set(dimDHndl, 'BackgroundColor', [.5 .5 .5]);
    delHndl=LocalBuildBtns( 'PopupMenu', 2.5, {'subtractiv', 'fcm'}, 'findcluster #method', 'method');

    %=======The # of cluster/influence==============
       
    dimDHndl=LocalBuildBtns('text', 3.5, 'Cluster Num.', '', 'clstrNumlabel');
    dimDHndl=LocalBuildBtns('text', 3.5, 'Influence Range', '', 'sbtrparam');
   
    addHndl=LocalBuildBtns( 'edit', 4., '2', 'findcluster #setclstrnum', 'setclstrnum');
    saveHndl=LocalBuildBtns( 'edit', 4., '.5', 'findcluster #setparam', 'influence');
    %=======The param button==============
    dimDHndl=LocalBuildBtns('text', 5, 'Max Iteration#', '', 'clstrNumlabel');
    dimDHndl=LocalBuildBtns('text', 5, 'Squash', '', 'sbtrparam');

    saveHndl=LocalBuildBtns( 'edit', 5.5, '100', 'findcluster #setparam', 'maxitera');
    saveHndl=LocalBuildBtns( 'edit', 5.5, '1.25', 'findcluster #setparam', 'squash');

    dimDHndl=LocalBuildBtns('text', 6.5, 'Min. Improvement', '', 'clstrNumlabel');
    dimDHndl=LocalBuildBtns('text', 6.5, 'Accept Ratio', '', 'sbtrparam');

    saveHndl=LocalBuildBtns( 'edit', 7, '1e-5', 'findcluster #setparam', 'minimprove');
    saveHndl=LocalBuildBtns( 'edit', 7, '.5', 'findcluster #setparam', 'accept');

    dimDHndl=LocalBuildBtns('text', 8, 'Exponent', '', 'clstrNumlabel');
    dimDHndl=LocalBuildBtns('text', 8, 'Reject Ratio', '', 'sbtrparam');

    saveHndl=LocalBuildBtns( 'edit', 8.5, '2.0', 'findcluster #setparam', 'exponent');
    saveHndl=LocalBuildBtns( 'edit', 8.5, '.15', 'findcluster #setparam', 'reject');

    %=======The Save button==============
    saveHndl=LocalBuildBtns( 'Pushbutton', 11, 'Save Center...', 'findcluster #save', 'save');
    set(saveHndl, 'Enable', 'off');
    %=======The clear button==============
    Hndl=LocalBuildBtns( 'Pushbutton', 12, 'Clear Plot', 'cla', 'cla');
        
    %=======The Info button==============
    infoHndl=LocalBuildBtns( 'Pushbutton', 0, 'Info', 'findcluster #info', 'info');

    %=======The Close button=============
    closeHndl=LocalBuildBtns( 'Pushbutton', 0, 'Close', 'close(gcf)', 'close');
    TextHndl=uicontrol('Style', 'text', 'Unit', 'normal',...
                      'Visible', 'off',...
                      'Position', [0 0 .1 .020], 'Tag', 'strcparam');

    % Now uncover the figure
    param.dataDim=1;
    param.dispList=[];
    param.data=[];
    param.center=[];
    param.centerplotH=[];
    param.inputparam={'.5', '1.25', '.5', '.15'};
    LocalButtonControl;
    set(figNumber, 'Userdata', param);
    set(figNumber,'Visible','on');
    if ~isempty(filename)
       localloadfile(filename, param);
    end
%========display dimesions
case 'dispdim',
   cla
   dimHndl=findobj(gcf, 'Type', 'uicontrol', 'Tag', 'dimX');
   x=get(dimHndl, 'Value');
   dimHndl=findobj(gcf, 'Type', 'uicontrol', 'Tag', 'dimY');
   y=get(dimHndl, 'Value');
%   dimHndl=findobj(gcf, 'Type', 'uicontrol', 'Tag', 'dimZ');
%   z=get(dimHndl, 'Value');

   dispList=[x, y];              %, z];
   LocalPlotdata(dispList);
%=======select subtractive or fcm======
case 'method',
   LocalButtonControl;
%=======start clustering========
case 'start',
   param=get(gcbf, 'Userdata');
   stopHndl=findobj(gcbf, 'Tag', 'start');
   statusHndl=findobj(gcbf, 'Tag', 'status');

   stopflag=get(stopHndl, 'String');
   if strcmp(stopflag, 'Stop')
     set(stopHndl, 'String', 'Start');
   else
     set(stopHndl, 'String', 'Stop');

     medHndl=findobj(gcbf, 'Type', 'uicontrol', 'Tag', 'method');
     n=get(medHndl, 'value');
     %=========subtractive
     if n==1
      radiHndl=findobj(gcbf, 'Tag', 'influence');
      squaHndl=findobj(gcbf, 'Tag', 'squash');
      accpHndl=findobj(gcbf, 'Tag', 'accept');
      rejeHndl=findobj(gcbf, 'Tag', 'reject');

      inputparam=get(radiHndl, 'String');
      radioList=str2double(inputparam);
      if ~isempty(radioList)
         if length(radioList) < size(param.data, 2)
            radioList(end+1:size(param.data, 2))=radioList(end);
         elseif length(radioList) > size(param.data, 2)
            radioList(size(param.data, 2)+1, end) = [];
         end
      end     
      squafactor=get(squaHndl, 'String');
      acceptfact=get(accpHndl, 'String');
      rejectfact=get(rejeHndl, 'String');
      set(statusHndl, 'String', 'processing clustering...');
      [center, sigmas]=subclust(param.data, radioList, [],...
                                [str2double(squafactor), str2double(acceptfact), str2double(rejectfact), 0]);
      set(statusHndl, 'String', 'ready');
   %=========fcm=============
   else
      paramHndl=findobj(gcbf, 'Tag', 'setclstrnum');
      maxiHndl=findobj(gcbf, 'Tag', 'maxitera');
      miniHndl=findobj(gcbf, 'Tag', 'minimprove');
      expoHndl=findobj(gcbf, 'Tag', 'exponent');
      options=[str2double(get(expoHndl, 'String')), str2double(get(maxiHndl, 'String')),...
              str2double(get(miniHndl, 'String')), 0];
      cluster_n=str2double(get(paramHndl, 'String'));
      data_n = size(param.data, 1);
      in_n = size(param.data, 2);

      expo = options(1);		% Exponent for U
      max_iter = options(2);		% Max. iteration
      min_impro = options(3);		% Min. improvement
      display = options(4);		% Display info or not

      obj_fcn = zeros(max_iter, 1);	% Array for objective function

      U = initfcm(cluster_n, data_n);			% Initial fuzzy partition
if ~isempty(param.centerplotH)
set(param.centerplotH, 'Xdata', [],...
                                 'Ydata', [],...
                                 'Zdata', []);      % Main loop
 drawnow
end
      for i = 1:max_iter,
	[U, center, obj_fcn(i)] = stepfcm(param.data, U, cluster_n, expo);
        if strcmp(get(stopHndl, 'String'), 'Start')
            break;
        end

        set(statusHndl, 'String',...
             ['Iteration count = ' num2str(i) ' obj. fcn = ' num2str(obj_fcn(i))]);
        if isempty(param.centerplotH)
          param.center=center;
          set(gcbf, 'UserData', param);
          findcluster #dispdim
          param=get(gcbf, 'Userdata');

        else
          set(param.centerplotH, 'Xdata', center(:,param.dispList(1)),...
                                 'Ydata', center(:,param.dispList(2)));         
%                                 'Zdata', center(:,param.dispList(3)));
          drawnow
         
        end
	% check termination condition
	if i > 1,
		if abs(obj_fcn(i) - obj_fcn(i-1)) < min_impro, break; end,
	end
      end
%============ 
%%        maxU = max(U);
%%        color=['c', 'g', 'b', 'r', 'm'];
%%        for i = 1:cluster_n,
%%            index = find(U(i, :) == maxU);
%%            cluster = param.data(index', :);
%%            if isempty(cluster), cluster = [nan nan]; end
%            hold on
%%            line('xdata', cluster(:, 1), ...
%%                'ydata', cluster(:, 2),...                     % 'zdata', cluster(:, 3),...
%%                'linestyle', 'none', 'color', color(mod(i, 5)+1),...
%%                'marker', '*');
%%        end
        drawnow
%=====================

   end
   set(stopHndl, 'String', 'Start');
 
   param.center=center;
   if ~isempty(center)
         saveHndl = findobj(gcf, 'Tag', 'save');
         set(saveHndl, 'Enable', 'on');
   end

   set(gcbf, 'UserData', param);
   findcluster #dispdim
 end %if stopHndl
case 'open',
% open an existing file
    param=get(gcbf,'UserData'); 
    [fname, fpath]=uigetfile('*.dat'); 
     
    if isstr(fname)&isstr(fpath)
%       cd(fpath(1:(length(fpath)-1)));
       filename=[fpath fname];
       localloadfile(filename, param);
   end
case 'save',
    param= get(gcf, 'Userdata');
    [fname, fpath]=uiputfile('*.dat', 'Save As'); 
    center = param.center; 
    if isstr(fname)&isstr(fpath)
       save([fpath fname], 'center', '-ascii', '-double');
    end
case '#mousedownstr'
   patchHndl=gco;
   showStr=get(patchHndl, 'Tag');
   showPosx = get(patchHndl, 'XData');
   showPosy = get(patchHndl, 'YData');
   textHndl=findobj(gcf, 'Tag', 'strcparam');
   a=100;
   set(textHndl,'String', 'test', 'Position', [showPosx(1) showPosy(1) .2 .080], 'Visible', 'on');
   
case 'info',

    helpwin(mfilename)       

end;    % if strcmp(action, ...
% End of function makeshow


%===================================
function LocalButtonControl
   medHndl=findobj(gcf, 'Tag', 'method');
   clustnumHndl=findobj(gcf, 'Tag', 'setclstrnum');
   infuHndl=findobj(gcf, 'Tag', 'influence');
   squaHndl=findobj(gcf, 'Tag', 'squash');
   accpHndl=findobj(gcf, 'Tag', 'accept');
   rejcHndl=findobj(gcf, 'Tag', 'reject');

   expoHndl=findobj(gcf, 'Tag', 'influence');
   maxiHndl=findobj(gcf, 'Tag', 'squash');
   miniHndl=findobj(gcf, 'Tag', 'accept');
   numHndl=findobj(gcf,  'Tag', 'reject');


   sbtrLabelHndl=findobj(gcf, 'Tag', 'sbtrparam');
   n=get(medHndl, 'value');
   
   if n==1
      set(sbtrLabelHndl, 'Visible', 'on');
      set(infuHndl, 'Visible', 'on');
      set(squaHndl, 'Visible', 'on');
      set(accpHndl, 'Visible', 'on');
      set(rejcHndl, 'Visible', 'on');
      
      set(clustnumHndl, 'Visible', 'off');
   else
      set(sbtrLabelHndl, 'Visible', 'off');
      set(infuHndl, 'Visible', 'off');
      set(squaHndl, 'Visible', 'off');
      set(accpHndl, 'Visible', 'off');
      set(rejcHndl, 'Visible', 'off');
     
      set(clustnumHndl, 'Visible', 'on');
   end  
   
   
%==================================================
function uiHandle=LocalBuildUi(uiPos, uiStyle, uiCallback, promptStr, uiTag)
% build editable text 
    uiHandle=uicontrol( ...
        'Style',uiStyle, ...
        'HorizontalAlignment','left', ...
        'Units','normalized', ...
        'Max',20, ...
        'BackgroundColor',[1 1 1], ...
        'Position',uiPos, ...
        'Callback',uiCallback, ... 
        'Tag', uiTag, ...
        'String',promptStr);

%==================================================
function frmHandle=LocalBuildFrmTxt(frmPos, txtStr, uiStyle, txtTag)
% build frame and label
      frmHandle=uicontrol( ...
        'Style', uiStyle, ...
        'Units','normalized', ...
        'Position',frmPos, ...
        'BackgroundColor',[0.50 0.50 0.50], ...
        'ForegroundColor',[1 1 1], ...                  %generates an edge
        'String', txtStr, ...
        'Tag', txtTag);

%==================================================
function btHandle=LocalBuildBtns(thisstyle, btnNumber, labelStr, callbackStr, uiTag)
% build buttons or check boxes so they easily aline on the right

labelColor=[0.8 0.8 0.8];
top=0.95;
left=0.80;
btnWid=0.15;
btnHt=0.05;
bottom=0.05;
% Spacing between the button and the next command's label
spacing=0.01;
if strcmp(thisstyle, 'edit')
  % btnHt =.05;
end
   
yPos=top-(btnNumber-1)*(btnHt+spacing);
if strcmp(labelStr, 'Close')==1
   yPos= bottom;
elseif strcmp(labelStr, 'Info')==1
   yPos= bottom+btnHt+spacing; 
else
   yPos=top-(btnNumber-1)*(btnHt+spacing)-btnHt;
end
%button information
btnPos=[left yPos btnWid btnHt];
btHandle=uicontrol( ...
   'Style',thisstyle, ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'Tag', uiTag, ...
   'Callback',callbackStr); 
if strcmp(thisstyle, 'text')
  set(btHandle, 'BackgroundColor', [.5 .5 .5], 'ForeGroundColor', [1 1 1]);
   end



function LocalPlotdata(dispList)
     param=get(gcf, 'Userdata');
     param.dispList = dispList;
     axesHndl=findobj(gcf, 'Tag', 'mainaxes');
     axes(axesHndl);
%     cla     
      data=param.data;
      plotmarker = 'o';
      plotcolor='red';
 
      center=param.center;
      plotmarker1='.';
      plotcolor1='black';
      
 
   if param.dataDim > 1
      ydim=2;
   else
      ydim=1;
      end
   
      if ~isempty(data)
         dataplotH = line(data(:, dispList(1)), data(:, dispList(2)),...        %data(:, dispList(3)),...
            'color', plotcolor, ...
            'LineStyle', 'none',...
            'Marker', plotmarker,...
            'clipping', 'off'); 
      end
      if ~isempty(center)
         centerplotH = line(center(:, dispList(1)), center(:, dispList(2)),...       %center(:, dispList(3)),...
            'color', plotcolor1, ...
            'LineStyle', 'none', 'Marker', plotmarker1,...
            'MarkerSize', 16,...
            'ButtonDownFcn', 'findcluster #mousedownstr',...
            'clipping', 'off', 'erase', 'none'); 
         param.centerplotH=centerplotH;
         set(gcbf, 'Userdata', param);
      end
      drawnow

function localloadfile(filename, param)
       load(filename);
       slashindex=find(filename==filesep);
       if ~isempty(slashindex)
           strtindex=max(slashindex)+1;
       else
           strtindex=1;
       end
       dotIndex=find(filename=='.');
       varname=filename(strtindex:dotIndex-1);
       data=eval(varname);
       
       param.data=data;
       param.dataDim = size(data, 2);
       param.center=[];
       if param.dataDim>1
         dispList = [1 2];                                %[1 2 2];
         dimHndlx=findobj(gcf, 'Tag', 'dimX');
         dimHndly=findobj(gcf, 'Tag', 'dimY');
%         dimHndlz=findobj(gcf, 'Tag', 'dimZ');
         for i=1:param.dataDim
          dispstr{i}=['data_' num2str(i)];
         end
         set(dimHndlx, 'String', dispstr);
         set(dimHndly, 'String', dispstr);
%         set(dimHndlz, 'String', dispstr);

%         if param.dataDim > 2
%          dispList(3)=3;
%          set(dimHndlz, 'Value', 3);         
%         end

         set(dimHndly, 'Value', 2);

       else
         dispList = [1 1];                             %[1 1 1];
       end
       if ~isempty(data)
         startHndl = findobj(gcf, 'Tag', 'start');
         set(startHndl, 'Enable', 'on');
       end
       if isempty(param.center)
         saveHndl = findobj(gcf, 'Tag', 'save');
         set(saveHndl, 'Enable', 'off');
       end
       param.dispList = dispList;
       set(gcf, 'Userdata', param);
   
       LocalPlotdata(dispList);




