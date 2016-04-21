function varargout = exportlti(action,varargin)
%EXPORTLTI opens the window for exporting LTI models from CODA GUIs
%   EXPORTLTI('initialize',ParentFig,ExportData,Title) opens an Export Window
%   when issued by a callback from the GUI with handle ParentFig. The
%   data available to be exported is passed to the Export window in
%   the structured array ExportData.
%
%   ExportData = EXPORTLTI('getdata') returns an empty structured array
%   in the form that must be passed to EXPORTLTI.

%   Authors: Karen D. Gondoly
%   Revised: Adam W. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 04:43:21 $

%---Check if number of input arguments is in the correct range
ni = nargin;
no = nargout;

%---Read data based on action
switch lower(action)
case 'getdata', % Return an empty Data structure
    ExportData =struct('All',struct('Name',[],'Model',{}),...
        'DesignModels',struct('Name',[],'Model',{}),...
        'OpenLoop',struct('Name',[],'Model',{}),...
        'ClosedLoop',struct('Name',[],'Model',{}),...
        'Compensators',struct('Name',[],'Model',{}),...
        'MatName','untitled');
    if no,
        varargout{1}=ExportData;
    end
    return
    
case 'initialize',
   ParentFig = varargin{1};
   ExportData=[];
   Title = 'Export';
   if ni>2,
      ExportData = varargin{2};
   end
   if ni>3
      Title = varargin{3};
   end
   if isempty(ExportData),
       ExportData =struct('All',struct('Name',[],'Model',{}),...
           'DesignModels',struct('Name',[],'Model',{}),...
           'OpenLoop',struct('Name',[],'Model',{}),...
           'ClosedLoop',struct('Name',[],'Model',{}),...
           'Compensators',struct('Name',[],'Model',{}),...
           'MatName','untitled');
   end
   
otherwise
   ExportFig = varargin{1};
   if ni>2,
      ExportUd = varargin{2};
   else
      ExportUd = get(ExportFig,'UserData');
   end
end % switch action

%---Actions
switch action
case 'initialize',
   ExportFig = LocalOpenFig(ParentFig,ExportData,Title);
   uiwait(ExportFig)
   
   if ishandle(ExportFig)
      close(ExportFig)
   end
   
case 'disk',
   %---Callback from the Export to Disk button
   ExportVal = get(ExportUd.Handles.ModelList,'Value');
   if isempty(get(ExportUd.Handles.ModelList,'String')),
      warndlg('There are no systems to export.','Export Warning');
      return      
   end
   
   if ~isempty(ExportVal),
      
      fname = ExportUd.MatName;
      fname=[fname,'.mat']; % Revisit for CODA -- is a .mat extension already provide
      [fname,p]=uiputfile(fname,'Export to Disk');
      if fname,
         fname = fullfile(p,fname);
         eval([ExportUd.ListData.Name{ExportVal(1)}, ...
               '= ExportUd.ListData.Model{ExportVal(1)};'])
         save(fname,ExportUd.ListData.Name{ExportVal(1)});
         for ct = 2:length(ExportVal),
            eval([ExportUd.ListData.Name{ExportVal(ct)}, ...
                  '= ExportUd.ListData.Model{ExportVal(ct)};'])
            save(fname,ExportUd.ListData.Name{ExportVal(ct)},'-append');
         end
      end
      uiresume(ExportFig)
      
   else
      warndlg('You must select some variables in the list box','Export Warning');
   end % if/else ~isempty(ExportVal)
   
case 'workspace',
   %---Callback from the Export to Workspace button
   ExportVal = get(ExportUd.Handles.ModelList,'Value');
   if isempty(get(ExportUd.Handles.ModelList,'String')),
      warndlg('There are no systems to export.','Export Warning');
      return      
   end
   
   if ~isempty(ExportVal),
      w = evalin('base','whos');
      Wname = {w.name};
      overwrite=0;
      for CheckName = 1:length(ExportVal),
         if ~isempty(strmatch(ExportUd.ListData.Name{ExportVal(CheckName)},...
               Wname,'exact')),
            overwrite=1;
            break
         end % if ~isempty...
      end % for CheckName
      
      if overwrite
         switch questdlg(...
               {'At least one of the items you are exporting to'
               'the workspace already exists.'
               ' ';
               'Exporting will overwrite the existing variables.'
               ' '
               'Do you want to continue?'},...
               'Variable Name Conflict','Yes','No','No');
            
         case 'Yes'
            overwriteOK = 1;
         case 'No'
            overwriteOK = 0;
         end % switch questdlg
      else
         overwriteOK = 1;
      end % if/else overwrite
      
      if overwriteOK 
         for k = 1:length(ExportVal)
            assignin('base',...
               ExportUd.ListData.Name{ExportVal(k)},...
               ExportUd.ListData.Model{ExportVal(k)});
         end % for k
      uiresume(ExportFig)   
      end
   else
      warndlg('You must select some variables in the list box','Export Warning');
      
   end % if ~isempty(ExportVal)
   
case 'makelist',
    %---Callback to make the list in the ModelList listbox based on DisplayType
    
    % Undesignated models
    Names = {ExportUd.All.Name}';
    Models = {ExportUd.All.Model}';
    Components = {};
    
    if ~isempty(ExportUd.DesignModels), % Design Model
        Components = {'G :';'H :';'F :'};
        Names = [Names;{ExportUd.DesignModels.Name}'];
        Models = [Models;{ExportUd.DesignModels.Model}'];
    end
    
    if ~isempty(ExportUd.Compensators), % Compensators
        Components = [Components ; {'C :'}];
        Names = [Names;{ExportUd.Compensators.Name}];
        Models = [Models;{ExportUd.Compensators.Model}];
    end

    if ~isempty(ExportUd.OpenLoop), % Open-loop models
        Components = [Components ; {'OL:  '}];
        Names = [Names;{ExportUd.OpenLoop.Name}];
        Models = [Models;{ExportUd.OpenLoop.Model}];
    end
    
    if ~isempty(ExportUd.ClosedLoop), % Closed-loop models
        Components = [Components ; {'CL:'}];
        Names = [Names;{ExportUd.ClosedLoop.Name}];
        Models = [Models;{ExportUd.ClosedLoop.Model}];
    end
    
    if isempty(Components)
        ListBoxText = Names;
    else
        ListBoxText = [strvcat(Components),strvcat(Names)];
    end
    set(ExportUd.Handles.ModelList,'String',ListBoxText);
    
    ExportUd.ListData.Name = Names;   
    ExportUd.ListData.Model = Models;   
    set(ExportFig,'UserData',ExportUd)
    
case 'cancel',
   %---Cancel button callback
   uiresume(ExportFig)
   
otherwise
   error('Invalid Export action')
end

%--------------------------Internal Functions------------------------
%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenFig %%%
%%%%%%%%%%%%%%%%%%%%
function a = LocalOpenFig(ParentFig,ExportData,Title)

PointsToPixels = 72/get(0,'ScreenPixelsPerInch');
StdUnit = 'points';
UIColor = get(0,'DefaultUIControlBackground');

ud = ExportData;
ud.ListData = struct('Name','','Model',[]);

%---Open an Export figure
a = figure('Color',UIColor,...
   'Name',xlate(Title), ...
   'MenuBar','none',...
   'Visible','off',...
   'IntegerHandle','off',...
   'NumberTitle','off',...
   'Resize', 'off',...
   'WindowStyle','modal',...
   'Position',[0 0 340 262],...
   'Tag','ExportLTIFig');

%---Position figure within ParentFig bounds
centerfig(a,ParentFig);

%---Add the Export List controls
b = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[4 6 179 244], ...
	'Style','frame');
b = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[51 236 90 19], ...
	'String','Export List', ...
	'Style','text');
ud.Handles.ModelList = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',[1 1 1], ...
	'Position',PointsToPixels*[11 15 166 222], ...
	'Style','listbox', ...
	'Max',2,...
	'FontName','courier',...
	'Tag','ModelList', ...
	'Value',1);

%---Add the window buttons
b = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[189 7 147 243], ...
	'Style','frame');
ud.Handles.DiskButton = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[198 193 125 20], ...
	'Callback','exportlti(''disk'',gcbf);',...
	'String','Export to Disk', ...
	'Tag','DiskButton');
ud.Handles.WorkspaceButton = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[198 220 125 20], ...
	'Callback','exportlti(''workspace'',gcbf);',...
	'String','Export to Workspace', ...
	'Tag','WorkspaceButton');
b = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[195 183 136 1], ...
	'Style','frame');
ud.Handles.HelpButton= uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[198 130 125 20], ...
	'Callback','ctrlguihelp(''viewer_export'');',...
	'String','Help', ...
	'Tag','HelpButton');
ud.Handles.CancelButton = uicontrol('Parent',a, ...
	'Units',StdUnit, ...
	'BackgroundColor',UIColor, ...
	'Position',PointsToPixels*[198 156 125 20], ...
	'Callback','exportlti(''cancel'',gcbf);',...
	'String','Cancel', ...
	'Tag','CancelButton');

set(a,'UserData',ud,'visible','on')
exportlti('makelist',a,ud);
