function [out1,out2] = dw1dtrem(option,win_dw1dtool,in3,in4)
%DW1DTREM Discrete Wavelet 1-D tree mode manager.
%   [OUT1,OUT2] = DW1DTREM(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 15-Dec-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.18 $

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
ind_thr_val    = 8;
nb1_stored     = 8;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
ind_graph_area =  1;
ind_view_mode  =  2;
ind_savepath   =  3;
nb4_stored     =  3;

% Tag property of objects.
%-------------------------
tag_pus_anal = 'Pus_Anal';
tag_axe_sig  = 'Axe_Sig_Tre';
tag_axe_ele  = 'Axe_Ele_Tre';
tag_axe_tre  = 'Axe_Tree_Tre';
tag_axe_txt  = 'Axe_Txt_Tre';
tag_s_tre    = 'S_tre';
tag_ss_tre   = 'SS_Tre';
tag_ele_tre  = 'Ele_Tre';
tag_app      = 'App_Tre';
tag_det      = 'Det_Tre';

axe_handles   = findobj(get(win_dw1dtool,'Children'),'flat','type','axes');
txt_a_handles = findobj(axe_handles,'Type','text');

switch option
    case 'ssig'
        % in3 = chk_handle
        %-----------------
        [flg_s_ss,ccfs] = dw1dvmod('get_vm',win_dw1dtool,5);
        val = get(in3,'Value');
        flg_s_ss(2) = val; 
        dw1dvmod('set_vm',win_dw1dtool,5,flg_s_ss,ccfs);
        ss_tre  = findobj(axe_handles,'Tag',tag_ss_tre);
        if val==0
            set(ss_tre,'Visible','off');
        else
            set(ss_tre,'Visible','on');
        end
        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
        if ss_type=='ss'
            str_plus = 'Synthesized';
        elseif ss_type=='cs'
            str_plus  = 'Compressed';
        elseif ss_type=='ds'
            str_plus  = 'De-noised';
        end
        if val==1
            str_title = ['Signal and ' str_plus ' signal.'];
        else
            str_title = ['Signal'];
        end
        axe_sig = findobj(axe_handles,'flat','Tag',tag_axe_sig);
        axes(axe_sig)
        wtitle(str_title,'Parent',axe_sig);

    case 'view'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean
        %-------------------------
        % in4 = level (optional)
        %-------------------------

        % Get Globals.
        %-------------
        Terminal_Prop = mextglob('get','Terminal_Prop');

        old_mode = in3;
        [Wave_Name,Level_Anal,Signal_Size] = ...
                        wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                ind_wav_name,ind_lev_anal,ind_sig_size);
        if nargin==3 , level = Level_Anal; else level = in4; end
        [v_flg,ccfs_m] = dw1dvmod('get_vm',win_dw1dtool,5);
        vis_str = getonoff(v_flg);
        v_s  = vis_str(1,:);
        v_ss = vis_str(2,:);

        axe_sig = findobj(axe_handles,'flat','Tag',tag_axe_sig);
        if isempty(axe_sig)
            dw1dtrem('axes',win_dw1dtool);
            axe_handles = findobj(win_dw1dtool,'Type','axes');
            axe_sig = findobj(axe_handles,'flat','Tag',tag_axe_sig);
        end
        axe_ele = findobj(axe_handles,'flat','Tag',tag_axe_ele);
        axe_txt = findobj(axe_handles,'flat','Tag',tag_axe_txt);
        set([axe_sig axe_ele axe_txt],'Visible','On');

        s_tre   = findobj(axe_sig,'Tag',tag_s_tre);
        ss_tre  = findobj(axe_sig,'Tag',tag_ss_tre);
        ele_tre = findobj(axe_ele,'Tag',tag_ele_tre);
        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
        switch ss_type
            case 'ss' , str_plus = 'Synthesized';
            case 'cs' , str_plus = 'Compressed';
            case 'ds' , str_plus = 'De-noised';
        end

        if v_flg(1)==1
            if v_flg(2)==1
                str_title = ['Signal and ' str_plus ' signal.'];
            else
                str_title = ['Signal'];
            end
        else
            if v_flg(2)==1
                str_title = [str_plus ' signal.'];
            else
                str_title = '';
            end
        end
        if isempty(s_tre)
            [x,ymin,ymax] = dw1dfile('sig',win_dw1dtool,1);
            xmin = 1;  xmax = length(x);
            set(axe_sig,'Xlim',[xmin xmax]);
            col = wtbutils('colors','sig');
            axes(axe_sig);
            line(...
                 'Xdata',[xmin:xmax],...
                 'Ydata',x,...
                 'Color',col,...
                 'Visible',v_s,...
                 'Tag',tag_s_tre,...
                 'Parent',axe_sig);
            set(axe_sig,'Ylim',[ymin ymax]);
        else
            set(s_tre,'Visible',v_s);
        end
        if isempty(ss_tre)
            [x,ymin,ymax] = dw1dfile('ssig',win_dw1dtool,1);
            ylim = get(axe_sig,'Ylim');
            if ylim(1)<ymin , ymin = ylim(1); end
            if ylim(2)>ymax , ymax = ylim(2); end
            col = wtbutils('colors','ssig');
            xmin = 1;  xmax = length(x);
            axes(axe_sig);
            line(...
                 'Xdata',[xmin:xmax],...
                 'Ydata',x,...
                 'Color',col,...
                 'Visible',v_ss,...
                 'Tag',tag_ss_tre,...
                 'Parent',axe_sig);
            set(axe_sig,'Ylim',[ymin,ymax]);
        else
            set(ss_tre,'Visible',v_ss);
        end
        axes(axe_sig)
        wtitle(str_title,'Parent',axe_sig);
        col_app = wtbutils('colors','app',Level_Anal);
        col_det = wtbutils('colors','det',Level_Anal);
        if isempty(ele_tre)
            [x,ymin,ymax] = dw1dfile('app',win_dw1dtool,Level_Anal,3);
            axe = axe_ele;
            axes(axe);
            xmin = 1;  xmax = length(x);
            line(...
                 'Parent',axe,                   ...
                 'Xdata',[xmin:xmax],'Ydata',x,  ...
                 'Color',col_app(Level_Anal,:),  ...
                 'Userdata',Level_Anal,'Tag',tag_ele_tre);
            set(axe,'Ylim',[ymin ymax]);
            wtitle(sprintf(' Approximation at level %d (reconstructed).',Level_Anal),'Parent',axe);
        else
            set(ele_tre,'Visible','on');
        end

        push = findobj(win_dw1dtool,'Style','pushbutton','tag',tag_pus_anal);
        A_or_S = get(push,'String');
        A_or_S = lower(A_or_S(1));
        xdiv = 4;
        ydiv = 12;
        xa   = 1/xdiv;
        xd   = (xdiv-1)/xdiv;
        y    = 1/ydiv;
        dy   = (ydiv-2)/(ydiv*Level_Anal);
        col  = get(axe_txt,'Xcolor');
        lineWidth = 1;
        line(...
             'Parent',axe_txt,               ...
             'Xdata',[xa xa],                ...
             'Ydata',[1/ydiv (ydiv-1)/ydiv], ...
             'LineWidth',lineWidth,          ...
             'Color',col                     ...
             );
        for k = 1:Level_Anal
            line(...
                 'Parent',axe_txt,       ...
                 'Xdata',[xa xd],        ...
                 'Ydata',[y y+dy],       ...
                 'LineWidth',lineWidth,  ...
                 'Color',col             ...
                 );
            y = y+dy;
        end
        
        if A_or_S=='a' , sens = -1; else , sens = 1; end
        y     = 1/ydiv+dy/2;
        lon   = 0.03;
        scaleX = sens*lon;
        scaleY = sens*lon;
        alpha = pi/4;
        theta = pi/2;
        betaP = theta+alpha;
        betaM = theta-alpha;
        for k = 1:Level_Anal
            xx = xa + [0 , scaleX*cos(betaP) , NaN , 0 , scaleX*cos(betaM)]';
            yy = y  + [0 , scaleY*sin(betaP) , NaN , 0 , scaleY*sin(betaM)]';
            line(...
	         'Parent',axe_txt,...
	         'Xdata',xx,'Ydata',yy,...
	         'LineWidth',lineWidth,'Color',col);
            y  = y+dy;
        end

        old_u = get(axe_txt,'Units');
        set(axe_txt,'Units','pixels');
        pos = get(axe_txt,'Position');
        set(axe_txt,'Units',old_u);
        tp  = mextglob('get','Terminal_Prop');
        mul = (tp(1)*pos(3))/(tp(2)*pos(4));
        
        y     = 1/ydiv+dy/2;
        xm    = (xa+xd)/2;
        lon   = 0.02;
        scaleX = 2*sens*lon;
        scaleY = sens*lon;
        alpha = atan(dy/((xd-xa)*mul));
        theta = alpha;
        betaP = theta+alpha;
        betaM = theta-alpha;
        for k = 1:Level_Anal
            xx = xm + [0 , scaleX*cos(betaP) , NaN , 0 , scaleX*cos(betaM)]';
            yy = y  + [0 , scaleY*sin(betaP) , NaN , 0 , scaleY*sin(betaM)]';
            line(...
	         'Parent',axe_txt,...
	         'Xdata',xx,'Ydata',yy,...
	         'LineWidth',lineWidth,'Color',col);
            y = y+dy;
        end
       
        y  = 1/ydiv;
        Ps = [xa;y];
        Pa = [xa*ones(1,Level_Anal) ; y+dy*[1:Level_Anal]];
        Pd = [xd*ones(1,Level_Anal) ; y+dy*[1:Level_Anal]];
        lPts = line(...
                    'Parent',axe_txt,                  ...
                    'Xdata',[Ps(1,:),Pa(1,:),Pd(1,:)], ...
                    'Ydata',[Ps(2,:),Pa(2,:),Pd(2,:)], ...
                    'LineStyle','none', ...
                    'Marker','.',       ...
                    'MarkerSize',28,    ...
                    'Color',col         ...
                    );        

        axes(axe_txt)
        if A_or_S=='a' ,
            wtitle('DWT : Wavelet Tree','Parent',axe_txt);
            sig_nam = 's';
        else
            wtitle('IDWT : Wavelet Tree','Parent',axe_txt);
            sig_nam = 'ss';
        end
        beg_cba = [mfilename '(''select'',' int2str(win_dw1dtool) ','];
        y       = 1/ydiv;
        fontsize = wmachdep('fontsize','normal',6,Level_Anal)+2;
        col     = wtbutils('colors','sig');
        xa = xa-0.5/xdiv;
        xd = xd+0.5/xdiv;
        commonProp = {...
           'Parent',axe_txt,               ...
           'FontWeight','bold',            ...
           'FontSize',fontsize,            ...
           'HorizontalAlignment','center', ...
           'VerticalAlignment','middle',   ...
           'Clipping','on'                 ...
           };
        locProp = {commonProp{:}, ...
                   'String', sig_nam,   ...
                   'Position',[xa y 0], ...
                   'UserData',0,        ...
                   'Color',col,         ...
                   'tag',tag_app        ...
                   };
        txt = text(locProp{:});
        set(txt,'ButtonDownFcn',[beg_cba num2mstr(txt) ');']);

        y = y+dy;
        for k = 1:Level_Anal
            locProp = {commonProp{:}, ...
                       'String',['a' wnsubstr(k)],...
                       'Position',[xa y 0], ...
                       'UserData',k,        ...
                       'Color',col_app(k,:),...
                       'tag',tag_app        ...
                       };
            txt = text(locProp{:});
            set(txt,'ButtonDownFcn',[beg_cba num2mstr(txt) ');']);

            locProp = {commonProp{:}, ...
                       'String',['d' wnsubstr(k)],...
                       'Position',[xd y 0], ...
                       'UserData',k,        ...
                       'Color',col_det(k,:),...
                       'tag',tag_det        ...
                       };
            txt = text(locProp{:});
            set(txt,'ButtonDownFcn',[beg_cba num2mstr(txt) ');']);

            y = y+dy;
        end
        set(axe_txt,'Visible','on')

        % Axes attachment.
        %-----------------
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'tre',old_mode);
        if okNew
            set([axe_sig axe_ele],'Xlim',[1 Signal_Size]);
            dynvtool('init',win_dw1dtool,[],[axe_sig axe_ele],[],[1 0]);
        end

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_sig);

    case 'axes'
        % in3 = level_view
        %-----------------
        Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_lev_anal);
        if nargin==2 , in3 = Level_Anal; end

        % Axes Positions.
        %----------------
        pos_graph = wmemtool('rmb',win_dw1dtool,n_miscella,ind_graph_area);
        pos_win   = get(win_dw1dtool,'Position');
        win_units = get(win_dw1dtool,'Units');

        bdx    = 0.05*pos_win(3);
        bdy    = 0.06*pos_win(4);
        w_used = pos_graph(3)-3*bdx;
        h_used = pos_graph(4)-2*bdy;
        w_tre  = w_used/3;
        h_tre  = h_used;
        y_tre  = pos_graph(2)+bdy;
        w_sig  = (2*w_used)/3;
        h_sig  = (h_used-2*bdy)/2;
        x_sig  = bdx+w_tre+bdx;
        y_sig  = y_tre+h_sig+2*bdy;
        pos_axe_tre = [bdx y_tre w_tre h_tre];
        pos_axe_ele = [x_sig y_tre w_sig h_sig];
        pos_axe_sig = [x_sig y_sig w_sig h_sig];
        axe_sig = axes(...
                        'Parent',win_dw1dtool,  ...
                        'Units',win_units,      ...
                        'Visible','off',        ...
                        'Position',pos_axe_sig, ...
                        'Nextplot','add',       ...
                        'DrawMode','Fast',      ...
                        'Box','On',             ...
                        'Tag',tag_axe_sig       ...
                        );
        axe_ele = axes(...
                        'Parent',win_dw1dtool,  ...
                        'Units',win_units,      ...
                        'Visible','off',        ...
                        'Position',pos_axe_ele, ...
                        'DrawMode','Fast',      ...
                        'Box','On',             ...
                        'Tag',tag_axe_ele       ...
                        );
        axe_txt = axes(...
                        'Parent',win_dw1dtool,  ...
                        'Units',win_units,      ...
                        'Visible','off',        ...
                        'XLim',[0 1],           ...
                        'YDir','reverse',       ...
                        'YLim',[0 1],           ...
                        'Position',pos_axe_tre, ...
                        'DrawMode','Fast',      ...
                        'Box','On',             ...
                        'Xtick',[],             ...
                        'Ytick',[],             ...
                        'Xticklabel',[],        ...
                        'Yticklabel',[],        ...
                        'Tag',tag_axe_txt       ...
                        );

    case 'select'
        % in3 = txt_handle
        %------------------
		selectType = get(win_dw1dtool,'SelectionType');
		if ~isequal(selectType,'normal') , return; end
		
        mousefrm(0,'watch')
        axe_sig = findobj(axe_handles,'flat','Tag',tag_axe_sig);
        axe_ele = findobj(axe_handles,'flat','Tag',tag_axe_ele);
        usr = get(in3,'Userdata');
        col = get(in3,'Color');
        if usr~=0 
            tag = get(in3,'tag');
            if tag==tag_app , app = 1; else , app = 0; end
        end
        delete(get(axe_ele,'Children'));
        if usr==0
            push = findobj(win_dw1dtool,'Style','pushbutton','tag',tag_pus_anal);
            A_or_S  = get(push,'String');
            A_or_S  = lower(A_or_S(1));
            if A_or_S=='a' ,
                str_title = ['Signal (approximation at level 0).'];
            else
                str_title = ['Synthesized signal (approximation at level 0).'];
            end
            [x,ymin,ymax] = dw1dfile('sig',win_dw1dtool,1);
        elseif app
            [x,ymin,ymax] = dw1dfile('app',win_dw1dtool,usr,3);
            str_title = sprintf('Approximation at level %d (reconstructed).', usr);
        else
            [x,set_ylim,ymin,ymax] = dw1dfile('det',win_dw1dtool,usr,1);
            str_title = sprintf('Detail at level %d (reconstructed).', usr);
        end
        xlim = get(axe_sig,'Xlim');
        axes(axe_ele);
        xmin = 1; xmax = length(x);
        line(...
             'Xdata',[xmin:xmax],...
             'Ydata',x,...
             'Color',col,...
             'Userdata',usr,...
             'tag',tag_ele_tre,...
             'Parent',axe_ele);
        set(axe_ele,'Xlim',xlim,'Ylim',[ymin ymax]);
        wtitle(str_title,'Parent',axe_ele)
        mousefrm(0,'arrow')

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_sig      = findobj(lin_handles,'Tag',tag_ss_tre);
        delete(ss_sig);

    case 'clear'
        dynvtool('stop',win_dw1dtool);
        axe_sig = findobj(axe_handles,'flat','tag',tag_axe_sig);
        axe_ele = findobj(axe_handles,'flat','Tag',tag_axe_ele);
        axe_txt = findobj(axe_handles,'flat','Tag',tag_axe_txt);
        out1 = [axe_sig axe_ele axe_txt];
        delete(out1);

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
