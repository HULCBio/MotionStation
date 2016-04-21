function buttonmotionfcn2D(hZoom)
% Mouse Button Motion Function

% Copyright 2003 The MathWorks, Inc.

% This zoom code originates from signal and simulink toolbox

if strcmp(hZoom.Debug,'on')
    disp('buttonmotionfcn')
end

hLines         = get(hZoom,'LineHandles');
currentAxes    = get(hZoom,'CurrentAxes');

% The first axes in currentAxes is the one on the top. On this axes the
% lines are to be drawn.
cAx            = currentAxes(1);
cp             = get(cAx, 'CurrentPoint'); cp = cp(1,1:2);
xcp            = cp(1);
ycp            = cp(2);

% The first point of line 1 is always the zoom origin.
XDat   = get(hLines(1), 'XData');
YDat   = get(hLines(1), 'YData');
origen = [XDat(1), YDat(1)];

% Consider log plots
% TBD
isxlog = logical(0); isylog = logical(0);
if strcmpi(get(cAx,'xscale'),'log')
  isxlog = logical(1);
end
if strcmpi(get(cAx,'yscale'),'log')
  isylog = logical(1);
end

% Draw rbbox depending on mode.
switch(get(hZoom,'Constraint')),
    case 'none',
        % Both x and y zoom.
        % RBBOX - lines:
        % 
        %          2
        %    o-------------
        %    |            |
        %  1 |            | 4
        %    |            |
        %    --------------
        %          3
        %

        % Set data for line 1.
        YDat = get(hLines(1), 'YDat');
        YDat(2) = ycp;
        set(hLines(1),'YDat',YDat);
        
        % Set data for line 1.
        XDat = get(hLines(2),'XDat');
        XDat(2) = xcp;
        set(hLines(2),'XDat',XDat);
        
        % Set data for line 3.
        XDat = get(hLines(3),'XDat');
        YDat = [ycp ycp];
        XDat(2) = xcp;
        set(hLines(3),'XDat',XDat,'YDat',YDat);

        % Set data for line 4.
        YDat = get(hLines(4), 'YDat');
        XDat = [xcp xcp];
        YDat(2) = ycp;
        set(hLines(4),'XDat',XDat,'YDat',YDat);
        
    case 'horizontal',
        % x only zoom.
        % RBBOX - lines (only 1-3 used):
        %   
        %    |     1      |
        %  2 o------------| 3 
        %    |            |
        %             
        
        % Set the end bracket lengths (actually the halfLength).
        YLim = get(get(gcbf,'CurrentAxes'), 'YLim');
        
        % Set data for line 1.
        XDat = get(hLines(1),'XDat');
        XDat(2) = xcp;
        set(hLines(1),'XDat',XDat);

        if isylog
          YLim = log10(YLim);
          origen = log10(origen);
        end

        endHalfLength = (YLim(2) - YLim(1)) / 30;
        YDat = [origen(2) - endHalfLength, origen(2) + endHalfLength];

        if isylog
          YDat = 10.^YDat;
        end

        % Set data for line 2.
        set(hLines(2), 'YDat', YDat);
                
        % Set data for line 3.
        XDat = [xcp xcp];
        set(hLines(3), 'XDat', XDat, 'YDat', YDat);
        
    case 'vertical',
        % y only zoom.
        % RBBOX - lines (only 1-3 used):
        %    2
        %  --o--  
        %    |
        %  1 |
        %    |
        %  -----           
        %    3
        %
        
        % Set the end bracket lengths (actually the halfLength).
        XLim = get(get(gcbf,'CurrentAxes'), 'XLim');
        
        if isxlog
          XLim = log10(XLim);
          origen = log10(origen);
        end
        
        endHalfLength = (XLim(2) - XLim(1)) / 30;
        
        % Set data for line 1.
        YDat = get(hLines(1),'YDat');
        YDat(2) = ycp;
        set(hLines(1),'YDat',YDat);
        
        % Set data for line 2.
        XDat = [origen(1) - endHalfLength, origen(1) + endHalfLength];
        if isxlog
          XDat = 10.^XDat;
        end
        set(hLines(2), 'XDat', XDat);
        
        % Set data for line 3.
        YDat = [ycp ycp];
        set(hLines(3), 'XDat', XDat, 'YDat', YDat);
end






