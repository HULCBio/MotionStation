function    sf_snr_inject_event(cmd)
% SF_SNR_INJECT_EVENT  Inject   an  event   into the    Stateflow Icon  Editor
%
% Use: sf_snr_inject_event  (ev),   where   ev  can be one of
%    'search'         Search for the next match
%    'replace'        Replace the current match
%    'replaceAll'     Replace all additional matches
%    'help'           Get Help
%    'cancel'         Close this dialog
%    'regExp'         Search by Regular Expressions
%    'matchWord'      Match only exact words
%    'containsWord'   Match directly
%    'fieldsToggle'   Toggle the display of  the fields checkboxes
%    'labels'         Toggle the searching of labels
%    'names'          Toggle the searching of labels
%    'descriptions'   Toggle the searching of labels
%    'document'       Toggle the searching of labels
%    'customCode'     Toggle the searching of labels
%    'typesToggle'    Toggle the display of  the types checkboxes
%    'states'         Toggle the searching of states
%    'charts'         Toggle the searching of charts
%    'junctions'      Toggle the searching of junctions
%    'transitions'    Toggle the searching of transitions
%    'data'           Toggle the searching of data
%    'events'         Toggle the searching of events
%    'targets'        Toggle the searching of targets
%    'machine'        Toggle the searching of machine
%    'chartScope'     Set the search scope to chart
%    'machineScope'   Set the search scope to machine
%    'replaceThis'    Replace all the matches in the  current object
%    'refreshTypes'   Refresh the types string if applicable
%    'standAlone'     Initialize or reset the search machine
%    'reset'          Reset the search (and redisplay the figure if necessary)
%    'kill'           Destroy the figure and the state machine
%    'mouse_up'       Denotes a mouse up action
%    'mouse_down'     Denotes a mouse down action
%    'mouse_moved'    Denotes a mouse moved action
%    'view'           View the current item in a chart or explorer
%    'properties'     View the Properties Dialog for the current item
%    'explore'        View the current item in an explorer
%    'escape'         Reset the mouse mode
%    'matchCase'      Toggle Case Sensitivity
%    'preserveCase'   Toggle Case Preservation


%
%    Tom Walsh August 2000
%    J Breslau September 2000
%
%    Copyright 2000-2003 The MathWorks, Inc.
%    $Revision: 1.8.4.2 $ $Date: 2004/04/15 00:59:48 $
%

% keep track of the instance
persistent instId;

if isempty(instId)
    if strcmp(cmd, 'standAlone')
        % create an instance
        instId = snr_sfm('create');
        return;
    else
        % initializing
        return;
    end
end

switch cmd,
case 'search',
    snr_sfm('broadcast', instId, 'SEARCH');
case 'replace',
    snr_sfm('broadcast', instId, 'REPLACE');
case 'replaceAll',
    snr_sfm('broadcast', instId, 'REPLACE_ALL');
case 'help',
    snr_sfm('broadcast', instId, 'HELP');
case 'cancel',
    snr_sfm('broadcast', instId, 'CANCEL');
case 'regExp',
    snr_sfm('broadcast', instId, 'REG_EXP');
case 'matchWord',
    snr_sfm('broadcast', instId, 'MATCH_WORD');
case 'matchCase',
    snr_sfm('broadcast', instId, 'MATCH_CASE');
case 'preserveCase',
    snr_sfm('broadcast', instId, 'PRESERVE_CASE');
case 'containsWord',
    snr_sfm('broadcast', instId, 'CONTAINS_WORD');
case 'fieldsToggle',
    snr_sfm('broadcast', instId, 'FIELDS_TOGGLE');
case 'labels',
    snr_sfm('broadcast', instId, 'LABELS');
case 'names',
    snr_sfm('broadcast', instId, 'NAMES');
case 'descriptions',
    snr_sfm('broadcast', instId, 'DESCRIPTIONS');
case 'document',
    snr_sfm('broadcast', instId, 'DOCUMENT');
case 'customCode',
    snr_sfm('broadcast', instId, 'CUSTOM_CODE');
case 'typesToggle',
    snr_sfm('broadcast', instId, 'TYPES_TOGGLE');
case 'states',
    snr_sfm('broadcast', instId, 'STATES');
case 'charts',
    snr_sfm('broadcast', instId, 'CHARTS');
case 'junctions',
    snr_sfm('broadcast', instId, 'JUNCTIONS');
case 'transitions',
    snr_sfm('broadcast', instId, 'TRANSITIONS');
case 'data',
    snr_sfm('broadcast', instId, 'DATA');
case 'events',
    snr_sfm('broadcast', instId, 'EVENTS');
case 'targets',
    snr_sfm('broadcast', instId, 'TARGETS');
case 'machine',
    snr_sfm('broadcast', instId, 'MACHINE');
case 'chartScope',
    snr_sfm('broadcast', instId, 'CHART_SCOPE');
case 'machineScope',
    snr_sfm('broadcast', instId, 'MACHINE_SCOPE');
case 'replaceThis',
    snr_sfm('broadcast', instId, 'REPLACE_THIS');
case 'refreshTypes',
    snr_sfm('broadcast', instId, 'REFRESH_TYPES');
case 'mouse_up',
    snr_sfm('broadcast', instId, 'MOUSE_UP');
case 'mouse_down',
    snr_sfm('broadcast', instId, 'MOUSE_DOWN');
case 'mouse_moved',
    snr_sfm('broadcast', instId, 'MOUSE_MOVED');
case 'view',
    snr_sfm('broadcast', instId, 'VIEW');
case 'properties',
    snr_sfm('broadcast', instId, 'PROPERTIES');
case 'explore',
    snr_sfm('broadcast', instId, 'EXPLORE');
case 'escape',
    snr_sfm('broadcast', instId, 'ESCAPE');
case 'kill',
    try
        snr_sfm('broadcast', instId, 'KILL');
        snr_sfm('destroy', instId);
        instId =    [];
    catch
        % the machine has already been killed
    end
case 'standAlone',
    % reset
    snr_sfm('broadcast', instId, 'RESET');
end % switch cmd
