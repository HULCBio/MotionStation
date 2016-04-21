function varargout = utthrset(option,in2,in3)
%UTTHRSET Utilities for threshold settings.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-May-97.
%   Last Revision: 16-Jan-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/06/17 12:19:38 $

% MemBloc of stored values.
%==========================
% MB1.
%-----
n_membloc1  = 'ReturnTHR_Bloc';
ind_ret_fig = 1;
ind_tog_thr = 2;
ind_status  = 3;
nb1_stored  = 3;

% Same bloc in utthrw1d.
%-----------------------
n_memblocTHR   = 'MB_ThrStruct';
ind_thr_struct = 1;
ind_int_thr    = 2;

% Tag property.
%--------------
tag_figThresh = 'Fig_Thresh';
tag_pus_close = 'Close';

% Tag property (2).
%------------------
tag_lineH_up   = 'LH_u';
tag_lineH_down = 'LH_d';
tag_lineV      = 'LV';

switch option
    case 'init'
        % Handle of Calling Toggle Button.
        %---------------------------------
        switch nargin
          case 1 , tog_thr = gcbo;
          case 2 , tog_thr = in2;
        end
        calling_Fig = get(tog_thr,'Parent');
        oldFig = wfindobj('figure','tag',tag_figThresh);
        existFig = ~isempty(oldFig);
        if existFig
            existFig = 0;
            for k = 1:length(oldFig)
                oldCall = wmemtool('rmb',oldFig(k),n_membloc1,ind_ret_fig);
                if isequal(oldCall,calling_Fig)
                   existFig = oldFig(k);
                   break
                end
            end
        end

        if existFig == 0
             [den_struct,int_DepThr_Cell] = ...
                 wmemtool('rmb',calling_Fig,n_memblocTHR, ...
                          ind_thr_struct,ind_int_thr);
             nb = size(den_struct,1);
             jj = zeros(nb,1);
             for k = 1:nb
                 jj(k) = ~isempty(den_struct(k).thrParams);
             end
             NB_lev = length(find(jj>0));
             NB_Max_Int = 6;

            % Create window.
            %---------------
            [Def_Txt_Height,Def_Btn_Height] = ...
                mextglob('get','Def_Txt_Height','Def_Btn_Height');
            pos_win = get(0,'DefaultfigurePosition');
            pos_win(3) = 6*pos_win(3)/5;
            leftx = 45;   rightx  = 160;
            topy  = 30;   bottomy = 60;
            bdx   = 30;   bdy     = 30;
            callName = get(calling_Fig,'Name');
            lenName  = length(callName);
            if lenName<36
                strDEB = ['Interval Dependent Threshold Settings for '];
            else
                strDEB = ['Int. Dependent Threshold Settings for '];
            end
            lenStrDEB = length(strDEB);
            lenTOT = lenName+lenStrDEB;
            strDEB = [strDEB callName];            
            if lenTOT>72 , strDEB = [strDEB(1:72) '...']; end
            strName  = [strDEB ' (fig. ' int2str(calling_Fig),')'];
            fig = wfigmngr('init',      ...
                     'Name',strName,    ...
                     'Position',pos_win,...
                     'Visible','Off',   ...
                     'Tag',tag_figThresh...
                     );
            wfigmngr('extfig',fig,'ExtFig_ThrSet')

			% Add Help for Tool.
			%------------------
			wfighelp('addHelpTool',fig,'&One-Dimensional Local Thresholding','IDTS_GUI');

			% Add Help Item.
			%----------------
			wfighelp('addHelpItem',fig,'Variance Adaptive Thresholding','VARTHR');
	
            set(fig,'Visible','On')
            xprop = (pos_win(3)+bdx-rightx)/pos_win(3);
            pos_dyn_visu = dynvtool('create',fig,xprop,0);
            ylow = pos_dyn_visu(4);
            pos_gra = [0, pos_dyn_visu(4), pos_win(3), pos_win(4)-ylow];

            % Creating axes and uicontrols.
            %==============================
            noINT_DEP = isempty(int_DepThr_Cell);

            % Positions
            %-----------
            d_txt   = (Def_Btn_Height-Def_Txt_Height)/2;
            w_fra   = rightx-bdx;
            x_fra   = pos_gra(3)-w_fra;
            pos_fra = [x_fra 0 w_fra pos_win(4)+5];
            bdx     = 6;
            bdy     = 6;
            h_txt   = Def_Txt_Height;
            h_btn   = Def_Btn_Height;
            w_fra_lev = w_fra-2*bdx;
            x_fra_lev = x_fra+bdx;
            w_pus     = (5*w_fra_lev)/6;
            x_pus     = x_fra_lev+(w_fra_lev-w_pus)/2; 

            h_fra_lev   = h_btn+2*bdy;
            y_fra_lev   = pos_win(4)-h_fra_lev-2*bdy;
            pos_fra_lev = [x_fra_lev y_fra_lev w_fra_lev h_fra_lev];            
            w_uic       = (w_fra_lev-2*bdx)/2;
            x_uic       = x_fra_lev+bdx;
            y_uic       = y_fra_lev+bdy;
            pos_txt_lev = [x_uic, y_uic+d_txt/2, w_uic, h_txt];
            x_uic       = x_uic+w_uic;
            pos_pop_lev = [x_uic, y_uic, w_uic, h_btn];

            y_fra_top   = y_fra_lev-6*bdy;
            w_uic       = w_fra_lev-bdx;
            x_uic       = x_fra_lev+(w_fra_lev-w_uic)/2;
            y_uic       = y_fra_top-h_txt-bdy;
            pos_txt_lim = [x_uic y_uic w_uic h_txt];        
            h_uic       = 1.5*h_btn;
            y_uic       = y_uic-h_uic-2*bdy;
            pos_pus_del = [x_pus, y_uic, w_pus, h_uic];
            y_uic       = y_uic-h_uic-2*bdy;
            pos_pus_pro = [x_pus, y_uic, w_pus, h_uic];
            y_fra_lim   = y_uic-bdy;
            h_fra_lim   = y_fra_top-y_fra_lim;
            pos_fra_lim = [x_fra_lev y_fra_lim w_fra_lev h_fra_lim];

            y_fra_top   = y_fra_lim-6*bdy;
            w_uic       = w_fra_lev-bdx;
            x_uic       = x_fra_lev+(w_fra_lev-w_uic)/2;
            h_def       = 2*h_txt;
            y_uic       = y_fra_top-h_def-bdy;
            pos_txt_def = [x_uic y_uic w_uic h_def];
            w_uic       = (w_fra_lev-2*bdx)/2;
            x_uic       = x_fra_lev+bdx;
            y_uic       = y_uic-h_btn-1*bdy;
            pos_txt_num = [x_uic, y_uic+d_txt/2, w_uic, h_txt];
            x_uic       = x_uic+w_uic;
            pos_pop_num = [x_uic, y_uic, w_uic, h_btn];
            h_uic       = 1.5*h_btn;
            w_uic       = (2*w_fra_lev)/3;
            if noINT_DEP , y_uic = y_uic-0.5*h_btn; end
            pos_pus_gen = [x_pus, y_uic, w_pus, h_uic];
            y_fra_def   = y_uic-bdy;
            h_fra_def   = y_fra_top-y_fra_def;
            pos_fra_def = [x_fra_lev y_fra_def w_fra_lev h_fra_def];

            y_uic       = y_uic-h_uic-8*bdy;
            y_uic       = h_btn/2;
            pos_close   = [x_pus y_uic w_pus h_uic];

            % Strings
            %--------
            str_txt_lev = 'Level';
            str_levels  = int2str([1:NB_lev]');
            str_txt_lim = 'Interval Delimiters';
            str_pus_del = 'Delete';
            tip_pus_pro = 'Propagate intervals to all levels';
            str_pus_pro = 'Propagate';
            str_txt_num = 'Number';
            str_pop_num = int2str([1:NB_Max_Int]');
            str_pus_gen = 'Generate';
            str_close   = 'Close';

            if noINT_DEP
                strBEG = '    Generate    ';
                strEND = 'Default Intervals';
                toolTipGEN = 'Generate Interval Dependent Thresholds';
                visNum = 'Off'; visGen = 'On';
            else
                strBEG = 'Select Number';
                strEND = 'of Intervals ';
                toolTipGEN = 'Select Number of Intervals';
                visNum = 'On'; visGen = 'Off';
            end
            str_txt_def = strvcat(strBEG,strEND);

            % Create UIC and Axes.
            %---------------------
            commonProp = {'Parent',fig,'Unit','pixels'}; 
            fra_ini  = uicontrol(...
                        commonProp{:},   ...
                        'Style','frame', ...
                        'Position', pos_fra ...
                        );

            fra_lev  = uicontrol(...
                        commonProp{:},  ...
                        'Style','frame',...
                        'Position', pos_fra_lev ...
                        );

            txt_lev = uicontrol(...
                        commonProp{:},  ...
                        'Style','text', ...
                        'HorizontalAlignment','left', ...
                        'Position',pos_txt_lev,       ...
                        'String',str_txt_lev ...
                        );

            pop_lev = uicontrol(...
                        commonProp{:},  ...
                        'Style','Popup',...
                        'Position',pos_pop_lev, ...
                        'String',str_levels,    ...
                        'Userdata',1            ...
                        );

            fra_lim  = uicontrol(...
                        commonProp{:},  ...
                        'Style','frame',...
                        'Position', pos_fra_lim ...
                        );

            txt_lim = uicontrol(...
                        commonProp{:},  ...
                        'Style','text', ...
                        'HorizontalAlignment','Center', ...
                        'Position',pos_txt_lim,       ...
                        'String',str_txt_lim ...
                        );

            pus_pro = uicontrol(...
                        commonProp{:},...
                        'Style','Pushbutton',  ...
                        'Position',pos_pus_pro, ...
                        'String',xlate(str_pus_pro),   ...
                        'Enable','On',         ...
                        'TooltipString',xlate(tip_pus_pro) ...
                        );

            pus_del = uicontrol(...
                        commonProp{:},     ...
                        'Style','Pushbutton',   ...
                        'Position',pos_pus_del, ...
                        'String',xlate(str_pus_del),   ...
                        'Interruptible','on'    ...
                        );

            fra_def  = uicontrol(...
                        commonProp{:},  ...
                        'Style','frame',...
                        'Position', pos_fra_def ...
                        );

            txt_def = uicontrol(...
                        commonProp{:},  ...
                        'Style','text', ...
                        'HorizontalAlignment','Center', ...
                        'Max',2,                ...
                        'Position',pos_txt_def, ...
                        'ToolTip',toolTipGEN,   ...
                        'String',str_txt_def    ...
                        );

            txt_num = uicontrol(...
                        commonProp{:},  ...
                        'Style','text', ...
                        'Visible',visNum, ...
                        'HorizontalAlignment','left', ...
                        'Position',pos_txt_num,       ...
                        'ToolTip',toolTipGEN,...
                        'String',str_txt_num ...
                        );

            pop_num = uicontrol(...
                        commonProp{:},  ...
                        'Style','Popup',...
                        'Visible',visNum, ...
                        'Position',pos_pop_num, ...
                        'ToolTip',toolTipGEN,   ...
                        'String',str_pop_num    ...
                        );

            pus_gen = uicontrol(...
                        commonProp{:},          ...
                        'Style','Pushbutton',   ...
                        'Visible',visGen,       ...
                        'Position',pos_pus_gen, ...
                        'String',xlate(str_pus_gen),   ...
                        'ToolTip',toolTipGEN,   ...
                        'Interruptible','on'    ...
                        );

            pus_close = uicontrol(...
                        commonProp{:},        ...
                        'Style','Pushbutton', ...
                        'Position',pos_close, ...
                        'String',xlate(str_close),   ...
                        'Interruptible','on', ...
                        'Tag',tag_pus_close,  ...
                        'Userdata',0          ...
                        );

            pos_axe = pos_gra+[leftx bottomy -(leftx+rightx) -(bottomy+topy)];
            ax_hdl  = axes(...
                        commonProp{:},     ...
                       'Position',pos_axe, ...
                       'box','on');
            ind_lev = 1;

            % Setting Callback.
            %------------------
            handles = ...
              [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
            if nargout>0 , varargout{1} = handles; end
            handles    = num2mstr(handles);
            cb_pop_lev = [mfilename '(''chg_level'',' handles ');'];
            cb_pus_del = [mfilename '(''del_Delimiters'',' handles ');'];
            cb_pus_pro = [mfilename '(''propagate'',' handles ');'];
            cb_pop_num = [mfilename '(''gen_Intervals'',' handles ');'];
            cb_pus_gen = [mfilename '(''gen_Intervals'',' handles ');'];
            cb_close   = wfigmngr('attach_close',fig,mfilename,'cond');
            set(pop_lev,'Callback',cb_pop_lev);
            set(pus_del,'Callback',cb_pus_del);
            set(pus_pro,'Callback',cb_pus_pro);
            set(pop_num,'Callback',cb_pop_num);
            set(pus_gen,'Callback',cb_pus_gen);
            set(pus_close,'Callback',cb_close);

            % Waiting Text construction.
            %---------------------------
            wwaiting('create',fig,xprop);

            %  Normalization.
            %----------------
            pos_gra = wfigmngr('normalize',fig,pos_gra);
            set(fig,'visible','on')
        else
          pus_close = wfindobj(existFig,...
                          'style','Pushbutton','Tag',tag_pus_close);
          eval(get(pus_close,'Callback'));
          return
        end

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_GENER_VARTHR = [fra_lim,txt_lim,pus_pro,pus_del];
		hdl_MODIF_VARTHR = [fra_def,txt_def,txt_num,pop_num,pus_gen];
		wfighelp('add_ContextMenu',fig,hdl_GENER_VARTHR,'GENER_VARTHR');
		wfighelp('add_ContextMenu',fig,hdl_MODIF_VARTHR,'MODIF_VARTHR');		
		%-------------------------------------

        % Memory blocks update.
        %----------------------
        wmemtool('wmb',fig,n_membloc1,...
                       ind_ret_fig,calling_Fig,ind_tog_thr,tog_thr,...
                       ind_status,0);
        wmemtool('wmb',fig,n_memblocTHR,...
                       ind_thr_struct,den_struct,...
                       ind_int_thr,int_DepThr_Cell ...
                       );

        % Plotting lines.
        %----------------
        plotlines(fig,ax_hdl,den_struct(ind_lev),ind_lev)

    case 'chg_level'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig     = in2(1);
        ax_hdl  = in2(2);
        pop     = in2(3);
        old_lev = get(pop,'Userdata');
        new_lev = get(pop,'Value');
        if old_lev==new_lev , return; end
        lHu     = findobj(ax_hdl,'tag',tag_lineH_up);
        cbthrw1d('upd_thrStruct',fig,lHu);
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        set(pop,'Userdata',new_lev)
        plotlines(fig,ax_hdl,thrStruct(new_lev),new_lev);

    case 'del_Delimiters'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig   = in2(1);
        axe   = in2(2);
        pop_num = in2(6);
        lines = findobj(axe,'type','line');
        lHu   = findobj(lines,'tag',tag_lineH_up);
        lHd   = findobj(lines,'tag',tag_lineH_down);
        lV    = findobj(lines,'tag',tag_lineV);
        xh    = get(lHu,'Xdata');
        yh    = get(lHu,'Ydata');
        xh    = xh([1 length(xh)]);
        yhok  = yh(~isnan(yh));
        yh    = mean(yhok);
        yh    = [yh yh];
        if ~isempty(lV),  delete(lV); end
        set(lHu,'Xdata',xh,'Ydata',yh)
        set(lHd,'Xdata',xh,'Ydata',-yh)
        cbthrw1d('upd_thrStruct',fig,lHu);

    case 'gen_Intervals'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig     = in2(1);
        ax_hdl  = in2(2);
        pop_lev = in2(3);
        txt_def = in2(4);
        txt_num = in2(5);
        pop_num = in2(6);
        pus_gen = in2(7);
        nb_IntVal = get(pop_num,'Value');

        % Delete previous delimiters.
        %----------------------------
        utthrset('del_Delimiters',in2);

        % Computing Intervals.
        %---------------------
        [thrStruct,int_DepThr_Cell] = wmemtool('rmb',fig,n_memblocTHR,...
                                          ind_thr_struct,ind_int_thr);
        if isempty(int_DepThr_Cell)
            % Compute decomposition and plot.
            %--------------------------------
			uic_ON = findall(fig,'type','uicontrol','enable','on');
			set(uic_ON,'enable','Off');
			uic_MSG = wwaiting('handle',fig);
			set(uic_MSG,'enable','On');
            msg = 'Wait ... computing (only for the first request)';
            wwaiting('msg',fig,msg);

            % Extract the detail of order1.
            %------------------------------
            hdl_DET1 = thrStruct(1).hdlLines;
            det   = get(hdl_DET1,'Ydata');
            xdata = get(hdl_DET1,'Xdata');

            % Replacing 2% of biggest values of by the mean.
            %-----------------------------------------------
            x = sort(abs(det));
            v2p100 = x(fix(length(x)*0.98));
            ind = find(abs(det)>v2p100);
            det(ind) = mean(det);
            lenDet   = length(det);

            % Finding breaking points.
            %-------------------------
            dum = get(pop_num,'String');
            nb_Max_Int = wstr2num(dum(end,:));
            d = 10;            
            if lenDet>1024
                ratio = ceil(lenDet/1024);
                [Rupt_Pts,nb_Opt_Rupt,Xidx] = ...
                    wvarchg(det(1:ratio:end),nb_Max_Int,d);
                Xidx = min(ratio*Xidx,lenDet);
            else
                [Rupt_Pts,nb_Opt_Rupt,Xidx] = wvarchg(det,nb_Max_Int,d);            
            end    
            nb_Opt_Int = nb_Opt_Rupt+1;

            % Computing denoising structure.
            %-------------------------------
            Xidx = [zeros(size(Xidx,1),1) Xidx];
            norma = sqrt(2)*thselect(det,'minimaxi');
            % sqrt(2) comes from the fact that if x is a white noise 
            % of variance 1 the reconstructed detail_1 of x is of 
            % variance 1/sqrt(2)            
            int_DepThr = cell(1,nb_Max_Int);
            for nbint = 1:nb_Max_Int
              for j = 1:nbint
                 sig = median(abs(det(Xidx(nbint,j)+1:Xidx(nbint,j+1))))/0.6745;
                 thr = norma*sig;
                 int_DepThr{nbint}(j,:) = ...
                     [Xidx(nbint,j) , Xidx(nbint,j+1), thr];
              end
              int_DepThr{nbint}(1,1) = 1;
              int_DepThr{nbint}(:,[1 2]) = xdata(int_DepThr{nbint}(:,[1 2]));
            end
            int_DepThr_Cell = {int_DepThr,nb_Opt_Int}; 
            wmemtool('wmb',fig,n_memblocTHR,ind_int_thr,int_DepThr_Cell);
            calling_Fig = wmemtool('rmb',fig,n_membloc1,ind_ret_fig);
            wmemtool('wmb',calling_Fig,n_memblocTHR,ind_int_thr,int_DepThr_Cell);            
            viewNUM = 1;

            % End waiting.
            %-------------
            wwaiting('off',fig);
			set(uic_ON,'enable','On');

        else
            int_DepThr = int_DepThr_Cell{1};
            nb_Opt_Int = int_DepThr_Cell{2};
            viewNUM = isequal(lower(get(pus_gen,'Visible')),'on');
        end
        if viewNUM
            nb_IntVal = nb_Opt_Int;
            str_txt_def = strvcat('Select Number','of Intervals ');
            toolTipGEN  = 'Select Number of Intervals';            
            set(pop_num,'Value',nb_IntVal);
            set(pus_gen,'Visible','Off','ToolTip',toolTipGEN);
            set(txt_def,'String',str_txt_def,'ToolTip',toolTipGEN)
            set([txt_num,pop_num],'Visible','On','ToolTip',toolTipGEN);
        end

        intervals = int_DepThr{nb_IntVal};
        for k=1:length(thrStruct);
           if ~isempty(thrStruct(k).thrParams)
               maxTHR = max(abs(get(thrStruct(k).hdlLines,'Ydata')));
               thrPAR = intervals;
               TMP = min(thrPAR(:,3),maxTHR);
               thrPAR(:,3) = TMP;
               thrStruct(k).thrParams = thrPAR;
           end
        end
        wmemtool('wmb',fig,n_memblocTHR,ind_thr_struct,thrStruct);

        % Plotting lines.
        %----------------
        ind_lev = get(pop_lev,'Value');
        plotlines(fig,ax_hdl,thrStruct(ind_lev),ind_lev);



    case 'propagate'
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig   = in2(1);
        axe   = in2(2);
        pop   = in2(3);
        lines = findobj(axe,'type','line');
        lHu   = findobj(lines,'tag',tag_lineH_up);
        xini  = get(lHu,'Xdata');
        yini  = get(lHu,'Ydata');
        iniPar = getparam(xini,zeros(size(yini)));
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        level  = get(pop,'Value');
        strlev = get(pop,'String');
        for k=1:size(strlev,1)
            lev = str2num(strlev(k,:));
            if lev~=level
                oldPar = thrStruct(lev).thrParams;
                [x,y] = getxy(oldPar);
                for j = 1:length(xini)
                    [dummy,ind] = min(x-xini(j));
                    yini(j) = y(ind);
                end
                newPar = getparam(xini,yini);
                thrStruct(lev).thrParams = newPar;
            end
        end
       wmemtool('wmb',fig,n_memblocTHR,ind_thr_struct,thrStruct);

    case 'clear_GRAPHICS'
        % called by lines callback
        % do nothing
        %--------------------------

    case 'close'
        fig = in2(1);
        [calling_Fig,tog_thr,status] = ...
            wmemtool('rmb',fig,n_membloc1,ind_ret_fig,ind_tog_thr,ind_status);
        if status
            thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
            status = wwaitans(fig,'Update thresholds ?',2,'cond');
            switch status
              case -1 ,  
              case  0 ,
              case  1 , utthrw1d('return_SetThr',calling_Fig,thrStruct);
            end            
        end
        if status>-1 , set(tog_thr,'Value',0); end
        varargout{1} = status;

    case 'stop'
        calling_Fig = in2;
        oldFig = wfindobj('figure','tag',tag_figThresh);
        existFig = ~isempty(oldFig);
        if existFig
            existFig = 0;
            for k = 1:length(oldFig)
                oldCall = wmemtool('rmb',oldFig(k),n_membloc1,ind_ret_fig);
                if isequal(oldCall,calling_Fig)
                   existFig = oldFig(k);
                   break
                end
            end
        end
        if existFig == 0 , return; end
        wmemtool('wmb',existFig,n_membloc1,ind_status,0);
        pus_close = ...
          wfindobj(existFig,'style','Pushbutton','Tag',tag_pus_close);
        eval(get(pus_close,'Callback'));

    case 'demo'
        tog_thr = in2;
        nbINT   = in3;
        handles = utthrset('init',tog_thr);
        drawnow;
        % in2 = [fig;ax_hdl;pop_lev;txt_def;txt_num;pop_num;pus_gen;fra_def];
        %---------------------------------------------------------------------
        fig = handles(1);
        figure(fig)
        txt_def = handles(4);
        txt_num = handles(5);        
        pop_num = handles(6);
        pus_gen = handles(7);

		% Generating Intervals.
		%----------------------
        eval(get(pus_gen,'Callback'));
		
		% Setting message for waiting.
		%-----------------------------
		uic_ON = findall(fig,'type','uicontrol','enable','on');
		uic_MSG = wwaiting('handle',fig);
		set(uic_ON,'enable','Off');	
		set(uic_MSG,'enable','On');
		msg = 'The intervals are generated ...';
		wwaiting('msg',fig,msg);

        str_txt_def = strvcat('Select Number','of Intervals ');
        toolTipGEN  = 'Select Number of Intervals';
        set(pus_gen,'Visible','Off','ToolTip',toolTipGEN);
        
        %--------------------------------------------------------%
        fra_def = handles(end);
        pos_fra = get(fra_def,'Position');
        pos_num = get(pop_num,'Position');
        deltaH  = pos_num(4)/2;
        set(fra_def,'Position',pos_fra+[0 deltaH 0 -deltaH]);
        drawnow
        %--------------------------------------------------------%
        
        set(txt_def,'String',str_txt_def,'ToolTip',toolTipGEN)
        set([txt_num,pop_num],'Visible','On','ToolTip',toolTipGEN);
        nbINTComp = get(pop_num,'Value');
        if ~isequal(nbINTComp,nbINT)
		    msg = 'Selecting the best number of Intervals';
		    wwaiting('msg',fig,msg);		
            pause(1.5)
            set(pop_num,'Value',nbINT);
            eval(get(pop_num,'Callback'));
        end
        pause(3)
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        calling_Fig = wmemtool('rmb',fig,n_membloc1,ind_ret_fig);
        utthrw1d('return_SetThr',calling_Fig,thrStruct);
        delete(fig)
        set(tog_thr,'Value',0);

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function param = getparam(x,y)

lx    = length(x);
x_beg = x(1:3:lx);
x_end = x(2:3:lx);
y     = y(1:3:lx);
param = [x_beg(:) , x_end(:) , y(:)];
%-----------------------------------------------------------------------------%
function [x,y] = getxy(arg)

NB_int  = size(arg,1);
if NB_int>1
    x = [arg(:,1:2) NaN*ones(NB_int,1)]';
    x = x(:)';
    l = 3*NB_int-1;
    x = x(1:l);
    y = [arg(:,[3 3]) NaN*ones(NB_int,1)]';
    y = y(:)';
    y = y(1:l);
else
    x = arg(1,1:2); y = arg(1,[3 3]);
end
%-----------------------------------------------------------------------------%
function plotlines(fig,ax_hdl,deno_struct,level)

linesHDL = findobj(ax_hdl,'type','line');
if ~isempty(linesHDL), delete(linesHDL); end
hdlLineVal  = deno_struct.hdlLines;
[xHOR,yHOR] = getxy(deno_struct.thrParams);
if ~isempty(hdlLineVal)
    xdata = get(hdlLineVal,'Xdata');
    ydata = get(hdlLineVal,'Ydata');
    color = get(hdlLineVal,'Color');
    lsig  = line(...
              'Parent',ax_hdl, ...
              'Xdata',xdata,   ...
              'Ydata',ydata,   ...
              'Linestyle','-', ...
              'linewidth',1,   ...
              'Color',color,   ...
              'Tag','Sig'      ...
              );
    ysigmax = max(abs(ydata));
else
    ysigmax = 1;
end

[lHu,lHd] = cbthrw1d('plotLH',ax_hdl,xHOR,yHOR,level,ysigmax);
ylim  = get(ax_hdl,'Ylim');
yVMin = 2*abs(ylim(1));
cbthrw1d('plotLV',[fig ; lHu ; lHd],[xHOR ; yHOR],yVMin);
notNAN = ~isnan(xHOR);
xmin   = min(xHOR(notNAN));
xmax   = max(xHOR(notNAN));
ymax   = 1.05*max([yHOR(notNAN),ysigmax]);
set(ax_hdl,'Xlim',[xmin xmax],'Ylim',[-ymax ymax])

% Dynvtool Attachement.
%---------------------
dynvtool('init',fig,[],ax_hdl,[],[1 0],...
                '','','',[],'cbthrw1d',[ax_hdl lHu lHd]);
%-----------------------------------------------------------------------------%
%=============================================================================%
