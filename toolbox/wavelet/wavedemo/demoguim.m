function out1 = demoguim(option,in2,in3)
%DEMOGUIM Main GUI-mode demos menu in the Wavelet Toolbox.
%   DEMOGUIM creates the window for GUI mode demos.

%   DEMOGUIM('auto') shows all the GUI mode demos
%   in automatic mode.
%
%   DEMOGUIM('gr_auto') shows all the GUI mode demos
%   in automatic mode: first in the increasing slide order
%   and then in the decreasing slide order.
%
%   DEMOGUIM('loop') shows all the GUI mode demos
%   in loop mode.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 12-Nov-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.17.4.4 $ $Date: 2004/04/13 00:39:07 $

if nargin==0 , option = 'create'; end

tag_dem_tool  = 'Demo_Tool';
tag_guim_tool = 'Guim_Tool';
tag_sub_close = 'Guim_Close';  % tag for sub_window

switch option
    case 'create'
        win = demoguimwin;
        winSTR = sprintf('%25.18f',win);
        set(win,'CloseRequestFcn',[mfilename '(''close'',' winSTR ')'])
        if nargout>0 , out1 = win; end

    case {'dw1d','wp1d','cw1d','cwim','dw2d','wp2d','wvdi','wpdi',...
          'sw1d','de1d','re1d','cf1d','sw2d','cf2d','sext','iext',...
          'nwav','wfbm','wfus'}
        if nargin==1
            win = wfindobj('figure','tag',tag_guim_tool);
        else
            win = in2;
        end
        switch option
            case {'futureDEMOS'} % Template
                uiwait(msgbox('This demo is not available.',...
                    'Caution','warn','modal'));
                return
        end
        if ishandle(win)
            set(wfindobj(win,'style','pushbutton'),'Enable','Off');
        end
        demoname = ['dgui' option];
		addclose = [mfilename '(''endshow'');'];
		fig = wshowdrv(demoname,addclose,tag_sub_close);
		if nargout>0 , out1 = fig; end

    case {'auto','gr_auto'}
        %************************************%
        %** OPTION = 'auto' and 'gr_auto'  **%
		%** All demos inautomatic modes.   **%
        %************************************%
		lstDEMOS = {...
				'dw1d','wp1d','cw1d','cwim','dw2d','wp2d','wvdi','wpdi', ...
				'sw1d','de1d','re1d','cf1d','sw2d','cf2d','sext','iext',...
                'nwav','wfbm','wfus'};
		win = demoguim('create');
		set(wfindobj(win,'style','pushbutton'),'Enable','Off');
		stop = 0;
        while stop==0
            for k=1:length(lstDEMOS)
                feval(['dgui',lstDEMOS{k}],option);
                if ~ishandle(win) , stop = 1; break; end
            end
            if ~isequal(stop,1) & nargin==2 & isequal(in2,'loop')
				stop = 0 ;
			else
				stop = 1;
			end
        end
        demoguim('close',win);

    case 'loop'
        %***********************************************************%
        %** OPTION = 'loop' - loop for all demos (automatic mode) **%
        %***********************************************************%
        demoguim('auto','loop');

    case 'endshow'
        %**************************************************%
        %** OPTION = 'endshow' - used to finish wshowdrv **%
        %**************************************************%
        win = wfindobj('figure','tag',tag_guim_tool);
        set(findobj(win,'style','pushbutton'),'Enable','on');
		mousefrm(win,'arrow');
        drawnow;

    case 'close'
        %***********************************************%
        %** OPTION = 'close' - close demoguim window  **%
        %***********************************************%
        mousefrm(0,'watch')

        % Closing all opened main analysis windows.
        %------------------------------------------
        pus_handles = wfindobj(0,'Style','pushbutton');
        hdls        = findobj(pus_handles,'flat','Tag',tag_sub_close);
        for i=1:length(hdls)
            hdl = hdls(i);
            try , par = get(hdl,'Parent'); end            
            try , eval(get(hdl,'Callback')); end
            try , delete(par); end
        end

        % Closing the demoguim window.
        %-----------------------------
        try , delete(in2); end

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

% Reset the LASTERR function
lasterr('');

