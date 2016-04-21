function varargout = utnbcfs(option,fig,varargin)
%UTNBCFS Utilities for Coefficients Selection 1-D and 2-D tool.
%   VARARGOUT = UTNBCFS(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Jun-98.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/03/15 22:42:07 $

% Default values.
%----------------
max_lev_anal = 9;
def_lev_anal = 5;

% Tag property of objects.
%-------------------------
tag_fra_tool = ['Fra_CFS_Tool'];

switch option
  case {'create','apply','select','unselect'}

  otherwise
    % Memory Blocs of stored values.
    %===============================
    % MB0.
    %-----
    n_membloc0 = 'MB0';
    ind_sig    = 1;
    ind_coefs  = 2;
    ind_longs  = 3;
    ind_first  = 4;
    ind_last   = 5;
    ind_sort   = 6;
    ind_By_Lev = 7;
    ind_sizes  = 8;   % 2D Only
    nb0_stored = 8;

    if ~ishandle(fig) , varargout{1} = []; return; end
    uic = findobj(get(fig,'Children'),'flat','type','uicontrol');
    fra = findobj(uic,'style','frame','tag',tag_fra_tool);
    if isempty(fra) , return; end
    ud  = get(fra,'Userdata');
    toolOPT = ud.toolOPT;
    handlesUIC = ud.handlesUIC;
    h_CMD_SIG  = ud.h_CMD_SIG;
    h_CMD_APP  = ud.h_CMD_APP;
    h_CMD_LVL  = ud.h_CMD_LVL;
    if isequal(option,'handles')
        handles = [handlesUIC(:);h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:)];
        varargout{1} = handles(ishandle(handles));
        return;
    end
    Hdls_toolPos = utanapar('handles',fig,'all');
    ind          = 2;
    txt_top      = handlesUIC(ind); ind = ind+1;
    pop_met      = handlesUIC(ind); ind = ind+1;
    txt_app      = handlesUIC(ind); ind = ind+1;
    pop_app      = handlesUIC(ind); ind = ind+1;
    txt_cfs      = handlesUIC(ind); ind = ind+1;
    txt_tit(1:4) = handlesUIC(ind:ind+3); ind = ind+4;
    tog_res      = handlesUIC(ind); ind = ind+1;
    pus_act      = handlesUIC(ind); ind = ind+1;

    % Get stored structure.
    %----------------------
    Hdls_Sel = wfigmngr('getValue',fig,'Hdls_Sel');
    Hdls_Mov = wfigmngr('getValue',fig,'Hdls_Mov');
 
    % Get UIC Handles.
    %-----------------
    pus_sel = Hdls_Sel.pus_sel;
    pus_uns = Hdls_Sel.pus_uns;
    [fra_mov,txt_mov,txt_app,pop_app,...
     txt_min_mov,edi_min_mov,txt_stp_mov,edi_stp_mov, ...
     txt_max_mov,edi_max_mov,...
     chk_mov_aut,pus_mov_sta,pus_mov_sto,pus_mov_can] = deal(Hdls_Mov{:});

    switch option
      case {'clean','enable','Init_Movie','Mngr_Movie'}
        toolATTR = wfigmngr('getValue',fig,'ToolATTR');
        hdl_UIC  = toolATTR.hdl_UIC;
        pus_ana  = hdl_UIC.pus_ana;
        switch toolOPT
          case 'cf1d' , chk_sho = hdl_UIC.chk_sho;
          case 'cf2d' , chk_sho = [];
        end

      otherwise
    end
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
    ydir   = -1;
    levmin = 1;
    levmax = def_lev_anal;
    levmaxMAX = max_lev_anal;
    visVal  = 'On';
    enaVal  = 'Off';
    toolOPT = 'cf1d';

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
          case 'ydir'     , ydir      = varargin{k+1};
          case 'levmin'   , levmin    = varargin{k+1};
          case 'levmax'   , levmax    = varargin{k+1};
          case 'levmaxMAX', levmaxMAX = varargin{k+1};
          case 'toolopt'  , toolOPT   = varargin{k+1};
        end
    end

    % Structure initialization.
    %--------------------------
    h_CMD_SIG = NaN*ones(4,1);
    h_CMD_APP = NaN*ones(4,1);
    h_CMD_LVL = NaN*ones(4,levmaxMAX);
    ud = struct(...
            'toolOPT',toolOPT, ...
            'levmin',levmin, ...
            'levmax',levmax, ...
            'levmaxMAX',levmaxMAX, ...
            'visible',lower(visVal),...
            'ydir', ydir,    ...
            'handlesUIC',[], ...
            'h_CMD_SIG',h_CMD_SIG, ...
            'h_CMD_APP',h_CMD_APP, ...
            'h_CMD_LVL',h_CMD_LVL, ...
            'handleORI' ,[], ...
            'handleTHR',[], ...
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
    dx = X_Spacing; bdx = 3; dx2 = 2*dx;
    dy = Y_Spacing; bdy = 4; dy2 = 2*dy;
    d_txt  = (Def_Btn_Height-Def_Txt_Height);
    deltaY = (Def_Btn_Height+dy);
    d_lev  = 2;
    sli_hi = Def_Btn_Height*sliYProp;
    sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);

    % Setting frame position.
    %------------------------
    NB_Height = 6;
    w_fra   = wfigmngr('get',fig,'fra_width');
    h_fra   = (levmaxMAX+NB_Height)*Def_Btn_Height+...
               levmaxMAX*d_lev+ ...
               depOfMachine(Def_Btn_Height)+(NB_Height-1)*bdy;
    x_fra   = utposfra(xleft,xright,xloc,w_fra);
    y_fra   = utposfra(ybottom,ytop,yloc,h_fra);
    pos_fra = [x_fra,y_fra,w_fra,h_fra];

    % String properties.
    %-------------------
    str_txt_top = 'Define Selection method';
    str_txt_tit = strvcat(' ','Initial','  ','Kept');
    str_tog_res = 'Residuals';
    str_pop_met = strvcat('Global','By Level', ...
                          'Manual','Stepwise Movie');
    if isequal(toolOPT,'cf2d') , str_pop_met(3,:) = []; end
    str_txt_app = 'App. cfs';
    str_pop_app = strvcat('Select All','Selectable','Unselect');

    str_pus_sel = 'Select';
    str_pus_uns = 'Unselect';
    str_txt_cfs = 'Selected Biggest Coefficients';
    str_pus_act = 'Apply';
 
    str_txt_mov     = 'Set Stepwise Movie Parameters';
    str_txt_min_mov = 'Min. ( > 0 )';
    str_edi_min_mov = '';
    str_txt_stp_mov = 'Step ( > 0 )';
    str_edi_stp_mov = '';
    str_txt_max_mov = 'Max.';
    str_edi_max_mov = '';
    str_chk_mov_aut = 'AutoPlay';
    str_pus_mov_sta = 'Start';
    str_pus_mov_sto = 'Stop';
    str_pus_mov_can = 'Quit Movie';

    % Position properties.
    %---------------------
    txt_width   = Def_Btn_Width;
    edi_width   = 3*Def_Btn_Width/4;
    dy_lev      = Def_Btn_Height+d_lev;
    xleft       = x_fra+bdx;
    w_rem       = w_fra-2*bdx;
    ylow        = y_fra+h_fra-Def_Btn_Height-bdy;

    w_uic       = (5*txt_width)/2;
    x_uic       = xleft+(w_rem-w_uic)/2;
    y_uic       = ylow;
    pos_txt_top = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

    w_uic       = (7*w_fra)/12;
    x_uic       = x_fra+(w_fra-w_uic)/2;
    y_uic       = y_uic-Def_Btn_Height;
    pos_pop_met = [x_uic, y_uic, w_uic, Def_Btn_Height];

    y_uic       = y_uic-Def_Btn_Height-bdy;
    w_txt       = w_fra/4;
    w_uic       = w_fra/2;
    x_uic       = x_fra+(w_fra-w_uic-w_txt)/2;
    pos_txt_app = [x_uic, y_uic+d_txt/2, w_txt, Def_Txt_Height];        
    x_uic       = x_uic+w_txt;
    pos_pop_app = [x_uic, y_uic, w_uic, Def_Btn_Height];        

    w_uic       = ((2*w_fra)/3-2*bdx)/2;
    x_uic       = x_fra+(w_fra-(2*w_fra)/3)/2;    
    pos_pus_sel = [x_uic, y_uic, w_uic, Def_Btn_Height];
    x_uic       = x_uic+w_uic+2*bdx;
    pos_pus_uns = [x_uic, y_uic, w_uic, Def_Btn_Height];

    y_uic       = y_uic-Def_Btn_Height-bdy;
    w_uic       = (5*txt_width)/2;
    x_uic       = xleft+(w_rem-w_uic)/2;
    pos_txt_cfs = [x_uic, y_uic, w_uic, Def_Txt_Height];

    wx          = 2;
    wbase       = 2*(w_rem-5*wx)/5;
    w_lev       = [4*wbase ; 7*wbase ; 12*wbase ; 7*wbase]/12;
    x_uic       = xleft+wx;
    y_uic       = y_uic-Def_Btn_Height;
    pos_lev_tit = [x_uic, y_uic, w_lev(1), Def_Txt_Height];
    pos_lev_tit = pos_lev_tit(ones(1,4),:);
    pos_lev_tit(:,3) = w_lev;
    for k=1:3 , pos_lev_tit(k+1,1) = pos_lev_tit(k,1)+pos_lev_tit(k,3); end
    y_uic       = pos_lev_tit(1,2)-levmaxMAX*(Def_Btn_Height+d_lev);

    w_uic       = w_fra/2-bdx;
    x_uic       = pos_fra(1);
    h_uic       = (3*Def_Btn_Height)/2;
    y_uic       = pos_fra(2)-h_uic-Def_Btn_Height/2;
    pos_pus_act = [x_uic, y_uic, w_uic, h_uic];
    x_uic       = x_uic+w_uic+2*bdx;
    pos_tog_res = [x_uic, y_uic, w_uic, h_uic];

    d_h_mov     = 3*Def_Btn_Height/4;
    h_txt       = Def_Txt_Height;
    h_uic       = Def_Btn_Height;
    y_fra_top   = pos_pop_app(2)+pos_pop_app(4)+h_txt+d_h_mov;
    w_uic       = (5*txt_width)/2;
    x_uic       = x_fra+(w_fra-w_uic)/2;
    y_uic       = y_fra_top-h_txt-dy2;
    pos_txt_mov = [x_uic, y_uic+d_txt/2, w_uic, h_txt];

    y_uic       = pos_pop_app(2)-d_h_mov-h_uic;
    x_uic_1     = x_fra+dx2;
    x_uic_2     = x_fra+w_fra/2+dx;
    w_uic_1     = txt_width;
    w_uic_2     = w_fra/2-3*dx2/2;

    pos_txt_min_mov = [x_uic_1, y_uic+d_txt/2, w_uic_1, h_txt];
    pos_edi_min_mov = [x_uic_2, y_uic, w_uic_2, h_uic];
    y_uic           = y_uic-(h_uic+d_h_mov/2);
    pos_txt_stp_mov = [x_uic_1, y_uic+d_txt/2, w_uic_1, h_txt];
    pos_edi_stp_mov = [x_uic_2, y_uic, w_uic_2, h_uic];
    y_uic           = y_uic-(h_uic+d_h_mov/2);
    pos_txt_max_mov = [x_uic_1, y_uic+d_txt/2, w_uic_1, h_txt];
    pos_edi_max_mov = [x_uic_2, y_uic, w_uic_2, h_uic];

    w_bas           = (w_fra-6*bdx)/12;
    w_uic           = 5*w_bas;
    x_uic           = x_fra+2*bdx;    
    h_uic           = 1.5*Def_Btn_Height;
    y_uic           = y_uic-h_uic-d_h_mov;    
    pos_chk_mov_aut = [x_uic, y_uic, w_uic, h_uic];

    x_uic           = x_uic+w_uic+bdx;
    w_uic           = 3.5*w_bas;
    pos_pus_mov_sta = [x_uic, y_uic, w_uic, h_uic];

    x_uic           = x_uic+w_uic+bdx;
    pos_pus_mov_sto = [x_uic, y_uic, w_uic, h_uic];

    y_uic           = y_uic-h_uic-2*bdy;    
    w_uic           = w_fra/2;
    x_uic           = x_fra+(w_fra-w_fra/2)/2;    
    pos_pus_mov_can = [x_uic, y_uic, w_uic, h_uic];

    y_fra_mov       = y_uic-2*bdy;
    h_fra_mov       = y_fra_top-y_fra_mov;
    pos_fra_mov     = [x_fra,y_fra_mov,w_fra,h_fra_mov];

    % Create UIC.
    %------------
    commonProp = {...
                  'Parent',fig,     ...
                  'Unit',fig_units  ...
                  'Visible','Off'   ...
                  };
    comTxtProp = {commonProp{:}, ...
                  'Style','Text',                 ...
                  'HorizontalAlignment','center', ...
                  'Backgroundcolor',bkColor       ...
                  };
    comEdiProp = {commonProp{:},                             ...
                           'ForeGroundColor','k',            ...
                           'HorizontalAlignment','center',   ...
                           'Style','Edit'                    ...
                           };
    comFraProp = {commonProp{:},                             ...
                           'BackGroundColor',Def_FraBkColor, ...
                           'Style','frame'                   ...
                           };
    comPusProp = {commonProp{:},'Style','Pushbutton'};
    comPopProp = {commonProp{:},'Style','Popupmenu'};
    comChkProp = {commonProp{:},'Style','CheckBox'};

    fra_utl = uicontrol(comFraProp{:},      ...
                        'Style','frame',    ...
                        'Position',pos_fra, ...
                        'Tag',tag_fra_tool  ...
                        );

    fra_mov = uicontrol(comFraProp{:},          ...
                        'Style','frame',        ...
                        'Position',pos_fra_mov  ...
                        );

    txt_top = uicontrol(comTxtProp{:},          ...
                        'Position',pos_txt_top, ...
                        'String',str_txt_top    ...
                        );
    cba     = [mfilename '(''update_methode'',' str_numfig ');'];
    pop_met = uicontrol(comPopProp{:},                  ...
                        'Position',pos_pop_met,         ...
                        'String',str_pop_met,           ...
                        'HorizontalAlignment','center', ...
                        'Enable',enaVal,                ...
                        'Userdata',0,                   ...
                        'Callback',cba                  ...
                        );

    txt_app = uicontrol(comTxtProp{:},          ...
                        'Position',pos_txt_app, ...
                        'HorizontalAlignment','left', ...
                        'String',str_txt_app    ...
                        );
    pop_app = uicontrol(comPopProp{:},                  ...
                        'Position',pos_pop_app,         ...
                        'HorizontalAlignment','center', ...
                        'String',str_pop_app,           ...
                        'Enable',enaVal,               ...
                        'Value',1,'Userdata',0          ...
                        );

    cba = [mfilename '(''update_AppFlag'',' str_numfig ');'];
    set(pop_app,'Callback',cba);

    tip     = 'Select using a select Box';
    cba     = [mfilename '(''select'',' str_numfig ');'];
    pus_sel = uicontrol(comPusProp{:},          ...
                        'Position',pos_pus_sel, ...
                        'String',xlate(str_pus_sel),   ...
                        'Visible','Off',        ...
                        'Tooltip',tip,          ...
                        'callback',cba          ...
                        );

    tip     = 'Unselect using a select Box';
    cba     = [mfilename '(''unselect'',' str_numfig ');'];
    pus_uns = uicontrol(comPusProp{:},          ...
                        'Position',pos_pus_uns, ...
                        'String',xlate(str_pus_uns),   ...
                        'Tooltip',tip,          ...
                        'Visible','Off',        ...
                        'callback',cba          ...
                        );
    txt_cfs = uicontrol(comTxtProp{:},          ...
                        'Position',pos_txt_cfs, ...
                        'String',str_txt_cfs    ...
                        );

    txt_tit = zeros(4,1);
    for k=1:4
        txt_tit(k) = uicontrol(...
                               comTxtProp{:},                     ...
                               'Position',pos_lev_tit(k,:),       ...
                               'String',deblank(str_txt_tit(k,:)) ...
                               );
    end

    xbtn0 = xleft;
    ybtn0 = pos_lev_tit(1,2)-Def_Btn_Height;
    xbtn  = xbtn0;
    ybtn  = ybtn0;
    if ud.ydir==1
        index = [1:levmaxMAX,-levmax,0];
    else
        index = [-levmax,levmaxMAX:-1:1,0];
        ybtn  = ybtn0+(levmaxMAX-levmax)*dy_lev;
    end
    for j=1:length(index)
        i = index(j);
        pos_lev = [xbtn ybtn+d_txt/2 w_lev(1) Def_Txt_Height];
        switch i
          case 0
            str_lev = sprintf('S');
            col = wtbutils('colors','sig');
          case -levmax
            str_lev = sprintf('A%.0f',-i);
            col = wtbutils('colors','app','text');
          otherwise
            str_lev = sprintf('D%.0f',i);
            col = wtbutils('colors','det','text');
        end
        uicProp = {commonProp{:}, ...
          'Enable','inactive','Backgroundcolor',bkColor,'Userdata',i};
        txt_lev = uicontrol(...
                     comTxtProp{:},     ...
                     'Position',pos_lev,...
                     'String',str_lev,  ...
                     'ForeGroundColor',col, ...
                     'Userdata',i       ...
                     );
        xbtn      = xbtn+w_lev(1)+wx;
        pos_lev = [xbtn ybtn w_lev(2) Def_Btn_Height];
        edi_ini = uicontrol(...
                     uicProp{:}, ...
                     'Style','Edit',...
                     'Position',pos_lev,...
                     'String','' ...
                     );

        xbtn    = xbtn+w_lev(2)+wx;
        pos_lev = [xbtn, ybtn+sli_dy, w_lev(3), sli_hi];
        sli_lev = uicontrol(...
                     uicProp{:},         ...
                     'Style','Slider',   ...
                     'Position',pos_lev, ...
                     'Min',0,'Max',2,'Value',1 ...
                     );

        xbtn    = xbtn+w_lev(3)+wx;
        pos_lev = [xbtn ybtn w_lev(4) Def_Btn_Height];
        str_val = sprintf('%1.4g',1);
        edi_lev = uicontrol(...
                     uicProp{:},         ...
                     'Style','Edit',     ...
                     'Position',pos_lev, ...
                     'String','',        ...
                     'HorizontalAlignment','center'...
                     );

        strHdl  = num2mstr([edi_ini,sli_lev,edi_lev]);
        beg_cba = [mfilename '(''update_by_UIC'',' str_numfig ...
                   ',' strHdl];
        cba_sli = [beg_cba ',''sli'');'];
        cba_edi = [beg_cba ',''edi'');'];
        set(sli_lev,'Callback',cba_sli);
        set(edi_lev,'Callback',cba_edi);
        switch i
          case 0
            h_CMD_SIG = [txt_lev;edi_ini;sli_lev;edi_lev];
            set(edi_lev,'Backgroundcolor',Def_EdiBkColor);
          case -levmax
            h_CMD_APP = [txt_lev;edi_ini;sli_lev;edi_lev];
          otherwise
            h_CMD_LVL(:,i) = [txt_lev;edi_ini;sli_lev;edi_lev];
        end
        xbtn = xbtn0;
        ybtn = ybtn-dy_lev;
    end

    cba     = [mfilename '(''residuals'',' str_numfig ');'];
    tip     = 'More on Residuals';
    tog_res = uicontrol(...
                        commonProp{:},          ...
                        'Style','Togglebutton', ...
                        'Position',pos_tog_res, ...
                        'String',str_tog_res,   ...
                        'Enable','off',         ...
                        'Callback',cba,         ...
                        'tooltip',tip,          ...
                        'Interruptible','Off'   ...
                        );

    cba     = [mfilename '(''apply'',' str_numfig ');'];
    pus_act = uicontrol(comPusProp{:},          ...
                        'Position',pos_pus_act, ...
                        'String',xlate(str_pus_act),   ...
                        'Enable',enaVal,        ...
                        'callback',cba          ...
                        );

    txt_mov = uicontrol(comTxtProp{:},          ...
                        'Position',pos_txt_mov, ...
                        'String',str_txt_mov,   ...
                        'Visible','Off'         ...
                        );

    txt_min_mov = uicontrol(comTxtProp{:},               ...
                            'Position',pos_txt_min_mov,  ...
                            'HorizontalAlignment','left',...
                            'String',str_txt_min_mov,    ...
                            'Visible','Off'              ...
                            );

    cba = [mfilename '(''update_Edi_Movie'',' str_numfig ',''Min'');'];
    edi_min_mov = uicontrol(comEdiProp{:},                   ...
                            'Position',pos_edi_min_mov,      ...
                            'String',str_edi_min_mov,        ...
                            'Callback',cba,                  ...
                            'Backgroundcolor',Def_EdiBkColor,...
                            'Visible','Off'                  ...
                            );
    txt_stp_mov = uicontrol(comTxtProp{:},                   ...
                            'Position',pos_txt_stp_mov,      ...
                            'HorizontalAlignment','left',    ...
                            'String',str_txt_stp_mov,        ...
                            'Visible','Off'                  ...
                            );
    cba = [mfilename '(''update_Edi_Movie'',' str_numfig ',''Stp'');'];
    edi_stp_mov = uicontrol(comEdiProp{:},                    ...
                            'Position',pos_edi_stp_mov,       ...
                            'String',str_edi_stp_mov,         ...
                            'Callback',cba,                   ...
                            'Backgroundcolor',Def_EdiBkColor, ...
                            'Visible','Off'                   ...
                            );
    txt_max_mov = uicontrol(comTxtProp{:},                ...
                            'Position',pos_txt_max_mov,   ...
                            'HorizontalAlignment','left', ...
                            'String',str_txt_max_mov,     ...
                            'Visible','Off'               ...
                            );

    cba = [mfilename '(''update_Edi_Movie'',' str_numfig ',''Max'');'];
    edi_max_mov = uicontrol(comEdiProp{:},                    ...
                            'Position',pos_edi_max_mov,       ...
                            'String',str_edi_max_mov,         ...
                            'Callback',cba,                   ...
                            'Backgroundcolor',Def_EdiBkColor, ...
                            'Visible','Off'                   ...
                            );

    cba = [mfilename '(''Mngr_Movie'',' str_numfig ');'];
    chk_mov_aut = uicontrol(comChkProp{:},              ...
                            'Position',pos_chk_mov_aut, ...
                            'String',str_chk_mov_aut,   ...
                            'Value',1,                  ...
                            'callback',cba,             ...
                            'Visible','Off'             ...
                            );

    cba = [mfilename '(''Mngr_Movie'',' str_numfig ');'];
    pus_mov_sta = uicontrol(comPusProp{:},              ...
                            'Position',pos_pus_mov_sta, ...
                            'String',xlate(str_pus_mov_sta),   ...
                            'callback',cba,             ...
                            'Visible','Off'             ...
                            );

    cba = [mfilename '(''Mngr_Movie'',' str_numfig ');'];
    pus_mov_sto = uicontrol(comPusProp{:},              ...
                            'Position',pos_pus_mov_sto, ...
                            'String',xlate(str_pus_mov_sto),   ...
                            'callback',cba,             ...
                            'Enable','Off',             ...
                            'Visible','Off'             ...
                            );

    cba = [mfilename '(''Mngr_Movie'',' str_numfig ');'];
    pus_mov_can = uicontrol(comPusProp{:},              ...
                            'Position',pos_pus_mov_can, ...
                            'String',xlate(str_pus_mov_can),   ...
                            'callback',cba,             ...
                            'Visible','Off'             ...
                            );
    ud.handlesUIC = [...
                     fra_utl;txt_top;pop_met;      ...
                     txt_app;pop_app;txt_cfs;txt_tit(1:4); ...
                     tog_res;pus_act;              ...
                     ];

    ud.h_CMD_SIG = h_CMD_SIG;
    ud.h_CMD_APP = h_CMD_APP;
    ud.h_CMD_LVL = h_CMD_LVL;
    set(fra_utl,'Userdata',ud);

    % Store values.
    %--------------
    Hdls_Sel = struct(...
                      'pus_sel', pus_sel, ...
                      'pus_uns', pus_uns, ...
                      'pop_met', pop_met  ...
                      );
    Hdls_Mov = {...
                fra_mov,txt_mov,txt_app,pop_app, ...
                txt_min_mov,edi_min_mov, ...
                txt_stp_mov,edi_stp_mov, ...
                txt_max_mov,edi_max_mov, ...
                chk_mov_aut,pus_mov_sta,pus_mov_sto,pus_mov_can ...
                 };
    wfigmngr('storeValue',fig,'Hdls_Sel',Hdls_Sel);
    wfigmngr('storeValue',fig,'Hdls_Mov',Hdls_Mov);

	% Add Context Sensitive Help (CSHelp).
	%-------------------------------------
	hdl_CSHelp  = [...
		fra_utl,txt_top,pop_met,      				...
		txt_app,pop_app,txt_cfs,txt_tit(:)', 		...
		h_CMD_SIG(:)',h_CMD_APP(:)',h_CMD_LVL(:)', 	...
		pus_sel,pus_uns,							...
		cat(2,Hdls_Mov{:}) 							...
		];
	switch toolOPT
		case 'cf1d' , helpName = 'CF1D_GUI';
		case 'cf2d' , helpName = 'CF2D_GUI';
	end
    wfighelp('add_ContextMenu',fig,hdl_CSHelp,helpName);		
	%-------------------------------------
	
    varargout{1} = utnbcfs('set',fig,'position',{levmin,levmax});

  case 'visible'
    visVal     = lower(varargin{1});
    ud.visible = visVal;
    if isequal(visVal,'on')
        h_CMD_LVL = h_CMD_LVL(1:4,ud.levmin:ud.levmax);
    end
    handles = [h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:);handlesUIC(:)];
    set(handles(ishandle(handles)),'visible',visVal);

  case 'clean'
    nameMeth = utnbcfs('get',fig,'nameMeth');
    switch nameMeth
      case 'Stepwise' , utnbcfs('Mngr_Movie',fig,pus_mov_can);
      case {'ByLevel','Manual'}   , utnbcfs('update_methode',fig,'clean');
    end
    dum1 = h_CMD_SIG([2,4],:);
    dum2 = h_CMD_APP([2,4],:);
    dum3 = h_CMD_LVL([2,4],:);
    dummy = [dum1(:);dum2(:);dum3(:)];
    set(dummy,'String','');
    dummy = [h_CMD_SIG(3,:),h_CMD_APP(3,:),h_CMD_LVL(3,:)];
    set(dummy,'Min',0,'Value',1,'Max',2);
    h_CMD_SIG = h_CMD_SIG(3:4,:);
    h_CMD_APP = h_CMD_APP(3:4,:);
    h_CMD_LVL = h_CMD_LVL(3:4,:);
    uic = [pop_met;pop_app;pus_act;tog_res;chk_sho; ...
           h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:)];
    set(uic,'Enable','Off');
    vis_ON  = [txt_app,pop_app];
    vis_OFF = [pus_sel,pus_uns];
    set(vis_ON,'Visible','On')
    set(vis_OFF,'Visible','Off')

  case 'enable'
    mode   = varargin{1};
    switch mode      
      case 'anal'
        uic = [pop_met;pop_app;pus_act;tog_res;chk_sho];
        set(uic','Enable','On');
    end

   case 'get'
    nbarg = length(varargin);
    if nbarg<1 , return; end
    for k = 1:nbarg
       outType = lower(varargin{k});
       switch outType
           case 'position'
             pos_fra = get(fra,'Position');
             pos_est = get(pus_act,'Position');
             varargout{k} = [pos_fra(1) , pos_est(2) , pos_fra([3 4])];

           case 'nbori'
             hdl = [h_CMD_APP(2),...
                    h_CMD_LVL(2,ud.levmax:-1:ud.levmin),h_CMD_SIG(2)];
             val = get(hdl,'Value');
             varargout{k} = cat(2,val{:});

           case 'nbkept'
             hdl = [h_CMD_APP(3),...
                    h_CMD_LVL(3,ud.levmax:-1:ud.levmin),h_CMD_SIG(3)];
             val = get(hdl,'Value');
             varargout{k} = round(cat(2,val{:}));

           case 'namemeth'
             tmp = get(pop_met,{'Value','String'});
             ini = tmp{2}(tmp{1},1);
             switch ini
               case 'G' , varargout{k} = 'Global';
               case 'B' , varargout{k} = 'ByLevel';
               case 'M' , varargout{k} = 'Manual';
               case 'S' , varargout{k} = 'Stepwise';
             end

           case 'nummeth'   , varargout{k} = get(pop_met,'Value');
           case 'appflag'   , varargout{k} = get(pop_app,'Value');
           case 'tog_res'   , varargout{k} = tog_res;
           case 'pus_act'   , varargout{k} = pus_act;
           case 'handleori' , varargout{k} = ud.handleORI;
           case 'handlethr' , varargout{k} = ud.handleTHR;
           case 'handleres' , varargout{k} = ud.handleRES;
       end
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
             tmpHandles = [h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:); ...
                           handlesUIC(:)];
             tmpHandles = tmpHandles(ishandle(tmpHandles));
             set(tmpHandles,'visible','off');
             set([fig;tmpHandles],'units','pixels');
             [pos_fra,dy_lev,y_res,y_est] = getPosFraThr(fra,nblevs,toolOPT);
             set(fra,'Position',pos_fra);
             ytrans = dnum_lev*dy_lev;
             for j=1:size(h_CMD_LVL,2)
                 for k = 1:4
                     p = get(h_CMD_LVL(k,j),'Position');
                     set(h_CMD_LVL(k,j),'Position',[p(1),p(2)+ytrans, ...
                         p(3:4)]);
                 end
             end
             ydir = ud.ydir;
             pbase = get(h_CMD_LVL(1,levmax),'Position');
             y = pbase(2)-ydir*dy_lev;
             p = get(h_CMD_APP(1,1),'Position');
             ytrans = y-p(2);
             for k = 1:4
                 p = get(h_CMD_APP(k,1),'Position');
                 set(h_CMD_APP(k,1),'Position',[p(1),p(2)+ytrans,p(3:4)]);
             end
             set(h_CMD_APP(1,1),'String',sprintf('A%.0f',levmax));

             if ydir==1
                pbase = get(h_CMD_APP(1,1),'Position');
             else
                pbase = get(h_CMD_LVL(1,1),'Position');
             end
             y = pbase(2)-dy_lev;
             p = get(h_CMD_SIG(1,1),'Position');
             ytrans = y-p(2)-(dy_lev-p(4));
             for k = 1:4
                 p = get(h_CMD_SIG(k,1),'Position');
                 set(h_CMD_SIG(k,1),'Position',[p(1),p(2)+ytrans,p(3:4)]);
             end

             p = get(tog_res,'Position');
             ytrans = y_res-p(2);
             set(tog_res,'Position',[p(1),y_res,p(3:4)]);
             p = get(pus_act,'Position');
             set(pus_act,'Position',[p(1),y_est,p(3:4)]);
             set([fig;tmpHandles],'units',old_units);
             utnbcfs('visible',fig,ud.visible);
             if nargout>0
                 varargout{1} = [pos_fra(1) , y_est , pos_fra([3 4])];
             end

           case 'nbkept'
             hdl_sli = [h_CMD_APP(3),...
                        h_CMD_LVL(3,ud.levmax:-1:ud.levmin),h_CMD_SIG(3)];
             hdl_edi = [h_CMD_APP(4),...
                        h_CMD_LVL(4,ud.levmax:-1:ud.levmin),h_CMD_SIG(4)];
             for k=1:length(hdl_sli)
                 nbk = argVal(k);
                 set(hdl_sli(k),'Value',nbk);
                 set(hdl_edi(k),'Value',nbk,'String',sprintf('%.0f',nbk));
             end
 
           case 'handleori' , ud.handleORI = argVal; set(fra,'Userdata',ud);
           case 'handlethr' , ud.handleTHR = argVal; set(fra,'Userdata',ud);
           case 'handleres' , ud.handleRES = argVal; set(fra,'Userdata',ud);
       end
    end

  case 'update_NbCfs'
    typeUpd = varargin{1};
    switch typeUpd
       case 'clean'
          len = size(h_CMD_LVL,2);
          HDL = zeros(3,len+2);
          for j = 2:4
              HDL(j-1,:) = [h_CMD_APP(j,1),h_CMD_LVL(j,:),h_CMD_SIG(j,1)];
          end
          set(HDL([1 3],:),'Value',0,'String','');
          set(HDL(2,:),'Min',0,'Value',0,'Max',2);

       case 'anal'
          levels = [ud.levmax:-1:ud.levmin];
          longs = wmemtool('rmb',fig,n_membloc0,ind_longs);
          longs(end) = sum(longs(1:end-1));
          len = length(longs);
          HDL = zeros(3,len);
          for j = 2:4
              HDL(j-1,:) = ...
                [h_CMD_APP(j,1),h_CMD_LVL(j,levels),h_CMD_SIG(j,1)];
          end
          for k = 1:len
              nbk = longs(k);
              txt = sprintf('%.0f',nbk);
              set(HDL([1 3],k),'Value',nbk,'String',txt);
              set(HDL(2,k),'Min',0,'Value',nbk,'Max',nbk);
          end
    end

  case 'update_methode'
    resetFLAG = 0;
    if ~isempty(varargin)
        numMeth = 1; nameMeth = 'Global';
        set(pop_met,'value',numMeth);
        resetMODE = varargin{1};
        if isequal(resetMODE,'reset') , resetFLAG = 1; end
    else
        [numMeth,nameMeth] = utnbcfs('get',fig,'numMeth','nameMeth');
        user = get(pop_met,'Userdata');
        if isequal(user{1},numMeth) , return; end
        if isequal(user{2},'Manual') , resetFLAG = 1; end
    end    
    set(pop_met,'Userdata',{numMeth,nameMeth});
    set(txt_cfs,'String',xlate('Selected Biggest Coefficients'));

    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    if isequal(toolOPT,'cf1d')
        feval(calledFUN,'set_Stems_HDL',fig,'reset',nameMeth);
    end
 
    [Def_FraBkColor,Def_EdiBkColor] = ...
        mextglob('get','Def_FraBkColor','Def_EdiBkColor');
    switch nameMeth
      case 'Global'
        if resetFLAG
            set(pop_app,'Value',1);
            nbKept = utnbcfs('get',fig,'nbOri');
        end
        ena_INA = [h_CMD_APP(3:4)',h_CMD_LVL(3,:),h_CMD_LVL(4,:)];
        ena_ON  = [h_CMD_SIG(3:4)'];
        vis_ON  = [txt_app,pop_app];
        vis_OFF = [pus_sel,pus_uns];
        bkc_FRA = [h_CMD_APP(4),h_CMD_LVL(4,:)];
        bkc_EDI = [h_CMD_SIG(4)];

      case 'ByLevel'
        if resetFLAG
            set(pop_app,'Value',1);
            nbKept = utnbcfs('get',fig,'nbOri');
        end
        app_Val = get(pop_app,'Value');
        ena_INA = [h_CMD_SIG(3:4)'];
        ena_ON  = [h_CMD_LVL(3,:),h_CMD_LVL(4,:)];
        vis_ON  = [txt_app,pop_app];
        vis_OFF = [pus_sel,pus_uns];
        bkc_FRA = [h_CMD_SIG(4)];
        bkc_EDI = [h_CMD_LVL(4,:)];
        switch app_Val
          case {1,3}
            ena_INA = [ena_INA , h_CMD_APP(3:4)'];
            bkc_FRA = [bkc_FRA , h_CMD_APP(4)];
          case 2
            ena_ON  = [ena_ON ,h_CMD_APP(3:4)'];
            bkc_EDI = [bkc_EDI , h_CMD_APP(4)];
        end

      case 'Manual'
        set(txt_cfs,'String',xlate('Selected coefficients'));
        resetFLAG = 1;
        set(pop_app,'Value',2);
        nbKept = zeros(1,ud.levmax + 2);
        ena_INA = [h_CMD_APP(3:4)',h_CMD_LVL(3,:),h_CMD_LVL(4,:), ...
                   h_CMD_SIG(3:4)'];
        ena_ON  = [];
        vis_OFF = [txt_app,pop_app];
        vis_ON  = [pus_sel,pus_uns];
        bkc_FRA = [h_CMD_APP(4),h_CMD_LVL(4,:),h_CMD_SIG(4)];
        bkc_EDI = [];

      case {'Stepwise','StepWise'}
        utnbcfs('Init_Movie',fig);
    end

    switch nameMeth
      case {'Global','Manual','ByLevel'}
        set(bkc_FRA,'Backgroundcolor',Def_FraBkColor);
        set(bkc_EDI,'Backgroundcolor',Def_EdiBkColor);
        set(ena_ON, 'Enable','On');
        set(ena_INA,'Enable','Inactive');
        set(vis_OFF,'Visible','Off');
        set(vis_ON, 'Visible','On');
        if resetFLAG
            utnbcfs('update_AppFlag',fig,pop_app);
            utnbcfs('set',fig,'nbKept',nbKept);
            feval(calledFUN,'apply',fig);
        end

      case {'Stepwise','StepWise'}
    end

  case 'update_AppFlag'
    if length(varargin)>0 , uic = varargin{1}; else , uic = gcbo; end
    appFlag = get(uic,'Value');
    [nameMeth,nbOri] = utnbcfs('get',fig,'nameMeth','nbOri');

    switch nameMeth
      case {'Global','ByLevel','Manual'}
        if isequal(nameMeth,'ByLevel') && (appFlag==2)
            BkColor = mextglob('get','Def_EdiBkColor');
            ena_val = 'On';
        else
            BkColor = mextglob('get','Def_FraBkColor');
            ena_val = 'inactive';
        end
        set(h_CMD_APP(3:4),'Enable',ena_val);
        set(h_CMD_APP(4),'Backgroundcolor',BkColor);
        switch appFlag
          case {1,3}
            switch appFlag
              case 1 , App_Len = nbOri(1); maxVal = nbOri(end);
              case 3 , App_Len = 0;        maxVal = nbOri(end)-nbOri(1);
            end  
            set(h_CMD_APP(3),'Value',App_Len);
            set(h_CMD_SIG(3),'Min',App_Len,'Value',maxVal,'Max',maxVal)
            eval(get(h_CMD_APP(3),'Callback'));
          case 2
            maxVal = nbOri(end);
            set(h_CMD_SIG(3),'Min',0,'Max',maxVal)
        end

      case {'Stepwise'}
        %--------------------------%
        % Option: UPDATE_APP_MOVIE %
        %--------------------------%
        Nb_Coefs = nbOri(end);
        App_Len  = nbOri(1);
        Min_Val  = wstr2num(get(edi_min_mov,'String'));
        Max_Val  = wstr2num(get(edi_max_mov,'String'));
        switch appFlag
          case 1 , Min_Val = App_Len; Max_Val = Nb_Coefs;
          case 2 , Min_Val = 1;       Max_Val = Nb_Coefs;
          case 3 , Min_Val = 1;       Max_Val = Nb_Coefs-App_Len;
        end
        dif_Val = min([30,Max_Val-Min_Val,round(0.05*Nb_Coefs)]);
        def_Max_Val = Min_Val+dif_Val;
        set(edi_min_mov,'String',sprintf('%.0f',Min_Val));
        set(edi_max_mov,'String',sprintf('%.0f',def_Max_Val));
        set(txt_max_mov,'String',sprintf('Max < %.0f', Max_Val+1));
    end

  case 'update_by_UIC'
    strHdl = varargin{1};
    typHdl = varargin{2};
    edi_0 = strHdl(1);
    sli   = strHdl(2);
    edi   = strHdl(3);
    idx   = get(edi_0,'Userdata');
    [nameMeth,nbOri] = utnbcfs('get',fig,'nameMeth','nbOri');
    appFlag = get(pop_app,'Value');
    sliValues = get(sli,{'Min','Value','Max'});
    sliValues = round(cat(2,sliValues{:}));
    switch typHdl
      case 'sli' , nbcfs = sliValues(2);
      case 'edi'
        valstr = get(edi,'string');
        [nbcfs,count,err] = sscanf(valstr,'%f');
        if (count~=1) || ~isempty(err)
            nbcfs = sliValues(2);
            set(edi,'Value',nbcfs,'string',sprintf('%.0f',nbcfs));
            return;
        else
            if     nbcfs<sliValues(1) , nbcfs = sliValues(1);
            elseif nbcfs>sliValues(3) , nbcfs = sliValues(3);
            end
        end
    end 
    set(sli,'Value',nbcfs);
    set(edi,'Value',nbcfs,'string',sprintf('%.0f',nbcfs));

    switch nameMeth
      case 'Global'
        if idx>=0
            [first,last,idxsort,idxByLev] = ...
                 wmemtool('rmb',fig,n_membloc0, ...
                        ind_first,ind_last,...
                        ind_sort,ind_By_Lev);
            len = length(idxByLev);
            switch toolOPT
              case 'cf1d'
                nbKept = zeros(1,len+1);
                switch appFlag
                  case {1,3}
                    if appFlag==1 , nbKept(1) = nbOri(1); end
                    idxsort(idxByLev{1}) = [];
                    nbcfs = nbcfs-nbKept(1);
                    kBeg = 2;

                  case 2 , kBeg = 1;

                end
                idxsort = idxsort(end-nbcfs+1:end);
                for k=kBeg:len
                    idxByLev{k} = find((first(k)<=idxsort) & ...
                                       (idxsort<=last(k)));
                    nbKept(k) = length(idxByLev{k});
                end

              case 'cf2d'
                nbLev  = (len-1)/3;
                nbKept = zeros(1,2+nbLev);
                switch appFlag
                  case {1,3}
                    if appFlag==1 , nbKept(1) = nbOri(1); end
                    idxsort(idxByLev{1}) = [];
                    nbcfs = nbcfs-nbKept(1);
                    kBeg = 2;

                  case 2 , kBeg = 1;

                end
                idxsort  = idxsort(end-nbcfs+1:end);
                for k=kBeg:len
                    idxByLev{k} = find((first(k)<=idxsort) & ...
                                       (idxsort<=last(k)));
                end
                if appFlag==2 , nbKept(1) = length(idxByLev{1}); end
                iBeg = 2;
                for jj = 1:nbLev
                    iEnd = iBeg+2;
                    nbKept(jj+1) = length(cat(2,idxByLev{iBeg:iEnd}));
                    iBeg = iEnd+1;
                end
            end
        else   % For approximation case.
            nbKept = utnbcfs('get',fig,'nbKept');
        end
        nbKept(end) = sum(nbKept(1:end-1));
        utnbcfs('set',fig,'nbKept',nbKept);

      case 'ByLevel'
        nbKept = utnbcfs('get',fig,'nbKept');
        nbKept(end) = sum(nbKept(1:end-1));
        utnbcfs('set',fig,'nbKept',nbKept);

      case 'Manual'

      case 'Stepwise'

    end

  case 'residuals'
    [handleORI,handleTHR,handleRES] = ...
        utnbcfs('get',fig,'handleORI','handleTHR','handleRES');
    wmoreres('create',fig,tog_res,handleRES,handleORI,handleTHR,'blocPAR');

  case {'apply','select','unselect'}
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    feval(calledFUN,option,fig);
 
  case 'Init_Movie'
    %--------------------%
    % Option: INIT_MOVIE %
    %--------------------%
    pop_lev = utanapar('handles',fig,'lev');
    level   = get(pop_lev,'value');
    h_CMD_LVL = h_CMD_LVL(:,1:level);
    hdl_OFF = [...
              fra;txt_top;pop_met;txt_cfs;txt_tit(:); ...
              h_CMD_LVL(:);h_CMD_APP(:);h_CMD_SIG(:); ...
              pus_act;tog_res;pus_ana                 ...
              ];

    if ~isempty(chk_sho)
       pos_chk = get(chk_sho,'Position');
       pos_fra = get(fra_mov,'Position');
       pos_chk(2) = pos_fra(2)-1.5*pos_chk(4);
       set(chk_sho,'Position',pos_chk);
    end

    hdl_OFF = hdl_OFF(ishandle(hdl_OFF));
    set(pus_mov_can,'Userdata',hdl_OFF);
    set([hdl_OFF;pus_sel;pus_uns],'Visible','Off');
    set(Hdls_toolPos,'Enable','Inactive');
    set(cat(1,Hdls_Mov{:}),'visible','On');
    drawnow
    app_val = get(pop_app,'Value');
    longs   = wmemtool('rmb',fig,n_membloc0,ind_longs);
    Stp_Val = 1;
    Nb_Coefs = sum(longs(1:end-1));
    App_Len  = longs(1);
    switch app_val
      case 1 , Min_Val = App_Len; Max_Val = Nb_Coefs;
      case 2 , Min_Val = 1;       Max_Val = Nb_Coefs;
      case 3 , Min_Val = 1;       Max_Val = Nb_Coefs-App_Len;
    end
    dif_Val = min([30,Max_Val-Min_Val,round(0.05*Nb_Coefs)]);
    def_Max_Val = Min_Val+dif_Val;
    set(edi_stp_mov,'String',sprintf('%.0f',Stp_Val),'Userdata',Stp_Val);
    set(edi_min_mov,'String',sprintf('%.0f',Min_Val),'Userdata',Min_Val);
    set(edi_max_mov,'String',sprintf('%.0f',def_Max_Val),'Userdata',Max_Val);
    set(txt_max_mov,'String',sprintf('Max < %.0f', Max_Val+1));

    % Initialize plot.
    %-----------------
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    feval(calledFUN,'Apply_Movie',fig,[]);

  case 'Mngr_Movie'
    %--------------------%
    % Option: MNGR_MOVIE %
    %--------------------%
    if length(varargin)>0 , uic = varargin{1}; else , uic = gcbo; end
    hdl = [chk_mov_aut ; pus_mov_sta ; pus_mov_sto ; pus_mov_can];
    idx = find(uic==hdl);
    okAuto = get(chk_mov_aut,'Value');

    if (idx==2) || (idx==3 && ~okAuto)
        Min_Val = wstr2num(get(edi_min_mov,'String'));
        Stp_Val = wstr2num(get(edi_stp_mov,'String'));
        Max_Val = wstr2num(get(edi_max_mov,'String'));
        movieSET = [Min_Val:Stp_Val:Max_Val];
        nbInSet  = length(movieSET);
        App_Val = get(pop_app,'Value');
        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        setIDX = get(chk_mov_aut,'Userdata');
    end
   
    switch idx
      case 1    % Option: AUTOPLAY_MOVIE %
        if okAuto
           set(pus_mov_sta,'String',xlate('Start'),'Enable','On')
           set(pus_mov_sto,'String',xlate('Stop'),'Enable','Off','Userdata',[])
        else
           set(chk_mov_aut,'Userdata',0);
           set(pus_mov_sta,'String',xlate('<< Prev'),'Enable','Off')
           set(pus_mov_sto,'String',xlate('Next >>'),'Enable','On')
        end

      case 2    % Option: START_MOVIE or PREVIOUS %
        if okAuto
           set([chk_mov_aut,pus_mov_sta,pus_mov_can],'Enable','Off');
           set(pus_mov_sto,'Enable','On');
           feval(calledFUN,'Apply_Movie',fig,movieSET,App_Val,pus_mov_sto);
           set(pus_mov_sto,'Enable','Off');    
           set([chk_mov_aut,pus_mov_sta,pus_mov_can],'Enable','On');
        else
            setIDX = setIDX-1;
        end

      case 3    % Option: STOP_MOVIE or NEXT %
        if okAuto
           set(pus_mov_sto,'Userdata',1);
        else
            setIDX = setIDX+1;          
        end

      case 4    % Option: CANCEL_MOVIE %
        set(cat(1,Hdls_Mov{:}),'visible','Off');
        if ~okAuto
           set(chk_mov_aut,'Value',1,'Userdata',[])
           set(pus_mov_sta,'String',xlate('Start'),'Enable','On')
           set(pus_mov_sto,'String',xlate('Stop'),'Enable','Off','Userdata',[])
        end

        if ~isempty(chk_sho)
            pos_chk = get(chk_sho,'Position');
            pos_tog = get(tog_res,'Position');
            pos_chk(2) = pos_tog(2)-1.5*pos_chk(4);
            set(chk_sho,'Position',pos_chk);
        end

        hdl_ON = get(pus_mov_can,'Userdata');
        set(hdl_ON,'Visible','On');
        set(Hdls_toolPos,'Enable','On');
        utnbcfs('update_methode',fig,'reset');       
    end

    if ~okAuto && (idx==2 || idx==3)
        if (0<=setIDX) && (setIDX<=nbInSet)
            if setIDX>0 ,       enaSTA = 'On'; else , enaSTA = 'Off'; end
            if setIDX<nbInSet , enaSTO = 'On'; else , enaSTO = 'Off'; end            
            set([chk_mov_aut,pus_mov_can,pus_mov_sta,pus_mov_sto],...
                'Enable','Inactive');
            set(chk_mov_aut,'Userdata',setIDX)
            if setIDX==0 , CFS = [] ; else  , CFS = movieSET(setIDX); end    
            feval(calledFUN,'Apply_Movie',fig,CFS ,App_Val,pus_mov_sto);
            set([chk_mov_aut,pus_mov_can],'Enable','On');
            set(pus_mov_sta,'Enable',enaSTA);
            set(pus_mov_sto,'Enable',enaSTO);                       
        end
    end

  case 'update_Edi_Movie'
  %--------------------------%
  % Option: UPDATE_EDI_MOVIE %
  %--------------------------%
    Edi_Val = varargin{1};
 
    % Get stored structure.
    %----------------------
    longs = wmemtool('rmb',fig,n_membloc0,ind_longs); 
    app_val  = get(pop_app,'Value');
    Nb_Coefs = sum(longs(1:end-1));
    App_Len  = longs(1);
    switch app_val
      case 1 , minPos = App_Len; maxPos = Nb_Coefs;
      case 2 , minPos = 1;       maxPos = Nb_Coefs;
      case 3 , minPos = 1;       maxPos = Nb_Coefs-App_Len;
    end
    Max_Val = wstr2num(get(edi_max_mov,'String'));
    Min_Val = wstr2num(get(edi_min_mov,'String'));
    Stp_Val = wstr2num(get(edi_stp_mov,'String'));
 
    switch Edi_Val
      case 'Min'
        if  isempty(Min_Val)
            Min_Val = get(edi_min_mov,'Userdata');        
        else
            if     Min_Val > maxPos , Min_Val = maxPos;
            elseif Min_Val < minPos , Min_Val = minPos;
            end
            set(edi_min_mov,'Userdata',Min_Val);
            if Min_Val > Max_Val
                set(edi_max_mov,...
                    'String',sprintf('%.0f',Min_Val),'Userdata',Min_Val);
            end   
        end
        set(edi_min_mov,'String',sprintf('%.0f',Min_Val));
        if Min_Val > Max_Val
            set(edi_max_mov,...
                'String',sprintf('%.0f',Min_Val),'Userdata',Min_Val);
        end

      case 'Stp'
        if  isempty(Stp_Val) || Stp_Val < 1 || ...
            Stp_Val > Nb_Coefs || Stp_Val > Max_Val
            Stp_Val = get(edi_stp_mov,'Userdata');
        else
            set(edi_stp_mov,'Userdata',Stp_Val);
        end
        set(edi_stp_mov,'String',sprintf('%.0f',Stp_Val));

      case 'Max'
        if  isempty(Max_Val)
            Max_Val = get(edi_max_mov,'Userdata');
        else
            if     Max_Val > maxPos , Max_Val = maxPos;
            elseif Max_Val < minPos , Max_Val = minPos;
            end
            set(edi_max_mov,'Userdata',Max_Val);            
        end
        set(edi_max_mov,'String',sprintf('%.0f',Max_Val));
        if Max_Val < Min_Val
            set(edi_min_mov,...
                'String',sprintf('%.0f',Max_Val),'Userdata',Max_Val);
        end
    end 

  case 'demo'
  %--------------%
  % Option: DEMO %
  %--------------%
  parDemo  = varargin{1};
  nameMeth = parDemo{1};
  if length(parDemo)==1
      parDemo = [];
  else
      parDemo = parDemo{2};
  end
  switch nameMeth
    case 'Global' 
      switch toolOPT
        case 'cf1d'
          [coefs,longs] = wmemtool('rmb',fig,n_membloc0, ...
                                   ind_coefs,ind_longs);
          [thr,nkeep] = wdcbm(coefs,longs,3);
          nkeep  = fliplr(nkeep);
          lkeep  = length(nkeep);
          nbKept = longs;
          nbKept(2:1+lkeep) = nkeep;
          nbKept(end) = sum(nbKept(1:end-1));
          utnbcfs('set',fig,'nbKept',nbKept);
          cf1dtool('apply',fig);
          cf1dtool('show_ori_sig',fig,'On');

        case 'cf2d'
          [coefs,sizes] = wmemtool('rmb',fig,n_membloc0, ...
                                   ind_coefs,ind_sizes);
          [thr,nkeep] = wdcbm2(coefs,sizes,1.5);
          nkeep  = fliplr(nkeep);
          lkeep  = length(nkeep);
          nbKept = utnbcfs('get',fig,'nbKept');
          nbKept(2:1+lkeep) = nkeep;
          nbKept(end) = sum(nbKept(1:end-1));
          utnbcfs('set',fig,'nbKept',nbKept);
          cf2dtool('apply',fig);
      end
      
    case 'Stepwise' 
      switch toolOPT
        case 'cf1d'
          numMeth = 4;
          Stp_Val = 10;
          nb_Step = 15;
        case 'cf2d'
          numMeth = 3;
          Stp_Val = 20;
          nb_Step = 15;
      end
      nbOri = utnbcfs('get',fig,'nbOri');
      set(pop_met,'Value',numMeth);
      utnbcfs('update_methode',fig)
      if isempty(parDemo)
          set(edi_min_mov,'String',sprintf('%.0f',1));
          utnbcfs('update_Edi_Movie',fig,'Min');
          Min_Val = wstr2num(get(edi_min_mov,'String'));
          Max_Val = min(Min_Val+nb_Step*Stp_Val,nbOri(end));
      else
          Min_Val = parDemo(1);
          Stp_Val = parDemo(2);
          Max_Val = parDemo(3);
      end
      set(edi_min_mov,'String',sprintf('%.0f',Min_Val));
      set(edi_stp_mov,'String',sprintf('%.0f',Stp_Val));
      set(edi_max_mov,'String',sprintf('%.0f',Max_Val));
      utnbcfs('update_Edi_Movie',fig,'Max')
      utnbcfs('update_Edi_Movie',fig,'Stp')
      pause(1)
      utnbcfs('Mngr_Movie',fig,pus_mov_sta);
  end

end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function [pos_fra,dy_lev,y_res,y_est] = getPosFraThr(fra,nblevs,toolOPT)

Def_Btn_Height = mextglob('get','Def_Btn_Height');
d_lev = 2;
bdy   = 4;
pos_fra = get(fra,'Position');
top_fra = pos_fra(2)+pos_fra(4);
switch  toolOPT
  case {'cf1d','cf2d'} , NB_Height = 6;
end
h_ini   = (NB_Height-1)*bdy+NB_Height*Def_Btn_Height;
h_fra   = h_ini+ nblevs*(Def_Btn_Height+d_lev)+ ...
          depOfMachine(Def_Btn_Height);
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
