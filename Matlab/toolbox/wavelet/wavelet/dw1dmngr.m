function out1 = dw1dmngr(option,win_dw1dtool,in3,in4,in5)
%DW1DMNGR Discrete wavelet 1-D general manager.
%   OUT1 = DW1DMNGR(OPTION,WIN_DW1DTOOL,IN3,IN4,IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 28-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.18 $

% Default values.
%----------------
max_lev_anal = 12;

% MemBloc0 of stored values.
%---------------------------
n_InfoInit   = 'DW1D_InfoInit';
ind_filename =  1;
ind_pathname =  2;
nb0_stored   =  2;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
ind_thr_val    = 8;
nb1_stored     = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
nb2_stored    = 2;

%***********************************************%
%** OPTION = 'ini' - Only for precompilation. **%
%***********************************************%
if strcmp(option,'ini') , return; end
%***********************************************%

switch option
    case 'anal'
        active_option = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_act_option);
        if ~strcmp(active_option,'load_sig')

            % Cleaning.
            %----------
            Signal_Anal = dw1dfile('sig',win_dw1dtool);
            wwaiting('msg',win_dw1dtool,'Wait ... cleaning');
            dw1dutil('clean',win_dw1dtool,'load_sig','new_anal');

            % Setting GUI values.
            %--------------------
            dw1dutil('set_gui',win_dw1dtool,'load_sig','new_anal');

            % Drawing.
            %---------
            dw1dvdrv('plot_sig',win_dw1dtool,Signal_Anal);

            % Setting enabled values.
            %------------------------
            dw1dutil('enable',win_dw1dtool,'load_sig');
        else
            wmemtool('wmb',win_dw1dtool,n_param_anal,ind_act_option,'anal');
        end

        % Waiting message.
        %-----------------
        wwaiting('msg',win_dw1dtool,'Wait ... computing');

        % Setting Analysis parameters
        %-----------------------------
        dw1dutil('set_par',win_dw1dtool,option);

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);
        mousefrm(0,'watch');

        % Computing
        %-----------
        if strcmp(active_option,'load_dec')
            dw1dfile('anal',win_dw1dtool,'new_anal');
        else
            dw1dfile('anal',win_dw1dtool);
        end

        % Drawing.
        %---------
        dw1dvdrv('plot_anal',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'synt'
        active_option = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                        ind_act_option);
        if ~strcmp(active_option,'load_cfs')

            % Cleaning.
            %----------
            wwaiting('msg',win_dw1dtool,'Wait ... cleaning');
            dw1dutil('clean',win_dw1dtool,'load_cfs','new_synt');

            % Setting GUI values.
            %--------------------
            dw1dutil('set_gui',win_dw1dtool,'load_cfs');

            % Drawing.
            %---------
            dw1dvdrv('plot_cfs',win_dw1dtool);

            % Setting enabled values.
            %------------------------
            dw1dutil('enable',win_dw1dtool,'load_cfs');
        else
            wmemtool('wmb',win_dw1dtool,n_param_anal,ind_act_option,'synt');
        end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,'Wait ... computing');

        % Setting Analysis parameters
        %-----------------------------
        dw1dutil('set_par',win_dw1dtool,option);

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Computing
        %-----------
        dw1dfile('anal',win_dw1dtool,'synt');

        % Computing & Drawing.
        %----------------------
        dw1dvdrv('plot_synt',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'stat'
        mousefrm(0,'watch'); drawnow;
        out1 = feval('dw1dstat','create',win_dw1dtool);

    case 'hist'
        mousefrm(0,'watch'); drawnow;
        out1 = feval('dw1dhist','create',win_dw1dtool);

    case 'comp'
        mousefrm(0,'watch'); drawnow;
        dw1dutil('enable',win_dw1dtool,option);
        out1 = feval('dw1dcomp','create',win_dw1dtool);

    case 'deno'
        mousefrm(0,'watch'); drawnow;
        dw1dutil('enable',win_dw1dtool,option);
        out1 = feval('dw1ddeno','create',win_dw1dtool);

    case {'return_comp','return_deno'}
        % in3 = 1 : preserve compression
        % in3 = 0 : discard compression
        % in4 = hld_lin (optional)
        %--------------------------------------
        if in3==1
            % Begin waiting.
            %--------------
            wwaiting('msg',win_dw1dtool,'Wait ... drawing');

            % Computing
            %-----------
            dw1dfile('comp_ss',win_dw1dtool,in4);

            % Cleaning axes & drawing.
            %------------------------
            dw1dvmod('ss_vm',win_dw1dtool,[1 4 6],1,0);
            dw1dvmod('ss_vm',win_dw1dtool,[2 3 5],1);
            dw1dvmod('ch_vm',win_dw1dtool,2);

            % End waiting.
            %-------------
            wwaiting('off',win_dw1dtool);
        end
        dw1dutil('enable',win_dw1dtool,option);

    case 'load_sig'
        % Loading file.
        %-------------
        [sigInfos,Signal_Anal,ok] = ...
            utguidiv('load_sig',win_dw1dtool,'Signal_Mask','Load Signal');
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,'Wait ... cleaning');
        dw1dutil('clean',win_dw1dtool,option,'');

        % Setting Analysis parameters.
        %-----------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal, ...
                       ind_act_option,option,     ...
                       ind_sig_name,sigInfos.name,...
                       ind_sig_size,sigInfos.size ...
                       );
        wmemtool('wmb',win_dw1dtool,n_InfoInit, ...
                       ind_filename,sigInfos.filename, ...
                       ind_pathname,sigInfos.pathname  ...
                       );

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option,'');

        % Drawing.
        %---------
        dw1dvdrv('plot_sig',win_dw1dtool,Signal_Anal);

        % Setting enabled values.
        %------------------------
        dw1dutil('enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'load_cfs'
        % Testing file.
        %--------------
        if nargin==2
            % Testing file.
            %--------------
            [filename,pathname,ok] = utguidiv('load_var',win_dw1dtool,   ...
                                       '*.mat','Load Coefficients (1D)', ...
                                       {'coefs','longs'});
            if ~ok, return; end

            % Loading file.
            %--------------
            load([pathname filename],'-mat');
            lev = length(longs)-2;
            if lev>max_lev_anal
                wwaiting('off',win_dw1dtool);
				msg = sprintf(...
				   'The level of the decomposition \nis too large (max = %d).',max_lev_anal);
                wwarndlg(msg,'Load Coefficients (1D)','block');
                return  
            end
            [Signal_Name,ext] = strtok(filename,'.');
            in3 = '';
        end

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,'Wait ... cleaning');
        dw1dutil('clean',win_dw1dtool,option,in3);

        if nargin==2
            % Getting Analysis parameters.
            %-----------------------------
            len         = length(longs);
            Signal_Size = longs(len);
            Level_Anal  = len-2;

            % Setting Analysis parameters
            %-----------------------------
            wmemtool('wmb',win_dw1dtool,n_param_anal,...
                           ind_act_option,option,    ...
                           ind_sig_name,Signal_Name, ...
                           ind_lev_anal,Level_Anal,  ...
                           ind_sig_size,Signal_Size  ...
                           );
            wmemtool('wmb',win_dw1dtool,n_InfoInit,...
                           ind_filename,filename,  ...
                           ind_pathname,pathname   ...
                           );

            % Setting coefs and longs.
            %-------------------------
            wmemtool('wmb',win_dw1dtool,n_coefs_longs, ...
                           ind_coefs,coefs,ind_longs,longs);
        end

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Drawing.
        %---------
        dw1dvdrv('plot_cfs',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'load_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wa1;*.mat' , 'Decomposition  (*.wa1;*.mat)';
               '*.*','All Files (*.*)'};        
        [filename,pathname,ok] = utguidiv('load_var',win_dw1dtool, ...
                                   fileMask,'Load Wavelet Analysis (1D)',...
                                   {'coefs','longs','wave_name','data_name'});
        if ~ok, return; end

        % Loading file.
        %--------------
        load([pathname filename],'-mat');
        lev = length(longs)-2;
        if lev>max_lev_anal
            wwaiting('off',win_dw1dtool);
            msg = sprintf(...
				   'The level of the decomposition \nis too large (max = %d).',max_lev_anal);
            wwarndlg(msg,'Load Wavelet Analysis (1D)','block');
            return
        end

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,'Wait ... cleaning');
        dw1dutil('clean',win_dw1dtool,option);

        % Getting Analysis parameters.
        %-----------------------------
        len         = length(longs);
        Signal_Size = longs(len);
        Level_Anal  = len-2;
        Signal_Name = data_name;
        Wave_Name   = wave_name;

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal, ...
                       ind_act_option,option,    ...
                       ind_sig_name,Signal_Name, ...
                       ind_wav_name,Wave_Name,   ...
                       ind_lev_anal,Level_Anal,  ...
                       ind_sig_size,Signal_Size  ...
                       );
        wmemtool('wmb',win_dw1dtool,n_InfoInit, ...
                       ind_filename,filename, ...
                       ind_pathname,pathname  ...
                       );

        % Setting coefs and longs.
        %-------------------------
        wmemtool('wmb',win_dw1dtool,n_coefs_longs, ...
                       ind_coefs,coefs,ind_longs,longs);

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Computing
        %-----------
        sig_rec = dw1dfile('anal',win_dw1dtool,'load_dec');

        % Drawing.
        %---------
        dw1dvdrv('plot_sig',win_dw1dtool,sig_rec,1);
        dw1dvdrv('plot_anal',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'demo'
        % in3 = Signal_Name
        % in4 = Wave_Name
        % in5 = Level_Anal
        %------------------
        Signal_Name = deblank(in3);
        Wave_Name   = deblank(in4);
        Level_Anal  = in5;

        % Loading file.
        %-------------
        filename = [Signal_Name '.mat'];       
        pathname = utguidiv('WTB_DemoPath',filename);
        [sigInfos,Signal_Anal,ok] = ...
            utguidiv('load_dem1D',win_dw1dtool,pathname,filename);
        if ~ok, return; end

        % Cleaning.
        %----------
        wwaiting('msg',win_dw1dtool,'Wait ... cleaning');
        dw1dutil('clean',win_dw1dtool,option);

        % Setting Analysis parameters
        %-----------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,  ...
                       ind_act_option,option,      ...
                       ind_sig_name,sigInfos.name, ...
                       ind_wav_name,Wave_Name,     ...
                       ind_lev_anal,Level_Anal,    ...
                       ind_sig_size,sigInfos.size  ...
                       );
        wmemtool('wmb',win_dw1dtool,n_InfoInit, ...
                       ind_filename,sigInfos.filename,  ...
                       ind_pathname,sigInfos.pathname   ...
                       );

        % Setting GUI values.
        %--------------------
        dw1dutil('set_gui',win_dw1dtool,option);

        % Drawing.
        %---------
        dw1dvdrv('plot_sig',win_dw1dtool,Signal_Anal,1);

        % Computing
        %-----------
        dw1dfile('anal',win_dw1dtool);
        
        % Drawing.
        %---------
        dw1dvdrv('plot_anal',win_dw1dtool);

        % Setting enabled values.
        %------------------------
        dw1dutil('enable',win_dw1dtool,option);

        % End waiting.
        %-------------
        wwaiting('off',win_dw1dtool);

    case 'save_synt'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
                                     '*.mat','Save Synthesized Signal');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,'Wait ... saving');

        % Getting Analysis values.
        %-------------------------
        [wname,thrParams] = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                     ind_wav_name,ind_thr_val);
        if length(thrParams)==1
            thrName = 'valTHR';  valTHR = thrParams;
        else
            thrName = 'thrParams';
        end
        ssig = dw1dfile('ssig',win_dw1dtool);

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = name;
        eval([saveStr '= ssig ;']);
 
        wwaiting('off',win_dw1dtool);       
        try
          save([pathname filename],saveStr,thrName,'wname');
        catch          
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_cfs'
        % Testing file.
        %--------------
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
                                     '*.mat','Save Coefficients (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,'Wait ... saving coefficients');

        % Getting Analysis values.
        %-------------------------
        [wname,thrParams] = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                     ind_wav_name,ind_thr_val);
        if length(thrParams)==1
            thrName = 'valTHR';  valTHR = thrParams;
        else
            thrName = 'thrParams';
        end
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs);

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.mat'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wname'};

        wwaiting('off',win_dw1dtool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    case 'save_dec'
        % Testing file.
        %--------------
         fileMask = {...
               '*.wa1;*.mat' , 'Decomposition  (*.wa1;*.mat)';
               '*.*','All Files (*.*)'};
        [filename,pathname,ok] = utguidiv('test_save',win_dw1dtool, ...
                                     fileMask,'Save Wavelet Analysis (1D)');
        if ~ok, return; end

        % Begin waiting.
        %--------------
        wwaiting('msg',win_dw1dtool,'Wait ... saving decomposition');

        % Getting Analysis parameters.
        %-----------------------------
        [wave_name,data_name,thrParams] = wmemtool('rmb',win_dw1dtool,n_param_anal, ...
                                             ind_wav_name,ind_sig_name,ind_thr_val);
        if length(thrParams)==1
            thrName = 'valTHR';  valTHR = thrParams;
        else
            thrName = 'thrParams';
        end
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs);

        % Saving file.
        %--------------
        [name,ext] = strtok(filename,'.');
        if isempty(ext) | isequal(ext,'.')
            ext = '.wa1'; filename = [name ext];
        end
        saveStr = {'coefs','longs',thrName,'wave_name','data_name'};

        wwaiting('off',win_dw1dtool);
        try
          save([pathname filename],saveStr{:});
        catch
          errargt(mfilename,'Save FAILED !','msg');
        end

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
