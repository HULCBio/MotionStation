function conv_plotOutputs(outputs, numOutSymb)
% Utility function to display outputs matrix for Convolutional Encoder demo
% with Uncoded Bits and Feedback.
% To open the model, type conv_encoderdemo.

%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/01 18:58:29 $

%-- Create a new figure to plot Output matrix
figure;

%-- Declare and initialize intermediate variables
[numStates,numIn] = size(outputs); 
yplot = NaN*ones(3*numIn,numStates);
offset = floor((numOutSymb-numStates)/2);
yplot([1:3:end],:) = ones(numIn,1)*[0:numStates-1]+offset;
yplot([2:3:end],:) = oct2dec(outputs)';
xplot = repmat([1 numStates NaN]',numIn,numStates);

%-- Plot Output matrix
plot(xplot,yplot,'o-','MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor','k');
grid on; 
title('Plot of {\itOutputs} Matrix');
xlabel('State Transition');                      
set(gca,'yTick',[0:numOutSymb-1],'YDir','Reverse',... 
    'YTickLabel', ...
    [repmat(' ',offset,log2(numStates)+1+ceil(numStates/8)); ...
    dec2base([0:numStates-1],2) repmat('/',numStates,1) dec2base([0:numStates-1],8); ...
    repmat(' ',numOutSymb-numStates-offset,log2(numStates)+1+ceil(numStates/8))], ...
    'YLim', [-1 numOutSymb],'Xlim',[0 numStates+1],'xTick',[1 numStates], ...
    'xTickLabel','N|N+1','Position',[.11 .1 .76 .8]);
ylabel('Initial State (Binary/Octal representation)',...
    'HorizontalAlignment','center','VerticalAlignment','Bottom');

axes('yTick',[0:numOutSymb-1], ...
    'YAxisLocation','right','Color','none','XTick',[],'YLim',get(gca,'YLim'), ...
    'YTickLabel',...
    [dec2base([0:numOutSymb-1],2) repmat('/',numOutSymb,1) dec2base([0:numOutSymb-1],8)], ...
    'YDir','Reverse', 'Position',get(gca,'Position'));
ylabel('Output Symbol (Binary/Octal representation)', ...
    'HorizontalAlignment','center','VerticalAlignment','Top');

%[EOF]