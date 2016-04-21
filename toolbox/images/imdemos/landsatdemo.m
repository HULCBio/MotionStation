function out = landsatdemo(varargin)
%LANDSATDEMO Landsat color composite demo.
%
%   This demo allows you to experiment with creating color composites from
%   Landsat Thematic Mapper data. Landsat data consists of 7 spectral bands
%   that each reveal different features of the region that is imaged. The
%   data is read into a 512-by-512-by-7 array. To create a color composite,
%   we form an RGB image by assigning spectral bands to red, green, and blue
%   intensities.
%
%   Try out some common color composites by clicking on the radio
%   buttons. The numbers in square brackets map the spectral bands to red,
%   green, and blue. The array [3 2 1] means band 3 will be shown as red
%   intensities, band 2 will be shown as blue intensities, and band 1 will
%   be shown as green intensities.
%
%   "True Color [3 2 1]" - shows what our eyes would see from an airplane.
%
%   "Near Infrared [4 3 2]" - shows vegetation as red, water as dark.
%
%   "Shortwave Infrared [7 4 3]" - shows changes due to moisture.
%   
%   Click on "Custom Composite", and change the popup menus to create your own
%   combinations of red, green, and blue.
%
%   Click on "Single Band Intensity" to see individual bands as gray
%   intensity images.
%
%   Try turning off "Saturation Stretch" by clicking on the checkbox. For
%   most Landsat data sets, saturation stretching is important. When
%   saturation stretching is turned on, the demo clips 2% of the pixels in
%   each band and does a linear contrast stretch before displaying the
%   image.
%
%   Try turning on "Decorrelation Stretch" by clicking on the checkbox.
%   This visual enhancement increases color separation by eliminating
%   correlation between channels, making subtle spectral differences
%   easier to recognize. If both "Saturation Stretch" and "Decorrelation
%   Stretch" are checked, the decorrelation stretch is followed by a
%   linear saturation stretch.
%
%   While the demo is running, you can bring the image and data into the
%   workspace.
%   IMG = LANDSATDEMO('getimage') brings the image into the workspace.
%   DATA = LANDSATDEMO('getdata') brings all 7 bands into the workspace.
%
%   Note
%   ----
%   Permission to use Landsat TM data sets provided by Space Imaging,
%   LLC, Denver, Colorado.
%
%   Example
%   -------
%       data = landsatdemo('getdata');
%       truecolor = data(:,:,[3 2 1]);
%       stretched = imadjust(truecolor,stretchlim(truecolor),[]); 
%       imshow(truecolor), figure, imshow(stretched)
%
%   See also DECORRSTRETCH, IMADJUST, STRETCHLIM, IPEXLANSTRETCH.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $ $Date: 2003/05/03 17:53:52 $

if (nargin >= 1)
  switch varargin{1}
   case 'new_image'
    new_image
   case 'update_radio'
    update_radio
   case 'update_band'
    update_band
   case 'display_image'
    display_image
   case 'getimage'
    out = get_image;
   case 'getdata'
    out = get_data;
   otherwise
    error('Unrecognized syntax.');
  end
else
  hfig = DemoFigHandle;
  if (isempty(DemoFigHandle))
    hfig = create_gui;
    set(hfig,'Visible','on');
    drawnow
    new_image
  else
    figure(hfig);
  end
end

%-------------------------------------------------------
function out = get_image

  hfig = DemoFigHandle;
  ud = get(hfig,'UserData');
  h = ud.h;
  
  if (~isempty(DemoFigHandle))
    out = get(h.img,'CData');
  else
    error('LANDSATDEMO must be running to get an image.');
  end
  
%-------------------------------------------------------
function out = get_data

  hfig = DemoFigHandle;
  ud = get(hfig,'UserData');
  
  if (~isempty(DemoFigHandle))
    out = ud.lan_data;
  else
    error('LANDSATDEMO must be running to get data.');
  end
  
%-------------------------------------------------------
function new_image
  
  hfig = DemoFigHandle;
  ud = get(hfig,'UserData');
  h = ud.h;
  
  value = get(h.img_popup, 'Value');
  userdata = get(h.img_popup, 'UserData');
  if (userdata ~= value)    % The selected image really did change
    show_busy(hfig);
    
    set(h.img_popup, 'UserData', value);
    
    % Which image has been selected?
    img_choices = get(h.img_popup, 'String');
    img_choice = img_choices{value};
    
    switch img_choice
     case 'Little Colorado River'
      lan_filename = 'littlecoriver.lan';
      
     case 'Mississippi River'
      lan_filename = 'mississippi.lan';
      
     case 'Montana'
      lan_filename = 'montana.lan';
      
     case 'Paris'
      lan_filename = 'paris.lan';
      
     case 'Rio de Janeiro'
      lan_filename = 'rio.lan';        
      
     case 'Tokyo'
      lan_filename = 'tokyo.lan';        
    end
    
    ud.lan_data = lan_read(lan_filename);
    set(hfig,'UserData',ud);  % add data array to figure userdata
    
    new_composite
  end
  
%-------------------------------------------------------
function new_composite
  
  hfig = DemoFigHandle;
  ud = get(hfig,'UserData');
  h = ud.h;
  
  show_busy(hfig)
  
  if (get(h.truecolor_radio,'Value') == 1)
    bands = [3 2 1];
  elseif (get(h.nir_radio,'Value') == 1)
    bands = [4 3 2];
  elseif (get(h.swir_radio,'Value') == 1)
    bands = [7 4 3];
  elseif (get(h.custom_radio,'Value') == 1)
    red = get(h.red_popup,'Value');             % get bands from popups
    green = get(h.green_popup,'Value');
    blue = get(h.blue_popup,'Value');
    bands = [red green blue];
  else
    intensity = get(h.intensity_popup,'Value'); % get band from popup
    bands = intensity;                    
  end
  
  ud.img_data = ud.lan_data(:,:,bands);
  set(hfig,'UserData',ud)                         % add img_data to userdata
  
  display_image
  
%-------------------------------------------------------
function display_image

  hfig = DemoFigHandle;
  ud = get(hfig,'UserData');
  h = ud.h;
  
  show_busy(hfig)
  
  % linear saturation stretch and/or decorrelation stretch
  tol = [.01 .99];
  doLinear = (get(h.stretch,'Value') == 1);
  doDecorr = (get(h.decorr, 'Value') == 1);
  if doDecorr
    if doLinear
      img_data = decorrstretch(ud.img_data,'Tol',tol);  % both
    else
      img_data = decorrstretch(ud.img_data);  % decorrstretch only
    end
  else
    if doLinear 
      % linear stretch only
      img_data = imadjust(ud.img_data,stretchlim(ud.img_data,tol),[]); 
    else
      img_data = ud.img_data;  % don't stretch
    end
  end
  
  set(h.img,'cdata',img_data)
  drawnow
  show_ready(hfig)
  
%-------------------------------------------------------
function update_radio
  
  hfig = gcbf;
  ud = get(hfig,'UserData');
  h = ud.h;
  h_new = gcbo;
  
  % turn enable off when 
  if (h_new ~= h.custom_radio)
    h_custom =   [h.red_popup h.green_popup h.blue_popup];
    set(h_custom,'Enable','off')
  end
  
  if (h_new ~= h.singleband_radio)
    set(h.intensity_popup,'Enable','off')    
  end
  
  h_radios = [h.truecolor_radio h.nir_radio h.swir_radio h.custom_radio ...
              h.singleband_radio];
  
  state = get(h_radios,'Value');      % get state after button pressed
  state_vec = [state{:}];             % convert cell array to vector
  
  set(h_radios,'Value',0)
  set(h_new,'Value',1)
  
  if (length(find(state_vec==1)) > 1) % check if new button was pressed
    new_composite
  end
  
%-------------------------------------------------------
function update_band
  
  hfig = gcbf;
  h_band = gcbo;
  
  % First, determine if the selected band really changed
  value = get(h_band, 'Value');
  userdata = get(h_band, 'UserData');
  if (userdata ~= value)    % The selected band really did change
    set(h_band, 'UserData', value);
    new_composite
  end
  
%-------------------------------------------------------
function [lan_data] = lan_read(lan_filename)
% LAN_READ  Read Landsat data file type .lan
%
  
  fid = fopen(lan_filename,'r');
  
  % find out how big image is based on file size, assume square image, 7 bands
  nbands = 7;
  fseek(fid,0,'eof');
  file_bytes = ftell(fid);
  nlines = floor(sqrt(file_bytes/nbands));
  nsamples = nlines;
  
  % skip header
  nbytes_header = 128;
  fseek(fid,nbytes_header,'bof');
  
  % prepend * to read data into an array that has the same class as the data
  A = fread(fid,[nsamples nlines*nbands],'*uint8'); 
  
  fclose(fid);
  
  % put data into a 3D array
  A_3dim = reshape(A,nsamples,nbands,nlines);
  lan_data = permute(A_3dim,[3 1 2]);
  
%-------------------------------------------------------
function lowhigh = stretchlim(img,tol)
%STRETCHLIM Find limits to contrast stretch an image.
%   LOW_HIGH = STRETCHLIM(I,TOL) returns a pair of intensities that can be
%   used by IMADJUST to increase the contrast of an image.
%
%   TOL = [LOW_FRACT HIGH_FRACT] specifies the fraction of the image to
%   saturate at low and high intensities. 
%
  
  nbins = 256;
  tol_low = tol(1);
  tol_high = tol(2);
  [m,n,p] = size(img);
  
  for i = 1:p                          % Find limits, one plane at a time
    N = imhist(img(:,:,i),nbins);
    if (length(find(N~=0)) > 1)      % check that image is not flat
      cdf = cumsum(N)/sum(N);
      ilow = min(find(cdf>tol_low));
      ihigh = min(find(cdf>=tol_high));   
      ilowhigh(:,i) = [ilow;ihigh];
    else                             % image is flat
      ilowhigh(:,i) = [1; nbins];    
    end
  end   
  
  lowhigh = (ilowhigh - 1)/(nbins-1);  % convert to range [0 1]
  
%-------------------------------------------------------
function show_busy(hfig)
  
  ud = get(hfig,'UserData');
  h = ud.h;
  
  h_inactive = [h.img_popup h.truecolor_radio h.nir_radio h.swir_radio ...
                h.custom_radio h.singleband_radio h.info h.close];
  set(h_inactive,'Enable','inactive')
  
  if (get(h.custom_radio,'Value') == 1)
    h_custom =   [h.red_popup h.green_popup h.blue_popup];
    set(h_custom,'Enable','inactive')
  elseif (get(h.singleband_radio,'Value') == 1)
    set(h.intensity_popup,'Enable','inactive')
  end
  
  set(hfig,'pointer','watch')
  drawnow
  
%-------------------------------------------------------
function show_ready(hfig)
  
  ud = get(hfig,'UserData');
  h = ud.h;
  
  h_enable1 = [h.img_popup h.truecolor_radio h.nir_radio h.swir_radio,...
               h.custom_radio h.singleband_radio h.info h.close];
  set(h_enable1,'Enable','on')
  
  % check state of radio buttons to decide what else to enable
  if ( get(h.custom_radio,'Value') == 1 )          % custom
    h_enable2 = [h.red_popup h.green_popup h.blue_popup];
  elseif ( get(h.singleband_radio,'Value') == 1 )  % singleband
    h_enable2 = h.intensity_popup;
  else
    h_enable2 = [];                              % nothing else to enable
  end
  set(h_enable2,'Enable','on')
  set(hfig,'pointer','arrow')
  drawnow

%-------------------------------------------------------
function hfig = DemoFigHandle
  
  hfig = findobj(allchild(0),'Tag','LANdemo');
  
%-------------------------------------------------------
function hfig = create_gui
  
  fig_color = [0.8 0.8 0.8];
  
  hfig = figure('Tag','LANdemo',...
                'Visible','off',...
                'HandleVisibility','callback',...
                'Resize','off',...
                'menubar','none', ...              
                'Units','pixels',...
                'IntegerHandle','off',...
                'NumberTitle','off',...
                'Name','Landsat Color Composite Demo',...
                'Pointer','watch',...
                'Color',fig_color,...
                'DoubleBuffer','on',...
                'Colormap',gray(256));
  
  create_menus(hfig);
  create_gui_elements(hfig);
  position_gui_elements(hfig)
  
%-------------------------------------------------------
function create_menus(hfig)
  
% Menus
  
% File menu
  mFile = uimenu('parent',hfig,'label','&File');
  uimenu('parent',mFile,'label','&Print','callback','printdlg(gcbf);');
  uimenu('parent',mFile,'label','&Close', ...
         'callback','close(gcbf);','separator','on');
  
  % Window menu
  uimenu('parent',hfig, 'label','&Window', ...
         'tag','winmenu', ...
         'Callback', winmenu('callback'));
  winmenu(hfig);  % Initialize the submenu
  
%-------------------------------------------------------
function create_gui_elements(hfig)

  text_color = [0 0 0];
  status_color = [0 0 .8];
  frame_color = [.45 .45 .45];
  frame_label_color = [1 1 1];
  radio_color = [.7 .7 .7];
  fig_color = get(hfig,'color');
  
  % image axes
  h.img_axes = axes('Parent',hfig,...
                    'YDir','reverse',...
                    'XLim',[0.5 512.5],...
                    'YLim',[0.5 512.5],...
                    'CLim',[0 255],...
                    'XTick',[],...
                    'YTick',[],...
                    'Units','pixels');

  fig_color_uint8 = uint8(round(fig_color(1)*255));
  gray_img = repmat(fig_color_uint8,512,512);
  h.img = image('Parent',h.img_axes,...
                'CData',gray_img,...
                'CDataMapping','scaled',...
                'EraseMode','none');
  
  % frame
  h.frame = uicontrol('Parent',hfig, ...
                      'Style', 'frame', ...
                      'BackgroundColor', frame_color, ...
                      'Units', 'pixels');
  
  % custom frame
  h.custom_frame = uicontrol('Parent',hfig, ...
                             'Style', 'frame', ...
                             'BackgroundColor', radio_color, ...
                             'Units', 'pixels');
  
  % singleband frame
  h.singleband_frame = uicontrol('Parent',hfig, ...
                                 'Style', 'frame', ...
                                 'BackgroundColor', radio_color, ...
                                 'Units', 'pixels');
  
  % image popup label
  h.img_popup_label = uicontrol('Parent',hfig,...
                                'Style','text',...
                                'String','Select an image:',...
                                'BackgroundColor', frame_color, ...
                                'ForegroundColor', frame_label_color, ...   
                                'Units','pixels');
  
  % image popup
  % UserData tracks the value setting and is used to see if the
  % selected image really changes.  We set it to 0 here for
  % initialization purposes.
  h.img_popup = uicontrol('Parent',hfig,...
                          'Interruptible','off',...
                          'Enable','inactive',...
                          'Style','popupmenu',...
                          'String',{'Little Colorado River',...
                      'Mississippi River',...
                      'Montana',...
                      'Paris',...
                      'Rio de Janeiro',...
                      'Tokyo'},...
                          'Callback',[mfilename '(''new_image'')'],...
                          'UserData',0,...
                          'Units','pixels');
  
  % True Color radio button
  callback_str = [mfilename '(''update_radio'')'];
  h.truecolor_radio = uicontrol('Parent',hfig,...
                                'Interruptible','off',...
                                'Enable','inactive',...
                                'Style','radiobutton',...
                                'String','True Color [3 2 1]',...
                                'UserData',1,...
                                'Value',1,...
                                'Callback',callback_str,...
                                'BackgroundColor', radio_color, ...
                                'Units', 'pixels');
  
  % Near Infrared radio button
  callback_str = [mfilename '(''update_radio'')'];
  h.nir_radio = uicontrol('Parent',hfig,...
                          'Interruptible','off',...
                          'Enable','inactive',...
                          'Style','radiobutton',...
                          'String','Near Infrared [4 3 2]',...
                          'UserData',0,...
                          'Value',0,...
                          'Callback',callback_str,...
                          'BackgroundColor', radio_color, ...
                          'Units', 'pixels');
  
  % Shortwave Infrared radio button
  callback_str = [mfilename '(''update_radio'')'];
  h.swir_radio = uicontrol('Parent',hfig,...
                           'Interruptible','off',...
                           'Enable','inactive',...
                           'Style','radiobutton',...
                           'String','Shortwave Infrared [7 4 3]',...
                           'UserData',0,...
                           'Value',0,...
                           'Callback',callback_str,...
                           'BackgroundColor', radio_color, ...
                           'Units', 'pixels');
  
  % Custom Composite radio button
  callback_str = [mfilename '(''update_radio'')'];
  h.custom_radio = uicontrol('Parent',hfig,...
                             'Interruptible','off',...
                             'Enable','inactive',...
                             'Style','radiobutton',...
                             'String','Custom Composite',...
                             'UserData',0,...
                             'Value',0,...
                             'Callback',callback_str,...
                             'BackgroundColor', radio_color, ...
                             'Units', 'pixels');                        
  
  % Single Band radio button
  callback_str = [mfilename '(''update_radio'')'];
  h.singleband_radio = uicontrol('Parent',hfig,...
                                 'Interruptible','off',...
                                 'Enable','inactive',...
                                 'Style','radiobutton',...
                                 'String','Single Band Intensity',...
                                 'UserData',0,...
                                 'Value',0,...
                                 'Callback',callback_str,...
                                 'BackgroundColor', radio_color, ...
                                 'Units', 'pixels');                        
  
  band_string = {'1','2','3','4','5','6','7'};
  
  % Red popup
  h.red_popup = uicontrol('Parent',hfig,...
                          'Interruptible','off',...
                          'Enable','off',...
                          'Style','popupmenu',...
                          'String',band_string,...
                          'Callback',[mfilename '(''update_band'')'],...
                          'UserData',3,...
                          'Value',3,...
                          'Units','pixels');
  
  % Green popup
  h.green_popup = uicontrol('Parent',hfig,...
                            'Interruptible','off',...
                            'Enable','off',...
                            'Style','popupmenu',...
                            'String',band_string,...
                            'Callback',[mfilename '(''update_band'')'],...
                            'UserData',1,...
                            'Value',1,...
                            'Units','pixels');
  
  
  % Blue popup
  h.blue_popup = uicontrol('Parent',hfig,...
                           'Interruptible','off',...
                           'Enable','off',...
                           'Style','popupmenu',...
                           'String',band_string,...
                           'Callback',[mfilename '(''update_band'')'],...
                           'UserData',7,...
                           'Value',7,...
                           'Units','pixels');
  
  % Intensity popup
  h.intensity_popup = uicontrol('Parent',hfig,...
                                'Interruptible','off',...
                                'Enable','off',...
                                'Style','popupmenu',...
                                'String',band_string,...
                                'Callback',[mfilename '(''update_band'')'],...
                                'UserData',5,...
                                'Value',5,...                              
                                'Units','pixels');
  
  % Red label
  h.red_popup_label = uicontrol('Parent',hfig,...
                                'Style','text',...
                                'String','Red',...
                                'BackgroundColor', radio_color, ...
                                'ForegroundColor',[.8 0 0],...
                                'Units','pixels');
  
  % Green label
  h.green_popup_label = uicontrol('Parent',hfig,...
                                  'Style','text',...
                                  'String','Green',...
                                  'BackgroundColor', radio_color, ...
                                  'ForegroundColor',[0 .5 0],...
                                  'Units','pixels');
  
  % Blue label
  h.blue_popup_label = uicontrol('Parent',hfig,...
                                 'Style','text',...
                                 'String','Blue',...
                                 'BackgroundColor', radio_color, ...
                                 'ForegroundColor',[0 0 .8],...
                                 'Units','pixels');
  
  % stretch checkbox
  h.stretch = uicontrol('parent',hfig, ...
                        'Style','checkbox',...
                        'String','Saturation Stretch', ...
                        'Callback', [mfilename '(''display_image'')'],...
                        'Value',1,...
                        'Units','pixels');
  
  % decorr checkbox
  h.decorr = uicontrol('parent',hfig, ...
                        'Style','checkbox',...
                        'String','Decorrelation Stretch', ...
                        'Callback', [mfilename '(''display_image'')'],...
                        'Value',0,...
                        'Units','pixels');
  
  % Info button
  h.info = uicontrol('Parent',hfig, ...
                     'Interruptible','off',...
                     'Enable', 'inactive', ...
                     'Style', 'pushbutton', ...
                     'String', 'Info', ...
                     'Callback', 'helpwin(''landsatdemo'')', ...
                     'Units', 'pixels');
  
  % Close button
  h.close = uicontrol('Parent',hfig, ...
                      'Interruptible','off',...
                      'Enable', 'inactive', ...
                      'Style', 'pushbutton', ...
                      'String', 'Close', ...
                      'Callback', 'delete(gcbf)', ...
                      'Units', 'pixels');
  
  ud.h = h;
  set(hfig,'UserData',ud);  % Store handles of gui elements in figure userdata
  
%-------------------------------------------------------
function position_gui_elements(hfig)
  
  ud = get(hfig,'UserData');
  h = ud.h;
  
  geom = imuigeom; %imuigeom is a private function to set location of gui elements
  
  gutter = 20;   % pixels
  image_width = 512;
  image_height = 512;
  label_gap = 5;
  
  bottom = gutter; 
  top = bottom + image_height + gutter; % top of figure 
  left1 = gutter;
  
  % find position of h.img
  pos.img_axes = [left1 bottom image_width image_height];
  
  left2 = pos.img_axes(1) + image_width + gutter + label_gap;
  
  % image popup label
  extent.img_popup_label = find_extent(h.img_popup_label,geom.text);
  bottom1 = top - gutter - label_gap - extent.img_popup_label(4);
  pos.img_popup_label = [left2 bottom1 extent.img_popup_label(3:4)];
  
  % image popup
  extent.img_popup = find_popup_extent(h.img_popup,geom.popupmenu);
  bottom2 = bottom1 - extent.img_popup(4); 
  pos.img_popup = [left2 bottom2 extent.img_popup(3:4)];
  
  % find extent of widest radio button
  extent.radio = find_extent(h.swir_radio,geom.radiobutton);
  width_radio = extent.radio(3);
  height_radio = extent.radio(4);
  
  bottom3 = bottom2 - 5*label_gap - height_radio;
  bottom4 = bottom3 - label_gap - height_radio;                  
  bottom5 = bottom4 - label_gap - height_radio;
  bottom6 = bottom5 - label_gap - height_radio;
  
  pos.truecolor_radio = [left2 bottom3 extent.radio(3:4)];
  pos.nir_radio       = [left2 bottom4 extent.radio(3:4)];
  pos.swir_radio      = [left2 bottom5 extent.radio(3:4)];
  pos.custom_radio    = [left2 bottom6 extent.radio(3:4)];
  
  % band popups
  extent.band_popup = find_extent(h.red_popup,geom.popupmenu);
  width_band_popup = extent.band_popup(3);
  height_band_popup = extent.band_popup(4);
  
  left_red   = left2 + 4*label_gap;
  left_green = left_red   + width_band_popup + 2*label_gap;
  left_blue  = left_green + width_band_popup + 2*label_gap;
  bottom7 = bottom6 - label_gap - height_band_popup;
  
  pos.red_popup   = [left_red   bottom7 extent.band_popup(3:4)];
  pos.green_popup = [left_green bottom7 extent.band_popup(3:4)];
  pos.blue_popup  = [left_blue  bottom7 extent.band_popup(3:4)];
  
  % band labels
  extent.band_popup_label = find_extent(h.green_popup_label,geom.text);
  bottom8 = bottom7 - label_gap - extent.band_popup_label(4);
  
  pos.red_popup_label   = [left_red    bottom8 extent.band_popup_label(3:4)];
  pos.green_popup_label = [left_green  bottom8 extent.band_popup_label(3:4)];
  pos.blue_popup_label  = [left_blue   bottom8 extent.band_popup_label(3:4)];
  
  % custom frame
  bottom9 = bottom8 - label_gap;
  height_custom_frame = bottom6 + height_radio - bottom9 + 1;
  pos.custom_frame = [left2-1 bottom9 width_radio+2 height_custom_frame];
  
  % Single Band radio button and popup
  bottom10 = bottom9 - 2*label_gap - height_radio;
  pos.singleband_radio = [left2 bottom10 extent.radio(3:4)];
  bottom11 = bottom10 - label_gap - height_band_popup;
  pos.intensity_popup = [left_green bottom11 extent.band_popup(3:4)];

  % single band frame
  bottom12 = bottom11 - label_gap;
  height_singleband_frame = bottom10 + height_radio - bottom12 + 1;
  pos.singleband_frame=[left2-1 bottom12 width_radio+2 height_singleband_frame];
  
  % stretch checkbox
  bottom13 = bottom12 - 10*label_gap - height_radio;
  pos.stretch = [left2 bottom13 width_radio height_radio]; 
  
  % decorr checkbox
  bottom16 = bottom13 - 1*label_gap - height_radio;
  pos.decorr = [left2 bottom16 width_radio height_radio]; 
  
  % close button
  bottom15 = bottom + label_gap;
  extent.button = find_extent(h.close,geom.pushbutton);
  height_button = extent.button(4);
  pos.close = [left2 bottom15 width_radio height_button];
  
  % info button
  bottom14 = bottom15 + height_button + label_gap;
  pos.info = [left2 bottom14 width_radio height_button];
  
  % find figure size
  max_width = max([extent.img_popup(3) width_radio]);
  frame_width = max_width + 2*label_gap;
  pos.frame = [left2-label_gap bottom frame_width image_height];
  
  figureWidth = left2 + max_width + gutter + label_gap;
  figureHeight = top;
  
  %
  % Adjust figure position - copied from qtdemo
  %
  horizDecorations = 30;  % resize controls, etc.
  vertDecorations = 65;   % title bar, etc.
  screenSize = get(0,'ScreenSize');
  if (screenSize(3) <= 1)
    % No display connected (apparently)
    screenSize(3:4) = [100000 100000]; % don't use Inf because of vms
  end
  if (((figureWidth + horizDecorations) > screenSize(3)) | ...
      ((figureHeight + vertDecorations) > screenSize(4)))
    % Screen size is too small for this demo!
    delete(hfig);
    error(['Screen resolution is too low ', ...
           '(or text fonts are too big) to run this demo']);
  end
  figPos = get(hfig, 'Position');
  figPos(3:4) = [figureWidth figureHeight];
  dx = screenSize(3) - figPos(1) - figPos(3) - horizDecorations;
  dy = screenSize(4) - figPos(2) - figPos(4) - vertDecorations;
  if (dx < 0)
    figPos(1) = figPos(1) + dx;
  end
  if (dy < 0)
    figPos(2) = figPos(2) + dy;
  end
  set(hfig, 'Position', figPos)
  
  set(h.img_axes,'Position',pos.img_axes)
  set(h.frame,'Position',pos.frame)
  set(h.img_popup_label,'Position',pos.img_popup_label)
  set(h.img_popup,'Position',pos.img_popup)
  set(h.truecolor_radio,'Position',pos.truecolor_radio)
  set(h.nir_radio,'Position',pos.nir_radio)
  set(h.swir_radio,'Position',pos.swir_radio)
  
  set(h.custom_frame,'Position',pos.custom_frame)
  set(h.custom_radio,'Position',pos.custom_radio)
  set(h.red_popup,'Position',pos.red_popup)
  set(h.green_popup,'Position',pos.green_popup)
  set(h.blue_popup,'Position',pos.blue_popup)
  set(h.red_popup_label,'Position',pos.red_popup_label)
  set(h.green_popup_label,'Position',pos.green_popup_label)
  set(h.blue_popup_label,'Position',pos.blue_popup_label)
  
  set(h.singleband_frame,'Position',pos.singleband_frame)
  set(h.singleband_radio,'Position',pos.singleband_radio)
  set(h.intensity_popup,'Position',pos.intensity_popup)
  
  set(h.stretch,'Position',pos.stretch)
  set(h.decorr, 'Position',pos.decorr)
  
  set(h.info,'Position',pos.info)
  set(h.close,'Position',pos.close)

%-------------------------------------------------------                    
function extent = find_extent(h,fudge_factor)
  
  extent = get(h, 'Extent');
  extent = extent + fudge_factor;
  
%-------------------------------------------------------                    
function extent = find_popup_extent(h,fudge_factor)
  
  popup_string = get(h,'string');
  
  max_length = 0;                  % find longest string of popup
  for i = 1:length(popup_string)
    i_length = length(popup_string{i});
    if ( i_length > max_length ) 
      max_length = i_length;
      i_longest = i;
    end
  end
  dummy = popup_string{i_longest};
  set(h,'string',dummy);
  extent = get(h, 'Extent');       % use longest string to get extent
  
  set(h,'string',popup_string);    % restore actual string
  extent = extent + fudge_factor;
