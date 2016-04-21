function varpick(varlist,hndl)

%VARPICK  Modal pick list to select a variable from the workspace
%
%  VARPICK(list,h) displays a list box allowing the selection of
%  a variable name from the cell array list and assigns this name
%  to the edit box specified by the handle h.  This function is
%  used by several GUIs in the Mapping Toolbox to select variables
%  from the workspace.  The typical callback to activate this
%  function is varpick(who,h).

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
%  Written by:  E. Byrns, E. Brown


if nargin ~= 2;  error('Incorrect number of arguments');  end

%  Make the variable list into a string matrix.

if isempty(varlist);    varlist = ' ';
    else;               varlist = char(varlist);  end

%  Make the list dialog for the variable list

indx = listdlg('ListString',cellstr(varlist),...
               'SelectionMode','single',...
					'ListSize',[160 170],...
					'Name','Select a Variable');

if ~isempty(indx);   set(hndl,'String',deblank(varlist(indx,:)));   end
