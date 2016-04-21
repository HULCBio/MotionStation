function update(this,varargin)
%UPDATE  Updates axes selector GUI.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:41 $

% RE: Behavior mimics two independent listboxes containing the row & column names
H = this.Handles;

% Dot color
for j=1:this.Size(2)
   for i=1:this.Size(1)
      if this.RowSelection(i) & this.ColumnSelection(j)
         DotColor = this.Style.OnColor;
      else
         DotColor = this.Style.OffColor;
      end
   set(H.Dots(i,j),'Color',DotColor,'MarkerFaceColor',DotColor);
   end
end

% Text color
set([H.AllText;H.RowText;H.ColText],'Color',[0 0 0])  % reset
if all(this.RowSelection) & all(this.ColumnSelection)
   set(H.AllText,'Color',[1 0 0])
end
% Hightlight selected rows and columns in red
set(H.ColText(this.ColumnSelection),'Color',[1 0 0])
set(H.RowText(this.RowSelection),'Color',[1 0 0])   

% Row names
RowLabels = this.RowName;
if this.Size(1)>1
   for ct=1:this.Size(1)
      if isempty(RowLabels{ct})
         RowLabels{ct} = sprintf('r%d',ct);
      end
   end
end
set(H.RowText,{'String'},RowLabels)

% Column names
ColumnLabels = this.ColumnName;
if this.Size(2)>1
   for ct=1:this.Size(2)
      if isempty(ColumnLabels{ct})
         ColumnLabels{ct} = sprintf('c%d',ct);
      end
   end
end
set(H.ColText,{'String'},ColumnLabels)
