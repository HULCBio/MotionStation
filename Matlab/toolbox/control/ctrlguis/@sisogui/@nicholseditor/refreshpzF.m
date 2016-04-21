function refreshpzF(Editor,event,varargin)
%REFRESHPZF  Refreshes plot during dynamic edit of F's poles and zeros.
%
%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 05:05:43 $

% Only need to update rleditor if filter forms a minor-loop
if Editor.LoopData.Configuration ~= 4
    return
end

% Process events
switch event 
case 'init'   
    % Initialization for dynamic gain update (drag).
    PZGroup = varargin{1};     % Modified PZGROUP
    
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';    
    
    % For speed, hide "fixed" poles and zeros (vary with F)
    set(Editor.HG.System,'Visible','off')

    % Precompute frequency response of loop components
    LoopData = Editor.LoopData;
    W = Editor.Frequency;
    S = LoopData.freqresp(W);

    % Install listener on PZGROUP data and store listener reference 
    InitPhase = round(Editor.Phase(1)/180);  % initial phase (as multiple of 180)
    L = handle.listener(PZGroup,'PZDataChanged',{@refreshplot W S InitPhase get(PZGroup) PZGroup});
    L.CallbackTarget = Editor;
    Editor.EditModeData = L;
    
case 'finish'
    % Clean up after dynamic gain update (drag)
    % Return editor's RefreshMode to normal
    Editor.RefreshMode = 'normal';
    
    % Delete gain listener
    delete(Editor.EditModeData);
    Editor.EditModeData = [];
end
