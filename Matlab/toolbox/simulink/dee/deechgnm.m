function deechgnm()
%DEECHNM Change the name of a DEE block.
%   DEECHGNM changes the name of a DEE block.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

% inputs:  none
% outputs: none

% this function:
%      (i)    gets the string in the name edit field in the DEE and then
%      (ii)   takes the string stored therein and changes the name of the
%             block to this new string


% useful handles
fig = gcf;
handles = get(fig,'UserData');
nameh = handles(11);

% setup
set(fig,'Pointer','Watch');drawnow


%                                   (i)                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the string value of the name field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newname = get(nameh,'String');


%                                   (ii)                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stuff string into mask display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sysname = get(fig,'Name');

set_param(sysname,...
          'Mask Display',newname);

set(fig,'Pointer','Arrow');drawnow