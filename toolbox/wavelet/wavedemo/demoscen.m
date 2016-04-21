function out1 = demoscen(option,in2,in3)
%DEMOSCEN Demonstrates typical wavelet 1-D scenarios using the Wavelet Toolbox. 
%   DEMOSCEN shows Short 1-D scenario demo.

%   DEMOSCEN('auto') shows Short 1-D scenario demo
%   in automatic mode.
%
%   DEMOSCEN('gr_auto') shows Short 1-D scenario demo
%   in automatic mode: first in the increasing slide
%   order and then in the decreasing slide order.
%
%   DEMOSCEN('loop') shows Short 1-D scenario demo
%   in loop mode.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 12-Oct-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.16 $ $Date: 2002/04/14 19:30:40 $

% Tag property of objects.
%------------------------
tag_dem_tool  = 'Demo_Tool';
tag_dmsgfig   = 'Wdmsgfig';
tag_sub_close = 'Sce_Close';

if nargin==0 , option = 'dw1d'; end

switch option
    case 'create'
        win = wfindobj('figure','tag',tag_dem_tool);
        if nargout>0 ,out1 = win; end

    case 'enable'

    case {'dw1d'}
        %*****************************************************%
        %** OPTION = 'dw1d' -  demo DW1D  (now only)        **%
        %*****************************************************%
        expo_flag = 0;
        if nargin==2 & isempty(in2) , expo_flag = 1; end
        demoname = ['dsce' option];
		addclose = [mfilename '(''close'');'];
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
		lstDEMOS = {'dw1d'};
        win = demoscen('create');
		stop = 0;
		while stop==0
			for k=1:length(lstDEMOS)
				feval(['dsce',lstDEMOS{k}],option);
				if ~ishandle(win) , stop = 1; break; end
			end
			if ~isequal(stop,1) & nargin==2 & isequal(in2,'loop')
				stop = 0 ;
			else
				stop = 1;
			end
		end
		
	case 'loop'
		%*******************************************%
		%** OPTION = 'loop' - loop automatic mode **%
		%*******************************************%
		demoscen('auto','loop');
		
	case 'close'
		%***********************************************%
		%** OPTION = 'close' - close demoscen window  **%
		%***********************************************%
		mousefrm(0,'watch')
		delete(wfindobj('figure','tag',tag_dmsgfig));
		
		win_ini = wfindobj('figure','tag',tag_dem_tool);
		if ~isempty(win_ini)
			pus_handles = findobj(win_ini,'Style','pushbutton');
			set(pus_handles,'Enable','on');
		else
			mextglob('clear');
			wtbxmngr('clear');
		end
		mousefrm(0,'arrow');
		
	otherwise
		errargt(mfilename,'Unknown Option','msg');
		error('*');
end

% Reset the LASTERR function
lasterr('');

