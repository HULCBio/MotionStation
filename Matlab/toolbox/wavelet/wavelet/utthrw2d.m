function varargout = utthrw2d(option,fig,varargin)
%UTTHRW2D Utilities for wavelet thresholding 2-D.
%   VARARGOUT = UTTHRW2D(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-98.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/03/15 22:42:12 $

% Default values.
%----------------
max_lev_anal = 5;
def_lev_anal = 2;

% Tag property.
%--------------
tag_fra_tool = ['Fra_' mfilename];

switch option
  case {'create'}

  otherwise
    uic = findobj(get(fig,'Children'),'flat','type','uicontrol');
    fra = findobj(uic,'style','frame','tag',tag_fra_tool);
    if isempty(fra) , return; end
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    ud = get(fra,'Userdata');
    toolOPT = ud.toolOPT;
    toolStatus = ud.status;
    handlesUIC = ud.handlesUIC;
    h_CMD_LVL  = ud.h_CMD_LVL;
    h_GRA_LVL  = ud.h_GRA_LVL;
    if isequal(option,'handles')
        handles = [handlesUIC(:);h_CMD_LVL(:)];
        varargout{1} = handles(ishandle(handles));
        return;
    end
    thrStruct = ud.thrStruct;
    ind = 2;
    txt_top = handlesUIC(ind); ind = ind+1;
    pop_met = handlesUIC(ind); ind = ind+1;
    rad_sof = handlesUIC(ind); ind = ind+1;
    rad_har = handlesUIC(ind); ind = ind+1;
    txt_noi = handlesUIC(ind); ind = ind+1;
    pop_noi = handlesUIC(ind); ind = ind+1;
    txt_BMS = handlesUIC(ind); ind = ind+1;  
    sli_BMS = handlesUIC(ind); ind = ind+1;
    pop_dir = handlesUIC(ind); ind = ind+1;
    txt_tit(1:3) = handlesUIC(ind:ind+2); ind = ind+3;
    txt_nor = handlesUIC(ind); ind = ind+1;
    edi_nor = handlesUIC(ind); ind = ind+1;
    txt_npc = handlesUIC(ind); ind = ind+1;
    txt_zer = handlesUIC(ind); ind = ind+1;
    edi_zer = handlesUIC(ind); ind = ind+1;
    txt_zpc = handlesUIC(ind); ind = ind+1;
    tog_res = handlesUIC(ind); ind = ind+1;
    pus_est = handlesUIC(ind); ind = ind+1;
end

switch option
    case 'create'
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
        enaVal  = 'Off';
        %------------------------
        ydir   = -1;
        levmin = 1;
        levmax = def_lev_anal;
        levmaxMAX = max_lev_anal;
        levANAL = def_lev_anal;
        visVal = 'On';        
        isbior = 0;
        statusINI = 'On';
        toolOPT   = 'deno';
        %------------------------

        % Inputs.
        %--------        
        nbarg = length(varargin);
        for k=1:2:nbarg
            arg = lower(varargin{k});
            switch arg
              case 'left'     , xleft     = varargin{k+1};
              case 'right'    , xright    = varargin{k+1};
              case 'xloc'     , xloc      = varargin{k+1};
              case 'bottom'   , ybottom   = varargin{k+1};
              case 'top'      , ytop      = varargin{k+1};
              case 'yloc'     , yloc      = varargin{k+1};
              case 'bkcolor'  , bkColor   = varargin{k+1};
              case 'visible'  , visVal    = varargin{k+1};
              case 'enable'   , enaVal    = varargin{k+1};
              case 'isbior'   , isbior    = varargin{k+1};
              case 'ydir'     , ydir      = varargin{k+1};
              case 'levmin'   , levmin    = varargin{k+1};
              case 'levmax'   , levmax    = varargin{k+1};
              case 'levmaxmax', levmaxMAX = varargin{k+1};
              case 'levanal'  , levANAL   = varargin{k+1};
              case 'status'   , statusINI = varargin{k+1};
              case 'toolopt'  , toolOPT   = varargin{k+1};
            end 
        end

        % Structure initialization.
        %--------------------------
        % h_CMD_LVL: [txt_lev ; sli_lev ; edi_lev] x Level
        % h_GRA_LVL: [axe_thr ; lin_min ; lin_max] x Dir x Level
        h_CMD_LVL = NaN*ones(3,levmaxMAX);        
        h_GRA_LVL = NaN*ones(3,3,levmaxMAX);
        threshDEF = NaN*ones(3,levmaxMAX);
        thrStruct = struct('value',threshDEF,'max',threshDEF);
        ud = struct(...
                'toolOPT',toolOPT, ...
                'status',statusINI,...
                'levmin',levmin,   ...
                'levmax',levmax,   ...
                'levmaxMAX',levmaxMAX, ...
                'levANAL',levANAL, ...
                'thrStruct',thrStruct, ...            
                'visible',lower(visVal),...
                'ydir', ydir,          ...
                'isbior',isbior,       ...
                'handlesUIC',[],       ...
                'h_CMD_LVL',h_CMD_LVL, ...
                'h_GRA_LVL',h_GRA_LVL, ...
                'handleORI' ,[],       ... 
                'handleTHR',[],        ... 
                'handleRES' ,[]        ... 
                );

        % Figure units.
        %--------------
        str_numfig = num2mstr(fig);
        old_units  = get(fig,'units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'units',fig_units); end       

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
        switch  toolOPT
          case {'deno','esti'} , NB_Height = 7;
          case {'comp'}        , NB_Height = 8;
        end
        w_fra   = wfigmngr('get',fig,'fra_width');
        h_fra   = (levmaxMAX+NB_Height)*Def_Btn_Height+...
                   levmaxMAX*d_lev+ (NB_Height-2)*bdy;
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fra = [xleft,ybottom,w_fra,h_fra];

        % String property of objects.
        %----------------------------
        str_txt_top = 'Select thresholding method';
        str_txt_BMS = '-       Sparsity       +';
        str_pop_dir = strvcat('Horizontal details coefs', ...
                              'Diagonal details coefs',   ...
                              'Vertical details coefs'  );
        str_txt_tit = strvcat('Level','Select','Thresh');
        str_tog_res = 'Residuals';
        str_pop_met = wthrmeth(toolOPT,'names');
        switch  toolOPT
          case {'deno','esti'}
            str_rad_sof = 'soft';
            str_rad_har = 'hard';
            str_txt_noi = 'Select noise structure';
            str_pop_noi = strvcat(...
                'Unscaled white noise', ...
                'Scaled white noise',   ...
                'Non-white noise'       ...
                );

          case 'comp'
            if ud.isbior
                str_txt_nor = 'Norm cfs recovery';
            else
                str_txt_nor = 'Retained energy';
            end
            str_txt_zer = 'Number of zeros';
        end
        switch  toolOPT
          case 'deno' , str_pus_est = 'De-noise'; estOPT = 'denoise';
          case 'comp' , str_pus_est = 'Compress'; estOPT = 'compress';
          case 'esti' , str_pus_est = 'Estimate'; estOPT = 'estimate';
        end

        % Position properties.
        %---------------------
        txt_width   = Def_Btn_Width;
        dy_lev      = Def_Btn_Height+d_lev;
        xleft       = xleft+bdx;
        w_rem       = w_fra-2*bdx;
        ylow        = ybottom+h_fra-Def_Btn_Height-bdy;

        w_uic       = (5*txt_width)/2;
        x_uic       = xleft+(w_rem-w_uic)/2;
        y_uic       = ylow;
        pos_txt_top = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        pos_pop_met = [x_uic, y_uic, w_uic, Def_Btn_Height];
        y_uic       = y_uic-Def_Btn_Height;
        switch  toolOPT
          case {'deno','esti'}
            y_uic       = y_uic-bdy;
            w_rad       = Pop_Min_Width;
            w_sep       = (w_uic-2*w_rad)/3;
            x_rad       = x_uic+w_sep;
            pos_rad_sof = [x_rad, y_uic, w_rad, Def_Btn_Height];
            x_rad       = x_rad+w_rad+w_sep;
            pos_rad_har = [x_rad, y_uic, w_rad, Def_Btn_Height];

            y_uic       = y_uic-Def_Btn_Height;
            y_BMS       = y_uic;
            pos_txt_noi = [x_uic, y_uic, w_uic, Def_Txt_Height];
            y_uic       = y_uic-Def_Btn_Height;
            pos_pop_noi = [x_uic, y_uic, w_uic, Def_Btn_Height];

          case 'comp'
            y_BMS       = y_uic;
            y_uic       = y_uic-Def_Btn_Height;
        end

        pos_txt_BMS = [x_uic, y_BMS, w_uic, Def_Txt_Height];
        y_BMS       = y_BMS-Def_Btn_Height;
        w_BMS       = (w_uic-bdx)/3;
        pos_sli_BMS = [x_uic+w_BMS/2, y_BMS+sli_dy, 2*w_BMS, sli_hi];

        y_uic       = y_uic-Def_Btn_Height-bdy;
        pos_pop_dir = [x_uic, y_uic, w_uic, Def_Btn_Height];

        wx          = 2;
        wbase       = 2*(w_rem-4*wx)/5;
        w_lev       = [6*wbase ; 15*wbase ; 9*wbase]/12;
        x_uic       = xleft+wx;
        y_uic       = y_uic-Def_Btn_Height;
        pos_lev_tit = [x_uic, y_uic, w_lev(1), Def_Txt_Height];
        pos_lev_tit = pos_lev_tit(ones(1,3),:);
        pos_lev_tit(:,3) = w_lev; 
        for k=1:2 , pos_lev_tit(k+1,1) = pos_lev_tit(k,1)+pos_lev_tit(k,3); end
        y_uic = pos_lev_tit(1,2)-levmaxMAX*(Def_Btn_Height+d_lev);

        switch  toolOPT
          case {'deno','esti'}
          case {'comp'}
            wid1 = (15*w_rem)/26;
            wid2 = (8*w_rem)/26;
            wid3 = (2*w_rem)/26;
            wx   = (w_rem-wid1-wid2-wid3)/4;
            y_uic       = y_uic-Def_Btn_Height-bdy;
            pos_txt_nor = [xleft, y_uic+d_txt/2, wid1, Def_Txt_Height];
            x_uic       = pos_txt_nor(1)+pos_txt_nor(3)+wx;
            pos_edi_nor = [x_uic, y_uic, wid2, Def_Btn_Height];
            x_uic       = pos_edi_nor(1)+pos_edi_nor(3)+wx;
            pos_txt_npc = [x_uic, y_uic+d_txt/2, wid3, Def_Txt_Height];

            y_uic       = y_uic-Def_Btn_Height-bdy;
            pos_txt_zer = [xleft, y_uic+d_txt/2, wid1, Def_Txt_Height];
            x_uic       = pos_txt_zer(1)+pos_txt_zer(3)+wx;
            pos_edi_zer = [x_uic, y_uic, wid2, Def_Btn_Height];
            x_uic       = pos_edi_zer(1)+pos_edi_zer(3)+wx;
            pos_txt_zpc = [x_uic, y_uic+d_txt/2, wid3, Def_Txt_Height];
        end

        w_uic = w_fra/2-bdx;
        x_uic = pos_fra(1);
        h_uic = (3*Def_Btn_Height)/2;
        y_uic = pos_fra(2)-h_uic-Def_Btn_Height/2;
        pos_pus_est = [x_uic, y_uic, w_uic, h_uic];
        x_uic = x_uic+w_uic+2*bdx;
        pos_tog_res = [x_uic, y_uic, w_uic, h_uic];

        % Create UIC.
        %------------
        comProp = {...
           'Parent',fig,    ...
           'Unit',fig_units ...
           'Visible','On'  ...
           };
        comTxtProp = {comProp{:}, ...
           'Style','Text',...
           'HorizontalAlignment','center', ...
           'Backgroundcolor',bkColor ...
           };

        fra_utl = uicontrol(comProp{:}, ...
                            'Style','frame', ...
                            'Position',pos_fra, ...
                            'Backgroundcolor',bkColor, ...
                            'Tag',tag_fra_tool ...
                            );

        txt_top = uicontrol(comProp{:}, ...
                            'Style','Text', ...
                            'Position',pos_txt_top,   ...
                            'String',str_txt_top,     ...
                            'Backgroundcolor',bkColor ...
                            );

        cba = [mfilename '(''update_methName'',' str_numfig ');'];
        pop_met = uicontrol(comProp{:}, ...
                            'Style','Popup',...
                            'Position',pos_pop_met,...
                            'Enable',statusINI, ...
                            'String',str_pop_met,...
                            'HorizontalAlignment','center',...
                            'Userdata',1,...
                            'Callback',cba ...
                            );

        switch  toolOPT
          case {'deno','esti'}
            rad_sof = uicontrol(comProp{:}, ...
                                'Style','RadioButton',...
                                'Position',pos_rad_sof,...
                                'Enable',statusINI, ...
                                'HorizontalAlignment','center',...
                                'String',str_rad_sof,...
                                'Value',1,'Userdata',1 ...
                                );

            rad_har = uicontrol(comProp{:}, ...
                                'Style','RadioButton',...
                                'Position',pos_rad_har,...
                                'Enable',statusINI, ...
                                'HorizontalAlignment','center',...
                                'String',str_rad_har,...
                                'Value',0,'Userdata',0 ...
                                );
            cba = [mfilename '(''update_thrType'',' str_numfig ');'];
            set(rad_sof,'Callback',cba);
            set(rad_har,'Callback',cba);

            txt_noi = uicontrol(comProp{:}, ...
                                'Style','Text',...
                                'Position',pos_txt_noi,...
                                'Backgroundcolor',bkColor,...
                                'String',str_txt_noi...
                                );

            cba = [mfilename '(''update_by_Caller'',' str_numfig ');'];
            pop_noi = uicontrol(comProp{:}, ...
                                'Style','Popup',...
                                'Position',pos_pop_noi,...
                                'Enable',statusINI, ...
                                'String',str_pop_noi,...
                                'HorizontalAlignment','center',...
                                'Userdata',1,...
                                'Callback',cba ...
                                );
          case {'comp'}
        end

        txt_BMS = uicontrol(comProp{:}, ...
                            'Style','Text',...
                            'Position',pos_txt_BMS,...
                            'Backgroundcolor',bkColor,...
                            'String',str_txt_BMS...
                            );

        cba = [mfilename '(''update_by_Caller'',' str_numfig ');'];
        sli_BMS = uicontrol(comProp{:}, ...
                            'Style','Slider',...
                            'Position',pos_sli_BMS,...
                            'Enable',statusINI,    ...
                            'Min',1+sqrt(eps),     ...
                            'Max',5-sqrt(eps),     ...
                            'Value',1.5,           ...
                            'Backgroundcolor',bkColor, ...
                            'Callback',cba         ...
                            );

        cba = [mfilename '(''update_DIR'',' str_numfig ');'];
        pop_dir = uicontrol(comProp{:}, ...
                            'Style','Popup',...
                            'Position',pos_pop_dir,...
                            'Enable',statusINI,    ...
                            'String',str_pop_dir,  ...
                            'Userdata',1,          ...
                            'Callback',cba         ...
                            );
        txt_tit = zeros(3,1);
        for k=1:3
            txt_tit(k) = uicontrol(...
                                   comTxtProp{:}, ...
                                   'Position',pos_lev_tit(k,:), ...
                                   'String',deblank(str_txt_tit(k,:))...
                                   );
        end
        xbtn0 = xleft;
        ybtn0 = pos_lev_tit(1,2)-Def_Btn_Height;
        xbtn  = xbtn0;
        ybtn  = ybtn0;
        if ud.ydir==1
            index = [1:levmaxMAX];
        else
            index = [levmaxMAX:-1:1];
            ybtn  = ybtn0+(levmaxMAX-levmax)*dy_lev;
        end
        for j=1:length(index)
            i = index(j);
            max_lev = 1;
            val_lev = 0.5;
            pos_lev = [xbtn ybtn+d_txt/2 w_lev(1) Def_Txt_Height];
            str_lev = sprintf('%.0f',i);
            txt_lev = uicontrol(...
                              comTxtProp{:},     ...
                              'Position',pos_lev,...
                              'String',str_lev,  ...
                              'Userdata',i       ...
                              );

            xbtn    = xbtn+w_lev(1)+wx;
            pos_lev = [xbtn, ybtn+sli_dy, w_lev(2), sli_hi];
            sli_lev = uicontrol(...
                              comProp{:},         ...
                              'Style','Slider',   ...
                              'Enable',enaVal,    ...
                              'Position',pos_lev, ...
                              'Min',0,            ...
                              'Max',max_lev,      ...
                              'Value',val_lev,    ...
                              'Userdata',i        ...
                              );

            xbtn    = xbtn+w_lev(2)+wx;
            pos_lev = [xbtn ybtn w_lev(3) Def_Btn_Height];
            str_val = sprintf('%1.4g',val_lev);
            edi_lev = uicontrol(...
                              comProp{:},         ...
                              'Style','Edit',     ...
                              'Enable',enaVal,    ...
                              'Position',pos_lev, ...
                              'String',str_val,   ...
                              'HorizontalAlignment','center',...
                              'Backgroundcolor',Def_EdiBkColor,...
                              'Userdata',i          ...
                              );

            beg_cba = [mfilename '(''update_by_UIC'',' str_numfig ',' str_lev];
            cba_sli = [beg_cba ',''sli'');'];
            cba_edi = [beg_cba ',''edi'');'];
            set(sli_lev,'Callback',cba_sli);
            set(edi_lev,'Callback',cba_edi);
            h_CMD_LVL(:,i) = [txt_lev ; sli_lev ; edi_lev];
            xbtn = xbtn0;
            ybtn = ybtn-dy_lev;
        end

        switch  toolOPT
          case {'deno','esti'}
          case {'comp'}
            comEdiProp = {comProp{:}, ...
                'Style','Edit',...
                'String','',...
                'Enable','Inactive', ...
                'Backgroundcolor',bkColor,...
                'HorizontalAlignment','center'...
                };
            txt_nor = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_nor,...
                                'HorizontalAlignment','left',...
                                'String',str_txt_nor...
                                );

            cba_nor = [mfilename '(''updateTHR'',' str_numfig ',''nor'');'];
            edi_nor = uicontrol(comEdiProp{:}, ...
                                'Position',pos_edi_nor,...
                                'Callback',cba_nor ...
                                );

            txt_npc = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_npc,...
                                'String','%'...
                                );

            txt_zer = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_zer,...
                                'HorizontalAlignment','left',...
                                'String',str_txt_zer...
                                );

            cba_zer = [mfilename '(''updateTHR'',' str_numfig ',''zer'');'];
            edi_zer = uicontrol(comEdiProp{:}, ...
                                'Position',pos_edi_zer,...
                                'Callback',cba_zer ...
                                );

            txt_zpc = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_zpc,...
                                'String','%'...
                                );
        end

        cba = [mfilename '(''residuals'',' str_numfig ');'];
        tip = 'More on Residuals';
        tog_res = uicontrol(...
                            comProp{:},             ...
                            'Style','Togglebutton', ...
                            'Position',pos_tog_res, ...
                            'String',str_tog_res,   ...
                            'Enable','off',         ...
                            'Callback',cba,         ...
                            'tooltip',tip,          ...
                            'Interruptible','Off'   ...
                            );

        cba_pus_est = [mfilename '(''' estOPT ''',' str_numfig ');'];
        pus_est = uicontrol(comProp{:},             ...
                            'Style','Pushbutton',   ...
                            'Position',pos_pus_est, ...
                            'String',xlate(str_pus_est),   ...
                            'Enable',enaVal,        ...
                            'callback',cba_pus_est  ...
                            );

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------							
        switch  toolOPT
          case {'deno','esti'}
			hdl_DENO_SOFTHARD   = [rad_sof,rad_har];
			hdl_DENO_NOISSTRUCT = [txt_noi,pop_noi];
			wfighelp('add_ContextMenu',fig,hdl_DENO_SOFTHARD,'DENO_SOFTHARD');
			wfighelp('add_ContextMenu',fig,hdl_DENO_NOISSTRUCT,'DENO_NOISSTRUCT');
		
          case {'comp'}
			hdl_COMP_SCORES = [...
				txt_nor,edi_nor,txt_npc,txt_zer,edi_zer,txt_zpc ...
				];			  
			wfighelp('add_ContextMenu',fig,hdl_COMP_SCORES,'COMP_SCORES');

        end
        hdl_COMP_DENO_STRA = [...
			fra_utl,txt_top,pop_met,txt_BMS,sli_BMS,  ...
			];				
		wfighelp('add_ContextMenu',fig,hdl_COMP_DENO_STRA,'COMP_DENO_STRA');
		%-------------------------------------

		% Store handles.
		%--------------
        switch  toolOPT
          case {'deno','esti'}
            ud.handlesUIC = ...
                [fra_utl;txt_top;pop_met;...
                rad_sof;rad_har;txt_noi;pop_noi; ...
                txt_BMS;sli_BMS;pop_dir;txt_tit(1:3); ...
                NaN;NaN;NaN;NaN;NaN;NaN; ...
                tog_res;pus_est];

          case {'comp'}
            ud.handlesUIC = ...
                [fra_utl;txt_top;pop_met; ...
                NaN;NaN;NaN;NaN; ...
                txt_BMS;sli_BMS;pop_dir;txt_tit(1:3);...
                txt_nor;edi_nor;txt_npc;txt_zer;edi_zer;txt_zpc; ...
                tog_res;pus_est];

        end        
        ud.h_CMD_LVL = h_CMD_LVL;
        ud.h_GRA_LVL = h_GRA_LVL;
        set(fra_utl,'Userdata',ud);
        varargout{1} = utthrw2d('set',fig,'position',{levmin,levmax});

    case 'status'
      if length(varargin)>0
         toolStatus = varargin{1};
         ud.status  = toolStatus;
         set(fra,'Userdata',ud);
         set([pop_met;rad_sof;rad_har;...
              pop_noi;sli_BMS;pop_dir],'Enable',toolStatus)
         if isequal(lower(toolStatus),'off')
             utthrw2d('enable',fig,'off')
         end       
      end
      varargout{1} = toolStatus;

    case 'enable'
        enaVal = varargin{1};
        if length(varargin)>1
            levs = varargin{2};
        else
            levs = [1:size(h_GRA_LVL,3)];
        end
        uic = h_CMD_LVL(2:3,:);
        set([uic(:);tog_res;pus_est],'Enable','off');
        if isequal(lower(enaVal),'on')
            uic = h_CMD_LVL(2:3,levs);
            set([uic(:);pus_est],'Enable',enaVal);
        end

    case 'enable_tog_res'
        enaVal = varargin{1};
        set(tog_res,'Enable',enaVal);

    case 'visible'
        visVal     = lower(varargin{1});
        ud.visible = visVal;
        handlesAXE = h_GRA_LVL(1,:,ud.levmin:ud.levmax);
        handlesAXE = findobj(handlesAXE(ishandle(handlesAXE(:))));
        if isequal(visVal,'on')
            h_CMD_LVL = h_CMD_LVL(1:3,ud.levmin:ud.levmax);
            numMeth = get(pop_met,'value');
            switch toolOPT
              case {'deno','esti'}
                switch numMeth
                  case {1,5}   , invis = [txt_BMS;sli_BMS];
                  case {2,3,4} , invis = [txt_noi;pop_noi];
                end

              case {'comp'}
                switch numMeth
                   case {1,2,3} , invis = [];
                   case {4,5,6} , invis = [txt_BMS;sli_BMS];
                end 
            end
            handlesUIC = setdiff(handlesUIC,invis);
        end
        handles = [h_CMD_LVL(:);handlesAXE(:);handlesUIC(:)];
        set(handles(ishandle(handles)),'visible',visVal);

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:2:nbarg
           argType = lower(varargin{k});
           argVal  = varargin{k+1};
           switch argType
               case 'position'
                 [levmin,levmax] = deal(argVal{:});
                 nblevs = levmax-levmin+1;
                 if ud.ydir==1
                     dnum_lev = (levmin-ud.levmin);
                 else
                     dnum_lev = (ud.levmax-levmax);
                 end
                 ud.levmin = levmin;
                 ud.levmax = levmax;
                 set(fra,'Userdata',ud);
                 old_units = get(fig,'units');
                 tmpHandles = [h_CMD_LVL(:);handlesUIC(:)];
                 tmpHandles = tmpHandles(ishandle(tmpHandles));
                 set(tmpHandles,'visible','off');
                 set([fig;tmpHandles],'units','pixels');
                 [pos_fra,dy_lev,y_res,y_est] = getPosFraThr(fra,nblevs,toolOPT);
                 set(fra,'Position',pos_fra);
                 ytrans = dnum_lev*dy_lev;
                 [row,col] = size(h_CMD_LVL);
                 for j=1:col
                     for k = 1:row
                         p = get(h_CMD_LVL(k,j),'Position');
                         set(h_CMD_LVL(k,j),'Position',[p(1),p(2)+ytrans,p(3:4)]);
                     end
                 end
                 p = get(tog_res,'Position');
                 set(tog_res,'Position',[p(1),y_res,p(3:4)]);
                 ytrans = y_res-p(2);
                 p = get(pus_est,'Position');
                 set(pus_est,'Position',[p(1),y_est,p(3:4)]);
                 switch toolOPT
                   case {'comp'}
                     tmpHDL = [txt_nor;edi_nor;txt_npc;txt_zer;edi_zer;txt_zpc];
                     for k = 1:length(tmpHDL)
                         p = get(tmpHDL(k),'Position');
                         set(tmpHDL(k),'Position',[p(1),p(2)+ytrans,p(3:4)]);
                     end                  
                 end
                 set([fig;tmpHandles],'units',old_units);
                 utthrw2d('visible',fig,ud.visible);
                 if nargout>0
                     varargout{1} = [pos_fra(1) , y_est , pos_fra([3 4])];
                 end

               case 'axes'
                 [row,col] = size(argVal);
                 ud.h_GRA_LVL(1,1:row,1:col) = argVal;
                 set(fra,'Userdata',ud);

               case 'handleori' , ud.handleORI = argVal; set(fra,'Userdata',ud);
               case 'handlethr' , ud.handleTHR = argVal; set(fra,'Userdata',ud);
               case 'handleres' , ud.handleRES = argVal; set(fra,'Userdata',ud);
               case 'perfos'  
                 switch toolOPT
                   case {'comp'}
                     set(edi_nor,'string',sprintf('%5.2f',argVal{1}));
                     set(edi_zer,'string',sprintf('%5.2f',argVal{2}));
                 end
               case {'valthr','maxthr'}
                 threshDEF = NaN*ones(3,ud.levmaxMAX);
                 sizARG = size(argVal);
                 NB_old = ud.levmax-ud.levmin+1;
                 if (sizARG(1)==3) && (sizARG(2)>NB_old)
                    Cbeg = 1; Cend = sizARG(2);
                 else
                    Cbeg = ud.levmin; Cend = ud.levmax;
                 end
                 threshDEF(:,Cbeg:Cend) = argVal;
                 if isequal(argType,'valthr')
                     ud.thrStruct.value = threshDEF;
                 else
                     ud.thrStruct.max = threshDEF;
                 end
                 set(fra,'Userdata',ud);
           end
        end

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:nbarg
           outType = lower(varargin{k});
           switch outType
               case 'position'
                 pos_fra = get(fra,'Position');
                 pos_est = get(pus_est,'Position');
                 varargout{k} = [pos_fra(1) , pos_est(2) , pos_fra([3 4])];

               case 'valthr' ,
                 varargout{k} = ud.thrStruct.value(:,ud.levmin:ud.levmax);

               case 'allvalthr' , varargout{k} = ud.thrStruct.value;                 
               case 'maxthr'    , varargout{k} = ud.thrStruct.max;

               case {'pus_den','pus_est','pus_com'} , varargout{k} = pus_est;
               case 'handleori' , varargout{k} = ud.handleORI;
               case 'handlethr' , varargout{k} = ud.handleTHR;
               case 'handleres' , varargout{k} = ud.handleRES;
           end
        end

    case 'update_methName'
        numMeth = get(pop_met,'value');
        switch toolOPT
          case {'deno','esti'}
            HDL_1 = [txt_BMS;sli_BMS];
            HDL_2 = [txt_noi;pop_noi];
            switch numMeth
              case {1,5}
                invis  = HDL_1;   vis = HDL_2;
                radDef = rad_sof; radNoDef = rad_har;
              case {2,3,4}
                invis  = HDL_2;   vis = HDL_1;
                radDef = rad_har; radNoDef = rad_sof;
            end
            set(sli_BMS,'value',3)
            set(invis,'Visible','off')
            set(vis,'Visible','on')
            set(radDef,'Value',1,'Userdata',1);
            set(radNoDef,'Value',0,'Userdata',0);

          case {'comp'}
            HDL_1 = [txt_BMS;sli_BMS];
            HDL_2 = [];
            switch numMeth
              case {1,2,3} , invis = HDL_2; vis = HDL_1;
              case {4,5,6} , invis = HDL_1; vis = HDL_2;
            end
            set(sli_BMS,'value',1.5);
            set(invis,'Visible','off')
            set(vis,'Visible','on')
        end
        utthrw2d('update_by_Caller',fig)

    case 'update_DIR'
        newDIR = get(pop_dir,'Value');
        oldDIR = get(pop_dir,'Userdata');
        if isequal(newDIR,oldDIR) , return; end
        set(pop_dir,'Userdata',newDIR)
        valTHR = ud.thrStruct.value(newDIR,:);
        maxTHR = ud.thrStruct.max(newDIR,:);
        for k = ud.levmin:ud.levmax
            set(h_CMD_LVL(2,k),'Min',0,'Max',maxTHR(k),'Value',valTHR(k));
            set(h_CMD_LVL(3,k),'String',sprintf('%1.4g',valTHR(k)));
        end

    case 'update_by_UIC'
        level    = varargin{1};
        type_hdl = varargin{2};
        sli = h_CMD_LVL(2,level);
        edi = h_CMD_LVL(3,level);
        dir = get(pop_dir,'Value');
        lHu = h_GRA_LVL(2,dir,level);
        lHd = h_GRA_LVL(3,dir,level);

        % Updating threshold.
        %---------------------
        switch type_hdl
            case 'sli'
              thresh = get(sli,'value');
              set(edi,'string',sprintf('%1.4g',thresh));

            case 'edi'
              valstr = get(edi,'string');
              [thresh,count,err] = sscanf(valstr,'%f');
              if (count~=1) || ~isempty(err)
                  thresh = get(sli,'Value');
                  set(edi,'string',sprintf('%1.4g',thresh));
                  return
              else
                  mi = get(sli,'Min');
                  ma = get(sli,'Max');
                  if     thresh<mi , thresh = mi;
                  elseif thresh>ma , thresh = ma;
                  end
                  set(sli,'Value',thresh);
                  set(edi,'string',sprintf('%1.4g',thresh));
              end
        end
        xdata = [thresh thresh];
        set(lHu,'Xdata', xdata);
        if thresh<sqrt(eps) , xdata = [NaN NaN]; end
        set(lHd,'Xdata',-xdata);
        feval(calledFUN,'clear_GRAPHICS',fig);
        utthrw2d('update_thrStruct',fig,dir,level,thresh);
        if isequal(toolOPT,'comp') , utthrw2d('show_LVL_perfos',fig); end

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

    case 'update_by_Caller'
        feval(calledFUN,'update_LVL_meth',fig);

    case 'get_LVL_par'
        numMeth = get(pop_met,'value');
        meth    = wthrmeth(toolOPT,'shortnames',numMeth);
        switch  toolOPT
          case {'deno','esti'}             
             valType = get(rad_sof,'value');
             if valType==1 , sorh = 's'; else , sorh = 'h'; end
             switch numMeth
               case {1,5}
                 valNoise = get(pop_noi,'value');
                 switch valNoise
                   case 1 , scal = 'sln';
                   case 2 , scal = 'one';
                   case 3 , scal = 'mln';
                 end
               case {2,3,4}, scal = get(sli_BMS,'value');
             end
             varargout = {numMeth,meth,scal,sorh};

          case {'comp'}
             sorh = 'h';
             switch numMeth
               case {1,2,3} , scal = get(sli_BMS,'value');
               case {4,5,6} , scal = get(sli_BMS,'value'); % Not Used           
             end
             varargout = {numMeth,meth,scal,sorh};
        end

    case 'update_LVL_meth'
        % called by : calledFUN('update_LVL_meth', ...)
        %-------------------------------------------
        valTHR = varargin{1};
        NB_lev = size(valTHR,2);
        maxTHR = utthrw2d('get',fig,'maxTHR');
        maxTHR = maxTHR(:,ud.levmin:NB_lev);        
        valTHR = min(valTHR,maxTHR);
        
        utthrw2d('set',fig,'valTHR',valTHR);
        direct = get(pop_dir,'Value'); 
        sli_lev = h_CMD_LVL(2,1:NB_lev);
        edi_lev = h_CMD_LVL(3,1:NB_lev);        
        for k = 1:NB_lev
            thr  = valTHR(direct,k);
            set(sli_lev(k),'Value',thr);
            set(edi_lev(k),'string',sprintf('%1.4g',thr));            
        end
        for k = 1:NB_lev
            for d=1:3
                thr = valTHR(d,k);
                thr = [thr thr];
                set(h_GRA_LVL(2,d,k),'Xdata', thr);
                set(h_GRA_LVL(3,d,k),'Xdata',-thr);
            end
        end

    case 'show_LVL_perfos'
        if isequal(toolOPT,'comp')
            feval(calledFUN,'show_LVL_perfos',fig);
        end

    case 'update_thrStruct'
        % called by : cbthrw2d
        %----------------------
        dir   = varargin{1};
        level = varargin{2};
        thr   = varargin{3};
        ud.thrStruct.value(dir,level) = thr;
        set(fra,'Userdata',ud);

    case {'denoise','compress','estimate'}
        feval(calledFUN,option,fig);

    case 'clean_thr'
        set(h_CMD_LVL(2,:),'Min',0,'Max',1,'Value',0.5);  % sli_lev;
        set(h_CMD_LVL(3,:),'String','');                  % edi_lev
        switch toolOPT
          case {'deno','esti'} , 
          case {'comp'} ,
        end

    case 'residuals'
        wmoreres('create',fig,tog_res,ud.handleRES,ud.handleORI,ud.handleTHR,'blocPAR');

    case 'plot_dec'
        dirDef = get(pop_dir,'Value');
        [thr_max,thr_val,ylim,direct,level,axeAct] = deal(varargin{2}{:});
        if direct==dirDef
            set(h_CMD_LVL(2,level),'Min',0,'Max',thr_max,'Value',thr_val);
            set(h_CMD_LVL(3,level),'String',sprintf('%1.4g',thr_val));
        end
        colTHR = wtbutils('colors','linTHR');
        l_min = line('Linestyle','--',...
                  'Color',colTHR,...
                  'EraseMode','xor',...
                  'Xdata',[thr_val thr_val],...
                  'Ydata',ylim,...
                  'Parent',axeAct);
        l_max = line('Linestyle','--',...
                  'Color',colTHR,...
                  'EraseMode','xor',...
                  'Xdata',[-thr_val -thr_val],...
                  'Ydata',ylim,...
                  'Parent',axeAct);
        setappdata(l_min,'selectPointer','V');
        setappdata(l_max,'selectPointer','V');
        if thr_val==0 , set(l_max,'Visible','Off'); end
        maxval  = num2mstr(thr_max);
        hdl_str = num2mstr(...
                    [fig ; pop_dir ; direct ; level ; ...
                     l_min; l_max; h_CMD_LVL(2:3,level)] ...
                     );
        cba_thr_min = ['cbthrw2d' '(''down'',' hdl_str ',' ...
                                int2str(+1) ',' maxval ');'];
        cba_thr_max = ['cbthrw2d' '(''down'',' hdl_str ',' ...
                                int2str(-1) ',' maxval ');'];
        set(l_min,'ButtonDownFcn',cba_thr_min)
        set(l_max,'ButtonDownFcn',cba_thr_max)
        h_GRA_LVL(2:3,direct,level) = [l_min , l_max];
        ud.h_GRA_LVL = h_GRA_LVL;
        set(fra,'Userdata',ud);

    case 'demo'
    % SPECIAL for DEMOS
    %------------------
    [tool,den_Meth,thr_Val] = deal(varargin{:});
    shortnames = wthrmeth(toolOPT,'shortnames');
    ind = strmatch(deblank(den_Meth),shortnames);
    if isempty(ind) , return; end
    set(pop_met,'Value',ind)
    utthrw2d('update_methName',fig)
    if ~isnan(thr_Val)
        utthrw2d('set',fig,'valTHR',thr_Val);
        thr_Val = utthrw2d('get',fig,'valTHR');
        utthrw2d('update_LVL_meth',fig,thr_Val);
    end

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
  case {'deno','esti'}
    thrMethods = {...
        'Fixed form threshold',       'sqtwolog',    1; ...
        'Penalize high',              'penalhi',     2; ...
        'Penalize medium',            'penalme',     3; ...
        'Penalize low',               'penallo',     4; ...
        'Bal. sparsity-norm (sqrt)',  'sqrtbal_sn',  5  ...
        };

  case 'comp'
    thrMethods = {...
        'Scarce high',                'scarcehi',   1; ...
        'Scarce medium',              'scarceme',   2; ...
        'Scarce low',                 'scarcelo',   3; ...
        'Balance sparsity-norm',      'bal_sn',     4; ...
        'Remove near 0',              'rem_n0',     5; ...
        'Bal. sparsity-norm (sqrt)',  'sqrtbal_sn', 6  ...
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
function [pos_fra,dy_lev,y_res,y_est] = getPosFraThr(fra,nblevs,toolOPT)

Def_Btn_Height = mextglob('get','Def_Btn_Height');
d_lev = 2;
bdy   = 4;
pos_fra = get(fra,'Position');
top_fra = pos_fra(2)+pos_fra(4);
switch  toolOPT
  case {'deno','esti'} , NB_Height = 7;
  case {'comp'}        , NB_Height = 8;
end
h_ini   = (NB_Height-2)*bdy+NB_Height*Def_Btn_Height;
h_fra   = h_ini+ nblevs*(Def_Btn_Height+d_lev);
pos_fra(2) = top_fra-h_fra;
pos_fra(4) = h_fra;
dy_lev = d_lev+Def_Btn_Height;
y_est  = pos_fra(2)-(3*Def_Btn_Height)/2-Def_Btn_Height/2;
y_res  = y_est;
%-----------------------------------------------------------------------------%
function varargout = depOfMachine(varargin)

btn_height = varargin{1};
scrSize = get(0,'ScreenSize');
if scrSize(4)<600
    height = btn_height;
elseif scrSize(4)<800
    height = 3*btn_height/2;
else
    height = 3*btn_height/2;
end
varargout = {height};
%-----------------------------------------------------------------------------%
%=============================================================================%
