function showwindow(name, state, onTop)
% Copyright 2004 The MathWorks, Inc.

if ~ispc
	return;
end

if ~libisloaded(mfilename);
	loadlibrary('user32.dll',@userproto,'alias',mfilename);
end

switch state
	case 'hide',            flag =  0;
	case 'shownormal',      flag =  1;
	case 'normal',          flag =  1;
	case 'showminimized',   flag =  2;
	case 'showmaximized',   flag =  3;
	case 'maximize',        flag =  3;
	case 'shownoactivate',  flag =  4;
	case 'show',            flag =  5;
	case 'minimize',        flag =  6;
	case 'showminnoactive', flag =  7;
	case 'showna',          flag =  8;
	case 'restore',         flag =  9;
	case 'showdefault',     flag = 10;
	case 'forceminimize',   flag = 11;
	case 'max',             flag = 11;
	otherwise error('Unknown state "%s".',state);
end

h = calllib(mfilename, 'FindWindowA', [], name);
calllib(mfilename, 'ShowWindow', h, flag);

if onTop
	calllib(mfilename, 'SetForegroundWindow', h);
end;

%===============================================================================
function [fcns,structs,enuminfo] = userproto

fcns=[]; structs=[]; enuminfo=[]; fcns.alias={};

%  HWND _stdcall FindWindowA(LPCSTR,LPCSTR); 
fcns.name{1} = 'FindWindowA';
fcns.calltype{1} = 'stdcall';
fcns.LHS{1} = 'voidPtr';
fcns.RHS{1} = {'int8Ptr', 'string'};

%  BOOL _stdcall ShowWindow(HWND,int); 
fcns.name{2} = 'ShowWindow';
fcns.calltype{2} = 'stdcall';
fcns.LHS{2} = 'int32';
fcns.RHS{2} = {'voidPtr', 'int32'};

% BOOL SetForegroundWindow(HWND hWnd);
fcns.name{3} = 'SetForegroundWindow';
fcns.calltype{3} = 'stdcall';
fcns.LHS{3} = 'int32';
fcns.RHS{3} = {'voidPtr'};
