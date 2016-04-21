function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:29 $

if (c.att.isSinglePlot | c.att.isDoublePlot)
   plotString = 'snapshot';
else
   plotString = '';
end

if (c.att.isSingleTable | c.att.isDoubleTable | c.att.isMultiTable)
   tableString = 'table';
else
   tableString = '';
end

if (c.att.isSinglePlot | c.att.isSingleTable)
   singleString = '1-D';
else
   singleString = '';
end

if (c.att.isDoublePlot | c.att.isDoubleTable)
   doubleString = '2-D';
else
   doubleString = '';
end

if (c.att.isMultiTable)
    multiString = 'N-D';
    if (~isempty(singleString) | ~isempty(doubleString))
        multiConjunction='/';
    else
        multiConjunction='';
    end
else
    multiString = '';
    multiConjunction='';
end

if (~isempty(tableString) & ~isempty(plotString))
   typeConjunction = '/';
else
   typeConjunction = '';
end

if (~isempty(singleString) & ~isempty(doubleString))
   dimensionConjunction = '/';
else
   dimensionConjunction = '';
end


strout = sprintf('Look-Up %s%s%s (%s%s%s%s%s)',...
      plotString,...
      typeConjunction,...
      tableString,...
      singleString,...
      dimensionConjunction,...
      doubleString,...
      multiConjunction,...
      multiString);
