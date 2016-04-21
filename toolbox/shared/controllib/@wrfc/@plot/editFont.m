function FontBox = editFont(this,BoxLabel,BoxPool)
% Builds Font Tab for Property Editor

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:19 $
AxGrid = this.AxesGrid;

% Build FontData structure (targets generic editor to adequate style
% objects)
FontData = struct(...
   'FontLabel',{sprintf('Title:');sprintf('X/Y-Labels:');...
      sprintf('Tick Labels:');sprintf('I/O-Names:')},...
   'FontTarget',{AxGrid.TitleStyle;...
      [AxGrid.XlabelStyle;AxGrid.YLabelStyle];...
      AxGrid.AxesStyle;...
      [AxGrid.ColumnLabelStyle;AxGrid.RowLabelStyle]});

% Create group box
FontBox = this.AxesGrid.editFont(BoxLabel,BoxPool,FontData);

