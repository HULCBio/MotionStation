function out1 = wp1dmngr(option,win_wptool,in3,in4,in5,in6,in7)
%WP1DMNGR Wavelet packets 1-D general manager.
%   OUT1 = WP1DMNGR(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 28-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.17 $

% Default values.
%----------------
max_lev_anal = 12;
default_nbcolors = 128;

% Memory Blocks of stored values.
%================================
% MB0.
%-----
n_InfoInit   = 'WP1D_InfoInit';
ind_filename = 1;
ind_pathname = 2;
nb0_stored   = 2;

% MB1.
%-----
n_param_anal   = 'WP1D_Par_Anal';
ind_sig_name   = 1;
ind_wav_name   = 2;
ind_lev_anal   = 3;
ind_ent_anal   = 4;
ind_ent_par    = 5;
ind_sig_size   = 6;
ind_act_option = 7;
ind_thr_val    = 8;
nb1_stored     = 8;

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
    case 'load_sig'
        % in3 optional (new_anal)
        %------------------------

        % Loading file.
        %-------------
        [sigInfos,Signal_Anal,ok] = ...
            utguidiv('load_sig',win_wptool,'Signal_Mask','Load Signal');
        
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaiting('msg',win_wptool,'Wait ... cleaning');
        wp1dutil('clean',win_wptool,option,'');

        % Setting Analysis parameters.
        %-----------------------------
        wmemtool('wmb',win_wptool,n_param_anal, ...
                       ind_act_option,option,     ...
                       ind_sig_name,sigInfos.name,...
                       ind_sig_size,sigInfos.size ...
                       );
        wmemtool('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,...
                       ind_nb_colors,default_nbcolors);

        % Setting GUI values.
        %--------------------
        wp1dutil('set_gui',win_wptool,option);

        % Drawing.
        %---------
        wp1ddraw('sig',win_wptool,Signal_Anal);

        % Setting enabled values.
        %------------------------
        wp1dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'load_dec'
        switch nargin
            case 2
                % Testing file.
                %--------------
                winTitle = 'Load Wavelet Packet Analysis (1D)';
                fileMask = {...
                    '*.wp1;*.mat' , 'Decomposition  (*.wp1;*.mat)';
                    '*.*','All Files (*.*)'};                
                [filename,pathname,ok] = utguidiv('load_wpdec',win_wptool, ...
                    fileMask,winTitle,2);
                if ~ok, return; end

                % Loading file.
                %--------------
                load([pathname filename],'-mat');
                if isa(tree_struct,'wptree') , data_struct = []; end
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
                        msg = strvcat(['The decomposition is not a' ...
						' valid one dimensional analysis'],' ');
                        errordlg(msg,...
                                'Load Wavelet Packet Analysis (1D)',...
                                'modal');
                        return
                    end
                else
                    data_struct = in4;
                end
                data_name = 'input var';
        end

        % Cleaning.
        %----------
        wwaiting('msg',win_wptool,'Wait ... cleaning');
        wp1dutil('clean',win_wptool,option);

        % Getting Analysis parameters.
        %-----------------------------
        if isa(tree_struct,'wptree')
            [Wave_Name,Ent_Name,Ent_Par,Signal_Size] = ...
                read(tree_struct,'wavname','entname','entpar','sizes',0);
        else
            Wave_Name = wdatamgr('read_wave',data_struct);
            [Ent_Name,Ent_Par] = wdatamgr('read_tp_ent',data_struct);
            sizes       = wdatamgr('rsizes',data_struct);
            Signal_Size = sizes(1,1);
        end
        Level_Anal  = treedpth(tree_struct);
        Signal_Name = data_name;

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_wptool,n_param_anal,  ...
                       ind_act_option,option,    ...
                       ind_sig_name,Signal_Name, ...
                       ind_wav_name,Wave_Name,   ...
                       ind_lev_anal,Level_Anal,  ...
                       ind_sig_size,Signal_Size, ...
                       ind_ent_anal,Ent_Name,    ...
                       ind_ent_par,Ent_Par       ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,      ...
                       ind_nb_colors,default_nbcolors ...
                       );
        % Writing structures.
        %----------------------
        wmemtool('wmb',win_wptool,n_sav_struct,     ...
                       ind_sav_tree_st,tree_struct, ...
                       ind_sav_data_st,data_struct);
        wmemtool('wmb',win_wptool,n_structures, ...
                       ind_tree_st,tree_struct, ...
                       ind_data_st,data_struct);

        % Setting GUI values.
        %--------------------
        wp1dutil('set_gui',win_wptool,option);

        % Computing and Drawing Original Signal.
        %---------------------------------------
        wwaiting('msg',win_wptool,'Wait ... computing');
        if isa(tree_struct,'wptree')
            Signal_Anal = wprec(tree_struct);
        else
            Signal_Anal = wprec(tree_struct,data_struct);
        end
        wp1ddraw('sig',win_wptool,Signal_Anal);

        % Decomposition drawing
        %----------------------
        wp1ddraw('anal',win_wptool);

        % Setting enabled values.
        %------------------------
        wp1dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'demo'
        % in3 = Signal_Name
        % in4 = Wave_Name
        % in5 = Level_Anal
        % in6 = Ent_Name
        % in7 = Ent_Par (optional)
        %--------------------------
        Signal_Name = deblank(in3);
        Wave_Name   = deblank(in4);
        Level_Anal  = in5;
        Ent_Name    = deblank(in6);
        if nargin==6 ,  Ent_Par = 0 ; else , Ent_Par = in7; end

        % Loading file.
        %-------------
        filename = [Signal_Name '.mat'];       
        pathname = utguidiv('WTB_DemoPath',filename);
        [sigInfos,Signal_Anal,ok] = ...
            utguidiv('load_dem1D',win_wptool,pathname,filename);
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaiting('msg',win_wptool,'Wait ... cleaning');
        wp1dutil('clean',win_wptool,option);

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_wptool,n_param_anal,    ...
                       ind_act_option,option,      ...
                       ind_sig_name,sigInfos.name, ...
                       ind_wav_name,Wave_Name,     ...
                       ind_lev_anal,Level_Anal,    ...
                       ind_sig_size,sigInfos.size, ...
                       ind_ent_anal,Ent_Name,      ...
                       ind_ent_par,Ent_Par         ...
                        );
        wmemtool('wmb',win_wptool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );
        wmemtool('wmb',win_wptool,n_wp_utils,      ...
                       ind_nb_colors,default_nbcolors ...
                       );

        % Setting GUI values.
        %--------------------
        wp1dutil('set_gui',win_wptool,option);

        % Drawing.
        %---------
        wp1ddraw('sig',win_wptool,Signal_Anal);

        % Calling Analysis.
        %-----------------
        wp1dmngr('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp1dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_wptool, ...
                                     '*.mat','Save Synthesized Signal');
        if ~ok, return; end
        [name,ext] = strtok(filename,'.');

        % Begin waiting.
        %--------------
        wwaiting('msg',win_wptool,'Wait ... saving');

        % Saving Synthesized Signal.
        %---------------------------
        [wname,valTHR] = wmemtool('rmb',win_wptool,n_param_anal,...
                                  ind_wav_name,ind_thr_val);
        str_name = name;
        hdl_node = wpssnode('r_synt',win_wptool);
        if ~isempty(hdl_node)
            eval([str_name '= get(hdl_node,''userdata'');']);       
        else
            % Reading structures.
            %--------------------
            [tree_struct,data_struct] =     ...
                    wmemtool('rmb',win_wptool,n_structures,...
                                   ind_tree_st,ind_data_st);
            if isa(tree_struct,'wptree')
                eval([str_name '= wprec(tree_struct);']);
            else
                eval([str_name '= wprec(tree_struct,data_struct);']);
            end
        end

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = str_name;
        wwaiting('off',win_wptool);
        try
          save([pathname filename],saveStr,'valTHR','wname');
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'
         % Testing file.
        %--------------
         fileMask = {...
               '*.wp1;*.mat' , 'Decomposition  (*.wp1;*.mat)';
               '*.*','All Files (*.*)'};                
        [filename,pathname,ok] = utguidiv('test_save',win_wptool, ...
                                   fileMask,'Save Wavelet Packet Analysis (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_wptool,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        data_name = wmemtool('rmb',win_wptool,n_param_anal,ind_sig_name);

        % Reading structures.
        %--------------------
        [tree_struct,data_struct] = wmemtool('rmb',win_wptool,n_structures,...
                                                   ind_tree_st,ind_data_st);

        % Saving file.
        %--------------
        valTHR = wmemtool('rmb',win_wptool,n_param_anal,ind_thr_val);
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.wp1'; filename = [name ext];
        end
        if isa(tree_struct,'wptree')
            saveStr = {'tree_struct','data_name','valTHR'};
        else
            saveStr = {'tree_struct','data_struct','data_name','valTHR'};
        end
        wwaiting('off',win_wptool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'anal'
        active_option = wmemtool('rmb',win_wptool,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_sig')
            % Cleaning. 
            %----------
            wwaiting('msg',win_wptool,'Wait ... cleaning');
            wp1dutil('clean',win_wptool,'load_sig','new_anal');
            wp1dutil('enable',win_wptool,'load_sig');
        else
            wmemtool('wmb',win_wptool,n_param_anal,ind_act_option,'anal');
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_wptool,'Wait ... computing');

        % Setting Analysis parameters
        %-----------------------------
        [Wave_Name,Level_Anal] = cbanapar('get',win_wptool,'wav','lev');
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
                       ind_wav_name,Wave_Name, ...
                       ind_lev_anal,Level_Anal,...
                       ind_ent_anal,Ent_Name,  ...
                       ind_ent_par,Ent_Par     ...
                       );

        % Calling Analysis.
        %------------------
        wp1dmngr('step2',win_wptool,option);

        % Setting enabled values.
        %------------------------
        wp1dutil('enable',win_wptool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'step2'
        % Begin waiting.
        %---------------
        wwaiting('msg',win_wptool,'Wait ... computing');

        % Getting  Analysis parameters.
        %------------------------------
        [Signal_Name,Signal_Size,Wave_Name,Level_Anal,Ent_Name,Ent_Par] = ...
                wmemtool('rmb',win_wptool,n_param_anal, ...
                               ind_sig_name,ind_sig_size, ...
                               ind_wav_name,ind_lev_anal, ...
                               ind_ent_anal,ind_ent_par);
        active_option = wmemtool('rmb',win_wptool,n_param_anal,ind_act_option);
        [filename,pathname] = wmemtool('rmb',win_wptool,n_InfoInit, ...
                                             ind_filename,ind_pathname);

        % Computing.
        %-----------   
        objVersion = wtbxmngr('get','objVersion');
        switch active_option
          case {'demo','anal'}
            try
              load([pathname filename],'-mat');
              Signal_Anal = eval(Signal_Name);
            catch
                [Signal_Anal,ok] = utguidiv('direct_load_sig',win_wptool,pathname,filename);
                if ~ok
                    wwaiting('off',win_wptool);
                    msg = sprintf('File %s not found!', filename);
                    errordlg(msg,'Load ERROR','modal');
                    return
                end
            end

          case 'load_dec'       % second time only for load_dec
            Signal_Anal = get(wp1ddraw('r_orig',win_wptool),'Ydata');
            tree_struct = wmemtool('rmb',win_wptool,n_structures,ind_tree_st);
            objVersion  = isa(tree_struct,'wptree');
        end
        if objVersion>0
            tree_struct = wpdec(Signal_Anal,Level_Anal,Wave_Name,Ent_Name,Ent_Par);
            data_struct = [];
        else
            [tree_struct,data_struct] = ...
                    wpdec(Signal_Anal,Level_Anal,Wave_Name,Ent_Name,Ent_Par);
        end

        % Writing structures.
        %----------------------
        wmemtool('wmb',win_wptool,n_sav_struct,     ...
                       ind_sav_tree_st,tree_struct, ...
                       ind_sav_data_st,data_struct);

        wmemtool('wmb',win_wptool,n_structures,  ...
                       ind_tree_st,tree_struct,  ...
                       ind_data_st,data_struct);

        % Decomposition drawing
        %----------------------
        wp1ddraw('anal',win_wptool);

        % End waiting.
        %-------------
        wwaiting('off',win_wptool);

    case 'comp'
        mousefrm(0,'watch');
        drawnow;
        wp1dutil('enable',win_wptool,option);
        out1 = feval('wp1dcomp','create',win_wptool);

    case 'deno'
        mousefrm(0,'watch');
        drawnow;
        wp1dutil('enable',win_wptool,option);
        out1 = feval('wp1ddeno','create',win_wptool);

    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hdl_line (optional)
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
            wpssnode('plot',win_wptool,namesig,1,in4,[]);

            % End waiting.
            %-------------
            wwaiting('off',win_wptool);
        end
        wp1dutil('enable',win_wptool,option);

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
