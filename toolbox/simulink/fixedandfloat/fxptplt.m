function fxptplt(action, PlotType)
%FXPTPLT Graphical interface for plotting blocks in a Fixed-Point system.
%
%   FXPTPLT is intended to be used by FXPTDLG only.  The plotting interface
%   lists all ToWorkspace, Outport and Scope blocks.  These blocks can be
%   selected and plotted by using the Plot Signals or Plot Doubles pushbuttons:
%
%      Plot Signals - Plots the current data against time for the selected
%                     blocks.
%      Plot Doubles - Plots the data obtained with all data types set to doubles
%                     against time.
%
%   See also FXPTDLG.

% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.19.2.3 $  
% $Date: 2004/04/15 00:34:53 $

%
% if there are no input arguments, then that indicates that 
% the plot button on the main fixed point GUI has called this function.
%
% For this situation, the main task is to create the plot dialog if
% it does not already exist.
%
if nargin==0,
   %
   % get data from main window.
   %
   toolbarHandle = get( gcbo, 'parent');

   hFixGui = get(toolbarHandle, 'parent');
   
   fixGuiData = get( hFixGui, 'userdata');

   %
   % determine the status of the dialog
   %  1)  does it exist
   %  2)  what's its handle
   %
   figStatus = getFigureStatus(fixGuiData.system);

   if ~figStatus.DialogExists, 
       %
       % the dialog does not already exist so create it
       %   
       hPlotDialog = makegui(fixGuiData.system);       
   else   
       hPlotDialog = figStatus.DialogHandle;
   end
   
   %
   % try to find all the names of all blocks/signals available for plotting
   %
   set(hPlotDialog,'visible','off')
   
   try
       %
       % get the list of plotable blocks.
       %
       %fixGuiData = get( hFixGui,'userdata');

       displist = { fixGuiData.plotableSigInfo(1:end).name };
   
       displist = strrep( displist, sprintf('\n'),' ');
   catch
       displist = '';
   end    
   
    if isempty(displist),

      delete(hPlotDialog)

      msg = ['The list of signals for plotting is empty.\n\n',...
             '1) For Scope data to be on the list, it must be saved as ',...
             'Array or StructureWithTime.\n\n',...
             '2) For Output data to be on the list, both time and output ',...
             'must be saved.\n\n',...
             '3) For ToWorkspace data to be on the list, it must be saved ',...
             'as StructureWithTime.\n\n',...
             'For changes to take effect, the fixed point GUI must be ',...
             'closed and then reopened.'];

      uiwait(msgbox( sprintf(msg),'help','modal'))
      
      return
    end
    %
    % Have the display window list the blocks/signals found.
    %
    plotGuiData = get(hPlotDialog,'userdata');
    
    set( plotGuiData.hListBox, 'string', displist )
    
    set( hPlotDialog, 'visible', 'on')      
   
   return
   
else
   if ~any(strcmpi(action,{'plot'})),
      error('Argument passed not recognized. See FXPTDLG.')
      return
   end
   %
   % plot GUI userdata
   %
   hPlotDialog = get( gcbo, 'parent');

   plotGuiData = get( hPlotDialog, 'userdata' );
   %
   % get main fixed point GUI userdata.
   %
   %hFixGui = findobj(allchild(0),'name',['Fixed-Point Blockset Interface - ' plotGuiData.system]);
   
   hFixGui = findobj(allchild(0),'Tag','fxptdlgbx');
   
   fixGuiData = get( hFixGui, 'userdata');
   %
   % Find out which blocks are selected.
   %
   win = findobj(hPlotDialog,'tag','blocknames');
   blks = get(win,{'string','value'});
   %
   %
   % Obtain the data we will plot for each selected block.
   %
   switch PlotType
   case 'signals',
      if isDataEmpty(fixGuiData.RawData)
       reportError(PlotType)
       return
      end
      data  = plotdata( fixGuiData.RawData, blks, '-');
    case 'doubles',      
     
      if isDataEmpty(fixGuiData.DblData)
        
       reportError(PlotType)
       return
      end

      data  = plotdata( fixGuiData.DblData, blks, ':');
    case 'both',
     
      if isDataEmpty(fixGuiData.RawData)
        
        if isDataEmpty(fixGuiData.DblData)
          
          reportError(PlotType,'both')
          return
        else

          reportError(PlotType,'signals')
          return
        end
        
      elseif isDataEmpty(fixGuiData.DblData)
        
       reportError(PlotType,'doubles')
       return
      end

      data1 = plotdata( fixGuiData.RawData, blks, '-');
      data2 = plotdata( fixGuiData.DblData, blks, ':');
   end
   %
   % prepare plotting figures.
   %
   figStatus = getFigureStatus(plotGuiData.system);
   
   if ~figStatus.PlotExists,
      % No plotting figure is open yet.
      pltfig=plotfigure(plotGuiData.system);
   else
      % A plotting figure is already open.
      pltfig = figStatus.PlotHandle;
      figure(pltfig)
      zoom out
      cla      
   end
   %
   % Since we would've errored out by now, we can now plot the data that we've obtained.
   %
   switch PlotType
   
   case 'signals',
      if ~isempty(data),
         plot(data{:})
      end
   case 'doubles',      
      if ~isempty(data),
         plot(data{:})
      end
   case 'both',
      if ~isempty(data1),
         plot(data1{:})
         hold on
      end
      if ~isempty(data2),
         plot(data2{:})
      end
   end
   
   axis auto
   zoom on

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hPlotDialog = makegui(system)
%
% Create the plotting dialog figure.
%
width=525;
height=275;

RootUnits=get(0,'units');
set(0,'units','pixels')
scrnsize=get(0,'screensize');
set(0,'units',RootUnits)
figpos=[((scrnsize(3)-width)/2) ((scrnsize(4)-height)/2) width height];

hPlotDialog=figure('integerhandle','off','menubar','none','units','pixels','name',['Plot system: ' system],...
   'numbertitle','off','parent',0,'position',figpos,'tag','fxptplt');
hpltpb = uicontrol('Units','pixels','String','Plot Signals','Tag','plotpb',...
   'Position',[20 10 125 20],'callback','fxptplt(''plot'',''signals'');');
hdblspb = uicontrol('Units','pixels','String','Plot Doubles','callback','fxptplt(''plot'',''doubles'');',...
   'Position',[152 10 125 20]);
hbothpb = uicontrol('Units','pixels','String','Plot Both','Tag','doublespb',...
   'Tag','bothpb','Position',[283 10 125 20],'callback','fxptplt(''plot'',''both'');');
hcnclpb = uicontrol('Units','pixels','String','Cancel','Tag','cancelpb',...
   'Position',[width-110 10 90 20],'callback','closereq');   
hwin = uicontrol('Units','normalized','listboxtop',1,'Style','listbox','max',3,'min',1,...
   'Tag','blocknames','Position',[0.02 0.15 0.96 0.80]);

% SET PARENT, BACKGROUND COLORS AND FONTS.
fwFont = get(0,'FixedWidthFontName');

set(allchild(hPlotDialog),'Parent',hPlotDialog,'BackgroundColor',[0.8 0.8 0.8])
set(hwin,'fontname',fwFont)
set(hwin,'BackgroundColor',[1 1 1])
%
% define UserData
%
plotGuiData.hListBox = hwin;
plotGuiData.system   = system;

% Store the system name and the handle to the display window so we
% can have access to the list of blocks.
set(hPlotDialog,'userdata',plotGuiData,'handlevisibility','off','resize','off')
%
% END   makegui
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figStatus = getFigureStatus(system)
%
% CHECK FOR EXISTING PLOT WINDOWS
%
% figStatus.DialogExists => True if main plot dialog window is open.
% figStatus.DialogHandle
% figStatus.PlotExists   => True if the figure used for plotting is open.
% figStatus.PlotHandle   => Contains the handle to the plotting figure 
%                           if figStatus.PlotExists is true.

ch = allchild(0);

hPlotDialog = findobj(ch,'name',['Plot system: ' system]);
hPlotFigure = findobj(ch,'name',['Plotting ' system, ' outputs.']);

if ~isempty(hPlotDialog),
   figure(hPlotDialog)
   figStatus.DialogExists = 1;
   figStatus.DialogHandle = hPlotDialog;
else
   figStatus.DialogExists = 0;
   figStatus.DialogHandle = [];
end

if ~isempty(hPlotFigure),
   figStatus.PlotExists = 1;
   figStatus.PlotHandle = hPlotFigure;
else
   figStatus.PlotExists =  0;
   figStatus.PlotHandle = [];
end
%
% END getFigureStatus  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plth=plotfigure(system)
%
% Create a plotting figure if one does not exist yet.

plth=figure('integerhandle','off','menubar','none','numbertitle','off',...
   'name',sprintf('Plotting %s outputs.',system),'parent',0,'tag','blkplts');
ax=axes('drawmode','fast');
%
% END   plotfigure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = plotdata(data2plot,blks,linestyle)
%
% FOR SELECTED BLOCKS
%    ORGANIZED DATA TO BE PLOTTED
%
data={};

sigName  = blks{1};
sigIndex = blks{2};

warnList = '';

for i = 1:length(sigIndex),

    doWarn = 1;

    try
        k = sigIndex(i);
        
        for j = 1:length(data2plot(k).signals)
        
            t = data2plot(k).time;

            y = data2plot(k).signals(j).values;
    
            try    
                discrete = data2plot(k).signals(j).plotStyle;
            catch
                discrete = 0;
            end
            
            if all(discrete),
                % 
                % If all signals are discretized, then we will convert the data to
                % stairs format.
                [t,y] = stairs(t,y);
            end
        
            if isempty(t) || isempty(y)
            
                doWarn = 1;
            else
                data={ data{:} t y linestyle };
            
                doWarn = 0;
            end
        end
    catch    
    end

    if doWarn
        
        warnList = sprintf( '%s\n     %s',warnList, sigName{sigIndex(i)} );

    end
end

wstate = warning('query', 'all');
if ~strcmpi(wstate(1).state, 'off') && ~isempty( warnList )

    if strcmp(linestyle,':')

      pType = 'doubles';
    else
      pType = 'signals';
    end
    
    reportError('list',pType,warnList)
end
%
% END   plotdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataIsEmpty = isDataEmpty(data)
  
dataIsEmpty = 1;

if ~isempty(data)

  for i=1:length(data)
    
    curData = data(1);
    
    if isfield(curData,'signals')
      if ~isempty(curData.signals)
        dataIsEmpty = 0;
        return
      end
    end
  end
end
%
% END   isDataEmpty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reportError(PlotType,MissingCase,sigList)
  
   strGetDoubles = ['To obtain Doubles data:\n', ...
                    '1) Open the Fixed Point Settings Dialog\n', ...
                    '2) Set ''Select current system:'' to the root level model\n', ...
                    '3) Set ''Data type override:'' to ''Scaled Doubles'' or ''True Doubles''\n', ...
                    '4) Run the simulation'];
      
   strGetSignals = ['To obtain Signals data:\n', ...
                    '1) Open the Fixed Point Settings Dialog\n', ...
                    '2) Set ''Select current system:'' to the root level model\n', ...
                    '3) Set ''Data type override:'' to anything EXCEPT ''Scaled Doubles''\n   or ''True Doubles''\n', ...
                    '4) Run the simulation'];   
  switch PlotType
    
   case 'signals'

    errType = 'Error plotting signals.';
    
    message = sprintf(['Plot Signals can''t be carried out.\n',...
               'Signals data is not available.\n\n%s'],...
               strGetSignals);
    
   case 'doubles'
    
    errType = 'Error plotting doubles.';
    
    message = sprintf(['Plot Doubles can''t be carried out.\n',...
               'Doubles data is not available.\n\n%s'],...
               strGetDoubles);

   case 'both'

    errType = 'Error plotting both signals and doubles.';
    
    switch MissingCase
      
     case 'both'

      message = sprintf(['Plot Both can''t be carried out.\n',...
                 'Neither Signals data nor Doubles data is available.\n\n%s\n\n\%s'], ...
                 strGetSignals,strGetDoubles);

     case 'signals'
      
       message = sprintf(['Plot Both can''t be carried out.\n',...
                  'Doubles data is available, but Signals data is not available.\n\n%s'],...
                  strGetSignals);
    
     case 'doubles'

      message = sprintf(['Plot Both can''t be carried out.\n',...
                 'Signals data is available, but Doubles data is not available.\n\n%s'],...
                 strGetDoubles);

     otherwise
       
      message = 'Unknown error';
      
    end
   
   case 'list'

    errType = 'Error processing plot data';
    
    switch MissingCase
      
     case 'doubles'

      tempStr = ' Doubles ';
     
     otherwise
       
      tempStr = ' Signals ';
     
    end
   
    message = sprintf(['The%s data was not properly available for signal(s):%s', ...
               '\nA possible error is that the model has been changed since\n',...
               'the Fixed-Point Settings Dialog was first openned.  If so,\n', ...
               'close the dialog and then reopen it.  The data may need to be\n',...
               'collected again.\n\n%s'], tempStr, sigList, strGetSignals);
    
   otherwise
       
    message = 'Unknown error';
      
   end

   errordlg(sprintf(message),errType,'modal');
   
%
% END   reportError
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END   fxptplt.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
