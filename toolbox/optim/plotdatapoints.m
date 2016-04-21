function h = plotdatapoints(t,y)
%PLOTDATAPOINTS Helper function for DATDEMO
h = plot(t,y,'b-','EraseMode','xor');
axis([0 2 -0.5 6])
hold on
plot(t,y,'ro','EraseMode','none'),    
title('Data points and fitted curve')
hold off