function nnshrink(z)
%NNSHRINK Neural Network Design utility function.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

% Shrink figure by factor to fit smaller screens.

% FACTOR TO DECREASE FIGURE BY
factor = 0.8;

% NEW FIGURE SIZE
fig_x = 500*factor;
fig_y = 400*factor;

% GET SCREEN SIZE
su = get(0,'units');
set(0,'units','points');
ss = get(0,'ScreenSize');
set(0,'units',su);
left = ss(1);
bottom = ss(2);
width = ss(3);
height = ss(4);

% IDENTIFY WHETHER COMPUTER IS A PC
c = computer;
pc = strcmp(c(1:2),'PC');

if nargin == 0
  z = gcf;
  p = get(z,'pos');
  if (p(3) == fig_x) & (p(4) == fig_y)
    return
  end
end

% FONT SIZE MAPPING
font_size1 = [6 8 9 10 12 14 16 18 20 22 24 36 42];
font_size2 = [5 6 7  8 10 12 12 14 16 18 20 30 36];

% TYPE OF OBJECT TO RESIZE
t = get(z,'type');

% RESIZE FIGURE
if strcmp(t,'figure')
  p = [(width-fig_x)/2+left, (height-fig_y)/2+bottom fig_x fig_y];
  set(z,'pos',p);
  cc = get(z,'children');
  for i=1:length(cc)
    nnshrink(cc(i))
  end

% RESIZE AXIS IN FIGURE
elseif strcmp(t,'axes')
  p = get(z,'pos');
  set(z,'pos',p*factor);
  cc = [get(z,'children');
        get(z,'xlabel');
        get(z,'ylabel');
        get(z,'title')];
  for i=1:length(cc)
    nnshrink(cc(i))
  end

% RESIZE UICONTROLS IN FIGURE
elseif strcmp(t,'uicontrol');
  p = get(z,'pos');

  % STYLE OF UICONTROL TO RESIZE
  s = get(z,'style');

  % RESIZE PUSH BUTTON
  if strcmp(s,'pushbutton')
    p = [p(1) p(2) p(3) p(4)]*factor;

  % RESIZE RADIO BUTTON
  elseif strcmp(s,'radiobutton')
    p = [p(1) p(2) p(3) p(4)]*factor;

  % RESIZE CHECK BOX
  elseif strcmp(s,'checkbox')
    p = [p(1) p(2) p(3) p(4)]*factor;

  % RESIZE EDIT
  elseif strcmp(s,'edit')
    if ~pc
      factor2 = 0.9;
      p = [p(1)*factor p(2)*factor p(3)*factor2 p(4)*factor2];
    else
      p = [p(1) p(2) p(3) p(4)]*factor;
    end

  % RESIZE TEXT
  elseif strcmp(s,'text')
    p = [p(1) p(2) p(3) p(4)]*factor;

  % RESIZE SLIDER
  elseif strcmp(s,'slider')
    if (p(3) == 16)
      p = [p(1)*factor p(2)*factor p(3) p(4)*factor-2];
    else
      p = [p(1)*factor p(2)*factor-2 p(3)*factor p(4)];
    end

  % RESIZE POPUP MENU
  elseif strcmp(s,'popupmenu')
    p = [p(1) p(2) p(3) p(4)]*factor;
    set(z,'position',[50 50 p(3) p(4)]); % Avoid PC MATLAB bug
  end

  set(z,'position',p);

% RESIZE TEXT IN AXIS
elseif strcmp(t,'text')
  p = get(z,'pos');
  s = get(z,'fontsize');
  v = get(z,'string');
  i = find(font_size1 == s);
  
  if strcmp(v,'Neural Network') & (s == 16) & ~pc
    new_s = 10;
  elseif strcmp(v,'DESIGN') & (s == 16) & ~pc
    new_s = 10;
    set(z,'pos',[p(1)-7 p(2) p(3)])
  elseif (length(i) == 0)
    fprintf('Figure contains unexpected text size: %g',s);
  else
    new_s = font_size2(i);
  end
  set(z,'fontsize',new_s);
end

