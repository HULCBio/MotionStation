function localize(this)
%LOCALIZE  Determines waveform location inside axes grid.
%
%  LOCALIZE compares the axes grid's row and column names with the 
%  data source's row and column names to determine the waveform 
%  location.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2004/04/16 22:20:06 $

% Default location is upper left corner
RowIndex = 1:length(this.RowIndex);
ColIndex = 1:length(this.ColumnIndex);

% Use data source info for named-based localization
if ~isempty(this.DataSrc)
   [RowNames,ColNames] = getrcname(this.Parent);
   try
      [SrcRowNames,SrcColNames] = getrcname(this.DataSrc);
      RowIndex = LocalMatchName(SrcRowNames,RowNames);
      ColIndex = LocalMatchName(SrcColNames,ColNames);
   end
end

% Assign new value (turn off listener for efficiency and to prevent 
% errors during plot resize)
set(this.Listeners,'Enable','off')
this.RowIndex = RowIndex;
this.ColumnIndex = ColIndex;
set(this.Listeners,'Enable','on')

% Update graphics
reparent(this)


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Localize a given set of row/column names among plot row/column labels
% RE: Generalized to any sortable entities, e.g., handles
% ----------------------------------------------------------------------------%
function Index = LocalMatchName(Names,RefNames)
if isempty(RefNames)
   % Axes grid row or column have fixed size = 1
   Index = 1;
else
   if iscell(Names) && any(cellfun('isempty',Names))
      % Not all names defined
      Index = [];
   else
      [junk,ia,ib] = intersect(RefNames,Names);
      [junk,is] = sort(ib);
      Index = ia(is).';
   end
   % Use default location if not all names were matched
   % REVISIT: assumes unique names!
   if length(Index)<length(Names)
      Index = 1:length(Names);
   end
end
