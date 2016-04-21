function grandfather_precedence( chart )
% GRANDFATHER_PRECEDENCE( CHART )

%  Charlie DeVane
%  Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:58:18 $

for state = sf('get',chart,'.states')
   fixup_precedence(state);
end
for trans = sf('get',chart,'.transitions');
   fixup_precedence(trans);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fixup_precedence( object )

locs = sf('GrandfatherPrecedence',object,0);  % get locations of required parentheses
if isempty(locs), return; end

oldLabel = sf('get',object,'.labelString');
locs = remove_redundant_parens(oldLabel,locs);

if ~isempty(locs)
   oldAst = collect_asts(object);
   newLabel = insert_paren(oldLabel,locs);
   sf('set',object,'.labelString',newLabel);
   
   try
      sf('GrandfatherPrecedence',object,1);
      newAst = collect_asts(object);
      if ~isequal(oldAst,newAst)
         error('Asts not equal');
      end
   catch
      % if we get an error here, the translation screwed up somehow
      % restore the label and error out
      sf('set',object,'.labelString',oldLabel);
      %%disp('Failed to correctly update label string');
      return;
   end
   disp(sprintf('Note: in object #%d: expression depends on obsoleted operator precedence rules.', object));
   disp(sprintf('Inserted () into expression to preserve evaluation order.'));
   disp(sprintf('original label: %s',oldLabel));
   disp(sprintf('modified label: %s',newLabel));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ast = collect_asts(object)
ast = {};
%% vijay 04/18: when calling sf('Ast') method, we pass in
%% an additional boolean flag (0) not to fill in treeStart 
%% and treeEnd index values as these will make the asts
%% look different due to parenthesis insertions.

if ~isempty(sf('get',object,'state.id'))
   ast{end+1} = sf('Ast',object,'entryAction',0);
   ast{end+1} = sf('Ast',object,'activityAction',0);
   ast{end+1} = sf('Ast',object,'exitAction',0);
elseif ~isempty(sf('get',object,'transition.id'))
   ast{end+1} = sf('Ast',object,'condition',0);
   ast{end+1} = sf('Ast',object,'conditionAction',0);
   ast{end+1} = sf('Ast',object,'transitionAction',0);
else
   error('bogus object id');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newstr = insert_paren(oldstr, locs)
if isempty(locs)
   newstr = oldstr;
   return;
end

% convert start/end pairs into location/character pairs
nPairs = size(locs,1);
inserts = [locs(:,1); locs(:,2)];
inserts(1:nPairs,2) = '(';
inserts(nPairs+1:end,2) = ')';
nInserts = size(inserts,1);
% add a dummy terminator - location impossibly high
% this simplifies & speeds insertion loop below
inserts(end+1,:) = [inf 0];

% sort the location/character pairs so we can insert them in order
% note: this algorithms relies on there being no place in the
% language where we might need to insert both '(' and ')' at the
% same position.  If that occured, the sort below might cause us
% to insert '()' when we really wanted to insert ')('.
inserts = sortrows(inserts,1);

% insert the ()s
insertIndex = 1;
oldPos = 1;
for newPos = 1:(length(oldstr)+nInserts)
   % sprintf('i is %d', newPos);
   if oldPos == inserts(insertIndex,1)
      newstr(newPos) = inserts(insertIndex,2);
      insertIndex=insertIndex+1;
   else
      newstr(newPos) = oldstr(oldPos);
      oldPos=oldPos+1;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newlocs = remove_redundant_parens(oldstr, oldlocs)
% if the subexpression is already parenthesized in the 
% label string, don't add more parentheses
newlocs = [];
for i = 1:size(oldlocs,1)
   if ~is_already_parenthesized( oldstr, oldlocs(i,1), oldlocs(i,2) )
      newlocs(end+1,:) = oldlocs(i,:);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = is_already_parenthesized( oldstr, first, last )
% sprintf('checking for () in ''%s''',oldstr(first:last))

result = 0;
% search backward for opening paren
if first <= 1 
   return;
end
i = first-1;
while i > 1 & isspace(oldstr(i))
   i = i-1;
end
if oldstr(i) ~= '('
   return;
end

% search forward for closing paren
if last > length(oldstr)
   return;
end

i = last;
while( i < length(oldstr) & isspace(oldstr(i)) )
   i = i+1;
end
if oldstr(i) ~= ')'
   return;
end

result = 1;
return;


      
      
      
      
      
      
      
      
      
      
      
      
      
      
