function varargout = wdretool(option,varargin)
%WDRETOOL Wavelet Density and Regression tool.
%   VARARGOUT = WDRETOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 05-Dec-96.
%   Last Revision: 05-Feb-2004.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/03/15 22:42:38 $

% Test inputs.
%-------------
if nargin==0 , option = 'createREG'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Memory Blocks of stored values.
%================================
% MB1.
%-----
n_membloc1   = 'MB_1';
ind_xdata    = 1;
ind_ydata    = 2;
ind_xbounds  = 3;
ind_filename = 4;
ind_pathname = 5;
ind_sig_name = 6;
nb2_stored   = 6;

% MB2.
%-----
n_membloc2   = 'MB_2';
ind_status   = 1;
ind_lin_den  = 2;
ind_gra_area = 3;
nb1_stored   = 3;

% MB3.
%-----
n_membloc3 = 'MB_3';
ind_coefs  = 1;
ind_longs  = 2;
ind_sig    = 3;
nb4_stored = 3;

% Default values.
%----------------
def_MinBIN = 64;
def_DefBIN = 256;
default_wave = 'sym4';
NB_max_lev = 8;
NB_def_lev = 5;
yLevelDir  = -1;

% Tag property.
%--------------
tag_ori = 'Sig';
tag_dat = 'Proc_Data';
tag_app = 'App';
tag_est = 'Est';

switch option
  case {'createDEN','createREG'}
  case 'close' ,
  otherwise
    win_tool = varargin{1};
    handles  = wfigmngr('getValue',win_tool,['WDRE_handles']);
    hdl_UIC  = handles.hdl_UIC;
    hdl_AXE  = handles.hdl_AXE;
    txt_hdl  = handles.hdl_TXT;
    hdl_MEN  = handles.hdl_MEN;
    men_sav  = hdl_MEN(end);
    dummy    = struct2cell(hdl_UIC);
    [txt_bin,sli_bin,edi_bin,pus_dec,chk_den] = deal(dummy{:});
    axe_hdl  = struct2cell(hdl_AXE);
    [axe_L_1,axe_R_1,axe_L_2,axe_R_2,axe_cfs,axe_det,axe_app] =  ...
           deal(axe_hdl{:});
    axe_hdl  = cat(2,axe_hdl{:});
    colors   = wfigmngr('getValue',win_tool,['WDRE_colors']);
    toolATTR = wfigmngr('getValue',win_tool,['WDRE_toolATTR']);
    switch option
      case {'load','demo'}
      otherwise , toolMode = toolATTR.toolMode;
    end
end

switch option
    case {'createDEN','createREG'}

        % Parameters initialization.
        %---------------------------
        indic_vis_lev = getLevels(NB_max_lev,yLevelDir);

        % Get Globals.
        %-------------
        [Def_Txt_Height,Def_Btn_Height,X_Spacing,Y_Spacing, ...
         sliYProp,Def_EdiBkColor, Def_FraBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','X_Spacing','Y_Spacing', ...
                'Sli_YProp','Def_EdiBkColor','Def_FraBkColor' ...
                );

        % Window initialization.
        %-----------------------
        switch option
          case 'createREG'
            win_title = 'Regression Estimation 1-D';
            estiNAME  = 'esti_REG';
			figExtMode = 'ExtFig_Tool_1';			

          case 'createDEN'
            win_title = 'Density Estimation 1-D';
            estiNAME  = 'esti_DEN';
			figExtMode = 'ExtFig_Tool_3';
        end
        [win_tool,pos_win,win_units,str_numwin,...
            frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
               wfigmngr('create',win_title,winAttrb,figExtMode,mfilename,1,1,0);
        if nargout>0 , varargout{1} = win_tool; end

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngr('getmenus',win_tool);
        switch option
          case 'createREG'

			% Add Help for Tool.
			%------------------
			wfighelp('addHelpTool',win_tool, ...
				'One-Dimensional Estimation - &Random Design','REGR_GUI');
			wfighelp('addHelpTool',win_tool, ...
				'One-Dimensional Estimation - &Fixed Design','REGF_GUI');

			% Add Help Item.
			%----------------
			wfighelp('addHelpItem',win_tool,'Regression Estimation','REG_EST');			
			wfighelp('addHelpItem',win_tool,'Available Methods','COMP_DENO_METHODS');
			wfighelp('addHelpItem',win_tool,'Variance Adaptive Thresholding','VARTHR');
			wfighelp('addHelpItem',win_tool,'Loading and Saving','REG_LOADSAVE');		

			m_load = wfigmngr('getmenus',win_tool,'load');  
            lab = 'Data for &Fixed Design Regression';
            men_fix = uimenu(m_load,...
                         'Label',lab,'Position',1, ...
                         'Callback',               ...
                         [mfilename '(''load'','   ...
                             str_numwin ',''fixreg'');'] ...
                         );
            lab = 'Data for &Stochastic Design Regression';
            men_sto = uimenu(m_load,...
                        'Label',lab,'Position',2, ...
                        'Callback',               ...
                        [mfilename '(''load'','   ...
                            str_numwin ',''storeg'');'] ...
                        );
            men_den = [];
            men_sav = uimenu(m_files,...
                         'Label','&Save Estimated Function',...
                         'Position',2,            ...
                         'Enable','Off',          ...
                         'Callback',              ...
                         [mfilename '(''save'','  ...
                             str_numwin ',''fun'');']...
                         );

            m_demo = uimenu(m_files,...
                        'Label','&Example Analysis','Position',3,'Separator','Off');
						 
            numDEM = 1;
            labDEM = 'Fixed Design';
            m_demo_1 = uimenu(m_demo, ...
                        'Label',labDEM,'Position',numDEM,'Separator','Off');

            demoSET = {...
              'fixreg' , 'Example I'     , 'ex1nfix'  , 'db2'  , 5 ; ...
              'fixreg' , 'Example II'    , 'ex2nfix'  , 'sym4' , 5 ; ...
              'fixreg' , 'Example II'    , 'ex3nfix'  , 'db3'  , 5 ; ...
              'fixreg' , 'Noisy blocks'  , 'noisbloc' , 'haar' , 5 ; ...
              'fixreg' , 'Noisy Doppler' , 'noisdopp' , 'db5'  , 5 ; ...
              'fixreg' , 'Noisy bumps'   , 'noisbump' , 'db5'  , 5   ...
              };
            setDEMOS(m_demo_1,mfilename,str_numwin,demoSET,0)

            numDEM = 2;
            labDEM = ['Fixed Design - Interval Dependent Noise Variance'];
            m_demo_2 = uimenu(m_demo, ...
                        'Label',labDEM,'Position',numDEM,'Separator','Off');

            demoSET = {...
              'fixreg' , 'Noisy blocks (I)  - 3 intervals' , 'nblocr1' , 'sym4', 5 , '{3}' ; ...
              'fixreg' , 'Noisy blocks (II) - 3 intervals' , 'nblocr2' , 'sym4', 5 , '{3}' ; ...
              'fixreg' , 'Noisy Doppler (I) - 3 intervals' , 'ndoppr1' , 'sym4', 5 , '{3}' ; ...
              'fixreg' , 'Noisy bumps (I)   - 3 intervals' , 'nbumpr1' , 'sym4', 5 , '{3}' ; ...
              'fixreg' , 'Noisy bumps (II)  - 2 intervals' , 'nbumpr2' , 'sym4', 5 , '{2}' ; ...
              'fixreg' , 'Noisy bumps (III) - 4 intervals' , 'nbumpr3' , 'sym4', 5 , '{4}' ; ...
              'fixreg' , 'Elec. consumption - 3 intervals' , 'nelec'   , 'sym4', 5 , '{3}'   ...
              };
            setDEMOS(m_demo_2,mfilename,str_numwin,demoSET,0)

            numDEM = 3;
            labDEM = 'Stochastic Design';
            m_demo_3 = uimenu(m_demo,...
                        'Label',labDEM,'Position',numDEM,'Separator','On');
            demoSET = {...
              'storeg' , 'Example I'     , 'ex1nsto'  , 'sym4' ,5 ; ...
              'storeg' , 'Example II'    , 'ex2nsto'  , 'haar' ,5 ; ...
              'storeg' , 'Example III'   , 'ex3nsto'  , 'db6'  ,5 ; ...
              'storeg' , 'Noisy Doppler' , 'noisdopp' , 'db5'  ,5 ; ...
              'storeg' , 'Noisy bumps'   , 'noisbump' , 'db5'  ,5   ...
              };
            setDEMOS(m_demo_3,mfilename,str_numwin,demoSET,0)
 
            numDEM = 4;
            labDEM = ['Stochastic Design '...
			                ' - Interval Dependent Noise Variance'];
            m_demo_4 = uimenu(m_demo,...
                        'Label',labDEM,'Position',numDEM,'Separator','Off');
            demoSET = {...
              'storeg' , 'Noisy blocks (I)  - 3 intervals' , 'snblocr1' , 'sym4', 5 , '{3}' ; ...
              'storeg' , 'Noisy blocks (II) - 3 intervals' , 'snblocr2' , 'sym4', 5 , '{3}' ; ...
              'storeg' , 'Noisy Doppler (I) - 3 intervals' , 'sndoppr1' , 'sym4', 5 , '{3}' ; ...
              'storeg' , 'Noisy bumps (I)   - 3 intervals' , 'snbumpr1' , 'sym4', 5 , '{3}' ; ...
              'storeg' , 'Noisy bumps (II)  - 2 intervals' , 'snbumpr2' , 'sym4', 5 , '{2}' ; ...
              'storeg' , 'Noisy bumps (III) - 4 intervals' , 'snbumpr3' , 'sym4', 5 , '{4}' ; ...
              'storeg' , 'Elec. consumption - 3 intervals' , 'snelec'   , 'sym4', 5 , '{3}'   ...
              };
            setDEMOS(m_demo_4,mfilename,str_numwin,demoSET,0)


          case 'createDEN'

			% Add Help for Tool.
			%------------------
			wfighelp('addHelpTool',win_tool, ...
				'&One-Dimensional Estimation','EDEN_GUI');

			% Add Help Item.
			%----------------
			wfighelp('addHelpItem',win_tool,'Available Methods','COMP_DENO_METHODS');
			wfighelp('addHelpItem',win_tool,'Variance Adaptive Thresholding','VARTHR');
			wfighelp('addHelpItem',win_tool,'Loading and Saving','EDEN_LOADSAVE');		
			wfighelp('addHelpItem',win_tool,'Density Estimation','DENS_EST');		
			  
            lab = '&Load data for Density Estimate';
            men_fix = [];
            men_sto = [];
            men_den = uimenu(m_files,...
                         'Label',lab,'Position',1, ...
                         'Callback',               ...
                         [mfilename '(''load'','   ...
                             str_numwin ',''denest'');'] ...
                         );

            men_sav = uimenu(m_files,...
                         'Label','&Save Density', ...
                         'Position',2,           ...
                         'Enable','Off',         ...
                         'Callback',             ...
                         [mfilename '(''save'',' ...
                             str_numwin ',''den'');'] ...
                         );
            numDEM = 3;
            demoSET = {...
              'denest' , 'ex1cusp1' , 'ex1cusp1' , 'sym4'  , 5 ; ...
              'denest' , 'ex2cusp1' , 'ex2cusp1' , 'sym6'  , 5 ; ...
              'denest' , 'ex1cusp2' , 'ex1cusp2' , 'sym4'  , 5 ; ...
              'denest' , 'ex2cusp2' , 'ex2cusp2' , 'coif1' , 5 ; ...
              'denest' , 'ex1gauss' , 'ex1gauss' , 'sym3'  , 5 ; ...
              'denest' , 'ex2gauss' , 'ex2gauss' , 'sym4'  , 5   ...
              };
            m_demo = uimenu(m_files,'Label','&Example Analysis ','Position',3);
            setDEMOS(m_demo,mfilename,str_numwin,demoSET,0);
        end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_tool,'Wait ... initialization');

        % General parameters initialization.
        %-----------------------------------
        dx = X_Spacing;
        dy = Y_Spacing;
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        deltaY = (Def_Btn_Height+dy);
        sli_hi = Def_Btn_Height*sliYProp;
        sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);
        minimum_bin = 16;
        maximun_bin = 1024;
        default_bin = 256;

        % String property of objects.
        %----------------------------
        str_pus_dec = 'Decompose';
        str_chk_den = 'Overlay Estimated Function';
        str_txt_bin = 'Nb bins';
        str_edi_bin = sprintf('%.0f',default_bin);

        % Command part of the window.
        %============================
        comFigProp = {'Parent',win_tool,'Unit',win_units};

        % Data, Wavelet and Level parameters.
        %------------------------------------
        xlocINI = pos_frame0([1 3]);
        ytopINI = pos_win(4)-dy;
        toolPos = utanapar('create',win_tool, ...
                    'xloc',xlocINI,'top',ytopINI,...
                    'enable','off',      ...
                    'wtype','dwt',       ...
                    'deflev',NB_def_lev, ...
                    'maxlev',NB_max_lev  ...
                    );
        pop_lev = utanapar('handles',win_tool,'lev');

        % Callbacks.
        %-----------
        cba_sli_bin = [mfilename '(''upd_bin'',' str_numwin ',''sli'');'];
        cba_edi_bin = [mfilename '(''upd_bin'',' str_numwin ',''edi'');'];
        cba_pus_dec = [mfilename '(''decompose'',' str_numwin ');'];
        cba_chk_den = [mfilename '(''show_lin_den'',' str_numwin ');'];

        % Bins settings.
        %---------------
        w_bas = toolPos(3)/48;        
        h_uic = Def_Btn_Height;

        w_uic = 11*w_bas;
        x_uic = toolPos(1);
        y_uic = toolPos(2)-h_uic-2*dy;
        pos_txt_bin = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        x_uic = x_uic+w_uic;
        w_uic = 27*w_bas;
        pos_sli_bin = [x_uic, y_uic+sli_dy, w_uic, sli_hi];

        x_uic = x_uic+w_uic+4;
        w_uic = 10*w_bas-4;
        pos_edi_bin = [x_uic, y_uic, w_uic, h_uic];
       
        txt_bin = uicontrol(comFigProp{:},...
                            'Style','Text',...
                            'Position',pos_txt_bin,...
                            'HorizontalAlignment','left',...
                            'Backgroundcolor',Def_FraBkColor,...
                            'String',str_txt_bin...                            
                            );
 
        sli_bin = uicontrol(comFigProp{:},...
                            'Style','Slider',...
                            'Position',pos_sli_bin,...
                            'Min',minimum_bin,...
                            'Max',maximun_bin,...
                            'Value',default_bin, ...
                            'Enable','off', ...
                            'Callback',cba_sli_bin ...
                            );

        edi_bin = uicontrol(comFigProp{:},...
                            'Style','Edit',...
                            'Backgroundcolor',Def_EdiBkColor,...
                            'Position',pos_edi_bin,...
                            'String',str_edi_bin,...
                            'Enable','off',...
                            'Callback',cba_edi_bin ...
                            );

        % Decompose pushbutton.
        %----------------------
        h_uic = 3*Def_Btn_Height/2;
        y_uic = y_uic-h_uic-2*dy;
        w_uic = pos_frame0(3)/2;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        pos_pus_dec = [x_uic, y_uic, w_uic, h_uic];
        pus_dec = uicontrol(comFigProp{:},          ...
                            'Style','Pushbutton',   ...
                            'Position',pos_pus_dec, ...
                            'String',xlate(str_pus_dec),   ...
                            'Enable','off',         ...
                            'Interruptible','On',   ...
                            'Callback',cba_pus_dec  ...
                            );

        % Thresholding tool.
        %-------------------
        ytopTHR = pos_pus_dec(2)-2*dy;
        toolPos = utthrw1d('create',win_tool, ...
                 'xloc',xlocINI,'top',ytopTHR,...
                 'ydir',yLevelDir,       ...
                 'levmax',NB_def_lev,    ...
                 'levmaxMAX',NB_max_lev, ...
                 'status','Off',         ...
                 'toolOPT',estiNAME      ...
                 );


        % Estimated Line(s) Check.
        %-------------------------
        w_uic = (3*pos_frame0(3))/4;
        x_uic = pos_frame0(1)+(pos_frame0(3)-w_uic)/2;
        h_uic = Def_Btn_Height;
        y_uic = toolPos(2)-Def_Btn_Height/2-h_uic;
        pos_chk_den = [x_uic, y_uic, w_uic, h_uic];
        if isequal(option,'createDEN') , vis = 'Off'; else , vis = 'On'; end  
        chk_den = uicontrol(comFigProp{:},          ...
                            'Style','checkbox',     ...
                            'Visible',vis,          ...
                            'Position',pos_chk_den, ...
                            'String',str_chk_den,   ...
                            'Enable','off',         ...
                            'Callback',cba_chk_den  ...
                            );

        % Callbacks update.
        %------------------
        hdl_den = utthrw1d('handles',win_tool);
        utanapar('set_cba_num',win_tool,[m_files;hdl_den(:)]);
        pop_lev = utanapar('handles',win_tool,'lev');
        tmp     = num2mstr(pop_lev );
        cba_pop_lev = [mfilename '(''upd_lev'',' str_numwin ',' tmp ');'];
        set(pop_lev,'Callback',cba_pop_lev);

        % General graphical parameters initialization.
        %--------------------------------------------
        txtLRProp = {'off','bold',14};

        % Axes construction parameters.
        %------------------------------
        NB_lev    = NB_max_lev;    % dummy
        w_gra_rem = Pos_Graphic_Area(3);
        h_gra_rem = Pos_Graphic_Area(4);
        ecx_left  = 0.08*pos_win(3);
        ecx_med   = 0.07*pos_win(3);
        ecx_right = 0.06*pos_win(3);
        w_axe     = (w_gra_rem-ecx_left-ecx_med-ecx_right)/2;
        x_cfs     = ecx_left;
        x_det     = x_cfs+w_axe+ecx_med;
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.07*pos_win(4);
        ecy_mid_2 = ecy_mid_1;
        ecy_mid_3 = ecy_mid_1;
        ecy_det   = (0.04*pos_win(4))/1.4;
        ecy_down  = ecy_up;
        h_min     = h_gra_rem/12;
        h_max     = h_gra_rem/5;
        h_axe_std = (h_min*NB_lev+h_max*(NB_max_lev-NB_lev))/NB_max_lev;
        h_space   = ecy_up+ecy_mid_1+ecy_mid_2+ecy_mid_3+...
                    (NB_lev-1)*ecy_det+ecy_down;
        h_detail  = (h_gra_rem-2*h_axe_std-h_space)/(NB_lev+1);
        y_low_ini = pos_win(4);

        % Building data axes.
        %--------------------
        comAxeProp = {...
          comFigProp{:},'Visible','off','Drawmode','fast','Box','On'};
        y_low_ini = y_low_ini-h_axe_std-ecy_up;
        pos_L_1   = [x_cfs y_low_ini w_axe h_axe_std];
        axe_L_1   = axes(comAxeProp{:},'Position',pos_L_1);
        pos_R_1   = [x_det y_low_ini w_axe h_axe_std];
        axe_R_1   = axes(comAxeProp{:},'Position',pos_R_1);
        y_low_ini = y_low_ini-h_axe_std-ecy_mid_1;
        pos_L_2   = [x_cfs y_low_ini w_axe h_axe_std];
        axe_L_2   = axes(comAxeProp{:},'Position',pos_L_2);
        pos_R_2   = [x_det y_low_ini w_axe h_axe_std];
        axe_R_2   = axes(comAxeProp{:},'Position',pos_R_2);
        y_low_ini = y_low_ini-h_axe_std-ecy_mid_2;

        % Building approximation axes on the right part.
        %-----------------------------------------------
        pos_app = [x_det y_low_ini w_axe h_detail];
        axe_app = axes(comAxeProp{:},'Position',pos_app);
        str_txt = ['a' wnsubstr(abs(NB_max_lev))];
        txt_app = txtinaxe('create',str_txt,axe_app,'r',txtLRProp{:});
        y_low_ini = y_low_ini-h_detail-ecy_mid_3+ecy_det;

        % Building details axes on the left part.
        %----------------------------------------
        comAxePropMore = {...
          comAxeProp{:},'XTicklabelMode','manual','XTickLabel',[]};
        axe_cfs = zeros(1,NB_max_lev);
        txt_cfs = zeros(1,NB_max_lev);
        y_cfs   = y_low_ini;
        pos_cfs = [x_cfs y_cfs w_axe h_detail];
        for j = 1:NB_max_lev
            k = indic_vis_lev(j);
            pos_cfs(2) = pos_cfs(2)-pos_cfs(4)-ecy_det;
            axe_cfs(k) = axes(comAxePropMore{:},'Position',pos_cfs);
            str_txt    = ['d' wnsubstr(k)];
            txt_cfs(k) = txtinaxe('create',str_txt,axe_cfs(k),'l',txtLRProp{:});
            set(txt_cfs(k),'Userdata',k,'tag','');
        end
        utthrw1d('set',win_tool,'axes',axe_cfs);

        % Building details axes on the right part.
        %-----------------------------------------
        axe_det = zeros(1,NB_max_lev);
        txt_det = zeros(1,NB_max_lev);
        y_det   = y_low_ini;
        pos_det = [x_det y_det w_axe h_detail];
        for j = 1:NB_max_lev
            k = indic_vis_lev(j);
            pos_det(2) = pos_det(2)-pos_det(4)-ecy_det;
            axe_det(k) = axes(comAxePropMore{:},'Position',pos_det);
            str_txt    = ['d' wnsubstr(k)];
            txt_det(k) = txtinaxe('create',str_txt,axe_det(k),'r',txtLRProp{:});
        end

        %  Normalization.
        %----------------
        Pos_Graphic_Area = wfigmngr('normalize',win_tool,Pos_Graphic_Area);
        drawnow

        % Set default wavelet.
        %---------------------
        cbanapar('set',win_tool,'wav',default_wave);

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_BINS  = [txt_bin,sli_bin,edi_bin];
		switch option
			case 'createDEN' , helpName = 'EDEN_BINS';
			case 'createREG' , helpName = 'REG_BINS';
		end
		wfighelp('add_ContextMenu',win_tool,hdl_BINS,helpName);		
		%-------------------------------------
		
        % Memory blocks update.
        %----------------------
        wmemtool('ini',win_tool,n_membloc2,nb1_stored);
        wmemtool('ini',win_tool,n_membloc1,nb2_stored);
        wmemtool('ini',win_tool,n_membloc3,nb4_stored);
        wmemtool('wmb',win_tool,n_membloc2,...
                                ind_status,0,        ...
                                ind_lin_den,[NaN,NaN], ...
                                ind_gra_area,Pos_Graphic_Area ...
                                );
        fields = {...
          'txt_bin','sli_bin','edi_bin', ...
          'pus_dec','chk_den'            ...
          };
        values = {...
           txt_bin,sli_bin,edi_bin, ...
           pus_dec,chk_den          ...
           };
        hdl_UIC = cell2struct(values,fields,2);
        hdl_MEN = [men_fix ; men_sto ; men_den ; men_sav];
        fields = {...
          'axe_L_1' , 'axe_R_1' , 'axe_L_2' , 'axe_R_2' ,  ...
          'axe_cfs' , 'axe_det' , 'axe_app' ...
          };
        values = {...
          axe_L_1 , axe_R_1 , axe_L_2 , axe_R_2 ,  ...
          axe_cfs , axe_det , axe_app ...
           };
        hdl_AXE = cell2struct(values,fields,2);
        hdl_TXT = [NaN  NaN  NaN  NaN  txt_cfs txt_det txt_app];
        handles = struct(...
            'hdl_MEN',hdl_MEN, ...
            'hdl_UIC',hdl_UIC, ...
            'hdl_AXE',hdl_AXE, ...
            'hdl_TXT',hdl_TXT  ...
            );
        wfigmngr('storeValue',win_tool,['WDRE_handles'],handles);

        %-----------------------------------------------------------------
        % colors = struct( ...
        %   'sigColor',[1 0 0],'denColor',[1 0 0],'appColor',[0 1 1], ...
        %   'detColor',[0 1 0],'cfsColor',[0 1 0],'estColor',[1 1 0]  ...
        %   );
        %-----------------------------------------------------------------

        colors = wtbutils('colors','wdre');
        wfigmngr('storeValue',win_tool,['WDRE_colors'],colors);

        toolATTR = struct('toolMode','','toolState','','level',[],'wname','','NBClasses',[]);
        wfigmngr('storeValue',win_tool,['WDRE_toolATTR'],toolATTR);

        % End waiting.
        %---------------
        wwaiting('off',win_tool);

    case {'load','demo'}
        tool_OPT = varargin{2};
        switch option
          case 'load'
            dialName = ['Load data - '];
            switch tool_OPT
              case 'denest' , dialName = [dialName 'density estimation' ];
              case 'fixreg' , dialName = [dialName 'fixed design'];
              case 'storeg' , dialName = [dialName 'stochastic design'];
            end
            [filename,pathname,ok] = ...
                utguidiv('test_load',win_tool,'*.mat',dialName);
            if ~ok, return; end

          case 'demo'
            sig_Name = deblank(varargin{3});
            wav_Name = deblank(varargin{4});
            lev_Anal = varargin{5};
            if length(varargin)>5  & ~isempty(varargin{6})
                parDemo = varargin{6};
            else
                parDemo = '';
            end
            filename = [sig_Name '.mat'];
            pathname = utguidiv('WTB_DemoPath',filename);
        end

        % Loading file.
        %--------------
        wwaiting('msg',win_tool,'Wait ... loading');
        fullName = fullfile(pathname,filename);
        [fileStruct,err] = wfileinf(fullName);
        if ~err
            try
              load(fullName,'-mat');
            catch
              err = 1;
              msg = sprintf('File %s is not a valid file.', filename);
            end
        end
        if ~err
            % Keep only numeric values.
            %--------------------------
            dum = struct2cell(fileStruct);
            dumClass = dum(4,:);
            idxClass = find(~strcmp(dumClass,'double') & ...
                       ~strcmp(dumClass,'uint8') & ...
                       ~strcmp(dumClass,'sparse'));
            fileStruct(idxClass) = [];
            err = isempty(fileStruct);
        end

        if ~err
            % Keep only one dim values.
            %--------------------------
            dum = struct2cell(fileStruct);
            dumSize = dum(2,:);
            dumSize = cat(1,dumSize{:});
            mini    = min(dumSize,[],2);
            maxi    = max(dumSize,[],2);
            idxSize = find(mini~=1 | maxi<2);
            fileStruct(idxSize) = [];
            err = isempty(fileStruct);
        end

        if ~err
            err = 1;
            switch tool_OPT
              case 'denest'
                xdata = eval(fileStruct(1).name);
                ydata = ones(size(xdata));
                err = 0;

              case {'fixreg','storeg'}
                % Seek X and Y values.
                %---------------------
                dum = struct2cell(fileStruct);
                dum = lower(dum(1,:));
                idxVarSET = [1:length(dum)];
                flagX = 0;
                flagY = 0;
                idx_Xdata = find(strcmp(dum,'xdata'));
                if ~isempty(idx_Xdata)
                   flagX = 1;
                   idxVarSET = setdiff(idxVarSET,idx_Xdata);
                else
                   idxSET = strmatch('x',dum);
                   if ~isempty(idxSET)
                       flagX = 1;
                       idx_Xdata = idxSET(1);
                       idxVarSET = setdiff(idxVarSET,idx_Xdata);
                   end
                end
                idx_Ydata = find(strcmp(dum,'ydata'));
                if ~isempty(idx_Ydata)
                   flagY = 1;
                   idxVarSET = setdiff(idxVarSET,idx_Ydata);
                else
                   idxSET = strmatch('y',dum);
                   if ~isempty(idxSET)
                       flagY = 1;
                       idx_Ydata = idxSET(1);
                       idxVarSET = setdiff(idxVarSET,idx_Ydata);
                   end
                end
                if ~flagX & ~isempty(idxVarSET)
                    flagX = 1;
                    idx_Xdata = idxVarSET(1);
                    idxVarSET(1) = [];
                end
                if ~flagY & ~isempty(idxVarSET)
                    flagY = 1;
                    idx_Ydata = idxVarSET(1);
                    idxVarSET(1) = [];
                end
                if ~isempty(idx_Xdata)
                     xdata = eval(fileStruct(idx_Xdata).name);
                end
                if ~isempty(idx_Ydata)
                     ydata = eval(fileStruct(idx_Ydata).name);
                end
                fileStruct([idx_Xdata,idx_Ydata]) = [];
                if flagX & ~flagY
                   flagY = 1;
                   ydata = xdata;
                   xdata = [1:length(ydata)];

                elseif flagY & ~flagX
                   flagX = 1;
                   xdata = [1:length(ydata)];
                end
                if flagX & flagY & (length(xdata)==length(ydata))
                    err = 0;
                end
            end
        end
        if err
            msg = ['File not found or invalid values for variables!'];
        elseif ~isreal(xdata) | ~isreal(ydata)
            msg = strvcat(sprintf('File %s doesn''t contain real data.', filename),' ');
            err = 1;                     
        end
        if err
            wwaiting('off',win_tool);
            errordlg(msg,'Load ERROR','modal');
            return            
        end
        
        [sig_Name,ext] = strtok(filename,'.');
        sig_Size = length(xdata);
        xbounds  = [min(xdata),max(xdata)];

        % Begin waiting.
        %---------------
        wwaiting('msg',win_tool,'Wait ... cleaning');

        % Tool Settings.
        %---------------
        levm   = wmaxlev(sig_Size,'haar');
        levmax = min(levm,NB_max_lev);
        if isequal(option,'demo')
            anaPar = {'wav',wav_Name};
        else
            wav_Name = cbanapar('get',win_tool,'wav');
            lev_Anal = NB_def_lev;
            anaPar = {};
        end
        strlev = int2str([1:levmax]');
        anaPar = {anaPar{:},'n_s',{sig_Name,sig_Size}, ...
                  'lev',{'String',strlev,'Value',lev_Anal}};
        defaultBIN = min([def_DefBIN,fix(sig_Size/4)]);
        minBIN     = min([def_MinBIN,defaultBIN]);            
        maxBIN     = sig_Size;     

        % Store tool settings & analysis parameters.
        %------------------------------------------- 
        toolATTR.toolMode  = tool_OPT;
        toolATTR.toolState = 'ini';
        toolATTR.level     = lev_Anal;
        toolATTR.wname     = wav_Name;
        toolATTR.NBClasses = defaultBIN;
        wfigmngr('storeValue',win_tool,['WDRE_toolATTR'],toolATTR);

        % Store analysis parameters.
        %--------------------------- 
        wmemtool('wmb',win_tool,n_membloc2,ind_status,0);
 
        wmemtool('wmb',win_tool,n_membloc1,   ...
                       ind_filename,filename, ...
                       ind_pathname,pathname, ...
                       ind_sig_name,sig_Name, ...
                       ind_xdata,xdata, ...
                       ind_ydata,ydata, ...
                       ind_xbounds,xbounds ...
                       );

        % Clean , Set analysis & GUI values.
        %-----------------------------------
        dynvtool('stop',win_tool)
        utthrset('stop',win_tool);
        wdretool('clean',win_tool,option);
        cbanapar('set',win_tool,anaPar{:});

        % Set bins.
        %-----------
        set(sli_bin,'Min',minBIN,'Value',defaultBIN,'Max',maxBIN)
        set(edi_bin,'String',int2str(defaultBIN));

        % Setting axes and UIC. 
        %----------------------
        wdretool('position',win_tool,lev_Anal);
        wdretool('enable',win_tool,'ini','on');
        wdretool('set_axes',win_tool);

        % Plot.
        %------
        color   = colors.sigColor;
        linProp = {...
            'Parent',axe_L_1, ...
            'Color',color,    ...
            'LineStyle','none',...
            'Marker','o',     ...
            'Markersize',2,   ...
            'MarkerEdgeColor',color, ...
            'MarkerFaceColor',color, ...
            'tag',tag_ori     ...
            };
        
        switch tool_OPT
          case 'denest'
            xval = linspace(xbounds(1),xbounds(2),sig_Size);
            ll = line(linProp{:},'Xdata',xval,'Ydata',xdata);
            ylim = getylim(xdata);
            set(axe_L_1,'Xlim',xbounds,'Ylim',ylim,'Xtick',[],'XtickLabel',[])
            wtitle('Data','Parent',axe_L_1)
            color  = colors.denColor;
            his    = wgethist(xdata,minBIN);
            wplothis(axe_L_2,his,color);
            strTitle = sprintf('%d bins - Histogram',minBIN);
            wtitle(strTitle,'Parent',axe_L_2)
            wdretool('set_Bins',win_tool);
            
          case {'fixreg','storeg'}
            lin_ori = line(linProp{:},'Xdata',xdata,'Ydata',ydata);
            utthrw1d('set',win_tool,'handleORI',lin_ori);
            ylim = getylim(ydata);
            set(axe_L_1,'Ylim',ylim)          
            wtitle('Data (X,Y)','Parent',axe_L_1)
            if tool_OPT(1)=='s' , wdretool('set_Bins',win_tool); end
        end

        % Plotting Processed data.
        %------------------------
        wdretool('plot_Processed_Data',win_tool);

        % if DEMO, analyze and estimate.
        %-------------------------------
        if isequal(option,'demo')
            wdretool('decompose',win_tool);
            if ~isempty(parDemo)
                 utthrw1d('demo',win_tool,'wdre',parDemo);
            end
            wdretool('estimate',win_tool);
            wdretool('show_lin_den',win_tool,'On')
        end
        cbanapar('enable',win_tool,'On');

        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'save'
        % Testing file.
        %--------------
        dialName = ['Save estimated '];
        switch toolMode
          case {'fixreg','storeg'} , dialName = [dialName 'function'];
          case 'denest' , dialName = [dialName 'denest' ];
        end
        [filename,pathname,ok] = utguidiv('test_save',win_tool, ...
                                     '*.mat',dialName);
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_tool,'Wait ... saving');

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end

        % Get de-noising parameters & de-noised signal.
        %-----------------------------------------------
        toolATTR = wfigmngr('getValue',win_tool,'WDRE_toolATTR');
        NB_lev = toolATTR.level;
        wname  = toolATTR.wname;
        [thrStruct,hdl_den] = utthrw1d('get',win_tool,...
                                 'thrstruct','handleTHR');
        thrParams = {thrStruct(1:NB_lev).thrParams};
        xdata = get(hdl_den,'Xdata');
        ydata = get(hdl_den,'Ydata');
        try
          save([pathname filename],'xdata','ydata','thrParams','wname');
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end
   
        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'decompose'
    
        % Compute decomposition and plot.
        %--------------------------------
        wwaiting('msg',win_tool,'Wait ... computing');

        % Clean HDLG.
        %---------------
        utthrw1d('clean_thr',win_tool);
        wdretool('show_lin_den',win_tool,'off')

        % Get analyzis parameters.
        %-------------------------
        [wname,NB_lev] = cbanapar('get',win_tool,'wav','lev');
        NBClasses = round(get(sli_bin,'Value'));

        % Tool Settings.
        %---------------
        toolATTR.toolState = 'dec';
        toolATTR.level     = NB_lev;
        toolATTR.wname     = wname;
        toolATTR.NBClasses = NBClasses;
        wfigmngr('storeValue',win_tool,['WDRE_toolATTR'],toolATTR);

        % Get Handles.
        %-------------
        indic_vis_lev = getLevels(NB_lev,yLevelDir);

        % Clean axes
        %------------
        axes2clean = [axe_R_2,axe_cfs,axe_det,axe_app];
        obj2del = findobj(axes2clean,'type','line');
        delete(obj2del)

        % Get X bounds values.
        %---------------------
        xbounds = wmemtool('rmb',win_tool,n_membloc1,ind_xbounds);        
        xmin = xbounds(1);  xmax = xbounds(2);

        % Compute.
        %---------
        sig_pro = wmemtool('rmb',win_tool,n_membloc3,ind_sig);
        [coefs,longs] = wavedec(sig_pro,NB_lev,wname);
        [det,app] = getFullDecTec(coefs,longs,wname,NB_lev);
        wmemtool('wmb',win_tool,n_membloc3, ...
                       ind_coefs,coefs, ...
                       ind_longs,longs ...
                       );

        % Initializing by level threshold.
        %---------------------------------
        maxTHR = zeros(1,NB_lev);
        for k = 1:NB_lev
            maxTHR(k) = max(abs(detcoef(coefs,longs,k)));
        end
        valTHR = wdretool('compute_LVL_THR',win_tool);
        valTHR = min(valTHR,maxTHR);

        % Plotting Coefficients.
        %-----------------------
        hdl_lines = NaN*ones(NB_max_lev,1);
        color = colors.cfsColor;
        len   = longs(end);
        viewSTEMS = 1;
        if viewSTEMS 
           dummy =  wfilters(wname);
           lf = length(dummy);
        end
        x_cfs = linspace(xbounds(1),xbounds(2),len);
        for j = 1:NB_lev
            k       = indic_vis_lev(j);
            axe_act = axe_cfs(k);
            axes(axe_act);            
            cfs = detcoef(coefs,longs,k);
            tag = ['cfs_' int2str(k)];
            ybounds = [-valTHR(k) , valTHR(k) , -maxTHR(k) , maxTHR(k)];            
            if ~viewSTEMS
                cfs = cfs(ones(1,2^k),:);
                cfs = wkeep1(cfs(:)',len);                
                hdl_lines(k) = plotline(axe_act,x_cfs,cfs,color,tag,ybounds);
            else
                ld = length(cfs);
                xd = coefsLOC([1:ld],k,lf,len);                
                x_tmp = x_cfs(xd);               
                hh = plotstem(axe_act,x_tmp,cfs,color,1,tag,ybounds);
                hdl_lines(k) = hh(3);
            end
            utthrw1d('plot_dec',win_tool,k,{maxTHR(k),valTHR(k),xmin,xmax,k});
        end

        i_axe_cfs_max = indic_vis_lev(NB_lev);
        xt = get(axe_app,{'Xtick','XtickLabel'});
        set([axe_det,axe_cfs],'Xtick',[],'XtickLabel',[]);
        set([axe_cfs(i_axe_cfs_max),axe_det(i_axe_cfs_max)], ...
           'Xtick',xt{1},'XtickLabel',xt{2}, ...
           'XtickMode','auto','XTickLabelMode','auto' ...
           );
        set(axe_hdl,'Xlim',[xmin xmax])
        set(txt_hdl(end),'String',['a' wnsubstr(abs(NB_lev))]);
  
        % Dynvtool Attachement.
        %---------------------
        if ~isequal(toolMode,'denest')
           axe_IND = []; axe_CMD = axe_hdl;       
        else
           axe_IND = axe_hdl(1); axe_CMD = axe_hdl(2:end);
        end
        dynvtool('init',win_tool,axe_IND,axe_CMD,[],[1 0],'','','')

        % Initialization of Denoising structure.
        %---------------------------------------
        utthrw1d('set',win_tool,...
                       'thrstruct',{xmin,xmax,valTHR,hdl_lines},...
                       'intdepthr',[]);

        % Enabling HDLG.
        %---------------
        wdretool('enable',win_tool,'dec','on');

        % Setting prog status.
        %----------------------
        wmemtool('wmb',win_tool,n_membloc2,ind_status,1);

        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'estimate'
        % Compute decomposition and plot.
        %--------------------------------
        wwaiting('msg',win_tool,'Wait ... computing');

        % Diseable De-noising Tool.
        %---------------------------
        utthrw1d('enable',win_tool,'off');

        % Read Tool Memory Block.
        %-----------------------
        [coefs,longs] = wmemtool('rmb',win_tool,n_membloc3,ind_coefs,ind_longs);
        NB_lev    = toolATTR.level;
        wname     = toolATTR.wname;
        NBClasses = toolATTR.NBClasses;
        indic_vis_lev = getLevels(NB_lev,yLevelDir);

        % De-noising & Plot de-noised signal.
        %------------------------------------
        cden = utthrw1d('den_M2',win_tool,coefs,longs);
        xbounds = wmemtool('rmb',win_tool,n_membloc1,ind_xbounds);
        xmin = xbounds(1); xmax = xbounds(2);
        xval = linspace(xmin,xmax,NBClasses);
        [det,app,sig_est] = getFullDecTec(cden,longs,wname,NB_lev);

        % Reset dynvtool.
        %----------------
        dynvtool('get',win_tool,0,'force');

        % Plotting details.
        %------------------
        color = colors.detColor;
        for j = 1:NB_lev
            k   = indic_vis_lev(j);
            tag = ['det_' int2str(k)];
            ll  = plotline(axe_det(k),xval,det(k,:),color,tag);
        end

        % Plotting approximation.
        %------------------------
        color = colors.appColor;
        plotline(axe_app,xval,app,color,tag_app);
        set(txt_hdl(end),'String',['a' wnsubstr(abs(NB_lev))]);

        % Plotting Estimation.
        %---------------------
        color = colors.estColor;
        if ~isequal(toolMode,'denest')
            lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
            set(lin_den,'Ydata',sig_est);
        else
            xdata = wmemtool('rmb',win_tool,n_membloc1,ind_xdata);
        end
        lin_den = plotline(axe_R_2,xval,sig_est,color,tag_est);
        i_axe_cfs_max = indic_vis_lev(NB_lev);
        xt = get(axe_app,{'Xtick','XtickLabel'});
        set([axe_det,axe_cfs],'Xtick',[],'XtickLabel',[]);
        set([axe_cfs(i_axe_cfs_max),axe_det(i_axe_cfs_max)], ...
           'Xtick',xt{1},'XtickLabel',xt{2}, ...
           'XtickMode','auto','XTickLabelMode','auto' ...
           );

        % Dynvtool Attachement.
        %---------------------
        if ~isequal(toolMode,'denest')
           axe_IND = []; axe_CMD = axe_hdl;       
        else
           axe_IND = axe_hdl(1); axe_CMD = axe_hdl(2:end);
        end
        dynvtool('init',win_tool,axe_IND,axe_CMD,[],[1 0],'','','')

        % Enabling HDLG.
        %---------------
        utthrw1d('set',win_tool,'handleTHR',lin_den);
        utthrw1d('enable',win_tool,'on');
        wdretool('enable',win_tool,'den','on');

        % Storing tool State.
        %--------------------
        toolATTR.toolState = 'den';
        wfigmngr('storeValue',win_tool,['WDRE_toolATTR'],toolATTR);
        
        % End waiting.
        %-------------
        wwaiting('off',win_tool);

    case 'show_lin_den'
        if isequal(toolMode,'denest') , return; end
        lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
        ok = ishandle(lin_den(1));
        if length(varargin)>1
            vis = lower(varargin{2});
            if isequal(vis,'on') & ok , val = 1; else , val = 0; end 
            set(chk_den,'value',val);
        else
            vis = deblank(getonoff(get(chk_den,'value')));
            if ~ok , set(chk_den,'value',0); end
        end
        
        if ok
            if isequal(vis,'on')
                strTitle1 = ['Data (X,Y) and Estimate Y = f(X)'];
                strTitle2 = ['Processed Data (X,Y) and Estimate Y = f(X)'];
            end
            set(lin_den,'Visible',vis);
        end
        wtitle('Data (X,Y)','Parent',axe_L_1)
        wtitle('Processed Data (X,Y)','Parent',axe_R_1)

    case 'position'
        NB_lev  = varargin{2};
        set(chk_den,'Visible','off');
        pos_old = utthrw1d('get',win_tool,'position');
        utthrw1d('set',win_tool,'position',{1,NB_lev})
        pos_new = utthrw1d('get',win_tool,'position');
        ytrans  = pos_new(2)-pos_old(2);
        pos_chk = get(chk_den,'Position');
        pos_chk(2) = pos_chk(2)+ytrans;
        switch toolMode
          case 'denest' , vis_chk = 'off';
          otherwise ,     vis_chk = 'on';
        end
        set(chk_den,'Position',pos_chk,'Visible',vis_chk);

    case 'upd_lev'
        pop_lev = varargin{2};
        lev_New = get(pop_lev,'value');
        wdretool('position',win_tool,lev_New);
        wdretool('set_axes',win_tool);
        lev_Anal = toolATTR.level;
        flagView = 2;
        if isequal(lev_New,lev_Anal)
            state =  toolATTR.toolState;
            switch state
                case 'ini' ,
                    flagView = 1;
                    wdretool('enable',win_tool,'ini');
                case 'dec' , 
                    wdretool('enable',win_tool,'dec');
                case 'den' ,
                    val = get(chk_den,'Value');
                    wdretool('enable',win_tool,'dec','on');
                    wdretool('enable',win_tool,'den','on');
                    set(chk_den,'Value',val);
            end
        else
            flagView = 0;
            wdretool('enable',win_tool,'ini');
        end
        if flagView<2
            wdretool('show_lin_den',win_tool,'off')
            axe_off = [axe_R_2,axe_app,axe_det];
            axe_off = axe_off(ishandle(axe_off));
            lin_Off = findobj(axe_off,'type','line');
            set(lin_Off,'Visible','off');
        end

    case 'upd_bin'
        typ_upd = varargin{2};
        switch typ_upd
          case 'sli'
            nbOld = round(wstr2num(get(edi_bin,'String')));
            nbNew = round(get(sli_bin,'Value'));

          case 'edi'
            sliVal = get(sli_bin,{'Min','Value','Max'});
            minNb = sliVal{1};
            nbOld = sliVal{2};
            maxNb = sliVal{3};
            nbNew = round(wstr2num(get(edi_bin,'String')));
            if isempty(nbNew) | (nbNew<minNb) | (nbNew>maxNb)
               nbNew = nbOld;
            end
        end
        set(edi_bin,'String',int2str(nbNew));
        set(sli_bin,'Value',nbNew)
        if isequal(nbNew,nbOld) , return; end
        wdretool('clean',win_tool,'bin');

    case 'compute_LVL_THR'
        [numMeth,meth,alfa,sorh] = utthrw1d('get_LVL_par',win_tool);
        [coefs,longs] = wmemtool('rmb',win_tool,n_membloc3,ind_coefs,ind_longs);
        switch toolMode
          case 'denest'
            varargout{1}  = wthrmngr('dw1ddenoDEN',meth,coefs,longs,alfa); 
          case {'fixreg','storeg'}
            varargout{1}  = wthrmngr('dw1ddenoLVL',meth,coefs,longs,alfa);
        end

    case 'update_LVL_meth'
        wdretool('clear_GRAPHICS',win_tool);
        valTHR = wdretool('compute_LVL_THR',win_tool);
        utthrw1d('update_LVL_meth',win_tool,valTHR);
 
    case 'clear_GRAPHICS'
        status = wmemtool('rmb',win_tool,n_membloc2,ind_status);
        if status<1 , return; end

        wdretool('enable',win_tool,'den','off');
        wdretool('show_lin_den',win_tool,'off')
        axe_off = [axe_R_2,axe_app,axe_det];
        axe_off = axe_off(ishandle(axe_off));
        lin_Off = findobj(axe_off,'type','line');
        set(lin_Off,'Visible','off');

    case 'enable'
        type = varargin{2};
        if length(varargin)>2 , enaVal = varargin{3}; else , enaVal = 'on'; end
        switch type
          case 'ini'
            set([men_sav;chk_den],'Enable','off');
            utthrw1d('status',win_tool,'off');
            set([pus_dec;sli_bin;edi_bin],'Enable','on');

          case 'dec'
            NB_lev = toolATTR.level;
            set(chk_den,'Value',0);
            set([men_sav;chk_den],'Enable','off');
            utthrw1d('status',win_tool,'on');
            utthrw1d('enable',win_tool,'on');
            utthrw1d('enable',win_tool,enaVal,[1:NB_lev]);

          case 'den'
            set([men_sav;chk_den],'Enable',enaVal);
            utthrw1d('enable_tog_res',win_tool,enaVal);
            if strncmpi(enaVal,'on',2) , status = 1; else , status = 0; end
            wmemtool('wmb',win_tool,n_membloc2,ind_status,status);
        end

    case 'clean'
        calling_opt = varargin{2};        
        wdretool('show_lin_den',win_tool,'off')
        lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
        lin_den = lin_den(ishandle(lin_den));
        delete(lin_den);
        wmemtool('wmb',win_tool,n_membloc2,ind_lin_den,[NaN,NaN]); 
        switch calling_opt
          case {'load','demo'}
            obj2del = [findobj(axe_hdl,'type','line'); ...
                       findobj(axe_hdl,'type','patch')];
            delete(obj2del)
            switch toolMode
              case 'fixreg'
                win_title = 'Regression Estimation 1-D - Fixed Design';
                set(win_tool,'Name',win_title);
              case 'storeg'
                win_title = 'Regression Estimation 1-D - Stochastic Design';
                set(win_tool,'Name',win_title);
            end
            sig_name = wmemtool('rmb',win_tool,n_membloc1,ind_sig_name);
            cbanapar('set',win_tool,'nam',sig_name);
            utthrw1d('clean_thr',win_tool);

          case 'bin'
            switch toolMode
              case 'denest'  , axetoClean = axe_hdl([2,4:end]);
              case {'fixreg','storeg'} , axetoClean = axe_hdl(2:end);
            end
            obj2del = [findobj(axetoClean,'type','line'); ...
                       findobj(axetoClean,'type','patch')];
            delete(obj2del)
            wdretool('set_Bins',win_tool);
            wdretool('plot_Processed_Data',win_tool);
            wdretool('enable',win_tool,'ini');
        end

    case 'set_Bins'
        xdata  = wmemtool('rmb',win_tool,n_membloc1,ind_xdata);
        nbBINS = get(sli_bin,'Value');
        toolATTR.NBClasses = nbBINS;
        wfigmngr('storeValue',win_tool,['WDRE_toolATTR'],toolATTR);
        switch toolMode
          case 'denest'
            color  = colors.denColor;
            his    = wgethist(xdata,nbBINS);
            wplothis(axe_R_1,his,color);
            wtitle('Binned Data','Parent',axe_R_1)

          case 'fixreg'

          case 'storeg'
            color  = colors.denColor;
            his    = wgethist(xdata,nbBINS);
            wplothis(axe_L_2,his,color);
            wtitle('Histogram of X','Parent',axe_L_2)
        end

    case 'plot_Processed_Data'
        [xdata,ydata] = wmemtool('rmb',win_tool,n_membloc1, ...
                                       ind_xdata,ind_ydata);
        [sig_pro,xval] = wedenreg(toolATTR,xdata,ydata);
        wmemtool('wmb',win_tool,n_membloc3,ind_sig,sig_pro);
   
        % Plotting Processed data & initial Estimation(s).
        %-------------------------------------------------        
        switch toolMode
          case {'fixreg','storeg'}
            color = colors.sigColor;
            lin_processed = plotline(axe_R_1,xval,sig_pro,color,tag_dat);            
            color = colors.estColor;
            lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
            lin_den(1) = plotline(axe_L_1,xval,sig_pro,color,'');
            lin_den(2) = plotline(axe_R_1,xval,sig_pro,color,'');
            set(lin_den(1:2),'Visible','Off');
            ylim = getylim(ydata);
            set(axe_L_1,'Ylim',ylim);
            wmemtool('wmb',win_tool,n_membloc2,ind_lin_den,lin_den);
            hdl_est = plotline(axe_R_2,xval,sig_pro,color,tag_est);
            set(hdl_est,'Visible','Off');
            set(axe_hdl,'Xlim',[xval(1) xval(end)]);

          case {'denest'}
 
        end

    case 'set_axes'
        %*************************************************************%
        %** OPTION = 'set_axes' - Set axes positions and visibility **%
        %*************************************************************%
        if strcmp(toolMode,'nul') , return; end
        Pos_Graphic_Area = wmemtool('rmb',win_tool,n_membloc2,ind_gra_area);
        
        % Hide axes
        %-----------
        if ~isequal(toolMode,'denest')
            lin_den = wmemtool('rmb',win_tool,n_membloc2,ind_lin_den);
            if ishandle(lin_den(1)) , vis_den = get(lin_den(1),'Visible'); end
        end
        obj_in_axes = findobj(axe_hdl);
        set(obj_in_axes,'Visible','off');

        % Parameters initialization.
        %---------------------------
        NB_lev = cbanapar('get',win_tool,'lev');
        indic_vis_lev = getLevels(NB_lev,yLevelDir);
 
        % General graphical parameters initialization.
        %---------------------------------------------
        pos_win   = get(win_tool,'Position');
        ecy_up    = 0.06*pos_win(4);
        ecy_mid_1 = 0.07*pos_win(4);
        ecy_mid_2 = ecy_mid_1;
        ecy_mid_3 = ecy_mid_1;
        ecy_det   = (0.04*pos_win(4))/1.4;
        ecy_down  = ecy_up;
        h_gra_rem = Pos_Graphic_Area(4);
        h_min     = h_gra_rem/12;
        h_max     = h_gra_rem/5;
        h_axe_std = (h_min*NB_lev+h_max*(NB_max_lev-NB_lev))/NB_max_lev;
        h_space   = ecy_up+ecy_mid_1+ecy_mid_2+ecy_mid_3+...
                    (NB_lev-1)*ecy_det+ecy_down;
        h_detail  = (h_gra_rem-2*h_axe_std-h_space)/(NB_lev+1);
        y_low_ini = 1;

        % Building data axes.
        %--------------------
        y_low_ini = y_low_ini-h_axe_std-ecy_up;
        pos_L_1 = get(axe_L_1,'Position');
        pos_L_1([2 4]) = [y_low_ini h_axe_std];
        set(axe_L_1,'Position',pos_L_1);
        pos_R_1 = get(axe_R_1,'Position');
        pos_R_1([2 4]) = [y_low_ini h_axe_std];
        set(axe_R_1,'Position',pos_R_1);
        axe_vis = [axe_L_1,axe_R_1];
        
        y_low_ini = y_low_ini-h_axe_std-ecy_mid_1;
        pos_L_2  = get(axe_L_2,'Position');
        pos_L_2([2 4]) = [y_low_ini h_axe_std];
        set(axe_L_2,'Position',pos_L_2)
        pos_R_2  = get(axe_R_2,'Position');
        pos_R_2([2 4]) = [y_low_ini h_axe_std];
        set(axe_R_2,'Position',pos_R_2)
        switch toolMode
          case 'denest' , axe_vis = [axe_vis,axe_L_2,axe_R_2];
          case 'fixreg' , axe_vis = [axe_vis,axe_R_2];
          case 'storeg' , axe_vis = [axe_vis,axe_L_2,axe_R_2];
        end

        % Position for approximation axes on the right part.
        %---------------------------------------------------
        y_low_ini = y_low_ini-h_detail-ecy_mid_2;
        pos_axes = pos_R_2;
        pos_y   = [y_low_ini , h_detail];
        pos_axes([2 4]) = pos_y;
        set(axe_app,'Position',pos_axes);
        axe_vis = [axe_vis,axe_app];
        y_low_ini = y_low_ini-ecy_mid_3+ecy_det;

        % Position for details axes on the left part.
        %--------------------------------------------          
        pos_y  = [y_low_ini , h_detail];
        for j = 1:NB_lev
            i_axe    = indic_vis_lev(j);
            axe_act  = axe_cfs(i_axe);
            pos_axes = get(axe_act,'Position');
            pos_y(1) = pos_y(1)-h_detail-ecy_det;
            pos_axes([2 4]) = pos_y;
            set(axe_act,'Position',pos_axes);
            axe_vis = [axe_vis axe_act];
        end
        i_axe_cfs_min = indic_vis_lev(1);
        i_axe_cfs_max = indic_vis_lev(NB_lev);

        % Position for details axes on the right part.
        %---------------------------------------------
        pos_y   = [y_low_ini , h_detail];
        for j = 1:NB_lev
            i_axe    = indic_vis_lev(j);
            axe_act  = axe_det(i_axe);
            pos_axes = get(axe_act,'Position');
            pos_y(1) = pos_y(1)-h_detail-ecy_det;
            pos_axes([2 4]) = pos_y;
            set(axe_act,'Position',pos_axes);
            axe_vis  = [axe_vis axe_act];
        end
        i_axe_det_min = indic_vis_lev(1);

        % Modification of app_text.
        %--------------------------
        status = wmemtool('rmb',win_tool,n_membloc2,ind_status);
        if status==0
            txt_app = txt_hdl(end);
            num_app = NB_lev;
            set(txt_app,'string',['a' wnsubstr(abs(num_app))]);
        end

        % Set axes.
        %-----------
        xt = get(axe_L_1,{'Xtick','XtickLabel'});
        ind_axe_cfs = [i_axe_cfs_min:i_axe_cfs_max-1];
        set(axe_cfs(ind_axe_cfs),'Xtick',[],'XtickLabel',[]);
        set([axe_cfs(i_axe_cfs_max),axe_det(i_axe_cfs_max)], ...
            'Xtick',xt{1},'XtickLabel',xt{2} , ...
            'XtickMode','auto','XTickLabelMode','auto' ...
            )
        titles = get([axe_cfs;axe_det],'title');
        titles = cat(1,titles{:});
        set(titles,'String','');
        obj_in_axes_vis = findobj(axe_vis);
        set(obj_in_axes_vis,'Visible','on');
        if ~isequal(toolMode,'denest')
            if ishandle(lin_den(1)) , set(lin_den,'Visible',vis_den); end
        end
       %  hdl_den = utthrw1d('get',win_tool,'handleTHR')
       %  set(hdl_den,'color','g')
        
        % Setting axes title
        %--------------------
        switch toolMode
          case 'fixreg'
            wtitle('Data (X,Y)','Parent',axe_L_1);
            wtitle('Regression Estimate Y = f(X)','Parent',axe_R_2);

          case 'storeg'
            wtitle('Data (X,Y)','Parent',axe_L_1)
            wtitle('Histogram of X','Parent',axe_L_2);
            wtitle('Regression Estimate Y = f(X)','Parent',axe_R_2);
            wtitle('Processed Data (X,Y)','Parent',axe_R_1);

          case 'denest'
            wtitle('Data','Parent',axe_L_1);
            wtitle(sprintf('%d bins - Histogram',def_MinBIN),'Parent',axe_L_2);
            wtitle('Binned Data','Parent',axe_R_1);
            wtitle('Density Estimate','Parent',axe_R_2);
        end
        wtitle('Details coefficients','Parent',axe_cfs(i_axe_cfs_min));
        wtitle('Details','Parent',axe_det(i_axe_det_min));
        wtitle('Approximation','Parent',axe_app);

    case 'close'

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
function setDEMOS(m_demo,funcName,str_numwin,demoSET,sepFlag)

beg_call_str = [funcName '(''demo'',' str_numwin ','''];
[nbDEM,nbVAL] = size(demoSET);
for k=1:nbDEM
    typ = demoSET{k,1};
    nam = demoSET{k,2};
    fil = demoSET{k,3};
    wav = demoSET{k,4};
    len = length(wav);
    wavDum = [wav , blanks(4-len)];
    lev = int2str(demoSET{k,5});
    if nbVAL>5 , par = demoSET{k,6}; else , par = '[]'; end
    libel = ['with  ' wavDum '   at level ' lev '  --->  ' nam];
    action = [beg_call_str ...
              typ ''',''' fil ''',''' wav  ''',' lev ',' par ');'];
    if sepFlag & (k==1) , sep = 'on'; else , sep = 'off'; end
    uimenu(m_demo,'Label',libel,'Separator',sep,'Callback',action);
end
%-----------------------------------------------------------------------------%
function indic_vis_lev = getLevels(level,yDir)

indic_vis_lev = [1:level]';
if yDir==-1 , indic_vis_lev = flipud(indic_vis_lev); end
%-----------------------------------------------------------------------------%
function [det,app,sig] = getFullDecTec(coefs,longs,wname,level)

det  = wrmcoef('d',coefs,longs,wname,[1:level]);
app  = wrcoef('a',coefs,longs,wname,level);
if nargout<3 , return; end
sig  = waverec(coefs,longs,wname);
%-----------------------------------------------------------------------------%
function ylim = getylim(sig)

mini = min(sig);
maxi = max(sig);
dy   = maxi-mini;
tol  = sqrt(eps);
if abs(dy)<tol
    maxi = maxi+tol;
    mini = mini-tol;
end;
ylim = [mini maxi]+0.05*dy*[-1 1];
%-----------------------------------------------------------------------------%
function ll = plotline(axe,x,y,color,tag,ylimplus)

vis = get(axe,'visible');
ll = findobj(axe,'type','line','tag',tag);
if isempty(ll)
     ll = line(...
            'Parent',axe,'Xdata',x,'Ydata',y, ...
            'Color',color,'Visible',vis,'tag',tag);
else
     set(ll,'Xdata',x,'Ydata',y,'Color',color,'Visible',vis,'tag',tag);
end
if nargin<6
    ylim = getylim(y);
else
    ylim = getylim([y(:) ; ylimplus(:)]);
end
set(axe,'Ylim',ylim);
%-----------------------------------------------------------------------------%
function loc = coefsLOC(idx,lev,lf,lx)
%COEFSLOC coefficient location

up  = idx;
low = idx;
for j=1:lev
    low = 2*low+1-lf;
    up  = 2*up;
end
loc = max(1,min(lx,round((low+up)/2)));
%-----------------------------------------------------------------------------%
function h = plotstem(axe,x,y,color,flgzero,tag,ylimplus)
%PLOTSTEM Plot discrete sequence data.

vis = get(axe,'visible');
xAxeColor = get(axe,'xcolor');
q = [min(x) max(x)];
h = NaN*ones(1,4);
h(1) = line(...
              'Xdata',[q(1) q(2)],'Ydata',[0 0],...
              'Parent',axe,'color',xAxeColor ...
              );

indZ = find(abs(y)<eps);
xZ   = x(indZ);
yZ   = y(indZ);
x(indZ) = [];
y(indZ) = [];

n = length(x);
if n>0
    MSize = 3; Mtype = 'o';
    MarkerEdgeColor = color;
    MarkerFaceColor = color;
    xx = [x;x;NaN*ones(size(x))];
    yy = [zeros(1,n);y;NaN*ones(size(y))];
    h(2) = line(...
                  'Xdata',xx(:),'Ydata',yy(:),...
                  'Parent',axe,'LineStyle',...
                  '-','Color',color...
                  );
    h(3) = line(...
                  'Xdata',x,'Ydata',y,...
                  'Parent',axe,...
                  'Marker',Mtype, ...
                  'MarkerEdgeColor',MarkerEdgeColor, ...
                  'MarkerFaceColor',MarkerFaceColor, ...
                  'MarkerSize',MSize, ...
                  'LineStyle','none',...
                  'Color',color ...
                  );
end

nZ = length(xZ);
if flgzero & (nZ>0)
    MSize = 3; Mtype = 'o';
    h(4) = line(...
                  'Xdata',xZ,'Ydata',yZ,...
                  'Parent',axe,...
                  'Marker',Mtype, ...
                  'MarkerEdgeColor',xAxeColor, ...
                  'MarkerFaceColor',xAxeColor, ...
                  'MarkerSize',MSize, ...
                  'LineStyle','none',...
                  'Color',xAxeColor...
                  );
end

set(h(ishandle(h)),'Visible',vis,'tag',tag);
if nargin<7
    ylim = getylim(y);
else
    ylim = getylim([y(:) ; ylimplus(:)]);
end
set(axe,'Ylim',ylim);
%-----------------------------------------------------------------------------%
%=============================================================================%


%=============================================================================%
function [ysig,xsig,coefs,longs] = wedenreg(toolATTR,x,y)
%WEDENREG Density and Regression Estimation.

%== Initialisation ==========================================================%
toolMode  = toolATTR.toolMode;
level     = toolATTR.level;
wname     = toolATTR.wname;
NBClasses = toolATTR.NBClasses;
if nargin<3 , y = ones(size(x)); end
%============================================================================%

%== Traitement sur les couples (Xm,Ym) ======================================%
interpol = 0; % pas d'interpolation.
[sx,sy] = prepxy(toolMode,x,y,NBClasses,interpol);
ind_sx  = find(sx>0);
%============================================================================%

%============================================================================%
% Calcul de la grille en x.
%-------------------------
xmin = min(x);
xmax = max(x);
xsig = [0:NBClasses-1]/(NBClasses-1);
xsig = (xmax-xmin)*xsig+xmin;
%============================================================================%

%============================================================================%
% Normalization & Processed Data.
%-------------------------------
switch toolMode
    case {'denest'}
        ysig = sy;
        delta = xsig(2)-xsig(1);
        integ = sum(ysig)*delta;
        ysig = ysig/integ;
        
    case {'fixreg','storeg'}
        ysig = zeros(size(sx));
        ysig(ind_sx) = sy(ind_sx)./sx(ind_sx);
end

% Decomposition of processed signal.
%-----------------------------------
if nargout>2
    [coefs,longs] = wavedec(ysig,level,wname);
    varargout = {ysig,xsig,coefs,longs};
else
    varargout = {ysig,xsig};
end
%============================================================================%
% INTERNAL FUNCTIONS for WEDENREG
%============================================================================%
%----------------------------------------------------------------------------%
function [sx,sy] = prepxy(option,x,y,NBClasses,interpol)
%PREPXY Traitement des couples (X,Y)
%   
%   [sx,sy] = prepxy(option,x,y,NBClasses,interpol)
%
%   Entrees:
%       option    = 'denest','fixreg','storeg'
%       (x,y)     = couples des donnees (y==1 pour 'estidens') 
%       NBClasses = Nombre de classes de la grille sur [0,1].
%                   La grille sur l'intervalle [0,1] est:
%                   xgrid = [0.5:NBClasses-0.5]/NBClasses
%
%   Sorties:
%       sx = nombre d'element dans chaque classe.
%       sy = somme des elements de chaque classe.
%               (sy == sx pour 'denest' )

%----------------------------------------%
% On change l'intervalle.                %
% On travaille sur l'intervalle [0,1]    %
%----------------------------------------%
xmin  = min(x);
xmax  = max(x);
x     = (x-xmin)/(xmax-xmin);
I1    = find(x==1);
x(I1) = x(I1)-eps;

%----------------------------------------%
% La grille sur l'intervalle [0,1] est : %
% xf = [0.5:NBClasses-0.5]/NBClasses     %
%----------------------------------------%
ex = round(NBClasses*x+0.5); 

%----------------------------------------%
% Recherche des valeurs repetees et      %
% manquantes de ex.                      %
% Calcul des sommes des valeurs de y     %
% pour chaque ex distinct.               %
%----------------------------------------%
lx = length(ex);
sx = full(sum(sparse(1:lx,ex,1,lx,NBClasses)));

switch option
   case 'denest' , sy = sx;
   case 'fixreg' , sy = full(sum(sparse(1:lx,ex,y,lx,NBClasses)));
   case 'storeg'
     sy = full(sum(sparse(1:lx,ex,y,lx,NBClasses)));
     if nargin<5 , return; end

     % PROBLEME DES VALEURS MANQUANTES: interpol = 1;
     %----------------------------------------------
     if interpol
         % Interpolation lineaire pour les trous.
         Ind_0  = find(sx==0);
         Ind_sx = (find(sx>0))';
         for k=1:length(Ind_0)
             Ik = Ind_0(k);
             av = find(Ind_sx<Ik);
             ap = find(Ind_sx>Ik);
             Iav = Ind_sx(av(length(av)));
             Iap = Ind_sx(ap(1));
             sy(Ik) = ( (sy(Iap)*(Ik-Iav))/sx(Iap)+ ...
                        (sy(Iav)*(Iap-Ik))/sx(Iav) )/(Iap-Iav);
             sx(Ik) = 1;
         end
     end
end
%----------------------------------------------------------------------------%
%============================================================================%
