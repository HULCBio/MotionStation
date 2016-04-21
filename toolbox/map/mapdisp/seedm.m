function seedm(varargin)

%SEEDM  Interactive tool encoding regular surface maps
%
%  SEEDM(map,maplegend) creates an interactive tool for encoding
%  regular matrix maps.  Seeds can be interactively specified and the
%  encoded map generated.  The encoded map can then be saved back
%  to the workspace.
%
%  See Also  MAPTRIM, COLORM, GETSEEDS, ENCODEM

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin < 1
    error('Incorrect number of arguments')
elseif nargin == 1
    action = varargin{1};
elseif nargin == 2
    if isstr(varargin{1})
        action = varargin{1};  varargin(1) = [];
    else
	    action = 'initialize';
		map = varargin{1};    maplegend = varargin{2};
    end
end




switch action
case 'initialize'    %  Initialize the display
      h = seedinit;
      if any(map(:) == 0);   imagem(map+1,maplegend)
	     else;               imagem(map,maplegend)
	  end
      panzoom('on')

%  Set data for later retrieval

	 h.map = map;
	 h.maplegend = maplegend;
	 h.seeds = [];

	 set(h.figure,'Visible','on','UserData',h)


case 'get'         %  Get seeds for map

%  Retrieve appropriate data

     h  = get(get(0,'CurrentFigure'),'UserData');

     nseeds    = str2num(get(h.seednum,'String'));
     seedval   = str2num(get(h.seedval,'String'));

%  Turn panzoom off

     panzoom('off')

	 if ~isempty(nseeds) & ~isempty(seedval)
		   seedmat = getseeds(h.map,h.maplegend,nseeds,seedval);
		   h.seeds   = [h.seeds; seedmat];
	 else
	       error('Blank number of seeds or value.')
	 end

     seedm('zoomon')   %  Turn panzoom back on

     set(h.figure,'UserData',h);


case 'seed'       %  Seed the map

     h  = get(get(0,'CurrentFigure'),'UserData');
     h.map = encodem(h.map,h.seeds);
	 set(h.figure,'UserData',h)
     panzoom('off')
     if any(h.map(:) == 0);   imagem(h.map+1,h.maplegend)
	     else;                imagem(h.map,h.maplegend)
	 end
     seedm('zoomon')   %  Turn panzoom back on


case 'change'    %  Change map codes

     h  = get(get(0,'CurrentFigure'),'UserData');

     oldcode = str2num(get(h.from,'String'));
	 if isempty(oldcode)
	     oldcode = 0;
	 end

     newcode = str2num(get(h.to,'String'));
	 if isempty(newcode)
	     newcode = 0;
	 end
	 h.map = changem(h.map,newcode,oldcode);

	 set(h.figure,'UserData',h)
     panzoom('off')
     if any(h.map(:) == 0);   imagem(h.map+1,h.maplegend)
	     else;                imagem(h.map,h.maplegend)
	 end
     seedm('zoomon')   %  Turn panzoom back on


case 'clear'     %  Clear the map seeds

     h  = get(get(0,'CurrentFigure'),'UserData');
     h.seeds = [];
	 set(h.figure,'UserData',h)

case 'save'

     h  = get(get(0,'CurrentFigure'),'UserData');

%  Get the variable name inputs

      prompt={'Map Variable:'};
      answer={'map'};
      lineNo=1;
      title='Enter the Surface Map variable name';


	  while ~isempty(answer)   %  Prompt until correct, or cancel
	      answer=inputdlg(prompt,title,lineNo,answer);

          breakflag = 1;
		  if ~isempty(answer)   % OK button pushed
              if isempty(answer{1})
		           breakflag = 0;
				   uiwait(errordlg('Variable name must be supplied',...
			                       'Seed Map Error','modal'))
			  else
                   mapmatch = strmatch(answer{1},varargin{1});
                   if ~isempty(mapmatch)
                        Btn=questdlg('Replace existing variable?', ...
 	                                 'Save Map Data', 'Yes','No','No');
                        if strcmp(Btn,'No');   breakflag = 0;  end
				  end
		      end
		  end

		  if breakflag;  break;   end
      end

      if isempty(answer);   return;   end   %  Cancel pushed

      assignin('base',answer{1},h.map)

case 'zoomoff'     %  Turn panzoom off
      hmenu = findobj(get(0,'CurrentFigure'),'type','uimenu','label','Off');

	  panzoom('off')
	  set(hmenu,'Label','On','Callback','seedm(''zoomon'')')

case 'zoomon'      %  Turn panzoom on
      hmenu = findobj(get(0,'CurrentFigure'),'type','uimenu','label','On');

	  panzoom('on')
	  set(hmenu,'Label','Off','Callback','seedm(''zoomoff'')')

case 'close'         %  Close figure
     ButtonName = questdlg('Are You Sure?','Confirm Closing','Yes','No','No');
     if strcmp(ButtonName,'Yes');   delete(get(0,'CurrentFigure'));   end
end


%**************************************************************************
%**************************************************************************
%**************************************************************************


function h = seedinit

%  SEEDINIT creates the interface window for SEEDM.

%  Written by:  E. Byrns, E. Brown


%  Control panel window
%  Creating invisible figure flickers patches while window draws.

h.figure = figure('Visible','off', 'Name', 'Seed Map',...
            'CloseRequestFcn','seedm(''close'')');

colordef(h.figure,'white')
colormap('prism')
figclr = get(h.figure,'Color');

hmenu = uimenu(h.figure,'Label','Zoom');   %  Add the menu items
uimenu(hmenu,'Label','Off','Callback','seedm(''zoomoff'')')
clrmenu;


set(gca,'Units','Normalized','Position',[0.13 0.20 0.80 0.72])

%  Get button

h.get = uicontrol(h.figure, 'Style', 'push',...
		'Units', 'Normalized','Position', [0.13  0.08  0.10  0.06],...
		'String','Get', 'CallBack', 'seedm(''get'')' ,...
		'BackgroundColor',figclr, 'ForegroundColor','black' );

%  Seed button

h.seed = uicontrol(gcf, 'Style', 'push',...
		'Units', 'Normalized', 'Position', [0.25  0.08  0.10  0.06], ...
		'String','Fill In', 'CallBack', 'seedm(''seed'')' ,...
		'BackgroundColor',figclr, 'ForegroundColor','black' );

%  Clear button

h.clear = uicontrol(gcf, 'Style', 'push',...
	    'Units', 'Normalized', 'Position', [0.13  0.01  0.10  0.06], ...
		'String','Reset', 'CallBack', 'seedm(''clear'')' ,...
		'BackgroundColor',figclr, 'ForegroundColor','black' );

%  Change button

h.change = uicontrol(gcf, 'Style', 'push',...
		'Units', 'Normalized','Position', [0.25  0.01  0.10  0.06], ...
	    'String','Change', 'CallBack', 'seedm(''change'')',...
		'BackgroundColor',figclr, 'ForegroundColor','black' );

%  Save button

h.save  = uicontrol(gcf, 'Style', 'push',...
	    'Units', 'Normalized', 'Position', [0.85  0.01  0.10  0.06], ...
		'String','Save', 'CallBack', 'seedm(''save'',who)',...
		'BackgroundColor',figclr, 'ForegroundColor','black' );

%  Number of seeds edit object

h.seedlabel = uicontrol(gcf, 'Style', 'Text', ...
              'Units', 'Normalized', 'Position', [0.40  0.06  0.11  0.04], ...
			  'String','# of Seeds', 'HorizontalAlignment','left',...
			  'BackgroundColor',figclr, 'ForegroundColor','black' );

h.seednum = uicontrol(gcf, 'Style', 'edit', ...
               'Units', 'Normalized','Position', [0.52  0.06  0.09  0.05],...
			   'Max', 1 ,...
			  'BackgroundColor',figclr, 'ForegroundColor','black' );

%  Seed value edit object

h.vallabel = uicontrol(gcf, 'Style', 'Text', ...
              'Units', 'Normalized','Position', [0.64  0.06  0.07  0.04], ...
			  'String','Value', 'HorizontalAlignment','left',...
			  'BackgroundColor',figclr, 'ForegroundColor','black' );

h.seedval = uicontrol(gcf, 'Style', 'edit', ...
               'Units', 'Normalized','Position', [0.72  0.06  0.09  0.05],...
			   'Max', 1 ,...
			  'BackgroundColor',figclr, 'ForegroundColor','black' );

%  From/To edit object

h.fromlabel = uicontrol(gcf, 'Style', 'Text', ...
              'Units', 'Normalized', 'Position', [0.40  0.01  0.09  0.04], ...
			  'String','From/To', 'HorizontalAlignment','left',...
			  'BackgroundColor',figclr, 'ForegroundColor','black' );

h.from = uicontrol(gcf, 'Style', 'edit', ...
               'Units', 'Normalized', 'Position', [0.52  0.005  0.05  0.05], ...
			   'Max', 1 ,...
			  'BackgroundColor',figclr, 'ForegroundColor','black' );

h.to = uicontrol(gcf, 'Style', 'edit', ...
               'Units', 'Normalized', 'Position', [0.59  0.005  0.05  0.05], ...
			   'Max', 1 ,...
			  'BackgroundColor',figclr, 'ForegroundColor','black' );


%**************************************************************************
%**************************************************************************
%**************************************************************************
