function out1 = dw2dmngr(option,win_dw2dtool,in3,in4,in5)
%DW2DMNGR Discrete wavelet 2-D general manager.
%   OUT1 = DW2DMNGR(OPTION,WIN_DW2DTOOL,IN3,IN4,IN5)
%
%   option = 'load_img'
%   option = 'load_dec'
%   option = 'load_cfs'
%   option = 'demo'
%   option = 'save_synt'
%   option = 'save_cfs'
%   option = 'save_dec'
%   option = 'analyze'
%   option = 'synthesize'
%   option = 'step2'
%   option = 'view_dec'
%   option = 'select'
%   option = 'view_mode'
%   option = 'fullsize'
%   option = 'return_comp'
%   option = 'return_deno'
%   option = 'set_graphic'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-Apr-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.24.4.2 $ $Date: 2004/03/15 22:40:20 $

% Get Globals.
%-------------
[Def_AxeFontSize,Terminal_Prop,Def_TxtBkColor] = ...
    mextglob('get','Def_AxeFontSize','Terminal_Prop','Def_TxtBkColor');

% Default values.
%----------------
max_lev_anal = 5;
def_nbCodeOfColors = 255;

% Image Coding Value.
%-------------------
codemat_v = wimgcode('get',win_dw2dtool);

% Tag property of objects.
%-------------------------
tag_m_savesyn  = 'Save_Syn';
tag_m_savecfs  = 'Save_Cfs';
tag_m_savedec  = 'Save_Dec';
tag_cmd_frame  = 'Cmd_Frame';
tag_pus_anal   = 'Pus_Anal';
tag_pus_deno   = 'Pus_Deno';
tag_pus_comp   = 'Pus_Comp';
tag_pus_hist   = 'Pus_Hist';
tag_pus_stat   = 'Pus_Stat';
tag_pop_declev = 'Pop_DecLev';
tag_pus_visu   = 'Pus_Visu';
tag_pus_big    = 'Pus_Big';
tag_pus_rec    = 'Pus_Rec';
tag_pop_viewm  = 'Pop_ViewM';
tag_txt_full   = 'Txt_Full';
tag_pus_full   = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];
tag_btnaxeset  = 'Btn_Axe_Set';
tag_axefigutil = 'Axe_FigUtil';
tag_linetree   = 'Tree_lines';
tag_txttree    = 'Tree_txt';
tag_axeimgbig  = 'Axe_ImgBig';
tag_axeimgini  = 'Axe_ImgIni';
tag_axeimgvis  = 'Axe_ImgVis';
tag_axeimgsel  = 'Axe_ImgSel';
tag_axeimgdec  = 'Axe_ImgDec';
tag_axeimgsyn  = 'Axe_ImgSyn';
tag_axeimghdls = 'Img_Handles';
tag_imgdec     = 'Img_Dec';

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'DW2D_InfoInit';
ind_filename = 1;
ind_pathname = 2;
nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'DWAn2d_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_img_t_name = 4;
ind_img_size   = 5;
ind_nbcolors   = 6;
ind_act_option = 7;
ind_simg_type  = 8;
ind_thr_val    = 9;
nb1_stored     = 9;

% MB2.1 and 2.2.
%---------------
n_coefs = 'MemCoefs';
n_sizes = 'MemSizes';

% MB3.
%-----
n_miscella      = 'DWAn2d_Miscella';
ind_graph_area  =  1;
ind_pos_axebig  =  2;
ind_pos_axeini  =  3;
ind_pos_axevis  =  4;
ind_pos_axedec  =  5;
ind_pos_axesyn  =  6;
ind_pos_axesel  =  7;
ind_view_status =  8;
ind_save_status =  9;
ind_sel_funct   = 10;
nb3_stored      = 10;

% Miscellaneous values.
%----------------------
square_viewm    = 1;
tree_viewm      = 2;
[Col_BoxAxeSel,Col_Selected,BoxTitleSel_Col] = wtbutils('colors','dw2d');
Width_LineSel   = 3;

% View Status
%--------------------------------------------------------%
% 'none' : init
% 's_l*' : square        * = lev_dec (1 --> Level_Anal)
% 'f1l*' : full ini      * = lev_dec (1 --> Level_Anal)
% 'f2l*' : full syn      * = lev_dec (1 --> Level_Anal)
% 'f3l*' : full vis      * = lev_dec (1 --> Level_Anal)
% 'f4l*' : full dec      * = lev_dec (1 --> Level_Anal)
% 'b*l*' : big
%            first   * = index   (1 --> 4*Level_Anal)
%            second  * = lev_dec (1 --> Level_Anal)
% 't_l*' : tree          * = lev_dec (1 --> Level_Anal)
%--------------------------------------------------------%

% Handles of tagged objects.
%---------------------------
str_numwin  = sprintf('%.0f',win_dw2dtool);
children    = get(win_dw2dtool,'Children');
uic_handles = findobj(children,'flat','type','uicontrol');
axe_handles = findobj(children,'flat','type','axes');
txt_handles = findobj(uic_handles,'Style','text');
pop_handles = findobj(uic_handles,'Style','popupmenu');
pus_handles = findobj(uic_handles,'Style','pushbutton');

m_files   = wfigmngr('getmenus',win_dw2dtool,'file');
m_savesyn = findobj(m_files,'Tag',tag_m_savesyn);
m_savecfs = findobj(m_files,'Tag',tag_m_savecfs);
m_savedec = findobj(m_files,'Tag',tag_m_savedec);

pus_anal   = findobj(pus_handles,'Tag',tag_pus_anal);
pus_deno   = findobj(pus_handles,'Tag',tag_pus_deno);
pus_comp   = findobj(pus_handles,'Tag',tag_pus_comp);
pus_hist   = findobj(pus_handles,'Tag',tag_pus_hist);
pus_stat   = findobj(pus_handles,'Tag',tag_pus_stat);
pop_declev = findobj(pop_handles,'Tag',tag_pop_declev);
pus_visu   = findobj(pus_handles,'Tag',tag_pus_visu);
pus_big    = findobj(pus_handles,'Tag',tag_pus_big);
pus_rec    = findobj(pus_handles,'Tag',tag_pus_rec);
pop_viewm  = findobj(pop_handles,'Tag',tag_pop_viewm);
txt_full   = findobj(txt_handles,'Tag',tag_txt_full);
for k =1:size(tag_pus_full,1)
    pus_full(k) = (findobj(pus_handles,'Tag',tag_pus_full(k,:)))';
end

Axe_ImgBig = findobj(axe_handles,'flat','Tag',tag_axeimgbig);
Axe_ImgIni = findobj(axe_handles,'flat','Tag',tag_axeimgini);
Axe_ImgVis = findobj(axe_handles,'flat','Tag',tag_axeimgvis);
Axe_ImgSel = findobj(axe_handles,'flat','Tag',tag_axeimgsel);
Axe_ImgSyn = findobj(axe_handles,'flat','Tag',tag_axeimgsyn);

switch option
    case 'load_img'
        % Testing file.
        %--------------
        imgFileType = ['*.mat;*.bmp;*.hdf;*.jpg;' ...
                '*.jpeg;*.pcx;*.tif;*.tiff;*.gif'];
        [imgInfos,img_anal,map,ok] = ...
            utguidiv('load_img',win_dw2dtool, ...
                imgFileType,'Load Image',def_nbCodeOfColors);
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaiting('msg',win_dw2dtool,'Wait ... cleaning');
        dw2dutil('clean',win_dw2dtool,option);

        % Setting Analysis parameters.
        %-----------------------------
        NB_ColorsInPal = size(map,1);
        wmemtool('wmb',win_dw2dtool,n_param_anal,   ...
                       ind_act_option,option,       ...
		       ind_img_name,imgInfos.name,  ...
		       ind_img_t_name,imgInfos.true_name, ...
		       ind_img_size,imgInfos.size,  ...
                       ind_nbcolors,NB_ColorsInPal, ...
                       ind_simg_type,'ss'           ...
                       );
        wmemtool('wmb',win_dw2dtool,n_InfoInit, ...
		       ind_filename,imgInfos.filename, ...
		       ind_pathname,imgInfos.pathname  ...
                       );

        % Setting GUI values.
        %--------------------
        levm   = wmaxlev(imgInfos.size,'haar');
        levmax = min(levm,max_lev_anal);
        if isequal(imgInfos.true_name,'X')
            img_Name = imgInfos.name;
        else
	        img_Name = imgInfos.true_name;
        end
        img_Size = imgInfos.size;
        cbanapar('set',win_dw2dtool, ...
            'n_s',{img_Name,img_Size}, ...
            'lev',{'String',int2str([1:levmax]'),'Value',min(levmax,2)} ...
            );
        if imgInfos.self_map , arg = map; else , arg = []; end
        cbcolmap('set',win_dw2dtool,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Drawing axes.
        %--------------
        dw2dutil('pos_axe_init',win_dw2dtool,option);

        % Drawing Original Image
        %-----------------------
        img_anal = wimgcode('cod',0,img_anal,NB_ColorsInPal,codemat_v);
        image([1 img_Size(1)],[1 img_Size(2)],img_anal,'Parent',Axe_ImgIni);
        wtitle('Original Image','Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Tag',tag_axeimgini)

        % Setting enabled values.
        %------------------------
        dw2dutil('enable',win_dw2dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'load_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wa2;*.mat' , 'Decomposition  (*.wa2;*.mat)';
               '*.*','All Files (*.*)'};        
        [filename,pathname,ok] = utguidiv('load_var',win_dw2dtool, ...
                                   fileMask,'Load Wavelet Analysis (2D)',...
                                   {'coefs','sizes','wave_name'});
        if ~ok, return; end

        % Loading file.
        %--------------
        load([pathname filename],'-mat');
        if ~exist('map','var'), map = pink(def_nbCodeOfColors); end
        if ~exist('data_name','var') , data_name = 'no name'; end
        lev = size(sizes,1)-2;
        if lev>max_lev_anal
            msg = sprintf('The level of the decomposition \nis too large (max = %.0f).', max_lev_anal);
            wwarndlg(msg,'Load Wavelet Analysis (2D)','block');
            return  
        end

        % Cleaning.
        %----------
        wwaiting('msg',win_dw2dtool,'Wait ... cleaning');
        dw2dutil('clean',win_dw2dtool,option);

        % Getting Analysis parameters.
        %-----------------------------
        s_img          = size(sizes);
        Img_Size       = fliplr(sizes(s_img(1),:));
        Level_Anal     = s_img(1)-2;
        NB_ColorsInPal = size(map,1);

        % Setting coefs and sizes.
        %-------------------------
        wmemtool('wmb',win_dw2dtool,n_coefs,1,coefs);
        wmemtool('wmb',win_dw2dtool,n_sizes,1,sizes);

        % Setting GUI values.
        %--------------------
        levm   = wmaxlev(Img_Size,'haar');
        levmax = min(levm,max_lev_anal);
        cbanapar('set',win_dw2dtool, ...
                 'n_s',{data_name,Img_Size},'wav',wave_name, ...
                 'lev',{'String',int2str([1:levmax]'),'Value',Level_Anal});
        levels = int2str([1:Level_Anal]');
        set(pop_declev,'String',levels,'Value',Level_Anal);
        pink_map = pink(NB_ColorsInPal);
        self_map = max(max(abs(map-pink_map)));
        if self_map , arg = map; else , arg = []; end
        cbcolmap('set',win_dw2dtool,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Setting Analysis parameters.
        %-----------------------------
        wmemtool('wmb',win_dw2dtool,n_param_anal,   ...
                       ind_act_option,option,       ...
                       ind_wav_name,wave_name,      ...
                       ind_lev_anal,Level_Anal,     ...
                       ind_img_name,data_name,      ...
                       ind_img_t_name,'',           ...
                       ind_img_size,Img_Size,       ...
                       ind_nbcolors,NB_ColorsInPal, ...
                       ind_simg_type,'ss'           ...
                       );
        wmemtool('wmb',win_dw2dtool,n_InfoInit, ...
                       ind_filename,filename,   ...
                       ind_pathname,pathname    ...
                       );

        % Drawing axes.
        %--------------
        dw2dutil('pos_axe_init',win_dw2dtool,option);

        % Calling Analysis
        %-----------------
        dw2dmngr('step2',win_dw2dtool,option);

        % Computing Original Image.
        %--------------------------
        X = appcoef2(coefs,sizes,wave_name,0);

        % Drawing Original Image
        %-----------------------
        X = wimgcode('cod',0,X,NB_ColorsInPal,codemat_v);
        image([1 Img_Size(1)],[1,Img_Size(2)],X,'Parent',Axe_ImgIni);
        wtitle('Reconstructed Image','Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Tag',tag_axeimgini)
        image([1 Img_Size(1)],[1 Img_Size(2)],X,'Parent',Axe_ImgSyn);
        set(Axe_ImgSyn,...
            'XTicklabelMode','manual', ...
            'YTicklabelMode','manual', ...
            'XTicklabel',[],           ...
            'YTicklabel',[],           ...
            'Box','On',                ...
            'Tag',tag_axeimgsyn        ...
            );
        wtitle('Synthesized Image','Parent',Axe_ImgSyn);

        % Setting enabled values.
        %------------------------
        dw2dutil('enable',win_dw2dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'load_cfs'
        % in3 = 'new_synt' (optional).
        %----------------------------
        if nargin==2
            % Testing file.
            %--------------
            [filename,pathname,ok] = utguidiv('load_var',win_dw2dtool,  ...
                                       '*.mat','Load Coefficients (2D)',...
                                       {'coefs','sizes'});
            if ~ok, return; end

            % Loading file.
            %--------------
            load([pathname filename],'-mat');
            lev = size(sizes,1)-2;
            if lev>max_lev_anal
                msg = sprintf(...
				   'The level of the decomposition \nis too large (max = %d).',max_lev_anal);
                wwarndlg(msg,'Load Coefficients (2D)','block');
                return  
            end
            in3 = '';
            [Img_Name,ext] = strtok(filename,'.');

            % Cleaning.
            %----------
            wwaiting('msg',win_dw2dtool,'Wait ... cleaning');
            dw2dutil('clean',win_dw2dtool,option);

            % Getting Analysis parameters.
            %-----------------------------
            s_img      = size(sizes);
            Img_Size   = fliplr(sizes(s_img(1),:));
            Level_Anal = s_img(1)-2;

            % Setting coefs and sizes.
            %-------------------------
            wmemtool('wmb',win_dw2dtool,n_coefs,1,coefs);
            wmemtool('wmb',win_dw2dtool,n_sizes,1,sizes);

            % Setting GUI values.
            %--------------------
            cbanapar('set',win_dw2dtool, ...
               'n_s',{Img_Name,Img_Size}, ...
               'lev',{'String',int2str(Level_Anal),'Value',1} ...
               );
            levels = int2str([1:Level_Anal]');
            set(pop_declev,'String',levels,'Value',Level_Anal);

            % Computing (approximate) colormap.
            %----------------------------------
            tmp = appcoef2(coefs,sizes,'haar',Level_Anal);
            NB_ColorsInPal = ceil(max(max(tmp))/(2^Level_Anal));
            NB_ColorsInPal = min([max([2,NB_ColorsInPal]),def_nbCodeOfColors]);
            cbcolmap('set',win_dw2dtool,'pal',{'pink',NB_ColorsInPal});

            % Setting Analysis parameters.
            %-----------------------------
            wmemtool('wmb',win_dw2dtool,n_param_anal,   ...
                           ind_act_option,option,       ...
                           ind_lev_anal,Level_Anal,     ...
                           ind_img_size,Img_Size,       ...
                           ind_img_name,Img_Name,       ...
                           ind_nbcolors,NB_ColorsInPal, ...
                           ind_simg_type,'ss'           ...
                           );
            wmemtool('wmb',win_dw2dtool,n_InfoInit, ...
                           ind_filename,filename,   ...
                           ind_pathname,pathname    ...
                           );
        else
            % Cleaning.
            %----------
            wwaiting('msg',win_dw2dtool,'Wait ... cleaning');
            dw2dutil('clean',win_dw2dtool,option,in3);
        end

        % Drawing axes.
        %--------------
        dw2dutil('pos_axe_init',win_dw2dtool,option);

        % Calling Analysis
        %-----------------
        dw2dmngr('step2',win_dw2dtool,option);

        % Setting enabled values.
        %------------------------
        dw2dutil('enable',win_dw2dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'demo'
        Img_Name   = deblank(in3);
        Wave_Name  = deblank(in4);
        Level_Anal = in5;

        % Loading file.
        %--------------
        filename = [Img_Name '.mat'];
        pathname = utguidiv('WTB_DemoPath',filename);
        [imgInfos,img_anal,map,ok] = utguidiv('load_dem2D',win_dw2dtool, ...
                                       pathname,filename,def_nbCodeOfColors);
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaiting('msg',win_dw2dtool,'Wait ... cleaning');
        dw2dutil('clean',win_dw2dtool,option);

        % Setting GUI values.
        %--------------------
        NB_ColorsInPal = size(map,1);
        if isequal(imgInfos.true_name,'X')
            img_Name = imgInfos.name;
        else
            img_Name = imgInfos.true_name;
        end
        cbanapar('set',win_dw2dtool, ...
            'n_s',{img_Name,imgInfos.size}, ...
            'wav',Wave_Name, ...
            'lev',Level_Anal ...
            );
        levels = int2str([1:Level_Anal]');
        set(pop_declev,'String',levels,'Value',Level_Anal);
        if imgInfos.self_map , arg = map; else , arg = []; end
        cbcolmap('set',win_dw2dtool,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Setting Analysis parameters
        %-----------------------------
        NB_ColorsInPal = size(map,1);
        wmemtool('wmb',win_dw2dtool,n_param_anal,  ...
                       ind_act_option,option,      ...
                       ind_img_name,imgInfos.name, ...
                       ind_wav_name,Wave_Name,     ...
                       ind_lev_anal,Level_Anal,    ...
                       ind_img_t_name,imgInfos.true_name, ...
                       ind_img_size,imgInfos.size, ...
                       ind_nbcolors,NB_ColorsInPal,...
                       ind_simg_type,'ss'          ...
                       );
        wmemtool('wmb',win_dw2dtool,n_InfoInit, ...
                       ind_filename,imgInfos.filename, ...
                       ind_pathname,imgInfos.pathname  ...
                       );

        % Drawing axes.
        %--------------
        dw2dutil('pos_axe_init',win_dw2dtool,option);

        % Drawing Original Image
        %-----------------------
        X = wimgcode('cod',0,img_anal,NB_ColorsInPal,codemat_v);
        image([1 imgInfos.size(1)],[1,imgInfos.size(2)],X,...
                'Parent',Axe_ImgIni);
        wtitle('Original Image','Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Tag',tag_axeimgini)

        % Calling Analysis.
        %-----------------
        dw2dmngr('step2',win_dw2dtool,option);

        % Setting enabled values.
        %------------------------
        dw2dutil('enable',win_dw2dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'save_synt'
        % Testing file.
        %--------------        
        [filename,pathname,ok] = utguidiv('test_save',win_dw2dtool, ...
                                     '*.mat','Save Synthesized Image');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw2dtool,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        [wname,valTHR] = wmemtool('rmb',win_dw2dtool,n_param_anal, ...
                                  ind_wav_name,ind_thr_val);
        map = cbcolmap('get',win_dw2dtool,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_nbcolors);
            map = pink(nb_colors);
        end

        % Getting Synthesized Image.
        %---------------------------
        img = dw2drwcd('r_synt',win_dw2dtool);
        X = round(get(img,'Cdata'));

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'X','map','valTHR','wname'};
        wwaiting('off',win_dw2dtool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_cfs'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_dw2dtool, ...
                                     '*.mat','Save Coefficients (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw2dtool,'Wait ... saving coefficients');

        % Getting Analysis values.
        %-------------------------
        [wname,valTHR] = wmemtool('rmb',win_dw2dtool,n_param_anal, ...
                                  ind_wav_name,ind_thr_val);
        map = cbcolmap('get',win_dw2dtool,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_nbcolors);
            map = pink(nb_colors);
        end
        coefs = wmemtool('rmb',win_dw2dtool,n_coefs,1);
        sizes = wmemtool('rmb',win_dw2dtool,n_sizes,1);

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','map','valTHR','wname'};
        wwaiting('off',win_dw2dtool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wa2;*.mat' , 'Decomposition  (*.wa2;*.mat)';
               '*.*','All Files (*.*)'};                
        [filename,pathname,ok] = utguidiv('test_save',win_dw2dtool, ...
                                     fileMask,'Save Wavelet Analysis (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw2dtool,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        [wave_name,data_name,level_anal,nb_colors,valTHR] = ...
                wmemtool('rmb',win_dw2dtool,n_param_anal, ...
                               ind_wav_name, ...
                               ind_img_name, ...
                               ind_lev_anal, ...
                               ind_nbcolors, ...
                               ind_thr_val   ...
                               );

        map = cbcolmap('get',win_dw2dtool,'self_pal');
        if isempty(map) , map = pink(nb_colors); end
        coefs = wmemtool('rmb',win_dw2dtool,n_coefs,1);
        sizes = wmemtool('rmb',win_dw2dtool,n_sizes,1);

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.wa2'; filename = [name ext];
        end
        saveStr = {'coefs','sizes','wave_name','map','valTHR','data_name'};
        wwaiting('off',win_dw2dtool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'analyze'
        active_option = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_act_option);        

        if ~strcmp(active_option,'load_img')
            wwaiting('msg',win_dw2dtool,'Wait ... computing');
            dw2dutil('clean2',win_dw2dtool,option);
            wmemtool('wmb',win_dw2dtool,n_param_anal,ind_simg_type,'ss');
        end

        % Reading Analysis Parameters.
        %----------------------------
        [Wave_Name,Level_Anal] = cbanapar('get',win_dw2dtool,'wav','lev');

        % Setting GUI values.
        %--------------------
        levels = int2str([1:Level_Anal]');
        set(pop_declev,'String',levels,'Value',Level_Anal);

        % Setting Analysis parameters.
        %-----------------------------
        wmemtool('wmb',win_dw2dtool,n_param_anal, ...
                       ind_act_option,option,  ...
                       ind_wav_name,Wave_Name, ...
                       ind_lev_anal,Level_Anal ...
                       );

        % Calling Analysis.
        %------------------
        dw2dmngr('step2',win_dw2dtool,option);

        % Setting enabled values.
        %------------------------
        dw2dutil('enable',win_dw2dtool,option);

    case 'synthesize'
        active_option = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_cfs')
            wwaiting('msg',win_dw2dtool,'Wait ... computing');
            dw2dmngr('load_cfs',win_dw2dtool,'new_synt');
        end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw2dtool,'Wait ... computing');

        % Reading Analysis Parameters.
        %----------------------------
        Wave_Name  = cbanapar('get',win_dw2dtool,'wav');

        % Getting & Setting Analysis parameters.
        %---------------------------------------
        [Img_Size,NB_ColorsInPal,Level_Anal] = ...
                wmemtool('rmb',win_dw2dtool,n_param_anal, ...
                               ind_img_size, ...
                               ind_nbcolors, ...
                               ind_lev_anal  ...
                               );
        wmemtool('wmb',win_dw2dtool,n_param_anal, ...
                       ind_act_option,option, ...
                       ind_wav_name,Wave_Name ...
                       );

        % Setting GUI values.
        %--------------------
        cbanapar('set',win_dw2dtool, ...
            'lev',{'String',sprintf('%.0f',Level_Anal)});
        levels  = int2str([1:Level_Anal]');
        set(pop_declev,'String',levels,'Value',Level_Anal);

        % Getting Analysis values.
        %-------------------------
        coefs = wmemtool('rmb',win_dw2dtool,n_coefs,1);
        sizes = wmemtool('rmb',win_dw2dtool,n_sizes,1);

        % Getting Select Function.
        %------------------------
        [view_status,select_funct] = wmemtool('rmb',win_dw2dtool,n_miscella,...
                                        ind_view_status,ind_sel_funct);

        % Setting axes properties.
        %-------------------------
        Axe_ImgDec  = wmemtool('rmb',win_dw2dtool,tag_axeimgdec,1);
        Axe_ImgDec  = Axe_ImgDec(1:4*Level_Anal);
        Img_Handles = wmemtool('rmb',win_dw2dtool,tag_axeimghdls,1);

        % Computing Synthesized Image.
        %-----------------------------
        view_mode = view_status(1);
        for k=Level_Anal-1:-1:1
            X = appcoef2(coefs,sizes,Wave_Name,k);
            if (k~=Level_Anal) & ( view_mode=='s' | view_mode=='f')
                vis = 'Off';
            else
                vis = 'On';
            end
            num_img = 4*k;
            axeAct  = Axe_ImgDec(num_img);
            axes(axeAct)
            %--------------------------------%
            %-   k = level ;
            %-   m = 1 : v ;    m = 2 : d ;         
            %-   m = 3 : h ;    m = 4 : a ; 
            %--------------------------------%
            trunc_p = [k Img_Size(2) Img_Size(1)];
            X = wimgcode('cod',1,X,NB_ColorsInPal,codemat_v,trunc_p);
            Img_Handles(num_img) = ...
                            image([1 Img_Size(1)],[1,Img_Size(2)],X,...
                                    'Parent',axeAct,...
                                    'Visible',vis,...
                                    'UserData',[0;k;4],...
                                    'Tag',tag_imgdec,...
                                    'ButtonDownFcn',select_funct...
                                    );
            set(axeAct, ...
                  'Visible',vis,                   ...
                  'Xcolor',Col_BoxAxeSel,          ...
                  'Ycolor',Col_BoxAxeSel,          ...
                  'XTicklabelMode','manual',       ...
                  'YTicklabelMode','manual',       ...
                  'XTicklabel',[],'YTicklabel',[], ...
                  'XTick',[],'YTick',[],           ...
                  'Box','On',                      ...
                  'Tag',tag_axeimgdec              ...
                  );
        end
        wmemtool('wmb',win_dw2dtool,tag_axeimghdls,1,Img_Handles);

        % Drawing Synthesized Image.
        %--------------------------
        X = appcoef2(coefs,sizes,Wave_Name,0);
        X = wimgcode('cod',0,X,NB_ColorsInPal,codemat_v);
        if (view_mode=='f') , vis = 'Off'; else , vis = 'On'; end
        axes(Axe_ImgIni);
        image([1 Img_Size(1)],[1 Img_Size(2)],X, ...
                'Visible',vis,'Parent',Axe_ImgIni);
        set(Axe_ImgIni,'Visible',vis,'Tag',tag_axeimgini);
        wtitle('Original Synthesized Image','Parent',Axe_ImgIni);
        axes(Axe_ImgSyn);
        image([1 Img_Size(1)],[1 Img_Size(2)],X, ...
                'Visible',vis,'Parent',Axe_ImgSyn);
        set(Axe_ImgSyn,'Visible',vis,'Tag',tag_axeimgsyn);
        wtitle('Synthesized Image','Parent',Axe_ImgSyn);

        delete(findobj(Axe_ImgVis,'Type','image'));

        % Setting enabled values.
        %------------------------
        dw2dutil('enable',win_dw2dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'step2'
        %*****************************************************%
        %** OPTION = 'step2' - (load_dec & demo & analyze)  **%
        %*****************************************************%
        % in3 = calling option
        %---------------------

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Name,Img_Size,...
         NB_ColorsInPal,Wave_Name,Level_Anal] = ...
                 wmemtool('rmb',win_dw2dtool,n_param_anal, ...
                                ind_img_name, ...
                                ind_img_size, ...
                                ind_nbcolors, ...
                                ind_wav_name, ...
                                ind_lev_anal  ...
                                );

        % Setting axes properties.
        %-------------------------
        Axe_ImgDec = wmemtool('rmb',win_dw2dtool,tag_axeimgdec,1);
        set(Axe_ImgDec,'Visible','Off');
        Axe_ImgDec = Axe_ImgDec(1:4*Level_Anal);
        indVis = [1:4*Level_Anal];
        indVis = [indVis(mod(indVis,4)~=0),indVis(end)];
        set(Axe_ImgDec(indVis),'Visible','On');

        % Getting Select Function.
        %------------------------
        select_funct = wmemtool('rmb',win_dw2dtool,n_miscella,ind_sel_funct);

        % Begin waiting.
        %---------------
        wwaiting('msg',win_dw2dtool,'Wait ... computing');

        % Computing.
        %-----------
        if strcmp(in3,'demo') | strcmp(in3,'analyze')
            img_anal      = get(dw2drwcd('r_orig',win_dw2dtool),'Cdata');
            [coefs,sizes] = wavedec2(img_anal,Level_Anal,Wave_Name);
            clear img_anal

            % Setting coefs and sizes.
            %-------------------------
            wmemtool('wmb',win_dw2dtool,n_coefs,1,coefs);
            wmemtool('wmb',win_dw2dtool,n_sizes,1,sizes);
        else
            % Getting Analysis values.
            %-------------------------
            coefs = wmemtool('rmb',win_dw2dtool,n_coefs,1);
            sizes = wmemtool('rmb',win_dw2dtool,n_sizes,1);
        end
        
        % App flag.
        %----------
        if strcmp(in3,'load_cfs') | strcmp(in3,'new_synt')
            app_flg = 0;
        else
            app_flg = 1;
        end

        % Decomposition drawing
        %----------------------
        size0 = sizes(1,:);
        Img_Handles = zeros(1,4*Level_Anal);
        for k=1:Level_Anal
            for m=1:4
                switch m
                    case 1 , Y = detcoef2('v',coefs,sizes,k);
                    case 2 , Y = detcoef2('d',coefs,sizes,k);
                    case 3 , Y = detcoef2('h',coefs,sizes,k);
                    case 4
                        if app_flg | k==Level_Anal
                            Y = appcoef2(coefs,sizes,Wave_Name,k);
                        else
                            Y = zeros(size(Y));
                        end
                   otherwise , error('*');
                end
                if (m==4) & (k~=Level_Anal)
                    vis = 'Off'; 
                else
                    vis = 'On'; 
                end
                num_img = 4*(k-1)+m;
                axeAct  = Axe_ImgDec(num_img);
                axes(axeAct)
                %-------------------------------%
                %-   k = level ;
                %-   m = 1 : v ;   m = 2 : d ;         
                %-   m = 3 : h ;   m = 4 : a ; 
                %-------------------------------%
                trunc_p = [k Img_Size(2) Img_Size(1)];
                Y = wimgcode('cod',1,Y,NB_ColorsInPal,codemat_v,trunc_p);
                Img_Handles(num_img) = ...
                        image([1 Img_Size(1)],[1 Img_Size(2)],Y,...
                              'Parent',axeAct,             ...
                              'Visible',vis,               ...
                              'UserData',[0;k;m],          ...
                              'Tag',tag_imgdec,            ...
                              'ButtonDownFcn',select_funct ...
                              );
                set(axeAct,...
                    'Visible',vis,                    ...
                    'Xcolor',Col_BoxAxeSel,           ...
                    'Ycolor',Col_BoxAxeSel,           ...
                    'XTicklabelMode','manual',        ...
                    'YTicklabelMode','manual',        ...
                    'XTicklabel',[],'YTicklabel',[],  ...
                    'XTick',[],'YTick',[],'Box','On', ...
                    'Tag',tag_axeimgdec               ...
                    );
            end
        end
        wmemtool('wmb',win_dw2dtool,tag_axeimghdls,1,Img_Handles);

        % Decomposition Title.
        %---------------------
        wsetxlab(Axe_ImgSel,sprintf('Decomposition at level %.0f',Level_Anal));

        % Synthesized Image (same that original).
        %----------------------------------------
        if strcmp(in3,'demo') | strcmp(in3,'analyze')
            X      = appcoef2(coefs,sizes,Wave_Name,0);
            X      = wimgcode('cod',0,X,NB_ColorsInPal,codemat_v);
            gx     = get(Axe_ImgSyn,'Xgrid');
            gy     = get(Axe_ImgSyn,'Ygrid');
            strtit = get(get(Axe_ImgSyn,'title'),'String');
            image([1 Img_Size(1)],[1 Img_Size(2)],X,'Parent',Axe_ImgSyn);
            set(Axe_ImgSyn,...
                'Visible','On',           ...
                'Xgrid',gx,'Ygrid',gy,    ...
                'XTicklabelMode','manual',...
                'YTicklabelMode','manual',...
                'XTicklabel',[],          ...
                'YTicklabel',[],          ...
                'Box','On',               ...
                'Tag',tag_axeimgsyn       ...
                );
            wtitle(strtit,'Parent',Axe_ImgSyn);
        end

        % Setting Dynamic Visualization tool.
        %------------------------------------
        dynvtool('init',win_dw2dtool,...
                        [],...
                        [Axe_ImgIni Axe_ImgBig Axe_ImgSyn Axe_ImgVis],...
                        [Axe_ImgDec],...
                        [1 1],'','','','int');

        % Setting view_status.
        %---------------------
        view_status = ['s_l' sprintf('%.0f',Level_Anal)];
        wmemtool('wmb',win_dw2dtool,n_miscella, ...
                       ind_view_status,view_status,...
                       ind_save_status,view_status ...
                       );

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'view_dec'
        %**********************************************%
        %** OPTION = 'view_dec' - view decomposition **%
        %**********************************************%
        % Getting position parameters.
        %-----------------------------
        [view_status,save_status] = ...
                wmemtool('rmb',win_dw2dtool,n_miscella, ...
                               ind_view_status,ind_save_status ...
                               );
        new_lev_view = get(pop_declev,'Value');
        k = findstr(view_status,'l');
        lev_old = wstr2num(view_status(k+1:length(view_status)));
        if new_lev_view==lev_old , return; end
        dw2dimgs('cleanif',win_dw2dtool,new_lev_view,lev_old);
        view_status = [view_status(1:k) sprintf('%.0f',new_lev_view)];
        wmemtool('wmb',win_dw2dtool,n_miscella,ind_view_status,view_status);

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw2dtool,'Wait ... drawing');

        % Drawing.
        %---------
        dw2dmngr('set_graphic',win_dw2dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'select'
        % Getting active option.
        %------------------------
        active_option = wmemtool('rmb',win_dw2dtool,n_param_anal,ind_act_option);

        Drag_Tools = [pus_visu,pus_big,pus_rec];
        if nargin==3 , in4 = 0; end
        if strcmp(in3,'end_big')
            % End Big Image.
            %---------------
            dw2dmngr('set_graphic',win_dw2dtool,option,'end');
            handles = [pus_anal, pop_declev, pus_visu, ...
                       pus_rec,  pop_viewm,  pus_full  ...
                       ];
            set(handles,'Enable','On');
            cba_pus_big  = ['dw2dmngr(''select'','  ...
                            str_numwin ','  ...
                            num2mstr(pus_big) ');'];
            bk_col = get(pus_visu,'BackGroundColor');
            set(pus_big,...
                    'String',xlate('Full Size'),     ...
                    'BackGroundColor',bk_col, ...
                    'Callback',cba_pus_big    ...
                    );
            val = get(pop_viewm,'Value');
            if (val==square_viewm)
                dw2darro('vis_arrow',win_dw2dtool,'on');
            end
            ind = 0;
		    dynvtool('dynvzaxe_BtnOnOff',win_dw2dtool,'On')

        else
            obj_sel = dw2dimgs('get',win_dw2dtool);
            if ~isempty(obj_sel)
                ind = find(in3==Drag_Tools);
            else
                ind = 0;
            end
        end

        if ind~=0
            % Getting  Analysis parameters.
            %------------------------------
            if strcmp(get(Drag_Tools(ind),'Enable'),'off') , return; end

            Img_Handles = wmemtool('rmb',win_dw2dtool,tag_axeimghdls,1);
            indimg      = find(Img_Handles==obj_sel);
            if isempty(indimg) , return; end

            % Begin waiting.
            %--------------
            wwaiting('msg',win_dw2dtool,'Wait ... computing');

            [Img_Size,Wave_Name,Level_Anal] = ...
                    wmemtool('rmb',win_dw2dtool,n_param_anal, ...
                                   ind_img_size, ...
                                   ind_wav_name, ...
                                   ind_lev_anal  ...
                                   );

            Axe_ImgDec = wmemtool('rmb',win_dw2dtool,tag_axeimgdec,1);
            Axe_ImgDec = Axe_ImgDec(1:4*Level_Anal);

            % Computing.
            %----------------------------%
            %-   m = 1 : v ;   m = 2 : d ;             
            %-   m = 3 : h ;   m = 4 : a ;     
            %----------------------------%
            us = get(Img_Handles(indimg),'UserData');
            us = get(obj_sel,'UserData');
            level = us(2,:);
            m     = us(3,:);
            str_lev = sprintf('%.0f',level);
            switch m
              case 1 , opt = 'v'; typestr = 'Vertical detail';
              case 2 , opt = 'd'; typestr = 'Diagonal detail';
              case 3 , opt = 'h'; typestr = 'Horizontal detail';
              case 4 , opt = 'a'; typestr = 'Approximation';
            end
            switch ind
                case {1,2}    %-- Visualize or big image
                    X = get(obj_sel,'CData');
                    strxlab = [typestr ' coef. at level ' str_lev];
                    axe = get(obj_sel,'Parent');
                    xl = get(axe,'Xlim');
                    yl = get(axe,'Ylim');

                case 3   %-- Reconstruction
                    NB_ColorsInPal = wmemtool('rmb',win_dw2dtool, ...
                                                    n_param_anal,  ...
                                                    ind_nbcolors   ...
                                                    );
                    coefs = wmemtool('rmb',win_dw2dtool,n_coefs,1);
                    sizes = wmemtool('rmb',win_dw2dtool,n_sizes,1);

                    X = wrcoef2(opt,coefs,sizes,Wave_Name,level);
                    if opt=='a' , flg_code = 0; else , flg_code = 1; end
                    X = wimgcode('cod',flg_code,X,NB_ColorsInPal,codemat_v);
                    strxlab = ['Recons. ' typestr ' coef. of level ' str_lev];
                    xl = get(Axe_ImgIni,'Xlim');
                    yl = get(Axe_ImgIni,'Ylim');
            end
            if ind~=2       % Drawing (little image)
                gx = get(Axe_ImgVis,'Xgrid');
                gy = get(Axe_ImgVis,'Ygrid');
                image([1 Img_Size(1)],[1 Img_Size(2)],X,'Parent',Axe_ImgVis);
                set(Axe_ImgVis,...
                    'Visible','On',            ...
                    'Xgrid',gx,'Ygrid',gy,     ...
                    'Xlim',xl,'Ylim',yl,       ...
                    'XTicklabel',[],           ...
                    'YTicklabel',[],           ...
                    'Xcolor',BoxTitleSel_Col,  ...
                    'Ycolor',BoxTitleSel_Col,  ...
                    'LineWidth',Width_LineSel, ...
                    'Box','On',                ...
                    'Tag',tag_axeimgvis        ...
                    );
                wtitle(strxlab,'Parent',Axe_ImgVis);

            else            % Drawing (big image)
                [row,col] = size(X);
                strxlab   = [strxlab '  -- image size : ('        ...
                             sprintf('%.0f',row) ',' sprintf('%.0f',col) ')'];

                % Setting enabled values.
                %------------------------
				dynvtool('dynvzaxe_BtnOnOff',win_dw2dtool,'Off')
                handles = [ pus_anal, pop_declev, pus_visu, ...
                            pus_rec,  pop_viewm,  pus_full  ...
                            ];
                set(handles,'Enable','Off');
                set(pus_big,                               ...
                        'String',xlate('End Full Size'),          ...
                        'BackGroundColor',Def_TxtBkColor,  ...
                        'Callback',                        ...
                        ['dw2dmngr(''select'',' str_numwin ...
                                 ',''end_big'');']         ...
                        );
                axe_figutil = findobj(get(win_dw2dtool,'Children'),...
                                    'flat','type','axes',      ...
                                    'Tag',tag_axefigutil...
                                    );
                t_lines = findobj(axe_figutil,'type','line','Tag',tag_linetree);
                t_txt   = findobj(axe_figutil,'type','text','Tag',tag_txttree);

                for k=1:4*Level_Anal
                    ax = Axe_ImgDec(k);
                    set(get(ax,'Children'),'Visible','Off');
                    set(ax,'Visible','Off');
                end
                set(findobj([Axe_ImgIni,Axe_ImgVis,...
                             Axe_ImgSyn,Axe_ImgSel]),'visible','off');
                wboxtitl('vis',Axe_ImgSel,'off');
                set([t_lines' t_txt'],'Visible','off');
                dw2darro('vis_arrow',win_dw2dtool,'off');

                gx = get(Axe_ImgBig,'Xgrid');
                gy = get(Axe_ImgBig,'Ygrid');
                image([1 Img_Size(1)],[1 Img_Size(2)],X,...
                      'Parent',Axe_ImgBig);
                set(Axe_ImgBig, ...
                    'Visible','On',        ...
                    'Xgrid',gx,'Ygrid',gy, ...
                    'XTicklabel',[],       ...
                    'YTicklabel',[],       ...
                    'Xlim',xl,'Ylim',yl,   ...
                    'Tag',tag_axeimgbig    ...
                    );
                wsetxlab(Axe_ImgBig,strxlab);

                % Changing View Status.
                %----------------------
                view_status = wmemtool('rmb',win_dw2dtool, ...
                                        n_miscella,ind_view_status);
                wmemtool('wmb',win_dw2dtool,n_miscella,...
                               ind_save_status,view_status);
                view_status = ['b' sprintf('%.0f',indimg) ...
                                'l' sprintf('%.0f',get(pop_declev,'Value'))];
                wmemtool('wmb',win_dw2dtool,n_miscella,...
                               ind_view_status,view_status);
            end

            % End waiting.
            %--------------
            wwaiting('off',win_dw2dtool);
        end

    case 'view_mode'
        % Getting & Setting View_status.
        %-------------------------------
        view_status = wmemtool('rmb',win_dw2dtool,n_miscella,ind_view_status);
        val = get(pop_viewm,'Value');
        if view_status(1)=='s'
            if val==square_viewm , return; end
            view_status(1) = 't';
        elseif view_status(1)=='t'
            if val==tree_viewm , return; end
            view_status(1) = 's';
        end
        wmemtool('wmb',win_dw2dtool,n_miscella, ...
                       ind_view_status,view_status, ...
                       ind_save_status,view_status  ...
                       );
        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw2dtool,'Wait ... drawing');
        
        pos = zeros(4,4);
        pos(1,:) = get(pus_full(1),'Position');
        if val==square_viewm
            pos(1,3) = (3*pos(1,3))/2;
            pos(2,:) = pos(1,:); pos(2,2) = pos(2,2)-pos(2,4);
            pos(3,:) = pos(1,:); pos(3,1) = pos(3,1)+pos(3,3);
            pos(4,:) = pos(3,:);
            pos(4,2) = pos(4,2)-pos(4,4);
        else
            pos(1,3) = (2*pos(1,3))/3;
            pos(2,:) = pos(1,:); pos(2,1) = pos(2,1)+pos(2,3);
            pos(3,:) = pos(2,:); pos(3,1) = pos(3,1)+pos(3,3);
            pos(4,:) = pos(1,:);
            pos(4,3) = 3*pos(4,3);
            pos(4,2) = pos(4,2)-pos(4,4);
        end

        dw2darro('vis_arrow',win_dw2dtool,'off');

        % Cleaning Selection.
        %--------------------
        dw2dimgs('clean',win_dw2dtool);

        % Drawing.
        %---------
        dw2dmngr('set_graphic',win_dw2dtool,option);

        set([txt_full,pus_full],'Visible','off');
        for k=1:4 , set(pus_full(k),'Position',pos(k,:)); end
        pos_txt = get(txt_full,'Position');
        d_txt   = pos(1,4)-pos_txt(4);
        if val==square_viewm
            hdl_on = [txt_full,pus_full];
            pos_txt(2) = pos(1,2)-pos_txt(1,4)/2;
        else
            hdl_on = [txt_full,pus_full(1:3)];
            pos_txt(2) = pos(1,2)+d_txt/2;
        end
        set(txt_full,'Position',pos_txt);
        set(hdl_on,'Visible','on');

        if val==square_viewm
            dw2darro('vis_arrow',win_dw2dtool,'on');
        end

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'fullsize'
        % in3 = btn number.
        %------------------

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw2dtool,'Wait ... drawing');

        % Getting active option.
        %------------------------
        active_option = wmemtool('rmb',win_dw2dtool,n_param_anal,...
                                       ind_act_option);

        % Test begin or end.
        %-------------------
        num = in3;
        btn = pus_full(num);
        act = get(btn,'Userdata');
        if act==0
            % begin full size
            %----------------
            dw2darro('vis_arrow',win_dw2dtool,'off');
            param = 'beg';
            for k=1:length(pus_full)
                act_old = get(pus_full(k),'Userdata');
                if act_old==1
                    other_btn = pus_full(length(pus_full)+1-k);
                    old_col = get(other_btn,'Backgroundcolor');
                    set(pus_full(k),...
                        'Backgroundcolor',old_col,  ...
                        'String',sprintf('%.0f',k), ...
                        'Userdata',0);
                    break;
                end
            end
            set(btn,'Backgroundcolor',Def_TxtBkColor,      ...
                    'String',['end ' sprintf('%.0f',num)], ...
                    'Userdata',1);
				
			if num==4 , ena_DynV = 'On'; else , ena_DynV = 'Off'; end
			
            % Changing View Status.
            %----------------------
            view_status = wmemtool('rmb',win_dw2dtool,n_miscella,...
                                         ind_view_status);
            if view_status(1)~='f'
                wmemtool('wmb',win_dw2dtool,n_miscella,...
                                    ind_save_status,view_status);
            end
            view_status = ['f' sprintf('%.0f',num) 'l' ...
                               sprintf('%.0f',get(pop_declev,'value'))];
            wmemtool('wmb',win_dw2dtool,n_miscella,ind_view_status,view_status);
        else
            % end full size.
            %---------------
            other_btn = pus_full(length(pus_full)+1-num);
            old_col = get(other_btn,'Backgroundcolor');
            param = 'end';
            set(btn,'Backgroundcolor',old_col,    ...
                    'String',sprintf('%.0f',num), ...
                    'Userdata',0);
			ena_DynV = 'On'; 				
        end
		dynvtool('dynvzaxe_BtnOnOff',win_dw2dtool,ena_DynV)

        % Setting enabled values.
        %------------------------
        handles = [pus_anal, pus_visu, pus_big, pus_rec, pop_viewm];
        if strcmp(param,'end')
            ena = 'on';
            handles = [handles , pop_declev];
        elseif find(num==[1 2 3])
            ena_val = 0; ena = 'off';
            handles = [handles , pop_declev];
        elseif num==4
            ena = 'off';
        end

        % Drawing.
        %---------
        if strcmp(ena,'off') , set(handles,'Enable',ena); end
        dw2dmngr('set_graphic',win_dw2dtool,option,param);
        if strcmp(ena,'on')
            set(handles,'Enable',ena);
        elseif num==4
            set(pop_declev,'Enable','On');
        end
        val = get(pop_viewm,'Value');
        if (val==square_viewm) & strcmp(param,'end')
            dw2darro('vis_arrow',win_dw2dtool,'on');
        end

        % End waiting.
        %-------------
        wwaiting('off',win_dw2dtool);

    case 'stat'
        set(wfindobj('figure'),'Pointer','watch');
        out1 = feval('dw2dstat','create',win_dw2dtool);

    case 'hist'
        set(wfindobj('figure'),'Pointer','watch');
        out1 = feval('dw2dhist','create',win_dw2dtool);

    case 'comp'
        set(wfindobj('figure'),'Pointer','watch');
        dw2dutil('enable',win_dw2dtool,option);
        out1 = feval('dw2dcomp','create',win_dw2dtool);

    case 'deno'
        set(wfindobj('figure'),'Pointer','watch');
        dw2dutil('enable',win_dw2dtool,option);
        out1 = feval('dw2ddeno','create',win_dw2dtool);

    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hdl_img (optional)
        %--------------------------------------

        if in3==1
            % Begin waiting.
            %--------------
            wwaiting('msg',win_dw2dtool,'Wait ... computing');

            if strcmp(option,'return_comp')
                arro_txt = 'comp';      t_simg = 'cs';
                xlab_str = 'Compressed Image';
            else
                arro_txt = 'deno';      t_simg = 'ds';
                xlab_str = 'De-noised Image';
            end
            wmemtool('wmb',win_dw2dtool,n_param_anal, ...
                           ind_simg_type,t_simg       ...
                           );

            [Wave_Name,Img_Size,NB_ColorsInPal] = ...
                    wmemtool('rmb',win_dw2dtool,n_param_anal,...
                                   ind_wav_name,ind_img_size,ind_nbcolors);

            % Drawing Synthesized Image.
            %--------------------------
            view_status = wmemtool('rmb',win_dw2dtool,n_miscella,ind_view_status);
            view_mode   = view_status(1);

            if (view_mode=='f') & (view_status(2)~='2')
                vis = 'Off';
            else
                vis = 'on';
            end
            if (view_mode=='s') , vis_ar = 'On'; else , vis_ar = 'Off'; end
            xlim = get(Axe_ImgIni,'Xlim');
            ylim = get(Axe_ImgIni,'Ylim');
            axes(Axe_ImgSyn);
            image(...
                    [1 Img_Size(1)],[1 Img_Size(2)],        ...
                    wimgcode('cod',0,get(in4,'Cdata'),NB_ColorsInPal,codemat_v), ...
                    'Visible',vis,                           ...
                    'Parent',Axe_ImgSyn                      ...
                    );
            col = get(get(Axe_ImgSyn,'xlabel'),'Color');
            set(Axe_ImgSyn,...
                'Visible',vis,                  ...
                'XTicklabelMode','manual',      ...
                'YTicklabelMode','manual',      ...
                'XTicklabel',[],'YTicklabel',[],...
                'Xlim',xlim,'Ylim',ylim,        ...
                'Box','On',                     ...
                'Tag',tag_axeimgsyn             ...
                );
            wtitle(xlab_str,'Color',col,...
                            'Visible',vis,...
                            'Parent',Axe_ImgSyn);

            dw2darro('vis_arrow',win_dw2dtool,vis_ar,arro_txt);

            % End waiting.
            %-------------
            wwaiting('off',win_dw2dtool);
        end
        dw2dutil('enable',win_dw2dtool,option);

    case 'set_graphic'
        % in3 = calling option.
        %  if in3 = 'fullsize' :
        %     in4 = 'beg' or 'end'.
        %  if in3 = 'select' :
        %     in4 = 'beg' or 'end'.
        %-----------------------------

        % Getting Analysis parameters.
        %-----------------------------
        [Img_Size,Level_Anal] = wmemtool('rmb',win_dw2dtool,n_param_anal,...
                                               ind_img_size,ind_lev_anal);
        level_view = get(pop_declev,'Value');

        % Getting Axes handles.
        %----------------------
        Axe_ImgDec  = wmemtool('rmb',win_dw2dtool,tag_axeimgdec,1);
        Img_Handles = wmemtool('rmb',win_dw2dtool,tag_axeimghdls,1);

        % Getting position parameters.
        %-----------------------------
        [ pos,pos_axeini,pos_axevis,pos_axesel,   ...
          pos_axesyn,pos_axebig,pos_axedec,view_status,save_status] = ...
                  wmemtool('rmb',win_dw2dtool,n_miscella, ...
                                 ind_graph_area,  ...
                                 ind_pos_axeini,  ...
                                 ind_pos_axevis,  ...
                                 ind_pos_axesel,  ...
                                 ind_pos_axesyn,  ...
                                 ind_pos_axebig,  ...
                                 ind_pos_axedec,  ...
                                 ind_view_status, ...
                                 ind_save_status  ...
                                 );
        k = findstr(save_status,'l');
        lev_view_old = wstr2num(save_status(k+1:length(save_status)));

        % Setting options.
        %-----------------
        obj_sel = [];
        switch in3
            case 'fullsize'
                if strcmp(in4,'beg')
                    view_attrb = 10+wstr2num(view_status(2));
                else
                    view_status = save_status;
                    wmemtool('wmb',win_dw2dtool,n_miscella,...
                                            ind_view_status,view_status);
                    switch view_status(1)
                        case 's' , view_attrb = 5;
                        case 't' , view_attrb = 6;
                    end
                    obj_sel = dw2dimgs('get',win_dw2dtool);
                end

            case 'select'       % end big_image
                view_status = save_status;
                wmemtool('wmb',win_dw2dtool,n_miscella,...
                                        ind_view_status,view_status);
                switch view_status(1)
                    case 's' , view_attrb = 5;
                    case 't' , view_attrb = 6;
                end
                obj_sel = dw2dimgs('get',win_dw2dtool);

            case 'view_dec'
                save_status = [save_status(1:k) sprintf('%.0f',level_view)];
                wmemtool('wmb',win_dw2dtool,n_miscella,...
                                        ind_save_status,save_status);
                switch view_status(1) 
                    case {'s','f'} , view_attrb = 3;
                    case 't' ,       view_attrb = 4;
                end

            case 'view_mode'
                switch view_status(1)
                    case 's' , view_attrb = 5;
                    case 't' , view_attrb = 6;
                end
        end

        % Computing axes positions.
        %--------------------------
        if view_status(1)=='t'
            % Getting position parameters.
            %-----------------------------
            term_dim      = Terminal_Prop;
            [xpixl,ypixl] = wfigutil('prop_size',win_dw2dtool,1,1);

            % View boundary parameters.
            %--------------------------
            mx = 0.73;  my = 0.70;

            x_marge = 0.05;
            x_left  = pos(1)+x_marge;
            width   = pos(3)-x_marge;
            NBL     = level_view+1; NBC     = 4;
            w_theo  = width/NBC;    h_theo  = pos(4)/NBL;
            w_pos   = w_theo*mx;    h_pos = h_theo*my;
            X_cent  = x_left+(w_theo/2)*[1:2:2*NBC-1];
            Y_cent  = pos(2)+(h_theo/2)*[1:2:2*NBL-1];
            alpha   = (term_dim(2)*h_pos*Img_Size(1))/...
                      (term_dim(1)*w_pos*Img_Size(2));
            w_used  = w_pos*min(1,alpha);
            h_used  = h_pos*min(1,1/alpha);

            dy  = (h_theo-h_used)/2;
            ind = [2:NBL-1];
            Y_cent(ind) = Y_cent(ind)-dy*(ind-1); 
            if NBL>Level_Anal-2
                Y_cent(NBL) = Y_cent(NBL)-(level_view*dy)/(NBL-1);
            end

            % Correction : Y-Shift
            %---------------------
            if level_view>max_lev_anal-2
                Y_cent(1:NBL-1) = Y_cent(1:NBL-1)+25*ypixl;
                bdy = 3*ypixl;
            else
                bdy = 0*ypixl;
            end

            w_u2 = w_used/2;  h_u2 = h_used/2;
            pos_axeini = [ X_cent(1)-w_u2 , Y_cent(NBL)-h_u2 ,...
                           w_used         , h_used           ];
            pos_axesyn = [ X_cent(2)-w_u2 , Y_cent(NBL)-h_u2 ,...
                           w_used         , h_used           ];
            pos_axevis = [ X_cent(3)      , Y_cent(NBL)-h_u2 ,...
                           w_used         , h_used           ];

            bdy = 0*ypixl;
            xl  = pos(1)+20*xpixl;
            wa  = pos(3)-40*xpixl;
            yd  = Y_cent(1)-h_u2-bdy;
            ha  = Y_cent(NBL-1)-Y_cent(1)+h_used+bdy;
            [ha,yd] = depOfMachine(ypixl,ha,yd);
            pos_axesel = [xl yd wa ha];

            max_l   = max_lev_anal+1;
            l_Xdata = zeros(max_l,2);
            l_Ydata = zeros(max_l,2);
            for k = 1:level_view
                for l = 1:4
                    ind = 4*(level_view-k+1)+1-l;
                    pos_axedec(ind,:) = [X_cent(l)-w_u2  ,...
                                         Y_cent(k)-h_u2  ,...
                                         w_used          ,...
                                         h_used  ];
                end
                l_Xdata(k,:) = [X_cent(1) X_cent(NBC)];
                l_Ydata(k,:) = [Y_cent(k) Y_cent(k)];
            end
            l_Xdata(max_l,:) = [X_cent(1),  X_cent(1)];
            l_Ydata(max_l,:) = [Y_cent(NBL),Y_cent(1)];
            x_left_txt = pos_axeini(1)-0.035;
        end

        max_a   = 4*Level_Anal;
        max_v   = 4*level_view;
        all_ind = [1:max_a];
        rem_4   = rem(all_ind,4);
        switch view_status(1)
            case 's'
                vis_ini = 'on';  vis_vis = 'on';
                vis_sel = 'on';  vis_syn = 'on';
                vis_big = 'off';
                ind_On  = [find(all_ind<max_v & rem_4~=0) , max_v];
                ind_Off = [find(all_ind<max_v & rem_4==0) , ...
                                        find(all_ind>max_v)];

            case 't'
                vis_ini = 'on';  vis_vis = 'on';
                vis_sel = 'on';  vis_syn = 'on';
                vis_big = 'off';
                ind_On  = 1:max_v;  ind_Off = max_v+1:max_a;

            case 'f'
                switch view_status(2)
                    case '1'
                        pos_axeini = pos_axebig;
                        vis_ini = 'on';  vis_vis = 'off';
                        vis_sel = 'off'; vis_syn = 'off';
                        vis_big = 'off';
                        ind_On  = [];    ind_Off = all_ind;

                    case '2'
                        pos_axesyn = pos_axebig;
                        vis_ini = 'off'; vis_vis = 'off';
                        vis_sel = 'off'; vis_syn = 'on';
                        vis_big = 'off';
                        ind_On  = [];    ind_Off = all_ind;

                    case '3'
                        pos_axevis = pos_axebig;
                        vis_ini = 'off'; vis_vis = 'on';
                        vis_sel = 'off'; vis_syn = 'off';
                        vis_big = 'off';
                        ind_On  = [];    ind_Off = all_ind;

                    case '4'
                        pos_axesel = pos_axebig;
                        xl = pos_axesel(1);
                        yb = pos_axesel(2);
                        la = pos_axesel(3)/2;
                        ha = pos_axesel(4)/2;
                        ind = 1;
                        for k = 1:max_lev_anal
                            pos_axedec(ind:ind+3,1:4) = ...
                                    [xl   , yb   , la, ha;
                                     xl+la, yb   , la, ha;
                                     xl+la, yb+ha, la, ha;
                                     xl   , yb+ha, la, ha ...
                                    ];
                            ind = ind+4;
                            yb = yb+ha; la = la/2; ha = ha/2;
                        end

                        vis_ini = 'off'; vis_vis = 'off';
                        vis_sel = 'on';  vis_syn = 'off';
                        vis_big = 'off';
                        ind_On  = [find(all_ind<max_v & rem_4~=0) , max_v];
                        ind_Off = [find(all_ind<max_v & rem_4==0) , ...
                                        find(all_ind>max_v)];
                end
        end     

        % Setting graphic area.
        %----------------------
        axe_figutil = findobj(axe_handles,'Tag',tag_axefigutil);
        t_lines     = findobj(axe_figutil,'type','line','Tag',tag_linetree);
        t_txt       = findobj(axe_figutil,'type','text','Tag',tag_txttree);
        set([t_lines' t_txt'],'Visible','off'); 
        set(Img_Handles,'Visible','Off');
        ind = 4*lev_view_old;
        delete([...
                get(Axe_ImgDec(ind),'Xlabel'),...
                get(Axe_ImgDec(ind-1),'Xlabel'),...
                get(Axe_ImgDec(ind-2),'Xlabel'),...
                get(Axe_ImgDec(ind-3),'Xlabel'),...
                ]);
        switch view_status(1)
            case 'f'
                switch view_status(2)
                    case '1' , set(Axe_ImgIni,'Position',pos_axeini);
                    case '2' , set(Axe_ImgSyn,'Position',pos_axesyn);
                    case '3' , set(Axe_ImgVis,'Position',pos_axevis);
                    case '4'
                        set(Axe_ImgSel,'Position',pos_axesel);
                        for k = 1:4*max_lev_anal
                            set(Axe_ImgDec(k),'Position',pos_axedec(k,:));
                        end
                end

            case {'s','t'}
                set(Axe_ImgIni,'Position',pos_axeini);
                set(Axe_ImgVis,'Position',pos_axevis);
                set(Axe_ImgSyn,'Position',pos_axesyn);
                set(Axe_ImgSel,'Position',pos_axesel);
                for k = 1:4*max_lev_anal
                    set(Axe_ImgDec(k),'Position',pos_axedec(k,:));
                end
        end
        set(findobj(Axe_ImgIni),'visible',vis_ini);
        set(findobj(Axe_ImgVis),'visible',vis_vis);
        set(findobj(Axe_ImgSyn),'visible',vis_syn);
        set(findobj(Axe_ImgSel),'visible',vis_sel);
        set(findobj(Axe_ImgBig),'visible',vis_big);
        s_font = Def_AxeFontSize;
        if view_status(1)=='t'
            bdy = 18;
            strxlab = sprintf('Decomposition at level %.0f',level_view); 
            box_str = ['Image Selection : ' strxlab];
            wboxtitl('set',Axe_ImgSel,box_str,s_font,9,10,bdy,vis_sel);
        else
            bdy = 18;
            box_str = 'Image Selection';
            wboxtitl('set',Axe_ImgSel,box_str,s_font,9,18,bdy,vis_sel);
        end

        switch view_attrb
            case 4
                for k = [1:level_view,max_lev_anal+1]
                    l = findobj(t_lines,'Type','line','Userdata',k);
                    set(l,...
                         'Xdata',l_Xdata(k,:),...
                         'Ydata',l_Ydata(k,:),...
                         'Visible','On'       ...
                         );
                end
                for k = [1:level_view]
                    txt = findobj(t_txt,'Type','text','Userdata',k);
                    j = level_view+1-k;
                    set(txt,...
                           'Position',[x_left_txt ,l_Ydata(j,1)], ...
                           'Visible','On'                         ...
                           );
                end
                set(Axe_ImgSel,'Visible','Off');

            case 5
                set([Axe_ImgDec,Axe_ImgIni,Axe_ImgVis,Axe_ImgSel,Axe_ImgSyn],...
                                'Visible','off');
                ind = 4*level_view;
                delete([...
                        get(Axe_ImgDec(ind),'Xlabel'),  ...
                        get(Axe_ImgDec(ind-1),'Xlabel'),...
                        get(Axe_ImgDec(ind-2),'Xlabel'),...
                        get(Axe_ImgDec(ind-3),'Xlabel') ...
                        ]);

            case 6
                set([Axe_ImgDec,Axe_ImgIni,Axe_ImgVis,Axe_ImgSel,Axe_ImgSyn],...
                                'Visible','off');
                for k = [1:level_view,max_lev_anal+1]
                    l = findobj(t_lines,'Type','line','Userdata',k);
                    set(l,...
                        'Xdata',l_Xdata(k,:),...
                        'Ydata',l_Ydata(k,:),...
                        'Visible','On'       ...
                        );
                end
                for k = [1:level_view]
                    txt = findobj(t_txt,'Type','text','Userdata',k);
                    j = level_view+1-k;
                    set(txt,...
                        'Position',[x_left_txt ,l_Ydata(j,1)], ...
                        'Visible','On'                         ...
                        );
                end
        end

        if find(view_attrb==[5 6])
                if view_attrb==5
                    set([Axe_ImgIni,Axe_ImgSel],'Visible','on','Box','On');
                else
                    set(Axe_ImgIni,...
                        'Visible','on',                 ...
                        'XTicklabelMode','manual',      ...
                        'YTicklabelMode','manual',      ...
                        'XTicklabel',[],'YTicklabel',[],...
                        'XTick',[],'YTick',[],          ...
                        'Box','On');
                end
                for k = 1:length(ind_On) , axes(Axe_ImgDec(k)); end
                set(Axe_ImgDec(ind_On),...
                    'Visible','on',...
                    'Xcolor',Col_BoxAxeSel,         ...
                    'Ycolor',Col_BoxAxeSel,         ...
                    'XTicklabelMode','manual',      ...
                    'YTicklabelMode','manual',      ...
                    'XTicklabel',[],'YTicklabel',[],...
                    'XTick',[],'YTick',[],'Box','On'...
                    );

                if ~isempty(obj_sel)
                    axe = get(obj_sel,'parent');
                    set(axe,...
                        'Xcolor',BoxTitleSel_Col, ...
                        'Ycolor',BoxTitleSel_Col, ...
                        'LineWidth',Width_LineSel,...
                        'Box','On'                ...
                        );
                end
                                       
                set(Axe_ImgVis,...
                    'Visible','on',                 ...
                    'XTicklabelMode','manual',      ...
                    'YTicklabelMode','manual',      ...
                    'XTicklabel',[],'YTicklabel',[],...
                    'Xcolor',BoxTitleSel_Col,       ...
                    'Ycolor',BoxTitleSel_Col,       ...
                    'LineWidth',Width_LineSel,      ...
                    'Box','On'                      ...
                    );
                set(Axe_ImgSyn,...
                    'Visible','on',                 ...
                    'XTicklabelMode','manual',      ...
                    'YTicklabelMode','manual',      ...
                    'XTicklabel',[],'YTicklabel',[],...
                    'Box','On'                      ...
                    );
  
        end

        if find(view_attrb==[3 4 5 6 11 12 13 14])
            set(Img_Handles(ind_On),'Visible','On');
            set(Axe_ImgDec(ind_On),'Visible','On');
            if ~isempty(ind_Off)
                set(Img_Handles(ind_Off),'Visible','Off');
                set(Axe_ImgDec(ind_Off),'Visible','Off');
            end
        end

        if view_attrb==5
            strxlab = sprintf('Decomposition at level %.0f',level_view); 
            wsetxlab(Axe_ImgSel,strxlab);

        elseif find(view_attrb==[4 6])
            strxlab = '';
            wsetxlab(Axe_ImgSel,strxlab);
            ind = 4*level_view;
            col_lab = get(win_dw2dtool,'DefaultAxesXColor');
            wsetxlab(Axe_ImgDec(ind),xlate('Approximations'),col_lab);
            wsetxlab(Axe_ImgDec(ind-1),'Horizontal Details',col_lab);
            wsetxlab(Axe_ImgDec(ind-2),'Diagonal Details',col_lab);
            wsetxlab(Axe_ImgDec(ind-3),'Vertical Details',col_lab);

        elseif find(view_attrb==[3 14])
            strxlab = sprintf('Decomposition at level %.0f',level_view); 
            wsetxlab(Axe_ImgSel,strxlab);
        end
		
    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end


%-------------------------------------------------
function varargout = depOfMachine(varargin)

ypixl = varargin{1};
ha    = varargin{2};
yd    = varargin{3};
scrSize = get(0,'ScreenSize');
if (scrSize(4)<700) 
    dyd = 10*ypixl;
    ha = ha+dyd; 
    yd = yd-dyd;
end
varargout = {ha,yd};
%-------------------------------------------------
