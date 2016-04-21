function stop = psplotwashington(optimvalues,flag)
%PSPLOTWASHINGTON: PlotFcn to plot best function value.
%   STOP = PSPLOTDEMO(OPTIMVALUES,FLAG,INTERVAL) plots current best point.	
%   OPTIMVALUES: A structure containing several information about the state of
%   the solver including X, FVAL, iteration number, etc. 

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:18 $

global x y Z TIMETOPLOT HBEST HPOINTS POPU
stop = false;
if(strcmp(flag,'init'))
        set(gcf,'renderer','zbuffer','Position', get(gcf,'Position')+[30 30 30 0])
        contour(x,y,Z); 
        colormap(terrain);
        shading interp;
        hold on;
        %view(153,47); 
        view(157,90);
    HBEST = plot(optimvalues.x(1), ...
        optimvalues.x(2), ...
        'o','Tag','bestSoFar', ...
        'MarkerFaceColor','yellow', ...
        'MarkerEdgeColor',[1 0 1],'MarkerSize',8);
    set(gca,'Xlim',[min(x),max(x)],'Ylim',[min(y),max(y)])
    maxpause = 3; minpause = 1e-3;
    slider_step(1) = 0.4/(maxpause-minpause);
    slider_step(2) = 1/(maxpause-minpause);
    handles = uicontrol(gcf,'style','slider','Position',[550 50 20 200], ...
        'Tag','Myslider');
    set(handles,'sliderstep',slider_step,...
        'max',maxpause,'min',minpause,'Value',((minpause+maxpause)/2));
    shg
    title('Topography map of white mountains');
    drawnow
    TIMETOPLOT = true;
elseif strcmp(flag,'iter')
    handles = findobj(get(gcf,'children'),'Tag','Myslider');
    HBEST = plot(optimvalues.x(1), ...
        optimvalues.x(2), ...
        'o','Tag','bestSoFar', ...
        'MarkerFaceColor','c', ...
        'MarkerEdgeColor','c','MarkerSize',8);
    pause(get(handles,'value'))

    if ~isempty(HPOINTS) & ishandle(HPOINTS)
        %         set(HPOINTS,'Marker','o','MarkerFaceColor','yellow');
        set(HPOINTS,'Color','k')
    end
    
    good = POPU(:,1) <= max(x) & POPU(:,1) >= min(x) & ...
           POPU(:,2) <= max(y) & POPU(:,2) >= min(y);
    HPOINTS = plot(POPU(good,1),POPU(good,2), ...
        '+','Tag','allpoints', ...
        'Color','red','MarkerSize',8,'LineWidth',2); drawnow;
    
    pause(get(handles,'value'))

    if ~isempty(HBEST) & ishandle(HBEST)
        %dbstop here
        %pause(1)
        set(HBEST,'MarkerFaceColor','k')
    end

else
    return;
end