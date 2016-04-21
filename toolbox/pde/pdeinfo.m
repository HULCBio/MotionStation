function [outstr,save]=pdeinfo(str,flag)
%PDEINFO Displays information string for PDE Toolbox.
%
%       Usage: PDEINFO(STR,FLAG), where STR contains the string to be
%       displayed. If called without arguments, redisplays previous info.
%       PDEINFO(STR,1) (default) saves the displayed string (will become
%       previous info). PDEINFO(STR,0) displays string without saving it.

%       Magnus Ringh 7-01-94, MR 5-05-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:16 $

if nargin<2, flag=1; end

pde_fig=findobj(get(0,'Children'),'flat','Tag','PDETool');
hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEInfo');
if isempty(hndl), return; end

% case: display info

if nargin>0

  save=get(hndl,'Value');
  if save==1,
    tmp=get(hndl,'String');
    set(hndl,'UserData',tmp)
  end
  if flag==2,
    set(hndl,'Value',flag,'String',str)
  else
    set(hndl,'Value',flag,'String',str,'Callback',str)
  end

% case: return current string

elseif nargout,

  outstr=get(hndl,'Callback');
  save=get(hndl,'Value');

% case: redisplay previous info

else

  tmp=get(hndl,'UserData');
  set(hndl,'String',tmp,'Callback',tmp)

end

