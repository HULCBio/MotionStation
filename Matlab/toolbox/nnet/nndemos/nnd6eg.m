function nnd6eg(cmd,data)
%NND6EG Eigenvector game.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% BRING UP FIGURE IF IT EXISTS

me = 'nnd6eg';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CONSTANTS
dangle = 10;
deg = pi/180;
Fs = 8192;
time = [0:(1/Fs):0.02];
w = time*2*pi;

% CREATE FIGURE ========================================================

if fig == 0

  % STANDARD DEMO FIGURE
  fig = nndemof(me,'DESIGN','Eigenvector Game','','Chapter 6');
  str = [me '(''down'',get(0,''pointerloc''))'];
  set(fig,...
    'WindowButtonDownFcn',str, ...
    'backingstore','off');
  
  % UNLOCK AND GET HANDLES
  set(fig,'nextplot','add','pointer','watch')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  nndicon(6,458,363,'shadow');
  
  % PICK EIGENVECTORS
  a = eye(2);
  while any(abs([a(1,2) a(2,1)]) < 0.15)
    angle1 = nnpin(rand*360-180,-180,180,dangle);
    v1=0.8*[cos(angle1*deg);sin(angle1*deg)];
    angle2 = angle1;
    while any(angle2 == (angle1+[0 170 180 190 350 -170 -180 -190 -350]))
      angle2 = nnpin(rand*360-180,-180,180,dangle);
      v2=0.8*[cos(angle2*deg);sin(angle2*deg)];
    end
    m=[v1 v2];
 
    % PICK EIGENVALUES
    e = 2*(rand(2,1)-0.5);
    e = (rand(2,1)*0.4+0.3) .* sign(rand(2,1)-0.5);
  
    % FIND THE MATRIX
    a=m*diag(e)*inv(m);
  end

  % HAPPY FACE
  angle = [0:5:360]*pi/180;
  circlex = cos(angle);
  circley = sin(angle);
  fill(circlex*50+290,circley*50+230,nnyellow,...
    'erasemode','none',...
    'edgecolor',nndkblue);
  fill(circlex*10+270,circley*15+245,[1 1 1],...
    'erasemode','none','edgecolor',nnltgray)
  fill(circlex*10+310,circley*15+245,[1 1 1],...
    'erasemode','none','edgecolor',nnltgray)
  fill(circlex*6+270,circley*7+240,nndkblue,...
    'erasemode','none','edgecolor',nndkgray)
  fill(circlex*7+310,circley*7+240,nndkblue,...
    'erasemode','none','edgecolor',nndkgray)
  smile_angle = [0:5:180]*pi/180;
  smilex = cos(smile_angle);
  smiley = -sin(smile_angle);
  smiles = zeros(1,11);
  for i=0:10
    smile_size = i*4-20;
    xx = smilex*35+290;
    yy = smiley*smile_size+smile_size/2+215;
    smiles(i+1) = plot(xx,yy,...
      'color',nnyellow,'erasemode','none','linewidth',4,'visible','off');
  end
  set(smiles(11),'color',nndkblue,'visible','on');
  
  % HAT
  hat_x = [0 40 40 30 20 10 0]+270;
  hat_y = [0 0 20 10 20 10 20]+290;
  hat = fill(hat_x,hat_y,nngreen,...
    'erasemode','none',...
    'edgecolor',nndkblue,...
    'visible','off');
  
  % JEWEL
  band_x = [3 37 37 3]+270;
  band_y = [3 3 7 7]+290;
  band = fill(band_x,band_y,nnred,...
    'erasemode','none',...
    'edgecolor',nndkgray,...
    'visible','off');

  % MESSAGE
  message1 = text(290,155,'>Find First Vector<',...
    'fontsize',12,...
    'color',nnred,...
    'erasemode','none',...
    'horiz','center',...
    'fontweight','bold');
  message2 = text(290,155,'Find First Vector',...
    'fontsize',12,...
    'color',nndkblue,...
    'erasemode','none',...
    'horiz','center',...
    'fontweight','bold');
  
  % BIG AXES
  big = nnsfo('a2','Function F','','');
  set(big,...
    'xlim',[-1 1],'xtick',[-1 -0.5 0 0.5 1],...
    'ylim',[-1 1],'ytick',[-1 -0.5 0 0.5 1])
  cross = plot([-1 1 NaN 0 0],[0 0 NaN -1 1],...
    'linestyle',':',...
    'color',nndkblue,...
    'erasemode','none');

  % LITTLE AXIS
  little = nnsfo('a3','','','Eigenpoints');
  set(get(little,'ylabel'),'fontsize',14);
  set(little,...
    'position',[38+377-20 153 20 160],...
    'xlim',[0 1],...
    'xtick',[],...
    'ylim',[0 10.2],...
    'ytick',[0 2 4 6 8 10])
  bar = fill([0 1 1 0]*0.6+0.2,[0 0 1 1]*10,nnred,'erasemode','none');
    
  % CREATE BUTTONS
  set(nnsfo('b0'),...
    'string','New Game',...
    'callback',nncallbk(me,'new'))
  set(nnsfo('b4'),...
    'string','Contents',...
    'callback','nndtoc')
  set(nnsfo('b5'),...
    'string','Close',...
    'callback','delete(gcf)')

  % DATA HANDLES
  angle_ptr = nnsfo('data');  set(angle_ptr,'userdata',[angle1 angle2]);
  a_ptr = nnsfo('data');  set(a_ptr,'userdata',a);
  line_ptr = nnsfo('data'); set(line_ptr,'userdata',[]);
  score_ptr = nnsfo('data'); set(score_ptr,'userdata',10);
  smiles_ptr = nnsfo('data'); set(smiles_ptr,'userdata',smiles);
  answer_ptr = nnsfo('data'); set(answer_ptr,'userdata',[angle1 angle2]);
  first_ptr = uicontrol('visible','off','userdata',[]);
  
  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text big little bar smiles_ptr angle_ptr ...
    a_ptr line_ptr score_ptr hat band answer_ptr cross ...
    message1 message2 first_ptr];
  set(fig,'userdata',H)

  % TEXT
  nnsettxt(desc_text,...
    'FINDING THE EIGENVECTORS',...
    'Your job is to find the two eigenvectors of an unknown transformation',...
    '',...
    'Click on the graph and hold the mouse button down.  The vector you have',...
    'chosen will appear in red.  The result of transforming this vector will be blue.',...
    'Release the button and try to click so the red and blue vectors point in',...
    'the same (or exactly opposite) direction. When you find an eigenvector',...
    'it will be shown in green. Continue searching for the other eigenvector.',...
    '',...
    'You must find both eigenvectors in ten clicks. Happy Eigenhunting!');
    
  % LOCK WINDOW AND RETURN
  set(fig,...
    'nextplot','new',...
    'pointer','arrow',...
    'color',nnltgray)

  nnchkfs;

  return
end

% SERVICE COMMANDS =======================================================

% UNLOCK FIGURE AND GET HANDLES
set(fig,'nextplot','add','pointer','arrow')
H = get(fig,'userdata');
desc_text = H(2);
big = H(3);
little = H(4);
bar = H(5);
smiles_ptr = H(6);
angle_ptr = H(7);
a_ptr = H(8);
line_ptr = H(9);
score_ptr = H(10);
hat = H(11);
band = H(12);
answer_ptr = H(13);
cross = H(14);
message1 = H(15);
message2 = H(16);
first_ptr = H(17);

% COMMAND: DOWN

cmd = lower(cmd);
if strcmp(cmd,'down')

  % FIND CLICK POSITION
  axes(big)
  pt = get(big,'currentpoint');
  x1 = pt(1);
  x2 = pt(3);
  if (x1 < -1) | (x1 > 1) | (x2 < -1) | (x2 > 1)
    set(fig,'nextplot','new','pointer','arrow')
    return
  end
  click_angle = nnpin(atan2(x2,x1)/deg,-180,180,dangle);
  click_len = sqrt(x1^2+x2^2);
  
  % GET DATA
  ltyell = nnltyell;
  yellow = nnyellow;
  dkblue = nndkblue;
  green = nngreen;
  red = nnred;
  score = get(score_ptr,'userdata');
  smiles = get(smiles_ptr,'userdata');
  a = get(a_ptr,'userdata');
  angles = get(angle_ptr,'userdata');
  answers = get(answer_ptr,'userdata');
  
  if (score > 0 & length(angles) > 0)
    nnsound(sin(w*600),Fs);
    click_v = click_len*[cos(click_angle*deg); sin(click_angle*deg)];
    trans_v = a*click_v;
    trans_len = sqrt(trans_v(1)^2+trans_v(2)^2);
    if trans_len > 1, trans_v = 0.95*trans_v / trans_len; end

    % CHECK FOR NEW HIT
    correct = 0;
    for i=1:length(angles)
      if any(abs(angles(i) - (click_angle+[0 180 -180 360 -360])) < dangle/2)
        angles(i) = [];
        correct = 1;
        break;
      end
    end
    
    if correct
      line1 = nndrwvec(click_v(1),click_v(2),2,0.1,green,'','normal');
      line2 = nndrwvec(trans_v(1),trans_v(2),2,0.1,dkblue,'','normal');
%      line1 = nndrwvec(click_v(1),click_v(2),2,0.1,green,'','none');
%      line2 = nndrwvec(trans_v(1),trans_v(2),2,0.1,dkblue,'','none');
      if length(angles) == 1
        nnsound(sin(w*700),Fs);nnsound(sin(w*1200),Fs);
        set(hat,...
          'facecolor',nngreen,...
          'edgecolor',nndkblue)
        set(hat,...
          'visible','on')
        nntxtchk;
        set(message1,...
          'color',nnltgray)
        set(message2,...
          'color',nnltgray)
        set(message1,...
          'string','>Find Second Vector<',...
          'color',nnred)
        set(message2,...
          'string','Find Second Vector',...
          'color',nndkblue)

      else
        nnsound(sin(w*700),Fs);nnsound(sin(w*1200),Fs);nnsound(sin(w*1800),Fs);
        nnsound(sin(w*700),Fs);nnsound(sin(w*1200),Fs);nnsound(sin(w*1800),Fs);
        set(band,'facecolor',nnred,'edgecolor',nndkblue)
        set(band,'visible','on')
        nntxtchk;
        set(message1,...
          'color',nnltgray)
        set(message2,...
          'color',nnltgray)
        set(message1,...
          'string','>> You Have Won <<',...
          'color',nnred)
        set(message2,...
          'string',' You Have Won ',...
          'color',nndkblue)
      end
      dscore = 0;
      
    else
      % CHECK FOR OLD HIT
      correct = 0;
      for i=1:length(answers)
        if any(abs(answers(i) - (click_angle+[0 180 -180 360 -360])) < dangle/2)
          correct = 1; break;
        end
      end
      
      if correct
        line1 = nndrwvec(click_v(1),click_v(2),2,0.1,green,'','normal');
%        line1 = nndrwvec(click_v(1),click_v(2),2,0.1,green,'','none');
      else
        line1 = nndrwvec(click_v(1),click_v(2),2,0.1,red,'','normal');
%        line1 = nndrwvec(click_v(1),click_v(2),2,0.1,red,'','none');
      end
      line2 = nndrwvec(trans_v(1),trans_v(2),2,0.1,dkblue,'','normal');
%      line2 = nndrwvec(trans_v(1),trans_v(2),2,0.1,dkblue,'','none');
      dscore = -1;
      if score == 1
        for i=500:(-100):100,nnsound(sin(w*i),Fs); end
        nntxtchk;
        set(message1,...
          'color',nnltgray)
        set(message2,...
          'color',nnltgray)
        set(message2,...
          'string',' You Have Lost ',...
          'color',nndkblue)
        set(message1,...
          'string','> You Have Lost <',...
          'color',nnred)
      end
    end
    
    % ADJUST SCORE
    set(smiles(score+1),'color',yellow);
    set(smiles(score+1),'visible','off');  
    score = score + dscore;
    if length(angles)
      smile_num = score+1;
    else
      smile_num = 11;
    end
    set(smiles(smile_num),'color',dkblue,'visible','on');
    set(bar,'edgecolor',ltyell,'facecolor',ltyell);
    set(bar,'ydata',[0 0 1 1]*score);
    if length(angles) == 0
      set(bar,'edgecolor',[0 0 0],'facecolor',red);
    else
      set(bar,'edgecolor',[0 0 0],'facecolor',dkblue);
    end
  
    % STORE DATA
    set(score_ptr,'userdata',score);
    set(line_ptr,'userdata',[line1 line2]);
    set(angle_ptr,'userdata',angles);
    set(gcf,'windowbuttonupfcn',nncallbk(me,'up'));
  end

% COMMAND: UP

elseif strcmp(cmd,'up')
    
  set(gcf,'windowbuttonupfcn','');

  nnpause(0.1);
    
  % GET DATA
  lines = get(line_ptr,'userdata');
  score = get(score_ptr,'userdata');
  angles = get(angle_ptr,'userdata');
  answer = get(answer_ptr,'userdata');
  first = get(first_ptr,'userdata');
  green = nngreen;
  
  % CLEAR LINES
  set(lines,'color',nnltyell);
  delete(lines);
  set(line_ptr,'userdata',[]);

  % FIRST ANSWER FOUND
  if (length(angles) == 1) & (length(first) == 0)
    if (angles == answer(1))
      angle = answer(2);
    else
      angle = answer(1);
    end
    x1 = 0.8*cos(angle*deg);
    y1 = 0.8*sin(angle*deg);
    first = nndrwvec(x1,y1,2,0.1,green,'','none');
    set(first_ptr,'userdata',first)
  else
    first = get(first_ptr,'userdata');
  end

  % DRAW ANSWER IF GAME IS DONE
  if (length(angles) == 0) | (score == 0)
    delete(first);
    set(first_ptr,'userdata',[]);

    x1 = 0.8*cos(answer(1)*deg);
    y1 = 0.8*sin(answer(1)*deg);
    x2 = 0.8*cos(answer(2)*deg);
    y2 = 0.8*sin(answer(2)*deg);
    first = nndrwvec(x1,y1,2,0.1,green,'','none');
    second = nndrwvec(x2,y2,2,0.1,green,'','none');
    set(line_ptr,'userdata',[first second]);
  end

  set(first,...
    'color',green)
  set(cross,...
    'color',nndkblue)

% COMMAND: NEW MATRIX

elseif strcmp(cmd,'new')

  % GET DATA
  yellow = nnyellow;
  ltyell = nnltyell;
  lines = get(line_ptr,'userdata');
  score = get(score_ptr,'userdata');
  smiles = get(smiles_ptr,'userdata');
  first = get(first_ptr,'userdata');
  
  % CLEAR LINES
  set(lines,...
    'color',nnltyell);
  delete(lines);
  set(line_ptr,'userdata',[]);
  set(first,...
    'color',nnltyell);
  delete(first);
  set(first_ptr,'userdata',[]);

  set(cross,...
    'color',nndkblue);
  nntxtchk;
  set(message1,...
    'color',nnltgray)
  set(message2,...
    'color',nnltgray)
  set(message1,...
    'string','>Find First Vector<',...
    'color',nnred)
  set(message2,...
    'string','Find First Vector',...
    'color',nndkblue)

  % PICK EIGENVECTORS
  a = eye(2);
  while any(abs([a(1,2) a(2,1)]) < 0.15)
    angle1 = nnpin(rand*360-180,-180,180,dangle);
    v1=0.8*[cos(angle1*deg);sin(angle1*deg)];
    angle2 = angle1;
    while any(angle2 == (angle1+[0 170 180 190 350 -170 -180 -190 -350]))
      angle2 = nnpin(rand*360-180,-180,180,dangle);
      v2=0.8*[cos(angle2*deg);sin(angle2*deg)];
    end
    e = (rand(2,1)*0.2+[0.6; 0.8]) .* sign(rand(2,1)-0.5);
  
    % FIND THE MATRIX
    m=[v1 v2];
    a=m*diag(e)*inv(m);
  end

  % RESET FACE AND BAR
  set(smiles(score+1),'color',yellow);
  set(smiles(score+1),'visible','off');  
  score = 10;
  set(smiles(score+1),'color',nndkblue,'visible','on');
  set(bar,'edgecolor',ltyell,'facecolor',ltyell);
  set(bar,'ydata',[0 0 1 1]*9.96);
  set(bar,'edgecolor',[0 0 0],'facecolor',nnred);
  set(hat,'facecolor',nnltgray,'edgecolor',nnltgray)
  set(hat,'visible','off')
  set(band,'facecolor',nnltgray,'edgecolor',nnltgray)
  set(band,'visible','off')
    
  % STORE DATA
  set(score_ptr,'userdata',score);
  set(a_ptr,'userdata',a);
  set(angle_ptr,'userdata',[angle1 angle2])
  set(answer_ptr,'userdata',[angle1 angle2])
end

% LOCK WINDOW AND RETURN
set(fig,'nextplot','new','pointer','arrow')

