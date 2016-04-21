function out1 = wp2dmngr(option,win_wptool,in3,in4,in5,in6,in7)
%WP2DMNGR Wavelet packets 2-D general manager.
%   OUT1 = WP2DMNGR(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 05-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $

% Default values.
%----------------
max_lev_anal = 5;
default_nbcolors = 255;

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'WP2D_InfoInit';
ind_filename = 1;
ind_pathname = 2;
nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'WP2D_Par_Anal';
ind_img_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_img_size   = 6;
ind_img_t_name = 7;
ind_act_option = 8;
ind_thr_val    = 9;
nb1_stored     = 9;

% MB2.
%-----
n_wp_utils = 'WP_Utils';
ind_tree_lin  = 1;
ind_tree_txt  = 2;
ind_type_txt  = 3;
ind_sel_nodes = 4;
ind_gra_area  = 5;
ind_nb_colors = 6;
nb2_stored    = 6;

% MB3.
%-----
n_structures = 'Structures';
ind_tree_st  = 1;
ind_data_st  = 2;
nb3_stored   = 2;

% MB4.
%-----
n_sav_struct    = 'Sav_Struct';
ind_sav_tree_st = 1;
ind_sav_data_st = 2;
nb4_stored      = 2;

switch option
    case 'load_img'
	% Loading file.
    %--------------
    imgFileType = ['*.mat;*.bmp;*.hdf;*.jpg;' ...
            '*.jpeg;*.pcx;*.tif;*.tiff;*.gif'];
    [imgInfos,Img_Anal,map,ok] = utguidiv('load_img',win_wptool, ...
        imgFileType,'Load Image',default_nbcolors);
    if ~ok, return; end

    % Cleaning. 
	%----------
	wwaiting('msg',win_wptool,'Wait ... cleaning');
	wp2dutil('clean',win_wptool,option,'');

    % Setting Analysis parameters.
	%-----------------------------
	NB_ColorsInPal = size(map,1);
        wmemtool('wmb',win_wptool,n_param_anal, ...
                       ind_act_option,option,  ...
		       ind_img_name,imgInfos.name, ...
		       ind_img_t_name,imgInfos.true_name, ...
		       ind_img_size,imgInfos.size ...
                        );
        wmemtool('wmb',win_wptool,n_InfoInit,  ...
		       ind_filename,imgInfos.filename, ...
		       ind_pathname,imgInfos.pathname  ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,  ...
                       ind_nb_colors,NB_ColorsInPal);

        % Setting GUI values.
        %--------------------
        wp2dutil('set_gui',win_wptool,option,'');
	if imgInfos.self_map , arg = map; else , arg = []; end
        cbcolmap('set',win_wptool,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Drawing.
        %---------
        wp2ddraw('sig',win_wptool,Img_Anal);

        % Setting enabled values.
        %------------------------
        wp2dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'load_dec'
        switch nargin
            case 2
                % Testing file.
                %--------------
                winTitle = 'Load Wavelet Packet Analysis (2D)';
                fileMask = {...
                    '*.wp2;*.mat' , 'Decomposition  (*.wp2;*.mat)';
                    '*.*','All Files (*.*)'};                
                [filename,pathname,ok] = utguidiv('load_wpdec',win_wptool, ...
                                           fileMask,winTitle,4);
                if ~ok, return; end

                % Loading file.
                %--------------
                load([pathname filename],'-mat');
                if isa(tree_struct,'wptree') , data_struct = []; end
                if ~exist('map','var'), map = pink(default_nbcolors); end
                if ~exist('data_name','var') , data_name = 'no name'; end

            case {3,4}
                filename    = '';
                pathname    = '';
                tree_struct = in3;
                if nargin==3
                    if isa(tree_struct,'wptree')
                        data_struct = [];
                    else
                        wwaiting('off',win_wptool);
                        msg = strvcat(['The decomposition is not a'...
						' valid two dimensional analysis'],' ');
                        errordlg(msg,...
                                'Load Wavelet Packet Analysis (2D)','modal');
                        return
                    end
                else
                    data_struct = in4;
                end
                map       = pink(default_nbcolors);
                data_name = 'input var';
        end

        % Cleaning.
        %----------
        wp2dutil('clean',win_wptool,option);

        % Getting Analysis parameters.
        %-----------------------------
        if isa(tree_struct,'wptree')
            [Wav_Name,Ent_Name,Ent_Par,Img_Size] = ...
                read(tree_struct,'wavname','entname','entpar','sizes',0);
            Img_Size = fliplr(Img_Size);
        else
            Wav_Name = wdatamgr('read_wave',data_struct);
            [Ent_Name,Ent_Par] = wdatamgr('read_tp_ent',data_struct);
            sizes    = wdatamgr('rsizes',data_struct);
            Img_Size = fliplr(sizes(:,1)');
        end
        Lev_Anal     = treedpth(tree_struct);
        Img_Name       = data_name;
        NB_ColorsInPal = size(map,1);

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_wptool,n_param_anal, ...
                       ind_act_option,option,   ...
                       ind_img_name,Img_Name,   ...
                       ind_wav_name,Wav_Name,   ...
                       ind_lev_anal,Lev_Anal,   ...
                       ind_img_size,Img_Size,   ...
                       ind_ent_anal,Ent_Name,   ...
                       ind_ent_par,Ent_Par      ...
                       );
        wmemtool('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,filename, ...
                       ind_pathname,pathname  ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,    ...
                       ind_nb_colors,NB_ColorsInPal ...
                       );
        % Writing structures.
        %----------------------
        wmemtool('wmb',win_wptool,n_sav_struct,     ...
                       ind_sav_tree_st,tree_struct, ...
                       ind_sav_data_st,data_struct);
        wmemtool('wmb',win_wptool,n_structures,  ...
                       ind_tree_st,tree_struct, ...
                       ind_data_st,data_struct);

        % Setting GUI values.
        %--------------------
        wp2dutil('set_gui',win_wptool,option);

        % Setting Initial Colormap.
        %--------------------------
        cbcolmap('set',win_wptool,'pal',{'pink',NB_ColorsInPal,'self',[]});

        % Computing Original Signal.
        %--------------------------
        if isa(tree_struct,'wptree')
            Img_Anal = wprec2(tree_struct);
        else
            Img_Anal = wprec2(tree_struct,data_struct);
        end

        % Drawing.
        %---------
        wp2ddraw('sig',win_wptool,Img_Anal);

        % Decomposition drawing
        %----------------------
        wp2ddraw('anal',win_wptool);

        % Setting enabled values.
        %------------------------
        wp2dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'demo'
        % in3 = Img_Name
        % in4 = Wav_Name
        % in5 = Lev_Anal
        % in6 = Ent_Name
        % in7 = Ent_Par (optional)
        %------------------
        Img_Name = deblank(in3);
        Wav_Name = deblank(in4);
        Lev_Anal = in5;
        Ent_Name   = deblank(in6);
        if nargin==6 , Ent_Par = 0 ; else , Ent_Par = in7; end

	% Loading file.
        %--------------
        filename = [Img_Name '.mat'];
        pathname = utguidiv('WTB_DemoPath',filename);
        [imgInfos,Img_Anal,map,ok] = utguidiv('load_dem2D',win_wptool, ...
            pathname,filename,default_nbcolors);
        if ~ok, return; end
        
        % Cleaning.
        %----------
        wp2dutil('clean',win_wptool,option);

        % Setting Analysis parameters
        %-----------------------------
        NB_ColorsInPal = size(map,1);
        wmemtool('wmb',win_wptool,n_param_anal,    ...
                       ind_act_option,option,      ...
                       ind_img_name,imgInfos.name, ...
                       ind_img_t_name,imgInfos.true_name, ...
                       ind_wav_name,Wav_Name,      ...
                       ind_lev_anal,Lev_Anal,      ...
                       ind_img_size,imgInfos.size, ...
                       ind_ent_anal,Ent_Name,      ...
                       ind_ent_par,Ent_Par         ...
                       );
        wmemtool('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,imgInfos.filename, ...
                       ind_pathname,imgInfos.pathname  ...
                       );
         wmemtool('wmb',win_wptool,n_wp_utils,    ...
                       ind_nb_colors,NB_ColorsInPal ...
                       );
        % Setting GUI values.
        %--------------------
        wp2dutil('set_gui',win_wptool,option);
        if imgInfos.self_map , arg = map; else , arg = []; end
        cbcolmap('set',win_wptool,'pal',{'pink',NB_ColorsInPal,'self',arg});

        % Drawing.
        %---------
        wp2ddraw('sig',win_wptool,Img_Anal);

        % Calling Analysis.
        %-----------------
        wp2dmngr('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp2dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_wptool, ...
                                     '*.mat','Save Synthesized Image');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_wptool,'Wait ... saving');

        % Getting colormap.
        %------------------
        map = cbcolmap('get',win_wptool,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_wptool,n_wp_utils,ind_nb_colors);
            map = pink(nb_colors);
        end

        % Getting Synthesized Image.
        %---------------------------
        hdl_node = wpssnode('r_synt',win_wptool);
        if ~isempty(hdl_node)
            X = get(hdl_node,'userdata');
        else
            % Reading structures.
            %--------------------
            [tree_struct,data_struct] = ...
                    wmemtool('rmb',win_wptool,n_structures,...
                                   ind_tree_st,ind_data_st);
            if isa(tree_struct,'wptree')
                X = wprec2(tree_struct);
            else
                X = wprec2(tree_struct,data_struct);
            end
        end
        X = round(X);

        % Saving file.
        %--------------
        [wname,valTHR] = wmemtool('rmb',win_wptool,n_param_anal,...
                                  ind_wav_name,ind_thr_val);
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'X','map','valTHR','wname'};
        wwaiting('off',win_wptool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wp2;*.mat' , 'Decomposition  (*.wp2;*.mat)';
               '*.*','All Files (*.*)'};                        
        [filename,pathname,ok] = utguidiv('test_save',win_wptool, ...
                                   fileMask,'Save Wavelet Packet Analysis (2D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_wptool,'Wait ... saving decomposition');

        [name,ext] = strtok(filename,'.');
        ext = '.wp2';
        filename = [name ext];

        % Getting Analysis parameters.
        %-----------------------------
        data_name = wmemtool('rmb',win_wptool,n_param_anal,ind_img_name);
        [tree_struct,data_struct] = wmemtool('rmb',win_wptool,n_structures,...
                                        ind_tree_st,ind_data_st);
        valTHR = wmemtool('rmb',win_wptool,n_param_anal,ind_thr_val);
        map = cbcolmap('get',win_wptool,'self_pal');
        if isempty(map)
            nb_colors = wmemtool('rmb',win_wptool,n_wp_utils,ind_nb_colors);
            map = pink(nb_colors);
        end

        % Saving file.
        %-------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.wp2'; filename = [name ext];
        end
        if isa(tree_struct,'wptree')
          saveStr = {'tree_struct','map','data_name','valTHR'};
        else
          saveStr = {'tree_struct','data_struct','map','data_name','valTHR'};
        end
        wwaiting('off',win_wptool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'anal'
        active_option = wmemtool('rmb',win_wptool,n_param_anal,...
                                        ind_act_option);
        if ~strcmp(active_option,'load_img')
            % Test for new Analysis.
            %-----------------------
            % new = wwaitans(win_wptool,'New Analysis ?');
            % if new==0 , return; end

            % Cleaning. 
            %----------
            wwaiting('msg',win_wptool,'Wait ... computing');
            wp2dutil('clean',win_wptool,'load_img','new_anal');
            wp2dutil('enable',win_wptool,'load_img');
        else
            wwaiting('msg',win_wptool,'Wait ... computing');
            wmemtool('wmb',win_wptool,n_param_anal,ind_act_option,'anal');
        end

        % Setting Analysis parameters
        %-----------------------------
        [Wav_Name,Lev_Anal] = cbanapar('get',win_wptool,'wav','lev');
        [Ent_Name,Ent_Par,err] = utentpar('get',win_wptool,'ent');
        if err>0
            wwaiting('off',win_wptool);
            switch err
              case 1 , msg = 'Invalid entropy parameter value! ';
              case 2 , msg = 'Invalid entropy name! ';
            end
            errargt(mfilename,msg,'msg');
            utentpar('set',win_wptool);
            return
        end
        wmemtool('wmb',win_wptool,n_param_anal, ...
                       ind_wav_name,Wav_Name,   ...
                       ind_lev_anal,Lev_Anal,   ...
                       ind_ent_anal,Ent_Name,   ...
                       ind_ent_par,Ent_Par      ...
                       );

        % Calling Analysis.
        %------------------
        wp2dmngr('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp2dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'step2'
        % Begin waiting.
        %---------------
        wwaiting('msg',win_wptool,'Wait ... computing');

        % Getting  Analysis parameters.
        %------------------------------
        [Img_Name,Img_Size,Wav_Name,Lev_Anal,...
                        Img_True_Name,Ent_Name,Ent_Par] = ...
                        wmemtool('rmb',win_wptool,n_param_anal, ...
                                        ind_img_name,ind_img_size, ...
                                        ind_wav_name,ind_lev_anal, ...
                                        ind_img_t_name, ...
                                        ind_ent_anal,ind_ent_par);
        active_option = wmemtool('rmb',win_wptool,n_param_anal,ind_act_option);
        [filename,pathname] = wmemtool('rmb',win_wptool,n_InfoInit, ...
                                        ind_filename,ind_pathname);

        if strcmp(active_option,'demo') | strcmp(active_option,'anal')
            numopt = 1;
        elseif strcmp(active_option,'load_dec')
            numopt = 2;
        end

        % Computing.
        %-----------
        objVersion = wtbxmngr('get','objVersion');
        if numopt==1
            try
                [fileStruct,err] = wfileinf(pathname,filename);
            catch
                err = 1;
            end
            if ~err
                try
                  load([pathname filename],'-mat');
                catch
                  msg = sprintf('File %s is not a valid file.', filename);
                  err = 1;
                end
            else
                [X,map,imgFormat,colorType,err] = ...
                    utguidiv('direct_load_img',win_wptool,pathname,filename);
                if err
                    msg = sprintf('File %s is not a valid file or is empty.', filename);
                end
            end
            if err==1
                msg = sprintf('File %s not found!', filename);
                wwaiting('off',win_wptool);
                errordlg(msg,'Load Image ERROR','modal');
                return
            end
            Img_Anal = double(eval(Img_True_Name));

        elseif numopt==2    % second time only for load_dec
            Img_Anal = get(wp2ddraw('r_orig',win_wptool),'Cdata');
            tree_struct = wmemtool('rmb',win_wptool,n_structures,ind_tree_st);
            if isa(tree_struct,'wptree')
                objVersion = 1;
            else
                objVersion = 0;
            end
        end
        if objVersion>0
            tree_struct = ...
                wpdec2(Img_Anal,Lev_Anal,Wav_Name,Ent_Name,Ent_Par);
            data_struct = [];
        else
            [tree_struct,data_struct] = ...
                wpdec2(Img_Anal,Lev_Anal,Wav_Name,Ent_Name,Ent_Par);
        end

        % Writing structures.
        %--------------------
        wmemtool('wmb',win_wptool,n_sav_struct, ...
                        ind_sav_tree_st,tree_struct, ...
                        ind_sav_data_st,data_struct);
        wmemtool('wmb',win_wptool,n_structures, ...
                        ind_tree_st,tree_struct, ...
                        ind_data_st,data_struct);

        % Decomposition drawing
        %----------------------
        wp2ddraw('anal',win_wptool);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'comp'
        mousefrm(0,'watch');
        drawnow;
        wp2dutil('enable',win_wptool,option);
        out1 = feval('wp2dcomp','create',win_wptool);

    case 'deno'
        mousefrm(0,'watch');
        drawnow;
        wp2dutil('enable',win_wptool,option);
        out1 = feval('wp2ddeno','create',win_wptool);

    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hdl_img (optional)
        %--------------------------------------

        if in3==1
            % Begin waiting.
            %--------------
            wwaiting('msg',win_wptool,'Wait ... drawing');

            if strcmp(option,'return_comp')
                namesig = 'cs';
            else
                namesig = 'ds';
            end
            NB_Col = wmemtool('rmb',win_wptool,n_wp_utils,ind_nb_colors);
            wpssnode('plot',win_wptool,namesig,2,in4,NB_Col)

            % End waiting.
            %-------------
            wwaiting('off',win_wptool);
        end
        wp2dutil('enable',win_wptool,option);

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
