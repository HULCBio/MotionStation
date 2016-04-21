function refreshgainF(Editor,action,varargin)
%REFRESHGAINF  Refreshes open-loop plot during dynamic edit of F's gain.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:03:17 $

% Only need to update the open-loop plot when filter forms a minor-loop
if Editor.LoopData.Configuration ~= 4 
    return
end

switch action
    
case 'init'
    % Initialization for dynamic gain update (drag)
    % Switch editor's RefreshMode to quick
    Editor.RefreshMode = 'quick';
    
    % Hide "fixed" poles and zeros (change with F)
    set([Editor.HG.System.Magnitude;Editor.HG.System.Phase],'Visible','off')
      
    % Include C's x and o frequencies in main freq. vector
    hPZ  = [Editor.HG.Compensator.Magnitude; Editor.HG.Compensator.Phase]; 
    Wpz = get(hPZ,{'Xdata'});    
    Wpz = unitconv(cat(1,Wpz{:}),Editor.Axes.XUnits,'rad/sec');   
    W = [Editor.Frequency; Wpz]; 
    [junk,is] = sort(W);    % sorting needed to unwrap phase

    % Precompute frequency response of loop components
    LoopData = Editor.LoopData;
    S = LoopData.freqresp(W);

    % Install listener on filter gain (save ref in EditModeData)
    Filter = LoopData.Filter;
    InitPhase = round(Editor.Phase(1)/180);  % initial phase (as multiple of 180)
    L = handle.listener(Filter,findprop(Filter,'Gain'),...
         'PropertyPostSet',{@refreshplot W S InitPhase is});
    L.CallbackTarget = Editor;
    Editor.EditModeData = struct('GainListener',L);
    
case 'finish'
    % Return editor's RefreshMode to normal
    Editor.RefreshMode = 'normal';
    
    % Delete listener
    delete(Editor.EditModeData.GainListener);
    Editor.EditModeData = [];
    
end