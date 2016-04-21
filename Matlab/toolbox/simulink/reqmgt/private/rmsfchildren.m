function [children, linked, descendents, blktypes] = rmsfchildren(doc, parent)
%RMSFCHILDREN requirements manager children and requirements of a Stateflow state.
%   [CHILDREN, LINKED, DESCENDENTS, BLKTYPES] = 
%   RMSFCHILDREN(DOC, PARENT)
%   returns all the children states and transitions, whether the children
%   have requirements links, how many descendents, and the block type.  
%   For example, try:
%   [c, l, d, b] = rmsfchildren('f14', 'f14');
%
%   Returns: success = 4 cell arrays of strings; errors = all thrown.
%
%   Used for populating tree navigation controls.
%   Assumes system is opened.
%

%  Author(s): M. Greenstein, 11/18/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:40 $

% Validate input arguments.
if (~exist('doc') | isempty(doc))
   error('No document specified.');
end
if (~exist('parent') | isempty(parent))
   error('No system specified.');
end
   
% Stateflow installed?
if (~rmsfinst)
   error('Stateflow is not installed.');
end

machine = sf('find', 'all', 'machine.name', doc);
if isempty(machine)         % Model contains no Stateflow.
   return;
elseif length(machine) > 1  % Should never see two machines with same name.
   error(['Expected only one machine named ''' doc '''.']);
end

%%% Collect all the charts. 
%%charts = sf('get', machine, 'machine.charts');

%%% Get the name in the proper form for Stateflow to look up.
%%% This a brute-force method to find the uniquely named chart
%%% or state.
%%id = [];
%%s = parent(min(find(parent == '/')) + 1 : end);
%%id = sf('find', charts, 'chart.name', s);
%%while (isempty(id))
%%   try
%%      s = s(min(find(s == '/')) + 1 : end);
%%      id = sf('find', 'all', 'state.name', s); 
%%   catch
%%      error('Chart or state not found.');
%%   end
%%end

% Get the states for this chart.
%%states = sf('get', id, 'chart.states');

[cid, id] = rmsfid(doc, parent);
if (id == 0), id = cid; end
if (isempty(id))
  	error(['No Stateflow id for ' name '.']);
end

% Get the items at this level.
%%temp = sf('find', states, '.treeNode.parent', id);
items = sf('AllSubstatesOf', id);
nstates = length(items);
items = [items sf('TransitionsOf', id)];
   
% Initialize output structures.
reqsys = reqmgropts;
children = {};
linked = {};
descendents = {};
blktypes = {};
n = length(items);
if (~n), return; end

% Loop through all the states at this level, noting which
% have valid requirements links in them.
for i = 1:n
   str = '';
   des = {};
   ndes = 0;

   % Look at the value in the Document field for the requirement data.
   r = 'false';
   str = sf('get', items(i), '.requirementInfo');
   if(length(str))
      req = reqinitstr(str);
      res = reqget(req, reqsys);
      % Look through all the items in the res cell array for at least one true.
      [rows, cols] = size(res);
		for j = 1:rows      
         if (strcmp(res{j, 2}, 'true')) 
            r = 'true'; 
            break;
         end
      end
   end
   
   % Are there descendents?  How many?
   %%des = sf('find', states, '.treeNode.parent', temp(i));
   if (i <= nstates)
      des = sf('AllSubstatesOf', items(i));
      des = [des sf('TransitionsOf', items(i))];
      s = sf('get', items(i), '.name');
   else
      s = sf('get', items(i), '.labelString');
   end
   ndes = length(des);
   
   % Put all the info into a cell array row.
   %%%%s = sf('FullNameOf', items(i), '/');
   %%%%s = rmsfnamefull(items(i));
   %%%%s = char(strrep(s, char(10), ' ')); % Replace line feeds with spaces.
   %%s = strrep(s, '//', '~~'); % Replace double slashes with tildas temporarily.

   %%j = findstr(s, '/');
   %%if (~isempty(j))
   %%   b = max(j) + 1;
   %%   s = s(b:end);
   %%  s = strrep(s, '~~', '//');
      children{i} = s;
      linked{i} = r;
      descendents{i} = num2str(ndes);
      
	   if (i <= nstates)
   		blktypes{i} = 'StateflowState';
   	else      
  			blktypes{i} = 'StateflowTransition';
   	end
	%%end
end

% end function [children, linked, descendents, blktypes] = rmsfchildren(doc, parent)
