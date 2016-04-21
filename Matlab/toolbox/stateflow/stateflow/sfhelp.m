function sfhelp(arg)
%SFHELP brings up online help and documentation for Stateflow.
%
%       See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFNEW, SFEXPLR.

%	 Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.34.4.1 $  $Date: 2004/04/15 01:01:40 $

%% turn off help during BAT testing
if(testing_stateflow_in_bat)
   return;
end

topic = '';

% First, figure out what type of thing is being passed in
if(nargin<1)
  % Nothing
  command = '';
else
  % Something.  Is it an object or a string?
  try
    % Give help on the first object, if given a bunch
    obj = arg(1);
    cls = classhandle(obj);
    
    if (isequal(get(get(cls, 'Package'), 'Name'), 'Stateflow'))
      % We've got a stateflow object
      cname = get(cls, 'Name');
      command = ['udd_' cname];
      
    else    
      % Non-Stateflow object!  Go to default sf help page.
      command = '';
      
    end
  catch
    % It's a string
    command = arg;
  end  
end


% handle explicit help requests regardless of where they
% eminate from.
switch(lower(command))
 case 'helpdesk'
  helpdesk;
  return;
 case 'stateflow'
  topic = 'STATEFLOW';
 case 'editor',
  topic =  'EDITOR';
 case 'explorer',
  topic = 'EXPLORER';
 case 'debugger',
  topic = 'DEBUGGER_DIALOG';
 case 'finder',
  topic = 'FINDER_DIALOG';
 case 'replace',
  topic = 'SEARCH_N_REPLACE_DIALOG';
 case 'target',
  topic = 'TARGET_DIALOG';   % main dialog
 case 'styler',
  topic = 'STYLER_DIALOG';
 case 'cycle_error'
  cycle_error_help;
  return;
 case 'obsoleted_features'
  topic = 'OBSOLETED_FEATURES';
 case 'udd_root'
  topic = 'root_methods';
 case 'udd_clipboard'
  topic = 'clipboard_methods';
 case 'udd_editor'
  topic = 'editor_properties';
 case 'udd_state'
  topic = 'state_properties';
 case 'udd_chart'
  topic = 'chart_properties';
 case 'udd_machine'
  topic = 'machine_properties';
 case 'udd_target'
  topic = 'target_properties';
 case 'udd_event'
  topic = 'event_properties';
 case 'udd_data'
  topic = 'data_properties';
 case 'udd_junction'
  topic = 'junction_properties';
 case 'udd_transition'
  topic = 'transition_properties';
 case 'udd_note'
  topic = 'note_properties';
 case 'udd_function'
  topic = 'function_properties';
 case 'udd_box'
  topic = 'box_properties';
 otherwise,
  topic = command;
end

% WUENSCH, redesign this file to be more like the above switch yard!

if ~isempty(topic);
    % using map file to isolate code from changes to doc
    helpview([docroot '/mapfiles/stateflow.map'], topic);
    return;
end;

obj = gcbo;

docRootDir = docroot;
% Show error if help docs not found
if (isempty(docRootDir))
   htmlFile = fullfile(matlabroot,'toolbox','local','helperr.html');
  	if (exist(htmlFile) ~=2)
   	error(sprintf('Could not locate help system home page.\nPlease make sure the help system files are installed.'));
   end
   display_file(htmlFile);
   return
end

if isempty(obj)
   % we must have been called from the command line: open up the whole collection
   helpview([docRootDir '/mapfiles/stateflow.map'], 'COLLECTION');
   return;
end

% we must have been called from a callback: open up specific help
 v = version;
if str2num(v(1)) < 6,
	topic = 'COLLECTION';
else,
	topic = 'STATEFLOW';              % default in case we can't find anything
end;
fig = get_parent_figure(obj);
if ~isempty(fig)
   tag = get(fig,'Tag');
   if ~isempty(tag)
      switch tag
         % someday we might want our own help for these contexts...
         % case 'PRINT->CURRENT VIEW'
         %    topic = 'chart42.html#11969';
         % case 'PRINT->ENTIRE CHART'
         %    topic = 'chart42.html#11969';
      case 'SFCHART'
         % editor specific menu pick
         if ~isempty(regexp(get(obj,'Label'),'Editor', 'once'))
            topic = 'EDITOR';
         % open the whole collection
         elseif ~isempty(regexp(get(obj,'Label'),'Topic', 'once'))
            topic = 'COLLECTION';
         end
      case 'SFEXPLR'
         % explorer-specific menu pick
         if ~isempty(regexp(get(obj,'Label'),'Explorer', 'once'))
            topic = 'EXPLORER';
         % open the whole collection
         elseif ~isempty(regexp(get(obj,'Label'),'Topic', 'once'))
            topic = 'COLLECTION';
         end
      case 'CHART'
         topic = 'CHART_DIALOG';
      case 'DATA'
         topic = 'DATA_DIALOG';
      case 'EVENT'
         topic = 'EVENT_DIALOG';
      case 'JUNCTION'
         % history or regular? help is same either way
         topic = 'JUNCTION_DIALOG';
      case 'MACHINE'
         % doesn't seem to be any help for machine properties dialog in user's guide
         topic = 'MACHINE_DIALOG';
      case 'STATE'
         % state or box? help is same either way
         userData = get(fig,'Userdata');
         stateType = sf('get',userData.objectId,'state.type');
         switch(stateType)
         case 2,
            if(sf('get', userData.objectId,'state.truthTable.isTruthTable'))
                topic = 'TRUTH_TABLE_DIALOG';
            else
                topic = 'FUNCTION_DIALOG';
            end
         case 3,
            topic = 'BLOCK_DIALOG';
         otherwise,
            topic = 'STATE_DIALOG';
         end
      case 'TARGET'
         topic = 'TARGET_DIALOG';   % main dialog
      case 'CODEROPTIONS'
         topic = 'CODEROPTIONS_DIALOG';
      case 'TARGETOPTIONS'
         topic = 'TARGETOPTIONS_DIALOG';
      case 'TRANSITION'
         topic = 'TRANSITION_DIALOG';
      case 'FINDER'
         topic = 'FINDER_DIALOG';
      case 'SF_DEBUGGER'
         topic = 'DEBUGGER_DIALOG';
		case 'SF_STYLER'
         topic = 'STYLER_DIALOG';
		case 'SFRGDialogFig'
         topic = 'PRINT_BOOK_DIALOG';
      end
   end
end

% using map file to isolate code from changes to doc
helpview([docroot '/mapfiles/stateflow.map'], topic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = get_parent_figure(obj)
fig = [];
if obj == 0 | ~ishandle(obj) return; end;
switch lower(get(obj,'Type'))
case 'figure'
   fig = obj;

case 'uicontrol'
   switch lower(get(obj,'style'))
   case {'pushbutton' 'text' 'edit'}
      fig = get(obj,'Parent');
   otherwise
      error('unexpected object invoked sfhelp');
   end

case 'uimenu'
   p = get(obj,'Parent');
   while isempty(findobj(p,'Type','Figure'))
      p = get(p,'Parent');
   end
   fig = p;

otherwise
   error('unexpected object invoked sfhelp');
end


function display_file(htmlFile)
    % Construct URL
    if (strncmp(computer,'MAC',3))
        html_file = ['file:///' strrep(html_file,filesep,'/')];
    end

    % Load the correct HTML file into the browser.
    stat = web(htmlFile);
    if (stat==2)
        error(sprintf('Could not launch Web browser. Please make sure that\nyou have enough free memory to launch the browser.'));
    elseif (stat)
        error(sprintf('Could not load HTML file into Web browser. Please make sure that\nyou have a Web browser properly installed on your system.'));
    end
