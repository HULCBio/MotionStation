function varargout = wfigmngr(option,varargin)
%WFIGMNGR Wavelet Toolbox Utilities for creating figures.
%   VARARGOUT = WFIGMNGR(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 12-Nov-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $

% Tool Memory Block.
%-------------------
n_toolMemB  = 'Tool_Params';

% Tag property of objects.
%------------------------
tag_m_files = 'M_Files';
tag_m_view  = 'M_View';
tag_m_dynv  = 'M_Zoom';

% Tag property of objects.
%-------------------------
tag_cmd_frame = 'Cmd_Frame';

% Test inputs.
%-------------
if nargin==0
    fig = gcf;
    option  = 'extfig';
    diffarg = 0;
elseif ~ischar(option)
    fig     = option;
    option  = 'extfig';
    diffarg = 0;
elseif strcmp(option,'extfig')
    diffarg = 1;
    if nargin<2 , fig = gcf; else , fig = varargin{1}; end    
end

switch option
    case 'getmenus'
        %***********************************************************%
        %** OPTION = 'getmenus' : get the handles of main menus.  **%
        %***********************************************************%
        fig   = varargin{1};
        lst_Main = findall(fig,'type','uimenu','Parent',fig);
		m_files  = findall(lst_Main,'tag',tag_m_files);
		nbIn = length(varargin);
		if nbIn==1
            varargout{1} = m_files;
            varargout{2} = lst_Main;
			return
		end

		% Search in menu Files First.
		%----------------------------
		lst_m = findall(m_files,'type','uimenu','Parent',m_files);
		varargout = cell(1,nbIn-1);
		for k = 2:nbIn
		    menuName = lower(varargin{k});
			switch menuName
			  case 'file'
				  varargout{k-1} = m_files;			
			  case {'load','save','close'}
				  varargout{k-1} = findmenu(lst_m,menuName);
			  case {'help'}
				  varargout{k-1} = findmenu(lst_Main,menuName);
			  case {'view'}
				  varargout{k-1} = findall(fig,'type','uimenu','tag',tag_m_view);				  
			end			
		end

    case 'init'
        %*************************************************************%
        %** OPTION = 'init' :  init a figure - with default values  **%
        %*************************************************************%
        % varargin contains figure properties.
        %-------------------------------------      

        % Get Globals.
        %-------------
        [...
        Def_FigColor,Def_DefColor,                      ...
        Def_AxeXColor,Def_AxeYColor,Def_AxeZColor,      ...
        Def_AxeFontSize,Def_TxtColor,Def_TxtFontSize,   ...
        Def_UicFtWeight,Def_AxeFtWeight,Def_TxtFtWeight,...
        Def_FraBkColor] = ...
            mextglob('get',...
                'Def_FigColor','Def_DefColor',...
                'Def_AxeXColor','Def_AxeYColor','Def_AxeZColor',        ...
                'Def_AxeFontSize','Def_TxtColor','Def_TxtFontSize',     ...
                'Def_UicFtWeight','Def_AxeFtWeight','Def_TxtFtWeight',  ...
                'Def_FraBkColor'                                        ...
                );
        varargout{1} = colordef('new',Def_DefColor);
        figProperties = {...
            'MenuBar','none',...
            'DefaultUicontrolBackgroundcolor',Def_FraBkColor,...
            'DefaultUicontrolFontWeight',Def_UicFtWeight,...
            'DefaultAxesFontWeight',Def_AxeFtWeight,...
            'DefaultTextFontWeight',Def_TxtFtWeight,...
            'Color',Def_FigColor,...
            'NumberTitle','Off',...
            'DefaultAxesFontSize',Def_AxeFontSize,...
            'DefaultAxesXColor',Def_AxeXColor,...
            'DefaultAxesYColor',Def_AxeYColor,...
            'DefaultAxesZColor',Def_AxeZColor,...
            'DefaultTextColor',Def_TxtColor,...
            'DefaultTextFontSize',Def_TxtFontSize,...
            'Name','',...
            'Visible','On',...
            'Position',get(0,'DefaultFigurePosition'),...
            'Unit',get(0,'defaultfigureUnit'),...
            varargin{:} ...
            };

        set(varargout{1}, figProperties{:});
        s = dbstack; defineWfigPROP(varargout{1},s)

    case 'attach_close'
        %******************************************************%
        %** OPTION = 'attach_close' :  attach close function **%
        %******************************************************%
        % in2 = fig
        % in3 = funct name (optional)
        % in4 = conditional closing (optional)
        %-------------------------------------
        fig     = varargin{1};
        lst     = findall(fig,'type','uimenu','Parent',fig);
        m_files = findall(lst,'tag',tag_m_files);
        lst     = findall(m_files,'type','uimenu','Parent',m_files);
        m_close = findmenu(lst,'close');
        set(m_close,'Interruptible','on');
        str1 = '';
        str2 = get(m_close,'callback');
        str3 = ['wfigmngr(''close'',' sprintf('%20.15f',fig) ');'];
        if nargin>2
            funcNam = varargin{2};       
            str1 = [funcNam '(''close'',' sprintf('%20.15f',fig) ');'];
            if nargin>3
                str1 = ['ansVal = ' str1];
                str2 = ['if ansVal>-1 ' str2 ' end; clear ansVal'];
            end
        end
        varargout{1} = [str3,str1,str2];
        set(m_close,'Callback',varargout{1});
        set(fig,'CloseRequestFcn',varargout{1})

    case 'close'
        fig = varargin{1};
        figChild = wfigmngr('getWinPROP',fig,'FigChild');
        figChild = figChild(ishandle(figChild));
        for k = 1:length(figChild)
            try , eval(get(figChild(k),'CloseRequestFcn')); end
        end

    case 'extfig'
        %******************************************%
        %** OPTION = 'extfig' :figure extension  **%
        %******************************************%
		createMenus(fig,varargin{2:end});

    case 'create'
        %******************************************%
        %** OPTION = 'create' :  create a window **%
        %******************************************%
        % in2 = win_name
        % in3 = color (1...8)
        % in4 = extmode (number or strmat)
        %   
        % in5 = closemode (strmat)
        %   if size(in5,1) = 2 , conditional close
        %-----------------------------------------
        % in6 = flag dynvisu   (optional)
        % in7 = flag close btn (optional)
        % in8 = flag txttitl   (optional)
        %-----------------------------------------
        % out1 = win_hld
        % out2 = frame_hdl
        % out3 = graphic_area
        % out4 = pus_close
        %-------------------------
        nbin = length(varargin);
        
        % Defaults Values
        %-----------------
        figName     = '';
        valColor    = '';
        extMode     = '';
        closeMode   = '';
        flgDynV     = 1;
        flgCloseBtn = 1;
        flgTitle    = 1;

        switch nbin
            case 1 , figName = varargin{1};
            case 2 , [figName,valColor] = deal(varargin{:});
            case 3 , [figName,valColor,extMode] = deal(varargin{:});
            case 4 , [figName,valColor,extMode,closeMode] = deal(varargin{:});
            case 5 , [figName,valColor,extMode,closeMode,...
                      flgDynV] = deal(varargin{:});
            case 6 , [figName,valColor,extMode,closeMode,...
                      flgDynV,flgCloseBtn] = deal(varargin{:});
            case 7 , [figName,valColor,extMode,closeMode,...
                      flgDynV,flgCloseBtn,flgTitle] = deal(varargin{:});
        end

        % Get Globals.
        %-------------
        [...
        Def_Btn_Height,X_Graph_Ratio,X_Spacing,Y_Spacing,...
        Def_TxtBkColor,Def_FraBkColor] = ...
            mextglob('get',...
                'Def_Btn_Height','X_Graph_Ratio', ...
                'X_Spacing','Y_Spacing',          ...
                'Def_TxtBkColor','Def_FraBkColor' ...
                );

        % Creating extended figure.
        %--------------------------
        win_units = 'pixels';
        [pos_win,win_width,win_height,cmd_width] = wfigmngr('figsizes');
        win_hld   = wfigmngr('init', ...
                        'Name',figName,...
                        'Unit',win_units,...
                        'Position',pos_win...
                        );

        % Figure Extension (add menus).
        %-----------------------------
        if ~isempty(extMode) , wfigmngr('extfig',win_hld,extMode); end
        s = dbstack; defineWfigPROP(win_hld,s,'replace')
        if ~isempty(closeMode)
            namefunc = deblank(closeMode(1,:));
            if size(closeMode,1)==2
               cba_close = wfigmngr('attach_close',win_hld,namefunc,'cond');
            else
               cba_close = wfigmngr('attach_close',win_hld,namefunc);      
            end
        else
            cba_close = wfigmngr('attach_close',win_hld);   
        end
        x_frame   = pos_win(3)-cmd_width+1;
        pos_frame = [x_frame,0,cmd_width,pos_win(4)+5];
        frame_hdl = uicontrol(...
                              'Parent',win_hld,               ...
                              'Style','frame',                ...
                              'Unit',win_units,               ...
                              'Position',pos_frame,           ...
                              'Backgroundcolor',Def_FraBkColor, ...
                              'Tag',tag_cmd_frame             ...
                              );
        drawnow;

        if flgDynV
            % Dynamic visualization tool.
            %----------------------------
            pos_dyn_visu = dynvtool('create',win_hld,X_Graph_Ratio);
            ylow = pos_dyn_visu(4);
            pos_gra = [0,pos_dyn_visu(4),x_frame,pos_win(4)-ylow];
        else
            pos_gra = [0,0,x_frame,pos_win(4)];
        end
        if flgCloseBtn
           % Close Button.
           %--------------
            push_width  = (cmd_width-4*X_Spacing)/2;
            xl = x_frame+(cmd_width-7*push_width/4)/2;
            yl = pos_frame(2)+2*Y_Spacing;
            wi = 7*push_width/4;
            scrSize = get(0,'ScreenSize');
            if scrSize(4)<700
                he = Def_Btn_Height;
            else
                he = 3*Def_Btn_Height/2;
            end
            pos_close = [xl , yl , wi , he];
            pus_close = uicontrol(...
                                  'Parent',win_hld,    ...
                                  'Style','Pushbutton',...
                                  'Unit',win_units,    ...
                                  'Position',pos_close,...
                                  'String',xlate('Close'),    ...
                                  'Interruptible','on',...
                                  'Userdata',0,        ...
                                  'Callback',cba_close,...
                                  'TooltipString',xlate('Close window')...
                                  );
        else
            pus_close = [];
        end
        wfigmngr('storeValue',win_hld,'pus_close',pus_close);

        if flgTitle
            % Figure Title.
            %--------------
            wfigtitl('set',win_hld,X_Graph_Ratio,'','off',Def_TxtBkColor);
            pos_gra(4) = pos_gra(4)-Def_Btn_Height;
        end

        % Waiting Text construction.
        %---------------------------
        wwaiting('create',win_hld,X_Graph_Ratio);

        switch nargout
            case 1 , varargout = {win_hld};
            case 4 , varargout = {win_hld,frame_hdl,pos_gra,pus_close};
            case 8
                varargout = {...
                             win_hld,pos_win,win_units, ...
                             sprintf('%.0f',win_hld),...
                             frame_hdl,pos_frame,pos_gra,pus_close...
                             };
        end
        drawnow

    case 'normalize'
        %************************************************%
        %** OPTION = 'normalize' :  normalize a window **%
        %************************************************%
        % in2 = win_hdl
        % in3 = pos_gra (optional)
        %--------------------------
        % out1 = pos_gra (optional)
        fig = varargin{1};
        pos_win = get(fig,'Position');
        if nargin>2
            varargout{1} = varargin{2}./[pos_win(3:4),pos_win(3:4)];
        end
        hdl = [wfindobj(fig,'units','pixels');wfindobj(fig,'units','data')];
        set(hdl,'units','normalized');

        % Resizing the Figure.
        %---------------------
        if isappdata(0,'ResizeRatioWTBX_Fig')
            RatScrPixPerInch = getappdata(0,'ResizeRatioWTBX_Fig');
            if ~isequal(RatScrPixPerInch,1.0)
                pos_winNOR = get(fig,'Position');
                pos_winNEW = RatScrPixPerInch*pos_winNOR;
                DeltaDIM = pos_winNEW-pos_winNOR;
                pos_win = [pos_winNOR(1:2)-DeltaDIM(3:4),pos_winNEW(3:4)];
                set(fig,'Position',pos_win);
            end
        end

    case 'handlevis'
        %***************************************************************%
        %** OPTION = 'handlevis' :  set HandleVisibility for a window **%
        %***************************************************************%
        % in2 = win_hdl
        % in3 = handleVisibility value
        %------------------------------
        fig    = varargin{1};
        flgVis = lower(varargin{2});
        switch flgVis
          case {'on','off','callback'}
            set(fig,'HandleVisibility',flgVis);
          otherwise
            errargt(mfilename,'Invalid Value for HandleVisibility','msg');
            error('*')
        end

    case 'get_activeHDL'
        % in2 = win_hdl
        % in3 = type
        %---------------
        fig  = varargin{1};
        type = varargin{2};
        switch type
            case 'uimenu'
                m0 = findall(get(fig,'children'),'flat','type','uimenu');
                m1 = findall(m0,'tag',tag_m_files);
                m0(m0==m1) = [];
                c1 = findall(m1,'Parent',m1);
                p1 = get(c1,'Position');
                p1 = cat(1,p1{:});
                [nul,I1] = sort(p1);
                n  = length(I1);
                I1 = I1(n-2:n);
                varargout{1} = [findall(m0) ; m1; c1(I1)];

            case 'close'
                cba  = get(fig,'CloseRequestFcn');
                varargout{1} = wfindobj(fig,'style','pushbutton','callback',cba);
                varargout{2} = wfindobj(fig,'type','uimenu','callback',cba);
        end

    case 'figsizes'
        % Get Globals.
        %-------------
        [ShiftTop_Fig, ...
         Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         X_Graph_Ratio,X_Spacing,Y_Spacing ] = ...
           mextglob('get',...
               'ShiftTop_Fig', ...
               'Def_Btn_Height','Def_Btn_Width','Pop_Min_Width', ...
               'X_Graph_Ratio','X_Spacing','Y_Spacing'           ...
               );
        win_height  = 21*Def_Btn_Height+45*Y_Spacing;
        cmd_width   = Def_Btn_Width+2*Pop_Min_Width+6*X_Spacing;
        win_width   = round(cmd_width/(1-X_Graph_Ratio));
        Screen_Size = get(0,'ScreenSize');
        left_win    = Screen_Size(3)-5-win_width;
        down_win    = Screen_Size(4)-win_height-ShiftTop_Fig;
        pos_win     = [left_win,down_win,win_width,win_height];                 
        varargout   = {pos_win , win_width , win_height , cmd_width};

    case 'dynv'
        %**************************************%
        %** OPTION = 'dynv' :  dynv ON /OFF  **%
        %**************************************%
        % in2 = fig
        %------------------------------------------
        fig    = varargin{1};
        menu   = gcbo;
        oldVal = get(menu,'checked');
        switch oldVal
          case 'on'  , newVal = 'off';
          case 'off' , newVal = 'on';
        end
        set(menu,'Checked',newVal);
        dynvtool('visible',fig,newVal)

	case {'storeValue','storevalue'}
        % varargin{2} = name
        % varargin{3} = value
        %--------------------
        fig  = varargin{1};
        memB = wfigmngr('rmb',fig);
        memB.(varargin{2}) = varargin{3};
        wfigmngr('wmb',fig,memB);
        if nargout>0 , varargout = {memB}; end

    case {'getValue','getvalue'}
        fig  = varargin{1};
        memB = wfigmngr('rmb',fig);
        try   , varargout{1} = memB.(varargin{2});
        catch , varargout{1} = [];
        end

    case 'getWinPROP'
        fig = varargin{1};
        nbarg = length(varargin);
        wfigPROP = wtbxappdata('get',fig,'WfigPROP');        
        if nbarg<2 , varargout{1} = wfigPROP; return; end
        notEmpty = ~isempty(wfigPROP);             
        for k = 2:nbarg
           outType = lower(varargin{k});
           switch outType
             case {'makefun','calledfun'}
               if notEmpty
                   varargout{k-1} = wfigPROP.MakeFun;
               else
                   varargout{k-1} = wdumfun;
               end

             case 'figparent'
               if notEmpty
                   varargout{k-1} = wfigPROP.FigParent;
               else
                   varargout{k-1} = [];
               end

             case 'figchild'
               if notEmpty
                   varargout{k-1} = wfigPROP.FigChild;
               else
                   varargout{k-1} = [];
               end
           end
        end

    case 'get'
        fig  = varargin{1};
        nbarg = length(varargin);
        if nbarg<2 , return; end
        for k = 2:nbarg
           outType = lower(varargin{k});
           switch outType
             case 'pos_close'
               pus_close = wfigmngr('getValue',fig,'pus_close');
               if isempty(pus_close)
                   varargout{k-1} = [];
               else
                   varargout{k-1} = get(pus_close,'Position');
               end

             case {'cmd_width','fra_width'}
               [Def_Btn_Width,Pop_Min_Width,X_Spacing] = ...
                  mextglob('get','Def_Btn_Width','Pop_Min_Width','X_Spacing');
               if isequal(outType,'fra_width'), nbx = 3; else nbx = 6; end
               varargout{k-1} = Def_Btn_Width+2*Pop_Min_Width+nbx*X_Spacing;               
           end
        end

    case 'cmb'
        %***********************************************%
        %** OPTION = 'cmb' - create Tool Memory Block **%
        %***********************************************%
        fig = varargin{1};
        wmemtool('ini',fig,n_toolMemB,1);

    case 'wmb'
        %**********************************************%
        %** OPTION = 'wmb' - write Tool Memory Block **%
        %**********************************************%
        fig = varargin{1};
        varargout{1} = wmemtool('wmb',fig,n_toolMemB,1,varargin{2});

    case 'rmb'
        %*********************************************%
        %** OPTION = 'rmb' - read Tool Memory Block **%
        %*********************************************%
        fig = varargin{1};
        varargout{1} = wmemtool('rmb',fig,n_toolMemB,1);

    case 'suppressMenu'
        fig = varargin{1};
		nbIn = length(varargin);
		k = 2;
		while k<nbIn
			menuLetter = varargin{k};
		    itemToSuppress = varargin{k+1};
		    h = getMainMenuHdl(fig,menuLetter);
		    suppressMenu(h,itemToSuppress);
			k = k+2;
		end

	case 'add_CCM_Menu'	
        fig  = varargin{1};		
        m_view = wfigmngr('getmenus',fig,'view');
        m_disp = uimenu(m_view,...
			'Label','Coefficient Coloration Mode', ...
			'Separator','On' ...
			);
        m_sub(1) = uimenu(m_disp,...
					'Label','Absolute Mode','Checked','On','Tag','CCM');
        m_sub(2) = uimenu(m_disp,...
					'Label','Normal Mode','Checked','Off','Tag','CCM');
		set(m_sub,'Userdata',m_sub,'Callback',@cb_Default_Color_Mode);

	case 'get_CCM_Menu'
        fig  = varargin{1};
        m_view = wfigmngr('getmenus',fig,'view');
		if isequal(m_view,0) , varargout{1} = 1; return; end
		m_chk = findall(m_view,'checked','On','Tag','CCM');
		lab = get(m_chk,'label');
		switch lower(lab(1))
			case 'n' , varargout{1} = 0;
			case 'a' , varargout{1} = 1;
		end
        
    case 'modify_FigChild'
        fig = varargin{1};
        wfigPROP = wtbxappdata('get',fig,'WfigPROP');
        wfigPROP.FigChild = unique([wfigPROP.FigChild,varargin{2}]);
        idx = ~ishandle(wfigPROP.FigChild);
        wfigPROP.FigChild(idx) = [];
        wtbxappdata('set',fig,'WfigPROP',wfigPROP);
        
	otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
%=======================================================================%


%=======================================================================%
%   CREATION AND MANAGEMENT OF THE MENUS								%
%=======================================================================%
%=======================================================================%
function createMenus(fig,varargin)

% Tag(s)
%------
tag_m_files = 'M_Files';
tag_m_view  = 'M_View';

% Get Default StandardMenus.
%---------------------------
% DefaultStandardMenus = GetDefaultFigureMenus;;
% DefaultStandardMenus = {'F','E','V','I','T','W','H'};
%---------------------------------------------------
% We suppress the "Edit" menu in all windows ...
%---------------------------------------------------
Kept_StandardMenus = {'V','I','T','W','H'};  

nbin = length(varargin);
switch nbin
case 0
	win_type = 'None';
	StandardMenus = Kept_StandardMenus;
	WTBXMenus     = {};
	
otherwise
	win_type = varargin{1};
	if isstr(win_type)
		switch win_type
			case {'ExtMainFig_WTBX','ExtFig_WH'}
				WTBXMenus     = {'F'};					
				StandardMenus = {'W','H'};

			case {'ExtFig_DynV'}
				WTBXMenus     = {'F'};
				StandardMenus = {'W'};

			case {'ExtFig_More'}
				WTBXMenus     = {};
				StandardMenus = {'W','H'};

			case {'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2',...
                  'ExtFig_Tool_3','ExtFig_GUIDE', ...
				  'ExtFig_CompDeno','ExtFig_WDisp','ExtFig_ThrSet'}
				WTBXMenus     = {'F','O'};
				StandardMenus = Kept_StandardMenus;
				
			case {'ExtFig_HistStat'}
				WTBXMenus     = {'F'};
				StandardMenus = Kept_StandardMenus;
                
            case {'ExtFig_Demos'}
				WTBXMenus     = {'F'};
				StandardMenus = Kept_StandardMenus;
                
            case {'Empty','ExtFig_NoMenu'}
				WTBXMenus     = {};
				StandardMenus = {};
		end
		
	elseif iscell(win_type)
		if length(win_type)>1
			params = win_type(2:end);
		else
			params = {};
		end
		win_type = win_type{1};
		
	else
		win_type = 'ExtFig_Gen';  
		StandardMenus = varargin{end-1};
		if ~iscell(StandardMenus)
			StandardMenus = num2cell(StandardMenus);
		end
		WTBXMenus = varargin{end};
		if ~iscell(WTBXMenus)
			WTBXMenus = num2cell(WTBXMenus);
		end	
	end
end
if isempty(find(wfindobj('figure')==fig)) , fig = gcf; end
s = dbstack; defineWfigPROP(fig,s)

% Adding Menus.
%==============
if ~isempty(WTBXMenus) | ~isempty(StandardMenus)
	showHiddenVal = get(0,'ShowHiddenHandles');
	set(0,'ShowHiddenHandles','on');
	fig_TEMPO = figure('visible','off');
	lst_Menus = [];
	
	% Add Files Menu.
	%----------------
	ind = find(strncmpi(WTBXMenus,'F',1));
	if ~isempty(ind)
		h = addMenuFilesWTBX(fig,win_type,tag_m_files);
		lst_Menus = [h ; lst_Menus];
	end
	
	% Add Standard Menus.
	%--------------------
	if ~isempty(StandardMenus)
		addMenu = {};
		for k = 1:length(Kept_StandardMenus)
			letter = Kept_StandardMenus{k};
			ind = find(strncmpi(StandardMenus,letter,1));
			if ~isempty(ind) , addMenu = {addMenu{:},['&' letter]}; end
		end
		h = addStandardMenus(fig,fig_TEMPO,addMenu{:});
		lst_Menus = [lst_Menus ; h];
	end

	switch win_type 
		case {'ExtMainFig_WTBX','ExtFig_WH','ExtFig_DynV',   ...
			  'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2', ...
              'ExtFig_Tool_3','ExtFig_GUIDE', ...
		      'ExtFig_ThrSet','ExtFig_WDisp','ExtFig_More','ExtFig_Gen', ...
			  'ExtFig_CompDeno','ExtFig_HistStat', ...
              'ExtFig_Demos' ...
			  }
	
			% If necessary modify some Menus.
			%--------------------------------
			lstLabels = get(lst_Menus,'label');
			
			% Modify View Menu.
			%------------------
			ind = strmatch('&V',lstLabels);
			if ~isempty(ind)
				m_View = lst_Menus(ind);
				set(m_View,'Tag',tag_m_view);
				add_DynV_Tool = 0;
				if ~isempty(WTBXMenus)
					ok_DynV = find(strncmpi(WTBXMenus,'O',1));
					if ~isempty(ok_DynV) , add_DynV_Tool = 1; end
				end
				setMenuView(m_View,add_DynV_Tool);
			end
			
			% Modify Insert Menu.
			%--------------------
			ind = strmatch('&I',lstLabels);
			if ~isempty(ind) , setMenuInsert(lst_Menus(ind)); end
			
			% Modify Tools Menu.
			%------------------
			ind = strmatch('&T',lstLabels);
			if ~isempty(ind) , setMenuTools(lst_Menus(ind)); end
			
			% Modify Help Menu.
			%------------------
			ind = strmatch('&H',lstLabels);
			if ~isempty(ind)
                wfighelp('set',lst_Menus(ind),win_type);
            end
	end
		
	delete(fig_TEMPO)
	set(0,'ShowHiddenHandles',showHiddenVal);
end

% Set Default 'WindowButtonMotionFcn'.
%-------------------------------------
set(fig,'WindowButtonMotionFcn','wtmotion');

% Prevent extrat plots.
set(fig,'HandleVisibility','Callback')

% End Of WTBMENUS
%=======================================================================%

%====================  ADDING and SETTING MENUS ========================%
%---------------------------------------------------------------------%
function h = addMenuFilesWTBX(fig,win_type,tag_m_files)

% Configuration of standard "Files" menu (reverse order).
%--------------------------------------------------------
lab_child = {... 
    '&Print...',			% num = 1
    'Print Pre&view...',	% num = 2
    'Print Set&up...',	    % num = 3
    'Pa&ge Setup...',		% num = 4
    'Pre&ferences...',		% num = 5
    'E&xport...',			% num = 6 ('&Export')
    'Save &As...',			% num = 7
    '&Save',				% num = 8
    '&Close',				% num = 9
    '&Open...',				% num = 10
    '&New Figure'			% num = 11
	};

% Modification of some labels.
%-----------------------------
lab_child{7} = 'Figure &As...';
lab_child{8} = '&Figure'; 
		
cb_child = {...
	'printdlg(gcbf)',                                                                      
	'printpreview(gcbf)',                                                                  
	'printdlg(''-setup'')',                                                                 
	'pagesetupdlg(gcbf)',                                                                  
	'preferences',                                                                         
	'filemenufcn(gcbf,''FileExport'')',                                                      
	'filemenufcn(gcbf,''FileSaveAs'')',                                                      
	'filemenufcn(gcbf,''FileSave'')',                                                        
	'close(gcbf)',                                                                         
	'filemenufcn(gcbf,''FileOpen'')',                                                        
	'figure' 
	};

h = uimenu(fig,...
	'Label','&File',  ...
	'Position',1,     ...
	'Tag',tag_m_files ...
	);								

switch win_type
	case {'ExtFig_Tool'}
		ok_Load = 1; ok_Save = 1;
		
	case {'ExtFig_Tool_1'}
		ok_Load = 1; ok_Save = 0;
		
	case {'ExtFig_Tool_2',...
		  'ExtFig_CompDeno'}
		ok_Load = 0; ok_Save = 1;

	case {'ExtFig_Tool_3','ExtFig_GUIDE', ...
		  'ExtFig_HistStat','ExtFig_ThrSet','ExtFig_WDisp'}
		ok_Load = 0; ok_Save = 0;
		
	otherwise
		ok_Load = 0; ok_Save = 0;		
end

% Add Load Menu.
%---------------
if ok_Load
	m_load = uimenu(h,'Label','&Load','Position',1);
end

% Add Save Menu and SubMenus.
%----------------------------
if ok_Save
	if ok_Load , pos = 2; else , pos = 1; end
	m_save = uimenu(h,'Label','&Save','Position',pos);
    flag_sub_Save = 0;
	if flag_sub_Save
		idx_child = [7,8];
		switch win_type
			case {'ExtFig_HistStat','ExtFig_WDisp','ExtFig_ThrSet'}
				sep_child = {'Off','Off'};			
			otherwise
				sep_child = {'On','Off'};
		end
		addChildren(m_save, ...
			lab_child(idx_child),sep_child,cb_child(idx_child));
	end
end

% Add Open & Export Menus.
%-------------------------
flag_Open_Export = 1;
if flag_Open_Export
    switch win_type			
		case {'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2', ...
              'ExtFig_Tool_3','ExtFig_GUIDE', ...
			  'ExtFig_WH','ExtFig_ThrSet','ExtFig_WDisp', ...
			  'ExtFig_CompDeno','ExtFig_HistStat','ExtFig_Demos'}
			idx_child = [6];
			switch win_type
				case {'ExtFig_HistStat','ExtFig_ThrSet','ExtFig_WDisp','ExtFig_Demos'}
					sep_child = {'Off'};				
				otherwise
					sep_child = {'On'};
			end
			if isequal(win_type,'ExtFig_WH'), sep_child{1} = 'Off'; end
			addChildren(h, ...
				lab_child(idx_child),sep_child,cb_child(idx_child));
    end
end

% Add Print Menus.
%-----------------
switch win_type
	case 'ExtMainFig_WTBX'
		idx_child = [5,1];
		sep_child = {'Off','Off','Off'};
		sep_close = 'On';
		m_Parent = h;
			
	case {'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2', ...
          'ExtFig_Tool_3','ExtFig_GUIDE', ...
		  'ExtFig_WH','ExtFig_WDisp','ExtFig_CompDeno','ExtFig_HistStat', ...
		  'ExtFig_ThrSet','ExtFig_Demos'}
		idx_child = [4,3,2,1];
		sep_child = {'Off','Off','Off','Off'};		
		sep_close = 'On';
		m_Parent = uimenu(h, ...
			'Label','&Print Tools', ...
			'Separator','On' ...
			);

	otherwise
		sep_close = 'Off';
		idx_child = []; sep_child = []; 
		m_Parent = h;
end
addChildren(m_Parent, ...
	lab_child(idx_child),sep_child,cb_child(idx_child));

% Add Close Menu.
%----------------
cb_Close = ['try , delete(' sprintf('%20.15f',fig) '); end;'];
uimenu(h,...
        'Label','&Close',      ...
        'Separator',sep_close, ...
        'CallBack',cb_Close    ...
        );
%---------------------------------------------------------------------%
function addChildren(par,lab_child,sep_child,cb_child)

for k = 1:length(lab_child)
	uimenu(par,...
		'Label',lab_child{k},     ...
		'Separator',sep_child{k}, ...
		'CallBack',cb_child{k}    ...
		);
end		
%---------------------------------------------------------------------%
function liste = addStandardMenus(fig,fig_TEMPO,varargin)

LstMenusInFig  = findall(get(fig,'Children'),'flat','type','uimenu');
lstLabelsInFig = get(LstMenusInFig,'label');
lstMenus  = findall(get(fig_TEMPO,'Children'),'flat','type','uimenu');
lstLabels = get(lstMenus,'label');
liste = [];
for k=1:length(varargin)
    lab = varargin{k};
    ind = strmatch(lab,lstLabelsInFig);
    if isempty(ind)
        ind = strmatch(lab,lstLabels);
        if ~isempty(ind)
            liste = [liste ; lstMenus(ind)];
        end
    end
end
if ~isempty(liste) , liste = copyMenu(liste,fig); end		
%---------------------------------------------------------------------%
%================== GENERAL SETTINGS FOR MAIN MENUS ====================%
%---------------------------------------------------------------------%
function setMenuView(h,Add_DynV_Tool)

% Tag and Label for DynVTool.
%----------------------------
tag_m_dynv = 'M_Zoom';
lab_m_dynv = 'Dynamical Visualization Tool';

% Get information and ...
%------------------------
c = get(h,'Children');
lab = get(c,'Label');
idx_Cam = [strmatch('&C',lab)];
idx_Fig = [strmatch('&F',lab)];
set(c(idx_Fig),'Checked','Off','Callback',@cb_FigToolBar);

if ~Add_DynV_Tool
	m_dynv = findmenu(c,lab_m_dynv);
	if m_dynv~=0 , Add_DynV_Tool = 0; end
end

% Suppress Camera Toolbar.
%-------------------------
if ~isempty(idx_Cam) , delete(c(idx_Cam)); end

% Add DynVTool if necessary.
%---------------------------
if Add_DynV_Tool
	uimenu(h,...
           'Label',lab_m_dynv, ...
		   'Separator','On',   ...
           'Checked','on',     ...
           'callback',@cb_DynVTool, ...
           'tag',tag_m_dynv    ...
           );
end
%---------------------------------------------------------------------%
function cb_FigToolBar(hco,eventStruct)

menu = gcbo;
oldVal = get(menu,'checked');
switch oldVal
  case 'on'  , newVal = 'off';
  case 'off' , newVal = 'on';
end
set(menu,'Checked',newVal);
domymenu('menubar','toggletoolbar',gcbf) 
%---------------------------------------------------------------------%
function cb_DynVTool(hco,eventStruct)

menu = gcbo;
oldVal = get(menu,'checked');
switch oldVal
  case 'on'  , newVal = 'off';
  case 'off' , newVal = 'on';
end
set(menu,'Checked',newVal);
dynvtool('visible',gcbf,newVal)	   
%---------------------------------------------------------------------%
function setMenuInsert(h)

c = get(h,'Children');
lab = get(c,'Label');
ind = [
	strmatch('&C',lab); strmatch('&L',lab);   ...  
	strmatch('&A',lab); findSubSTR('&i',lab); ...
	];
if ~isempty(ind) , delete(c(ind)); end
%---------------------------------------------------------------------%
function setMenuTools(h)

c = get(h,'Children');
lab = get(c,'Label');
ind = [
	strmatch('&E',lab);   findSubSTR('&C',lab);    ...	
	findSubSTR('&M',lab); findSubSTR('&x',lab); findSubSTR('&s',lab); ...
	strmatch('&B',lab);   strmatch('&D',lab);...
	];
if ~isempty(ind) , delete(c(ind)); end
%---------------------------------------------------------------------%
function cb_Default_Color_Mode(hco,eventStruct) % Menu Preference

ud = get(hco,'Userdata');
idx = find(ud==hco);
set(ud(idx),'Checked','On');
set(ud(3-idx),'Checked','Off');
%---------------------------------------------------------------------%
%=======================================================================%

%=================== MODIFICATIONS FOR MAIN MENUS ======================%
%---------------------------------------------------------------------%
function suppressMenu(h,toSuppress)

c = get(h,'Children');
lab = lower(get(c,'Label'));
toSuppress = lower(toSuppress);
ind = [];
for k = 1:length(toSuppress)
	item = toSuppress{k};
	indItem = [];
	for j = 1:length(lab)
		S = lab{j};
		dum = findstr(S,item);
		if ~isempty(dum) , indItem = j; break; end
	end
	ind = [ind ; indItem];
end
if ~isempty(ind) , delete(c(ind)); end

%---------------------------------------------------------------------%
%=======================================================================%


%========================= TOOLS FOR  MENUS ============================%
%---------------------------------------------------------------------%
function [DefaultStandardMenus,NBStandardMenus] = GetDefaultFigureMenus

% Use only once for a new version to find menu items.
%-----------------------------------------------------------------
% {'F','E','V','I','T','W','H'} for MATLAB Version 6.0.0.88 (R12)
%-----------------------------------------------------------------

showHiddenVal = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig_TEMPO = figure('visible','off');
lstMenus  = findall(get(fig_TEMPO,'Children'),'flat','type','uimenu');
lstLabels = get(lstMenus,'label');
NBStandardMenus = length(lstLabels);
DefaultStandardMenus = cell(1,NBStandardMenus);
for k=1:NBStandardMenus
    DefaultStandardMenus{k} = lstLabels{k}(2);
end
DefaultStandardMenus = fliplr(DefaultStandardMenus);
delete(fig_TEMPO);
set(0,'ShowHiddenHandles',showHiddenVal);
%---------------------------------------------------------------------%
function h = getMainMenuHdl(fig,item)

lstMenus  = findall(get(fig,'Children'),'flat','type','uimenu');
lstLabels = get(lstMenus,'label');
for k=1:length(lstMenus)
    if isequal(lstLabels{k}(2),item) , h = lstMenus(k); break; end
end
%---------------------------------------------------------------------%
function h = findmenu(lst,item)
%FINDMENU Find menu item.
%   h = findmenu(lst,item)
%   h is the handle of the uimenu which label is item.
%   The search is restricted to the list lst.
%   If no uimenu is found, 0 is returned.

h = 0;
item = lower(item(find(item~=32  & item~='&')));
for k = 1:length(lst)
    lab = get(lst(k),'label');
    lab = lower(lab(find(lab~=' ' & lab~='&')));
    if isequal(lab,item) , h = lst(k); break; end
end
%---------------------------------------------------------------------%
function ind = findSubSTR(sub,S)
ind = [];
for k = 1:length(S)
	dum = findstr(S{k},sub);
	if ~isempty(dum) , ind = k; break; end
end
%---------------------------------------------------------------------%
function liste = copyMenu(liste,cible)

for k=1:length(liste)
    m = liste(k);
    c = findall(m,'type','uimenu','parent',m);
    c = flipud(c);
    m = copyobj(m,cible);
    if ~isempty(c) , copyMenu(c,m); end
    liste(k) = m;
end
set(liste,'HandleVisibility','on');
%---------------------------------------------------------------------%
%=======================================================================%
%=======================================================================%



%=======================================================================%
%---------------------------------------------------------------------%
function defineWfigPROP(fig,s,flag)

wfigPROP = wtbxappdata('get',fig,'WfigPROP');
if ~isempty(wfigPROP) & (nargin<3) , return; end
switch length(s)
  case 0 ,    return
  case 1 ,    ind = 1;
  otherwise , ind = 2;
end
[path,name,ext,ver] = fileparts(s(ind).name);
figParent = gcbf;
wfigPROP  = struct('MakeFun',name,'FigParent',figParent,'FigChild',[]);
wtbxappdata('set',fig,'WfigPROP',wfigPROP);
if ~isempty(figParent)
    wfigPROP = wtbxappdata('get',figParent,'WfigPROP');
    if ~isempty(wfigPROP)
        wfigPROP.FigChild = unique([wfigPROP.FigChild,fig]);
        idx = ~ishandle(wfigPROP.FigChild);
        wfigPROP.FigChild(idx) = [];
        wtbxappdata('set',figParent,'WfigPROP',wfigPROP);
    end
end
%---------------------------------------------------------------------%
%=======================================================================%
