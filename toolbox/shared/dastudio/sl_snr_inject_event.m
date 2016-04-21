function sl_snr_inject_event (cmd)
% sl_snr_inject_event  Inject an event into the Grand Unified Search and Replace
%
% Use: sl_snr_inject_event (ev), where ev can be one of
%   'search'        Search for the next match
%   'replace'       Replace the current match
%   'replaceAll'    Replace all additional matches
%   'help'          Get Help
%   'cancel'        Close this dialog
%   'regExp'        Search by Regular Expressions
%   'matchWord'     Match only exact words
%   'containsWord'  Match directly
%   'fieldsToggle'  Toggle the display of the fields checkboxes
%   'labels'        Toggle the searching of labels
%   'names'         Toggle the searching of labels
%   'descriptions'  Toggle the searching of labels
%   'document'      Toggle the searching of labels
%   'customCode'    Toggle the searching of labels
%   'typesToggle'   Toggle the display of the types checkboxes
%   'states'        Toggle the searching of states
%   'charts'        Toggle the searching of charts
%   'junctions'     Toggle the searching of junctions
%   'transitions'   Toggle the searching of transitions
%   'data'          Toggle the searching of data
%   'events'        Toggle the searching of events
%   'targets'       Toggle the searching of targets
%   'machine'       Toggle the searching of machine
%   'chartScope'    Set the search scope to chart
%   'machineScope'  Set the search scope to machine
%   'replaceThis'   Replace all the matches in the current object
%   'refreshTypes'  Refresh the types string if applicable
%   'standAlone'    Initialize or reset the search machine
%   'reset'         Reset the search (and redisplay the figure if necessary)
%   'kill'          Destroy the figure and the state machine
%   'mouse_up'      Denotes a mouse up action
%   'mouse_down'    Denotes a mouse down action
%   'mouse_moved'   Denotes a mouse moved action
%   'view'          View the current item in a chart or explorer
%   'properties'    View the Properties Dialog for the current item
%   'explore'       View the current item in a explorer
%   'escape'        Reset the mouse mode
%   'matchCase'     Toggle Case Sensitivity
%   'preserveCase'  Toggle Case Preservation


%
%   Tom Walsh August 2000
%   J Breslau September 2000
%
%   Copyright 2000-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:20 $
%

% keep track of the instance
persistent instId;

if isempty(instId)
    if strcmp(cmd, 'standAlone')
        % create an instance
        instId = slsnr_sfm('create');
        return;
    else
        % initializing
        return;
    end
end


switch cmd,
case 'search',
    slsnr_sfm('broadcast', instId, 'SEARCH');
case 'replace',
    slsnr_sfm('broadcast', instId, 'REPLACE');
case 'replaceAll',
    slsnr_sfm('broadcast', instId, 'REPLACE_ALL');
case 'cancel',
    slsnr_sfm('broadcast', instId, 'CANCEL');
case 'regExp',
    slsnr_sfm('broadcast', instId, 'REG_EXP');
case 'matchWord',
    slsnr_sfm('broadcast', instId, 'MATCH_WORD');
case 'matchCase',
    slsnr_sfm('broadcast', instId, 'MATCH_CASE');
case 'preserveCase',
    slsnr_sfm('broadcast', instId, 'PRESERVE_CASE');
case 'containsWord',
    slsnr_sfm('broadcast', instId, 'CONTAINS_WORD');
case 'replaceThis',
    slsnr_sfm('broadcast', instId, 'REPLACE_THIS');
case 'mouse_up',
    slsnr_sfm('broadcast', instId, 'MOUSE_UP');
case 'mouse_down',
    slsnr_sfm('broadcast', instId, 'MOUSE_DOWN');
case 'mouse_moved',
    slsnr_sfm('broadcast', instId, 'MOUSE_MOVED');
case 'view',
    slsnr_sfm('broadcast', instId, 'VIEW');
case 'properties',
    slsnr_sfm('broadcast', instId, 'PROPERTIES');
case 'explore',
    slsnr_sfm('broadcast', instId, 'EXPLORE');
case 'escape',
    slsnr_sfm('broadcast', instId, 'ESCAPE');
case 'kill',
    try
        slsnr_sfm('broadcast', instId, 'KILL');
        slsnr_sfm('destroy', instId);
        instId = [];
    catch
        % the machine has already been killed
    end
case 'standAlone',
    % reset
    slsnr_sfm('broadcast', instId, 'RESET');
end % switch cmd
