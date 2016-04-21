function conv_plotNextstates(nextStates)
% Utility function to display nextStates matrix for Convolutional Encoder demo
% with Uncoded Bits and Feedback.
% To open the model, type conv_encoderdemo.

%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/01 18:58:28 $

%-- Create a new figure to plot NextStates
figure;

%-- Declare and initialize intermediate variables
[numStates,numIn] = size(nextStates); 
yplot = NaN*ones(3*numIn,numStates);
yplot([1:3:end],:) = ones(numIn,1)*[0:numStates-1];
yplot([2:3:end],:) = nextStates';
xplot = repmat([1 numStates NaN]',numIn,numStates);

%-- Plot NextStates matrix
plot(xplot,yplot,'o-','MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor','k');
grid on; 
title('Plot of {\itNextStates} Matrix');
xlabel('State Transition');                      
set(gca,'yTick',[0:numStates-1],'YDir','Reverse',... 
    'YTickLabel',...
[dec2base([0:numStates-1],2) repmat('/',numStates,1) dec2base([0:numStates-1],8)], ...
    'YLim', [-1 numStates], 'Xlim',[0 numStates+1],'xTick',[1 numStates], ...
    'xTickLabel','N|N+1','Position',[.11 .1 .78 .8]);
ylabel('Initial State (Binary/Octal representation)',...
    'HorizontalAlignment','center','VerticalAlignment','Bottom');

axes('yTick',get(gca,'YTick'), ...
    'YAxisLocation','right','Color','none','XTick',[],'YLim',get(gca,'YLim'), ...
    'YTickLabel', get(gca,'YTickLabel'), ...
    'YDir','Reverse', 'Position',get(gca,'Position'));
ylabel('Final State (Binary/Octal representation)', ...
    'HorizontalAlignment','center','VerticalAlignment','Top');

%[EOF]