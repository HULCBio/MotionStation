function rgbcodes = colorui(arg1,arg2)
   
%COLORUI  Platform independent setting of a RGB color triple
%
%  C = COLORUI will create an interface for the definition of a
%  RGB color triple.  For Macintosh or MS-Windows versions,
%  COLORUI will produce the same interface as UISETCOLOR.  For
%  other machines, COLORUI produces a platform independent
%  dialog for specifying the color values.
%
%  C = COLORUI(InitClr) will initialize the color value to the
%  RGB triple given in INITCLR.
%
%  C = COLORUI(InitClr,FigTitle) will use the string in FigTitle as
%  the window label.
%
%  The output value C is the selected RGB triple if the Accept or OK
%  button is pushed.  If the user presses Cancel, then the output value
%  is set to 0.
%
%  See also UISETCOLOR

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $  $Date: 2003/08/01 18:18:02 $
%  Written by:  E. Byrns, E. Brown


% Parse the input arguments

if nargin == 0
      initclr = [];   figtitle = [];   action = [];
	  
elseif nargin == 1
      if ~isstr(arg1)
	        initclr = arg1;   figtitle = [];    action = [];
      else   %  Internal callback
            initclr = [];     figtitle = [];    action = arg1;
	  end

elseif nargin == 2
      initclr = arg1;       figtitle = arg2;    action = [];
end


%  Empty argument tests

if isempty(initclr);    initclr  = [0.5 0.5 0.5];   end
if isempty(figtitle);   figtitle = 'Custom Color';  end
if isempty(action);     action   = 'initialize';    end



switch lower(action)
    case 'initialize'   %  Call uisetcolor if possible (nothing else then used)
          if strcmp(computer,'MAC2') | strcmp(computer,'PCWIN') 
		        rgbcodes = uisetcolor(initclr,figtitle);
              if all(rgbcodes == initclr);  rgbcodes = 0;  end
          else   %  Otherwise call internal GUI to set color
		        rgbcodes = rgbinit(initclr,figtitle);
          end

    case 'mode'    %  Switch the mode button (rgb or hsv)
          fig   = get(gco,'Parent');
		    tag   = lower(get(gco,'Tag'));
          other = get(gco,'UserData');	  
		    hndl  = get(fig,'UserData');

		  set(gco,'Value',1);
		  set(other,'Value',0);

          v1 = get(hndl.redslider,'Value');
		  v2 = get(hndl.greenslider,'Value');
		  v3 = get(hndl.blueslider,'Value');

          switch tag     %  Compute the rgb or hsv codes
		      case 'rgb'
			       [out1,out2,out3] = hsv2rgb(v1,v2,v3);

		           set(hndl.redtext,'String','Red')
		           set(hndl.greentext,'String','Green')
		           set(hndl.bluetext,'String','Blue')

		      case 'hsv'
 			       [out1,out2,out3] = rgb2hsv(v1,v2,v3);

		           set(hndl.redtext,'String','Hue')
		           set(hndl.greentext,'String','Saturation')
		           set(hndl.bluetext,'String','Value')
          end

		  set(hndl.redslider,'Value',out1)     %  Update display
		  set(hndl.redvalue,'String',num2str(out1,4))

		  set(hndl.greenslider,'Value',out2)
		  set(hndl.greenvalue,'String',num2str(out2,4))

		  set(hndl.blueslider,'Value',out3)
		  set(hndl.bluevalue,'String',num2str(out3,4))
		  
		  refresh(fig)

    case 'slider'    %  Move a color slider
		  edit = get(gco,'UserData');
		  val  = get(gco,'Value');
 		  set(edit,'String',num2str(val,4));
          colorui('patch')

   case 'edit'      %  Edit a color value
		  slider = get(gco,'UserData');
          maxval = get(slider,'Max');
		  minval = get(slider,'Min');
		  
		  val = str2num(get(gco,'String'));
		  if isempty(val)
		       val = minval;
		  else
		       val = min(max(minval,val), maxval);
		  end
		  
		  set(gco,'String',num2str(val,4));
		  set(slider,'Value',val)

          colorui('patch')

     case 'patch'   %  Update the patch with the new color
          fig    = get(gco,'Parent');
		  hndl   = get(fig,'UserData');
		  hsvval = get(hndl.hsv,'Value');

          v1 = get(hndl.redslider,'Value');
		  v2 = get(hndl.greenslider,'Value');
		  v3 = get(hndl.blueslider,'Value');

          if hsvval;     [v1,v2,v3] = hsv2rgb(v1,v2,v3);   end
		  
		  set(hndl.patch,'FaceColor',[v1 v2 v3]);

end


%***********************************************************************
%***********************************************************************
%***********************************************************************


function rgbcodes = rgbinit(initclr,figtitle)

%RGBINIT  Display the GUI for editing a color value (platform independent)

if nargin == 0
      initclr = [];   figtitle = [];
elseif nargin == 1
      if isstr(initclr)
	       figtitle = initclr;   initclr = [];
	  else
	       figtitle = [];
	  end
end

%  Empty argument tests

if isempty(initclr);    initclr = [0.5 0.5 0.5];    end
if isempty(figtitle);   figtitle = 'Custom Color';  end

%  Test for valid RGB entry

if  isstr(initclr) | ...
    length(initclr) ~= 3 | ndims(initclr) > 2 |  ...
	 any(initclr > 1) | any(initclr < 0)
		  initclr = [0.5 0.5 0.5];
end
red = initclr(1);   green = initclr(2);   blue = initclr(3);

%  Compute the Pixel and Font Scaling Factors so 
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = (72/get(0,'ScreenPixelsPerInch'))^.6;
FontScaling = get(0,'FactoryUicontrolFontSize')/10;

%  Create the dialog box

h.dlg = dialog('Name',figtitle,...
               'Units','Points',  'Position',PixelFactor*72*[2 2 5 3],...
			   'Visible','off');
colordef(h.dlg,'white');
figclr = get(h.dlg,'Color');
				  
%  Mode label and frame object

uicontrol(h.dlg,'Style','Frame',...              %  Mode frame object
                'Units', 'Normalized', ...
 				'Position', [0.01  0.72  0.25  0.22], ...
				'ForegroundColor', 'black',...
				'BackgroundColor', figclr);

uicontrol(h.dlg,'Style','Text', ...             %  Mode label object
                'Units', 'Normalized', ...
                'String', 'Mode', ...
			    'Position', [0.03  0.92  0.10  0.06], ...
			    'FontWeight','bold',  'FontSize',FontScaling*12, ...
				'HorizontalAlignment', 'center', ...
				'ForegroundColor', 'red',...
				'BackgroundColor', figclr);

h.rgb = uicontrol(h.dlg,'Style','Radio', ...             %  RGB Radio Button
                        'Units', 'Normalized', ...
                        'String', 'RGB', ...
						'Value', 1, ...
			            'Position', [0.06  0.83  0.15  0.06], ...
			            'FontWeight','bold',  'FontSize',FontScaling*10, ...
						'Tag', 'rgb', ...
				        'HorizontalAlignment', 'left', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr,...
						'CallBack','colorui(''mode'');');

h.hsv = uicontrol(h.dlg,'Style','Radio', ...             %  HSV Radio Button
                        'Units', 'Normalized', ...
                        'String', 'HSV', ...
						'Value', 0, ...
			            'Position', [0.06  0.74  0.15  0.06], ...
			            'FontWeight','bold',  'FontSize',FontScaling*10, ...
						'Tag', 'hsv', ...
				        'HorizontalAlignment', 'left', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr,...
						'CallBack','colorui(''mode'');');


%  Set handles to link radio buttons on callback

set(h.rgb,'UserData',h.hsv);
set(h.hsv,'UserData',h.rgb);
	  
%  Slider Control Frame

uicontrol(h.dlg,'Style','Frame',...              %  Color sliders frame object
                'Units', 'Normalized', ...
 				'Position', [0.01  0.25  0.98  0.40], ...
				'ForegroundColor', 'black',...
				'BackgroundColor', figclr);

uicontrol(h.dlg,'Style','Text', ...             %  Values label object
                'Units', 'Normalized', ...
                'String', 'Values', ...
			    'Position', [0.03  0.63  0.15  0.06], ...
			    'FontWeight','bold',  'FontSize',FontScaling*12, ...
				'HorizontalAlignment', 'center', ...
				'ForegroundColor', 'red',...
				'BackgroundColor', figclr);


%  Red color slider, text and edit controls

h.redtext = uicontrol(h.dlg,'Style','Text', ...             %  Red Text Label
                        'Units', 'Normalized', ...
                        'String', 'Red', ...
			            'Position', [0.03  0.52  0.24  0.06], ...
			            'FontWeight','bold',  'FontSize',FontScaling*12, ...
				        'HorizontalAlignment', 'right', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr);

h.redslider = uicontrol(h.dlg,'Style','Slider', ...           %  Red Slider
                          'Units', 'Normalized', ...
			              'Position', [0.28  0.51  0.50  0.06], ...
						  'Min', 0, 'Max', 1, ...
					      'Value', red, ...
				          'HorizontalAlignment', 'left', ...
				          'ForegroundColor', 'black',...
				          'BackgroundColor', figclr,...
						  'CallBack','colorui(''slider'');');

h.redvalue = uicontrol(h.dlg,'Style','Edit', ...             %  Red Value Edit
                        'Units', 'Normalized', ...
                        'String', num2str(red,4), ...
			            'Position', [0.81  0.51  0.15  0.10], ...
			            'FontWeight','bold',  'FontSize',FontScaling*12, ...
						'HorizontalAlignment', 'left', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr,...
						'CallBack','colorui(''edit'');');

%  Set handles to link slider and edit box on callback

set(h.redslider,'UserData',h.redvalue);
set(h.redvalue,'UserData',h.redslider);
	  
%  Green color slider, text and edit controls

h.greentext = uicontrol(h.dlg,'Style','Text', ...             %  Green Text Label
                        'Units', 'Normalized', ...
                        'String', 'Green', ...
			            'Position', [0.03  0.41  0.24  0.06], ...
			            'FontWeight','bold',  'FontSize',FontScaling*12, ...
				        'HorizontalAlignment', 'right', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr);

h.greenslider = uicontrol(h.dlg,'Style','Slider', ...           %  Green Slider
                          'Units', 'Normalized', ...
			              'Position', [0.28  0.40  0.50  0.06], ...
						  'Min', 0, 'Max', 1, ...
					      'Value', green, ...
				          'HorizontalAlignment', 'left', ...
				          'ForegroundColor', 'black',...
				          'BackgroundColor', figclr,...
						  'CallBack','colorui(''slider'');');

h.greenvalue = uicontrol(h.dlg,'Style','Edit', ...             %  Green Value Edit
                        'Units', 'Normalized', ...
                        'String', num2str(green,4), ...
			            'Position', [0.81  0.40  0.15  0.10], ...
			            'FontWeight','bold',  'FontSize',FontScaling*12, ...
				        'HorizontalAlignment', 'left', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr,...
						'CallBack','colorui(''edit'');');

%  Set handles to link slider and edit box on callback

set(h.greenslider,'UserData',h.greenvalue);
set(h.greenvalue,'UserData',h.greenslider);
	  						
%  Blue color slider, text and edit controls

h.bluetext = uicontrol(h.dlg,'Style','Text', ...             %  Blue Text Label
                        'Units', 'Normalized', ...
                        'String', 'Blue', ...
			            'Position', [0.03  0.30  0.24  0.06], ...
			            'FontWeight','bold',  'FontSize',FontScaling*12, ...
				        'HorizontalAlignment', 'right', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr);

h.blueslider = uicontrol(h.dlg,'Style','Slider', ...           %  Blue Slider
                          'Units', 'Normalized', ...
			              'Position', [0.28  0.29  0.50  0.06], ...
						  'Min', 0, 'Max', 1, ...
					      'Value', blue, ...
				          'HorizontalAlignment', 'left', ...
				          'ForegroundColor', 'black',...
				          'BackgroundColor', figclr,...
						  'CallBack','colorui(''slider'');');

h.bluevalue = uicontrol(h.dlg,'Style','Edit', ...             %  Blue Value Edit
                        'Units', 'Normalized', ...
                        'String', num2str(blue,4), ...
			            'Position', [0.81  0.29  0.15  0.10], ...
			            'FontWeight','bold',  'FontSize',FontScaling*12, ...
				        'HorizontalAlignment', 'left', ...
				        'ForegroundColor', 'black',...
				        'BackgroundColor', figclr,...
						'CallBack','colorui(''edit'');');
	  				  
%  Set handles to link slider and edit box on callback

set(h.blueslider,'UserData',h.bluevalue);
set(h.bluevalue,'UserData',h.blueslider);
	  						
	  				  

uicontrol(h.dlg,'Style','Push', ...    %  Apply Button
	                   'Units', 'Normalized', ...
                       'String', 'Accept', ...
					   'Position', [0.25  0.05  0.20  0.10], ...
					            'FontWeight','bold',  'FontSize',FontScaling*12, ...
					            'HorizontalAlignment', 'center', ...
					            'ForegroundColor', 'black',...
					            'BackgroundColor', figclr,...
								'CallBack','uiresume');

								
uicontrol(h.dlg,'Style','Push', ...    %  Cancel Button
	                   'Units', 'Normalized', ...
                       'String', 'Cancel', ...
					   'Position', [0.55  0.05  0.20  0.10], ...
					            'FontWeight','bold',  'FontSize',FontScaling*12, ...
					            'HorizontalAlignment', 'center', ...
					            'ForegroundColor', 'black',...
					            'BackgroundColor', figclr,...
								'CallBack','uiresume');



h.axis = axes('Parent',h.dlg,...                   %  Color patches axes
              'Units','Normalized',...
			  'Position', [0.40  0.72  0.50  0.17],...
              'Xlim', [0 1],   'Xtick',[], ...
			  'Ylim', [-1 1],  'Ytick', [], ...
	          'Box', 'on', 'Grid', 'none', ...
			  'NextPlot','add' );


xdata = [ 0;  1;  1;  0];       %  Patch Data
ydata = [-1; -1;  1;  1];
cdata = ones(size(xdata));

patch(0.5*xdata,ydata,cdata,...                        %  Original color patch
               'Parent',h.axis,'EraseMode','xor',...
	           'FaceColor',[red green blue], 'EdgeColor','none');
			   
h.patch = patch(0.5*xdata+0.5,ydata,cdata,...          %  New color patch
               'Parent',h.axis,'EraseMode','xor',...
	           'FaceColor',[red green blue], 'EdgeColor','none');

uicontrol(h.dlg,'Style','Text', ...             %  Original Color object
                'Units', 'Normalized', ...
                'String', 'Original', ...
			    'Position', [0.40  0.91  0.25  0.07], ...
			    'FontWeight','bold',  'FontSize',FontScaling*12, ...
				'HorizontalAlignment', 'center', ...
				'ForegroundColor', 'red',...
				'BackgroundColor', figclr);

uicontrol(h.dlg,'Style','Text', ...             %  New Color object
                'Units', 'Normalized', ...
                'String', 'New', ...
			    'Position', [0.65  0.91  0.25  0.07], ...
			    'FontWeight','bold',  'FontSize',FontScaling*12, ...
				'HorizontalAlignment', 'center', ...
				'ForegroundColor', 'red',...
				'BackgroundColor', figclr);


set(h.dlg,'Visible','on','UserData',h)

uiwait(h.dlg)

object = get(h.dlg,'CurrentObject');

buttonname = lower(get(object,'String'));
if strcmp(buttonname,'Accept')
      rgbcodes(1) = get(h.redslider,'Value');
      rgbcodes(2) = get(h.greenslider,'Value');
      rgbcodes(3) = get(h.blueslider,'Value');

      if get(h.hsv,'Value');   rgbcodes = hsv2rgb(rgbcodes);  end
else
      rgbcodes = 0;
end


delete(h.dlg)



						

