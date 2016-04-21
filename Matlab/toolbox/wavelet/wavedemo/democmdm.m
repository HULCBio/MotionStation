function out1 = democmdm(option,in2,in3)
%DEMOCMDM Main command-line mode demos menu in the Wavelet Toolbox.
%   DEMOCMDM creates the window for command line mode demos.

%   DEMOCMDM('auto') shows all the command line mode demos
%   in automatic mode.
%
%   DEMOCMDM('gr_auto') shows all the command line mode demos
%   in automatic mode: first in the increasing slide order
%   and then in the decreasing slide order.
%
%   DEMOCMDM('loop') shows all the command line mode demos
%   in loop mode.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 18-Apr-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.17 $ $Date: 2002/04/14 19:31:07 $

if nargin==0 , option = 'create'; end

tag_dem_tool  = 'Demo_Tool';
tag_cmdm_tool = 'Cmdm_Tool';
tag_btn_close = 'Demo_Close';
tag_sub_close = 'Cmdm_Close';

switch option
    case 'create'
        win = wfindobj('figure','tag',tag_cmdm_tool);
        if ~isempty(win) , return; end

        % Waiting Frame construction & begin waiting.
        %--------------------------------------------
        mousefrm(0,'watch');

        % CMDM main window initialization.
        %---------------------------------
        name = 'Command line mode demos';
        [win_democmdm,pos_win,defBtnWidth,defBtnHeight,win_units] = ...
                wdfigutl('menu',name,[13/4 41/2],tag_cmdm_tool);
        if nargout>0 ,out1 = win_democmdm; end
        str_win_democmdm = int2str(win_democmdm);

        % Position property of objects.
        %------------------------------
        btn_width  = 3*defBtnWidth;
        btn_heigth = 3*defBtnHeight/2;
        btn_left   = ceil(pos_win(3)-btn_width)/2;
        btn_low    = pos_win(4)-2*defBtnHeight;
        dif_heigth = 2*defBtnHeight;
        pos_dw1d   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_cw1d   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_dw2d   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_comp   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_deno   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_wpck   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_mala   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_casc   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_extm   = [btn_left , btn_low , btn_width , btn_heigth];
        btn_low    = btn_low-dif_heigth;
        pos_close  = [btn_left , btn_low , btn_width , btn_heigth];

        % String property of objects.
        %----------------------------
        str_dw1d   = 'Wavelet 1-D';
        str_cw1d   = 'Continuous Wavelet 1-D';
        str_dw2d   = 'Wavelet 2-D';
        str_comp   = 'Compression';
        str_deno   = 'De-noising';
        str_wpck   = 'Wavelet Packets';
        str_mala   = 'Mallat algorithm';
        str_casc   = 'Cascade algorithm';
        str_extm   = 'Border distortion';
        str_close  = 'Close';

        % Callback property of objects.
        %------------------------------
        cba_dw1d  = [mfilename '(''dw1d'',' str_win_democmdm ');'];
        cba_cw1d  = [mfilename '(''cw1d'',' str_win_democmdm ');'];
        cba_dw2d  = [mfilename '(''dw2d'',' str_win_democmdm ');'];
        cba_comp  = [mfilename '(''comp'',' str_win_democmdm ');'];
        cba_deno  = [mfilename '(''deno'',' str_win_democmdm ');'];
        cba_wpck  = [mfilename '(''wpck'',' str_win_democmdm ');'];
        cba_mala  = [mfilename '(''mala'',' str_win_democmdm ');'];
        cba_casc  = [mfilename '(''casc'',' str_win_democmdm ');'];
        cba_extm  = [mfilename '(''extm'',' str_win_democmdm ');'];
        cba_close = [mfilename '(''close'',' str_win_democmdm ');'];

        % Construction of objects.
        %-------------------------
        pus_dw1d   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_dw1d,...
                                   'String',str_dw1d,...
                                   'Callback',cba_dw1d...
                                   );
        pus_cw1d   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_cw1d,...
                                   'String',str_cw1d,...
                                   'Callback',cba_cw1d...
                                   );
        pus_dw2d   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_dw2d,...
                                   'String',str_dw2d,...
                                   'Callback',cba_dw2d...
                                   );
        pus_comp   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_comp,...
                                   'String',str_comp,...
                                   'Callback',cba_comp...
                                   );
        pus_deno   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_deno,...
                                   'String',str_deno,...
                                   'Callback',cba_deno...
                                   );
        pus_wpck   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_wpck,...
                                   'String',str_wpck,...
                                   'Callback',cba_wpck...
                                   );
        pus_mala   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_mala,...
                                   'String',str_mala,...
                                   'Callback',cba_mala...
                                   );
        pus_casc   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_casc,...
                                   'String',str_casc,...
                                   'Callback',cba_casc...
                                   );

        pus_extm   = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_extm,...
                                   'String',str_extm,...
                                   'Callback',cba_extm...
                                   );

        pus_close  = uicontrol(...
                                   'Style','Pushbutton',...
                                   'Unit',win_units,...
                                   'Position',pos_close,...
                                   'String',str_close,...
                                   'Callback',cba_close,...
                                   'Tag',tag_btn_close...
                                   );

        % Prevent OS closing.
        %--------------------
        set(win_democmdm,'CloseRequestFcn',cba_close)

        % Setting units to normalized.
        %-----------------------------
        set(findobj(win_democmdm,'Units','pixels'),'Units','Normalized');

        % Hide figure handle.
        %-------------------
        hidegui(win_democmdm,'off');

        % End waiting.
        %---------------
        mousefrm(0,'arrow');
        drawnow

    case 'enable'
        %*************************************************************%
        %** OPTION = 'enable' - Deseable or Enable democmdm window  **%
        %*************************************************************%
        % in2 = win handle
        % in3 = 'on' or 'off'   
        %--------------------
        if in3(1:2)=='of'
            mousefrm(0,'watch');
        else
            mousefrm(0,'arrow');
        end
        set(findobj(in2,'style','pushbutton'),'Enable',in3);
        drawnow;

    case {'dw1d','cw1d','dw2d','comp','deno','wpck','mala','casc','extm'}
        %*****************************************************%
        %** OPTION = 'dw1d' -  demo DW1D                    **%
        %** OPTION = 'cw1d' -  demo CW1D                    **%
        %** OPTION = 'dw2d' -  demo DW2D                    **%
        %** OPTION = 'comp' -  demo Compression             **%
        %** OPTION = 'deno' -  demo De-noising              **%
        %** OPTION = 'wpck' -  demo for Wavelet packets     **%
        %** OPTION = 'mala' -  demo for Mallat algorithm    **%
        %** OPTION = 'casc' -  demo for Cascade algorithm   **%
        %** OPTION = 'extm' -  demo for Boundary distortion **%
        %*****************************************************%
        expo_flag = 0;
        if nargin==1
            win = wfindobj('figure','tag',tag_cmdm_tool);
        else
            win = in2;
			if isempty(win) , expo_flag = 1; end
        end
        if ishandle(win) , democmdm('enable',win,'off'); end
        demoname = ['dcmd' option];
		addclose = [mfilename '(''endshow'');'];
		if expo_flag
			addclose = [addclose 'mextglob(''clear''); wtbxmngr(''clear'');'];
		end
		fig = wshowdrv(demoname,addclose,tag_sub_close);
		if nargout>0 , out1 = fig; end
		mousefrm(0,'arrow');

    case {'auto','gr_auto'}
        %************************************%
        %** OPTION = 'auto' and 'gr_auto'  **%
		%** All demos inautomatic modes.   **%
        %************************************%
		lstDEMOS = {'dw1d','cw1d','dw2d','comp','deno','wpck','mala','casc','extm'};
        win = democmdm('create');
		democmdm('enable',win,'off');
		stop = 0;
        while stop==0
			for k=1:length(lstDEMOS)
				feval(['dcmd',lstDEMOS{k}],option);
				if ~ishandle(win) , stop = 1; break; end
			end
            if ~isequal(stop,1) & nargin==2 & isequal(in2,'loop')
				stop = 0 ;
			else
				stop = 1;
			end
        end
        democmdm('close',win);
	
    case 'loop'
        %************************************************************%
        %** OPTION = 'loop' - loop with all demos (automatic mode) **%
        %************************************************************%
        democmdm('auto','loop');

	case 'endshow'
        %**************************************************%
        %** OPTION = 'endshow' - used to finish wshowdrv **%
        %**************************************************%
        win = wfindobj('figure','tag',tag_cmdm_tool);
        set(findobj(win,'style','pushbutton'),'Enable','on');
        drawnow;

    case 'close'
        %***********************************************%
        %** OPTION = 'close' - close democmdm window  **%
        %***********************************************%
        mousefrm(0,'watch')
        if nargin==2
            win_democmdm = in2;
        else
            win_democmdm = wfindobj('figure','tag',tag_cmdm_tool);
        end

        % Closing all opened main analysis windows.
        %------------------------------------------
        pus_handles = wfindobj(0,'Style','pushbutton');
        hdls        = findobj(pus_handles,'flat','Tag',tag_sub_close);
        for i=1:length(hdls)
            hdl = hdls(i);
            try
              par = get(hdl,'Parent');
              try
                eval(get(hdl,'Callback'));
              end
              delete(par);
            end
        end

        % Closing the democmdm window.
        %-----------------------------
        try , delete(win_democmdm); end

        win_ini = wfindobj('figure','tag',tag_dem_tool);
        if ~isempty(win_ini)
            pus_handles = findobj(win_ini,'Style','pushbutton');
            set(pus_handles,'Enable','on');
        else
            mextglob('clear')
            wtbxmngr('clear')
        end
        mousefrm(0,'arrow');

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
