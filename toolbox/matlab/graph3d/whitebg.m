function whitebg(fig,c)
%WHITEBG Change axes background color.
%   WHITEBG(FIG,C) sets the default axes background color of the
%   figures in the vector FIG to the color specified by C.  Other axes
%   properties and the figure background color may change as well so
%   that graphs maintain adequate contrast.  C can be a 1-by-3 rgb
%   color or a color string such as 'white' or 'w'. If the axes color
%   is 'none', the figure color (instead of the axes color) is set to
%   the requested color.
%
%   WHITEBG(FIG) complements the colors of the objects in the
%   specified figures.  This syntax is typically used to toggle
%   between black and white axes background colors and is where
%   WHITEBG gets its name.  Include the root window handle (0) in FIG
%   to affect the default properties for new windows or for CLF RESET.
%
%   Without a figure specification, WHITEBG or WHITEBG(C) affect the
%   current figure and the root's default properties so subsequent
%   plots and new figures use the new colors.
%
%   WHITEBG works best in cases where all the axes in the figure have
%   the same background color.
%
%   See also COLORDEF.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 04:29:07 $

% Note: Certain elements of the plot are always reset to be white or
% black.  These are the axes and labels colors, surface edge color,
% and default line and text colors.

rgbspec = [1 0 0;0 1 0;0 0 1;1 1 1;0 1 1;1 0 1;1 1 0;0 0 0];
cspec = ['rgbwcmyk'];
def = ['wk' % Default text colors
       'wk' % Default axesxcolors and xlabel colors
       'wk' % Default axesycolors and ylabel colors
       'wk' % Default axeszcolors and zlabel colors
       'wk' % Default patch face color
       'kk' % Default patch and surface edge color
       'wk' % Default line colors
];

if nargin==0,
  fig = [gcf 0];
  if isstr(get(fig(1),'defaultaxescolor')),
    c = 1 - get(fig(1),'color');
  else
    c = 1 - get(fig(1),'defaultaxescolor');
  end

elseif nargin==1,
  if isequal(size(fig),[1 3]) & max(max(fig))<=1, 
    c = fig; fig = [gcf 0];
  elseif isstr(fig),
    c = fig; fig = [gcf 0];
  else
    c = zeros(length(fig),3);
    for i=1:length(fig),
      if isstr(get(fig(i),'defaultaxescolor')),
        if fig(i)==0,
          c(i,:) = 1 - get(fig(i),'defaultfigurecolor');
        else
          c(i,:) = 1 - get(fig(i),'color');
        end
      else
        c(i,:) = 1 - get(fig(i),'defaultaxescolor');
      end
    end
  end
end

if length(fig)~=size(c,1) & ~isstr(c)
  c = c(ones(length(fig),1),:);
end

% Deal with string color specifications.
if isstr(c),
  k = find(cspec==c(1));
  if isempty(k), error('Unknown color string.'); end
  if k~=3 | length(c)==1,
    c = rgbspec(k,:);
  elseif length(c)>2,
    if lower(c(1:3))=='bla',
      c = [0 0 0];
    elseif lower(c(1:3))=='blu',
      c = [0 0 1];
    else
      error('Unknown color string.');
    end
  end
  c = c(ones(length(fig),1),:);
end

n = size(c,1);
lum = [.298936021 .58704307445 .114020904255]*c';
mode = (lum>=.5) + 1; % mode = 1 for black, mode = 2 for white.

for k=1:n,  % Change all the requested figures
  set(fig(k),'defaulttextcolor',def(1,mode(k)))
  set(fig(k),'defaultaxesxcolor',def(2,mode(k)))
  set(fig(k),'defaultaxesycolor',def(3,mode(k)))
  set(fig(k),'defaultaxeszcolor',def(4,mode(k)))
  set(fig(k),'defaultpatchfacecolor',def(5,mode(k)))
  set(fig(k),'defaultpatchedgecolor',def(6,mode(k)))
  set(fig(k),'defaultsurfaceedgecolor',def(6,mode(k)))
  set(fig(k),'defaultlinecolor',def(7,mode(k)))
  if (get(0,'ScreenDepth') == 1)
    if mode(k)==1, co = [1 1 1]; else co = [0 0 0]; end
  else
    co = get(fig(k),'defaultaxescolororder');
  end
  % Possibly complement the figure color if axis color isn't 'none'
  if ~isstr(get(fig(k),'defaultaxescolor')),
    fc = get(fig(k),'defaultaxescolor');
    clum = ([.298936021 .58704307445 .114020904255]*fc' >= .5) + 1;
    if fig(k)==0,
      set(fig(k),'defaultfigurecolor',brighten(0.2*(mode(k)==1)+0.8*c(k,:),.3))
    else
      set(fig(k),'color',brighten(.2*(mode(k)==1)+0.8*c(k,:),.3))
    end
    set(fig(k),'defaultaxescolor',c(k,:))
    if (clum==1 & mode(k)==2) | (clum==2 & mode(k)==1),
      set(fig(k),'defaultaxescolororder',1-co)
    end
  else
    if fig(k)==0,
      set(fig(k),'defaultfigurecolor',c(k,:))
    else,
      fc = get(fig(k),'color');
      set(fig(k),'color',c(k,:))
    end
  end

  % Blindly turn InvertHardcopy on
  if fig(k)==0, 
    set(fig(k),'defaultfigureinverthardcopy','on');
  else
    set(fig(k),'inverthardcopy','on');
  end
      
  if fig(k)~=0,
    % Now set the properties of the figure and axes in the current figure.
    h = get(fig(k),'children');
    for i=1:length(h),
      if strcmp(get(h(i),'Type'),'axes'),
        % Complement the figure and their contents if necessary
        if ~isstr(get(h(i),'color')),
          ac = get(h(i),'color');
        else
          ac = fc;
        end
        clum = ([.298936021 .58704307445 .114020904255]*ac' >= .5) + 1;
        if (clum==1 & mode(k)==2) | (clum==2 & mode(k)==1),
          complement = 1;
        else
          complement = 0;
        end
        if complement
          co = get(h(i),'colororder');
          set(h(i),'colororder',1-co);
        end
        hh = [get(h(i),'Title')
              get(h(i),'xlabel')
              get(h(i),'ylabel')
              get(h(i),'zlabel')
              get(h(i),'children')];
        for j=1:length(hh),
          tt = get(hh(j),'Type');
          if  strcmp(tt,'text') | strcmp(tt,'line'),
            if isequal(get(hh(j),'Color'),ac),
              set(hh(j),'Color',c(k,:))
            elseif complement,
              set(hh(j),'Color',1-get(hh(j),'Color'))
            end
          elseif strcmp(tt,'surface'),
            if ~isstr(get(hh(j),'FaceColor'))
              if isequal(get(hh(j),'FaceColor'),ac),
                set(hh(j),'FaceColor',c(k,:))
              elseif complement,
                set(hh(j),'FaceColor',1-get(hh(j),'FaceColor'))
              end
              if ~isstr(get(hh(j),'EdgeColor'))
                if isequal(get(hh(j),'EdgeColor'),ac),
                  set(hh(j),'EdgeColor',c(k,:))
                elseif complement,
                  set(hh(j),'EdgeColor',1-get(hh(j),'EdgeColor'))
                end
              end
            elseif strcmp(get(hh(j),'FaceColor'),'none')
              if ~isstr(get(hh(j),'EdgeColor'))
                if isequal(get(hh(j),'EdgeColor'),ac),
                  set(hh(j),'EdgeColor',c(k,:))
                elseif complement,
                  set(hh(j),'EdgeColor',1-get(hh(j),'EdgeColor'))
                end
              end
            end
          elseif strcmp(tt,'patch')
            if ~isstr(get(hh(j),'EdgeColor'))
              if isequal(get(hh(j),'EdgeColor'),ac),
                set(hh(j),'EdgeColor',c(k,:))
              elseif complement,
                set(hh(j),'EdgeColor',1-get(hh(j),'EdgeColor'))
              end
            end
            if ~isstr(get(hh(j),'FaceColor'))
              if isequal(get(hh(j),'FaceColor'),ac),
                set(hh(j),'FaceColor',c(k,:))
              elseif complement,
                set(hh(j),'FaceColor',1-get(hh(j),'FaceColor'))
              end
            end
          end
        end

        % Set the color of the axes if necessary
        set(h(i),'xcolor',def(2,mode(k)))
        set(h(i),'ycolor',def(3,mode(k)))
        set(h(i),'zcolor',def(4,mode(k)))
        if ~isstr(get(h(i),'color')) | ~isstr(get(fig(k),'defaultaxescolor'))
          set(h(i),'color',c(k,:))
        end
      end
    end
  end
end
