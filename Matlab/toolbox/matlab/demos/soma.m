function soma(Action)
% SOMA   display precomputed solutions to Piet Hein's soma cube
%   A solution is represented by a vector of locations within
%   the 3x3 cube, 1 being lower left front, 27 being upper right back.
%   This gui allows the user to look at one solution at a time.

%   W. M. McKeeman 
%
%   Copyright 1984-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.2 $
%   $Revision: 1.9.4.2 $  $Date: 2004/04/10 23:25:45 $
switch nargin,
  case 0,
    LocalInitFig
  case 1,
    fig=gcf;  
    Data=get(fig,'UserData');
    switch Action,
      case 'Info',
        ttlStr=mfilename;
        hlpStr1= ...
        {' The soma cube is a puzzle consisting of seven pieces that    '  
         ' can be assembled into a 3x3x3 cube.  It is a special case of '
         ' space-filling puzzles.                                       '  
         '                                                              '  
         ' The seven pieces of the soma cube are all pieces that can be '
         ' made by gluing four or less cubes together at their faces,   '
         ' producing a piece with an inside corner.  That is, three     '
         ' cubes forming a "V" are included but three cubes making an   '
         ' "I" are excluded.                                            '
         '                                                              '  
         ' The seven pieces are named V L T Z S R Y, all but S and R    '
         ' approximating the shape of the assembled cubes.  The S piece '
         ' is "screw shaped" and the R piece is its reflection.  The R  '
         ' piece is a "right-handed screw". Pictures of these pieces are'
         ' displayed when soma.m runs.                                  '
         '                                                              '  
         ' There are 240 unique ways to assemble the 7 pieces into a    '
         ' 3x3x3 cube, discounting reflections and rotations.           '
         '                                                              '}; 
     
        hlpStr2= ...
        {' The combinatorics of brute force computation are on the      '
         ' order of 100^7, since each piece can fit into the cube in    '
         ' about 100 different ways.  Fortunately, there are some       '
         ' theories which reduce the computation to a feasible task.    '
         '                                                              '  
         ' The simplest theorem involves examining the 8 vertices of the'
         ' completed solution.  The V Z S R Y pieces can occupy at most '
         ' 1 of these 8 vertices.  The T piece can touch 2 or 0         '
         ' vertices, and the L piece can touch 2, 1 or 0.  If you add   '
         ' up the maximum number of vertices touchable by the pieces,   '
         ' it comes out to 1+2+2+1+1+1+1=9.  Therefore, exactly one     '
         ' piece contributes 1 less than its maximum.  That cannot be T,'
         ' because it cannot touch 1 vertex.  One concludes that T      '
         ' always touches 2 vertices, and therefore is always in exactly'
         ' the same position in the finished cube (after rotation).  The'
         ' soma cube is really only a 6 piece puzzle!                   '
         '                                                              '};
     
        hlpStr3= ...
        {' A more general theorem accounts for classes VEFC, standing   '
         ' for the 8 Vertices, 12 Edges, 6 Faces and 1 Center.  Any     '
         ' solution has to fill each of the VEFC classes exactly.  To   '
         ' carry out the analysis, first classify the pieces themselves '
         ' by VEFC.  V, for example, can be 1200, meaning 1 vertex, 2   '
         ' edges, 0 faces and 0 centers.  The sum of the VEFC vectors   '
         ' has to add up to 8 12 6 1, and therefore the search can be   '
         ' restricted to class of piece positions for which the VEFC sum'
         ' holds.  This leads to 11 combinations of piece position      '
         ' classes, for which the combinatoric is more like 10^7, which '
         ' can be computed in about an hour.                            '
         '                                                              '
         ' This program could be modified to solve other objects that   '
         ' can be built out of the 7 pieces (commercial puzzles come    '
         ' with dozens of suggestions), or to solve puzzles made of     '
         ' other pieces (The double soma cube consists of L T Z S R Y   '
         ' plus two length 4 "I" pieces plus 2 size 4 "O" pieces gives  '
         ' 24+24+4+4+4+4=64, making a 4x4x4 cube possible).  The eight  '
         ' queens problem can be thought of as filling a space          '
         ' consisting of rows, columns and diagonals of the chessboard  '
         ' (8+8+14+14) where each queen takes a row, a column and two   '
         ' diagonals.                                                   '};
        
        helpwin(cat(1,hlpStr1, hlpStr2, hlpStr3), ttlStr);

      case 'Next',
        if Data.sn < 240,
          Data.sn = Data.sn+1; 
        else
          Data.sn=1;
        end          
        
        set(Data.pn,'string',[num2str(Data.sn) ' of 240']);
        Data.sol = Data.sols(Data.sn,:);
        LocalRepaint(Data)
        set(fig,'UserData',Data);
        
      case 'Previous',
        if Data.sn > 1,
          Data.sn = Data.sn-1; 
        else
          Data.sn=240;
        end          
        
        set(Data.pn,'string',[num2str(Data.sn) ' of 240']);
        Data.sol = Data.sols(Data.sn,:);
        LocalRepaint(Data)
        set(fig,'UserData',Data);
        
      case 'Close',
        delete(gcf)
        
      case 'RotateXY',      
        Data.sol = LocalRXY(Data.sol);
        LocalRepaint(Data)
        set(fig,'UserData',Data);
        
      case 'RotateYZ',
        Data.sol = LocalRYZ(Data.sol);
        LocalRepaint(Data)
        set(fig,'UserData',Data);
       
      otherwise, 
        error('SOMA accepts no input arguments');  
        
    end % switch        
    
  otherwise,
    error('SOMA accepts no input arguments');  
    
end % switch

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalRepaint %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRepaint(Data)
% FUNCTION:    LocalRepaint
% PURPOSE: callback to repaint the soma cube
% METHOD:  run from stage4.m

% facelet -- cubie correlation
%       R  L  T  R  L  T  R  L  T
face = [1  1 19 10 10 22 19 19 25,...
        2  4 20 11 13 23 20 22 26,...
        3  7 21 12 16 24 21 25 27];

% the standard VLTZSRY order of display, 3 V, 4 L, etc.
%         r  g  b        
purple = [.4  0 .6];                       % V -- piece colors
blue   = [0   0  1];                       % L
green  = [0   1 .2];                       % T
yellow = [1   1  0];                       % Z
orange = [.9 .5  0];                       % S
red    = [1   0  0];                       % R
violet = [1   0  1];                       % Y
white  = [1   1  1];                       % empty

pc = [purple; purple; purple
      blue;   blue;   blue;   blue
      green;  green;  green;  green
      yellow; yellow; yellow; yellow
      orange; orange; orange; orange
      red;    red;    red;    red
      violet; violet; violet; violet];

for c = 1:27
    soltn = Data.sol(c);
    set(Data.squarelet(soltn), 'facecolor', pc(c,:));
    for d = 1:27
        if soltn == face(d)
            set(Data.trp(d), 'facecolor', pc(c,:));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalRXY %%%%%
%%%%%%%%%%%%%%%%%%%%
function newp=LocalRXY(oldp)
% FUNCTION:    LocalRXY
% PURPOSE: rotate a cube in the xy plane

tx = [ 3  6  9   2  5  8   1  4  7,...
      12 15 18  11 14 17  10 13 16,...
      21 24 27  20 23 26  19 22 25];

newp = tx(oldp);

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalRYZ %%%%%
%%%%%%%%%%%%%%%%%%%%
function newp=LocalRYZ(oldp)
% FUNCTION:    LocalRYZ
% PURPOSE: rotate a cube in the xy plane

tx = [7 8 9  16 17 18  25 26 27,...
      4 5 6  13 14 15  22 23 24,...
      1 2 3  10 11 12  19 20 21];     % rotation y to z

newp = tx(oldp);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalInitFig
cubie = [0 0; 0 1; 1 1; 1 0; 0 0];    % to draw a little square

% physical layout of cubies to form sliced display of 3x3 cube
cube  = [0 0; 1 0; 2 0;   0 1; 1 1; 2 1;   0 2; 1 2;  2 2
         4 0; 5 0; 6 0;   4 1; 5 1; 6 1;   4 2; 5 2;  6 2
         8 0; 9 0; 10 0;  8 1; 9 1; 10 1;  8 2; 9 2; 10 2];

%         r  g  b        
purple = [.4  0 .6];                       % V -- piece colors
blue   = [0   0  1];                       % L
green  = [0   1 .2];                       % T
yellow = [1   1  0];                       % Z
orange = [.9 .5  0];                       % S
red    = [1   0  0];                       % R
violet = [1   0  1];                       % Y
white  = [1   1  1];                       % empty

v = [1 0; 0 0; 0 1];                       % to draw a V
l = [v; 0 2];                              % add a cubie and get an L
t = [0 1; 1 1; 2 1; 1 0];                  % to draw a T
z = [0 1; 1 1; 1 0; 2 0];                  % to draw a Z
s = [v; 1.2  .2];                          % add a cubie and get an S
r = [v;  .2 1.2];                          % add a cubie and get an R
y = [v;  .2  .2];                          % add a cubie and get a Y

xv = cubie(:,1);                           % x vector to drive patch()
yv = cubie(:,2);                           % y vector to drive patch()

backcolor  = [1 1 1];                      % white
backcolor  = [.8 .8 .8];                   % grey

screenpos  = 300;                          % about the middle
screenx = 700;                             % about half
screeny = 500;                             % about half

axescolor = [1 1 1];

figh = figure(...
   'Color'   , backcolor,...
   'NumberTitle','off', ...   
   'CloseRequestFcn','soma Close', ...
   'Name'    , 'Soma Cube Solutions');

ax2 = axes(...
    'Units'   ,    'normalized',...
    'Position', [0.05 .05 0.7 0.25]  ,...
    'Color'   , axescolor);
axis([0 1 0 1]);
set(gca,'XTick',[],'YTick',[]);

text(.5,.5,{'The Soma Cube:';' '; ...
            'A space-filling puzzle for fitting the'; ...
            'seven pieces shown into a perfect cube.'}, ...
    'HorizontalAlignment','center', ...    
    'color', 'black');

ax = axes(...
    'Units'   ,    'normalized',...
    'Position', [0.05 .3 0.7 0.7]  ,...
    'Color'   ,    axescolor);

axis('image');
axis([0 1 0 .6]);
set(gca,'XTick',[],'YTick',[]);

buttonx      = .80;
buttony      = .95;
buttonwidth=0.15;
buttonheight= 0.08;
spacing=0.03;
sn          = 1;
% following are the active elements for user control
uicontrol(figh,...                  % decrement solution selection
     'Style'   , 'frame',...
     'Units'   , 'normalized',...
     'Position', [buttonx-0.01,0.05,buttonwidth+0.02,0.9]);
 
pt = uicontrol(figh,...                    % slider title
     'Style', 'text',...
     'String', 'Solution Number',...
     'Units',  'normalized',...
     'Position',[buttonx,buttony-buttonheight-spacing, ...
                 buttonwidth,buttonheight]);
pn = uicontrol(figh,...                    % visible solution number 
     'Style',  'text',...
     'String', '1 of 240',...
     'Units',  'normalized',...
     'Position',[buttonx, buttony-2*buttonheight-spacing, ...
                 buttonwidth,buttonheight]);

decr = uicontrol(figh,...                  % decrement solution selection
     'Style'   , 'pushbutton',...
     'Units'   , 'normalized',...
     'String'  , 'Previous',...
     'Position',[buttonx, buttony-3*buttonheight-2*spacing, ...
                 buttonwidth,buttonheight], ...
     'Callback', 'soma Previous');
 
incr = uicontrol(figh,...                  % increment solution selection
    'Style'   , 'pushbutton',...
    'Units'   , 'normalized',...
    'String'  , 'Next',...
     'Position',[buttonx, buttony-4*buttonheight-3*spacing, ...
                 buttonwidth,buttonheight], ...
    'Callback', 'soma Next');


pq = uicontrol(figh   ,...                 % the [quit] button
     'Style'          , 'pushbutton',...
     'Units'          , 'normalized',...
     'String'         , 'Close',...
     'Position'       , [buttonx, 0.05+spacing,buttonwidth,buttonheight],...
     'Callback'       ,'soma Close');
 
pq = uicontrol(figh   ,...                 % the info button
     'Style'          , 'pushbutton',...
     'Units'          , 'normalized',...
     'String'         , 'Info',...
     'Position'       , [buttonx, 0.05+2*spacing+buttonheight, ...
                         buttonwidth,buttonheight],...
     'Callback'       ,'soma Info');

rot1 = uicontrol(figh,...                  % rotate solution xy
    'Style',    'pushbutton',...
    'Units',    'normalized',...
    'String',   'rotate right',...
    'Position', [.575, .72, .15, .08],...
    'Callback','soma RotateXY');

rot2 = uicontrol(figh,...                  % rotate solution yz
    'Style',    'pushbutton',...
    'Units',    'normalized',...
    'Position', [.44, .58, .15, .08],...
    'String',   'rotate down',...
    'Callback', 'soma RotateYZ');


sqsize = 0.03;                       % edge of a squarelet

dy3 = 1;                             % y posit for sample title
dy2 = dy3+1;                         % y posit for name of sample
dy  = dy2+1;                          % y posit for sample pieces
dx  = 4;                             % x posit for sample pieces

text('position', [dx+.5 dy2]*sqsize,  'string', 'V', 'color', 'black');
for c = 1:3                          % paint a sample V
    xx = xv+v(c,1)+dx;
    yy = yv+v(c,2)+dy;
    pv = patch(xx*sqsize, yy*sqsize, purple);
end

dx = dx + 4;
text('position', [dx+.5 dy2]*sqsize,  'string', 'L', 'color', 'black');
for c = 1:4                          % paint a sample  L
    xx = xv+l(c,1)+dx;
    yy = yv+l(c,2)+dy;
    ph = patch(xx*sqsize, yy*sqsize, blue);
end

dx = dx + 4;
text('position', [dx+1 dy2]*sqsize,  'string', 'T', 'color', 'black');
for c = 1:4                          % paint a sample T
    xx = xv+t(c,1)+dx;
    yy = yv+t(c,2)+dy;
    pt = patch(xx*sqsize, yy*sqsize, green);
end

dx = dx + 4;
text('position', [dx+1 dy2]*sqsize, 'string', 'Z', 'color', 'black');
for c = 1:4                          % paint a sample Z
    xx = xv+z(c,1)+dx;
    yy = yv+z(c,2)+dy;
    pz = patch(xx*sqsize, yy*sqsize, yellow);
end

dx = dx + 4;
text('position', [dx+.5 dy2]*sqsize, 'string', 'S', 'color', 'black');
for c = 1:4                          % paint a sample S
    xx = xv+s(c,1)+dx;
    yy = yv+s(c,2)+dy;
    ps = patch(xx*sqsize, yy*sqsize, orange);
end

dx = dx + 4;
text('position', [dx+.5 dy2]*sqsize, 'string', 'R', 'color', 'black');
for c = 1:4                          % paint a sample R
    xx = xv+r(c,1)+dx;
    yy = yv+r(c,2)+dy;
    pr = patch(xx*sqsize, yy*sqsize, red);
end

dx = dx + 4;
text('position', [dx+.5 dy2]*sqsize, 'string', 'Y', 'color', 'black');
for c = 1:4                          % paint a sample Y
    xx = xv+y(c,1)+dx;
    yy = yv+y(c,2)+dy;
    py = patch(xx*sqsize, yy*sqsize, violet);
end
text('position', [14.5 dy3]*sqsize,...
     'string', 'soma cube pieces',...
     'color', 'black');

% paint an empty solution in three layers
% cube(i,1) is a sequence of x positions outlining squarelet i [1:27]
% cube(i,2) is a sequence of y positions outlining squarelet 1 [1:27]
for c = 1:27                                  % cycle through cubies
    xx = xv+cube(c,1)+5;                      % x trace for cubie c
    yy = yv+cube(c,2)+12;                     % y trace + move image up 6
    squarelet(c) = patch(xx*sqsize, yy*sqsize, white);
end

% paint an empty cube in 3 d

c = cos(pi/6);                                % 30 degrees
s = sin(pi/6);
x1 = [0 c c 0 0];                             % trace a facelet on right
y1 = [0 s c+s c 0];
x2 = -x1;                                     % trace a facelet on left
x3 = [0 c 0 -c 0];                            % trace a facelet on top
y3 = [ 0 s 2*s s 0]+3*c;
dx3 = 22;                                     % place 3d image on screen
dy3 = 11;
x1 = x1 + dx3;
x2 = x2 + dx3;
x3 = x3 + dx3;
y1 = y1 + dy3;
y3 = y3 + dy3;

k=1;                                          % 27 visible facelets
for x = 0:2
   for y = 0:2
       px = x1+x*c;  py = y1+y*c+x*s;
       trp(k) = patch(px*sqsize, py*sqsize, [1 1 1]);      % on right R
       k = k + 1;
       px = x2-x*c;
       trp(k) = patch(px*sqsize, py*sqsize, [1 1 1]);      % on left  L
       k = k + 1;
       px = x3+x*c-y*c;  py = y3+y*s+x*s;
       trp(k) = patch(px*sqsize, py*sqsize, [1 1 1]);      % on top   T
       k = k + 1;
    end
end

gox = 11*sqsize;
goy = .48;
line1 = text(gox, goy,'',...
    'HorizontalAlignment','center', ...    
    'color', 'black', ...
    'String','Solution in three layers');

line2 = text(.5, .58,...
    'Solutions for the Soma Cube puzzle of Piet Hein',...
    'HorizontalAlignment','center', ...      
    'color', 'black');
    
layerx = .15;
layery = .32;
lw = sqsize*4;
line3 = text(layerx+.005, layery, 'bottom', 'color', 'black');
line4 = text(layerx+lw+.01, layery, 'middle', 'color', 'black');
line5 = text(layerx+2*lw+.025, layery, 'top', 'color', 'black');

Patches=findobj(figh,'Type','patch');
set(Patches,'EraseMode','none');

Data.pn=pn;
Data.sn=sn;
Data.sols=somasols;
Data.sol=Data.sols(1,:);
Data.squarelet=squarelet;
Data.trp=trp;

set(figh,'UserData',Data);

LocalRepaint(Data)

