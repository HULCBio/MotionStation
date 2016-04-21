function settarget(Editor,varargin)
%SETTARGET  Callback from changing target (EditedObject)

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 04:55:37 $

Target = Editor.EditedObject;
if ~isempty(Target)
    % Resync data
    Editor.importdata;
    % Set listener to target properties
    Editor.TargetListeners = handle.listener(Target,Target.findprop('Format'),...
        'PropertyPostSet',{@LocalUpdateGain Editor});
end
    
    
%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateGain %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateGain(src,event,Editor)
% Update gain value in PZ editor
if ~isempty(Editor.EditedObject)
    Gain = Editor.EditedObject.getgain;
    set(Editor.HG.TopHandles(3),'String',sprintf('%0.3g',Gain),'UserData',Gain)
end


