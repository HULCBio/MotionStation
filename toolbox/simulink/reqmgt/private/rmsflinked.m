function [reqitems, blktypes, itemnames] = rmsflinked(reqsys, doc, modelname)
%RMSFLINKED requirements management Stateflow states that have requirements links.
%   [REQITEMS, BLKTYPES, ITEMNAMES] = RMSFLINKED(REQSYS, DOC, MODELNAME)
%   returns all states that have requirements links in MODELNAME.  REQITEMS,
%   BLKTYPES, and ITEMNAMES are same-sized vectors.  MODELNAME must be in 
%   the current default directory or on the path.  Finds all states in all 
%   charts that have requirements links.
%
%   Returns: success = 3 vectors (can be empty) containing linked
%   items, failures = thrown.
%

%  Author(s): M. Greenstein, 11/30/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:43 $

% Validate input arguments.
if (nargin ~= 3)
   error('Insufficient number of arguments.  3 required.');
end
if (~exist('reqsys') | isempty(reqsys))
   error('No requirements system (reqsys) specified.');
end
if (~exist('doc') | isempty(doc))
   error('No document specified.');
end
if (~exist('modelname') | isempty(modelname))
   error('No model specified.');
end

% Stateflow installed?
if (~rmsfinst)
   error('Stateflow is not installed.');
end

% Create cell array containing all blocks.
reqitems = {};
blktypes = {};
itemnames = {};

% Get all states from this chart.
machine = sf('find', 'all', 'machine.name', modelname);
if isempty(machine)         % Model contains no Stateflow.
   return;
elseif length(machine) > 1  % Should never see two machines with same name.
   error(['Expected only one machine named ''' modelname '''.']);
end

% Collect all the charts. 
charts = sf('get', machine, 'machine.charts');
m = length(charts);

% Find all the 'true' requirements for reqsys.
linked = [];
for i = 1:m % For all charts.
   o = sf('ObjectsIn', charts(i));
	linkedstates = sf('regexp', o, 'state.requirementInfo', 'true');
   linkedstates = sf('regexp', linkedstates, 'state.requirementInfo', reqsys); 
   linkedtrans = sf('regexp', o, 'transition.requirementInfo', 'true');
   linkedtrans = sf('regexp', linkedtrans, 'transition.requirementInfo', reqsys);
   linked = [linkedstates linkedtrans];
end % for i = 1:m % For all charts.

% Create the output.
j = 1;
for i = 1:length(linked) 
   %%s = sf('FullNameOf', linked(i), '/');
   s = rmsfnamefull(linked(i));
   %%%%s = strrep(s, char(10), ' '); % Replace LFs with spaces.
   reqitems{j} = s;
   if (sf('get', linked(i), 'state.isa'))
      blktypes{j} = 'StateflowState';
      s = sf('get', linked(i), '.name');
		s = strrep(s, '/', '//');
      itemnames{j} = s;
   elseif (sf('get', linked(i), 'transition.isa'))
      blktypes{j} = 'StateflowTransition';
      s = sf('get', linked(i), '.labelString');
      
		s = strrep(s, '/', '//');
      itemnames{j} = s;
   end 
   j = j + 1;
end % for i:length(linked)

% end function [reqitems, blktypes, itemnames] = rmsflinked(reqsys, doc, modelname)

   