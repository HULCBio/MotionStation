function surfht(x,y,Z)
%SURFHT Interactive contour plot of a data grid.
%   SURFHT(Z) is an interactive contour plot of the matrix Z treating the
%   values in Z as height above the plane. The x-values are the column 
%   indices of Z while the y-values are the row indices of Z.
%   SURFHT(x,y,Z), where x and y are vectors specify the x and y-axes on the
%   contour plot. The length of x and y must match the number of rows in Z.
%
%   There are vertical and horizontal reference lines on the plot whose 
%   intersection defines the current x-value and y-value. You can drag
%   these dotted white reference lines and watch the interpolated z-values
%   (at the top of the plot) update simultaneously. Alternatively, you can 
%   get a specific interpolated z-value by typing the x-value and y-value  
%   into editable text fields on the x-axis and y-axis respectively. 
    
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.4.1 $  $Date: 2004/01/24 09:36:58 $

if ~ischar(x) 
    action = 'start';
else
    action = x;
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')   
   surf_fig = gcbf;
   if (isempty(surf_fig)), surf_fig = findobj('Tag','surf_fig'); end
   f = get(surf_fig,'Userdata');

   x_field          = f(1);
   y_field          = f(2);
   z_field          = f(3);
   xtext            = f(4);
   ytext            = f(5);
   ztext            = f(6);
   surf_axes        = f(7);
   
   xgrid = get(xtext,'UserData');
   ygrid = get(ytext,'UserData');
   zgrid = get(ztext,'UserData');
   h     = get(surf_axes,'UserData');
   
   vwitnessline = h(1);
   hwitnessline = h(2);

    xrange = get(surf_axes,'XLim');
    yrange = get(surf_axes,'YLim');

    newx = str2double(get(x_field,'String'));  
    newy = str2double(get(y_field,'String'));  
end

if strcmp(action,'start'),

% Set positions of graphic objects
axisp   = [.20 .15 .79 .74];

xfieldp = [0.53 .00 .13 .05];
yfieldp = [0.02 .50 .13 .05];
zfieldp = xfieldp + [0 .89 0 0];

surf_fig = figure;
whitebg(surf_fig, [0 0 0]);
set(surf_fig,'Units','Normalized','Tag','surf_fig');
fcolor  = get(surf_fig,'Color');

surf_axes = axes;

% Set axis limits and data
if nargin == 1
    [m, n] = size(x);
   Z = x;
   x = 1:n;
   y = 1:m;
   xrange = [1 n];
   yrange = [1 m];
else
   xrange        = [x(1) x(length(x))];
   yrange        = [y(1) y(length(y))];
end
[xgrid ygrid] = meshgrid(x,y);

% Define graphics objects
        
x_field=uicontrol('Style','edit','Units','normalized','Position',xfieldp,...
         'BackgroundColor','white','Userdata',mean(xrange),...
         'CallBack','surfht(''editX'')');
         
y_field=uicontrol('Style','edit','Units','normalized','Position',yfieldp,...
         'BackgroundColor','white','Userdata',mean(yrange),...
         'CallBack','surfht(''editY'')');

z_field=uicontrol('Style','text','Units','normalized','Position',zfieldp,...
         'BackgroundColor',fcolor,'ForegroundColor','w');

xtext   =uicontrol('Style','text','Units','normalized',...
        'Position',xfieldp + [0 0.05 0 0],'BackgroundColor',fcolor,...
        'ForegroundColor','w','String','X Value','UserData',xgrid);
        
ytext   =uicontrol('Style','text','Units','normalized',...
        'Position',yfieldp + [0 0.05 0 0],'BackgroundColor',fcolor,...
        'ForegroundColor','w','String','Y Value','UserData',ygrid);

ztext   =uicontrol('Style','text','Units','normalized',...
        'Position',zfieldp + [0 0.05 0 0],'BackgroundColor',fcolor,...
        'ForegroundColor','w','String','Z Value','UserData',Z);
         
%   Create Interactive Contour Plot
contour_labels  = contour(x,y,Z);
clabel(contour_labels);
set(gca,'Units','normalized','Position',axisp,'XLim',xrange,'YLim',yrange,'Box','on');
set(gca,'NextPlot','add','DrawMode','fast','Gridlinestyle','none');

%   Create Witness Lines
yvertical = [yrange(1) yrange(2)]';
xvertical = repmat((xrange(1) + xrange(2))/2, size(yvertical));
newx  = xvertical(1);
newy  = (yrange(1) + yrange(2))/2;
set(x_field,'String',num2str(newx));
set(y_field,'String',num2str(newy));

newz    = interp2(xgrid,ygrid,Z,newx,newy);
set(z_field,'String',num2str(newz));



xhorizontal = [xrange(1) xrange(2)]';
yhorizontal = repmat(newy, size(xhorizontal));


vwitnessline = plot(xvertical,yvertical,'w-.','EraseMode','xor');
hwitnessline = plot(xhorizontal,yhorizontal,'w-.','EraseMode','xor');

set(vwitnessline,'ButtonDownFcn','surfht(''down'')');
set(hwitnessline,'ButtonDownFcn','surfht(''down'')');

set(gcf,'Backingstore','off','WindowButtonMotionFcn','surfht(''motion'',0)');
set(gcf,'WindowButtonDownFcn','surfht(''down'')');

set(surf_fig,'Userdata',[x_field;y_field;z_field;xtext;ytext;ztext;surf_axes],...
    'HandleVisibility','callback');
set(surf_axes,'UserData',[vwitnessline;hwitnessline]);
  

% End of initialization activities.
elseif strcmp(action,'motion'),
    if y == 0,
      cursorstate = get(gcf,'Pointer');
        cp = get(gca,'CurrentPoint');
        cx = cp(1,1);
        cy = cp(1,2);
        fuzzx = 0.01 * (xrange(2) - xrange(1));
        fuzzy = 0.01 * (yrange(2) - yrange(1));
        online = cy > yrange(1) && cy < yrange(2) && cx > xrange(1) && cx < xrange(2) &&...
           ((cy > newy - fuzzy && cy < newy + fuzzy) || (cx > newx - fuzzx && cx < newx + fuzzx));
        if online && strcmp(cursorstate,'arrow'),
            set(gcf,'Pointer','crosshair');
        elseif ~online && strcmp(cursorstate,'crosshair'),
            set(gcf,'Pointer','arrow');
        end
    
    elseif y == 1 || y == 2
        cp = get(gca,'CurrentPoint');
        if ~isinaxes(cp, gca)
            if y == 1
                set(gcf,'Pointer','arrow');
                set(gcf,'WindowButtonMotionFcn','surfht(''motion'',2)');
            end
            return;
        elseif y == 2
            set(gcf,'Pointer','crosshair');
            set(gcf,'WindowButtonMotionFcn','surfht(''motion'',1)');
        end
        newx=cp(1,1);
        if newx > xrange(2)
            newx = xrange(2);
        end
        if newx < xrange(1)
            newx = xrange(1);
        end

        newy=cp(1,2);
        if newy > yrange(2)
            newy = yrange(2);
        end
        if newy < yrange(1)
            newy = yrange(1);
        end

        newz    = interp2(xgrid,ygrid,zgrid,newx,newy);

        set(x_field,'String',num2str(newx));
        set(x_field,'Userdata',newx);
        set(y_field,'String',num2str(newy));
        set(y_field,'Userdata',newy);
        set(z_field,'String',num2str(newz));

        set(vwitnessline,'XData', repmat(newx, size(yrange)),'YData',yrange);
        set(hwitnessline,'XData', xrange,'YData', repmat(newy, size(xrange)));
    end

elseif strcmp(action,'down'),
    cp = get(gca,'CurrentPoint');
    if ~isinaxes(cp, gca)
        return;
    end
    set(gcf,'Pointer','crosshair');
    newx=cp(1,1);
    if newx > xrange(2)
       newx = xrange(2);
    end
    if newx < xrange(1)
       newx = xrange(1);
    end

    newy=cp(1,2);
    if newy > yrange(2)
       newy = yrange(2);
    end
    if newy < yrange(1)
       newy = yrange(1);
    end

    newz    = interp2(xgrid,ygrid,zgrid,newx,newy);

    set(x_field,'String',num2str(newx));
    set(x_field,'Userdata',newx);
    set(y_field,'String',num2str(newy));
    set(y_field,'Userdata',newy);
    set(z_field,'String',num2str(newz));

    set(vwitnessline,'XData', repmat(newx, size(yrange)),'YData',yrange);
    set(hwitnessline,'XData',xrange,'YData', repmat(newy, size(xrange)));
   
    set(gcf,'WindowButtonMotionFcn','surfht(''motion'',1)');
    set(gcf,'WindowButtonUpFcn','surfht(''up'')');

elseif strcmp(action,'up'),
    set(gcf,'WindowButtonMotionFcn','surfht(''motion'',0)');
    set(gcf,'WindowButtonUpFcn','');
    
elseif strcmp(action,'editX'),
    if isempty(newx) 
      newx = get(x_field,'Userdata');
      set(x_field,'String',num2str(newx));
       return;
   end
    if newx > xrange(2)
        newx = xrange(2);
        set(x_field,'String',num2str(newx));
    end
    if newx < xrange(1)
        newx = xrange(1);
        set(x_field,'String',num2str(newx));
    end

    newz    = interp2(xgrid,ygrid,zgrid,newx,newy);
 
    set(x_field,'Userdata',newx);
    set(z_field,'String',num2str(newz));
    set(vwitnessline,'XData', repmat(newx, size(yrange)));

elseif strcmp(action,'editY'),
    if isempty(newy) 
      newy = get(y_field,'Userdata');
      set(y_field,'String',num2str(newy));
       return;
   end
    if newy > yrange(2)
        newy =  yrange(2);
        set(y_field,'String',num2str(newy));
    end
    if newy <  yrange(1)
        newy =  yrange(1);
        set(y_field,'String',num2str(newy));
    end

    newz    = interp2(xgrid,ygrid,zgrid,newx,newy);
    set(z_field,'String',num2str(newz));

    set(hwitnessline,'XData',xrange,'YData', repmat(newy, size(xrange)));
    set(y_field,'Userdata',newy);
elseif strcmp(action,'stray_click'),
   set(gcf,'CurrentAxes',surf_axes);
end     % End of long "case" statement.
