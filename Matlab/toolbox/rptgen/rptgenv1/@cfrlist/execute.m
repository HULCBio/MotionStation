function out=execute(c)
%EXECUTE report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:34 $

out=LocProcessCells(c,LocGetCells(c),parsevartext(c,c.att.ListTitle));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocProcessCells(c,ItemCells,titleString)

if isempty(ItemCells)
    out=[];
    return;
end

out=set(sgmltag,...
   'tag',c.att.ListStyle);

isSimple=0;
switch lower(c.att.ListStyle)
case 'orderedlist'
    out=att(out,...
        'Numeration',c.att.NumerationType,...
        'Inheritnum',c.att.NumInherit,...
        'Continuation',c.att.NumContinue,...
        'Spacing',c.att.Spacing);
case 'simplelist'
    out=att(out,...
        'Columns',1);
    isSimple=1;
otherwise %itemizedlist
    out=att(out,...
        'Spacing',c.att.Spacing);
end

if nargin>2 & ~isempty(titleString)
    out.data={set(sgmltag,'tag','Title','data',titleString)};
end

if isSimple
    iTag=set(sgmltag,'tag','Member');
else
    iTag=set(sgmltag,'tag','ListItem');
end

i=1;
while i<=length(ItemCells)
   subListTag='';
   if i<length(ItemCells) & ...
           iscell(ItemCells{i+1}) & ...
           ~isSimple
      subListTag=LocProcessCells(c,ItemCells{i+1});
      increment=2;
   else
      increment=1;
   end
   out=[out ; ...
         [verifychild(set(iTag,'data',ItemCells{i}));subListTag]];
   i=i+increment;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function itemCells=LocGetCells(c)

myChildren=children(c);
if ~isempty(myChildren)
   itemCells=runcomponent(myChildren,5);
   if isa(itemCells,'sgmltag') & ...
           isempty(itemCells.tag) & ...
           iscell(itemCells.data)
      itemCells=itemCells.data;
   elseif isa(itemCells,'cell')
   else
      itemCells={itemCells};
   end
else
   if c.att.isSourceFromWorkspace
      try
         itemCells=evalin('base',c.att.SourceVariableName);
      catch
         status(c,sprintf('Error - Could not read variable "%s".', ...
               c.att.SourceVariableName ),1);
         itemCells={};
      end
   else
      itemCells={c.att.SourceCell{:}};
   end
end

if ~iscell(itemCells)
   status(c,sprintf('Error - Variable "%s" is not a cell array.',...
         c.att.SourceVariableName),1);        
   itemCells={};
else
   itemCells={itemCells{:}};
end
