function fcns = menus_cbs
%MENUS_CBS  Handles all the callbacks executed by the uimenus and
%           toolbar pushbuttons and togglebuttons.
% Callbacks assume parent figure has the following application data:
%       - 'theAudioPlayer' - audioplayer object
%       - 'theAudioRecorder' - audiorecorder object
%       - 'audioSelection' - structure containing inPoint and outPoint
%           fields for designating the current selection to be played

%   Author(s): B. Wherry
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:57 $ 


fcns.play_cb   = @play_cb;
fcns.record_cb = @record_cb;
fcns.stop_cb   = @stop_cb;
fcns.pause_cb  = @pause_cb;
fcns.gtend_cb  = @goto_end_cb;
fcns.gtbeg_cb  = @goto_beginning_cb;
fcns.ffwd_cb   = @ffwd_cb;
fcns.rewind_cb = @rewind_cb;

%---------------------------------------------------------------------
function play_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
recorder = getappdata(gcbf, 'theAudioRecorder');
selection = getappdata(gcbf, 'audioSelection');
if ~ isplaying(player),
    if get(player, 'CurrentSample') ~= 1,   % paused
        play(player, [(get(player, 'CurrentSample')) selection.outPoint]);
    else
        play(player, [selection.inPoint selection.outPoint]);
    end
end


%---------------------------------------------------------------------
function record_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
recorder = getappdata(gcbf, 'theAudioRecorder');
if ~ isrecording(recorder),
    if get(recorder, 'CurrentSample') ~= 1,     %paused
        resume(recorder);
    else
        record(recorder);
    end
end


%---------------------------------------------------------------------
function pause_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
recorder = getappdata(gcbf, 'theAudioRecorder');
if isplaying(player),
    pause(player);
elseif ~ isempty(recorder) && isrecording(recorder),
    pause(recorder);
else
    return;
end


%---------------------------------------------------------------------
function stop_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
recorder = getappdata(gcbf, 'theAudioRecorder');
if isplaying(player) || get(player, 'CurrentSample') ~= 1,
    stop(player);
elseif ~ isempty(recorder) && (isrecording(recorder) || get(recorder, 'CurrentSample') ~= 1),
    stop(recorder);
end


%---------------------------------------------------------------------
function goto_end_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
selection = getappdata(gcbf, 'audioSelection');
%what exactly should this do??


%---------------------------------------------------------------------
function goto_beginning_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
selection = getappdata(gcbf, 'audioSelection');
%what exactly should this do??


%---------------------------------------------------------------------
function ffwd_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
selection = getappdata(gcbf, 'audioSelection');
% what exactly should this do??



%---------------------------------------------------------------------
function rewind_cb(hcbo,eventStruct)
player = getappdata(gcbf, 'theAudioPlayer');
selection = getappdata(gcbf, 'audioSelection');
%what exactly should this do??
