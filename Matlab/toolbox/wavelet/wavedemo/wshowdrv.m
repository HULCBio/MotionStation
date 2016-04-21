function varargout = wshowdrv(action,varargin);
% WSHOWDRV Wavelet toolbox slide show helper.
%   WSHOWDRV filename plays slide show from file filename.
%   Slide shows can be created using MAKESHOW.
%    
%   See also MAKESHOW, PLAYSHOW.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 09-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.17.4.2 $

if nargin<1,
   disp('You need to assign a name for script, for example: wshowdrv intro');
   return
else
   if strmatch('#',action) 
	   action = action(2:end);
	   if nargin<2 , figHandle = gcbf; else , figHandle = varargin{1}; end
	   if ishandle(figHandle)
		   oldVisibility = get(figHandle,'HandleVisibility');
		   set(figHandle,'HandleVisibility','on');
	   end
   else
	   funDemoName = action;
	   action = 'initialize';
   end;
end;

switch action
case 'initialize',
   figHandle = wfindobj('figure','tag',funDemoName);
   makeFIG   = isempty(figHandle);
   if makeFIG 
       try
		   [figName,showType] = feval(funDemoName,'getFigParam');
       catch
		   figName = ''; showType = 'mixed';
       end
       new_DESIGN = 1;
       figHandle = LocalInitFigure(funDemoName,figName,showType,new_DESIGN);
       if nargin>1
		   slideData = get(figHandle,'UserData');
		   closeHndl = slideData.closeHndl;
		   callbackStr = get(closeHndl,'Callback');
		   callbackStr = ['try, ' , callbackStr , ';', varargin{1} , ' end'];
		   set(closeHndl,'callBack',callbackStr);
		   if length(varargin)>1
			   set(closeHndl,'tag',varargin{2});
		   end
		   set(figHandle,'CloseRequestFcn',['closereq;',varargin{1}]);
       end
   else
       figure(figHandle);
   end
   if nargout>0 ,varargout{1} = figHandle; end

case 'next',
   LocalDoCmd(figHandle,1);
   
case 'back',
   slideData = get(figHandle,'UserData');
   idxSlide = slideData.index;
   deltaBackDEF = -1;
   deltaBack = deltaBackDEF;   
   if isfield(slideData.slide,'idxPrev')
	   idxPrev = slideData.slide(idxSlide).idxPrev;
	   if ~isempty(idxPrev) & isnumeric(idxPrev)
	        deltaBack = idxPrev-idxSlide;
	   else
	   end
   end
   LocalDoCmd(figHandle,deltaBack);

case 'reset',
   slideData = get(figHandle,'UserData');
   slideData.index = 1;
   set(figHandle,'UserData',slideData);   
   LocalDoCmd(figHandle,0);
   
   % 'try, wshowdrv('#close',1);demoguim('endshow'); end'

case 'autoplay',
   figNumber = figHandle;
   if nargin<3
	   direction = +1;
   else
	   direction = varargin{2};
	   if ~isequal(direction,-1), direction = +1; end
   end
   step = direction;
   allBtns  = findobj(figNumber,'Type','uicontrol','Style','pushbutton');
   autoHndl = findobj(allBtns,'Tag','autoPlay');

   % to check whether Handle is still there in case figure is closed
   if ishandle(autoHndl)
      btnStr = get(autoHndl,'String');
   else
      btnStr = '';
   end
   
   if strcmp(btnStr,xlate('AutoPlay'))
      slideData = get(figNumber,'UserData');
      cmdlen = length(slideData.slide);
      n = slideData.index;
      set(allBtns,'Enable','off');
      set(autoHndl,'String',xlate('Stop'),'Enable','on');
	  if direction==1
		  ok = (n<cmdlen);
	  else 
		  ok = (n>0);
		  findSTEP = isfield(slideData.slide,'idxPrev');
	  end
      while ok & ishandle(autoHndl) & strcmp(get(autoHndl,'String'),xlate('Stop')),
         figure(figNumber);
		 if direction==-1 & findSTEP
			 idxPrev = slideData.slide(n).idxPrev;
			 if ~isempty(idxPrev)
				 step = idxPrev-n;
			 else
				 step = -1;
			 end
		 end
         LocalDoCmd(figNumber,step);  
         drawnow;
         pause(2);
         n = n+step;
		 if direction==1 , ok = (n<cmdlen); else , ok = (n>0); end
      end;
   end
   if ishandle(autoHndl)
      set(autoHndl,'String',xlate('AutoPlay'));    
      set(allBtns,'Enable','on');
      slideData = get(figNumber,'UserData');
      n = slideData.index;
      LocalEnableBtns(n,slideData)
   end
%------------- Added for Wavelet ToolBox ---------%
case 'close',
	slideData = get(figHandle,'UserData');
	delete(figHandle);
   
case 'info',
	slideData = get(figHandle,'UserData');
	idxSlide = slideData.index;
	infoStrDEF = slideData.funDemoName;
	infoStr = infoStrDEF;
	if isfield(slideData.slide,'info')
		infoStr = slideData.slide(idxSlide).info;
		if isempty(infoStr) , infoStr = infoStrDEF; end
	end
	try 
		% feval('helpwin',infoStr);
		feval('doc',infoStr);
	catch
		% feval('helpwin',infoStrDEF);
		feval('doc',infoStrDEF);
	end

case 'set_axes',
	axes_mat = varargin{2};
	LocalBuildAxes(figHandle,axes_mat);   

case 'get_axes',
	slideData = get(figHandle,'UserData');
	varargout{1} = slideData.axesHandles;
   
case 'get_idxSlide',
	slideData = get(figHandle,'UserData');
	varargout{1} = slideData.index;

case 'modify_Comment',
	slideData = get(figHandle,'UserData');
	txtHndl = slideData.txtHndl;
	txtStr = get(slideData.txtHndl,'String');
	% idxLine = varargin{2};
	% txtLine = varargin{3};
	txtStr{varargin{2}} = varargin{3};
	set(txtHndl,'String',txtStr);

case 'bloc_BackBtn',
	slideData = get(figHandle,'UserData');
	backHndl = slideData.backHndl;
	wtbxappdata('set',backHndl,'blockbackHndl',1);
	
case 'free_BackBtn',
	slideData = get(figHandle,'UserData');
	backHndl = slideData.backHndl;
	if isappdata(backHndl,'blockbackHndl')
		wtbxappdata('del',backHndl,'blockbackHndl');
	end;

case 'eval_cbClose',
	slideData = get(figHandle,'UserData');
	closeHndl = slideData.closeHndl;
	callbackStr = get(closeHndl,'Callback');
	eval(callbackStr);
   
case {'modify_cbClose','modify_cbClose_NEW'}
    win_act = varargin{2};
    if ishandle(win_act);
        funName = varargin{3};
        slideData = get(figHandle,'UserData');
        closeHndl = slideData.closeHndl;
        callbackStr = get(closeHndl,'Callback');
        str_winact = num2str(win_act,16);
        str1 = 'try,';
        str2 = ['OKfig = any(findall(0,''type'',''figure'')==' str_winact ');'];
        switch action
            case 'modify_cbClose'
                funParamSTR = [funName '(''close'',' str_winact ');'];
            case 'modify_cbClose_NEW'
                funParamSTR = [...
                        'if ishandle(' str_winact ') ,' ...
                        funName '(''closeDEMO'',' str_winact ',[],[]);' ...
                    'end;'];
        end
        str3 = ['if OKfig==true , ' ...
                funParamSTR 'delete(' str_winact '); end;'];
        str4 = 'end;';
        addStr = [str1,str2,str3,str4];
        callbackStr = [addStr,'try,',callbackStr,';end; clear OKfig;'];
        set(closeHndl,'Callback',callbackStr);
        set(figHandle,'CloseRequestFcn',callbackStr);
    end
    
case 'gui_wait'
	figGUI = varargin{2};
	msg = varargin{3};
	dynvtool('hide',figGUI);
	hdlTxt = wwaiting('handle',figGUI);
	oldBkCol = get(hdlTxt,'Backgroundcolor');
	set(hdlTxt,'Backgroundcolor','w');
	nblin = size(msg,1);
	for k = 1:nblin
		hdlTxt = wwaiting('msg',figGUI,deblank(msg(k,:)));
		mousefrm(0,'watch');            
		pause(1.5);
		mousefrm(0,'arrow');            
	end
	hdlTxt = wwaiting('off',figGUI);
	set(hdlTxt,'Backgroundcolor',oldBkCol);
	dynvtool('show',figGUI);
   
case 'disp_msg'
	msg = varargin{2};
	wait_mode = varargin{3};
	active_fig = varargin{4};
	wait_Control = 0;
	max_lig = 6;
	max_lig = Inf;
	cellMSG = formatMSG(msg,max_lig);
	nbMSG = length(cellMSG);

	NEW_VERSION = 0;
	if NEW_VERSION & nbMSG>1
		slideData = get(figHandle,'UserData');
		nextHndl  = slideData.nextHndl;
		backHndl  = slideData.backHndl;
		resetHndl = slideData.resetHndl;
		autoHndl  = slideData.autoHndl;
		infoHndl  = slideData.infoHndl;
		closeHndl = slideData.closeHndl;
		idxSlide  = slideData.index;
		if ishandle(autoHndl)
			wait_Control = 1;
			btnStr = get(autoHndl,'String');
			if strcmp(btnStr,xlate('Stop'))
				wait_mode = 'auto';
			else
				wait_mode = 'step';
			end
			saveCallBack= {...
				get(nextHndl,'callback'),get(backHndl,'callback'), ...
				get(resetHndl,'callback'),get(autoHndl,'callback'), ...
				get(infoHndl,'callback'),get(closeHndl,'callback') ...
				};
		end
	end
	
	for j = 1:nbMSG
		msg = cellMSG{j};
		dmsgfun('create',msg,active_fig);
		if j<nbMSG
			wait_time = 1.5*size(msg,1);
		else
			wait_time = 0;
		end
		if NEW_VERSION & wait_Control
			LocalEnableBtns(idxSlide,slideData)
			switch wait_mode
			case 'fixed' , pause(wait_time);
			case 'step'  , pause(wait_time);
			case 'auto'  , set(autoHndl,'Enable','on'); pause(wait_time);
			end
		else
			mousefrm(0,'watch');
			pause(wait_time);
			mousefrm(0,'arrow');
		end		
	end
	if NEW_VERSION & wait_Control
		set(nextHndl,'callback',saveCallBack{1});
		set(backHndl,'callback',saveCallBack{2});
		set(resetHndl,'callback',saveCallBack{3});
		set(autoHndl,'callback',saveCallBack{4});
		set(infoHndl,'callback',saveCallBack{5});
		set(closeHndl,'callback',saveCallBack{6});
	end	

case 'autoMode'
	funDemoName = varargin{1};
	flagClose   = length(varargin)>1;
	figNumber = wshowdrv(funDemoName); pause(0.5)
	wshowdrv('#autoplay',figNumber);
	if flagClose
		try , wshowdrv('#eval_cbClose',figNumber); end
	end
	
case 'gr_autoMode'  % For test only
	funDemoName = varargin{1};
	flagClose   = length(varargin)>1;
	figNumber = wshowdrv(funDemoName); pause(0.5)
	wshowdrv('#autoplay',figNumber);
	wshowdrv('#autoplay',figNumber,-1);
	if flagClose
		try , wshowdrv('#eval_cbClose',figNumber); end
	end
	
end    % switch action

if ishandle(figHandle) & ~isequal(action,'initialize')
   set(figHandle,'HandleVisibility',oldVisibility);
end

% End of function wshowdrv
%------------------------------------------------------------------------------%



%------------------------------------------------------------------------------%
function LocalDoCmd(figNumber,ichange)
% execute the command in the command window 
% when ichange = 1, go to the next slide;
% when ichange = -1, go to the previous slide;
% when ichange = 0, stay with the current slide;

set(figNumber,'Pointer','watch');
% retrieve variables from saved UserData workspace

slideData = get(figNumber,'UserData');
SlideShowi = slideData.index+ichange;
cmdlen = length(slideData.slide);
if SlideShowi>1
   SlideShowVars = slideData.param(SlideShowi-1).vars;
   for SlideShown = 1:size(SlideShowVars,1); 
      eval([SlideShowVars{SlideShown,1} ' = SlideShowVars{SlideShown,2};']);
   end;
end;

%  guarantee the index is always inside the boundary
if SlideShowi<=0,
   SlideShowi = 1;
elseif SlideShowi>cmdlen
   SlideShowi = cmdlen;
end   
autoHndl = findobj(figNumber,'style','pushbutton','tag','autoPlay');
if strcmp(get(autoHndl,'String'),xlate('AutoPlay'))
   LocalEnableBtns(SlideShowi,slideData); 
end
% get slides
SlideShowcmdS = slideData.slide(SlideShowi).code;
if length(SlideShowcmdS)>0
   SlideShowcmdS = char(SlideShowcmdS);
else
   SlideShowcmdS = '';
end
SlideShowcmdNum = size(SlideShowcmdS,1);   
SlideShowtextStr = slideData.slide(SlideShowi).text;

% consider the empty case
if length(SlideShowtextStr)==0
   SlideShowtextStr = '';
   % else leave it alone: no need to call char(SlideShowtextStr)
end
set(slideData.txtHndl,'String',SlideShowtextStr);
sHndl = findobj(figNumber,'Type','uicontrol','Tag','slide');
%set(sHndl,'String',['Slide ',num2str(SlideShowi)]);
set(sHndl,'String',sprintf('Slide %s of %s',num2str(SlideShowi),num2str(cmdlen)));

% take comments out of the commands before eval them
SlideShowNoCmt = SlideShowcmdS;
if ~isempty(SlideShowcmdS)
   SlideShowNoCmt = LocalNoComments(SlideShowcmdS);
end
SlideShowerrorFlag = 0;
% add ',' at the end of each command 
SlideShowcmdStemp = [SlideShowNoCmt char(','*ones(size(SlideShowcmdS,1),1))];   
% make SlideShowcmdStemp in one line for eval (it has to be that way with 'for' or 'if')
SlideShowcmdStemp = SlideShowcmdStemp';
% evaluate the whole command window's code

h_ENA_ON = findobj(figNumber,'Style','Pushbutton','Enable','On');
set(h_ENA_ON,'Enable','Off');
try
  eval(SlideShowcmdStemp(:)')
catch
  SlideShowerrorFlag = 1;
end
set(h_ENA_ON,'Enable','On');

if SlideShowerrorFlag,
   return;
end

% -----------------------------------------------------------------%
% MiMi - Add the following line to manage the change of
% 'UserData' field during the eval(SlideShowcmdStemp(:)') command.
%------------------------------------------------------------------%
slideData = get(figNumber,'UserData');
%--------------------------------------%
slideData.index = SlideShowi;
set(figNumber,'UserData',slideData); 

% clear all wshowdrv specific variables  
clear SlideShowVars SlideShowcmdS SlideShowNoCmt cmdlen SlideShowi ichange 
clear SlideShown SlideShowtextStr slideData SlideShowcmdNum
% put variables into UserData workspace
vars = who;
slideData = get(figNumber,'UserData');
for SlideShown=1:size(vars,1),
   vars{SlideShown,2} = eval(vars{SlideShown,1});
end

slideData.param(slideData.index).vars = vars;
set(figNumber,'UserData',slideData);

set(figNumber,'Pointer','arrow');
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function NoComments = LocalNoComments(SlideShowcmdS)
% take out comments from command window commands
SlideShowNoCmt = SlideShowcmdS;
for SlideShowj=1:size(SlideShowcmdS,1)
   SlideShowCmt = find(SlideShowcmdS(SlideShowj,:)=='%');
   if ~isempty(SlideShowCmt)
      if SlideShowCmt(1)==1
         SlideShowNoCmt(SlideShowj,:) = ';';
      else
         % check whether '%' is inside quotes
         SlideShowQut = find(SlideShowcmdS(SlideShowj,:)=='''');
         if ~isempty(SlideShowQut)
            str = SlideShowcmdS(SlideShowj,:);  %to find out % inside '', and ignore it
            a = (str=='''');
            b = 1-rem(cumsum(a),2);
            c = (str=='%');
            d = b.*c;
            SlideShowCmt = find(d==1); 
            if isempty(SlideShowCmt),
               SlideShowCmt(1) = length(SlideShowcmdS(SlideShowj,:))+1;
            end
         end
         SlideShowNoCmt(SlideShowj,1:(SlideShowCmt(1)-1)) = SlideShowcmdS(SlideShowj,1:(SlideShowCmt(1)-1));
         SlideShowNoCmt(SlideShowj,SlideShowCmt(1):end) = ' ';
      end   
   else
      SlideShowNoCmt(SlideShowj,:) = SlideShowcmdS(SlideShowj, :);
   end
end
NoComments = SlideShowNoCmt;
%------------------------------------------------------------------------------%
function LocalEnableBtns(i,slideData)
% control the enable property for Next and Prev. buttons
cmdlen	= length(slideData.slide);
nextHndl = slideData.nextHndl;
backHndl = slideData.backHndl;  
autoHndl = slideData.autoHndl;  
set(autoHndl,'Enable','on');

lastPage  = (i==cmdlen);
firstPage = (i==1);

if lastPage & firstPage
   set(nextHndl,'Enable','off');
   set(backHndl,'Enable','off');
   set(autoHndl,'Enable','off');   
elseif lastPage
   set(nextHndl,'Enable','off');
   set(backHndl,'Enable','on');
   set(autoHndl,'Enable','off');   
elseif firstPage
   set(backHndl,'Enable','off');
   set(nextHndl,'Enable','on','String',xlate('Start >>'));  
else
   set(nextHndl,'Enable','on','String',xlate('Next >>'));
   set(backHndl,'Enable','on');        
end

if isappdata(backHndl,'blockbackHndl')
   set(backHndl,'Enable','off');        
end
%------------------------------------------------------------------------------%

%==============================================================================%
function figNumber = LocalInitFigure(funDemoName,figName,showType,new_DESIGN)

% Check inputs.
%--------------
if isempty(figName) , figName = 'Slide Player'; end
if strcmp(showType,'command') 
    no_output = 1;
	menubarVAL = 'none';
else
    no_output = 0;
	menubarVAL = 'figure';
end
pos_win = depOfMachine(no_output);

%===================================
% Now initialize the whole figure...

% Display mixed, text, or graphics only based on showType.
% If the figure is to be text only, hide the axis.
% If it is to be graphics only, hide the comment window.
% Otherwise, we'll assume that figure is mixed
defaultTextFontsize = wdfigutl('fontsize');
defLeftAxes  = 0.10; defLeftAxes  = 0.075;
defWidthAxes = 0.65; defWidthAxes = 0.675;
switch showType
    case 'text'
        axesVisStatus  = 'off';
        textVisStatus  = 'on';
        textBoxTop     = 0.97;
        defaultAxesPos = [0.45 0.45 0.1 0.1];

    case 'graphic'
        axesVisStatus  = 'on';
        textVisStatus  = 'off';
        textBoxTop     = 0.35;
        defaultAxesPos = [defLeftAxes 0.10 defWidthAxes 0.8];

    case 'mixed'  
        axesVisStatus  = 'on';
        textVisStatus  = 'on';
        textBoxTop     = 0.40;
        defaultAxesPos = [defLeftAxes 0.50 defWidthAxes 0.43];

    case 'manual'
        axesVisStatus  = 'off';
        textVisStatus  = 'off';
        textBoxTop     = 0.40;
        defaultAxesPos = [defLeftAxes 0.10 defWidthAxes 0.8];

    case 'command'
        axesVisStatus  = 'off';
        textVisStatus  = 'off';
        textBoxTop     = 0.40;
        defaultAxesPos = [defLeftAxes 0.10 defWidthAxes 0.8];

    otherwise
        if strcmp(showType(1:3),'mix'), 
            nb =  showType(4:length(showType));
            nb = wstr2num(nb);
			if new_DESIGN , nb = nb-1; end
            if      isempty(nb) , nb = 1;
            elseif  nb<1 ,  nb = 1;
            elseif  nb>20 , nb = 20;
            end
            nb = (nb-11);
            linh = (0.40-0.03)/11;
            axesVisStatus  = 'on';
            textVisStatus  = 'on';
            dy             = nb*linh;
            textBoxTop     = 0.40+dy;
            defaultAxesPos = [defLeftAxes 0.50+dy defWidthAxes 0.43-dy];
        else % mixed
            axesVisStatus  = 'on';
            textVisStatus  = 'on';
            textBoxTop     = 0.40;
            defaultAxesPos = [defLeftAxes 0.50 defWidthAxes 0.43];
        end
end;

if new_DESIGN
	defColDef = 'black';
	defFigColor = 0.4*[1 1 1];	
	defFontWeight = 'bold';
	defFontSize   = 8;
else
	defColDef = 'white';
	defFigColor = get(0,'DefaultFigureColor');	
	defFontWeight = 'normal';
	defFontSize   = 8;	
end

figProp_1 = {...
        'Name',figName,         ...
        'NumberTitle','off', 	...
        'IntegerHandle','On', 	...		
        'Visible','off',        ...
		'Position',pos_win,     ...
		'menubar','None'	    ...
        };
figProp_2 = {...
        'DefaultUicontrolFontWeight',defFontWeight, ...
        'DefaultAxesFontWeight',defFontWeight,      ...
        'DefaultTextFontWeight',defFontWeight,      ...
        'DefaultAxesFontSize',defFontSize,   ...
        'DefaultTextFontSize',defFontSize,   ...		
		'Position',pos_win,                  ...
		'DefaultAxesPosition',defaultAxesPos, ...
		'Color',defFigColor,                  ...
        'Tag',funDemoName                     ...
        };
if ~strcmp(showType,'command')
	figNumber = wfigmngr('init',figProp_1{:});
	set(figNumber,'HandleVisibility','On');
	wfigmngr('extfig',figNumber,'ExtFig_Demos')
    try
        feval(funDemoName,'addHelp',figNumber);
    end
	set(figNumber,'HandleVisibility','On');
else
	figNumber = figure(figProp_1{:});
	colordef(figNumber,defColDef);
    wfigmngr('extfig',figNumber,'Empty');
    set(figNumber,'HandleVisibility','On');
end
set(figNumber,figProp_2{:});
figNumberSTR = num2str(figNumber,16);


% Information for uicontrols.
%----------------------------
spacing	= 0.005;
btnWid  = 0.15;
btnHt   = 0.04;
btnSpacing = 0.03;
btnHtBig = 0.06;

if new_DESIGN
	left = 0.025; right = 0.7875; bottom = 0.025;
	frmBorder = 0.01; btnLeft = 0.8250; topFrm = 0.95;
	if no_output
		btnLeft = 0.10; btnWid = 0.80; btnHtBig = 0.10;
        bottom  = 0.08; topFrm = 0.85; frmBorder = 0.05;
		btnHt   = 0.05;
	end
	yPosTxt = bottom+topFrm-btnHt;
	% dx = 0.02; right = right-dx; btnLeft = btnLeft-dx; btnWid = btnWid+dx;
	btnPosParam = [btnLeft,bottom,yPosTxt,btnWid,btnHtBig,btnSpacing];
	frmBkColor = 0.6*ones(1,3);	
else
	left = 0.05; right = 0.75; bottom = 0.05;
	frmBorder = 0.02; btnLeft = 0.80; topFrm = 0.9;
	if no_output
		btnLeft = 0.10; btnWid = 0.80; btnHtBig = 0.10;
        bottom  = 0.08; topFrm = 0.85; frmBorder = 0.05;
		btnHt   = 0.05;
	end
	yPosTxt = 0.92;	
	btnPosParam = [btnLeft,bottom,topFrm,btnWid,btnHtBig,btnSpacing];
	frmBkColor = [0.5 0.5 0.5];
end


% The Text Window frame.
%-----------------------
frmPos = [left-frmBorder bottom-frmBorder ...
           (right-left)+2*frmBorder (textBoxTop-bottom+2*frmBorder)];
frmHndl = LocalBuildFrmTxt(frmPos,frmBkColor,'','frame','','');
set(frmHndl,'BackgroundColor',frmBkColor);
slideData.winFrmHndl = frmHndl;
if isequal(no_output,1) , set(slideData.winFrmHndl,'Visible','Off'); end

% The editable text field.
%-------------------------
mcwPos = [left bottom (right-left) textBoxTop-bottom]; 
callbackStr	= [mfilename,'(''#changetext'',',figNumberSTR,');'];
slideData.txtHndl = LocalBuildFrmTxt(mcwPos,frmBkColor,'','edit','comments',callbackStr);
set(slideData.txtHndl,...
	'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
	'FontWeight','bold');
if isequal(no_output,1) , set(slideData.txtHndl,'Visible','Off'); end

% The CONSOLE frame.
%-------------------
yPos = bottom-frmBorder;
frmPos = [btnLeft-frmBorder yPos btnWid+2*frmBorder topFrm+2*frmBorder];
frmHndl = LocalBuildFrmTxt(frmPos,frmBkColor,'','frame','','');
set(frmHndl,'BackgroundColor',frmBkColor);
slideData.cmdFrmHndl = frmHndl;
	
% The CONSOLE text (title).
%--------------------------
btnPos = [btnLeft yPosTxt btnWid btnHt];
slideHandle = LocalBuildFrmTxt(btnPos,frmBkColor,'Slide 1','text','slide','');
set(slideHandle,'HorizontalAlignment','center');
slideData.slitxtHndl = slideHandle;

% The Next button.
%-----------------
btnNumber	= 1;
labelStr	= 'Start >>';
callbackStr	= [mfilename,'(''#next'',',figNumberSTR,');'];
slideData.nextHndl = LocalBuildBtn('pushbutton',btnNumber,labelStr,callbackStr,'next',btnPosParam);

% The Prev button.
%-----------------
btnNumber	= 2;
labelStr	= 'Prev <<';
callbackStr	= [mfilename,'(''#back'',',figNumberSTR,');'];
slideData.backHndl = LocalBuildBtn('pushbutton',btnNumber,labelStr,callbackStr,'back',btnPosParam);

% The Reset button.
%------------------
btnNumber	= 3;
labelStr	= 'Reset';
callbackStr	= [mfilename,'(''#reset'',',figNumberSTR,');'];
slideData.resetHndl = LocalBuildBtn('pushbutton',btnNumber,labelStr,callbackStr,'reset',btnPosParam);

% The AutoPlay button.
%---------------------
btnNumber	= 4;
labelStr	= 'AutoPlay';
callbackStr	= [mfilename,'(''#autoplay'',',figNumberSTR,');'];
slideData.autoHndl = LocalBuildBtn('pushbutton',btnNumber,labelStr,callbackStr,'autoPlay',btnPosParam);

% The Info button.
%-----------------
btnNumber	= 0;
labelStr	= 'Info';
callbackStr	= [mfilename,'(''#info'',',figNumberSTR,');'];
slideData.infoHndl = LocalBuildBtn('pushbutton',btnNumber,labelStr,callbackStr,'info',btnPosParam);

% The Close button.
%-----------------
callbackStr	= [mfilename,'(''#close'',',figNumberSTR,');'];
slideData.closeHndl = LocalBuildBtn('pushbutton',0,'Close',callbackStr,'close',btnPosParam);
set(figNumber,'CloseRequestFcn',callbackStr);

% Now initiate userdata and uncover the figure
%---------------------------------------------
slideData.slide(1).code = {''};
slideData.slide(1).text = {''};
slideData.slide(1).info = {''};   % User defined for help!
slideData.slide(1).idxPrev = {};  % User defined for back button!
slideData.param(1).vars = {};

try
   slides = eval(funDemoName);
   set(slideData.slitxtHndl,'String', sprintf('Slide 1 of %s',num2str(length(slides))));
catch
   slides = [];
end

if ~isstruct(slides) | ...
      ~isfield(slides,'code') | ...
      ~isfield(slides,'text')
   slides.code = {'load logo'
      ' surf(L,R), colormap(M)'
      ' n = length(L(:,1));'
      ' axis off, axis([1 n 1 n -.2 .8]),view(-37.5,30)'
      'title(''Invalid WSHOWDRV File Requested'');'};
   slides.text = {'You have requested a file which does not exist'
      'or which is not a valid WSHOWDRV file.'};
   set(infoHndl,'Enable','off');
end

slideData.slide = slides;
slideData.index = 1;
slideData.funDemoName = funDemoName; 
set(figNumber,'UserData',slideData);
LocalDoCmd(figNumber,0);   

try 
	feval(funDemoName,'initShowViewer',figNumber);
end

%--------------------------------------------------------------%
% last thing: turn it on
% we are calling slide show code above, so don't switch
% HandleVis until we have computed the first slide: in case
% the code calls gcf or some such thing, if the demo is
% invoked from the command line, the fig won't be visible if
% we set handlevis to callback before computing...
%--------------------------------------------------------------%
set(figNumber, ...
        'Visible','on',...
        'HandleVisibility','callback');
%==============================================================================%


%==============================================================================%
%------------------------------------------------------------------------------%
function frmHndl = LocalBuildFrmTxt(frmPos,frmBkCol,txtStr,uiStyle,uiTag,uiCallback)
frmHndl = uicontrol( ...
        'Style', uiStyle, ...
        'HorizontalAlignment','left', ...
        'Units','normalized', ...
        'Max', 20, ...
        'Position',frmPos, ...
        'BackgroundColor',frmBkCol, ...
        'ForegroundColor',[1 1 1], ...             % generates an edge
        'String', txtStr, ...
        'Tag', uiTag);
%------------------------------------------------------------------------------%
function btHandle = LocalBuildBtn(btnStyle,btnNumber,labelStr,callbackStr,uiTag,btnPosParam)
% build buttons and check boxes on the right panel
labelColor = [0.8 0.8 0.8];
left = btnPosParam(1); bottom = btnPosParam(2); top = btnPosParam(3);
btnWid = btnPosParam(4); btnHt = btnPosParam(5); spacing = btnPosParam(6);
% Spacing between the button and the next command's label

yPos = top-(btnNumber-1)*(btnHt+spacing);
if strcmp(labelStr,'Close')==1
   yPos = bottom;
elseif strcmp(labelStr,'Info')==1
   yPos = bottom+btnHt+spacing; 
else
   yPos = top-(btnNumber-1)*(btnHt+spacing)-btnHt;
   yPos = yPos-btnHt/2;
   
end
% ui position
btnPos = [left yPos btnWid btnHt];
btHandle = uicontrol( ...
        'Style', btnStyle, ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',xlate(labelStr), ...
        'Tag', uiTag, ...
        'Callback',callbackStr); 	
%------------------------------------------------------------------------------%
function slideData = LocalBuildAxes(figNumber,axes_mat)

slideData = get(figNumber,'UserData');
delete(findobj(figNumber,'type','axes'));
if length(axes_mat)==0
	slideData.axesHandles = [];
	set(figNumber,'UserData',slideData);
	return;
end

nb_axes = prod(axes_mat);
axesHandles = zeros(1,nb_axes);
if length(axes_mat)==1 , axes_mat = [axes_mat 1]; end

% defAxesPos = get(figNumber,'DefaultAxesPosition');
left_a	 = 0;  right_a = 0.85;  % right_a = 0.80;
bottom_a = 0;  top_a = 1;
dy_axe	= 0.08;
dx_axe	= 0.1;
frmHndl = slideData.winFrmHndl;
if ishandle(frmHndl)
	pos_t = get(frmHndl,'Position');
	bottom_a = pos_t(2)+pos_t(4);
end
h_axe = (top_a-bottom_a-(axes_mat(1)+1)*dy_axe)/axes_mat(1);
w_axe = (right_a-left_a-(axes_mat(2)+1)*dx_axe)/axes_mat(2);
num = 1;
y_axe = top_a;

for r = 1:axes_mat(1)
	y_axe = y_axe-h_axe-dy_axe;        
	x_axe = left_a+dx_axe;
	for c = 1:axes_mat(2)
		pos_a = [x_axe y_axe w_axe h_axe];
		axesHandles(num) = axes('Parent',figNumber,...
								'Visible','off','Position',pos_a,'Userdata',num);
		num = num+1;
		x_axe = x_axe+w_axe+dx_axe;
	end
end
slideData.axesHandles = axesHandles;
set(figNumber,'UserData',slideData);
%------------------------------------------------------------------------------%
function varargout = depOfMachine(varargin)

no_output = varargin{1};
ShiftTop_Fig = mextglob('get','ShiftTop_Fig');
screen = get(0,'ScreenSize');
if no_output,
    height = 420; width = 240; height = 500; 
    if screen(4)<800
        height = height/2;
        width = 140;
    else
        height = height/1.5;
        width = 160;
    end
    left   = screen(3)*0.01;
    bottom = screen(4)-height-ShiftTop_Fig;
else
    height = 500; width  = 560;
    if screen(4)<height+ShiftTop_Fig , height = screen(4)-ShiftTop_Fig; end
    pos    = get(0,'DefaultFigurePosition');
    left   = (screen(3)-width)/2;
    bottom = screen(4)-height-ShiftTop_Fig;
end
varargout{1} = [left bottom width height];
%------------------------------------------------------------------------------%
%==============================================================================%

%==============================================================================%
%------------------------------------------------------------------------------%
function cellMSG = formatMSG(msg,max_lig)

if nargin<2 , max_lig = 6; end

if isequal(max_lig,Inf)
	ind = findstr(msg(:,1)','$');
	msg(ind) = ' ';
	cellMSG = {msg};
	return
end

i_msg = 0; cellMSG = {};
loop = 1;
while loop
	col1   = msg(:,1)';
	nb_lin = length(col1);
	ind    = findstr(col1,'$');
	if ~isempty(ind)
		lig = ind(1);
		if lig>max_lig+1
			beg = lig;
			tmp = msg(max_lig+1:nb_lin,:);
			msg = msg(1:max_lig,:);
		else
			beg = lig+1;
			tmp = msg(beg:nb_lin,:);
			msg = msg(1:lig-1,:);
		end
	elseif nb_lin>max_lig
		tmp = msg(max_lig+1:nb_lin,:);
		msg = msg(1:max_lig,:);
	else
		loop = 0;
	end
	i_msg = i_msg+1;
	cellMSG{i_msg} = msg;
	if loop , msg = tmp; end
end  % while loop
%------------------------------------------------------------------------------%
%==============================================================================%
