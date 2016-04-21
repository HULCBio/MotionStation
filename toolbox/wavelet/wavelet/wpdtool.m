function varargout = wpdtool(option,varargin)
%WPDTOOL Wavelet packets display tool.
%   VARARGOUT = WPDTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-Jan-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.20 $ $Date: 2002/06/17 12:18:56 $
        
% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% MemBloc1 of stored values.
%---------------------------
n_miscella     = 'WpDisp_Misc';
ind_graph_area = 1;
ind_wave_fam   = 2;
ind_wave_nam   = 3;
ind_maxnum     = 4;
ind_refinment  = 5;
nb1_stored     = 5;

% Tag property of objects.
%-------------------------
tag_prec_val  = 'Prec_Val';
tag_cmd_frame = 'Cmd_Frame';
tag_pop_mod   = 'Pop_Mod';
tag_display   = 'Display';
tag_pus_inf1  = 'Pus_Inf1';
tag_pus_inf2  = 'Pus_Inf2';


switch option
    case 'create'
        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,  ...
         Pop_Min_Width,X_Spacing,Y_Spacing,Def_FraBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                'Pop_Min_Width','X_Spacing','Y_Spacing','Def_FraBkColor' ...
                );

        % Window initialization.
        %----------------------
        win_title = 'Wavelets Packets W System Functions Display';
        [win_loctool,pos_win,win_units,str_numwin,...
                frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
                    wfigmngr('create',win_title,winAttrb,'ExtFig_WDisp',mfilename);  
        varargout{1} = win_loctool;
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_loctool,'Wavelet Packet Dis&play','WPDI_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_loctool,'Building Wavelet Packets','WPDI_BUILDING');
		wfighelp('addHelpItem',win_loctool,'Wavelet Packets Atoms','WPDI_ATOMS');

        % Begin waiting.
        %---------------
        set(wfindobj('figure'),'Pointer','watch');

        % General graphical parameters initialization.
        %--------------------------------------------
        dx = X_Spacing;   dx2 = 2*dx;
        dy = Y_Spacing;   dy2 = 2*dy;
        d_txt = (Def_Btn_Height-Def_Txt_Height);
        push_width = (pos_frame0(3)-4*dx)/2;

        % Position property of objects.
        %------------------------------
        xlocINI      = pos_frame0([1 3]);
        ybottomINI   = pos_win(4)-1.5*Def_Btn_Height-dy2;
        y_low        = ybottomINI-2*Def_Btn_Height;
        x_left       = pos_frame0(1)+dx2;
        pos_prec_txt = [x_left, y_low+d_txt/2, Def_Btn_Width, Def_Txt_Height];
        x_left       = x_left+Def_Btn_Width+dx;
        pos_prec_val = [x_left , y_low , Def_Btn_Width , Def_Btn_Height];
        x_left       = pos_frame0(1)+dx2;
        y_low        = y_low-2*Def_Btn_Height;
        pos_txt_mod  = [x_left , y_low , 2*Def_Btn_Width , Def_Btn_Height];
        y_low        = y_low-Def_Btn_Height;
        x_left       = pos_frame0(1)+(pos_frame0(3)-Pop_Min_Width)/2;
        pos_pop_mod  = [x_left , y_low , Pop_Min_Width+dx , Def_Btn_Height];
        w_uic        = 3*push_width/2;	
		xborder      = (pos_frame0(3)-w_uic)/2;
        x_left       = pos_frame0(1)+xborder;
        y_low        = pos_prec_txt(2)-7*Def_Btn_Height;
        pos_display  = [x_left , y_low , w_uic , 2*Def_Btn_Height];
        y_low        = y_low-3*Def_Btn_Height;
        x_left       = pos_frame0(1)+dx2;
        pos_inf_txt  = [x_left , y_low , 2.5*Def_Btn_Width , Def_Btn_Height];
        pos_pus_inf1    = pos_display;
        pos_pus_inf1(2) = pos_inf_txt(2)-2*Def_Btn_Height-dy;
        pos_pus_inf2    = pos_pus_inf1;
        pos_pus_inf2(2) = pos_pus_inf1(2)-3*Def_Btn_Height;
		% pos_pus_inf1(1) = pos_pus_inf1(1)-xborder/2;
		% pos_pus_inf1(3) = pos_pus_inf1(3)+xborder;

        % String property of objects.
        %----------------------------
        str_mod_txt  = 'Wav. Pack. from 0 to :';
        str_pop_mod  = ['1 ' ; '2 ' ; '3 ' ; '4 ' ; '5 ' ; '6 ' ; '7 ' ; '8 ' ; ...
                        '9 ' ; '10' ; '11' ; '12' ; '13' ; '14'] ;
        str_display  = 'Display';
        str_inf_txt  = 'Information on:';
        str_inf1     = 'Haar Family (HAAR)';
        str_inf2     = 'W Systems';
        str_prec_txt = 'Refinement';
        str_prec_val = ['5 ' ; '6 ' ; '7 ' ; '8 ' ; '9 ' ; '10' ; '11' ; '12'];

        % Command part construction of the window.
        %-----------------------------------------
        utanapar('create',win_loctool, ...
                 'xloc',xlocINI,'bottom',ybottomINI,...
                 'datflag',0,'levflag',0,...
                 'wtype','owt' ...
                 );
        comFigProp = {'Parent',win_loctool,'Unit',win_units};
        comPopProp = {comFigProp{:},'Style','Popup'};
        comPusProp = {comFigProp{:},'Style','Pushbutton'};
        comTxtProp = {comFigProp{:},'Style','Text', ...
           'HorizontalAlignment','left','Backgroundcolor',Def_FraBkColor};

        Tooltip      = 'Number of iterations used to calculate the wavelet packets';		
        txt_prec_txt = uicontrol(comTxtProp{:}, ...
                                 'Position',pos_prec_txt,...
                                 'String',str_prec_txt,...
                                 'Tooltip',Tooltip ...
                                  );

        pop_prec_val = uicontrol(comPopProp{:},...
                                 'Position',pos_prec_val,...
                                 'String',str_prec_val,...
                                 'Value',4,...
                                 'Tooltip',Tooltip,...
                                 'Tag',tag_prec_val...
                                 );

        txt_mod_txt  = uicontrol(comTxtProp{:},...
                                 'Position',pos_txt_mod,...
                                 'String',str_mod_txt...
                                 );

        pop_mod_dis  = uicontrol(comPopProp{:},...
                                 'Position',pos_pop_mod,...
                                 'String',str_pop_mod,...
                                 'Value',6,...
                                 'Tag',tag_pop_mod...
                                 );

        pus_display  = uicontrol(comPusProp{:},...
                                 'Position',pos_display,...
                                 'String',xlate(str_display),...
                                 'Tag',tag_display...
                                 );

        txt_inf_txt  = uicontrol(comTxtProp{:},...
                                 'Position',pos_inf_txt,...
                                 'String',str_inf_txt...
                                 );

        pus_inf1     = uicontrol(comPusProp{:},...
                                 'Position',pos_pus_inf1,...
                                 'String',xlate(str_inf1),...
                                 'Tag',tag_pus_inf1...
                                 );

        pus_inf2     = uicontrol(comPusProp{:},...
                                 'Position',pos_pus_inf2,...
                                 'String',xlate(str_inf2),...
                                 'Tag',tag_pus_inf2...
                                 );

        % Callbacks update.
        %------------------
        utanapar('set_cba_num',win_loctool,[pus_display]);
        [pop_fam,pop_num] = utanapar('handles',win_loctool,'fam','num');
        cb_fam = get(pop_fam,'Callback');
        cb_num = get(pop_num,'Callback');
        cba_upd_fam = [mfilename '(''upd_fam'',' str_numwin ');'];
        cba_update  = [mfilename '(''new'',' str_numwin ');'];
        cba_draw_1d = [mfilename '(''draw1d'',' str_numwin ');'];
        cba_inf1    = [mfilename '(''inf1'',' str_numwin ');'];
        cba_inf2    = [mfilename '(''inf2'',' str_numwin ');'];
        set(pop_fam,'Callback',[cb_fam , cba_upd_fam]);
        set(pop_num,'Callback',[cb_num , cba_update]);
        set(pop_prec_val,'Callback',cba_update);
        set(pop_mod_dis,'Callback',cba_update);
        set(pus_display,'Callback',cba_draw_1d);
        set(pus_inf1,'Callback',cba_inf1);
        set(pus_inf2,'Callback',cba_inf2);

        % Setting units to normalized.
        %-----------------------------
        Pos_Graphic_Area = Pos_Graphic_Area./[pos_win(3:4),pos_win(3:4)];
        set(findobj(win_loctool,'Units','pixels'),'Units','normalized');

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_WPDI_GUI = [txt_prec_txt,pop_prec_val,txt_mod_txt,pop_mod_dis];
		wfighelp('add_ContextMenu',win_loctool,hdl_WPDI_GUI,'WPDI_GUI');
		%-------------------------------------

        % Memory for stored values.
        %--------------------------
        wmemtool('ini',win_loctool,n_miscella,nb1_stored);
        wmemtool('wmb',win_loctool,n_miscella,...
                       ind_graph_area,Pos_Graphic_Area,...
                       ind_wave_fam,'haar', ...
                       ind_wave_nam,'haar', ...
                       ind_maxnum,6,         ...
                       ind_refinment,0       ...
                       );

        % End waiting.
        %-------------
        set(wfindobj('figure'),'Pointer','arrow');

    case 'upd_fam'
        %**********************************************************%
        %** OPTION = 'upd_fam' -  UPDATE OF THE WAVELET FAMILY   **%
        %**********************************************************%
        win_loctool = varargin{1};
        new = wpdtool('new',win_loctool);
        if new==0 , return; end

        % Handles of tagged objects.
        %---------------------------
        pus_handles  = findobj(win_loctool,'Style','pushbutton');
        pus_inf1     = findobj(pus_handles,'Tag',tag_pus_inf1);

        % Set visible on or off the wavelet number if exists.
        %----------------------------------------------------
        wav_nam = cbanapar('get',win_loctool,'wav');
        [wav_fn,wav_fsn,tabNums] = wavemngr('fields',wav_nam,'fn','fsn','tabNums');
        if size(tabNums,1)<2 ,add = ' wavelet'; else , add = ' wavelets'; end
		strPush = sprintf('%s Family (%s)', wav_fn, upper(wav_fsn));		
        set(pus_inf1,'String',strPush);		

    case 'inf1'
        %*****************************************%
        %** OPTION = 'inf1' - LOCAL INFORMATION **%
        %*****************************************%
        win_loctool     = varargin{1};

        % Getting wavelet.
        %-----------------
        wav_nam = cbanapar('get',win_loctool,'wav');
        wav_fam = wavemngr('fam_num',wav_nam);
        infotxt = [deblankl(wav_fam) 'info.m'];
        [old_info,fig] = whelpfun('getflag');
        if ~isempty(old_info) & strcmp(infotxt,old_info)
            figure(fig); return;
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_loctool,'Wait ... loading');

        [str_inf,fid] = wreadinf(infotxt,'noerror');
        if fid==-1
            msg = sprintf('File %s not found !', infotxt);
            errargt(mfilename,msg,'msg');
            wwaiting('off',win_loctool);
            return
        else
            dim     = size(str_inf);
            rowfam  = str_inf(1,:);
            str_inf = str_inf(2:dim(1),:);
            col = 1;
            while all(str_inf(:,col)==' ') , col = col+1; end
            blk  = ' ' ;
            str_inf = [rowfam ; ...
                       str_inf(:,col:dim(2)) blk*ones(dim(1)-1,col-1) ];
        end
        ftnsize = wmachdep('fontsize','winfo');
        whelpfun('create',str_inf,infotxt,ftnsize);

        % End waiting.
        %-------------
        wwaiting('off',win_loctool);

    case 'inf2'
        %*****************************************%
        %** OPTION = 'inf2' - LOCAL INFORMATION **%
        %*****************************************%
        win_loctool     = varargin{1};

        % Handles of tagged objects.
        %---------------------------
        infotxt         = 'infowsys.m';
        [old_info,fig]  = whelpfun('getflag');
        if ~isempty(old_info) & strcmp(infotxt,old_info)
            figure(fig); return;
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_loctool,'Wait ... loading');

        [str_inf,fid] = wreadinf(infotxt,'noerror');
        if fid==-1
            msg = sprintf('File %s not found !', infotxt);
            errargt(mfilename,msg,'msg');
            wwaiting('off',win_loctool);
            return
        end
        ftnsize = wmachdep('fontsize','winfo');
        whelpfun('create',str_inf,infotxt,ftnsize);

        % End waiting.
        %-------------
        wwaiting('off',win_loctool);

    case 'draw1d'
        %************************************************%
        %** OPTION = 'draw1d' - DRAW AXES IN 1D        **%
        %************************************************%
        win_loctool = varargin{1};
        [new,Wave_Fam,Wave_Nam,nb_func,prec_val] = wpdtool('new',win_loctool);
        if new==0 , return; end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_loctool,'Wait ... computing');

        % Handles of tagged objects.
        %---------------------------
        fra_handles = findobj(win_loctool,'Style','frame');
        hdl_frame0  = findobj(fra_handles,'Tag',tag_cmd_frame);

        % Update parameters selection before drawing.
        %-------------------------------------------
        wmemtool('wmb',win_loctool,n_miscella, ...
                       ind_wave_fam,Wave_Fam,  ...
                       ind_wave_nam,Wave_Nam,  ...
                       ind_maxnum,nb_func,     ...
                       ind_refinment,prec_val  ...
                       );

        % General graphical parameters initialization.
        %--------------------------------------------
        pos_g_area     = wmemtool('rmb',win_loctool,n_miscella,ind_graph_area);
        pos_hdl_frame0 = get(hdl_frame0,'Position');
        win_units      = 'normalized';
        pos_win        = get(win_loctool,'Position');
        bdx            = 0.08*pos_win(3);
        bdy            = 0.09*pos_win(4);
        bdy_d          = bdy;
        bdy_u          = bdy;
        w_graph        = pos_hdl_frame0(1);
        h_graph        = pos_g_area(4);

        % Computing and displaying wavelets and filters.
        %-----------------------------------------------
        wtype = wavemngr('type',Wave_Nam);
        if wtype==1
            str_wintitle = [Wave_Fam '  Wavelet Packets --> ' Wave_Nam];
        else
            % End waiting.
            %-------------
            wwaiting('off',win_loctool);
            return;
        end
        nb_axes = nb_func+1;
        pos_axe = zeros(nb_func,4);
        if nb_axes<11
            nb2    = ceil(nb_axes/2);
            w_axe  = (w_graph-3*bdx)/2;
            h_axe  = (h_graph-(nb2-1)*bdy-bdy_u-bdy_d)/nb2;
            x_left = bdx;
            y_low  = pos_g_area(2)+pos_g_area(4)-bdy_u-h_axe;
            for k= 1:nb2
                pos_axe(2*k-1,:) = [x_left,y_low,w_axe,h_axe];
                pos_axe(2*k,:)   = [x_left+w_axe+bdx,y_low,w_axe,h_axe];
                y_low            = y_low-h_axe-bdy;
            end
        else
            nb2    = ceil(nb_axes/3);
            w_axe  = (w_graph-4*bdx)/3;
            h_axe  = (h_graph-(nb2-1)*bdy-bdy_u-bdy_d)/nb2;
            x_left = bdx;
            y_low  = pos_g_area(2)+pos_g_area(4)-bdy_u-h_axe;
            for k= 1:nb2
                pos_axe(3*k-2,:) = [x_left,y_low,w_axe,h_axe]    ;
                xl               = x_left+w_axe+bdx;
                pos_axe(3*k-1,:) = [xl,y_low,w_axe,h_axe];
                xl               = xl+w_axe+bdx;
                pos_axe(3*k,:)   = [xl,y_low,w_axe,h_axe];
                y_low            = y_low-h_axe-bdy;
            end
        end
        [wpws,xval] = wpfun(Wave_Nam,nb_func,prec_val);
        hdl_axe =  zeros(1,nb_func);
        xaxis   = [min(xval)    max(xval)];
        % if isequal(Wave_Nam,'dmey') , xaxis = [40 60]; end 
        if ~isequal(get(0,'CurrentFigure'),win_loctool)
            figure(win_loctool);
        end
        for k= 1:nb_axes
            yaxis   = [min(wpws(k,:))-eps   max(wpws(k,:))+eps];
            ecart   = abs(yaxis(2)-yaxis(1))/20;
            yaxis(1) = yaxis(1)-ecart;
            yaxis(2) = yaxis(2)+ecart;
            hdl_axe(k) = axes(...
                              'Parent',win_loctool,   ...
                              'Units',win_units,      ...
                              'Position',pos_axe(k,:),...
                              'DrawMode','Fast',      ...
                              'Xlim',xaxis,           ...
                              'Ylim',yaxis,           ...
                              'Box','On'              ...
                              );
            line(...
                 'Xdata',xval,...
                 'Ydata',wpws(k,:),...
                 'Color','r',...
                 'Parent',hdl_axe(k));
            strlab = ['W' sprintf('%.0f',k-1)];
            if     k==1 , strlab = [strlab '  - phi function -'];
            elseif k==2 , strlab = [strlab '  - psi function -'];
            end
            wtitle(strlab,'Parent',hdl_axe(k));
        end

        % Display status line.
        %---------------------
        wfigtitl('string',win_loctool,str_wintitle,'on');

        % Axes attachment.
        %-----------------
        dynvtool('init',win_loctool,[],hdl_axe,[],[0 0]);

        % Setting units to normalized.
        %-----------------------------
        set(findobj(win_loctool,'Units','pixels'),'Units','normalized');

        % End waiting.
        %-------------
        wwaiting('off',win_loctool);

    case 'new'
        %*************************************************%
        %** OPTION = 'new' -  test drawing parameters   **%
        %*************************************************%
        win_loctool     = varargin{1};

        % Handles of tagged objects.
        %---------------------------
        pop_handles  = findobj(win_loctool,'Style','popupmenu');
        pop_mod_dis  = findobj(pop_handles,'Tag',tag_pop_mod);
        pop_prec_val = findobj(pop_handles,'Tag',tag_prec_val);

        % Test Main parameters selection before drawing.
        %-----------------------------------------------
        Wave_Nam = cbanapar('get',win_loctool,'wav');
        Wave_Fam = wavemngr('fam_num',Wave_Nam);
        prec_val = get(pop_prec_val,'Value')+4;
        ind      = get(pop_mod_dis,'value');
        strnum   = get(pop_mod_dis,'string');
        nb_func  = wstr2num(strnum(ind,:));

        varargout{1} = 0;
        [wfam,wnam,maxn,raf] = wmemtool('rmb',win_loctool,n_miscella,...
                                ind_wave_fam,ind_wave_nam,...
                                ind_maxnum,ind_refinment);
        if raf~=prec_val | ~strcmp(wnam,Wave_Nam) | ...
           ~strcmp(wfam,Wave_Fam) | nb_func~=maxn
            varargout = {1,Wave_Fam,Wave_Nam,nb_func,prec_val};
        else
            varargout{1} = 0;
            return
        end

        % Setting refinment to 0 (as flag).
        %----------------------------------
        wmemtool('wmb',win_loctool,n_miscella,ind_refinment,0);

        % Cleaning the graphical part.
        %-----------------------------
        dynvtool('stop',win_loctool);
        axe_handles = findobj(get(win_loctool,'children'),'flat', ...
                         'type','axes','visible','on');
        delete(axe_handles);
        wfigtitl('vis',win_loctool,'off');

    case 'demo'
        %*******************************************%
        %** OPTION = 'demo' -  for DEMOS or TESTS **%
        %*******************************************%
        win_loctool = varargin{1};
        Wave_Nam    = varargin{2};

        % Handles of tagged objects.
        %---------------------------
        children     = get(win_loctool,'Children');
        uic_handles  = findobj(children,'flat','type','uicontrol');
        pop_handles  = findobj(uic_handles,'Style','popupmenu');
        pop_prec_val = findobj(pop_handles,'Tag',tag_prec_val);
        pop_mod_dis  = findobj(pop_handles,'Tag',tag_pop_mod);
        pus_handles  = findobj(win_loctool,'Style','pushbutton');
        pus_inf1     = findobj(pus_handles,'Tag',tag_pus_inf1);

        cbanapar('set',win_loctool,'wav',Wave_Nam);
        [Wave_Fam,tabNums] = wavemngr('fields',Wave_Nam,'fsn','tabNums');

        if nargin>3
            set(pop_prec_val,'Value',varargin{3});
            if nargin>4 , set(pop_mod_dis,'Value',varargin{4}); end 
        end
        new = wpdtool('new',win_loctool);
        str_inf1 = [upper(Wave_Fam) ' wavelet'] ;
        if size(tabNums,1)>1
            str_inf1 = [str_inf1 's'] ;
        end
        set(pus_inf1,'String',str_inf1);
        wpdtool('draw1d',win_loctool);

    case 'close'

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
