function varargout = utthrwpd(option,fig,varargin)
%UTTHRWPD Utilities for thresholding (Wavelet Packet De-noising).
%   VARARGOUT = UTTHRWPD(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Sep-98.
%   Last Revision: 25-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/03/15 22:42:13 $

% Tag property.
%--------------
tag_fra_tool = ['Fra_' mfilename];

switch option
  case {'move','up','create'} , 
  otherwise
    wfigPROP = wtbxappdata('get',fig,'WfigPROP');
    if ~isempty(wfigPROP)
        calledFUN = wfigPROP.MakeFun;
    else
        calledFUN = wdumfun;    
    end
    if ~isequal(option,'down')
        % ud.handlesUIC = ...
        %    [fra_utl;txt_top;rad_sof;rad_har; ...
        %     sli_sel;edi_sel;txt_bin;edi_bin; ...
        %     tog_res;pus_est];
        %-----------------------------
        uic = findobj(get(fig,'Children'),'flat','type','uicontrol');
        fra = findobj(uic,'style','frame','tag',tag_fra_tool);
        if isempty(fra) , return; end
        ud = get(fra,'Userdata');
        toolOPT = ud.toolOPT;
        handlesUIC = ud.handlesUIC;
        handlesOBJ = ud.handlesOBJ;
        ind = 2;
        txt_top = handlesUIC(ind); ind = ind+1;
        pop_met = handlesUIC(ind); ind = ind+1;
        rad_sof = handlesUIC(ind); ind = ind+1;
        rad_har = handlesUIC(ind); ind = ind+1;
        txt_sel = handlesUIC(ind); ind = ind+1;
        sli_sel = handlesUIC(ind); ind = ind+1;
        edi_sel = handlesUIC(ind); ind = ind+1;
        txt_bin = handlesUIC(ind); ind = ind+1;
        edi_bin = handlesUIC(ind); ind = ind+1;
        tog_res = handlesUIC(ind); ind = ind+1;
        pus_est = handlesUIC(ind); ind = ind+1;   
    end
end

switch option
    case 'down'
        % in2 = [axe_perfo ; axe_histo; ...
        %        lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        % in3 = 1  for lin_perfo and in3 = 2 for lin_perfh
        %--------------------------------------------------------------
        sel_type = get(fig,'SelectionType');
        if strcmp(sel_type,'open') , return; end
        opt = varargin{2};   
        if opt==1 , axe = varargin{1}(1); else , axe = varargin{1}(2); end
        if (axe~=gca) , axes(axe); end;
    
        % Setting the thresholded coefs axes invisible.
        %----------------------------------------------
        feval(calledFUN,'clear_GRAPHICS',fig);
        lin_perfo = varargin{1}(3);
        lin_perfh = varargin{1}(4);
        set([lin_perfo lin_perfh],'Color','g');
        drawnow
        argCbstr = [num2mstr(fig) ',' num2mstr(varargin{1}) ...
                     ',' int2str(varargin{2})];
        cba_move = [mfilename '(''move'',' argCbstr ');'];
        cba_up   = [mfilename '(''up'','  argCbstr ');'];
        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);

    case 'move'
        % in2 = [axe_perfo ; axe_histo; ...
        %        lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        % in3 = 1  for lin_perfo and in3 = 2 for lin_perfh
        %--------------------------------------------------------------
        opt = varargin{2};   
        if opt==1 , axe = varargin{1}(1); else , axe = varargin{1}(2); end
        p = get(axe,'currentpoint');
        new_thresh = p(1,1);
        sli_sel = varargin{1}(5);
        min_sli = get(sli_sel,'Min');
        max_sli = get(sli_sel,'Max');
        new_thresh = max(min_sli,min(new_thresh,max_sli));
        xnew = [new_thresh new_thresh];
        xold = get(varargin{1}(3),'Xdata');
        if isequal(xold,xnew) , return; end
        set(varargin{1}(3:4),'Xdata',xnew);
        set(sli_sel,'value',new_thresh);
        set(varargin{1}(6),'string',sprintf('%1.4g',new_thresh));

    case 'up'
        % in2 = [axe_perfo ; axe_histo; ...
        %        lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        %--------------------------------------------------------------
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        set(fig,'WindowButtonMotionFcn','wtmotion',...
			'WindowButtonUpFcn',save_WindowButtonUpFcn);
        set(varargin{1}(3:4),'Color',wtbutils('colors','linTHR'));
        drawnow;

    case {'create'}
        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,sliYProp,Def_FraBkColor,Def_EdiBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
                'Pop_Min_Width','X_Spacing','Y_Spacing','Sli_YProp', ...
                'Def_FraBkColor','Def_EdiBkColor');

        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = Def_FraBkColor;
        enaVal = 'off';
        visVal = 'on';
        toolOPT = 'wpdeno1';

        % Inputs.
        %--------        
        nbarg = length(varargin);
        for k=1:2:nbarg
            arg = lower(varargin{k});
            switch arg
              case 'left'     , xleft   = varargin{k+1};
              case 'right'    , xright  = varargin{k+1};
              case 'xloc'     , xloc    = varargin{k+1};
              case 'bottom'   , ybottom = varargin{k+1};
              case 'top'      , ytop    = varargin{k+1};
              case 'yloc'     , yloc    = varargin{k+1};
              case 'bkcolor'  , bkColor = varargin{k+1};
              case 'visible'  , visVal  = varargin{k+1};
              case 'toolopt'  , toolOPT = varargin{k+1};
            end 
        end

        % Structure initialization.
        %--------------------------
        colHIST = wtbutils('colors','wp1d','hist');
        ud = struct(...
                'toolOPT',toolOPT, ...
                'visible',lower(visVal),...
                'handlesUIC',[], ...
                'handlesOBJ',[], ...
                'handleORI',     ...
                'handleTHR',     ...                 
                'histColor',colHIST ...
                );

        % Figure units.
        %--------------
        str_numfig = num2mstr(fig);
        old_units  = get(fig,'units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'units',fig_units); end       

        % String property.
        %-----------------
        default_bins = 50;
        str_txt_top = 'Select thresholding method';
        str_txt_sel = 'Select Global Threshold';
        str_pop_met = wthrmeth(toolOPT,'names');
        str_rad_sof = 'soft';
        str_rad_har = 'hard';
        str_txt_bin = 'Number of bins';
        str_edi_bin = sprintf('%.0f',default_bins);
        str_tog_res = 'Residuals';
        str_pus_est = 'De-noise';

        % Positions utilities.
        %---------------------
        dx = X_Spacing; bdx = 3;
        dy = Y_Spacing; bdy = 4;       
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        deltaY = (Def_Btn_Height+dy);
        d_lev  = 2;
        sli_hi = Def_Btn_Height*sliYProp;
        sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);

        % Setting frame position.
        %------------------------
        w_fra   = wfigmngr('get',fig,'fra_width');
        h_fra   = 6*Def_Btn_Height+6*bdy;              
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fra = [xleft,ybottom,w_fra,h_fra];

        % Position property.
        %-------------------
        txt_width = Def_Btn_Width;
        dy_lev    = Def_Btn_Height+d_lev;
        xleft = xleft+bdx;
        w_rem = w_fra-2*bdx;
        ylow  = ybottom+h_fra-Def_Btn_Height-bdy;

        w_uic       = (5*txt_width)/2;
        x_uic       = xleft+(w_rem-w_uic)/2;
        y_uic       = ylow;
        pos_txt_top = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        pos_pop_met = [x_uic, y_uic, w_uic, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;
        w_rad       = Pop_Min_Width;
        w_sep       = (w_uic-2*w_rad)/3;
        x_rad       = x_uic+w_sep;
        pos_rad_sof = [x_rad, y_uic, w_rad, Def_Btn_Height];
        x_rad       = x_rad+w_rad+w_sep;
        pos_rad_har = [x_rad, y_uic, w_rad, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;
        pos_txt_sel = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        wid1        = (15*w_rem)/26;
        wid2        = (8*w_rem)/26;
        wid3        = (2*w_rem)/26;
        wx          = (w_rem-wid1-wid2)/4;
        
        pos_sli_sel = [xleft+wx, y_uic+sli_dy, wid1-wx, sli_hi];
        x_uic       = pos_sli_sel(1)+pos_sli_sel(3)+wx;
        pos_edi_sel = [x_uic, y_uic, wid2, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;        
        pos_txt_bin = [xleft+wx, y_uic+d_txt/2, wid1-wx, Def_Txt_Height];
        x_uic       = pos_txt_bin(1)+pos_txt_bin(3)+wx;
        pos_edi_bin = [x_uic, y_uic, wid2, Def_Btn_Height];

        w_uic = w_fra/2-bdx;
        x_uic = pos_fra(1);
        h_uic = (3*Def_Btn_Height)/2;
        y_uic = pos_fra(2)-h_uic-Def_Btn_Height;     
        pos_pus_est = [x_uic, y_uic, w_uic, h_uic];
        x_uic = x_uic+w_uic+2*bdx;
        pos_tog_res = [x_uic, y_uic, w_uic, h_uic];

        % Create UIC.
        %------------
        comProp = {...
           'Parent',fig,    ...
           'Unit',fig_units ...
           'Visible',visVal ...
           };

        commonTxtProp = {comProp{:}, ...
            'Style','Text',...
            'Backgroundcolor',Def_FraBkColor...
            };        

        commonEdiProp = {comProp{:}, ...
            'Style','Edit',...
            'String','',...
            'Backgroundcolor',Def_EdiBkColor,...
            'HorizontalAlignment','center'...
            };        

        fra_utl = uicontrol(comProp{:}, ...
                            'Style','frame', ...
                            'Position',pos_fra, ...
                            'Backgroundcolor',bkColor, ...
                            'Tag',tag_fra_tool ...
                            );

        txt_top = uicontrol(commonTxtProp{:},      ...
                            'Position',pos_txt_top,...
                            'HorizontalAlignment','center',...
                            'String',str_txt_top   ...
                            );

        cba = [mfilename '(''update_methName'',' str_numfig ');'];
        pop_met = uicontrol(comProp{:}, ...
                            'Style','Popup',...
                            'Position',pos_pop_met,...
                            'String',str_pop_met,...
                            'HorizontalAlignment','center',...
                            'Userdata',1,...
                            'Callback',cba ...
                            );

        rad_sof = uicontrol(comProp{:}, ...
                            'Style','RadioButton',...
                            'Position',pos_rad_sof,...
                            'HorizontalAlignment','center',...
                            'String',str_rad_sof,...
                            'Value',1,'Userdata',1 ...
                            );

        rad_har = uicontrol(comProp{:}, ...
                            'Style','RadioButton',...
                            'Position',pos_rad_har,...
                            'HorizontalAlignment','center',...
                            'String',str_rad_har,...
                            'Value',0,'Userdata',0 ...
                            );
        cba = [mfilename '(''update_thrType'',' str_numfig ');'];
        set(rad_sof,'Callback',cba);
        set(rad_har,'Callback',cba);

        txt_sel = uicontrol(commonTxtProp{:},      ...
                            'Position',pos_txt_sel,...
                            'HorizontalAlignment','center',...
                            'String',str_txt_sel   ...
                            );


        cba_sli = [mfilename '(''updateTHR'',' str_numfig ',''sli'');'];
        sli_sel = uicontrol(comProp{:}, ...
                            'Style','Slider',...
                            'Position',pos_sli_sel,...
                            'Min',0,...
                            'Max',1,...
                            'Value',0.5, ...
                            'Callback',cba_sli ...
                            );

        cba_edi = [mfilename '(''updateTHR'',' str_numfig ',''edi'');'];
        edi_sel = uicontrol(commonEdiProp{:}, ...
                            'Position',pos_edi_sel,...
                            'Callback',cba_edi ...
                            );

        txt_bin = uicontrol(commonTxtProp{:}, ...
                            'Position',pos_txt_bin,...
                            'HorizontalAlignment','left',...
                            'String',str_txt_bin...
                            );

        cba_bin = [mfilename '(''updateBIN'',' str_numfig ',''bin'');'];
        edi_bin = uicontrol(commonEdiProp{:}, ...
                            'Position',pos_edi_bin,...
                            'String',str_edi_bin,   ...
                            'Callback',cba_bin ...
                            );

        cba = [mfilename '(''residuals'',' str_numfig ');'];
        tip = 'More on Residuals';
        tog_res = uicontrol(comProp{:},             ...
                            'Style','Togglebutton', ...
                            'Position',pos_tog_res, ...
                            'String',str_tog_res,   ...
                            'Enable','off',         ...
                            'Callback',cba,         ...
                            'tooltip',tip,          ...
                            'Interruptible','On'    ...
                            );

        cba_pus_est = [mfilename '(''denoise'',' str_numfig ');'];
        pus_est = uicontrol(comProp{:},             ...
                            'Style','Pushbutton',   ...
                            'Position',pos_pus_est, ...
                            'String',xlate(str_pus_est),   ...
                            'callback',cba_pus_est  ...
                            );

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
        hdl_COMP_DENO_STRA = [...
			fra_utl,txt_top,pop_met, ...
			txt_sel,sli_sel,edi_sel];
        hdl_DENO_SOFTHARD = [rad_sof,rad_har];
		wfighelp('add_ContextMenu',fig,hdl_COMP_DENO_STRA,'COMP_DENO_STRA');
		wfighelp('add_ContextMenu',fig,hdl_DENO_SOFTHARD,'DENO_SOFTHARD');
		%-------------------------------------

		% Store handles.
		%--------------
		ud.handlesUIC = ...
            [fra_utl;txt_top;pop_met;...
             rad_sof;rad_har;txt_sel;sli_sel;edi_sel;...
             txt_bin;edi_bin;tog_res;pus_est];
        set(fra_utl,'Userdata',ud);
        if nargout>0
            varargout{1} = [pos_fra(1) , pos_pus_est(2) , pos_fra([3 4])];
        end

    case 'displayPerf'
        % Displaying perfos.
        %-------------------
        [pos_axe_perfo,pos_axe_histo,cfs] = deal(varargin{:});
        cfs = sort(abs(cfs));
        fig_units = get(fig,'units');
        suggthr = get(sli_sel,'value');
        nb_cfs  = length(cfs);
        if nb_cfs==0
            xlim = [0 1];
            ylim = [0 1];
        else
            sigmax = cfs(end);
            if abs(sigmax)<eps , sigmax = 0.01; end
            xlim = [0 sigmax];
            ylim = [0 nb_cfs];
        end
        comAxeProp = {...
          'Parent',fig, ...
          'Units',fig_units, ...
          'Drawmode','fast', ...
          'Box','On'};
        colTHR = wtbutils('colors','linTHR');
        axe_perfo = axes(comAxeProp{:},...
                         'Position',pos_axe_perfo,...
                         'Xlim',xlim,'Ylim',ylim);

        % Set a text as a super title.
        %-----------------------------
        wtitle('Sorted absolute values of coefs','Parent',axe_perfo)
        lin_thres = line('xdata',cfs,...
                         'ydata',1:nb_cfs,...
                         'erasemode','none',...
                         'color',ud.histColor,...
                         'Parent',axe_perfo);
        lin_perfo = line('EraseMode','xor',...
                         'xdata',[suggthr suggthr],...
                         'ydata',[0       nb_cfs],...
                         'Color',colTHR,...
                         'linestyle',':', ...
                         'Parent',axe_perfo);
        setappdata(lin_perfo,'selectPointer','V')
        set(axe_perfo,'Userdata',lin_perfo);

        % Displaying histogram.
        %----------------------
        default_bins = 50;
        nb_bins = wstr2num(get(edi_bin,'String'));
        if isempty(nb_bins) | (nb_bins<2) , nb_bins = default_bins; end
        set(edi_bin,'String',sprintf('%.0f',nb_bins));
        
        axe_histo = axes(comAxeProp{:},...
                         'Position',pos_axe_histo,...
                         'NextPlot','Replace');
        his       = wgethist(cfs,nb_bins,'left');
        [xx,imod] = max(his(2,:));
        mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/nb_cfs;
        his       = AdjustHist(his,axe_perfo);

        axes(axe_histo);
        wplothis(axe_histo,his,ud.histColor);
        ylim      = get(axe_histo,'Ylim');
        lin_perfh = line('EraseMode','xor',...
                         'xdata',[suggthr suggthr],...
                         'ydata',[ylim(1)+eps ylim(2)-eps],...
                         'Color',colTHR,...
                         'linestyle',':', ...
                         'Parent',axe_histo);
        setappdata(lin_perfh,'selectPointer','V')
        wtitle('Histogram of absolute values of coefs','Parent',axe_histo);

        handles = [axe_perfo ; axe_histo; ...
                   lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        argCbstr = [num2mstr(fig) ',' num2mstr(handles)];
        cba_lin_perfo = [mfilename '(''down'',' argCbstr ',1);'];
        set(lin_perfo,'ButtonDownFcn',cba_lin_perfo);
        cba_lin_perfh = [mfilename '(''down'',' argCbstr ',2);'];
        set(lin_perfh,'ButtonDownFcn',cba_lin_perfh);
        ud.handlesOBJ.axes  = [axe_perfo ; axe_histo]; 
        ud.handlesOBJ.lines = [lin_perfo ; lin_perfh; lin_thres];
        set(fra,'Userdata',ud);

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:2:nbarg
           argType = lower(varargin{k});
           argVal  = varargin{k+1};
           switch argType
               case 'handleori' , ud.handleORI = argVal;
               case 'handlethr' , ud.handleTHR = argVal;
           end
        end
        set(fra,'Userdata',ud);

    case 'enable_tog_res'
        enaVal = varargin{1};
        set(tog_res,'Enable',enaVal);

    case 'denoise'
        feval(calledFUN,'denoise',fig);

    case 'setThresh'
        sliVal = varargin{1};
        set(sli_sel,'Min',sliVal(1),'Value',sliVal(2),'Max',sliVal(3));
        set(edi_sel,'String',sprintf('%1.4g',sliVal(2)));

    case 'get_GBL_par'
        numMeth = get(pop_met,'value');
        meth    = wthrmeth(toolOPT,'shortnames',numMeth);
        valType = get(rad_sof,'value');
        if valType==1 , sorh = 's'; else , sorh = 'h'; end
        valSli  = get(sli_sel,'Value');
        varargout = {numMeth,meth,valSli,sorh};

    case 'update_GBL_meth'
        % called by : calledFUN('update_GBL_meth', ...)
        %------------------------------------------------
        suggthr = varargin{1};
        utthrwpd('updateTHR',fig,'meth',suggthr);

    case 'update_methName'
        feval(calledFUN,'update_GBL_meth',fig);

    case 'updateBIN'
        % Check the bins number.
        %-----------------------
        default_bins = 50; max_bins = 500;
        nb_bins = wstr2num(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;
            set(edi_bin,'String',sprintf('%.0f',nb_bins));
            return
        elseif (nb_bins>max_bins)
            nb_bins = max_bins;
            set(edi_bin,'String',sprintf('%.0f',nb_bins));
        end
        axe_perfo = handlesOBJ.axes(1);
        axe_histo = handlesOBJ.axes(2);
        lin_perfh = handlesOBJ.lines(2);
        lin_thres = handlesOBJ.lines(3);
        thresVal  = get(lin_thres,'Xdata');
        his       = wgethist(thresVal,nb_bins,'left');
        his(2,:)  = his(2,:)/length(thresVal);
        his       = AdjustHist(his,axe_perfo);
        child = findobj(axe_histo,'parent',axe_histo);
        child(child==lin_perfh) = [];
        delete(child)
        set(axe_histo,'nextplot','add');
        wplothis(axe_histo,his,ud.histColor);
        ylim = get(axe_histo,'Ylim');
        set(lin_perfh,'Ydata',[ylim(1)+eps ylim(2)-eps]);
        wtitle('Histogram of absolute values of coefs','Parent',axe_histo);

    case 'updateTHR'
        upd_orig = varargin{1};
        switch upd_orig
          case 'sli'
            new_thresh = get(sli_sel,'value');

          case 'edi'
            new_thresh = wstr2num(get(edi_sel,'string'));
            if isempty(new_thresh)
                new_thresh = get(sli_sel,'value');
            else
                ma = get(sli_sel,'Max');
                if new_thresh>ma
                    new_thresh = ma;
                else
                    mi = get(sli_sel,'Min');
                    if new_thresh<mi , new_thresh = mi; end
                end
            end

          case 'meth'
            new_thresh = varargin{2};

        end
        set(sli_sel,'value',new_thresh);
        set(edi_sel,'string',sprintf('%1.4g',new_thresh));
        lin_perfo = handlesOBJ.lines(1);
        lin_perfh = handlesOBJ.lines(2);
        xold = get(lin_perfo,'Xdata');
        xnew = [new_thresh new_thresh];
        if ~isequal(xold,xnew)
            set([lin_perfo lin_perfh],'Xdata',xnew);
            feval(calledFUN,'clear_GRAPHICS',fig);
        end

    case 'update_thrType'
        rad = gcbo;
        old = get(rad,'userdata');
        if old==1 , set(rad,'Value',1); return; end
        if isequal(rad,rad_sof)
           type = 's'; other = rad_har;
        else
           type = 'h'; other = rad_sof;           
        end
        set(other,'Value',0,'Userdata',0);
        set(rad,'Value',1,'Userdata',1);
        feval(calledFUN,'clear_GRAPHICS',fig);

    case 'residuals'
        wmoreres('create',fig,tog_res,[],ud.handleORI,ud.handleTHR,'blocPAR');

    otherwise
      errargt(mfilename,'Unknown Option','msg');
      error('*');
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function varargout = wthrmeth(toolOPT,varargin)

switch toolOPT
  case {'wpdeno1'}
    thrMethods = {...
        'Fixed form thr. (unscaled wn)',  'sqtwologuwn',   1; ...
        'Fixed form thr. (scaled wn)',    'sqtwologswn',   2; ...
        'Balance sparsity-norm',          'bal_sn',        3; ...
        'Penalize high',                  'penalhi',       4; ...
        'Penalize medium',                'penalme',       5; ...
        'Penalize low',                   'penallo',       6  ...

        };

  case {'wpdeno2'}
    thrMethods = {...
        'Fixed form thr. (unscaled wn)',  'sqtwologuwn',   1; ...
        'Fixed form thr. (scaled wn)',    'sqtwologswn',   2; ...
        'Bal. sparsity-norm (sqrt)',      'sqrtbal_sn',    3; ...
        'Penalize high',                  'penalhi',       4; ...
        'Penalize medium',                'penalme',       5; ...
        'Penalize low',                   'penallo',       6  ...
        };
end
nbin = length(varargin);
if nbin==0 , varargout{1} = thrMethods; return; end

option = varargin{1};
switch option
  case 'names'
     out = strvcat(1,thrMethods{:,1});
     varargout{1} = out(2:end,:);
     if nbin==2
         num = varargin{2};
         varargout{1} = deblank(varargout{1}(num,:));
     end

  case 'shortnames'
     out = strvcat(1,thrMethods{:,2});
     varargout{1} = out(2:end,:);
     if nbin==2
         num = varargin{2};
         varargout{1} = deblank(varargout{1}(num,:));
     end

  case 'nums'
     varargout{1} = cat(1,thrMethods{:,3});
end

%-----------------------------------------------------------------------------%
function his = AdjustHist(his,axe)

xlim = get(axe,'Xlim');
d    = his(1,:)-his(1,1);
his(1,:) = xlim(2)*(d/max(d));
%-----------------------------------------------------------------------------%
%=============================================================================%
