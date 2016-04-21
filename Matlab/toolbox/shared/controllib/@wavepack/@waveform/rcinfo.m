function [str,ShowName] = rcinfo(this,Row,Col)
%RCINFO  Constructs data tip text locating @waveform in axes grid.
%
%   The boolean SHOWNAME indicates that at least one of the names is 
%   user-defined (nonempty).

%   Author(s): Pascal Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:16 $

[RowNames,ColNames] = getrcname(this);

% Fill blank names
ShowName = 0;
if isempty(RowNames)
   rName = '';
else
   rName = RowNames{Row};
   if isempty(rName)
      rName = this.RowIndex(Row);  % Define name via row index
   else
      ShowName = 1;  % indicates user-defined names
   end
end
if isempty(ColNames)
   cName = '';
else
   cName = ColNames{Col};
   if isempty(cName)
      cName = this.ColumnIndex(Col);
   else
      ShowName = 1;  % indicates user-defined names
   end
end

% Construct text (delegate to @plot to accomodate plot-specific display)
str = this.Parent.rcinfo(rName,cName);