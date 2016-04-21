function wf = addwf(this, varargin)
%ADDWF  Adds a new @waveform to a given plot.
%
%   WF = ADDWF(PLOT,ROWINDEX,COLINDEX,NWAVES) creates a new @waveform 
%   WF for the @plot instance PLOT.  The index vectors ROWINDEX 
%   and COLINDEX specify the wave position in the axes grid, and NWAVES
%   specifies the number of individual waves in W.
%
%   WF = ADDWF(PLOT,DATASRC) adds a wave W that is hot-linked to the data 
%   source DATASRC.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Revised  : Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:12 $

% Create a new @waveform object
wf = wavepack.waveform;
wf.Parent = this;

% Determine @waveform size (#rows, #columns, #waves)
nvargs = length(varargin);
switch nvargs
case 0
   % Spans full grid by default
   wf.RowIndex = 1:this.AxesGrid.Size(1);
   wf.ColumnIndex = 1:this.AxesGrid.Size(2);
   Nwaves = 1;
case 1
   % Data source supplied
   DataSrc = varargin{1};
   if ~isa(DataSrc, 'wrfc.datasource')
      error('Data source should be a subclass of wrfc.datasource.')
   end
   wf.DataSrc = DataSrc;
   wf.Name = DataSrc.Name;
   % Localize RowIndex and ColumnIndex
   localize(wf)
   Nwaves = getsize(DataSrc,3);
otherwise
   wf.RowIndex = varargin{1};
   wf.ColumnIndex = varargin{2};
   Nwaves = [varargin{3:end} ones(1,3-nvargs)];
end

% Initialize new @waveform
initialize(wf,Nwaves)

% Add default tip (tip function calls MAKETIP first on data source, then on view)
addtip(wf)

% Set style
% RE: Before adding wave to plot's wave list so that legend available to RC menus
SList = get(allwaves(this),{'Style'});
StyleList = cat(1,SList{:});
wf.Style = this.StyleManager.dealstyle(StyleList);  % use next available style
