function doc_contain1
% Shows how to use hgtransform groups
% 

%  Copyright 2004 The MathWorks, Inc.

h_axes = axes('XLim',[-10 10],'YLim',[-5 5]);
set(get(h_axes,'Parent'),'Renderer','opengl','DoubleBuffer','on')

%% Create transform matrices

tmtx1 = makehgtform('translate',[-.5 0 0]);
tmtx2 = makehgtform('translate',[0 -.5 0]);

%% Create hgtransform objects

T = hgtransform;
t1 = hgtransform('Parent',T,'Matrix',tmtx1);
t2 = hgtransform('Parent',T,'Matrix',tmtx2);

%% Define cursor
[sx,sy,sz] = cylinder([0 2 0]);
h_text = text('FontSize',12,'FontWeight','bold',...
                'HorizontalAlignment','center',...
                'VerticalAlignment','Cap','Parent',T);
surface(sz,sy,sx,'FaceColor','green',...
                'EdgeColor','none','FaceAlpha',.2,'Parent',t1);
surface(sx,sz./1.5,sy,'FaceColor','blue',...
                'EdgeColor','none','FaceAlpha',.2,'Parent',t2);

%% Plot the data
x = -10:.05:10;
y = [cos(x) + exp(-.01*x).*cos(x) + exp(.07*x).*sin(3*x)];
z = 1:length(x);
line(x,y)

%% Walk the cursor along the line
for ind = 1:length(x)
    set(T,'Matrix',makehgtform('translate',[x(ind) y(ind) z(ind)]))
    set(h_text,'String',num2str(y(ind)))
    drawnow,pause(.03)
end


