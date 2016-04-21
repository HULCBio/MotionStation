function anfisedit(action);
% anfisedit  Make anfis interface.
%

%   Kelly Liu, Dec. 96
%   Copyright 1994-2001 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2001/09/11 12:51:00 $

if nargin<1,
   % Open up an untitled system.
   newFis=newfis('Untitled', 'sugeno');
   newFis=addvar(newFis,'input','input1',[0 1],'init');
   newFis=addvar(newFis,'output','output1',[0 1],'init');
   action=newFis;
end

if isstr(action),
   if action(1)~='#',
      % The string "action" is not a switch for this function, 
      % so it must be a disk file
      fis=readfis(action);
      fis.inNum=length(fis.input);
      fis.outNum=length(fis.output);
      action='#initialize';
   end
else
   % For initialization, the fis matrix is passed in as the parameter
   fis=action;
   action='#initialize';
end;

if strcmp(action,'#initialize'),
   for i=1:length(fis.input)
      numInputMFs(i)=length(fis.input(i).mf);
   end
   totalInputMFs=sum(numInputMFs);
   fisnodenum=length(fis.input)+2*totalInputMFs+2*length(fis.rule)+2+1;
   infoStr=['Number of nodes: ' num2str(fisnodenum)];
   
   fisName=fis.name;
   nameStr=['ANFIS TRAINING: ' fisName];
   figNumber=figure( ...
      'Name',nameStr, ...
      'Units', 'pixels', ...
      'NumberTitle','off', ...
      'MenuBar','none', ...
      'NumberTitle','off', ...
      'Tag', 'anfisedit',...
      'Userdata', fis,...
      'Visible','off');
   %        'Position', [232 118 560 420],...
   %======= create the menus standard to every GUI
   fisgui #initialize
   
   editHndl=findobj(figNumber,'Type','uimenu','Tag','editmenu');
   uimenu(editHndl,'Label','Undo', ...
      'Enable','off');
   
   axes( ...
      'Units','normalized', ...
      'Position',[0.10 0.55 0.65 0.415]);
   
   %===================================    
   left=0.03;
   right=0.75;
   bottom=0.05;
   labelHt=0.03;
   spacing=0.005;
   frmBorder=0.012;
   %======Set up the text Window==========
   top=0.5;    
   % First, the Text Window frame 
   frmPos=[.031 .115 .40 .361];
   frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', ''); 
   frmPos=[.449 .115 .52 .361];
   frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', ''); 
   frmPos=[.031 .0218 .756 .073];
   frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', ''); 
   % Then the text label
   left=.052;
   labelPos=[left .431 .360 .030];    
   lableHndl=LocalBuildFrmTxt(labelPos, 'ANFIS Information', 'text', 'lable2');
   % Then the editable text field
   mcwPos=[left .141 .361 .276]; 
   textHndl=LocalBuildUi(mcwPos, 'text', 'anfisedit #changetext', infoStr, 'Comments');
   
   %========Set up the Command Text Window ==================     
   % The text label
   labelPos=[.481 .417 .275 .042];    
   lableHndl=LocalBuildFrmTxt(labelPos, 'data from workspace', 'text', 'lable2');
   left=.464;
   width=.126;
   height=.046;
   left1=.609;
   width1=.144;
   height1=.046;
   labelPos=[left .325 width height];    
   mcwPos=[left1 .325 width1 height1];
   lableHandle=LocalBuildFrmTxt(labelPos, 'trndatin', 'text', 'lable1');
   % Then the editable text field
   
   mcwHndl=LocalBuildUi(mcwPos, 'edit', 'anfisedit #trndatin', '', 'trndatin');
   set(mcwHndl, 'Max', 1);
   % ========trndtout
   labelPos=[left .266 width height];    
   mcwPos=[left1 .266 width1 height1];
   lableHandle=LocalBuildFrmTxt(labelPos, 'trndatout', 'text', 'lable1');
   % Then the editable text field
   
   mcwHndl=LocalBuildUi(mcwPos, 'edit', 'anfisedit #trndatout', '', 'trndatout');
   set(mcwHndl, 'Max', 1);
   
   % ========chkdatin
   labelPos=[left .206 width height];    
   mcwPos=[left1 .206 width1 height1];
   lableHandle=LocalBuildFrmTxt(labelPos, 'chkdatout', 'text', 'lable1');
   % Then the editable text field
   mcwHndl=LocalBuildUi(mcwPos, 'edit', 'anfisedit #chkdatin', '', 'chkdatin');
   set(mcwHndl, 'Max', 1);
   
   % ========chkdtout
   labelPos=[left .143 width height];    
   mcwPos=[left1 .143 width1 height1];
   lableHandle=LocalBuildFrmTxt(labelPos, 'chkdatout', 'text', 'lable1');
   % Then the editable text field
   mcwHndl=LocalBuildUi(mcwPos, 'edit', 'anfisedit #chkdatout', '', 'chkdatout');
   set(mcwHndl, 'Max', 1);
   
   %========Set up the Status Window ==================     
   
   % Then the status text field
   mcwPos=[0.0491071428571429 0.0376984126984127 0.705357142857143 0.040];
   mcwHndl=LocalBuildUi(mcwPos, 'text', '', '', 'status');
   
   %====================================
   % Information for all buttons    
   left=0.80;
   btnWid=0.15;
   top=.55;
   
   %=========The Panel frame============
   frmBorder=0.02;
   frmPos=[left-frmBorder .524 btnWid+2*frmBorder .446];
   frmHandle=LocalBuildFrmTxt(frmPos, '', 'frame', '');
   
   %=========The Error frame=============
   frmBorder=0.02;
   btnHt=0.03;
   yPos=top+.31;
   btnPos=[0.78125 0.38492 0.15029 0.035];
   slideHandle=LocalBuildFrmTxt(btnPos, 'Error Limit', 'text', 'slide');
   %=========The Epoch frame=============
   yPos=top+.22;
   btnPos=[0.787202380952381 0.246031746031746 0.150297619047619 0.0376984126984127];
   slideHandle=LocalBuildFrmTxt(btnPos, 'Epochs', 'text', 'slide');
   %=========The tst frame=============
   yPos=top-.23;
   btnPos=[0.802083333333333 0.595 0.150297619047619 0.0297619047619048];
   slideHandle=LocalBuildFrmTxt(btnPos, 'Test', 'text', 'slide');
   %======Error Lim edit===================
   mcwPos=[0.785714285714286 0.30952380952381 0.150297619047619 0.0615079365079365];
   backHndl=LocalBuildUi(mcwPos, 'edit', 'anfisedit #errorlim','0',  'errlim');
   
   %======The epoch edit==============
   
   mcwPos=[0.790178571428571 0.16468253968254 0.150297619047619 0.0595238095238095];
   LocalBuildUi(mcwPos, 'edit', 'anfisedit #reset', '3',  'epoch');
   
   %=========The Start button============
   callbackStr='anfisedit #start';  
   nextHndl=LocalBuildBtns('pushbutton', 3, 'Start', callbackStr, 'startbtn');
   
   %======The Genfis button================
   newHndl=LocalBuildBtns('popupmenu', 2, {'grid genfis', 'cluster genfis'}, 'anfisedit #genfis', 'genfis');
   
   %======The New fis button=============
   delHndl=LocalBuildBtns('pushbutton', 4, 'FIS Struc.', 'anfisedit #plotstruc', 'plotstrc');
   
   %=======The Open Training set button==============
   addHndl=LocalBuildBtns('pushbutton', 1, 'OpenTrn...', 'anfisedit #opentrn', 'opentrn');
   
   %=======The Open test button==============
   %   saveHndl=LocalBuildBtns('pushbutton', 7, 'OpenTest...', 'anfisedit #opentst', 'opentst');
   
   %=======The Test button==============
   infoHndl=LocalBuildBtns('popupmenu', 5, {'Training', 'Testing'}, 'anfisedit #test', 'test');
   
   %=======The Close button=============
   closeHndl=LocalBuildBtns('pushbutton', 0, 'Close', 'fisgui #close', 'close');
   
   %====================================
   % The MENUBAR items
   % First create the menus standard to every GUI
   % Now uncover the figure
   set(figNumber,'Visible','on');
   LocalEnableBtns(fis);   
elseif strcmp(action,'#update'),
   %====================================
   figNumber=watchon;
   fis=get(figNumber,'UserData');
   % Clear the current variable plots and redisplay
   textHndl=findobj(gcf, 'Tag', 'Comments');
   %textstr=get(textHndl, 'String');
   textstr={['input number: ' num2str(length(fis.input)) 'output number: ' ...
            num2str(length(fis.output)) 'input mfs: ' num2str(getfis(fis, 'inmfs'))]};
   textstr={['input mfs: ' num2str(getfis(fis, 'inmfs'))]};
   set(textHndl, 'String', textstr);
   watchoff;
   %========start to train anfis==============
elseif strcmp(action,'#start'),
   fis=get(gcf, 'UserData');
   %  fis=fis(1);
   if ~isfield(fis, 'trndata')| isempty(fis.trndata(1))
      msgbox('no training data yet');
   elseif isempty(fis.input(1).mf)
      msgbox('No membership functions! Use mf editor or genfis button to generate membership functions');
   elseif ~isfield(fis, 'rule') | isempty(fis.rule)
      msgbox('No rules yet! Use rule editor or genfis button to generate rules.');
   else
      if isfield(fis, 'tstdata')
         testdata=fis.tstdata;
      else
         testdata=[];
      end
      cla;
      EpochHndl=findobj(gcf, 'Tag', 'epoch');
      numEpochs=str2double(get(EpochHndl, 'String'));
      if isempty(numEpochs)
         numEpochs=0;
      end
      txtHndl=findobj(gcf, 'Tag', 'status');
      stopHndl=findobj(gcf, 'Tag', 'startbtn');
      stopflag=get(stopHndl, 'String');
      if strcmp(stopflag, 'Start')
         set(stopHndl, 'String', 'Stop');
         errHndl=findobj(gcf, 'Tag', 'errline');
         errLimHndl=findobj(gcf, 'Tag', 'errlim');
         errlim=str2double(get(errLimHndl, 'String'));
         if isempty(errlim)
            errlim=0;
         end
         if isempty(errHndl)|length(get(errHndl, 'Xdata'))~=numEpochs
            if length(get(errHndl, 'Xdata'))~=numEpochs
               delete(errHndl)
            end
            errHndl=line([1:numEpochs], [1:numEpochs], 'linestyle', 'none',...
               'marker', '*', 'Tag', 'errline');
         end
         errvector=zeros(numEpochs,1);
      else
         set(stopHndl, 'String', 'Start');
      end
      fismat1=fis;
      if strcmp(stopflag, 'Start')
         for i=1:numEpochs
            [fismat1, trn_err]=anfis(fis.trndata, fismat1, 2, NaN, testdata, errHndl, stopHndl);
            errvector(i)=trn_err(1);
            set(errHndl, 'Ydata', errvector);
            drawnow
            txtStr={['Epoch ' num2str(i) ':error= ' num2str(trn_err(1))]};
            set(txtHndl, 'String', txtStr);
            stopflag=get(stopHndl, 'String');
            if strcmp(stopflag, 'Start')| trn_err(1)<=errlim
               break;
            end
         end   %end of if Satrt
         set(stopHndl, 'String', 'Start');
      end     % end of for loop
      fismat1.trndata=fis.trndata;
      if isfield(fis, 'tst.dat');
         fismat1.tstdata=fis.tstdata;
      end 
      %     newfis(1)=fismat1;
      %     newfis(2)=fis;
      
      set(gcf, 'UserData', fismat1);
      figNumber=watchon;
      updtfis(figNumber,fismat1,[6]);
      watchoff;
   end
   %========take training input data from commandline workspace
elseif strcmp(action,'#trndatin'),
   fis=get(gcf, 'UserData');
   trndatinHndl=findobj(gcf, 'Tag', 'trndatin');
   trndatinTxt=get(trndatinHndl, 'String');
   trnData=[];
   trnData=evalin('base', trndatinTxt, '[]');
   if isempty(trnData),
      msgbox('No such variable (or variable is empty)')
   else
      fis.trndata(:,1:length(fis.input))=trnData
   end   
   %========take training output data from commandline workspace
elseif strcmp(action,'#trndatout'),
   fis=get(gcf, 'UserData');
   trndatinHndl=findobj(gcf, 'Tag', 'trndatout');
   trndatinTxt=get(trndatinHndl, 'String');
   trnData=[];
   trnData=evalin('base', trndatinTxt, '[]');
   if isempty(trnData)
      msgbox(['no such variable ' trndatinTxt ' in workspace']);
   else   
      fis.trndata(:,length(fis.input)+1)=trnData
   end   
   %=======Auto generate anfis with gbell mf=====
elseif strcmp(action,'#genfis'),
   figNumber=gcf;
   fis=get(gcf,'UserData'); 
   if ~isfield(fis, 'trndata');
      msgbox('No Training Data for automatically generate fis membership functions');
   else
      trnData=fis.trndata;
      genHndl=findobj(figNumber, 'Tag', 'genfis');
      n=get(genHndl, 'Value');
      
      if n==1
         mfType=getfis(fis, 'inmftypes');
         
         param=inputdlg({'input mfs:'});
         
         inmflist=str2double(char(param));
         if ~isempty(inmflist)&length(inmflist)~=length(fis.input)
            inmflist(end+1:length(fis.input))=inmflist(end);
         end
         %mfType=questdlg('Mf type?', ...
         %                  'selece mf type', ...
         %                  'trimf','gbellm','gauss','trim');
         %%      figNumber=watchon;
         %%      dlgHndl=gfmfdlg(figNumber, fis, 'input', 1);
         %%      waitfor(dlgHndl)
         %%       watchoff(figNumber);
         if isempty(inmflist)
            inmflist=[2];
         end
         if isempty(mfType)|( size(mfType, 1)~=1 & size(mfType,1)~=size(fis.trndata,2)-1)
            mfType='gbellmf';
         end
         mfType
         fismat=genfis1(trnData, inmflist, mfType);
         fismat.type=fis.type;
         fismat.name=fis.name;
         fismat.andMethod = fis.andMethod;
         fismat.orMethod = fis.orMethod;
         fismat.defuzzMethod =fis.defuzzMethod;
         fismat.impMethod = fis.impMethod;
         fismat.aggMethod = fis.aggMethod;
      else
         fismat=genfis2(trnData(:,1), trnData(:,2), .2);
      end
      if isfield(fis, 'tstData')
         fismat.tstdata=fis.tstData;
      end 
      fismat.trndata=fis.trndata;
      
      textHndl=findobj(gcf, 'Tag', 'Comments');
      % textstr=get(textHndl, 'String');
      textstr=['input number: ' num2str(length(fis.input)) 'output number: ' num2str(length(fis.output))];
      set(textHndl, 'String', textstr);
      set(figNumber, 'Userdata', fismat);
      updtfis(figNumber,fismat,[6]);
      LocalEnableBtns(fismat);  
      
   end
   %=======plot anfis structure=========     
elseif strcmp(action,'#plotstruc'),
   fis=get(gcbf, 'Userdata');
   plotFig=findobj('type', 'figure', 'Name', 'Anfis Structure');
   
   if isempty(plotFig)
      plotFig=figure('Name', 'Anfis Structure',...
         'Unit', 'normal',...
         'WindowButtonDownFcn', 'anfisedit #showparam',...
         'WindowButtonUpFcn', 'anfisedit #clearparam',...
         'NumberTitle','off',...
         'Tag', 'plotstruc');
      axis off;
      
   end
   gcf=plotFig;
   TextHndl=uicontrol('Style',  'text', 'Unit', 'normal', 'Position', [0 0 .1 .020], 'Tag', 'strcparam');
   plotFigChild=get(plotFig, 'children');
   axHndl=[];
   for i=1:length(plotFigChild)
      if strcmp(get(plotFigChild(i), 'type'),'axes')
         axHndl = plotFigChild(i);
      end
   end
   if ~isempty(axHndl)
      axes(axHndl);
   end 
   set(gca, 'XLimMode', 'Manual', 'Xlim', [0 .8], 'Ylim', [-0.1 1]);
   pos=get(plotFig, 'Position');
   % str={'input', 'input mf', 'rules', 'output mf','', 'output'};
   
   %for i=1:6
   %    text(.1*i, -0.02, str(i));
   % end
   instep=1/(length(fis.input)+1);
   for i=1:length(fis.input)
      line([.1], [instep*i], 'marker', 'o', 'MarkerSize', 15, 'color', 'red');
      mfstep=instep/(length(fis.input(i).mf)+1);
      for j=1:length(fis.input(i).mf)
         line([.2], [(i-1/2)*instep+mfstep*j], 'marker', 'o', 'MarkerSize', 15, 'color', 'blue');
         line([.1 .2], [instep*i (i-1/2)*instep+mfstep*j], 'color', 'black');
      end  
   end
   rulestep=1/(length(fis.rule)+1);
   rulecolor={'blue', 'red'};
   for i=1:length(fis.rule)
      temp=rulestep*i;
      line([.3], [temp], 'marker', 'o', 'MarkerSize', 15, 'color', 'red');
      line([.4], [temp], 'marker', 'o', 'MarkerSize', 15, 'color', 'blue');
      line([.3 .4], [temp temp], 'color', 'black');
      line([.3 .4], [temp .05], 'color', 'black');
      conn=fis.rule(i).connection;
      for j=1:length(fis.rule(i).antecedent)
         ruleindex=fis.rule(i).antecedent(j);
         if ruleindex~=0
            if conn==-1 
               thiscolor='green';
            else
               thiscolor=rulecolor(conn);
            end
            mfstep=instep/(length(fis.input(j).mf)+1);
            line([.2 .3], [(j-1/2)*instep+mfstep*ruleindex rulestep*i], 'color', char(thiscolor));
         end
      end  
   end
   
   outstep=1/(length(fis.output)+1);
   for i=1:length(fis.output)
      line([.5], [outstep*i], 'marker', 'o', 'MarkerSize', 15, 'color', 'red');
      for j=1:length(fis.rule)
         line([.4 .5], [rulestep*j outstep*i], 'color', 'black');
      end
   end
   line([.4], [.05], 'marker', 'o', 'MarkerSize', 15, 'color', 'red');
   line([.6], [outstep*(i)/2], 'marker', 'o', 'MarkerSize', 15, 'color', 'red');
   line([.5 .6], [outstep*(i) outstep*(i)/2], 'color', 'red');
   line([.4 .6], [.05 outstep*(i)/2],'color', 'red');
   
   line ([.7 .75], [0.5 0.5], 'Color', 'red');
   text(.77, .49, 'and');
   line ([.7 .75], [.6 0.6], 'Color', 'blue');
   text(.77, .59, 'or');
   line ([.7 .75], [0.7 0.7], 'Color', 'green');
   text(.77, .69, 'not');
   %=======mouse down function for plotting structure=========
elseif strcmp(action, '#showparam'),
   FigNumber=findobj(0, 'Type', 'figure', 'Tag','anfisedit');
   fis=get(FigNumber, 'Userdata'); 
   plotFig=findobj('type', 'figure', 'Name', 'Anfis Structure');
   set(plotFig, 'Unit', 'normal');
   pt=get(gca,'currentpoint');
   x=pt(1,1);
   y=pt(1,2);
   
   instep=1/(length(fis.input)+1);
   showparam=0;
   showstr=[];
   for i=1:length(fis.input)
      if x>.1-.02 & x<.1+.02 & y>instep*i-.02 & y<instep*i+.02
         showparam=1;
         showstr=['Input ' num2str(i)];
         break;
      else
         mfstep=instep/(length(fis.input(i).mf)+1);
         for j=1:length(fis.input(i).mf)
            thisy=(i-1/2)*instep+mfstep*j;
            if x>.2-.02 & x<.2+.02 & y>thisy-.02 & y<thisy+.02
               showparam=1;
               showstr=['Input mf ' num2str(j) ' of input ' num2str(i) ' ' fis.input(i).mf(j).name];
               
               break;
            end
         end
      end   
   end
   rulestep=1/(length(fis.rule)+1);
   if showparam==0
      for i=1:length(fis.rule)
         temp=rulestep*i;
         if x>.3-.02 & x<.3+.02 & y>temp-.02 & y<temp+.02
            showparam=1;
            showstr=['rule ' num2str(i)];
            break
         elseif x>.4-.02 & x<.4+.02 & y>temp-.02 & y<temp+.02
            showparam=1;
            showstr=['output mf ' num2str(fis.rule(i).consequent(1))];
            break
         end
      end
   end
   if showparam==0
      
      outstep=1/(length(fis.output)+1);
      for i=1:length(fis.output)
         temp=outstep*i/2;
         if x>.6-.02 & x<.6+.02 & y>temp-.02 & y<temp+.02
            showparam=1;
            showstr=['output ' num2str(i)];
         end
      end
   end
   
   if showparam==1
      textHndl=findobj(plotFig, 'Tag', 'strcparam');
      set(textHndl,'String', showstr, 'Position', [x y .2 .080], 'Visible', 'on');
   end   
   %============== mouse up function for plotting structure===============
elseif strcmp(action, '#clearparam'),
   plotFig=findobj('type', 'figure', 'Name', 'Anfis Structure');
   textHndl=findobj(plotFig, 'Tag', 'strcparam');
   set(textHndl, 'Visible', 'off');
   %========open training set file================                
elseif strcmp(action,'#opentrn'),
   % open an existing file
   fis=get(gcbf,'UserData'); 
   if isempty(fis)
      msgbox(' No fuzzy system, specify input number and output number through fuzzy editor');
   else
      inNum=length(fis.input);
      outNum=length(fis.output);
      [fname, fpath]=uigetfile('*.dat'); 
      
      if isstr(fname)&isstr(fpath)
         fid=fopen([fpath fname]);
         trndata=fscanf(fid, '%f', [inNum+outNum,inf])';
         fis.trndata=trndata;
         trn_num=['Number of training data pairs: ' num2str(size(trndata,1))];
         textHndl=findobj(gcbf, 'Tag', 'Comments');
         %  textstr=get(textHndl, 'String');
         set(textHndl, 'String', trn_num);
         set(gcbf, 'UserData', fis); 
      end  
      LocalEnableBtns(fis);  
      
   end
elseif strcmp(action,'#opentst'),
   fis=get(gcf,'UserData'); 
   [fname, fpath]=uigetfile; 
   
   if isstr(fname)&isstr(fpath)
      fid=fopen([fpath fname]);
      tstdata=fscanf(fid, '%f', [length(fis.input)+length(fis.output),inf])';
      fis.tstdata=trndata;
      set(gcf, 'UserData', fis);   
   end
   
   
elseif strcmp(action,'#test'),
   fis=get(gcbf,'UserData');
   testHndl=findobj(gcbf, 'Tag', 'test');
   n=get(testHndl, 'Value');
   cla
   if n==1
      if isfield(fis, 'trndata')
         testdata=fis(1).trndata;
      else
         msgbox('no training data');
         testdata=[];
      end
   else
      if isfield(fis, 'tstdata')
         testdata=fis(1).tstdata;
      else
         msgbox('no testing data');
         testdata=[];
      end
      
   end
   if ~isempty(testdata)
      datasize=size(testdata, 1);
      inputnum=size(testdata, 2)-1;
      targetdata=fis(1).trndata(1:datasize, inputnum+1);
      testOut=evalfis(testdata(1:datasize, 1:inputnum), fis(1));
      targetlineHndl=line([1:datasize],targetdata, 'lineStyle', 'none', 'Marker', 'o'); 
      testlineHndl=line([1:datasize],testOut); 
   end
end;    % if strcmp(action, ...
% End of function anfisedit

%==================================================
function LocalEnableBtns(fis)
% control the enable property for buttons
startHndl = findobj(gcf, 'Tag', 'startbtn');

if ~isfield(fis, 'trndata')| isempty(fis.trndata(1)) 
   %| isempty(fis.input(1).mf)|...
   %      ~isfield(fis, 'rule') | isempty(fis.rule)
   set(startHndl, 'Enable', 'off');
else
   set(startHndl, 'Enable', 'on');
end

genHndl = findobj(gcf, 'Tag', 'genfis');

if ~isfield(fis, 'trndata')| isempty(fis.trndata(1))
   set(genHndl, 'Enable', 'off');
else
   set(genHndl, 'Enable', 'on'); 
end
plotHndl = findobj(gcf, 'Tag', 'plotstrc');
testHndl = findobj(gcf, 'Tag', 'test');
if  isempty(fis.input(1).mf) | ~isfield(fis, 'rule') | isempty(fis.rule)
   set(plotHndl, 'Enable', 'off');
   set(testHndl, 'Enable', 'off');
   
else
   set(plotHndl, 'Enable', 'on');
   set(testHndl, 'Enable', 'on');
   
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
% build buttons or check boxes

labelColor=[0.8 0.8 0.8];
top=0.95;
left=0.80;
btnWid=0.15;
btnHt=0.06;
bottom=0.03;
% Spacing between the button and the next command's label
spacing=0.03;

yPos=top-(btnNumber-1)*(btnHt+spacing);
if strcmp(labelStr, 'Close')==1
   yPos= bottom;
elseif strcmp(labelStr, 'Info')==1
   yPos= bottom+btnHt+spacing; 
else
   yPos=top-(btnNumber-1)*(btnHt+spacing)-btnHt;
end
% Generic button information
btnPos=[left yPos btnWid btnHt];
btHandle=uicontrol( ...
   'Style',thisstyle, ...
   'Units','normalized', ...
   'Position',btnPos, ...
   'String',labelStr, ...
   'Tag', uiTag, ...
   'Callback',callbackStr); 

%==================================================

