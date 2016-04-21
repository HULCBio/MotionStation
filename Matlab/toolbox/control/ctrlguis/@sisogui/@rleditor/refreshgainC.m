function refreshgainC(Editor,action)
%REFRESHGAINC  Refreshes plot during dynamic edit of C's gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/10 04:58:02 $

%RE: Do not use persistent variables here (several rleditor's
%    might track gain changes in parallel).

switch action
case 'init'
   % Initialization for dynamic gain update (drag).
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Install listener on compensator gain only
   CompData = Editor.LoopData.Compensator;
   Editor.EditModeData = handle.listener(CompData,findprop(CompData,'Gain'),...
       'PropertyPostSet',{@LocalUpdatePlot Editor});
   
case 'finish'
   % Return editor's RefreshMode to normal
   Editor.RefreshMode = 'normal';
   
   % Delete listener
   delete(Editor.EditModeData);
   Editor.EditModeData = [];
   
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(hSrcProp,event,Editor)
% Update position of closed-loop poles (magenta squares)

% Compute closed-loop poles 
Editor.ClosedPoles = ...
   fastrloc(getopenloop(Editor.LoopData),getzpkgain(Editor.EditedObject,'mag'));

% Update red square locations
for ct=1:length(Editor.ClosedPoles)
	set(Editor.HG.ClosedLoop(ct),...
		'Xdata',real(Editor.ClosedPoles(ct)),...
		'Ydata',imag(Editor.ClosedPoles(ct)))
end
