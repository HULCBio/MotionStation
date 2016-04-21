function varargout = imgxtool(option,varargin)
%IMGXTOOL Image extension tool.
%   VARARGOUT = IMGXTOOL(OPTION,VARARGIN)
%
%   GUI oriented tool which allows the construction of a new
%   image from an original one by truncation or extension.
%   Extension is done by selecting different possible modes:
%   Symmetric, Periodic, Zero Padding, Continuous or Smooth.
%   A special mode is provided to extend an image in order 
%   to be accepted by the SWT decomposition.
%------------------------------------------------------------
%   Internal options:
%
%   OPTION = 'create'          'load'             'demo'
%            'update_deslen'   'extend_truncate'
%            'draw'            'save'
%            'clear_graphics'  'mode'
%            'close'
%
%   See also WEXTEND.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-Nov-98.
%   Last Revision: 14-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/03/15 22:40:45 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
default_nbcolors = 255;

% Image Coding Value.
%-------------------
codemat_v = wimgcode('get');

% Initialisations for all options excepted 'create'.
%---------------------------------------------------
switch option

  case 'create'
  
  otherwise
    % Get figure handle.
    %-------------------
    win_imgxtool = varargin{1};

    % Get stored structure.
    %----------------------
    Hdls_UIC_C      = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_C');
    Hdls_UIC_H      = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_H');
    Hdls_UIC_V      = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_V');
    Hdls_UIC_Swt    = wfigmngr('getValue',win_imgxtool,'Hdls_UIC_Swt');
    Hdls_Axes       = wfigmngr('getValue',win_imgxtool,'Hdls_Axes');
    Hdls_Colmap     = wfigmngr('getValue',win_imgxtool,'Hdls_Colmap');
    Pos_Axe_Img_Ori = wfigmngr('getValue',win_imgxtool,'Pos_Axe_Img_Ori');
 
    % Get UIC Handles.
    %-----------------
    [m_load,m_save,m_demo,txt_image,edi_image,...
     txt_mode,pop_mode,pus_extend] = deal(Hdls_UIC_C{:});
 
    [frm_fra_H,txt_fra_H,txt_length_H,edi_length_H,txt_nextpow2_H,  ...
     edi_nextpow2_H,txt_prevpow2_H,edi_prevpow2_H,txt_deslen_H,     ...
     edi_deslen_H,txt_direct_H,pop_direct_H] = deal(Hdls_UIC_H{:});
 
    [frm_fra_V,txt_fra_V,txt_length_V,edi_length_V,txt_nextpow2_V,  ...
     edi_nextpow2_V,txt_prevpow2_V,edi_prevpow2_V,txt_deslen_V,     ...
     edi_deslen_V,txt_direct_V,pop_direct_V] = deal(Hdls_UIC_V{:});
 
    [txt_swtdec,pop_swtdec,frm_fra_H_2,txt_fra_H_2,txt_swtlen_H,    ...
     edi_swtlen_H,txt_swtclen_H,edi_swtclen_H,txt_swtdir_H,         ...
     edi_swtdir_H,txt_swtdec,pop_swtdec,frm_fra_V_2,txt_fra_V_2,    ...
     txt_swtlen_V,edi_swtlen_V,txt_swtclen_V,edi_swtclen_V,         ...
     txt_swtdir_V,edi_swtdir_V] = deal(Hdls_UIC_Swt{:});
end

% Process control depending on the calling option.
%-------------------------------------------------
switch option

    case 'create'
    %-------------------------------------------------------%
    % Option: 'CREATE' - Create Figure, Uicontrols and Axes %
    %-------------------------------------------------------%
	
        % Get Globals.
        %-------------
        [Def_Btn_Height,Def_Btn_Width,Pop_Min_Width,X_Graph_Ratio, ...
        X_Spacing,Y_Spacing,Def_TxtBkColor,Def_EdiBkColor,         ...
        Def_FraBkColor] =                                          ...
                mextglob('get',                                    ...
                'Def_Btn_Height','Def_Btn_Width','Pop_Min_Width',  ...
                'X_Graph_Ratio','X_Spacing','Y_Spacing',           ...
                'Def_TxtBkColor','Def_EdiBkColor','Def_FraBkColor' ...
                );

        % Window initialization.
        %-----------------------
        [win_imgxtool,pos_win,win_units,str_numwin,                ...
        frame0,pos_frame0,Pos_Graphic_Area,pus_close] =            ...
                wfigmngr('create','Image Extension / Truncation',  ...
                         winAttrb,'ExtFig_Tool_3',                 ...
                         strvcat(mfilename,'cond'),1,1,0);
        if nargout>0 , varargout{1} = win_imgxtool; end
		
		% Add Help for Tool.
		%------------------
		wfighelp('addHelpTool',win_imgxtool, ...
			'Two-Dimensional &Extension','IMGX_GUI');

		% Add Help Item.
		%----------------
		wfighelp('addHelpItem',win_imgxtool,...
			'Dealing with Border Distortion','BORDER_DIST');

        % Menu construction for current figure.
        %--------------------------------------
        m_files = wfigmngr('getmenus',win_imgxtool,'file');
        m_load  = uimenu(m_files, ...
                         'Label','&Load Image',                    ...
                         'Position',1,                             ...
                         'Callback',                               ...
                         [mfilename '(''load'',' str_numwin ');']  ...
                         );

        m_save  = uimenu(m_files,...
                         'Label','&Save Transformed Image',       ...
                         'Position',2,                            ...
                         'Enable','Off',                          ...
                         'Callback',                              ...
                         [mfilename '(''save'',' str_numwin ');'] ...
                         );

        m_demo  = uimenu(m_files, ...
                         'Label','&Example Extension','Position',3);

        demoSET = {...
         'woman2'  , 'ext'   , '{''zpd'' , [220,200] , ''both'' , ''both''}' ; ...
         'woman2'  , 'trunc' , '{''nul'' , [ 96, 96] , ''both'' , ''both''}' ; ...
         'wbarb'   , 'ext'   , '{''sym'' , [512,200] , ''right'', ''both''}' ; ...
         'noiswom' , 'ext'   , '{''sym'' , [512,512] , ''right'', ''down''}' ; ...
         'noiswom' , 'ext'   , '{''ppd'' , [512,512] , ''right'', ''down''}' ; ...
         'wbarb'   , 'ext'   , '{''sym'' , [512,512] , ''both'' , ''both''}' ; ...
         'facets'  , 'ext'   , '{''ppd'' , [512,512] , ''both'' , ''both''}' ; ...
         'mandel'  , 'ext'   , '{''sym'' , [512,512] , ''left'' , ''both''}'   ...
         };
        nbDEM = size(demoSET,1);
        beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
		
		dummy = demoSET(:,1);
		names = strvcat(dummy{:});
		tab   = setstr(9);
        for k = 1:nbDEM
            typ = demoSET{k,2};
            fil = demoSET{k,1};
            par = demoSET{k,3};
            parVal = eval(par);

            switch parVal{1}
              case 'swt'
                lenSTR = [' - level: ',int2str(parVal{2})];
              otherwise
                siz = fliplr(parVal{2}); 
                lenSTR = [' - size: [' , int2str(parVal{2}) , ']'];
            end
            strPAR = ['mode: ' ,  parVal{1} , lenSTR, ...
                      ' - direction: [', parVal{3} , ',' parVal{4} ,']'];
            switch  typ
              case 'ext'   , strTYPE = ['Extension  - '];
              case 'trunc' , strTYPE = ['Truncation - '];
            end
            libel = [names(k,:) tab '  -  ' strTYPE strPAR];
            action = [beg_call_str fil  ''',''' typ ''',' par ');'];
            uimenu(m_demo,'Label',libel,'Callback',action);
        end


        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,'Wait ... initialization');

        % Borders and double borders.
        %----------------------------
        dx = X_Spacing; dx2 = 2*dx;
        dy = Y_Spacing; dy2 = 2*dy;

        % General graphical parameters initialization.
        %--------------------------------------------
        x_frame0  = pos_frame0(1);
        cmd_width = pos_frame0(3);
        pus_width = cmd_width-4*dx2;
        txt_width = 3*Def_Btn_Width/2;
        edi_width = 3*Def_Btn_Width/4;
        pop_width = 7*Def_Btn_Width/4;
        bdx       = 0.08*pos_win(3);
        bdy       = 0.06*pos_win(4);
        ecy       = 0.03*pos_win(4);
        x_graph   = bdx;
        y_graph   = 2*Def_Btn_Height+dy;
        h_graph   = pos_frame0(4)-y_graph;
        w_graph   = pos_frame0(1);

        % Command part of the window.
        %============================

        % Position property of objects.
        %------------------------------
        xlocINI            = [x_frame0 cmd_width];
        ybottomINI         = pos_win(4)-dy2;
        x_left_INI         = x_frame0+dx2+dx;

        x_left             = x_left_INI;
        y_low              = ybottomINI-(Def_Btn_Height+1*dy2);
        pos_txt_image      = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+3*dx;
        pos_edi_image      = [x_left, y_low+dy/2, 2*edi_width, ...
                               Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-1.5*(Def_Btn_Height+2*dy2);
        pos_txt_length_H   = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_length_H   = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_nextpow2_H = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_nextpow2_H = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_prevpow2_H = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_prevpow2_H = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_deslen_H   = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_deslen_H   = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_direct_H   = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_pop_direct_H   = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        fra_left           = x_left_INI-dx2;
        fra_low            = y_low-dy;
        fra_width          = cmd_width-dx2;
        fra_heigth         = 5*(Def_Btn_Height+1*dy2)+dy2;
        pos_fra_H          = [fra_left, fra_low, fra_width, fra_heigth];
        txt_fra_H_heigth   = 3 * Def_Btn_Height / 4;
        txt_fra_H_width    = Def_Btn_Width;
        txt_fra_H_low      = (fra_low + fra_heigth) - (txt_fra_H_heigth / 2);
        txt_fra_H_left     = fra_left + (fra_width - txt_fra_H_width) / 2;
        pos_txt_fra_H      = [txt_fra_H_left, txt_fra_H_low, ...
                               txt_fra_H_width, txt_fra_H_heigth];
 
        x_left             = x_left_INI;
        y_low              = fra_low-1.5*(Def_Btn_Height+2*dy2);
        pos_txt_length_V   = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_length_V   = [x_left, y_low+dy, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_nextpow2_V = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_nextpow2_V = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_prevpow2_V = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_prevpow2_V = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_deslen_V   = [x_left, y_low, txt_width Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_deslen_V   = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];

        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+1*dy2);
        pos_txt_direct_V   = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_pop_direct_V   = [x_left, y_low+dy/2, edi_width , Def_Btn_Height];
 
        fra_left           = x_left_INI-dx2;
        fra_low            = y_low-dy;
        fra_width          = cmd_width-dx2;
        fra_heigth         = 5*(Def_Btn_Height+1*dy2)+dy2;
        pos_fra_V          = [fra_left, fra_low, fra_width, fra_heigth];
        txt_fra_V_heigth   = 3 * Def_Btn_Height / 4;
        txt_fra_V_width    = Def_Btn_Width;
        txt_fra_V_low      = (fra_low + fra_heigth) - (txt_fra_V_heigth / 2);
        txt_fra_V_left     = fra_left + (fra_width - txt_fra_V_width) / 2;
        pos_txt_fra_V      = [txt_fra_V_left, txt_fra_V_low, ...
                               txt_fra_V_width, txt_fra_V_heigth];

        x_left             = x_left_INI-dx2+(cmd_width-3*txt_width/4)/2;
        y_low              = fra_low-(Def_Btn_Height+1*dy2);
        pos_txt_mode       = [x_left, y_low, txt_width Def_Btn_Height];
 
        x_left             = x_left_INI+dx2;
        y_low              = y_low-(Def_Btn_Height+dy);
        pos_pop_mode       = [x_left, y_low, pus_width , Def_Btn_Height];

        x_left             = x_left_INI+dx2;
        y_low              = y_low-2*Def_Btn_Height-dy;
        pos_pus_extend     = [x_left, y_low, pus_width , 1.5*Def_Btn_Height];

        pos_fra_H_2        = pos_fra_H;
        pos_fra_H_2(2)     = pos_fra_H(2)-Def_Btn_Height;
        pos_fra_H_2(4)     = 3*(Def_Btn_Height+2*dy2)+dy;

        txt_fra_H_heigth   = 3 * Def_Btn_Height / 4;
        txt_fra_H_width    = Def_Btn_Width;
        txt_fra_H_low      = (pos_fra_H_2(2)+pos_fra_H_2(4))-               ...
                             (txt_fra_H_heigth / 2);
        txt_fra_H_left     = pos_fra_H_2(1)+(pos_fra_H_2(3)-txt_fra_H_width)...
                             / 2;
        pos_txt_fra_H_2    = [txt_fra_H_left, txt_fra_H_low, ...
                               txt_fra_H_width, txt_fra_H_heigth];
 
        x_left             = x_left_INI-dx2;
        y_low              = pos_fra_H_2(2)+pos_fra_H_2(4)+3*dy2;
        pos_txt_swtdec     = [x_left, y_low, 3*txt_width/2, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx+dx2;
        pos_pop_swtdec     = [x_left, y_low+dy, edi_width, Def_Btn_Height];
 
        x_left             = x_left_INI;
        y_low              = pos_fra_H_2(2)+pos_fra_H_2(4)-(Def_Btn_Height+ ...
                             2*dy2);
        pos_txt_swtlen_H   = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_swtlen_H   = [x_left, y_low+dy, edi_width, Def_Btn_Height];
 
        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+2*dy2);
        pos_txt_swtclen_H  = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_swtclen_H  = [x_left, y_low+dy, edi_width, Def_Btn_Height];
 
        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+2*dy2);
        pos_txt_swtdir_H   = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_swtdir_H   = [x_left, y_low+dy, edi_width, Def_Btn_Height];
 
        pos_fra_V_2        = pos_fra_V;
        pos_fra_V_2(4)     = 3*(Def_Btn_Height+2*dy2)+dy;

        txt_fra_V_heigth   = 3 * Def_Btn_Height / 4;
        txt_fra_V_width    = Def_Btn_Width;
        txt_fra_V_low      = (pos_fra_V_2(2)+pos_fra_V_2(4))-               ...
                             (txt_fra_V_heigth / 2);
        txt_fra_V_left     = pos_fra_V_2(1)+(pos_fra_V_2(3)-txt_fra_V_width)...
                             / 2;
        pos_txt_fra_V_2    = [txt_fra_V_left, txt_fra_V_low, ...
                               txt_fra_V_width, txt_fra_V_heigth];
 
        x_left             = x_left_INI;
        y_low              = pos_fra_V_2(2)+pos_fra_V_2(4)-(Def_Btn_Height+ ...
                             2*dy2);
        pos_txt_swtlen_V   = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_swtlen_V   = [x_left, y_low+dy, edi_width, Def_Btn_Height];
 
        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+2*dy2);
        pos_txt_swtclen_V  = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_swtclen_V  = [x_left, y_low+dy, edi_width, Def_Btn_Height];
 
        x_left             = x_left_INI;
        y_low              = y_low-(Def_Btn_Height+2*dy2);
        pos_txt_swtdir_V   = [x_left, y_low, txt_width, Def_Btn_Height];
        x_left             = x_left+txt_width/2+edi_width+3*dx;
        pos_edi_swtdir_V   = [x_left, y_low+dy, edi_width, Def_Btn_Height];

        % String property of objects.
        %----------------------------
        str_txt_image    = 'Image';
        str_edi_image    = '';
        str_txt_length   = 'Length';
        str_edi_length   = '';
        str_txt_nextpow2 = 'Next Power of 2';
        str_edi_nextpow2 = '';
        str_txt_prevpow2 = 'Previous Power of 2';
        str_edi_prevpow2 = '';
        str_txt_deslen   = 'Desired Length';
        str_edi_deslen   = '';
        str_txt_direct   = 'Direction to extend';
        str_pop_direct_H = [ 'Both ' ; 'Left ' ; 'Right'];
        str_pop_direct_V = [ 'Both ' ; 'Up   ' ; 'Down '];
        str_txt_fra_H    = 'Horizontal';
        str_txt_fra_H_2  = 'Horizontal';
        str_txt_fra_V    = 'Vertical';
        str_txt_fra_V_2  = 'Vertical';
        str_txt_mode     = 'Extension Mode';
        str_pop_mode     = strvcat(...
                            'Symmetric (Half-Point)', ...
                            'Symmetric (Whole-Point)', ...
                            'Antisymmetric (Half-Point)', ...
                            'Antisymmetric (Whole-Point)', ...                            
                            'Periodic', ... 
                            'Zero Padding', ... 
                            'Continuous', ... 
                            'Smooth', ... 
                            'For SWT'  ... 
                            );
        str_pus_extend    = 'Extend';
        str_txt_swtdec    = 'SWT Decomposition Level';
        str_pop_swtdec    = num2str((1:10)');
        str_txt_swtlen_H  = 'Length';
        str_edi_swtlen_H  = '';
        str_txt_swtclen_H = 'Computed Length';
        str_edi_swtclen_H = '';
        str_txt_swtdir_H  = 'Direction to extend';
        str_edi_swtdir_H  = 'Right';
        str_tip_swtclen_H = strvcat(['Minimal length of the ',     ...
                                     'periodic extended signal ',  ...
                                     'for SWT decomposition']);
        str_tip_swtclen_V = str_tip_swtclen_H;
        str_txt_swtlen_V  = 'Length';
        str_edi_swtlen_V  = '';
        str_txt_swtclen_V = 'Computed Length';
        str_edi_swtclen_V = '';
        str_txt_swtdir_V  = 'Direction to extend';
        str_edi_swtdir_V  = 'Down';
 
        % Construction of uicontrols.
        %----------------------------
        commonProp = {...
                      'Parent',win_imgxtool, ...
                      'Unit',win_units,      ...
                      'Visible','off'        ...
                      };
        comFraProp = {commonProp{:}, ...
                      'BackGroundColor',Def_FraBkColor, ...
                      'Style','frame'                   ...
                      };
        comPusProp = {commonProp{:},'Style','Pushbutton'};
        comPopProp = {commonProp{:},'Style','Popupmenu'};
        comTxtProp = {commonProp{:}, ...
                      'ForeGroundColor','k',            ...
                      'BackGroundColor',Def_FraBkColor, ...
                      'HorizontalAlignment','left',     ...
                      'Style','Text'                    ...
                      };
        comEdiProp = {commonProp{:}, ...
                      'ForeGroundColor','k',          ...
                      'HorizontalAlignment','center', ...
                      'Style','Edit'                  ...
                      };
        
        txt_image      = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_image,          ...
                                   'String',str_txt_image             ...
                                   );
        edi_image      = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_image,          ...
                                   'String',str_edi_image,            ...
                                   'BackGroundColor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );

        frm_fra_H      = uicontrol(                                   ...
                                   comFraProp{:},                     ...
                                   'Position',pos_fra_H               ...
                                   );
        txt_fra_H      = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'HorizontalAlignment','center',    ...
                                   'Position',pos_txt_fra_H,          ...
                                   'String',str_txt_fra_H             ...
                                   );
        txt_length_H   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_length_H,       ...
                                   'String',str_txt_length            ...
                                   );
        edi_length_H   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_length_H,       ...
                                   'String',str_edi_length,           ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_nextpow2_H = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_nextpow2_H,     ...
                                   'String',str_txt_nextpow2          ...
                                   );
        edi_nextpow2_H = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_nextpow2_H,     ...
                                   'String',str_edi_nextpow2,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_prevpow2_H = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_prevpow2_H,     ...
                                   'String',str_txt_prevpow2          ...
                                   );
        edi_prevpow2_H = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_prevpow2_H,     ...
                                   'String',str_edi_prevpow2,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_deslen_H   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_deslen_H,       ...
                                   'String',str_txt_deslen            ...
                                   );
        edi_deslen_H   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_deslen_H,       ...
                                   'String',str_edi_deslen,           ...
                                   'Backgroundcolor',Def_EdiBkColor   ...
                                   );
        txt_direct_H   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_direct_H,       ...
                                   'String',str_txt_direct            ...
                                   );
        pop_direct_H   = uicontrol(                                   ...
                                   comPopProp{:},                     ...
                                   'Position',pos_pop_direct_H,       ...
                                   'String',str_pop_direct_H          ...
                                   );

        frm_fra_V      = uicontrol(                                   ...
                                   comFraProp{:},                     ...
                                   'Position',pos_fra_V               ...
                                   );
        txt_fra_V      = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'HorizontalAlignment','center',    ...
                                   'Position',pos_txt_fra_V,          ...
                                   'String',str_txt_fra_V             ...
                                   );
        txt_length_V   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_length_V,       ...
                                   'String',str_txt_length            ...
                                   );
        edi_length_V   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_length_V,       ...
                                   'String',str_edi_length,           ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
 
        txt_nextpow2_V = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_nextpow2_V,     ...
                                   'String',str_txt_nextpow2          ...
                                   );
        edi_nextpow2_V = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_nextpow2_V,     ...
                                   'String',str_edi_nextpow2,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_prevpow2_V = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_prevpow2_V,     ...
                                   'String',str_txt_prevpow2          ...
                                   );
        edi_prevpow2_V = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_prevpow2_V,     ...
                                   'String',str_edi_prevpow2,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                );
        txt_deslen_V   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_deslen_V,       ...
                                   'String',str_txt_deslen            ...
                                   );
        edi_deslen_V   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_deslen_V,       ...
                                   'String',str_edi_deslen,           ...
                                   'Backgroundcolor',Def_EdiBkColor   ...
                                   );
        txt_direct_V   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_direct_V,       ...
                                   'String',str_txt_direct            ...
                                   );
        pop_direct_V   = uicontrol(                                   ...
                                   comPopProp{:},                     ...
                                   'Position',pos_pop_direct_V,       ...
                                   'String',str_pop_direct_V          ...
                                   );

        txt_mode       = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_mode,           ...
                                   'String',str_txt_mode              ...
                                   );
        pop_mode       = uicontrol(                                   ...
                                   comPopProp{:},                     ...
                                   'Position',pos_pop_mode,           ...
                                   'String',str_pop_mode              ...
                                   );
        pus_extend     = uicontrol(                                   ...
                                   comPusProp{:},                     ...
                                   'Position',pos_pus_extend,         ...
                                   'String',xlate(str_pus_extend),           ...
                                   'Interruptible','On'               ...
                                   );

        txt_swtdec     = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_swtdec,         ...
                                   'String',str_txt_swtdec            ...
                                   );
        pop_swtdec     = uicontrol(                                   ...
                                   comPopProp{:},                     ...
                                   'Position',pos_pop_swtdec,         ...
                                   'String',str_pop_swtdec            ...
                                   );
        frm_fra_H_2    = uicontrol(                                   ...
                                   comFraProp{:},                     ...
                                   'Position',pos_fra_H_2             ...
                                   );
        txt_fra_H_2    = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'HorizontalAlignment','center',    ...
                                   'Position',pos_txt_fra_H_2,        ...
                                   'String',str_txt_fra_H_2           ...
                                   );
        txt_swtlen_H   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_swtlen_H,       ...
                                   'String',str_txt_swtlen_H          ...
                                   );
        edi_swtlen_H   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_swtlen_H,       ...
                                   'String',str_edi_swtlen_H,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_swtclen_H  = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_swtclen_H,      ...
                                   'ToolTipString',str_tip_swtclen_H, ...
                                   'String',str_txt_swtclen_H         ...
                                   );
        edi_swtclen_H  = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_swtclen_H,      ...
                                   'String',str_edi_swtclen_H,        ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_swtdir_H   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_swtdir_H,       ...
                                   'String',str_txt_swtdir_H          ...
                                   );
        edi_swtdir_H   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_swtdir_H,       ...
                                   'String',str_edi_swtdir_H,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        frm_fra_V_2    = uicontrol(                                   ...
                                   comFraProp{:},                     ...
                                   'Position',pos_fra_V_2             ...
                                   );
        txt_fra_V_2    = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'HorizontalAlignment','center',    ...
                                   'Position',pos_txt_fra_V_2,        ...
                                   'String',str_txt_fra_V_2           ...
                                   );
        txt_swtlen_V   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_swtlen_V,       ...
                                   'String',str_txt_swtlen_V          ...
                                   );
        edi_swtlen_V   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_swtlen_V,       ...
                                   'String',str_edi_swtlen_V,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_swtclen_V  = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_swtclen_V,      ...
                                   'ToolTipString',str_tip_swtclen_V, ...
                                   'String',str_txt_swtclen_V         ...
                                   );
        edi_swtclen_V  = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_swtclen_V,      ...
                                   'String',str_edi_swtclen_V,        ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
        txt_swtdir_V   = uicontrol(                                   ...
                                   comTxtProp{:},                     ...
                                   'Position',pos_txt_swtdir_V,       ...
                                   'String',str_txt_swtdir_V          ...
                                   );
        edi_swtdir_V   = uicontrol(                                   ...
                                   comEdiProp{:},                     ...
                                   'Position',pos_edi_swtdir_V,       ...
                                   'String',str_edi_swtdir_V,         ...
                                   'Backgroundcolor',Def_FraBkColor,  ...
                                   'Enable','Inactive'                ...
                                   );
                             
        % Callback property of objects.
        %------------------------------
        str_win_imgxtool = num2mstr(win_imgxtool);
        str_edi_deslen_H = num2mstr(edi_deslen_H);
        str_pop_direct_H = num2mstr(pop_direct_H);
        str_edi_deslen_V = num2mstr(edi_deslen_V);
        str_pop_direct_V = num2mstr(pop_direct_V);
        str_pop_mode 	 = num2mstr(pop_mode);
        str_pus_extend 	 = num2mstr(pus_extend);
        cba_edi_deslen_H = [mfilename '(''update_deslen'','   ...
                                 str_win_imgxtool             ...
                                 ',''H'');'];
        cba_edi_deslen_V = [mfilename '(''update_deslen'','   ...
                                 str_win_imgxtool             ...
                                 ',''V'');'];
        cba_pop_direct_H = [mfilename '(''clear_GRAPHICS'','  ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pop_direct_V = [mfilename '(''clear_GRAPHICS'','  ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pop_mode 	 = [mfilename '(''mode'','            ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pus_extend 	 = [mfilename '(''extend_truncate'',' ...
                                 str_win_imgxtool             ...
                                 ');'];
        cba_pop_swtdec 	 = [mfilename '(''update_swtdec'','   ...
                                 str_win_imgxtool             ...
                                 ');'];
        set(edi_deslen_H,'Callback',cba_edi_deslen_H);
        set(pop_direct_H,'Callback',cba_pop_direct_H);
        set(edi_deslen_V,'Callback',cba_edi_deslen_V);
        set(pop_direct_V,'Callback',cba_pop_direct_V);
        set(pop_mode,'Callback',cba_pop_mode);
        set(pus_extend,'Callback',cba_pus_extend);
        set(pop_swtdec,'Callback',cba_pop_swtdec);
        
        % Graphic part of the window.
        %============================

        % Axes Construction.
        %-------------------
        commonProp  = {...
                       'Parent',win_imgxtool,           ...
                       'Visible','off',                 ...
                       'Units','pixels',                ...
                       'XTicklabelMode','manual',       ...
                       'YTicklabelMode','manual',       ...
                       'XTicklabel',[],'YTicklabel',[], ...
                       'XTick',[],'YTick',[],           ...
                       'Box','On'                       ...
                       };

        % Image Axes construction.
        %--------------------------
        x_left      = x_graph;
        x_wide      = w_graph-2*x_left;
        y_low       = y_graph+2*bdy;
        y_height    = h_graph-y_low-2*bdy;
        Pos_Axe_Img = [x_left, y_low, x_wide, y_height];
        Axe_Img     = axes( commonProp{:},         ...
                            'Ydir','Reverse',      ...
                            'Position',Pos_Axe_Img ...
                            );

        % Legend Axes construction.
        %--------------------------
        X_Leg = Pos_Axe_Img(1);
        Y_Leg = Pos_Axe_Img(2) + 11*Pos_Axe_Img(4)/10;
        W_Leg = (Pos_Axe_Img(3) - Pos_Axe_Img(1)) / 2.5;
        H_Leg = (Pos_Axe_Img(4) - Pos_Axe_Img(2)) / 4;
        Pos_Axe_Leg = [X_Leg Y_Leg W_Leg H_Leg];
        ud.dynvzaxe.enable = 'Off';
        Axe_Leg = axes(commonProp{:},          ...
                       'Position',Pos_Axe_Leg, ...
                       'Xlim',[0 180],         ...
                       'Ylim',[0 20],          ...
                       'Drawmode','fast',      ...
                       'userdata',ud           ...
                       );
        L1 = line(                           ...
                  'Parent',Axe_Leg,          ...
                  'Xdata',11:30,             ...
                  'Ydata',ones(1,20)*14,     ...
                  'LineWidth',3,             ...
                  'Visible','off',           ...
                  'Color','yellow'           ...
                  );
        L2 = line(                           ...
                  'Parent',Axe_Leg,          ...
                  'Xdata',11:30,             ...
                  'Ydata',ones(1,20)*7,      ...
                  'LineWidth',3,             ...
                  'Visible','off',           ...
                  'Color','red'              ...
                  );
        T1 = text(40,14,xlate('Transformed image'), ...
                  'Parent',Axe_Leg,          ...
                  'FontWeight','bold',       ...
                  'Visible','off'            ...
                  );
        T2 = text(40,7,xlate('Original image'),     ...
                  'Parent',Axe_Leg,          ...
                  'FontWeight','bold',       ...
                  'Visible','off'            ...
                  );

        % Adding colormap GUI.
        %---------------------
        [Hdls_Colmap1,Hdls_Colmap2] = utcolmap('create',win_imgxtool, ...
                 'xloc',xlocINI,'bkcolor',Def_FraBkColor);
        Hdls_Colmap = [Hdls_Colmap1 Hdls_Colmap2];
        set(Hdls_Colmap,'visible','off');

        % Setting units to normalized.
        %-----------------------------
        wfigmngr('normalize',win_imgxtool);

        % Store values.
        %--------------
        Hdls_UIC_C  = {...
                       m_load,m_save,m_demo,...
                       txt_image,edi_image,  ...
                       txt_mode,pop_mode,pus_extend ...
                       };
        Hdls_UIC_H  = {...
                       frm_fra_H,txt_fra_H,           ...
                       txt_length_H,edi_length_H,     ...
                       txt_nextpow2_H,edi_nextpow2_H, ...
                       txt_prevpow2_H,edi_prevpow2_H, ...
                       txt_deslen_H,edi_deslen_H,     ...
                       txt_direct_H,pop_direct_H      ...
                       };
        Hdls_UIC_V  = {...
                       frm_fra_V,txt_fra_V,           ...
                       txt_length_V,edi_length_V,     ...
                       txt_nextpow2_V,edi_nextpow2_V, ...
                       txt_prevpow2_V,edi_prevpow2_V, ...
                       txt_deslen_V,edi_deslen_V,     ...
                       txt_direct_V,pop_direct_V      ...
                       };

        Hdls_UIC_Swt = {...
                       txt_swtdec,pop_swtdec,       ...
                       frm_fra_H_2,txt_fra_H_2,     ...
                       txt_swtlen_H,edi_swtlen_H,   ...
                       txt_swtclen_H,edi_swtclen_H, ...
                       txt_swtdir_H,edi_swtdir_H,   ...
                       txt_swtdec,pop_swtdec,       ...
                       frm_fra_V_2,txt_fra_V_2,     ...
                       txt_swtlen_V,edi_swtlen_V,   ...
                       txt_swtclen_V,edi_swtclen_V, ...
                       txt_swtdir_V,edi_swtdir_V    ...
                       };
 
        Hdls_Axes    = struct('Axe_Img',Axe_Img,'Axe_Leg',Axe_Leg);

        Pos_Axe_Img_Ori = get(Axe_Img,'Position');

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_BORDER_DIST = [txt_mode,pop_mode];
		wfighelp('add_ContextMenu',win_imgxtool,...
			hdl_BORDER_DIST,'BORDER_DIST');
		%-------------------------------------
        
		% Store handles and values.
        %--------------------------		
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_C',Hdls_UIC_C);
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_H',Hdls_UIC_H);
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_V',Hdls_UIC_V);
        wfigmngr('storeValue',win_imgxtool,'Hdls_UIC_Swt',Hdls_UIC_Swt);
        wfigmngr('storeValue',win_imgxtool,'Hdls_Axes',Hdls_Axes);
        wfigmngr('storeValue',win_imgxtool,'Hdls_Colmap',Hdls_Colmap);
        wfigmngr('storeValue',win_imgxtool,'Pos_Axe_Img_Ori',Pos_Axe_Img_Ori);

        % End waiting.
        %---------------
        wwaiting('off',win_imgxtool);

    case 'load'
    %------------------------------------------%
    % Option: 'LOAD' - Load the original image %
    %------------------------------------------%

        % Loading file.
        %--------------
        if length(varargin)<2  % LOAD Option
            imgFileType = ['*.mat;*.bmp;*.hdf;*.jpg;' ...
                    '*.jpeg;*.pcx;*.tif;*.tiff;*.gif'];
            [imgInfos,Anal_Image,map,ok] = ...
                utguidiv('load_img',win_imgxtool,imgFileType, ...
                'Load Image',default_nbcolors);
        else
            img_Name = deblank(varargin{2});
            filename = [img_Name '.mat'];
            pathname = utguidiv('WTB_DemoPath',filename);
            [imgInfos,Anal_Image,map,ok] = ...
                utguidiv('load_dem2D',win_imgxtool,pathname,filename,default_nbcolors);
        end
        if ~ok, return; end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,'Wait ... loading');

        % Cleaning.
        %----------
        imgxtool('clear_GRAPHICS',win_imgxtool,'load');

        % Disable save menu.
        %-------------------
        set(m_save,'Enable','off');

        % Compute UIC values.
        %--------------------
        H           = imgInfos.size(1);
        V           = imgInfos.size(2);
        pow_H       = fix(log(H)/log(2));
        Next_Pow2_H = 2^(pow_H+1);
        if isequal(2^pow_H,H)
            Prev_Pow2_H = 2^(pow_H-1);
            swtpow_H    = pow_H;
        else
            Prev_Pow2_H = 2^pow_H;
            swtpow_H    = pow_H+1;
        end
        pow_V       = fix(log(V)/log(2));
        Next_Pow2_V = 2^(pow_V+1);
        if isequal(2^pow_V,V)
            Prev_Pow2_V   = 2^(pow_V-1);
            swtpow_V    = pow_V;
        else
            Prev_Pow2_V   = 2^pow_V;
            swtpow_V    = pow_V+1;
        end
        
        % Compute the max level value for SWT.
        %-------------------------------------
        Max_Lev = min(swtpow_H,swtpow_V);
                
        % Compute the default level for SWT .
        %-----------------------------------
        def_pow = 1;
        if ~rem(H,2)
            while ~rem(H,2^def_pow), def_pow = def_pow + 1; end
            def_level_H = def_pow-1;
        else
            def_level_H = def_pow;
        end
        
        def_pow = 1;
        if ~rem(V,2)
            while ~rem(V,2^def_pow), def_pow = def_pow + 1; end
            def_level_V = def_pow-1;
        else
            def_level_V = def_pow;
        end
        Def_Lev = min(max(def_level_H,def_level_V),Max_Lev);
        
        % Compute the extended lengths for SWT.
        %--------------------------------------
        C_Length_H = H;
        while rem(C_Length_H,2^def_level_H), C_Length_H = C_Length_H + 1; end
        C_Length_V = V;
        while rem(C_Length_V,2^def_level_V), C_Length_V = C_Length_V + 1; end
        
        % Set UIC values.
        %----------------
        set(edi_image,'String',imgInfos.name);
        set(edi_length_H,'String',sprintf('%.0f',H));
        set(edi_nextpow2_H,'String',sprintf('%.0f',Next_Pow2_H));
        set(edi_prevpow2_H,'String',sprintf('%.0f',Prev_Pow2_H));
        set(edi_deslen_H,'String',sprintf('%.0f',Next_Pow2_H));
        set(pop_direct_H,'Value',1);
        set(edi_length_V,'String',sprintf('%.0f',V));
        set(edi_nextpow2_V,'String',sprintf('%.0f',Next_Pow2_V));
        set(edi_prevpow2_V,'String',sprintf('%.0f',Prev_Pow2_V));
        set(edi_deslen_V,'String',sprintf('%.0f',Next_Pow2_V));
        set(pop_direct_V,'Value',1);
        set(pop_mode,'Value',1);
        set(pus_extend,'String',xlate('Extend'));
        set(pus_extend,'Enable','On');
        set(pop_swtdec,'String',num2str((1:Max_Lev)'));
        set(pop_swtdec,'Value',Def_Lev);
        set(edi_swtlen_H,'String',sprintf('%.0f',H));
        set(edi_swtlen_V,'String',sprintf('%.0f',V));        
        set(edi_swtclen_H,'String',sprintf('%.0f',C_Length_H));
        set(edi_swtclen_V,'String',sprintf('%.0f',C_Length_V));        
                
        % Set UIC visible on.
        %--------------------
        set(cat(1,Hdls_UIC_H{:}),'visible','on')
        set(cat(1,Hdls_UIC_V{:}),'visible','on')
        set(cat(1,Hdls_UIC_Swt{:}),'visible','off')
        set(cat(1,Hdls_UIC_C{4:end}),'visible','on')

        % Setting Colormap.
        %------------------
        maxVal   = max(max(Anal_Image));
        nbcolors = round(max([2,min([maxVal,default_nbcolors])]));
        cbcolmap('set',win_imgxtool,'pal',{'pink',nbcolors});
        set(Hdls_Colmap,'Visible','on');
        set(Hdls_Colmap,'Enable','on');

        % Get Axes Handles.
        %------------------
        Axe_Img =  Hdls_Axes.Axe_Img ;

        % Drawing.
        %---------
        NB_ColorsInPal = default_nbcolors;
        Anal_Image     = wimgcode('cod',0,Anal_Image,NB_ColorsInPal,codemat_v);
        Img_Ori        = image(                ...
                           'parent',Axe_Img,   ...
                           'Xdata',[1,H],      ...
                           'Ydata',[1,V],      ...
                           'Cdata',Anal_Image, ...
                           'Visible','on'      ...
                           );
        [w,h]          = wpropimg([H V],Pos_Axe_Img_Ori(3),Pos_Axe_Img_Ori(4));
        Pos_Axe_Img    = Pos_Axe_Img_Ori;
        Pos_Axe_Img(1) = Pos_Axe_Img(1)+abs(Pos_Axe_Img(3)-w)/2;
        Pos_Axe_Img(2) = Pos_Axe_Img(2)+abs(Pos_Axe_Img(4)-h)/2;
        Pos_Axe_Img(3) = w;
        Pos_Axe_Img(4) = h;
        set(Axe_Img,                ...
            'Xlim',[1,H],           ...
            'Ylim',[1,V],           ...
            'Position',Pos_Axe_Img, ...
            'Visible','on');
        set(get(Axe_Img,'title'),'string',xlate('Original Image'));

        % Store values.
        %--------------
        wfigmngr('storeValue',win_imgxtool,'Anal_Image',Anal_Image);
        wfigmngr('storeValue',win_imgxtool,'Pos_Axe_Img_Bas',Pos_Axe_Img);

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngr('storeValue',win_imgxtool,'File_Save_Flag',File_Save_Flag);
        
        % Dynvtool Attachement.
        %----------------------
        dynvtool('init',win_imgxtool,[],Axe_Img,[],[1 1],'','','');

        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);

    case 'demo'
        imgxtool('load',varargin{:});
        Signal_Name  = deblank(varargin{2});
        ext_OR_trunc = varargin{3};
        if length(varargin)>3  & ~isempty(varargin{4})
            par_Demo = varargin{4};
        else
            return;
        end
        extMode  = par_Demo{1};
        lenSIG   = par_Demo{2};
        direct_H = lower(par_Demo{3});
        direct_V = lower(par_Demo{4});
        if ~isequal(extMode,'swt')
            set(edi_deslen_H,'String',sprintf('%.0f',lenSIG(1)));
            imgxtool('update_deslen',win_imgxtool,'H','noClear');
            set(edi_deslen_V,'String',sprintf('%.0f',lenSIG(2)));
            imgxtool('update_deslen',win_imgxtool,'V','noClear');
        else
            set(pop_swtdec,'Value',lenSIG)
            imgxtool('update_swtdec',win_imgxtool)
        end
        switch direct_H
          case 'both'  , direct = 1;
          case 'left'  , direct = 2;
          case 'right' , direct = 3;
        end
        set(pop_direct_H,'Value',direct);
        switch direct_V
          case 'both' , direct = 1;
          case 'up'   , direct = 2;
          case 'down' , direct = 3;
        end
        set(pop_direct_V,'Value',direct);
        switch ext_OR_trunc
          case 'ext'
            switch extMode
              case 'sym' ,         extVal = 1;
              case 'ppd' ,         extVal = 5;
              case 'zpd' ,         extVal = 6;
              case 'sp0' ,         extVal = 7;
              case {'sp1','spd'} , extVal = 8;
              case 'swt' ,         extVal = 9;
            end
            set(pop_mode,'Value',extVal);
            imgxtool('mode',win_imgxtool,'noClear')

          case 'trunc'
        end
        imgxtool('extend_truncate',win_imgxtool);

    case 'update_swtdec'
    %----------------------------------------------------------------------%
    % Option: 'UPDATE_SWTDEC' - Update values when using popup in SWT case %
    %----------------------------------------------------------------------%        
        % Update the computed length.
        %----------------------------
        Image_Length_H = wstr2num(get(edi_swtlen_H,'String'));
        Image_Length_V = wstr2num(get(edi_swtlen_V,'String'));
        Level          = get(pop_swtdec,'Value');
        remLen_H       = rem(Image_Length_H,2^Level);
        remLen_V       = rem(Image_Length_V,2^Level);
        if remLen_H>0
            C_Length_H = Image_Length_H + 2^Level-remLen_H;
        else
            C_Length_H = Image_Length_H;
        end
        if remLen_V>0
            C_Length_V = Image_Length_V + 2^Level-remLen_V;
        else
            C_Length_V = Image_Length_V;
        end
        set(edi_swtclen_H,'String',sprintf('%.0f',C_Length_H));
        set(edi_swtclen_V,'String',sprintf('%.0f',C_Length_V));
        
        % Enabling Extend button.
        %------------------------        
        set(pus_extend,'String',xlate('Extend'),'Enable','on');

    case 'update_deslen'
    %--------------------------------------------------------------------------%
    % Option: 'UPDATE_DESLEN' - Update values when changing the Desired Length %
    %--------------------------------------------------------------------------%
		
        % Get arguments.
        %---------------
        Direction = varargin{2};

        % Cleaning.
        %----------
        if nargin<4 , imgxtool('clear_GRAPHICS',win_imgxtool); end

        % Get Common UIC Handles.
        %------------------------	
        Image_length_H   = wstr2num(get(edi_length_H,'String'));
        Desired_length_H = wstr2num(get(edi_deslen_H,'String'));
        Image_length_V   = wstr2num(get(edi_length_V,'String'));
        Desired_length_V = wstr2num(get(edi_deslen_V,'String'));
        uic_mode         = [txt_mode;pop_mode];
        switch Direction
          case 'H'
            % Update UIC values.
            %-------------------
            if      isempty(Desired_length_H) | Desired_length_H < 2
                    set(edi_deslen_H,'String',get(edi_nextpow2_H,'String'));
                    set(txt_direct_H,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'),'Enable','on');
            elseif  Image_length_H <= Desired_length_H
                    set(txt_direct_H,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'));
            elseif  Image_length_H > Desired_length_H
                    set(txt_direct_H,'String','Direction to truncate');
                    set(pus_extend,'String',xlate('Truncate'));
            end

          case 'V'
            % Update UIC values.
            %-------------------
            if      isempty(Desired_length_V) | Desired_length_V < 2
                    set(edi_deslen_V,'String',get(edi_nextpow2_V,'String'));
                    set(txt_direct_V,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'));
            elseif  Image_length_V <= Desired_length_V
                    set(txt_direct_V,'String','Direction to extend');
                    set(pus_extend,'String',xlate('Extend'));
            elseif  Image_length_V > Desired_length_V
                    set(txt_direct_V,'String','Direction to truncate');
                    set(pus_extend,'String',xlate('Truncate'));
            end

          otherwise
            errargt(mfilename,'Unknown Action','msg');
            error('*');
        end
        set(uic_mode,'Enable','on');
        set(pus_extend,'Enable','on');                                
        if     	isequal(Image_length_H,Desired_length_H) & ...
                isequal(Image_length_V,Desired_length_V)
                set(txt_direct_V,'String','Direction to extend');
                set(txt_direct_H,'String','Direction to extend');
                set(uic_mode,'Enable','off');
                set(pus_extend,'Enable','off');                        
        elseif  ((Image_length_H <= Desired_length_H)  & ...
                 (Image_length_V <  Desired_length_V)) | ...
                ((Image_length_H <  Desired_length_H)  & ...
                 (Image_length_V <= Desired_length_V))                
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',xlate('Extend'));
        elseif  (Image_length_H <= Desired_length_H) & ...
                (Image_length_V > Desired_length_V)
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',xlate('Extend / Truncate'));
        elseif  (Image_length_H > Desired_length_H) & ...
                (Image_length_V <= Desired_length_V)
                set(uic_mode,'Visible','on');
                set(pus_extend,'String',xlate('Truncate / Extend'));
        elseif  (Image_length_H > Desired_length_H) & ...
                (Image_length_V > Desired_length_V)
                set(uic_mode,'Visible','off');
                set(pus_extend,'String',xlate('Truncate'));
        end
        set(pus_extend,'Visible','on');
	
    case 'mode'
    %------------------------------------------------------------------------%
    % Option: 'MODE' -  Update the command part when changing Extension Mode %
    %------------------------------------------------------------------------%

        % Cleaning.
        %----------
        if nargin<3 , imgxtool('clear_GRAPHICS',win_imgxtool); end

        % Checking the SWT case for visibility setings.
        %----------------------------------------------
        Mode_str = get(pop_mode,'String');
        Mode_val = get(pop_mode,'Value');
        if  strcmp(deblank(Mode_str(Mode_val,:)),'For SWT')
            set(cat(1,Hdls_UIC_H{:}),'visible','off')
            set(cat(1,Hdls_UIC_V{:}),'visible','off')
            set(cat(1,Hdls_UIC_Swt{:}),'visible','on')

            Image_Length_H    = wstr2num(get(edi_swtlen_H,'String'));
            Computed_Length_H = wstr2num(get(edi_swtclen_H,'String'));
            Image_Length_V    = wstr2num(get(edi_swtlen_V,'String'));
            Computed_Length_V = wstr2num(get(edi_swtclen_V,'String'));
            set(pus_extend,'String',xlate('Extend'));
            if isequal(Image_Length_H,nextpow2(Image_Length_H)) & ...
                isequal(Image_Length_V,nextpow2(Image_Length_V))
                set(pus_extend,'Enable','off');
                strSize = ['(' int2str(Image_Length_V), 'x', ...
                               int2str(Image_Length_H) ')'];
                msg = strvcat(...
                  sprintf('The size of the image %s is a power of 2.', strSize),  ...
                  ['The SWT extension is not necessary!']);
                wwarndlg(msg,'SWT Extension Mode','block');

            elseif Image_Length_H < Computed_Length_H | ...
                Image_Length_V < Computed_Length_V
                set(pus_extend,'Enable','on');
            end
        else
            set(pus_extend,'Enable','on');
            set(cat(1,Hdls_UIC_H{:}),'visible','on')
            set(cat(1,Hdls_UIC_V{:}),'visible','on')
            set(cat(1,Hdls_UIC_Swt{:}),'visible','off')
        end
        set(cat(1,Hdls_UIC_C{4:end}),'visible','on');
            
    case 'extend_truncate'
    %-------------------------------------------------------------------------%
    % Option: 'EXTEND_TRUNCATE' - Compute the new Extended or Truncated image %
    %-------------------------------------------------------------------------%
        
        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,'Wait ... computing');

        % Get Axes Handles.
        %------------------
        Axe_Img =  Hdls_Axes.Axe_Img;

        % Get stored structure.
        %----------------------        
        Anal_Image = wfigmngr('getValue',win_imgxtool,'Anal_Image');

        % Get UIC values.
        %----------------
        Image_length_H   = wstr2num(get(edi_length_H,'String'));
        Str_pop_direct_H = get(pop_direct_H,'String');
        Val_pop_direct_H = get(pop_direct_H,'Value');
        Str_pop_direct_H = deblank(Str_pop_direct_H(Val_pop_direct_H,:));
        Image_length_V   = wstr2num(get(edi_length_V,'String'));
        Str_pop_direct_V = get(pop_direct_V,'String');
        Val_pop_direct_V = get(pop_direct_V,'Value');
        Str_pop_direct_V = deblank(Str_pop_direct_V(Val_pop_direct_V,:));
        Str_pop_mode     = get(pop_mode,'String');
        Val_pop_mode     = get(pop_mode,'Value');
        Str_pop_mode     = deblank(Str_pop_mode(Val_pop_mode,:));

        % Directions mode conversion and desired lengths.
        %------------------------------------------------
        if strcmp(Str_pop_mode,'For SWT')
            Dir_H = 'r';
            Dir_V = 'b';
            Desired_length_H = wstr2num(get(edi_swtclen_H,'String'));
            Desired_length_V = wstr2num(get(edi_swtclen_V,'String'));
        else
            Dir_H_Values     = ['b';'l';'r'];
            Dir_V_Values     = ['b';'u';'d'];
            Dir_H            = Dir_H_Values(Val_pop_direct_H);
            Dir_V            = Dir_V_Values(Val_pop_direct_V);
            Desired_length_H = wstr2num(get(edi_deslen_H,'String'));
            Desired_length_V = wstr2num(get(edi_deslen_V,'String'));
        end
        Desired_Size = [Desired_length_V Desired_length_H];

        % Extension mode conversion.
        %---------------------------
        Mode_Values = {'sym';'symw';'asym';'asymw';'ppd';'zpd';'sp0';'spd';'ppd'};
        Mode        = Mode_Values{Val_pop_mode};

        % Get action to do.
        %------------------
        action = deblank(get(pus_extend,'string'));
        switch action
          case xlate('Truncate')
              Deb_O_H = 1;
              Deb_O_V = 1;
              delta_H = Image_length_H - Desired_length_H;
              delta_V = Image_length_V - Desired_length_V;
              switch Str_pop_direct_H
                case 'Left'  , Deb_N_H = 1 + delta_H;
                case 'Right' , Deb_N_H = 1;
                case 'Both'  , Deb_N_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_N_V = 1 + delta_V;
                case 'Down' , Deb_N_V = 1;
                case 'Both' , Deb_N_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2(Anal_Image,Desired_Size,First_Point);
              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case xlate('Extend / Truncate')
              Deb_O_V = 1;
              Deb_N_H = 1;
              delta_H = Desired_length_H - Image_length_H;
              delta_V = Image_length_V - Desired_length_V;
              switch Str_pop_direct_H
                case 'Left'  , Deb_O_H = 1 + delta_H;
                case 'Right' , Deb_O_H = 1;
                case 'Both'  , Deb_O_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_N_V = 1 + delta_V;
                case 'Down' , Deb_N_V = 1;
                case 'Both' , Deb_N_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2(Anal_Image,Desired_Size,First_Point);
              switch Dir_H
                case {'l','r'}
                  New_Image = wextend('ac',Mode,New_Image,delta_H,Dir_H);

                case 'b'
                  Ext_Size  = ceil(delta_H/2);
                  New_Image = wextend('ac',Mode,New_Image,Ext_Size,Dir_H);
                  if rem(delta_H,2)
                      New_Image = wkeep2(New_Image,Desired_Size,'c','dr');
                  end
              end

              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case xlate('Truncate / Extend')
              Deb_O_H = 1;
              Deb_N_V = 1;
              delta_H = Image_length_H - Desired_length_H;
              delta_V = Desired_length_V - Image_length_V ;
              switch Str_pop_direct_H
                case 'Left'  , Deb_N_H = 1 + delta_H;
                case 'Right' , Deb_N_H = 1;
                case 'Both'  , Deb_N_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_O_V = 1 + delta_V;
                case 'Down' , Deb_O_V = 1;
                case 'Both' , Deb_O_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              First_Point  = [Deb_N_V Deb_N_H ];
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              New_Image    = wkeep2(Anal_Image,Desired_Size,First_Point);
              switch Dir_V
                case {'u','d'}
                  New_Image = wextend('ar',Mode,New_Image,delta_V,Dir_V);

                case 'b'
                  Ext_Size  = ceil(delta_V/2);
                  New_Image = wextend('ar',Mode,Anal_Image,Ext_Size,Dir_V);
                  if rem(delta_V,2)
                      New_Image = wkeep2(New_Image,Desired_Size,'c','dr');
                  end
              end

              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

          case xlate('Extend')
              Deb_N_H = 1;
              Deb_N_V = 1;
              delta_H = Desired_length_H - Image_length_H;
              delta_V = Desired_length_V - Image_length_V ;
              switch Str_pop_direct_H
                case 'Left'  , Deb_O_H = 1 + delta_H;
                case 'Right' , Deb_O_H = 1;
                case 'Both'  , Deb_O_H = 1 + fix(delta_H/2);
              end
              switch Str_pop_direct_V
                case 'Up'   , Deb_O_V = 1 + delta_V;
                case 'Down' , Deb_O_V = 1;
                case 'Both' , Deb_O_V = 1 + fix(delta_V/2);
              end
              Fin_O_H      = Deb_O_H + Image_length_H - 1;
              Fin_O_V      = Deb_O_V + Image_length_V - 1;
              Fin_N_H      = Deb_N_H + Desired_length_H - 1;
              Fin_N_V      = Deb_N_V + Desired_length_V - 1;
              Image_Lims_O = [Deb_O_H Fin_O_H Deb_O_V Fin_O_V];
              Image_Lims_N = [Deb_N_H Fin_N_H Deb_N_V Fin_N_V];

              switch Dir_H
                case {'l','r'}
                  New_Image = wextend('ac',Mode,Anal_Image,delta_H,Dir_H);

                case 'b'
                  Ext_Size  = ceil(delta_H/2);
                  New_Image = wextend('ac',Mode,Anal_Image,Ext_Size,Dir_H);
              end

              switch Dir_V
                case {'u','d'}
                  New_Image  = wextend('ar',Mode,New_Image,delta_V,Dir_V);

                case 'b'
                  Ext_Size  = ceil(delta_V/2);
                  New_Image = wextend('ar',Mode,New_Image,Ext_Size,Dir_V);
              end
              if rem(delta_H,2) | rem(delta_V,2)
                  New_Image = wkeep2(New_Image,Desired_Size,'c','dr');
              end

              imgxtool('draw',win_imgxtool,Anal_Image,New_Image, ...
                          [Image_Lims_O;Image_Lims_N]);

        end
		
        % Saving the new image.
        %-----------------------		
        wfigmngr('storeValue',win_imgxtool,'New_Image',New_Image);

        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);
        
    case 'draw'
    %-----------------------------------------------------%
    % Option: 'DRAW' - Plot both new and original signals %
    %-----------------------------------------------------%
						
        % Get arguments.
        %---------------
        Anal_Image = varargin{2};
        New_Image  = varargin{3};
        Image_Lims = varargin{4};
        Deb_O_H    = Image_Lims(1,1);
        Fin_O_H    = Image_Lims(1,2);
        Deb_O_V    = Image_Lims(1,3);
        Fin_O_V    = Image_Lims(1,4);
        Deb_N_H    = Image_Lims(2,1);
        Fin_N_H    = Image_Lims(2,2);
        Deb_N_V    = Image_Lims(2,3);
        Fin_N_V    = Image_Lims(2,4);
        
        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,'Wait ... drawing');
        
        % Get Axes Handles.
        %------------------
        Axe_Img =  Hdls_Axes.Axe_Img;
        Axe_Leg =  Hdls_Axes.Axe_Leg;
		
        % Clean images axes.
        %--------------------
        delete(findobj(Axe_Img,'Type','image'));
        delete(findobj(Axe_Img,'Type','line'));

        % Compute axes limits.
        %---------------------
        Xmin = min(Deb_O_H,Deb_N_H)-1;
        Xmax = max(Fin_O_H,Fin_N_H)+1;
        Ymin = min(Deb_O_V,Deb_N_V)-1;
        Ymax = max(Fin_O_V,Fin_N_V)+1;

        % Compute image ratio.
        %---------------------
        Len_X = Xmax - Xmin;
        Len_Y = Ymax - Ymin;
        
        % Compute new Axes position to respect a good ratio.
        %---------------------------------------------------
        [w,h]          = wpropimg([Len_X Len_Y],Pos_Axe_Img_Ori(3), ...
                                   Pos_Axe_Img_Ori(4));
        Pos_Axe_Img    = Pos_Axe_Img_Ori;
        Pos_Axe_Img(1) = Pos_Axe_Img(1)+abs(Pos_Axe_Img(3)-w)/2;
        Pos_Axe_Img(2) = Pos_Axe_Img(2)+abs(Pos_Axe_Img(4)-h)/2;
        Pos_Axe_Img(3) = w;
        Pos_Axe_Img(4) = h;
            
        % Update axes properties.
        %------------------------
        set(Axe_Img,                         ...
            'XTicklabelMode','manual',       ...
            'YTicklabelMode','manual',       ...
            'XTicklabel',[],'YTicklabel',[], ...
            'XTick',[],'YTick',[],           ...
            'Ydir','reverse',                ...
            'Box','Off',                     ...
            'NextPlot','add',                ...
            'Position',Pos_Axe_Img,          ...
            'Xlim',[Xmin,Xmax],              ...
            'Ylim',[Ymin,Ymax],              ...
            'Xcolor','k',                    ...
            'Ycolor','k',                    ...
            'Visible','on'                   ...
            );
        set(get(Axe_Img,'title'),'string','');
            
        % Draw old image.
        %----------------
        Old_Img = image(Anal_Image,                   ...
                           'parent',Axe_Img,          ...
                           'Xdata',[Deb_O_H Fin_O_H], ...
                           'Ydata',[Deb_O_V Fin_O_V]  ...
                           );

        % Draw new image.
        %----------------
        New_Img = image(New_Image,                    ...
                           'parent',Axe_Img,          ...
                           'Xdata',[Deb_N_H Fin_N_H], ...
                           'Ydata',[Deb_N_V Fin_N_V]  ...
                           );

        % Constant coefs. for box design.
        %--------------------------------
        S1 = 4;
        S2 = 4;

        % Draw Box around old image.
        %---------------------------
        X = [Deb_O_H Fin_O_H Fin_O_H Deb_O_H Deb_O_H];
        Y = [Deb_O_V Deb_O_V Fin_O_V Fin_O_V Deb_O_V];
        Box_Old_Img = line(X,Y,              ...
                           'parent',Axe_Img, ...
                           'color','red',    ...
                           'LineWidth',S1    ...
                           );

        % Draw Box around new image.
        %----------------------------
        X = [Deb_N_H Fin_N_H Fin_N_H Deb_N_H Deb_N_H];
        Y = [Deb_N_V Deb_N_V Fin_N_V Fin_N_V Deb_N_V];
        Box_New_Img = line(X,Y,              ...
                           'parent',Axe_Img, ...
                           'color','yellow', ...
                           'LineWidth',S2    ...
                           );

        % Display Legend.
        %----------------
        set(Axe_Leg,'Visible','on');
        set(get(Axe_Leg,'Children'),'Visible','on');
				
        % Dynvtool Attachement.
        %----------------------
        dynvtool('init',win_imgxtool,[],Axe_Img,[],[1 1],'','','');

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 0;
        wfigmngr('storeValue',win_imgxtool,'File_Save_Flag',File_Save_Flag);
        				
        % Enable save menu.
        %------------------
        set(m_save,'Enable','on');

        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);
                		
    case 'save'
    %-----------------------------------------%
    % Option: 'SAVE' - Save transformed image %
    %-----------------------------------------%				

        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_imgxtool, ...
                                    '*.mat','Save Transformed Image');
        if ~ok, return; end

        % Begin waiting.
        %---------------
        wwaiting('msg',win_imgxtool,'Wait ... saving');
				
        % Restore the new image.
        %-----------------------		
        X = wfigmngr('getValue',win_imgxtool,'New_Image');

        % Setting Colormap.
        %------------------
        map = cbcolmap('get',win_imgxtool,'self_pal');
        if isempty(map)
            maxVal   = max(max(X));
            nbcolors = round(max([2,min([maxVal,default_nbcolors])]));
            map = pink(nbcolors);
        end
	
        % Saving transformed Image.
        %--------------------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        try
          save([pathname filename],'X','map');
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

        % Update File_Save_Flag.
        %-----------------------
        File_Save_Flag = 1;
        wfigmngr('storeValue',win_imgxtool,'File_Save_Flag',File_Save_Flag);
        				
        % Enable save menu.
        %------------------
        set(m_save,'Enable','off');
        
        % End waiting.
        %-------------
        wwaiting('off',win_imgxtool);
		
    case 'clear_GRAPHICS'
    %---------------------------------------------------------------------%
    % Option: 'CLEAR_GRAPHICS' - Clear graphics and redraw original image %
    %---------------------------------------------------------------------%
					
        % Get arguments.
        %---------------
        if length(varargin) > 1, Draw_flag = 0; else Draw_flag = 1; end

        % Get Axes Handles.
        %------------------
        Axe_Img = Hdls_Axes.Axe_Img;
        Axe_Leg = Hdls_Axes.Axe_Leg;

        % Set graphics part visible off and redraw original image if needed.
        %-------------------------------------------------------------------
        set(Axe_Leg,'Visible','off');
        set(get(Axe_Leg,'Children'),'Visible','off');
        
        if Draw_flag
            Anal_Image      = wfigmngr('getValue',win_imgxtool,'Anal_Image');
            Pos_Axe_Img_Bas = wfigmngr('getValue',win_imgxtool, ...
                                       'Pos_Axe_Img_Bas');
            set(findobj(Axe_Img,'Type','line'),'Visible','Off');
            [H,V] = size(Anal_Image);
            set(get(Axe_Img,'title'),'string',xlate('Original Image'));
            set(Axe_Img,                         ...
                'Xlim',[1,H],                    ...
                'Ylim',[1,V],                    ...
                'Position',Pos_Axe_Img_Bas,      ...
                'Visible','on');
            set(findobj(Axe_Img,'Type','image'), ...
                'parent',Axe_Img,                ...
                'Xdata',[1,H],                   ...
                'Ydata',[1,V],                   ...
                'Cdata',Anal_Image,              ...
                'Visible','on'                   ...
                );
            dynvtool('init',win_imgxtool,[],Axe_Img,[],[1 1],'','','');
        else
            set(Axe_Img,'Visible','off');
            set(get(Axe_Img,'Children'),'Visible','off');
        end
				
        % Disable save menu.
        %-------------------
        set(m_save,'Enable','off');
		
        % Reset the new image.
        %---------------------		
        wfigmngr('storeValue',win_imgxtool,'New_Image',[]);
        
    case 'close'
    %---------------------------------------%
    % Option: 'CLOSE' - Close current figure%
    %---------------------------------------%

        % Retrieve File_Save_Flag.
        %-------------------------
        File_Save_Flag = wfigmngr('getValue',win_imgxtool,'File_Save_Flag');
        		
        % Retrieve images values.
        %------------------------		
        New_Image  = wfigmngr('getValue',win_imgxtool,'New_Image');
        Anal_Image = wfigmngr('getValue',win_imgxtool,'Anal_Image');
        
        % Test for saving the new image.
        %-------------------------------
        status = 0;
        if ~isempty(New_Image) & any(size(New_Image)~=size(Anal_Image)) &...
            ~File_Save_Flag
            status = wwaitans(win_imgxtool,...
                     ' Do you want to save the transformed image ?',2,'cond');
        end
        switch status
          case 1 , imgxtool('save',win_imgxtool)
          case 0 ,
        end
        varargout{1} = status;
        				
    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
