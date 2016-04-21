function [stop,options,optchanged]  = psoutputwashington(optimvalues,options,flag)
%PSOUTPUTWASHINGTON: OutputFcn to plot best function value.
%   STOP = PSOUTPUTWASHINGTON(OPTIMVALUES,OPTIONS,FLAG) is an output function which 
%   plot current best point on a 3-d graph of the function @terrainfun.	
%   OPTIMVALUES: A structure containing several information about the state of
%   the solver including X, FVAL, iteration number, etc. 

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:17 $

global x y Z
persistent fig
stop = false;
optchanged = false;
if(strcmp(flag,'init')) || isempty(findobj(0,'Type','figure','name','White Mountains'))
    fig = findobj(0,'type','figure','name','White Mountains');
    if isempty(fig)   
     fig = figure('visible','off');
    end
    set(0,'CurrentFigure',fig);
    clf;
    set(fig,'DoubleBuffer','on','numbertitle','off','name','White Mountains', ...
        'userdata',[],'Renderer','zbuffer');
    set(fig,'renderer','zbuffer')
    h = surf(x(1:2:end),y(1:2:end),Z(1:2:end, 1:2:end)); %axis equal;
    set(h,'EdgeColor','none');
    rotate3d;colormap(terrain);
    shading interp;light;lighting phong
    hold on;view(153,47);
    hh = plot3(optimvalues.x(1), ...
        optimvalues.x(2), ...
        -optimvalues.fval,'o','Tag','bestSoFar', ...
        'MarkerFaceColor','r', ...
        'MarkerEdgeColor','r', 'MarkerSize',8);
    set(gca,'Xlim',[min(x),max(x)],'Ylim',[min(y),max(y)])
    shg
    title('White mountains');
elseif strcmp(flag,'iter')
   set(0,'CurrentFigure',fig);
    plot3(optimvalues.x(1), ...
        optimvalues.x(2), ...
        -optimvalues.fval,'o','Tag','bestSoFar', ...
        'MarkerFaceColor','r', ...
        'MarkerEdgeColor','r','MarkerSize',8);
elseif strcmp(flag,'done')
     set(0,'CurrentFigure',fig);
         plot3(optimvalues.x(1), ...
        optimvalues.x(2), ...
        -optimvalues.fval,'*','Tag','bestSoFar', ...
        'MarkerFaceColor','b', 'LineWidth',4, ...
        'MarkerEdgeColor','b','MarkerSize',16);
end