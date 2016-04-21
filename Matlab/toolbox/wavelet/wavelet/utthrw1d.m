function varargout = utthrw1d(option,fig,varargin)
%UTTHRW1D Utilities for wavelet thresholding 1-D.
%   VARARGOUT = UTTHRW1D(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-98.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/03/15 22:42:11 $

% MemBloc of stored values.
%--------------------------
n_memblocTHR   = 'MB_ThrStruct';
ind_thr_struct = 1;
ind_int_thr    = 2;

% Default values.
%----------------
max_lev_anal = 12;
def_lev_anal = 5;

% Tag property of objects.
%-------------------------
tag_fra_tool   = ['Fra_' mfilename];
tag_lineH_up   = 'LH_u';
tag_lineH_down = 'LH_d';
tag_lineV      = 'LV';

switch option
  case {'create'}

  otherwise
    % ud.handlesUIC = ...
    %   [fra_utl;txt_top;pop_met; ...
    %    rad_sof;rad_har;txt_noi;pop_noi; ...
    %    txt_BMS;sli_BMS;txt_tit(1:4),...
    %    txt_nor;edi_nor;txt_npc; ...
    %    txt_zer;edi_zer;txt_zpc; ...
    %    tog_thr;tog_res;pus_est];
    %-----------------------------------------
    if ~ishandle(fig) , varargout{1} = []; return; end
    uic = findobj(get(fig,'Children'),'flat','type','uicontrol');
    fra = findobj(uic,'style','frame','tag',tag_fra_tool);
    if isempty(fra) , return; end
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    ud  = get(fra,'Userdata');
    toolOPT = ud.toolOPT;
    toolStatus = ud.status;
    handlesUIC = ud.handlesUIC;
    h_CMD_LVL  = ud.h_CMD_LVL;
    h_GRA_LVL  = ud.h_GRA_LVL;
    switch option
      case 'handles'
        handles = [handlesUIC(:);h_CMD_LVL(:)];
        varargout{1} = handles(ishandle(handles));
        return;

      case {'handlesUIC','handlesuic'}
        varargout{1} = handlesUIC;
        return;

      case {'h_CMD_LVL','h_cmd_lvl'}
        varargout{1} = h_CMD_LVL;
        return;
    end
    ind = 2;
    txt_top = handlesUIC(ind); ind = ind+1;
    pop_met = handlesUIC(ind); ind = ind+1;
    rad_sof = handlesUIC(ind); ind = ind+1;
    rad_har = handlesUIC(ind); ind = ind+1;
    txt_noi = handlesUIC(ind); ind = ind+1;
    pop_noi = handlesUIC(ind); ind = ind+1;
    txt_BMS = handlesUIC(ind); ind = ind+1;  
    sli_BMS = handlesUIC(ind); ind = ind+1;
    txt_tit(1:4) = handlesUIC(ind:ind+3); ind = ind+4;
    txt_nor = handlesUIC(ind); ind = ind+1;
    edi_nor = handlesUIC(ind); ind = ind+1;
    txt_npc = handlesUIC(ind); ind = ind+1;
    txt_zer = handlesUIC(ind); ind = ind+1;
    edi_zer = handlesUIC(ind); ind = ind+1;
    txt_zpc = handlesUIC(ind); ind = ind+1;
    tog_thr = handlesUIC(ind); ind = ind+1;
    tog_res = handlesUIC(ind); ind = ind+1;
    pus_est = handlesUIC(ind); ind = ind+1;
end

switch option
    case 'create'
        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,sliYProp,...
         Def_FraBkColor,Def_EdiBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
                'Pop_Min_Width','X_Spacing','Y_Spacing','Sli_YProp', ...
                'Def_FraBkColor','Def_EdiBkColor'   ...
                );

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
        visVal = 'on';
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
        % h_CMD_LVL: [txt_lev ; pop_int; sli_lev ; edi_lev] x Level
        % h_GRA_LVL: [axe_thr ; lin_min ; lin_max] x Level
        h_CMD_LVL = NaN*ones(4,levmaxMAX);        
        h_GRA_LVL = NaN*ones(3,levmaxMAX);
        thrStruct = struct(...
                        'thrParams',cell(levmaxMAX,1), ...
                        'hdlLines',cell(levmaxMAX,1)   ...                        '
                        );
        wmemtool('wmb',fig,n_memblocTHR, ...
                  ind_thr_struct,thrStruct,ind_int_thr,[]);
        ud = struct(...
                'toolOPT',toolOPT, ...
                'status',statusINI,...
                'levmin',levmin, ...
                'levmax',levmax, ...
                'levmaxMAX',levmaxMAX, ...
                'levANAL',levANAL, ...
                'visible',lower(visVal),...
                'ydir', ydir,    ...
                'isbior',isbior, ...
                'handlesUIC',[], ...
                'h_CMD_LVL',h_CMD_LVL, ...
                'h_GRA_LVL',h_GRA_LVL, ...
                'handleORI' ,[], ... 
                'handleTHR',[],  ... 
                'handleRES' ,[]  ... 
                );

        % Figure units.
        %--------------
        str_numfig = num2mstr(fig);
        old_units  = get(fig,'units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'units',fig_units); end       

        % Positions utilities.
        %---------------------
        nblevs = abs(levmax-levmin)+1;        
        dx = X_Spacing; bdx = 3;
        dy = Y_Spacing; 
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        deltaY = (Def_Btn_Height+dy);
        [bdy,d_lev] = get_DLEV(nblevs,toolOPT);
        sli_hi = Def_Btn_Height*sliYProp;
        sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);

        % Setting frame position.
        %------------------------
        if ~isequal(toolOPT,'esti_DEN') , multiY = 1; else , multiY = 1; end
        switch  toolOPT
          case {'deno','esti'} , NB_Height = 6;
          case {'esti_REG'}    , NB_Height = 6;
          case {'esti_DEN'}    , NB_Height = 4+2*multiY;
          case {'comp'}        , NB_Height = 7;
        end
        w_fra   = wfigmngr('get',fig,'fra_width');
        h_fra   = (levmaxMAX+NB_Height)*Def_Btn_Height+...
                   levmaxMAX*d_lev+ ...
                   depOfMachine(Def_Btn_Height)+(NB_Height-1)*bdy;
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fra = [xleft,ybottom,w_fra,h_fra];

        % String properties.
        %-------------------
        str_txt_top = 'Select thresholding method';
        str_txt_BMS = '-       Sparsity       +';
        str_txt_tit = strvcat('Lev','Int','Select','Thresh');
        str_tog_thr = ['Int. dependent threshold settings'];
        str_tog_res = 'Residuals';
        str_pop_met = wthrmeth(toolOPT,'names');
        switch  toolOPT
          case {'deno','esti','esti_REG'}
            str_rad_sof = 'soft';
            str_rad_har = 'hard';
            str_txt_noi = 'Select noise structure';
            str_pop_noi = strvcat(...
                'Unscaled white noise', ...
                'Scaled white noise',   ...
                'Non-white noise'       ...
                );

          case {'esti_DEN'}
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
          case {'esti','esti_REG','esti_DEN'} ,
                        str_pus_est = 'Estimate'; estOPT = 'estimate';
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
        switch toolOPT
          case {'deno','esti','esti_REG','esti_DEN'}
            y_uic       = y_uic-bdy;
            w_rad       = Pop_Min_Width;
            w_sep       = (w_uic-2*w_rad)/3;
            x_rad       = x_uic+w_sep;
            pos_rad_sof = [x_rad, y_uic, w_rad, Def_Btn_Height];
            x_rad       = x_rad+w_rad+w_sep;
            pos_rad_har = [x_rad, y_uic, w_rad, Def_Btn_Height];

            y_uic       = y_uic-multiY*Def_Btn_Height;
            y_BMS       = y_uic;
            pos_txt_noi = [x_uic, y_uic, w_uic, Def_Txt_Height];
            y_uic       = y_uic-multiY*Def_Btn_Height;
            pos_pop_noi = [x_uic, y_uic, w_uic, Def_Btn_Height];

          case 'comp'
            y_BMS       = y_uic;
            y_uic       = y_uic-Def_Btn_Height;
        end

        pos_txt_BMS = [x_uic, y_BMS, w_uic, Def_Txt_Height];
        y_BMS       = y_BMS-multiY*Def_Btn_Height;
        w_BMS       = (w_uic-bdx)/3;
        pos_sli_BMS = [x_uic+w_BMS/2, y_BMS+sli_dy, 2*w_BMS, sli_hi];

        wx          = 2;
        wbase       = 2*(w_rem-5*wx)/5;
        w_lev       = [4*wbase ; 7*wbase ; 12*wbase ; 7*wbase]/12;
        x_uic       = xleft+wx;
        y_uic       = y_uic-Def_Btn_Height;
        pos_lev_tit = [x_uic, y_uic, w_lev(1), Def_Txt_Height];
        pos_lev_tit = pos_lev_tit(ones(1,4),:);
        pos_lev_tit(:,3) = w_lev; 
        for k=1:3 , pos_lev_tit(k+1,1) = pos_lev_tit(k,1)+pos_lev_tit(k,3); end
        y_uic = pos_lev_tit(1,2)-levmaxMAX*(Def_Btn_Height+d_lev);

        switch  toolOPT
          case {'deno','esti','esti_REG','esti_DEN'}
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

        w_uic = w_rem-2*bdx;
        x_uic = xleft+bdx;
        h_uic = depOfMachine(Def_Btn_Height);        
        y_uic = y_uic-2*bdy-h_uic;
        pos_tog_thr = [x_uic, y_uic, w_uic, h_uic];
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
           'Visible','Off'  ...
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

        switch toolOPT
          case {'deno','esti','esti_REG','esti_DEN'}
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
        txt_tit = zeros(4,1);
        for k=1:4
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

            xbtn      = xbtn+w_lev(1)+wx;
            pos_lev = [xbtn ybtn w_lev(2) Def_Btn_Height];
            pop_lev = uicontrol(...
                         comProp{:}, ...
                         'Style','popupmenu',...
                         'Enable',enaVal,  ...
                         'Position',pos_lev,...
                         'String','1',...
                         'Backgroundcolor',bkColor, ...
                         'Userdata',i ...
                         );

            xbtn    = xbtn+w_lev(2)+wx;
            pos_lev = [xbtn, ybtn+sli_dy, w_lev(3), sli_hi];
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

            xbtn    = xbtn+w_lev(3)+wx;
            pos_lev = [xbtn ybtn w_lev(4) Def_Btn_Height];
            str_val = sprintfLOC('%7.3f',val_lev);
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
            cba_pop = [beg_cba ',''pop'');'];
            cba_sli = [beg_cba ',''sli'');'];
            cba_edi = [beg_cba ',''edi'');'];
            set(pop_lev,'Callback',cba_pop);
            set(sli_lev,'Callback',cba_sli);
            set(edi_lev,'Callback',cba_edi);

            h_CMD_LVL(:,i) = [txt_lev;pop_lev;sli_lev;edi_lev];
            xbtn = xbtn0;
            ybtn = ybtn-dy_lev;
        end
        switch  toolOPT
          case {'deno','esti','esti_REG','esti_DEN'}
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
        cba = [mfilename '(''init_SetThr'',' str_numfig ');'];
        tip = 'Interval dependent threshold Settings';
        tog_thr = uicontrol(...
                            comProp{:},             ...
                            'Style','Togglebutton', ...
                            'Position',pos_tog_thr, ...
                            'String',str_tog_thr,   ...
                            'Enable',enaVal,        ...
                            'Callback',cba,         ...
                            'tooltip',tip,          ...
                            'Interruptible','Off'   ...
                            );
        cba = [mfilename '(''residuals'',' str_numfig ');'];
        tip = 'More on Residuals';
        tog_res = uicontrol(...
                            comProp{:},             ...
                            'Style','Togglebutton', ...
                            'Position',pos_tog_res, ...
                            'String',str_tog_res,   ...
                            'Enable','off',         ...
                            'Callback',cba,         ...
                            'tooltip',tip,...
                            'Interruptible','Off'   ...
                            );

        if isequal(toolOPT,'esti_DEN')
           set(tog_res,'Visible','Off')
           pos_pus_est(1) =  pos_pus_est(1)+pos_pus_est(3)/2;
        end

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
          case {'deno','esti','esti_REG','esti_DEN'}
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
		hdl_IDTS_GUI = tog_thr;	
		wfighelp('add_ContextMenu',fig,hdl_COMP_DENO_STRA,'COMP_DENO_STRA');
		wfighelp('add_ContextMenu',fig,hdl_IDTS_GUI,'IDTS_GUI');		
		%-------------------------------------

		% Store handles.
		%--------------
		switch  toolOPT
          case {'deno','esti','esti_REG'}
            ud.handlesUIC = ...
                [fra_utl;txt_top;pop_met;...
                rad_sof;rad_har;txt_noi;pop_noi; ...
                txt_BMS;sli_BMS;txt_tit(1:4); ...
                NaN;NaN;NaN;NaN;NaN;NaN; ...
                tog_thr;tog_res;pus_est];

          case {'esti_DEN'}
            ud.handlesUIC = ...
                [fra_utl;txt_top;pop_met;...
                rad_sof;rad_har;txt_noi;pop_noi; ...
                txt_BMS;sli_BMS;txt_tit(1:4); ...
                NaN;NaN;NaN;NaN;NaN;NaN; ...
                tog_thr;tog_res;pus_est];

          case {'comp'}
            ud.handlesUIC = ...
                [fra_utl;txt_top;pop_met; ...
                NaN;NaN;NaN;NaN; ...
                txt_BMS;sli_BMS;txt_tit(1:4);...
                txt_nor;edi_nor;txt_npc;txt_zer;edi_zer;txt_zpc; ...
                tog_thr;tog_res;pus_est];
        end
        ud.h_CMD_LVL = h_CMD_LVL;
        ud.h_GRA_LVL = h_GRA_LVL;
        set(fra_utl,'Userdata',ud);
        varargout{1} = utthrw1d('set',fig,'position',{levmin,levmax});

    case {'denoise','compress','estimate'}
        feval(calledFUN,option,fig);

    case 'get_LVL_par'
        numMeth = get(pop_met,'value');
        meth    = wthrmeth(toolOPT,'shortnames',numMeth);
        switch  toolOPT
          case {'deno','esti','esti_REG'}
             valType = get(rad_sof,'value');
             if valType==1 , sorh = 's'; else , sorh = 'h'; end
             switch numMeth
               case {1,2,3,4}
                 valNoise = get(pop_noi,'value');
                 switch valNoise
                   case 1 , scal = 'sln';
                   case 2 , scal = 'one';
                   case 3 , scal = 'mln';
                 end
               case {5,6,7}  , scal = get(sli_BMS,'value');
             end
             varargout = {numMeth,meth,scal,sorh};

          case {'esti_DEN'}
             valType = get(rad_sof,'value');
             if valType==1 , sorh = 's'; else , sorh = 'h'; end
             switch numMeth
               case {1,2,3} , scal = [];
               case {4}  , scal = get(sli_BMS,'value');
             end
             varargout = {numMeth,meth,scal,sorh};

          case {'comp'}
             sorh = 'h'; 
             switch numMeth
               case {1,2,3} , scal = get(sli_BMS,'value');
               case {4,5}   , scal = NaN;
             end
             varargout = {numMeth,meth,scal,sorh};
        end

    case 'update_methName'
        numMeth = get(pop_met,'value');
        switch toolOPT
          case {'deno','esti','esti_REG'}
            HDL_1 = [txt_BMS;sli_BMS];
            HDL_2 = [txt_noi;pop_noi];
            switch numMeth
              case {1,2,3,4}
                invis  = HDL_1;   vis = HDL_2;
                radDef = rad_sof; radNoDef = rad_har;
              case {5,6,7}
                invis  = HDL_2;   vis = HDL_1;
                radDef = rad_har; radNoDef = rad_sof;
            end
            set(sli_BMS,'value',3)
            set(invis,'Visible','off')
            set(vis,'Visible','on')
            set(radDef,'Value',1,'Userdata',1);
            set(radNoDef,'Value',0,'Userdata',0);

          case {'esti_DEN'}
            switch numMeth
              case {1,2,3}
                set([txt_noi;pop_noi;txt_BMS;sli_BMS],'Visible','off')
                radDef = rad_sof; radNoDef = rad_har;
              case {4}
                set([txt_noi;pop_noi],'Visible','off')
                set([txt_BMS;sli_BMS],'Visible','on')
                radDef = rad_sof; radNoDef = rad_har;
            end
            set(sli_BMS,'value',3)
            set(radDef,'Value',1,'Userdata',1);
            set(radNoDef,'Value',0,'Userdata',0);

          case {'comp'}
            HDL_1 = [txt_BMS;sli_BMS];
            HDL_2 = [];
            switch numMeth
              case {1,2,3} , invis = HDL_2; vis = HDL_1;                
              case {4,5}   , invis = HDL_1; vis = HDL_2;
            end
            set(sli_BMS,'value',1.5);
            set(invis,'Visible','off')
            set(vis,'Visible','on')
        end
        utthrw1d('update_by_Caller',fig)

    case 'update_thrType'
        rad = gcbo;
        old = get(rad,'userdata');
        if isequal(old,1) , set(rad,'Value',1); return; end
        if isequal(rad,rad_sof)
           type = 's'; other = rad_har;
        else
           type = 'h'; other = rad_sof;           
        end
        set(other,'Value',0,'Userdata',0);
        set(rad,'Value',1,'Userdata',1);
        feval(calledFUN,'clear_GRAPHICS',fig);

    case 'update_hdlDEN'
        thrStruct = varargin{1};
        NB_lev  = size(thrStruct,1);
        pop_int = h_CMD_LVL(2,1:NB_lev);
        sli_lev = h_CMD_LVL(3,1:NB_lev);
        edi_lev = h_CMD_LVL(4,1:NB_lev);
        for k = 1:NB_lev
            thrParams = thrStruct(k).thrParams;
            if ~isempty(thrParams)
                linvalHdl = thrStruct(k).hdlLines;
                if ishandle(linvalHdl)
                   NB_int  = size(thrParams,1);
                   act_int = 1;
                   set(pop_int(k),'String',int2str([1:NB_int]'),'Value',act_int);
                   thr     = thrParams(act_int,3);
                   oldMax  = get(sli_lev(k),'Max');
                   newMax  = max([thr oldMax]);
                   set(sli_lev(k),'Max',newMax,'Value',thr);
                   set(edi_lev(k),'string',sprintfLOC('%7.3f',thr));

                   axeHdl  = get(linvalHdl,'Parent');
                   lv      = findobj(axeHdl,'tag',tag_lineV);
                   if ~isempty(lv) , delete(lv); end
                   lu      = findobj(axeHdl,'tag',tag_lineH_up);
                   ld      = findobj(axeHdl,'tag',tag_lineH_down);
                   [xHOR,yHOR] = getxy(thrParams);
                   yHOR    = abs(yHOR);
                   set(lu,'Xdata',xHOR,'Ydata',yHOR);
                   ind     = find(yHOR<sqrt(eps));
                   tmp     = yHOR;
                   if ~isempty(ind) , tmp(ind) = NaN; end
                   set(ld,'Xdata',xHOR,'Ydata',-tmp);
                   yVMin   = 2*max(abs(get(linvalHdl,'Ydata')));
                   cbthrw1d('plotLV',[fig ; lu ; ld],[xHOR ; yHOR],yVMin);
                end
            end
        end
        utthrw1d('set',fig,'thrstruct',thrStruct);

    case 'update_by_UIC'
        level    = varargin{1};
        type_hdl = varargin{2};
        pop      = h_CMD_LVL(2,level);
        sli      = h_CMD_LVL(3,level);
        edi      = h_CMD_LVL(4,level);
        lHu      = h_GRA_LVL(2,level);
        lHd      = h_GRA_LVL(3,level);

        % Updating threshold.
        %---------------------
        ok = 0;
        switch type_hdl
            case 'pop'

            case 'sli'
              thresh = get(sli,'value');
              set(edi,'string',sprintfLOC('%7.3f',thresh));

            case 'edi'
              valstr = get(edi,'string');
              [thresh,count,err] = sscanf(valstr,'%f');
              if (count~=1) || ~isempty(err)
                  thresh = get(sli,'Value');
                  set(edi,'string',sprintfLOC('%7.3f',thresh));
                  return
              else
                  mi = get(sli,'Min');
                  ma = get(sli,'Max');
                  if     thresh<mi , thresh = mi;
                  elseif thresh>ma , thresh = ma;
                  end
                  set(sli,'Value',thresh);
                  set(edi,'string',sprintfLOC('%7.3f',thresh));
              end
        end
        num_int = get(pop,'Value');
        ydata   = get(lHu,'Ydata');
        i_beg   = 3*(num_int-1)+1;
        switch type_hdl
            case 'pop'
              thresh  = ydata(i_beg);
              set(sli,'Value',thresh);
              set(edi,'string',sprintfLOC('%7.3f',thresh));

            case {'sli','edi'}
              i_end   = i_beg+1;
              ydata([i_beg i_end]) = [thresh thresh];
              set(lHu,'Ydata', ydata);
              if thresh<sqrt(eps)
                  ydata([i_beg i_end]) = [NaN NaN];
              end
              set(lHd,'Ydata',-ydata);
              cbthrw1d('upd_thrStruct',fig,lHu);
              ok = 1;
        end
        feval(calledFUN,'clear_GRAPHICS',fig);
        if ok , utthrw1d('show_LVL_perfos',fig); end

    case 'update_by_Caller'
        feval(calledFUN,'update_LVL_meth',fig);

    case 'update_LVL_meth'
        % called by : calledFUN('update_LVL_meth', ...)
        %----------------------------------------------
        valTHR = varargin{1};
        NB_lev = length(valTHR);
        maxTHR = utthrw1d('get',fig,'maxTHR');
        maxTHR = maxTHR(ud.levmin:ud.levmin+NB_lev-1);
        valTHR = min(valTHR,maxTHR);
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        xmin = thrStruct(ud.levmin).thrParams(1,1);
        xmax = thrStruct(ud.levmin).thrParams(end,2);
        nb_MAX = min([ud.levmax,ud.levmin+NB_lev-1]);
        for k=ud.levmin:nb_MAX
            thrStruct(k).thrParams = [xmin xmax valTHR(k)];
        end
        utthrw1d('update_hdlDEN',fig,thrStruct);

    case 'show_LVL_perfos'
        if isequal(toolOPT,'comp')
            feval(calledFUN,'show_LVL_perfos',fig);
        end

    case 'init_SetThr'
        utthrset('init');

    case 'return_SetThr'
        if isempty(varargin{1}) , return; end        
        feval(calledFUN,'clear_GRAPHICS',fig);
        utthrw1d('update_hdlDEN',fig,varargin{:})
        utthrw1d('show_LVL_perfos',fig);

    case 'status'
      if length(varargin)>0
         toolStatus = varargin{1};
         ud.status  = toolStatus;
         set(fra,'Userdata',ud);
         set([pop_met;rad_sof;rad_har;pop_noi;sli_BMS],'Enable',toolStatus)
         if isequal(lower(toolStatus),'off')
             utthrw1d('enable',fig,'off')
         end       
      end
      varargout{1} = toolStatus;
              
    case 'enable'
        enaVal = varargin{1};
        if length(varargin)>1
            levs = varargin{2};
        else
            levs = [1:size(h_GRA_LVL,2)];
        end
        uic = h_CMD_LVL(2:4,:);
        set([uic(:);tog_thr;tog_res;pus_est],'Enable','off');
        if isequal(lower(enaVal),'on')
            uic = h_CMD_LVL(2:4,levs);
            set([uic(:);tog_thr;pus_est],'Enable',enaVal);
        end

    case 'enable_tog_res'
        enaVal = varargin{1};
        set(tog_res,'Enable',enaVal);

    case 'visible'
        visVal     = lower(varargin{1});
        ud.visible = visVal;
        handlesAXE = h_GRA_LVL(1,ud.levmin:ud.levmax);
        handlesAXE = findobj(handlesAXE(ishandle(handlesAXE(:))));
        if isequal(visVal,'on')
            h_CMD_LVL = h_CMD_LVL(1:4,ud.levmin:ud.levmax);
            numMeth = get(pop_met,'value');
            switch toolOPT
              case {'deno','esti','esti_REG'}
                switch numMeth
                  case {1,2,3,4} , invis = [txt_BMS;sli_BMS];
                  case {5,6,7}   , invis = [txt_noi;pop_noi];
                end

              case {'esti_DEN'}
                switch numMeth
                  case {1,2,3} , invis = [txt_noi;pop_noi;txt_BMS;sli_BMS];
                  case {4}     , invis = [txt_BMS;sli_BMS];
                end

              case {'comp'}
                switch numMeth
                   case {1,2,3} , invis = [];
                   case {4,5}   , invis = [txt_BMS;sli_BMS];
                end 
            end
            handlesUIC = setdiff(handlesUIC,invis);
        end
        handles = [h_CMD_LVL(:);handlesAXE(:);handlesUIC(:)];
        set(handles(ishandle(handles)),'visible',visVal);
        if isequal(toolOPT,'esti_DEN')
           set(tog_res,'Visible','Off')
        end
        
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
               [pos_fra,dy_lev,y_thr,y_res,y_est] = ...
                       getPosFraThr(fra,nblevs,toolOPT);
               set(fra,'Position',pos_fra);
               ytrans = dnum_lev*dy_lev;
               for j=1:size(h_CMD_LVL,2)
                   for k = 1:4
                       p = get(h_CMD_LVL(k,j),'Position');
                       set(h_CMD_LVL(k,j),'Position',[p(1),p(2)+ytrans,p(3:4)]);
                   end
               end
               p = get(tog_thr,'Position');
               set(tog_thr,'Position',[p(1),y_thr,p(3:4)]);
               ytrans = y_thr-p(2);
               p = get(tog_res,'Position');
               set(tog_res,'Position',[p(1),y_res,p(3:4)]);
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
               utthrw1d('visible',fig,ud.visible);
               if nargout>0
                   varargout{1} = [pos_fra(1) , y_est , pos_fra([3 4])];
               end

             case 'thrstruct'
               if iscell(argVal)
                   [xmin,xmax,thr,hdl_lines] = deal(argVal{:});
                   first = ud.levmin;
                   last  = ud.levmax;
                   argVal = struct(...
                                'thrParams',cell(ud.levmaxMAX,1), ...
                                'hdlLines',cell(ud.levmaxMAX,1)   ...
                                );
                   for k=first:last
                       argVal(k).thrParams = [xmin xmax thr(k)];
                       argVal(k).hdlLines  = hdl_lines(k);
                   end
                 end
                 wmemtool('wmb',fig,n_memblocTHR,ind_thr_struct,argVal);

             case 'intdepthr'
                 wmemtool('wmb',fig,n_memblocTHR,ind_int_thr,argVal);

             case 'axes'
               h_GRA_LVL(1,1:length(argVal)) = argVal;
               ud.h_GRA_LVL = h_GRA_LVL;
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

             case 'thrstruct'
               varargout{k} = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);

             case 'intdepthr'
               varargout{k} = wmemtool('rmb',fig,n_memblocTHR,ind_int_thr);

             case 'maxthr'
               val = get(h_CMD_LVL(3,:),'Max');
               val = cat(2,val{:});
               varargout{k} = val;

             case 'valthr'
               val = get(h_CMD_LVL(3,:),'Value');
               val = cat(2,val{ud.levmin:ud.levmax});
               varargout{k} = val;

             case 'tog_thr'   , varargout{k} = tog_thr;
             case 'tog_res'   , varargout{k} = tog_res;
             case {'pus_den','pus_est','pus_com'} , varargout{k} = pus_est;
             case 'handleori' , varargout{k} = ud.handleORI;
             case 'handlethr' , varargout{k} = ud.handleTHR;
             case 'handleres' , varargout{k} = ud.handleRES;
           end
        end

    case 'clean_thr'
        set(h_CMD_LVL(2,:),'String','1','Value',1);       % pop_int;
        set(h_CMD_LVL(3,:),'Min',0,'Max',1,'Value',0.5);  % sli_lev;
        set(h_CMD_LVL(4,:),'String','');                  % edi_lev

    case 'plot_dec'
        lev = varargin{1};
        [max_det,val_lev,xmin,xmax,k] = deal(varargin{2}{:});
        set(h_CMD_LVL(3,lev),'Min',0,'Max',max_det,'Value',val_lev);
        set(h_CMD_LVL(4,lev),'String',sprintfLOC('%7.3f',val_lev));
        xHOR    = [xmin xmax];
        yHOR    = [val_lev val_lev];
        [lu,ld] = cbthrw1d('plotLH',[h_CMD_LVL(2:4,lev);h_GRA_LVL(1,lev)], ...
                           xHOR,yHOR,k,max_det);
        h_GRA_LVL(2:3,lev) = [lu;ld];
        ud.h_GRA_LVL = h_GRA_LVL;
        set(fra,'Userdata',ud);
 
    case 'residuals'
        [handleORI,handleTHR,handleRES] = ...
            utthrw1d('get',fig,'handleORI','handleTHR','handleRES');
        wmoreres('create',fig,tog_res,handleRES,handleORI,handleTHR,'blocPAR');

    case 'den_M1'
        cfs = varargin{1};
        len = varargin{2};
        thrStruct = utthrw1d('get',fig,'thrstruct');
        switch toolOPT
          case {'deno','esti','esti_REG','esti_DEN'}
            v = get(rad_sof,'Value');
            if v==1 , sorh = 's'; else , sorh = 'h'; end
          case {'comp'} , sorh = 'h';
        end
        NB_lev = size(thrStruct,1);
        for k = 1:NB_lev
            thr_par = thrStruct(k).thrParams;
            if ~isempty(thr_par)
                NB_int = size(thr_par,1);
                x      = [thr_par(:,1) ; thr_par(NB_int,2)];
                x      = round(x);
                x(x<1) = 1;
                x(x>len) = len;
                thr = thr_par(:,3);
                for j = 1:NB_int
                    if j==1 , d_beg = 0; else , d_beg = 1; end
                    j_beg = x(j)+d_beg;
                    j_end = x(j+1);
                    j_ind = [j_beg:j_end];
                    cfs(k,j_ind) = wthresh(cfs(k,j_ind),sorh,thr(j));
                end
            end
        end
        varargout{1} = cfs;

    case 'den_M2'
        coefs = varargin{1};
        longs = varargin{2};
        len   = longs(end);
        first = cumsum(longs)+1;
        first = first(end-2:-1:1);
        tmp   = longs(end-1:-1:2);
        last  = first+tmp-1;
        longs = longs(end-1:-1:2);
        thrStruct = utthrw1d('get',fig,'thrstruct');
        switch toolOPT
          case {'deno','esti','esti_REG','esti_DEN'}
            v = get(rad_sof,'Value');
            if v==1 , sorh = 's'; else , sorh = 'h'; end

          case {'comp'} , sorh = 'h';
        end
        NB_lev  = size(thrStruct,1);        
        for k = 1:NB_lev
            thr_par = thrStruct(k).thrParams;
            if ~isempty(thr_par)
                cfs = coefs(first(k):last(k));
                nbCFS = longs(k);            
                NB_int = size(thr_par,1);
                x   = [thr_par(:,1) ; thr_par(NB_int,2)];
                alf = (nbCFS-1)/(x(end)-x(1));
                bet = 1 - alf*x(1);
                x   = round(alf*x+bet);
                x(x<1) = 1;
                x(x>nbCFS) = nbCFS;
                thr = thr_par(:,3);
                for j = 1:NB_int
                    if j==1 , d_beg = 0; else , d_beg = 1; end
                    j_beg = x(j)+d_beg;
                    j_end = x(j+1);
                    j_ind = [j_beg:j_end];
                    cfs(j_ind) = wthresh(cfs(j_ind),sorh,thr(j));
                end
                coefs(first(k):last(k)) = cfs;
            end
        end
        varargout{1} = coefs;

    case 'demo'
    % SPECIAL for DEMOS
    %------------------
    [tool,parDemo] = deal(varargin{:});
    switch tool
       case {'sw1d','wdre'}
         if ischar(parDemo{1})
             shortnames = wthrmeth(toolOPT,'shortnames');
             ind = strmatch(deblank(parDemo{1}),shortnames);
             if isempty(ind) , return; end
             set(pop_met,'Value',ind)
             utthrw1d('update_methName',fig)

         elseif isnumeric(parDemo{1})
             utthrset('demo',tog_thr,parDemo{1})
         end
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
  case {'deno','esti','esti_REG'}
    thrMethods = {...
        'Fixed form threshold',  'sqtwolog',    1; ...
        'Rigorous SURE',         'rigrsure',    2; ...
        'Heuristic SURE',        'heursure',    3; ...
        'Minimax',               'minimaxi',    4; ...
        'Penalize high',         'penalhi',     5; ...
        'Penalize medium',       'penalme',     6; ...
        'Penalize low',          'penallo',     7  ...
        };

  case {'esti_DEN'}
    thrMethods = {...
        'Global threshold',      'globalth',    1; ...
        'By level threshold 1',  'bylevth1',    2; ...
        'By level threshold 2',  'bylevth2',    3; ...
        'By level threshold 3',  'bylevsth',    4  ...
        };

  case 'comp'
    thrMethods = {...
        'Scarce high',           'scarcehi',     1; ...
        'Scarce medium',         'scarceme',     2; ...
        'Scarce low',            'scarcelo',     3; ...
        'Balance sparsity-norm', 'bal_sn',       4; ...
        'Remove near 0',         'rem_n0',       5  ...
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
function [pos_fra,dy_lev,y_thr,y_res,y_est] = getPosFraThr(fra,nblevs,toolOPT)

Def_Btn_Height = mextglob('get','Def_Btn_Height');
[bdy,d_lev] = get_DLEV(nblevs,toolOPT);
pos_fra = get(fra,'Position');
top_fra = pos_fra(2)+pos_fra(4);
if ~isequal(toolOPT,'esti_DEN') , multiY = 1; else , multiY = 1; end
switch  toolOPT
  case {'deno','esti'} , NB_Height = 6;
  case {'esti_REG'}    , NB_Height = 6;
  case {'esti_DEN'}    , NB_Height = 4+2*multiY;  
  case {'comp'}        , NB_Height = 7;
end
h_ini   = (NB_Height-1)*bdy+NB_Height*Def_Btn_Height;
h_fra   = h_ini+ nblevs*(Def_Btn_Height+d_lev)+ ...
          depOfMachine(Def_Btn_Height);
pos_fra(2) = top_fra-h_fra;
pos_fra(4) = h_fra;
dy_lev = d_lev+Def_Btn_Height;
y_thr  = pos_fra(2)+bdy;
y_est = pos_fra(2)-(3*Def_Btn_Height)/2-Def_Btn_Height/2;
y_res = y_est;
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
function s = sprintfLOC(frm,x);

s = sprintf(frm,x);
s(s==' ') = [];
%-----------------------------------------------------------------------------%
function [bdy,d_lev] = get_DLEV(nblevs,toolOPT)

if isequal(toolOPT,'comp') && (nblevs>10)
    bdy = 2; d_lev = 0;    
else
    bdy = 4; d_lev = 2;
end
%=============================================================================%
