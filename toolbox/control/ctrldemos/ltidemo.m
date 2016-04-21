function txt = ltidemo(topic,slide)
%LTIDEMO  Getting started with LTI models (demo)

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 06:40:55 $

topiclist = {
   'Creating Models'
   'Discrete-Time Models'
   'Accessing Model Data'
   'Connecting Models'
   'Model Type Conversions'
   'Continuous/Discrete Conversions'
};

if nargin==0
   % Initialization
   topicshow(topiclist,1,mfilename);
else
   set(gcf,'Name',sprintf('Getting Started: %s',topiclist{topic}));
   switch topic
   case 1
      txt = localCreatingModels(slide,gca);
   case 2
      txt = localDiscreteTimeModels(slide,gca);
   case 3
      txt = localAccessingModelData(slide,gca);
   case 4
      txt = localConnectingModels(slide,gca);
   case 5
      txt = localModelTypeConversions(slide,gca);
   case 6
      txt = localContinuousDiscreteConversions(slide,gca);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%
% localCreatingModels %
%%%%%%%%%%%%%%%%%%%%%%%
function txt = localCreatingModels(slide,ax)
 %---Slideshow for Connecting Models
  if slide<1
     txt = 10; % number of slides
     return
  end
  localClearAxes(ax);
  p = localParameters;
 %---Slides
  switch slide
  case 1
     set(ax,'XLim',[0 10],'YLim',[0 11],'Position',p.axpos2,'Visible','off');
     text('Parent',ax,'String','Creating LTI Models','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localMatrix(ax)
     txt = {
        ' The Control System Toolbox provides commands for creating 4 basic types of linear'
        ' time-invariant (LTI) models:'
        ' '
        '    \bullet transfer function models ({\bfTF})'
        '    \bullet zero-pole-gain models ({\bfZPK})'
        '    \bullet state-space models ({\bfSS})'
        '    \bullet frequency response data models ({\bfFRD})'
        ' '
        ' These functions take model data as input and return objects which embody this'
        ' data in a single MATLAB variable.'
     };
  case 2
     text('Parent',ax,'String','Transfer Function Models:','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,1)
     equation('Par',ax,'Pos',[1.5 7],'Name','H(s)',...
        'Num','p_{1} s^{n} + p_{2} s^{n-1} + \ldots + p_{n+1}',...
        'Den','q_{1} s^{m} + q_{2} s^{m-1} + \ldots + q_{m+1}',...
        'Anchor','left','FontSize',p.fs3);
     str = {
        'where:_{ }'
        '   \bullet {\itp_{1}} \ldots {\itp_{n+1}} are the numerator coefficients_{ }'
        '   \bullet {\itq_{1}} \ldots {\itq_{m+1}} are the denominator coefficients_{ }'
     };
     text('Parent',ax,'String',str,'Position',[1.5 3.5],'FontSize',p.fs3,'Hor','left','Ver','middle');
     txt = {
        ' A transfer function model is defined by its numerator and denominator polynomials.'
        ' '
        ' Polynomials are specified by a vector of their coefficients.  For example:'
        ' '
        '     [ 1  2  10 ]'
        ' '
        ' would specify the polynomial:'
        ' '
        '     s^{2} + 2 s + 10'
     };
  case 3
     text('Parent',ax,'String','Transfer Function Models:  (example)','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,1)
     equation('Par',ax,'Pos',[1.5 7],'Name','H(s)','Num','s','Den','s^2 + 2 s + 10',...
        'Anchor','left','FontSize',p.fs3);
     txt = {
        ' You can create a SISO transfer function model by specifying its numerator and'
        ' denominator polynomials as inputs to the TF command:'
        ' '
        '   >> num = [ 1  0 ];          % Numerator: s'
        '   >> den = [ 1  2  10 ];     % Denominator: s^2 + 2 s + 10'
        '   >> H = tf(num,den);'
        ' '
        ' You can also specify this model as a rational expression of s:'
        ' '
        '   >> s = tf(''s'');                          % Create Laplace variable'
        '   >> H = s / (s\^2 + 2*s + 10);'
     };

  case 4
     text('Parent',ax,'String','Zero-Pole-Gain Models:','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,2)
     equation('Par',ax,'Pos',[1.5 7],'Name','H(s)','Gain','k',...
        'Num','( s - z_{1} ) \ldots ( s - z_{n} )','Den','( s - p_{1} ) \ldots ( s - p_{m} )',...
        'Anchor','left','FontSize',p.fs3);
     str = {
        'where:_{ }'
        '   \bullet {\itk_{ }} is the gain'
        '   \bullet {\itz_{1}} \ldots {\itz_{n}} are the zeros of H(s)'
        '   \bullet {\itp_{1}} \ldots {\itp_{m}} are the poles of H(s)'
     };
     text('Parent',ax,'String',str,'Position',[1.5 3.4],'FontSize',p.fs3,'Hor','left','Ver','middle');
     txt = {
        ' Zero-pole-gain models are the factored form of transfer function models.'
        ' '
        ' In this format, a model is characterized by its gain k, zeros z (numerator roots),'
        ' and poles p (denominator roots).'
     };
  case 5
     text('Parent',ax,'String','Zero-Pole-Gain Models:  (example)','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,2)
     equation('Par',ax,'Pos',[1.5 7],'Name','H(s)','Num','s','Den','( s - 2 ) ( s^2 - 2 s + 2 )',...
        'Gain','-2','Anchor','left','FontSize',p.fs3);
     txt = {
        ' You can specify a SISO zero-pole-gain model using the ZPK command:'
        ' '
        '   >> z = 0;                        % Zeros'
        '   >> p = [ 2  1+i  1-i ];       % Poles'
        '   >> k = -2;                      % Gain'
        '   >> H = zpk(z,p,k);'
        ' '
        ' You can also specify this model as a rational expression of s:'
        ' '
        '   >> s = zpk(''s'');'
        '   >> H = -2*s / (s - 2) / (s\^2 - 2*s + 2);'
     };
  case 6
     text('Parent',ax,'String','State-Space Models:','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,3)
     equation('Par',ax,'Pos',[1.8 7.5],'Name',' ','Num','A x + B u','Anchor','left','FontSize',p.fs3);
     equation('Par',ax,'Pos',[1.8 7.5],'Num','dx','Den','dt','Anchor','right','FontSize',p.fs3);
     equation('Par',ax,'Pos',[1.8 6.0],'Name',' ','Num','C x + D u','Anchor','left','FontSize',p.fs3);
     equation('Par',ax,'Pos',[1.8 6.0],'Num','y','Anchor','right','FontSize',p.fs3);
     str = {
        'where:_{ }'
        '   \bullet {\itx} is the state vector_{ }'
        '   \bullet {\itu} and {\ity} are the input and output vectors_{ }'
        '   \bullet {\itA}, {\itB}, {\itC}, {\itD} are the state-space matrices_{ }'
     };
     text('Parent',ax,'String',str,'Position',[1.5 4.8],'FontSize',p.fs3,'Hor','left','Ver','top');
     txt = {
        ' State-space models are constructed from the linear differential or difference'
        ' equations describing the system dynamics.'
        ' '
        ' The state-space matrices A, B, C, and D are used to characterize these models.'
     };
  case 7
     text('Parent',ax,'String','State-Space Models:  (example)','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,3)
     text('Parent',ax,'String','A simple electric motor:',...
        'Position',[1.5 8],'FontSize',p.fs3,'Hor','left','Ver','middle');
     equation('Par',ax,'Pos',[2 6],'Num','d^{ 2} \theta','Den','dt^{ 2}','Anchor','center','FontSize',p.fs3);
     text('Parent',ax,'Position',[2.7 6],'String',' + ','FontSize',p.fs3,'Hor','center','Ver','middle');
     equation('Par',ax,'Pos',[3.4 6],'Num','d\theta','Den','dt','Gain','2','Anchor','center','FontSize',p.fs3);
     text('Parent',ax,'Position',[4.1 6],'String',' + ','FontSize',p.fs3,'Hor','center','Ver','middle');
     equation('Par',ax,'Pos',[4.6 6],'Num','5 \theta','Den','','Anchor','center','FontSize',p.fs3);
     text('Parent',ax,'Position',[5.1 6],'String',' = ','FontSize',p.fs3,'Hor','center','Ver','middle');
     equation('Par',ax,'Pos',[5.6 6],'Num','3 {\fontname{FixedWidth}I}','Anchor','center','FontSize',p.fs3);
     str = {
        'where:_{ }'
        '   \bullet {\fontname{FixedWidth}I} is the driving current (input, u)_{ }'
        '   \bullet \theta is the angular displacement of the rotor (output, y)_{ }'
     };
     text('Parent',ax,'String',str,'Position',[1.5 4],'FontSize',p.fs3,'Hor','left','Ver','top');
     txt = {
        ' For example, assume you are given the differential equation for an electric motor'
        ' and you want to construct a state-space model which describes the relationship'
        ' between the driving current (input) and the angular displacement of the rotor (output).'
     };
  case 8
     text('Parent',ax,'String','State-Space Models:  (example)','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,3)
     text('Parent',ax,'String','State-space equations for a simple electric motor:',...
        'Position',[1.3 8],'FontSize',p.fs2,'Hor','left','Ver','middle');
     y1 = 5.8;
     y2 = 2.8;
     x1 = 9-.2;
     x2 = 5.5-.2;
     x3 = 7.4-.2;
     x4 = x2;
     x5 = x3;
     dy = 0.6;
     dx = 0.28;
     CC = [.8 0 0];
     equation('Par',ax,'Pos',[2-.2 y1],'Name',' ','Num','A x + B {\fontname{FixedWidth}I}','Anchor','left','FontSize',p.fs2);
     equation('Par',ax,'Pos',[2-.2 y1],'Num','dx','Den','dt','Anchor','right','FontSize',p.fs2);
     equation('Par',ax,'Pos',[2-.2 y2],'Name',' ','Num','C x + D {\fontname{FixedWidth}I}','Anchor','left','FontSize',p.fs2);
     equation('Par',ax,'Pos',[2-.2 y2],'Num','\theta','Anchor','right','FontSize',p.fs2);
     text('Parent',ax,'Position',[x2-2.5*dx y1],'String','A = ','FontSize',p.fs2,'Hor','right','Ver','middle','Color',CC);
     equation('Par',ax,'Pos',[x2-dx y1+dy],'Num','0','Anchor','center','FontSize',p.fs2,'Color',CC);
     equation('Par',ax,'Pos',[x2+dx y1+dy],'Num','1','Anchor','center','FontSize',p.fs2,'Color',CC);
     equation('Par',ax,'Pos',[x2-dx y1-dy],'Num','-5','Anchor','center','FontSize',p.fs2,'Color',CC);
     equation('Par',ax,'Pos',[x2+dx y1-dy],'Num','-2','Anchor','center','FontSize',p.fs2,'Color',CC);
     line('Parent',ax,'XData',[x2-2*dx+dx/4 x2-2*dx x2-2*dx x2-2*dx+dx/4 NaN x2+2*dx-dx/4 x2+2*dx x2+2*dx x2+2*dx-dx/4],...
                      'YData',[y1+2*dy y1+2*dy y1-2*dy y1-2*dy NaN y1+2*dy y1+2*dy y1-2*dy y1-2*dy],'Color',CC);
     text('Parent',ax,'Position',[x3-1.5*dx y1],'String','B = ','FontSize',p.fs2,'Hor','right','Ver','middle','Color',CC);
     equation('Par',ax,'Pos',[x3 y1+dy],'Num','0','Anchor','center','FontSize',p.fs2,'Color',CC);
     equation('Par',ax,'Pos',[x3 y1-dy],'Num','3','Anchor','center','FontSize',p.fs2,'Color',CC);
     line('Parent',ax,'XData',[x3-1*dx+dx/4 x3-1*dx x3-1*dx x3-1*dx+dx/4 NaN x3+1*dx-dx/4 x3+1*dx x3+1*dx x3+1*dx-dx/4],...
                      'YData',[y1+2*dy y1+2*dy y1-2*dy y1-2*dy NaN y1+2*dy y1+2*dy y1-2*dy y1-2*dy],'Color',CC);
     text('Parent',ax,'Position',[x4-2.5*dx y2],'String','C = ','FontSize',p.fs2,'Hor','right','Ver','middle','Color',CC);
     equation('Par',ax,'Pos',[x4-dx y2],'Num','1','Anchor','center','FontSize',p.fs2,'Color',CC);
     equation('Par',ax,'Pos',[x4+dx y2],'Num','0','Anchor','center','FontSize',p.fs2,'Color',CC);
     line('Parent',ax,'XData',[x4-2*dx+dx/4 x4-2*dx x4-2*dx x4-2*dx+dx/4 NaN x4+2*dx-dx/4 x4+2*dx x4+2*dx x4+2*dx-dx/4],...
                      'YData',[y2+1*dy y2+1*dy y2-1*dy y2-1*dy NaN y2+1*dy y2+1*dy y2-1*dy y2-1*dy],'Color',CC);
     text('Parent',ax,'Position',[x5-1.5*dx y2],'String','D = ','FontSize',p.fs2,'Hor','right','Ver','middle','Color',CC);
     equation('Par',ax,'Pos',[x5 y2],'Num','0','Anchor','center','FontSize',p.fs2,'Color',CC);
     line('Parent',ax,'XData',[x5-1*dx+dx/4 x5-1*dx x5-1*dx x5-1*dx+dx/4 NaN x5+1*dx-dx/4 x5+1*dx x5+1*dx x5+1*dx-dx/4],...
                      'YData',[y2+1*dy y2+1*dy y2-1*dy y2-1*dy NaN y2+1*dy y2+1*dy y2-1*dy y2-1*dy],'Color',CC);
     text('Parent',ax,'Position',[x1-1.5*dx y1],'String','x = ','FontSize',p.fs2,'Hor','right','Ver','middle');
     equation('Par',ax,'Pos',[x1 y1+dy],'Num','\theta','Anchor','center','FontSize',p.fs2);
     equation('Par',ax,'Pos',[x1 y1-1.5*dy],'Num','d\theta','Den','dt','Anchor','center','FontSize',p.fs2);
     line('Parent',ax,'XData',[x1-1*dx+dx/4 x1-1*dx x1-1*dx x1-1*dx+dx/4 NaN x1+1*dx-dx/4 x1+1*dx x1+1*dx x1+1*dx-dx/4],...
                      'YData',[y1+2*dy y1+2*dy y1-3*dy y1-3*dy NaN y1+2*dy y1+2*dy y1-3*dy y1-3*dy]);
     txt = {
        ' Using the relations above, you can represent this differential equation in'
        ' state-space form.'
        ' '
        ' You can create the state-space model of this example in MATLAB using the'
        ' SS command:'
        ' '
        '   >> A = [ 0  1 ; -5  -2 ];'
        '   >> B = [ 0 ; 3 ];'
        '   >> C = [ 1  0 ];'
        '   >> D = 0;'
        '   >> H = ss(A,B,C,D);'
     };
  case 9
     text('Parent',ax,'String','Frequency Response Data Models:','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,4)
     sysblock('Par',ax,'Pos',[4 3.6 2 2.8],'Name','H(\omega)','FaceColor',p.cc4,'FontSize',p.fs3,'FontWeight',p.fw1);
     wire('Par',ax,'XData',[3 4],'YData',[5 5],'Arrow',.4);
     wire('Par',ax,'XData',[6 7],'YData',[5 5],'Arrow',.4);
     text('Parent',ax,'Pos',[3 4.8],'String','sin( \omega_{i} t )  ','Hor','right','FontSize',p.fs3,'FontWeight',p.fw1);
     text('Parent',ax,'Pos',[7 4.8],'String','  y_{i} ( t )','Hor','left','FontSize',p.fs3,'FontWeight',p.fw1);
     txt = {
        ' Frequency response data ({\bfFRD}) models allow you to store the measured or'
        ' simulated complex frequency response of a system in an LTI object which may'
        ' be analyzed using the Control System Toolbox.'
        ' '
        ' Given a vector of frequencies and a vector of system responses to excitation'
        ' at these frequencies, you can construct an {\bfFRD} model with this data using:'
        ' '
        '   >> H = frd(response,frequencies)'
     };
  case 10
     text('Parent',ax,'String','Frequency Response Data Models:  (example)','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,4)
     str = {
        '>> H = frd(resp,freq,''Units'',''Hz'')'
        '                                '
        'From input 1 to:                '
        '                                '
        '  Frequency(Hz)      output 1   '
        '  -------------      --------   '
        '       1000      -0.8126-0.0003i'
        '       2000      -0.1751-0.0016i'
        '       3000      -0.0926-0.4630i'
     };
     text('Parent',ax,'String',str,'Pos',[1.9 8.2],'Color',[0 0 .8],...
        'Hor','left','Ver','top','FontSize',p.fs3,'FontName','FixedWidth');
     txt = {
        ' For example, given the experimental data points:'
        ' '
        '   >> freq = [1000 ; 2000 ; 3000];  % measured in Hz'
        '   >> resp = [-0.8126-0.0003i ; -0.1751-0.0016i ; -0.0926-0.4630i];'
        ' '
        ' You can construct an {\bfFRD} model with this data using:'
        ' '
        '   >> H = frd(resp,freq,''Units'',''Hz'');'
        ' '
        ' The last 2 arguments in this example are used to indicate that the'
        ' frequency units are in Hertz.  The MATLAB output is shown above.'
     };
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localDiscreteTimeModels %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function txt = localDiscreteTimeModels(slide,ax)
 %---Slideshow for Connecting Models
  if slide<1
     txt = 2; % number of slides
     return
  end
  localClearAxes(ax);
  p = localParameters;
 %---Slides
  switch slide
  case 1
     set(ax,'XLim',[0 10],'YLim',[0 11],'Position',p.axpos2,'Visible','off');
     text('Parent',ax,'String','Discrete-Time LTI Models','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     x11 = 1.5; x12 = 4.0;
     x21 = 6.0; x22 = 8.5;
     y11 = 2.2; y12 = 7.2;
     sysblock('Par',ax,'Pos',[x11 y11 x12-x11 y12-y11],'Name','continuous time','Num',' ',...
        'FaceColor',p.cc3,'FontSize',p.fs2,'FontWeight',p.fw1);
     sysblock('Par',ax,'Pos',[x21 y11 x22-x21 y12-y11],'Name','discrete time','Num',' ',...
        'FaceColor',p.cc2,'FontSize',p.fs2,'FontWeight',p.fw1);
     xd = x11+.15:.05:x12-.15;
     yd = (y11+y12)/2+1.4*sin(2*xd+1.3);
     [xds,yds]=stairs(xd(1:3:end)+x21-x11,yd(1:3:end));
     wire('Par',ax,'XData',xd,'YData',yd,'Color','r');
     wire('Par',ax,'XData',xds,'YData',yds,'Color','b');
     t = 0:2*pi/128:2*pi;
     x = (x21+x22)/2 + (x22-x21)/1.18*sin(t);
     y = (y11+y12)/2 + (y12-y11)/1.28*cos(t);
     wire('Par',ax,'XData',x,'YData',y,'Color',[.8 .2 .2]);
     txt = {
        ' The Control System Toolbox supports the use of both continuous-time and'
        ' discrete-time models.'
        ' '
        ' The syntax for the creation of a discrete-time model is similar to that for a'
        ' continuous-time model, except that you must also provide a sampling time.'
     };
  case 2
     text('Parent',ax,'String','Discrete-Time Models:  (transfer function example)','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     localMatrix(ax,1)
     equation('Par',ax,'Pos',[1.5 7],'Name','H(z)','Num','z - 1','Den','z^2 - 1.85 z + 0.9','Anchor','left','FontSize',p.fs3);
     equation('Par',ax,'Pos',[1.5 4.2],'Name','Sample Time','Num','0.1 sec','Anchor','left','FontSize',p.fs3);
     txt = {
        ' You can specify a discrete-time transfer function model by providing a'
        ' sample time argument to the TF command:'
        ' '
        '   >> num = [ 1  -1 ];'
        '   >> den = [ 1  -1.85  0.9 ];'
        '   >> H = tf(num,den,0.1);                       % Ts = 0.1 sec'
        ' '
        ' You can also specify this model as a rational expression of z:'
        ' '
        '   >> z = tf(''z'',0.1);                                  % Ts = 0.1 sec'
        '   >> H = (z - 1) / (z\^2 - 1.85*z + 0.9);'
     };
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localAccessingModelData %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function txt = localAccessingModelData(slide,ax)
 %---Slideshow for Connecting Models
  if slide<1
     txt = 5; % number of slides
     return
  end
  localClearAxes(ax);
  p = localParameters;
 %---Slides
  switch slide
  case 1
     set(ax,'XLim',[-6 16],'YLim',[0 11],'Position',p.axpos2,'Visible','off');
     text('Parent',ax,'String','Accessing Model Data','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     bw = 4;
     bw2 = 2.8;
     bh = 1.6;
     bh2 = 1.3;
     pos = [5 5];
     dx = 2;
     dy = 0.5;
     y1 = pos(2)+1.5*dy+1.5*bh;
     y2 = pos(2)+.5*dy+0.5*bh;
     y3 = pos(2)-.5*dy-0.5*bh;
     y4 = pos(2)-1.5*dy-1.5*bh;
     sysblock('Par',ax,'Pos',[.5 2 9 6],'Numerator',' ','Name','LTI Model Object',...
        'FaceColor',[.9 .9 .9],'FontSize',p.fs2,'FontWeight',p.fw2);
     text('Parent',ax,'String','... I/O Names ...','Position',[3 7],...
        'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','middle');
     text('Parent',ax,'String','... Coefficients ...','Position',[5 5],...
        'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','middle');
     text('Parent',ax,'String','... UserData ...','Position',[7.4 6.5],...
        'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','middle');
     text('Parent',ax,'String','... Sample Time ...','Position',[2.6 3.5],...
        'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','middle');
     text('Parent',ax,'String','... I/O Delays ...','Position',[7 3],...
        'Color',[.8 0 0],'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','middle');
     txt = {
        ' LTI model objects store data in a single MATLAB variable.  This data includes the'
        ' the model coefficients (i.e., A,B,C,D matrices of state-space models) as well as'
        ' other information related to the model, such as its sample time or the names of'
        ' its inputs and outputs.'
        ' '
        ' You have several ways of accessing this data:'
        ' '
        '    \bullet The SET / GET commands'
        '    \bullet Direct structure referencing'
        '    \bullet Data retrieval commands'
     };
  case 2
     text('Parent',ax,'String','Accessing Model Data with SET / GET','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     bw1 = 5.8;
     bh1 = 2.8;
     bw2 = 4.4;
     bh2 = 1.4;
     x1 = -1.9;
     x2 = 2.3;
     x3 = 6.7;
     x4 = 10.9;
     y1 = 7;
     y2 = 4;
     y3 = 1.9;
     sysblock('Par',ax,'Pos',[x1-bw1/2 y1-bh1/2 bw1 bh1],'Num','2 ( s + 2 )',...
        'Den','( s - 1 ) ( s - 5 )','FaceColor',p.cc2,'FontSize',p.fs2,'FontWeight',p.fw2);
     sysblock('Par',ax,'Pos',[x3-bw1/2 y1-bh1/2 bw1 bh1],'Num','7 ( s + 2 )',...
        'Den','( s - 1 ) ( s - 5 )','FaceColor',p.cc2,'FontSize',p.fs2,'FontWeight',p.fw2);
     sysblock('Par',ax,'Pos',[x2-bw2/2 y2-bh2/2 bw2 bh2],'Num','>> set(sys,''k'',7)',...
        'FaceColor',p.cc1,'FontSize',p.fs1,'FontWeight',p.fw2,'Curvature',[.5 1]);
     sysblock('Par',ax,'Pos',[x4-bw2/2 y2-bh2/2 bw2 bh2],'Num','>> get(sys,''k'')',...
        'FaceColor',p.cc1,'FontSize',p.fs1,'FontWeight',p.fw2,'Curvature',[.5 1]);
     wire('Par',ax,'XData',[x1 x1 x2-bw2/2],'YData',[y1-bh1/2 y2 y2],'Arrow',.5)
     wire('Par',ax,'XData',[x2+bw2/2 x3-bw1/6 x3-bw1/6],'YData',[y2 y2 y1-bh1/2],'Arrow',.5)
     wire('Par',ax,'XData',[x3+bw1/6 x3+bw1/6 x4-bw2/2],'YData',[y1-bh1/2 y2 y2],'Arrow',.5)
     wire('Par',ax,'XData',x4+bw2/2+[0 1],'YData',[y2 y2],'Arrow',.5)
     text('Parent',ax,'String','  7','Position',[x4+bw2/2+1 y2],...
        'Color',[.8 0 0],'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     txt = {
        ' You can use the SET command to modify model data:'
        ' '
        '   >> set(sys,PropertyName,PropertyValue)'
        ' '
        ' Conversely, you can use the GET command to retrieve model data:'
        ' '
        '   >> PropertyValue = get(sys,PropertyName)'
        ' '
        ' The illustration above shows how to use SET and GET to modify and'
        ' retrieve the gain value of a zero-pole-gain model.'
     };
  case 3
     text('Parent',ax,'String','Direct Structure Referencing','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     bw1 = 5.8;
     bh1 = 2.8;
     bw2 = 4.4;
     bh2 = 1.4;
     x1 = -1.9;
     x2 = 2.3;
     x3 = 6.7;
     x4 = 10.9;
     y1 = 7;
     y2 = 4;
     y3 = 1.9;
     GRAY = [.45 .45 .45];
     sysblock('Par',ax,'Pos',[x1-bw1/2 y1-bh1/2 bw1 bh1],'Num','2 ( s + 2 )',...
        'Den','( s - 1 ) ( s - 5 )','FaceColor',p.cc2,'FontSize',p.fs2,'FontWeight',p.fw2);
     sysblock('Par',ax,'Pos',[x3-bw1/2 y1-bh1/2 bw1 bh1],'Num','7 ( s + 2 )',...
        'Den','( s - 1 ) ( s - 5 )','FaceColor',p.cc2,'FontSize',p.fs2,'FontWeight',p.fw2);
     sysblock('Par',ax,'Pos',[x2-bw2/2 y2-bh2/2 bw2 bh2],'Num','>> set(sys,''k'',7)',...
        'FaceColor',p.cc1,'FontSize',p.fs1,'FontWeight',p.fw2,'Curvature',[.5 1],'EdgeColor',GRAY);
     sysblock('Par',ax,'Pos',[x4-bw2/2 y2-bh2/2 bw2 bh2],'Num','>> get(sys,''k'')',...
        'FaceColor',p.cc1,'FontSize',p.fs1,'FontWeight',p.fw2,'Curvature',[.5 1],'EdgeColor',GRAY);
     sysblock('Par',ax,'Pos',[x2-bw2/2 y3-bh2/2 bw2 bh2],'Num','>> sys.k = 7',...
        'FaceColor',p.cc1,'FontSize',p.fs1,'FontWeight',p.fw2,'Curvature',[.5 1]);
     sysblock('Par',ax,'Pos',[x4-bw2/2 y3-bh2/2 bw2 bh2],'Num','>> sys.k',...
        'FaceColor',p.cc1,'FontSize',p.fs1,'FontWeight',p.fw2,'Curvature',[.5 1]);
     wire('Par',ax,'XData',[x1 x2-bw2/2],'YData',[y2 y2],'Arrow',.5,'Color',GRAY)
     wire('Par',ax,'XData',[x2+bw2/2 x3-bw1/6],'YData',[y2 y2],'Arrow',0,'Color',GRAY)
     wire('Par',ax,'XData',[x3+bw1/6 x4-bw2/2],'YData',[y2 y2],'Arrow',.5,'Color',GRAY)
     wire('Par',ax,'XData',x4+bw2/2+[0 1],'YData',[y2 y2],'Arrow',.5,'Color',GRAY)
     text('Parent',ax,'String','  7','Position',[x4+bw2/2+1 y2],...
        'Color',[.8 0 0],'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     wire('Par',ax,'XData',[x1 x1 x2-bw2/2],'YData',[y1-bh1/2 y3 y3],'Arrow',.5)
     wire('Par',ax,'XData',[x2+bw2/2 x3-bw1/6 x3-bw1/6],'YData',[y3 y3 y1-bh1/2],'Arrow',.5)
     wire('Par',ax,'XData',[x3+bw1/6 x3+bw1/6 x4-bw2/2],'YData',[y1-bh1/2 y3 y3],'Arrow',.5)
     wire('Par',ax,'XData',x4+bw2/2+[0 1],'YData',[y3 y3],'Arrow',.5)
     text('Parent',ax,'String','  7','Position',[x4+bw2/2+1 y3],...
        'Color',[.8 0 0],'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     txt = {
        ' You can also modify and retrieve model data directly by structure referencing:'
        ' '
        '   >> sys.PropertyName = PropertyValue         % equivalent to SET'
        '   >> PropertyValue = sys.PropertyName         % equivalent to GET'
        ' '
        ' The illustration above shows how this technique parallels the use of the'
        ' SET and GET commands.'
     };
  case {4,5}
     text('Parent',ax,'String','Data Retrieval:  Quick Access','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     bw = 4;
     bw2 = 2.8;
     bh = 1.6;
     bh2 = 1.3;
     pos = [5 5];
     dx = 2;
     dy = 0.5;
     y1 = pos(2)+1.5*dy+1.5*bh;
     y2 = pos(2)+.5*dy+0.5*bh;
     y3 = pos(2)-.5*dy-0.5*bh;
     y4 = pos(2)-1.5*dy-1.5*bh;
     sysblock('Par',ax,'Pos',[pos(1)-bw/2-dx-bw2 y2-bh2/2 bw2 bh2],'Num','sys','Name','(TF/ZPK/SS)',...
        'NameFontSize',p.fs1,'NameFontWeight',p.fw1,'FaceColor',[.9 .9 .9],'FontSize',p.fs3,'FontWeight',p.fw3);
     sysblock('Par',ax,'Pos',[pos(1)-bw/2-dx-bw2 y4-bh2/2 bw2 bh2],'Num','sysfr','Name','(FRD)',...
        'NameFontSize',p.fs1,'NameFontWeight',p.fw1,'FaceColor',[.9 .9 .9],'FontSize',p.fs3,'FontWeight',p.fw3);
     sysblock('Par',ax,'Pos',[pos(1)-bw/2 y1-bh/2 bw bh],'Num','TFDATA',...
        'FaceColor',p.cc1,'FontSize',p.fs3,'FontWeight',p.fw3,'Curvature',[.5 1]);
     sysblock('Par',ax,'Pos',[pos(1)-bw/2 y2-bh/2 bw bh],'Num','ZPKDATA',...
        'FaceColor',p.cc2,'FontSize',p.fs3,'FontWeight',p.fw3,'Curvature',[.5 1]);
     sysblock('Par',ax,'Pos',[pos(1)-bw/2 y3-bh/2 bw bh],'Num','SSDATA',...
        'FaceColor',p.cc3,'FontSize',p.fs3,'FontWeight',p.fw3,'Curvature',[.5 1]);
     sysblock('Par',ax,'Pos',[pos(1)-bw/2 y4-bh/2 bw bh],'Num','FRDATA',...
        'FaceColor',p.cc4,'FontSize',p.fs3,'FontWeight',p.fw3,'Curvature',[.5 1]);
     wire('Par',ax,'XData',pos(1)-bw/2+[-dx 0],'YData',[y2 y2],'Arrow',.5)
     wire('Par',ax,'XData',pos(1)-bw/2+[-dx/2 -dx/2 0],'YData',[y2 y1 y1],'Arrow',.5)
     wire('Par',ax,'XData',pos(1)-bw/2+[-dx/2 -dx/2 0],'YData',[y2 y3 y3],'Arrow',.5)
     wire('Par',ax,'XData',pos(1)-bw/2+[-dx 0],'YData',[y4 y4],'Arrow',.5)
     wire('Par',ax,'XData',pos(1)+bw/2+[0 dx],'YData',[y1 y1],'Arrow',.5)
     wire('Par',ax,'XData',pos(1)+bw/2+[0 dx],'YData',[y2 y2],'Arrow',.5)
     wire('Par',ax,'XData',pos(1)+bw/2+[0 dx],'YData',[y3 y3],'Arrow',.5)
     wire('Par',ax,'XData',pos(1)+bw/2+[0 dx],'YData',[y4 y4],'Arrow',.5)
     t1=text('Parent',ax,'String',' [num,den,Ts]','Position',[pos(1)+bw/2+dx y1],...
        'FontSize',p.fs2,'FontWeight',p.fw1,'Hor','left','Ver','middle');
     t2=text('Parent',ax,'String',' [z,p,k,Ts]','Position',[pos(1)+bw/2+dx y2],...
        'FontSize',p.fs2,'FontWeight',p.fw1,'Hor','left','Ver','middle');
     text('Parent',ax,'String',' [a,b,c,d,Ts]','Position',[pos(1)+bw/2+dx y3],...
        'FontSize',p.fs2,'FontWeight',p.fw1,'Hor','left','Ver','middle');
     text('Parent',ax,'String',' [response,freq,Ts]','Position',[pos(1)+bw/2+dx y4],...
        'FontSize',p.fs2,'FontWeight',p.fw1,'Hor','left','Ver','middle');
     switch slide
     case 4
        txt = {
           ' You can quickly retrieve model data with the following commands:'
           ' '
           '   >> [num,den,Ts] = tfdata(sys)'
           '   >> [z,p,k,Ts] = zpkdata(sys)'
           '   >> [a,b,c,d,Ts] = ssdata(sys)'
           '   >> [response,freq,Ts] = frdata(sysfr)'
           ' '
           ' Note that the FRDATA command is specific to {\bfFRD} models, but that TFDATA,'
           ' ZPKDATA, and SSDATA may be used with any {\bfTF}, {\bfZPK}, or {\bfSS} model.'
        };
     case 5
        t1e = get(t1,'Extent');
        t2e = get(t2,'Extent');
        w = max(t1e(3),t2e(3));
        h = max(t1e(4),t2e(4));
        t = 0:2*pi/128:2*pi;
        x = t1e(1)+w/2 + w/1.3*sin(t);
        y1 = t1e(2)+h/2 + h*cos(t);
        y2 = t2e(2)+h/2 + h*cos(t);
        wire('Par',ax,'XData',[x NaN x],'YData',[y1 NaN y2],'Color',[.8 .2 .2]);
        txt = {
           ' The commands TFDATA and ZPKDATA return some of their data (num,den,z,p)'
           ' in cell arrays in order to facilitate data retrieval of MIMO models and model arrays.'
           ' '
           ' For a single SISO model, you can use a second input argument ''v'' to specify'
           ' that these commands return data in vectors rather than cell arrays:'
           ' '
           '   >> [num,den,Ts] = tfdata(sys,''v'')'
           '   >> [z,p,k,Ts] = zpkdata(sys,''v'')'
        };
     end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%
% localConnectingModels %
%%%%%%%%%%%%%%%%%%%%%%%%%
function txt = localConnectingModels(slide,ax)
 %---Slideshow for Connecting Models
  if slide<1
     txt = 7; % number of slides
     return
  end
  localClearAxes(ax);
  p = localParameters;
 %---Slides
  switch slide
  case 1
     set(ax,'XLim',[-6 16],'YLim',[0 11],'Position',p.axpos2,'Visible','off');
     text('Parent',ax,'String','Connecting Models','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localParallel(ax,[1.1 6.8],.45,0,p.cc1);
     localSeries(ax,[5 2.5],.45,0,p.cc2);
     localFeedback(ax,[8.9 6.8],.45,0,p.cc3);
     localHConcatenate(ax,[-2 2.5],.45,0,p.cc4);
     localVConcatenate(ax,[12 2.5],.45,0,p.cc5);
     txt = {
        ' The Control System Toolbox provides a number of functions to help you build'
        ' complex networks of models.  These include functions to perform:'
        ' '
        '    \bullet Series and parallel connections (SERIES and PARALLEL)'
        '    \bullet Feedback connections (FEEDBACK and LFT)'
        '    \bullet I/O concatenation ([ , ], [ ; ], and APPEND)'
        ' '
        ' The following slides demonstrate several typical model interconnections using'
        ' these functions.'
     };
  case 2
     text('Parent',ax,'String','Series Connection','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localSeries(ax);
     txt = {
        ' You can connect models H1 and H2 in series using:'
        ' '
        '   >> H = series(H1,H2);'
        ' '
        ' A series connection is equivalent to the product of the models:'
        ' '
        '   >> H = H2 * H1;'
     };
  case 3
     text('Parent',ax,'String','Parallel Connection','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localParallel(ax);
     txt = {
        ' You can connect models H1 and H2 in parallel using:'
        ' '
        '   >> H = parallel(H1,H2);'
        ' '
        ' A parallel connection is equivalent to the sum of the models:'
        ' '
        '   >> H = H2 + H1;'
     };
  case 4
     text('Parent',ax,'String','Feedback Connection','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localFeedback(ax);
     txt = {
        ' You can connect models H1 and H2 in a feedback configuration using:'
        ' '
        '   >> H = feedback(H1,H2);'
        ' '
        ' To apply positive feedback, use the syntax:'
        ' '
        '   >> H = feedback(H1,H2,+1);'
     };
  case 5
     text('Parent',ax,'String','Summing Outputs','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localHConcatenate(ax);
     txt = {
        ' You can sum the outputs of models H1 and H2 using:'
        ' '
        '   >> H = [ H1 , H2 ];'
        ' '
        ' In matrix notation, this connection is equivalent to the horizontal concatenation'
        ' of these models.  Note that if H1 and H2 are SISO models, then the concatenated'
        ' model H is a MIMO model with 2 inputs and 1 output.'
     };
  case 6
     text('Parent',ax,'String','Distributing Inputs','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localVConcatenate(ax);
     txt = {
        ' You can distribute inputs to models H1 and H2 using:'
        ' '
        '   >> H = [ H1 ; H2 ];'
        ' '
        ' In matrix notation, this connection is equivalent to the vertical concatenation'
        ' of these models.  Note that if H1 and H2 are SISO models, then the concatenated'
        ' model H is a MIMO model with 1 input and 2 outputs.'
     };
  case 7
     text('Parent',ax,'String','Appending Models','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localAppend(ax);
     txt = {
        ' You can append the inputs and outputs of models H1 and H2 using:'
        ' '
        '   >> sys = append(H1,H2);'
        ' '
        ' In matrix notation, this connection is equivalent to the block-diagonal concatenation'
        ' of these models.  Note that if H1 and H2 are SISO models, then the concatenated'
        ' model H is a MIMO model with 2 inputs and 2 outputs.'
     };
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localModelTypeConversions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function txt = localModelTypeConversions(slide,ax)
 %---Slideshow for Continuous/Discrete Conversions
  if slide<1
     txt = 3; % number of slides
     return
  end
  localClearAxes(ax);
  p = localParameters;
 %---Slides
  switch slide
  case 1
     set(ax,'XLim',[-6 16],'YLim',[0 11],'Position',p.axpos2,'Visible','off');
     text('Parent',ax,'String','Model Type Conversions','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     localConvertDiagram(ax)
     txt = {
        ' The Control System Toolbox allows you to convert LTI models from one type to'
        ' another, as follows:'
        ' '
        '   >> sys = tf(sys)                   % Conversion to TF'
        '   >> sys = zpk(sys)                % Conversion to ZPK'
        '   >> sys = ss(sys)                   % Conversion to SS'
        '   >> sys = frd(sys,frequency)   % Conversion to FRD'
        ' '
        ' Note that {\bfFRD} models cannot be converted to the other model types and that'
        ' conversion to {\bfFRD} requires a frequency vector as input.'
     };
  case 2
     set(ax,'XLim',[0 10],'YLim',[0 11]);
     text('Parent',ax,'String','Model Conversion Example:','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     sysblock('Par',ax,'Pos',[2 3.6+.4 2 2.8],'Num','SS',...
        'FaceColor',p.cc3,'FontSize',p.fs3,'FontWeight',p.fw3);
     sysblock('Par',ax,'Pos',[6 3.6+.4 2 2.8],'Num','ZPK',...
        'FaceColor',p.cc2,'FontSize',p.fs3,'FontWeight',p.fw3);
     wire('Par',ax,'XData',[4.1 5.9],'YData',[5 5]+.4,'Arrow',.4,'Color',[.8 0 0])
     equation('Par',ax,'Pos',[3 2.8],'Num','dx/dt = -2 x + u','Anchor','center');
     equation('Par',ax,'Pos',[3 2.0],'Num','y = x + 3 u','Anchor','center');
     equation('Par',ax,'Pos',[7 2.4],'Num','3 ( s + 2.333 )','Den','( s + 2 )');
     txt = {
        ' For example, you can convert the state-space model:'
        ' '
        '   >> sys = ss(-2,1,1,3);'
        ' '
        ' to a zero-pole-gain model using:'
        ' '
        '   >> sys = zpk(sys);'
     };
  case 3
     text('Parent',ax,'String','Implicit Model Conversion Example:','Position',[1 9.5],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     %--- SS->TFDATA->[num,den] blocks
      sysblock('Par',ax,'Pos',[1.4 5.35 1.2 1.8],'Num','SS',...
         'FaceColor',p.cc3,'FontSize',p.fs3,'FontWeight',p.fw3);
      wire('Par',ax,'XData',[2.7 4.1],'YData',[6.25 6.25],'Arrow',.4,'Color',[.8 0 0]);
      sysblock('Par',ax,'Pos',[4.2 5 1.6 2.5],'Num','TFDATA',...
         'FaceColor',p.cc1,'FontSize',p.fs3,'FontWeight',p.fw3,'Curvature',[.3 .6]);
      wire('Par',ax,'XData',[5.9 7.1],'YData',[6.25 6.25],'Arrow',.4,'Color',[.8 0 0]);
      sysblock('Par',ax,'Pos',[7.2 5.2 1.7 2.1],'Num','[num,den]',...
         'FaceColor',p.cc1,'FontSize',p.fs3,'FontWeight',p.fw3,'Curvature',[.3 .6]);
     %--- SS->TF blocks
      line('Parent',ax,'XData',[3.1 5 6.9 NaN 3.1 5 6.9],'YData',[3.3 5.5 3.3 NaN .9 5.5 .9],'LineStyle',':');
      sysblock('Par',ax,'Pos',[3.3 1.2 1.2 1.8],'Num','SS',...
         'FaceColor',p.cc3,'FontSize',p.fs3,'FontWeight',p.fw3);
      wire('Par',ax,'XData',[4.6 5.4],'YData',[2.1 2.1],'Arrow',.4,'Color',[.8 0 0])
      sysblock('Par',ax,'Pos',[5.5 1.2 1.2 1.8],'Num','TF',...
         'FaceColor',p.cc1,'FontSize',p.fs3,'FontWeight',p.fw3);
      sysblock('Par',ax,'Pos',[3.1 .9 3.8 2.4],'FaceColor','none','LineStyle',':','LineWidth',0.5);
      txt = {
         ' Some algorithms operate on only one type of LTI model.  For convenience, such'
         ' commands automatically convert LTI models to the appropriate or required model'
         ' type.  For example, in'
         ' '
         '   >> sys = ss(0,1,1,0);'
         '   >> [num,den] = tfdata(sys);'
         ' '
         ' the function TFDATA internally converts the state-space model sys to an'
         ' equivalent transfer function model in order to obtain its numerator and'
         ' denominator data.'
      };
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localContinuousDiscreteConversions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function txt = localContinuousDiscreteConversions(slide,ax)
 %---Slideshow for Continuous/Discrete Conversions
  if slide<1
     txt = 3; % number of slides
     return
  end
  localClearAxes(ax);
  p = localParameters;
 %---Slides
  switch slide
  case 1
     set(ax,'XLim',[0 10],'YLim',[0 11],'Position',p.axpos2,'Visible','off');
     text('Parent',ax,'String','Continuous / Discrete Conversions','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     x11 = 1.5; x12 = 4.0;
     x21 = 6.0; x22 = 8.5;
     y11 = 2.5; y12 = 7.5;
     sysblock('Par',ax,'Pos',[x11 y11 x12-x11 y12-y11],'Name','continuous time',...
        'Num',' ','FaceColor',p.cc3,'FontSize',p.fs2,'FontWeight',p.fw1);
     sysblock('Par',ax,'Pos',[x21 y11 x22-x21 y12-y11],'Name','discrete time',...
        'Num',' ','FaceColor',p.cc2,'FontSize',p.fs2,'FontWeight',p.fw1);
     wire('Par',ax,'XData',[x12+.1 x21-.1],'YData',[y12-1.5 y12-1.5],'Arrow',.4);
     wire('Par',ax,'XData',[x21-.1 x12+.1],'YData',[y11+1.5 y11+1.5],'Arrow',.4);
     xd = x11+.15:.05:x12-.15;
     yd = (y11+y12)/2+1.4*sin(2*xd+1.3);
     [xds,yds] = stairs(xd(1:3:end)+x21-x11,yd(1:3:end));
     wire('Par',ax,'XData',xd,'YData',yd,'Color','r');
     wire('Par',ax,'XData',xds,'YData',yds,'Color','b');
     txt = {
        ' The function C2D is provided to convert {\bfTF}, {\bfZPK}, and {\bfSS} models from continuous'
        ' time to discrete time equivalents.  Conversely, the function D2C is provided to'
        ' convert these models from discrete time to continuous time equivalents.  Several'
        ' conversion methods are supported, including:'
        ' '
        '    \bullet Zero-order hold'
        '    \bullet First-order hold'
        '    \bullet Tustin approximation (bilinear)'
        '    \bullet Tustin with frequency prewarping'
        '    \bullet Matched poles and zeros'
     };
  case 2
     set(ax,'XLim',[0 10],'YLim',[0 11],'Position',p.axpos2,'Visible','off');
     text('Parent',ax,'String','Continuous / Discrete Conversions','Position',[5 10],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','middle');
     x11 = 1.5; x12 = 4.0;
     x21 = 6.0; x22 = 8.5;
     y11 = 2.5; y12 = 7.5;
     sysblock('Par',ax,'Pos',[x11 y11 x12-x11 y12-y11],'Name',{'continuous-time','model'},'Num','sysc',...
        'FaceColor',p.cc3,'FontSize',p.fs3,'FontWeight',p.fw3,'NameFontSize',p.fs2,'NameFontWeight',p.fw1);
     sysblock('Par',ax,'Pos',[x21 y11 x22-x21 y12-y11],'Name',{'discrete-time','model'},'Num','sysd',...
        'FaceColor',p.cc2,'FontSize',p.fs3,'FontWeight',p.fw3,'NameFontSize',p.fs2,'NameFontWeight',p.fw1);
     wire('Par',ax,'XData',[x12+.1 x21-.1],'YData',[y12-1.5 y12-1.5],'Arrow',.4);
     wire('Par',ax,'XData',[x21-.1 x12+.1],'YData',[y11+1.5 y11+1.5],'Arrow',.4);
     text('Parent',ax,'String','c2d','Position',[5 y12-1.5+.3],'Color',[.8 0 0],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','bottom');
     text('Parent',ax,'String','d2c','Position',[5 y11+1.5-.3],'Color',[.8 0 0],...
        'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','center','Ver','top');
     txt = {
        ' You can use these commands to perform basic zero-order hold conversions:'
        ' '
        '   >> sysd = c2d(sysc,Ts);    % Ts = sampling period in seconds'
        '   >> sysc = d2c(sysd);'
        ' '
        ' You can specify alternative conversions methods with an extra string input:'
        ' '
        '   >> sysd = c2d(sysc,Ts,Method);'
        '   >> sysc = d2c(sysd,Method);'
        ' '
        ' where Method may be ''zoh'', ''foh'', ''tustin'', ''prewarp'', or ''matched''.'
     };
  case 3
     axis(ax,'normal');
     set(ax,'Position',p.axpos1+[0 0 -0.37 -0.05],'Visible','on')
     sysc = tf([1 0.5 100],[1 5 100]);
     sysd = c2d(sysc,0.1);
     step(sysc,'b',sysd,'r',2.5);
     set(gca,'Ylim',[0.6 1.2]);
     set(gca,'Xlim',[0 2.5]);
     legend('Continuous','Discretized',4);
     h = text('Parent',ax,'String','Continuous-to-Discrete Conversion Example:','Units','norm',...
        'Position',[0 1.2],'FontSize',p.fs3,'FontWeight',p.fw3,'Hor','left','Ver','middle');
     fig = get(ax,'Parent');
     str = ['Run the "Notch Filter Discretization" demo for ',...
            'a detailed illustration of the effect various ',...
            'discretization methods have on the conversion of this ',...
            'continuous-time model to discrete time.'];
     l1 = handle.listener(h,'ObjectBeingDestroyed',@localDeleteCallbackTarget);
     h1 = uicontrol('Parent',fig,'Style','text','Back',get(fig,'Color'),'Units','norm',...
        'Position',[.64 .64 .31 .22],'String',str,'UserData',l1,'Hor','left');
     l1.CallbackTarget = h1;
     l2 = handle.listener(h,'ObjectBeingDestroyed',@localDeleteCallbackTarget);
     h2 = uicontrol('Parent',fig,'Units','norm','Position',[.64 .56 .27 .08],...
        'String','Run Notch Filter Demo','UserData',l2,'Callback','notchdemo');
     l2.CallbackTarget = h2;
     txt = {
        ' For example, you can discretize the continuous-time model:'
        ' '
        '   >> sysc = tf([1 0.5 100],[1 5 100]);'
        ' '
        ' with a 0.1 sec sampling time as follows:'
        ' '
        '   >> sysd = c2d(sysc,0.1);    % uses zero-order hold'
        ' '
        ' You can compare the step responses of these systems using the STEP command:'
        ' '
        '   >> step(sysc,''b'',sysd,''r'')'
     };
  end

%%%%%%%%%%%%%%%%%%%
% localParameters %
%%%%%%%%%%%%%%%%%%%
function p_out = localParameters
 %---Parameters/systems used in demo
 persistent p;
 if isempty(p)
    if ispc
       p.fs1 = 8;
       p.fs2 = 10;
       p.fs3 = 12;
    else
       p.fs1 = 10;
       p.fs2 = 12;
       p.fs3 = 14;
    end
    axBorder = 0.09;
    p.axpos1 = [axBorder 0.55 1-axBorder-.04 0.41];
    p.axpos2 = [0 0.45 1 0.55];
    p.fw1 = 'normal';
    p.fw2 = 'bold';
    p.fw3 = 'bold';
    p.as = .05;  %---Arrow size
    p.sbr = .04; %---Sumblock radius
    p.s = tf('s');
    p.cc1 = [1 1 .9];
    p.cc2 = [.9 1 1];
    p.cc3 = [1 .9 1];
    p.cc4 = [.9 1 .9];
    p.cc5 = [.9 .9 1];
    p.cc6 = [1 .9 .9];
    p.ccg = [.4 .4 .4];
 end
 p_out = p;

%%%%%%%%%%%%%%%
% localMatrix %
%%%%%%%%%%%%%%%
function localMatrix(ax,select)
 %---Model matrix GUI
  p = localParameters;
  if nargin>1
     scale = 0.14;
     xo = 8.75;  % 0.1
     yo = 9.2;   % 0.7
     switch select
     case 1
        fc1 = p.cc1;  ec1 = [0 0 0];
        fc2 = p.ccg;  ec2 = p.ccg;
        fc3 = p.ccg;  ec3 = p.ccg;
        fc4 = p.ccg;  ec4 = p.ccg;
        bstr = 'TF';
     case 2
        fc1 = p.ccg;  ec1 = p.ccg;
        fc2 = p.cc2;  ec2 = [0 0 0];
        fc3 = p.ccg;  ec3 = p.ccg;
        fc4 = p.ccg;  ec4 = p.ccg;
        bstr = 'ZPK';
     case 3
        fc1 = p.ccg;  ec1 = p.ccg;
        fc2 = p.ccg;  ec2 = p.ccg;
        fc3 = p.cc3;  ec3 = [0 0 0];
        fc4 = p.ccg;  ec4 = p.ccg;
        bstr = 'SS';
     case 4
        fc1 = p.ccg;  ec1 = p.ccg;
        fc2 = p.ccg;  ec2 = p.ccg;
        fc3 = p.ccg;  ec3 = p.ccg;
        fc4 = p.cc4;  ec4 = [0 0 0];
        bstr = 'FRD';
     end
     Num1 = ''; Name1 = '';
     Num2 = ''; Name2 = '';
     Num3 = ''; Name3 = '';
     Num4 = ''; Name4 = '';
  else
     scale = 1;
     xo = 0;
     yo = 0;
     fc1 = p.cc1; ec1 = [0 0 0];
     fc2 = p.cc2; ec2 = [0 0 0];
     fc3 = p.cc3; ec3 = [0 0 0];
     fc4 = p.cc4; ec4 = [0 0 0];
     Num1 = 'TF';  Name1 = 'Transfer Function';
     Num2 = 'ZPK'; Name2 = 'Zero-Pole-Gain';
     Num3 = 'SS';  Name3 = 'State-Space';
     Num4 = 'FRD'; Name4 = 'Frequency Response Data';
     bstr = '';
  end
  xe = 10*scale;
  ye = 10*scale;
  dx = 1.0*scale;
  dy = 1.5*scale;
  w = 2.0*scale;
  h = 2.8*scale;
  sysblock('Par',ax,'Pos',[xe/2-dx/2-w+xo ye/2+dy/2+yo w h],'Num',Num1,...
     'FaceColor',fc1,'EdgeColor',ec1,'FontSize',p.fs3,'FontWeight',p.fw3,...
     'NameFontSize',p.fs1,'NameFontWeight',p.fw1,'Name',Name1);
  sysblock('Par',ax,'Pos',[xe/2+dx/2+xo ye/2+dy/2+yo w h],'Num',Num2,...
     'FaceColor',fc2,'EdgeColor',ec2,'FontSize',p.fs3,'FontWeight',p.fw3,...
     'NameFontSize',p.fs1,'NameFontWeight',p.fw1,'Name',Name2);
  sysblock('Par',ax,'Pos',[xe/2-dx/2-w+xo ye/2-dy/2-h+yo w h],'Num',Num3,...
     'FaceColor',fc3,'EdgeColor',ec3,'FontSize',p.fs3,'FontWeight',p.fw3,...
     'NameFontSize',p.fs1,'NameFontWeight',p.fw1,'Name',Name3);
  sysblock('Par',ax,'Pos',[xe/2+dx/2+xo ye/2-dy/2-h+yo w h],'Num',Num4,...
     'FaceColor',fc4,'EdgeColor',ec4,'FontSize',p.fs3,'FontWeight',p.fw3,...
     'NameFontSize',p.fs1,'NameFontWeight',p.fw1,'Name',Name4);
  text('Parent',ax,'String',bstr,'Position',[xe/2+xo yo],...
     'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','center','Ver','top');

%%%%%%%%%%%%%%%%%%%%%%%
% localConvertDiagram %
%%%%%%%%%%%%%%%%%%%%%%%
function localConvertDiagram(ax)
 %---Model Conversion Diagram
  p = localParameters;
  xc = 5;
  yc = 5;
  dx = 4;
  ddx = dx/12;
  dy = 3;
  ddy = dy/10;
  w = 2.4;
  h = 2;
  %---Blocks
   sysblock('Par',ax,'Pos',[xc-dx/2-w yc+dy/2 w h],  'Num','TF', 'FaceColor',p.cc1,'FontSize',p.fs3,'FontWeight',p.fw3);
   sysblock('Par',ax,'Pos',[xc+dx/2 yc+dy/2 w h],    'Num','ZPK','FaceColor',p.cc2,'FontSize',p.fs3,'FontWeight',p.fw3);
   sysblock('Par',ax,'Pos',[xc-dx/2-w yc-dy/2-h w h],'Num','SS', 'FaceColor',p.cc3,'FontSize',p.fs3,'FontWeight',p.fw3);
   sysblock('Par',ax,'Pos',[xc+dx/2 yc-dy/2-h w h],  'Num','FRD','FaceColor',p.cc4,'FontSize',p.fs3,'FontWeight',p.fw3);
  %---Horizontal arrows
   wire('Par',ax,'XData',[xc-dx/2+ddx xc+dx/2-ddx],'YData',[yc+dy/2+h*2/3 yc+dy/2+h*2/3],'Arrow',dx/8,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc+dx/2-ddx xc-dx/2+ddx],'YData',[yc+dy/2+h*1/3 yc+dy/2+h*1/3],'Arrow',dx/8,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc-dx/2+ddx xc+dx/2-ddx],'YData',[yc-dy/2-h*1/2 yc-dy/2-h*1/2],'Arrow',dx/8,'Color',[.8 0 0])
  %---Vertical arrows
   wire('Par',ax,'XData',[xc-dx/2-w*2/3 xc-dx/2-w*2/3],'YData',[yc+dy/2-ddy yc-dy/2+ddy],'Arrow',dy/6,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc-dx/2-w*1/3 xc-dx/2-w*1/3],'YData',[yc-dy/2+ddy yc+dy/2-ddy],'Arrow',dy/6,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc+dx/2+w*1/2 xc+dx/2+w*1/2],'YData',[yc+dy/2-ddy yc-dy/2+ddy],'Arrow',dy/6,'Color',[.8 0 0])
  %---Diagonal arrows
   wire('Par',ax,'XData',[xc-dx/2+ddx*1 xc+dx/2-ddx],'YData',[yc+dy/2-ddy yc-dy/2+ddy*1],'Arrow',dy/7,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc-dx/2+ddx*0 xc+dx/2-ddx],'YData',[yc-dy/2+ddy yc+dy/2-ddy*0],'Arrow',dy/7,'Color',[.8 0 0])
   wire('Par',ax,'XData',[xc+dx/2-ddx*0 xc-dx/2+ddx],'YData',[yc+dy/2-ddy yc-dy/2+ddy*0],'Arrow',dy/7,'Color',[.8 0 0])

%%%%%%%%%%%%%%%
% localSeries %
%%%%%%%%%%%%%%%
function localSeries(ax,pos,scale,showlabels,color)
 %---Model series diagram
  p = localParameters;
  if nargin<5, color = p.cc1; end
  if nargin<4, showlabels = 1; end
  if nargin<3, scale = 1; end
  if nargin<2, pos = [5 5]; end
  if showlabels
     t1 = 'H1';
     t2 = 'H2';
  else
     t1 = '';
     t2 = '';
  end
  bw = 3*scale;
  bh = 2.5*scale;
  ar = .5*scale;
  sysblock('Parent',ax,'Position',[pos(1)-bw-1*scale pos(2)-bh/2 bw bh],'Name',t1,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  sysblock('Parent',ax,'Position',[pos(1)+1*scale pos(2)-bh/2 bw bh],'Name',t2,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  wire('Parent',ax,'XData',pos(1)-bw+[-3 -1]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
  wire('Parent',ax,'XData',pos(1)+[-1 1]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
  wire('Parent',ax,'XData',pos(1)+bw+[1 3]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
  sysblock('Parent',ax,'Position',[pos(1)-bw-2*scale pos(2)-bh/2-1.75*scale 10*scale 6*scale],...
     'LineStyle',':','LineWidth',0.5,'FaceColor','none');
  if showlabels
     text('Parent',ax,'String','u ','Position',[pos(1)-bw-3*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
%     equation('Par',ax,'Pos',[pos(1)+bw+3*scale pos(2)],'Name',' y','Num','( H1 x H2 ) u',...
%        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
     text('Parent',ax,'String',' y','Position',[pos(1)+bw+3*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
     text('Parent',ax,'String','H','Position',[pos(1)-bw+7.9*scale pos(2)-bh/2-1.65*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
  end

%%%%%%%%%%%%%%%%%
% localParallel %
%%%%%%%%%%%%%%%%%
function localParallel(ax,pos,scale,showlabels,color)
 %---Model parallel diagram
  p = localParameters;
  if nargin<5, color = p.cc1; end
  if nargin<4, showlabels = 1; end
  if nargin<3, scale = 1; end
  if nargin<2, pos = [5 5]; end
  if showlabels
     t1 = 'H1';
     t2 = 'H2';
     t3 = {'+45','+315'};
  else
     t1 = '';
     t2 = '';
     t3 = {' 45'};
  end
  bw = 3*scale;
  bh = 2.5*scale;
  y1 = pos(2)+.5*scale+bh/2;
  y2 = pos(2)-.5*scale-bh/2;
  ar = .5*scale;
  sysblock('Parent',ax,'Position',[pos(1)-bw/2 pos(2)+.5*scale bw bh],'Name',t1,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  sysblock('Parent',ax,'Position',[pos(1)-bw/2 pos(2)-.5*scale-bh bw bh],'Name',t2,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  wire('Parent',ax,'XData',pos(1)-bw/2+[-4 -1.5 -1.5 0]*scale,'YData',[pos(2) pos(2) y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',pos(1)-bw/2+[-1.5 -1.5 0]*scale,'YData',[pos(2) y2 y2],'Arrow',ar)
  wire('Parent',ax,'XData',pos(1)+bw/2+[0 1.5 1.5]*scale,'YData',[y1 y1 pos(2)+.5*scale],'Arrow',ar)
  wire('Parent',ax,'XData',pos(1)+bw/2+[0 1.5 1.5]*scale,'YData',[y2 y2 pos(2)-.5*scale],'Arrow',ar)
  wire('Parent',ax,'XData',pos(1)+bw/2+[2 4]*scale,'YData',[pos(2) pos(2)],'Arrow',ar)
  sumblock('Parent',ax,'Position',[pos(1)+bw/2+1.5*scale pos(2)],'Radius',.5*scale,'Label',t3,...
     'FontSize',p.fs3,'FontWeight',p.fw3);
  sysblock('Parent',ax,'Position',[pos(1)-bw/2-3*scale pos(2)-bh/2-2.75*scale 9*scale 8*scale],...
     'LineStyle',':','LineWidth',0.5,'FaceColor','none');
  if showlabels
     text('Parent',ax,'String','u ','Position',[pos(1)-bw/2-4*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
%     equation('Par',ax,'Pos',[pos(1)+bw/2+4*scale pos(2)],'Name',' y','Num','( H1 + H2 ) u',...
%        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
     text('Parent',ax,'String',' y','Position',[pos(1)+bw/2+4*scale pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
     text('Parent',ax,'String','H','Position',[pos(1)-bw/2+5.9*scale pos(2)-bh/2-2.65*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
  end

%%%%%%%%%%%%%%%%%
% localFeedback %
%%%%%%%%%%%%%%%%%
function localFeedback(ax,pos,scale,showlabels,color)
 %---Model feedback diagram
  p = localParameters;
  if nargin<5, color = p.cc1; end
  if nargin<4, showlabels = 1; end
  if nargin<3, scale = 1; end
  if nargin<2, pos = [5 5]; end
  if showlabels
     t1 = 'H1';
     t2 = 'H2';
     t3 = {'+145','-235'};
  else
     t1 = '';
     t2 = '';
     t3 = {' 45'};
  end
  bw = 3*scale;
  bh = 2.5*scale;
  x1 = pos(1)-bw/2-1.75*scale;
  x2 = pos(1)+bw/2+1.75*scale;
  y1 = pos(2)+.5*scale+bh/2;
  y2 = pos(2)-.5*scale-bh/2;
  ar = .5*scale;
  sysblock('Parent',ax,'Position',[pos(1)-bw/2 y1-bh/2 bw bh],'Name',t1,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  sysblock('Parent',ax,'Position',[pos(1)-bw/2 y2-bh/2 bw bh],'Name',t2,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  sumblock('Parent',ax,'Position',[x1 y1],...
     'Radius',.5*scale,'Label',t3,'FontSize',p.fs3,'FontWeight',p.fw3);
  wire('Parent',ax,'XData',[x1-2.5*scale x1-.5*scale],'YData',[y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[x1+.5*scale pos(1)-bw/2],'YData',[y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[pos(1)+bw/2 x2+3*scale],'YData',[y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[x2 x2 pos(1)+bw/2],'YData',[y1 y2 y2],'Arrow',ar)
  wire('Parent',ax,'XData',[pos(1)-bw/2 x1 x1],'YData',[y2 y2 y1-.5*scale],'Arrow',ar)
  sysblock('Parent',ax,'Position',[x1-1.5*scale y2-bh/2-1*scale 9.5*scale 8*scale],...
     'LineStyle',':','LineWidth',0.5,'FaceColor','none');
  if showlabels
     text('Parent',ax,'String','u ','Position',[x1-2.5*scale y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
%     equation('Par',ax,'Pos',[x2+3*scale y1],'Name',' y','Num','H1','Den','1 + H1 H2','Gain2',' u',...
%        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag1');
     text('Parent',ax,'String',' y','Position',[x2+3*scale y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
     text('Parent',ax,'String','H','Position',[x1+7.9*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
  end

%%%%%%%%%%%%%%%%%%%%%
% localHConcatenate %
%%%%%%%%%%%%%%%%%%%%%
function localHConcatenate(ax,pos,scale,showlabels,color)
 %---Horizontal concatenation diagram
  p = localParameters;
  if nargin<5, color = p.cc1; end
  if nargin<4, showlabels = 1; end
  if nargin<3, scale = 1; end
  if nargin<2, pos = [3.5 5]; end
  if showlabels
     t1 = 'H1';
     t2 = 'H2';
     t3 = {'+45','+315'};
  else
     t1 = '';
     t2 = '';
     t3 = {' 45'};
  end
  bw = 3*scale;
  bh = 2.5*scale;
  xm = pos(1)-.75*scale;
  x1 = xm-bw/2-2.5*scale;
  x2 = xm+bw/2+1.5*scale;
  x3 = x2+3*scale;
  y1 = pos(2)+.5*scale+bh/2;
  y2 = pos(2)-.5*scale-bh/2;
  ar = .5*scale;
  sysblock('Parent',ax,'Position',[xm-bw/2 y1-bh/2 bw bh],'Name',t1,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  sysblock('Parent',ax,'Position',[xm-bw/2 y2-bh/2 bw bh],'Name',t2,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  wire('Parent',ax,'XData',[x1 xm-bw/2],'YData',[y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[x1 xm-bw/2],'YData',[y2 y2],'Arrow',ar)
  wire('Parent',ax,'XData',[xm+bw/2 x2 x2],'YData',[y1 y1 pos(2)+.5*scale],'Arrow',ar)
  wire('Parent',ax,'XData',[xm+bw/2 x2 x2],'YData',[y2 y2 pos(2)-.5*scale],'Arrow',ar)
  wire('Parent',ax,'XData',[x2+.5*scale x3],'YData',[pos(2) pos(2)],'Arrow',ar)
  sumblock('Parent',ax,'Position',[x2 pos(2)],'Radius',.5*scale,'Label',t3,...
     'FontSize',p.fs3,'FontWeight',p.fw3);
  sysblock('Parent',ax,'Position',[xm-bw/2-1.5*scale y2-bh/2-1*scale 7.5*scale 8*scale],...
     'LineStyle',':','LineWidth',0.5,'FaceColor','none');
  if showlabels
     text('Parent',ax,'String','u1 ','Position',[x1 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
     text('Parent',ax,'String','u2 ','Position',[x1 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
     equation('Par',ax,'Pos',[x3 pos(2)],'Name',' y','Num',{'H1 , H2'},'Bracket',1,'Tag','mytag1',...
         'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
     th = findobj(get(ax,'Children'),'flat','Tag','mytag1','String',{'H1 , H2'});
     te = get(th,'Extent');
     equation('Par',ax,'Pos',[te(1)+te(3)+2*.4 pos(2)],'Num',{'u1';'u2'},'Bracket',1,...
         'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
     text('Parent',ax,'String','H','Position',[xm-bw/2+5.9*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
  end

%%%%%%%%%%%%%%%%%%%%%
% localVConcatenate %
%%%%%%%%%%%%%%%%%%%%%
function localVConcatenate(ax,pos,scale,showlabels,color)
 %---Vertical concatenation diagram
  p = localParameters;
  if nargin<5, color = p.cc1; end
  if nargin<4, showlabels = 1; end
  if nargin<3, scale = 1; end
  if nargin<2, pos = [3.5 5]; end
  if showlabels
     t1 = 'H1';
     t2 = 'H2';
  else
     t1 = '';
     t2 = '';
  end
  bw = 3*scale;
  bh = 2.5*scale;
  x1 = pos(1)-bw/2-3.25*scale;
  xm = pos(1)-.75*scale+bw/2;
  x2 = pos(1)+bw/2+3.75*scale;
  x3 = xm-bw/2-1.5*scale;
  y1 = pos(2)+.5*scale+bh/2;
  y2 = pos(2)-.5*scale-bh/2;
  ar = .5*scale;
  sysblock('Parent',ax,'Position',[xm-bw/2 y1-bh/2 bw bh],'Name',t1,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  sysblock('Parent',ax,'Position',[xm-bw/2 y2-bh/2 bw bh],'Name',t2,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  wire('Parent',ax,'XData',[x3-2.5*scale x3 x3 xm-bw/2],'YData',[pos(2) pos(2) y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[x3 x3 xm-bw/2],'YData',[pos(2) y2 y2],'Arrow',ar)
  wire('Parent',ax,'XData',[xm+bw/2 x2],'YData',[y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[xm+bw/2 x2],'YData',[y2 y2],'Arrow',ar)
  sysblock('Parent',ax,'Position',[x3-1.5*scale y2-bh/2-1*scale 7.5*scale 8*scale],...
     'LineStyle',':','LineWidth',0.5,'FaceColor','none');
  if showlabels
     text('Parent',ax,'String','u ','Position',[x1 pos(2)],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
     text('Parent',ax,'String',' y1','Position',[x2 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
     text('Parent',ax,'String',' y2','Position',[x2 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
     text('Parent',ax,'String','H','Position',[x3+5.9*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
     CC = [0 0 0];
     xsp = .4;
     X = 10.7;
     Y = 5;
     equation('Par',ax,'Pos',[X Y],'Num',{'y1';'y2'},'Bracket',1,...
        'Anchor','right','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag1');
     th = findobj(get(ax,'Children'),'flat','Tag','mytag1','String',{'y1';'y2'});
     te = get(th,'Extent');
     text('Parent',ax,'String','=','Position',[te(1)+te(3)+1.5*xsp Y],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center');
     equation('Par',ax,'Pos',[te(1)+te(3)+3*xsp Y],'Num',{'H1';'H2'},'Bracket',1,...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag2');
     th = findobj(get(ax,'Children'),'flat','Tag','mytag2','String',{'H1';'H2'});
     te = get(th,'Extent');
     equation('Par',ax,'Pos',[te(1)+te(3)+1*xsp Y],'Num','u',...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
  end

%%%%%%%%%%%%%%%
% localAppend %
%%%%%%%%%%%%%%%
function localAppend(ax,pos,scale,showlabels,color)
 %---Model append diagram
  p = localParameters;
  if nargin<5, color = p.cc1; end
  if nargin<4, showlabels = 1; end
  if nargin<3, scale = 1; end
  if nargin<2, pos = [3.5 5]; end
  if showlabels
     t1 = 'H1';
     t2 = 'H2';
  else
     t1 = '';
     t2 = '';
  end
  bw = 3*scale;
  bh = 2.5*scale;
  x1 = pos(1)-bw/2-3.25*scale;
  x2 = pos(1)+bw/2+3.75*scale;
  y1 = pos(2)+.5*scale+bh/2;
  y2 = pos(2)-.5*scale-bh/2;
  ar = .5*scale;
  sysblock('Parent',ax,'Position',[pos(1)-bw/2 y1-bh/2 bw bh],'Name',t1,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  sysblock('Parent',ax,'Position',[pos(1)-bw/2 y2-bh/2 bw bh],'Name',t2,...
     'FaceColor',color,'FontSize',p.fs2,'FontWeight',p.fw2);
  wire('Parent',ax,'XData',[x1 pos(1)-bw/2],'YData',[y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[x1 pos(1)-bw/2],'YData',[y2 y2],'Arrow',ar)
  wire('Parent',ax,'XData',[pos(1)+bw/2 x2],'YData',[y1 y1],'Arrow',ar)
  wire('Parent',ax,'XData',[pos(1)+bw/2 x2],'YData',[y2 y2],'Arrow',ar)
  sysblock('Parent',ax,'Position',[x1+1*scale y2-bh/2-1*scale 7.5*scale 8*scale],...
     'LineStyle',':','LineWidth',0.5,'FaceColor','none');
  if showlabels
     text('Parent',ax,'String','u1 ','Position',[x1 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
     text('Parent',ax,'String','u2 ','Position',[x1 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','right','Ver','middle');
     text('Parent',ax,'String',' y1','Position',[x2 y1],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
     text('Parent',ax,'String',' y2','Position',[x2 y2],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','left','Ver','middle');
     text('Parent',ax,'String','H','Position',[x1+8.4*scale y2-bh/2-.9*scale],...
        'FontSize',p.fs1,'FontWeight',p.fw1,'Hor','right','Ver','bottom');
     xsp = .4;
     X = 10.7;
     Y = 5;
     equation('Par',ax,'Pos',[X Y],'Num',{'y1';'y2'},'Bracket',1,...
        'Anchor','right','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag1');
     th = findobj(get(ax,'Children'),'flat','Tag','mytag1','String',{'y1';'y2'});
     te = get(th,'Extent');
     X1 = te(1)-2*xsp;
     text('Parent',ax,'String','=','Position',[te(1)+te(3)+1.5*xsp Y],...
        'FontSize',p.fs2,'FontWeight',p.fw2,'Hor','center');
     equation('Par',ax,'Pos',[te(1)+te(3)+3*xsp Y],'Num',{'H1   0 ';' 0   H2'},'Bracket',1,...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2,'Tag','mytag2');
     th = findobj(get(ax,'Children'),'flat','Tag','mytag2','String',{'H1   0 ';' 0   H2'});
     te = get(th,'Extent');
     equation('Par',ax,'Pos',[te(1)+te(3)+2*xsp Y],'Num',{'u1';'u2'},'Bracket',1,...
        'Anchor','left','FontSize',p.fs2,'FontWeight',p.fw2);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% localDeleteCallbackTarget %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDeleteCallbackTarget(eventSrc,eventData)
 %---Callback for listener for deletion of CallbackTarget
  delete(eventSrc)

%%%%%%%%%%%%%%%%%%
% localClearAxes %
%%%%%%%%%%%%%%%%%%
function localClearAxes(ax)
 %---Clear axes and remove legend
 delete(findobj(allchild(ax),'flat','Serializable','on'));
 legend(ax,'off');
