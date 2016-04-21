function handles = btnicon(action)
%BTNICON Icon library for BTNGROUP.
%   BTNICON('option') draws the selected shape into the current
%   axes object in the region [0 1 0 1].
%
%   Options include:
%       bigzoom       fillellipse   rect
%       circle        littlezoom    rectc
%       deltaomega    omega         select
%       doublearrow   pause         spline
%       downarrow     play          stop
%       ellpc         polyfill      text
%       ellp          polygon       triangle
%       equal         polyline      triangle2
%       eraser        pixel         uparrow
%       fillcircle    record        zoom
%
%   See also BTNGROUP.

%   Steven L. Eddins, September 1994, AFP 11-1-94, LPD 4-15-95
%   SLE 5-20-96
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/15 03:24:51 $

action = lower(action);

if (strcmp(action, 'bigzoom'))

  xx = [0.4408    0.5256    0.6105    0.6954    0.7803    0.8651    0.9500
        0.3756    0.4605    0.5454    0.6303    0.7151    0.8000    0.8849
        0.3105    0.3954    0.4803    0.5651    0.6500    0.7349    0.8197
        0.2454    0.3303    0.4151    0.5000    0.5849    0.6697    0.7546
        0.1803    0.2651    0.3500    0.4349    0.5197    0.6046    0.6895
        0.1151    0.2000    0.2849    0.3697    0.4546    0.5395    0.6244
        0.0500    0.1349    0.2197    0.3046    0.3895    0.4744    0.5592];


  yy = [0.0500    0.0889    0.1830    0.2874    0.3277    0.2713    0.1836
        0.2217    0.3411    0.5152    0.6859    0.7424    0.6057    0.3570
        0.3070    0.4266    0.5933    0.8025    0.9500    0.8281    0.4991
        0.2851    0.3223    0.3595    0.3967    0.8882    0.8573    0.5445
        0.3336    0.3708    0.4080    0.4452    0.7647    0.7722    0.5258
        0.3821    0.4193    0.4565    0.4937    0.6837    0.6839    0.5174
        0.4306    0.4678    0.5050    0.5422    0.6497    0.6501    0.5641];


  zz = [-0.2047   -0.2696   -0.3019   -0.3281   -0.3922   -0.5134   -0.6531
        -0.2179   -0.2352   -0.2203   -0.2074   -0.2619   -0.4304   -0.6652
        -0.2820   -0.2992   -0.2887   -0.2530   -0.2538   -0.4137   -0.6958
        -0.4094   -0.4753   -0.5412   -0.6071   -0.4048   -0.5109   -0.7835
        -0.4953   -0.5612   -0.6271   -0.6930   -0.5923   -0.6757   -0.9091
        -0.5812   -0.6471   -0.7130   -0.7789   -0.7546   -0.8423   -1.0285
        -0.6671   -0.7330   -0.7989   -0.8648   -0.8892   -0.9768   -1.1154];

  zz = zz - min(zz(:)) + 0.1;
    
  handles = surface('XData', xx, 'YData', yy, 'ZData', zz, ...
    'FaceColor', 'none', 'UserData', 'Background', 'EdgeColor', 'k');

 
elseif (strcmp(action, 'circle'))
  v = -.1:.05:2*pi;
  handles = line(.4*cos(v)+.5,.4*sin(v)+.5,'Color','k');
  

elseif (strcmp(action, 'deltaomega'))
  handles = text('String',char([182 87]),'Position',[.5 .5],'Color','k', ...
   'Horiz','center','Vertical','middle','FontName','Symbol','FontWeight','bold', ...
   'FontSize',15);


elseif (strcmp(action, 'doublearrow'))
  handles = line([.2 .8 NaN .3 .2 .3 NaN .7 .8 .7], ...
                 [.5 .5 NaN .7 .5 .3 NaN .7 .5 .3],'Color','k','LineWidth',2);

elseif (strcmp(action, 'downarrow'))
  handles(1) = patch([0.45 0.55 0.55 0.45],[0.8  0.8  0.2  0.2 ],'k');
  handles(2) = patch([0.3 0.7 0.5],[0.3 0.3 0.2],'k');

elseif (strcmp(action, 'ellp'))

  w = 0:pi/32:2*pi;
  a = .4;
  b = .3;
  x = a*cos(w) + .5;
  y = b*sin(w) + .5;
  handles = line('XData',x,'YData',y,'ZData',ones(size(x)),'Color','k');
 
elseif (strcmp(action, 'ellpc'))

  w = 0:pi/32:2*pi;
  a = .4;
  b = .3;
  x = a*cos(w) + .5;
  y = b*sin(w) + .5;
  handles = [ ...
    line('XData',x,'YData',y,'ZData',ones(size(x)),'Color','k');
    line('XData',.5,'YData',.5,'ZData',1,'Color','k','Marker','+')];

elseif (strcmp(action,'fillcircle'))
  arc=0:0.05:2*pi;
  xx=0.5+0.25*cos(arc);
  yy=0.5+0.25*sin(arc);
  color=[0.7 0.7 0.7];
  handles=patch(                  ...
               'XData'    ,xx   , ...
               'YData'    ,yy   , ...
               'EdgeColor',color, ...
               'FaceColor',color  ...
               );
elseif (strcmp(action,'fillellipse'))
  arc=0:0.05:2*pi;
  xx=0.5+0.4*cos(arc);
  yy=0.5+0.3*sin(arc);
  color=[0.7 0.7 0.7];
  handles=patch(                  ...
               'XData'    ,xx   , ...
               'YData'    ,yy   , ...
               'EdgeColor',color, ...
               'FaceColor',color  ...
               );
elseif (strcmp(action, 'equal'))
  handles = line([.3 .7 NaN .3 .7], ...
                 [.4 .4 NaN .6 .6],'color','k','LineWidth',2);


elseif (strcmp(action, 'eraser'))
  xx=[.25 .55 .5 .2 .25 .5 .8  .75 .5 .55 .8];
  yy=[.4  .4  .2 .2 .4  .8 .8  .6  .2 .4  .8];
  h1 = patch( ...
            'XData',[0.25 0.55 0.5 0.2 0.25], ...
            'YData',[0.4  0.4  0.2 0.2 0.4 ], ...
            'FaceColor',[0.6 0.6 0.6]);
  h2 = patch( ...
            'XData',[0.25 0.55 0.85 0.55 0.25], ...
            'YData',[0.4  0.8  0.8  0.4  0.4], ...
            'FaceColor',[0.7 0.7 0.7] ...
            );
  h3 = patch( ...
            'XData',[0.55 0.85 0.8  0.5 0.55], ...
            'YData',[0.4  0.8  0.6  0.2 0.4], ...
            'FaceColor',[0.6 0.6 0.6] ...
            );
  handles=[h1 h2 h3];

elseif (strcmp(action, 'littlezoom'))
 
  xx = [0.4408    0.5256    0.6105    0.6954    0.7803    0.8651    0.9500
        0.3756    0.4605    0.5454    0.6303    0.7151    0.8000    0.8849
        0.3105    0.3954    0.4803    0.5651    0.6500    0.7349    0.8197
        0.2454    0.3303    0.4151    0.5000    0.5849    0.6697    0.7546
        0.1803    0.2651    0.3500    0.4349    0.5197    0.6046    0.6895
        0.1151    0.2000    0.2849    0.3697    0.4546    0.5395    0.6244
        0.0500    0.1349    0.2197    0.3046    0.3895    0.4744    0.5592];


  yy = [0.0500    0.0889    0.1830    0.2874    0.3277    0.2713    0.1836
        0.2217    0.3411    0.5152    0.6859    0.7424    0.6057    0.3570
        0.3070    0.4266    0.5933    0.8025    0.9500    0.8281    0.4991
        0.2851    0.3223    0.3595    0.3967    0.8882    0.8573    0.5445
        0.3336    0.3708    0.4080    0.4452    0.7647    0.7722    0.5258
        0.3821    0.4193    0.4565    0.4937    0.6837    0.6839    0.5174
        0.4306    0.4678    0.5050    0.5422    0.6497    0.6501    0.5641];


  zz = [-0.2047   -0.2696   -0.3019   -0.3281   -0.3922   -0.5134   -0.6531
        -0.2179   -0.2352   -0.2203   -0.2074   -0.2619   -0.4304   -0.6652
        -0.2820   -0.2992   -0.2887   -0.2530   -0.2538   -0.4137   -0.6958
        -0.4094   -0.4753   -0.5412   -0.6071   -0.4048   -0.5109   -0.7835
        -0.4953   -0.5612   -0.6271   -0.6930   -0.5923   -0.6757   -0.9091
        -0.5812   -0.6471   -0.7130   -0.7789   -0.7546   -0.8423   -1.0285
        -0.6671   -0.7330   -0.7989   -0.8648   -0.8892   -0.9768   -1.1154];

  zz = zz - min(zz(:)) + .1;
    
  xx = (xx - .5)*.5 + .5;
  yy = (yy - .5)*.5 + .5;
 
  handles = surface('XData', xx, 'YData', yy, 'ZData', zz, ...
    'FaceColor', 'none', 'EdgeColor', 'k');

elseif (strcmp(action, 'omega'))
  handles = text('String','W','Position',[.5 .5],'Color','k', ...
   'Horiz','center','Vertical','middle','FontName','Symbol','FontWeight','bold', ...
   'FontSize',15);

elseif (strcmp(action, 'pause'))
  xx=[0.45 0.55 0.55 0.45 0.45];
  yy=[0.2  0.2  0.7  0.7  0.2];
  h1 = patch(xx,yy,'k');
  h2 = patch(xx+0.2,yy,'k');
  handles=[h1 h2];

elseif (strcmp(action, 'pixel'))
  
  handles = text('String', 'pixel', ...
      'Position', [.5 .5], ...
      'Color', 'k', ...
      'FontSize', 9, ...
      'Horiz', 'center', ...
      'Vert', 'middle');

elseif (strcmp(action, 'play'))
  xx=[0.4 0.8  0.4 0.4];
  yy=[0.2 0.45 0.7 0.2];
  handles = patch(xx,yy,'k');

elseif (strcmp(action, 'polyfill'))

  x = [.5 .2 .6 .7 .3 .5];
  y = [.5 .8 .7 .4 .15 .5];
  z = [1 1 1 1 1 1];
  handles = patch(x,y,z,[0.7 0.7 0.7]);

elseif (strcmp(action, 'polygon'))

  x = [.5 .2 .6 .7 .3 .5];
  y = [.5 .8 .7 .4 .15 .5];
  z = [1 1 1 1 1 1];
  handles = line(x,y,z,'Color','k');

elseif (strcmp(action, 'polyline'))

  x = [.5 .2 .6 .7 .3];
  y = [.5 .8 .7 .4 .15];
  z = [1 1 1 1 1];
  handles = line(x,y,z,'Color','k');

elseif (strcmp(action, 'record'))
  arc=0:0.05:2*pi;
  xx=0.6+0.2*cos(arc);
  yy=0.4+0.3*sin(arc);
  handles=patch(xx,yy,'k');
  
elseif (strcmp(action, 'rect'))
  handles = line([.2 .8 .8 .2 .2], [.2 .2 .8 .8 .2], ...
    ones(1,5), 'Color', 'k') ;
 
elseif (strcmp(action, 'rectc'))
  handles = [line([.2 .8 .8 .2 .2], [.2 .2 .8 .8 .2], ...
    ones(1,5), 'Color', 'k') ;
    line(.5,.5,1,'Marker','+','Color','k')];
 
elseif (strcmp(action, 'select'))

  x = [.3 .3 .65 .48 .65 .55 .4 .3];
  y = [.4 .9 .5 .52 .1 .1 .5 .4];
  z = ones(1,8);
  handles = patch(x,y,z,'FaceColor','k');

elseif (strcmp(action, 'spline'))
  v = -.1:.1:4;
  handles = line(.35*sin(v)+.5,.3*cos(v)+.5+0.05*sin(3*v),'Color','k'); 

elseif (strcmp(action, 'stop'))
  xx=[0.5 0.8 0.8 0.5];
  yy=[0.2 0.2 0.7 0.7];
  handles = patch(xx,yy,'k');
    
elseif (strcmp(action, 'triangle'))
   handles = line([.1 .9 .5 .1],[.2 .2 .9 .2],'Color','k');
      
elseif (strcmp(action, 'triangle2'))
   handles = line([.1 .9 .5 .1 NaN .5 .3 .7 .5], ...
                  [.2 .2 .9 .2 NaN .2 .55 .55 .2],'Color','k');
      
elseif (strcmp(action,'text')),
  handles = text('String'             ,'A'     , ...
                 'Position'           ,[.5 .5] , ...
                 'Color'              ,'k'     , ...
                 'HorizontalAlignment','center', ...
                 'VerticalAlignment'  ,'middle', ...
                 'FontName'           ,'Symbol', ...
                 'FontWeight'         ,'bold'  , ...
                 'FontSize'           ,15        ...
                 );
 
elseif (strcmp(action, 'uparrow'))
  handles(1) = patch([0.45 0.55 0.55 0.45],[0.8  0.8  0.2  0.2 ],'k');
  handles(2) = patch([0.3 0.7 0.5],[0.7 0.7 0.8],'k');

elseif (strcmp(action, 'zoom'))

  x1 = [ 0.0917    0.1250    0.1583    0.1917    0.2250    0.2917    0.3583, ...
      0.4250    0.4583    0.4917    0.5250    0.5250    0.5583    0.5917, ...
      0.6250    0.6583    0.6917    0.7250    0.7583    0.7917    0.8250, ...
      0.8917    0.9250    0.9250    0.8917    0.8583    0.8250    0.7917, ...
      0.7583    0.7250    0.6917    0.6583    0.6250    0.5583    0.5250, ...
      0.5583    0.5917    0.5917    0.5917    0.5917    0.5583    0.5250, ...
      0.4917    0.4583    0.4250    0.3583    0.2917    0.2250    0.1917, ...
      0.1583    0.1250    0.0917    0.0583    0.0583    0.0583    0.0583, ...
      0.0917    0.1250    0.1250    0.1250    0.1250    0.1583    0.1917, ...
      0.2250    0.2917    0.3583    0.4250    0.4583    0.4917    0.5250, ...
      0.5250    0.5250    0.5250    0.4917    0.4583    0.4250    0.3583, ...
      0.2917    0.2250    0.1917    0.1583    0.1583    0.1250];
  
  y1 = [0.5417    0.5083    0.4750    0.4417    0.4083    0.4083    0.4083, ...
      0.4083    0.4417    0.4750    0.4417    0.3750    0.3417    0.3083, ...
      0.2750    0.2417    0.2083    0.1750    0.1417    0.1083    0.0750, ... 
      0.0750    0.1083    0.1750    0.2083    0.2417    0.2750    0.3083, ...
      0.3417    0.3750    0.4083    0.4417    0.4750    0.4750    0.5083, ...
      0.5417    0.5750    0.6417    0.7083    0.7750    0.8083    0.8417, ...
      0.8750    0.9083    0.9417    0.9417    0.9417    0.9417    0.9083, ...
      0.8750    0.8417    0.8083    0.7750    0.7083    0.6417    0.5750, ...
      0.5417    0.5750    0.6417    0.7083    0.7750    0.8083    0.8417, ...
      0.8750    0.8750    0.8750    0.8750    0.8417    0.8083    0.7750, ...
      0.7083    0.6417    0.5750    0.5417    0.5083    0.4750    0.4750, ...
      0.4750    0.4750    0.5083    0.5417    0.5417    0.5750];
  
  x2 = [0.2917    0.3583    0.3917    0.3917    0.3583    0.2917    0.2583, ...
      0.2583    0.2917];
  
  y2 = [0.6083    0.6083    0.6417    0.7083    0.7417    0.7417    0.7083, ...
      0.6417    0.6083];
  
  patch1 = patch('XData', x1, 'YData', y1, 'ZData', ones(size(x1)), ...
      'EdgeColor', 'none', 'FaceColor', 'k');
  
  patch2 = patch('XData', x2, 'YData', y2, 'ZData', ones(size(x2)), ...
      'EdgeColor', 'none', 'FaceColor', 'k');
  
  handles = [patch1 patch2]';

else
  handles = text('String','???','Position',[.5 .5],'Color','k', ...
   'Horiz','center','Vertical','middle');
  
end

% end btnicon
