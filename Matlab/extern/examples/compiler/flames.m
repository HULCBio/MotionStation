function flames
%FLAMES creates an animation of the MathWorks logo rising through flames

%   Copyright (c) 1984-2000 by The MathWorks, Inc.
% $Revision: 1.1.4.1 $

figure('Menubar','None','NumberTitle','Off','Name','Demo','UserData',1);
set(gcf,'DoubleBuffer','On','Renderer','Painters','Resize','Off');
menu1 = uimenu('Label','&File');
menu2 = uimenu(menu1,'Label','E&xit');

%Only function calls are allowed in the C/C++ Graphics Library callbacks 
set(menu2,'Callback','set(gcf,''UserData'','''');');

X=[];
load flames.mat X

[a,b] = size(X);
x = ones(a,b)*.01;
x(end,:) = 201;
x(end-1,:) = 140;
x(end-2,:) = 60;
theImage = image(x);
set(theImage,'CDataMapping','Direct');
colormap([hot(200);[0 0 0]]);
axis off;
axis image;
set(gca,'YLim',[1 size(x,1)-2]);
set(gca,'Units','Pixels','Position',[15 15 1.5*a+30 1.5*b+30]);
theSize = get(0,'ScreenSize');
set(gcf,'Units','Pixels','Position',...
   [(theSize(3)-(1.5*a+60))/2 (theSize(4)-(1.5*b+60))/2 (1.5*a+60) (1.5*b+60)],...
   'Color',[0 0 0]);
animate_it(theImage,X);

%All figures must be closed for a C/C++ Graphics Library
%application to exit
close all;

function animate_it(theImage,theLogo);
%The algorithm used takes the last image used and based on a pixel-by-pixel
%basis deterime the next image. It uses the following rule for pixel X: that
%the new pixel value is based on the old value plus the two pixels below and 
%the two pixels two down and one to the right and left. Add in a bit of 
%randomness, normalize the matrix to one, and where ever the picture
%is 1, set that pixel to one.

X = get(theImage,'CData');

[a,b] = size(X);

%Pre-allocation of matricies speed up loops
theZeros = zeros(a,1);
theZeros2 = zeros(1,b);
theOnes = ones(1,b);
theRand = rand(a,b);
theLogical = [theLogo(1:end,:)];

%This loop causes the logo to rise.
for i = 1:a-1
   if ~isempty(get(gcf,'UserData'))
      theRand = [theRand(3:end,:);theRand(1:2,:)];
      movedUp = [X(2:end,:);theOnes];
      movedUp2 = [movedUp(2:end,:);theOnes];
      upAndLeftAndRight = ([movedUp2(:,2:end),theZeros]) + ...
         ([theZeros,movedUp2(:,1:end-1)]);
      theTemp = theRand .* X;
      X = theTemp + theTemp + movedUp + upAndLeftAndRight + movedUp2 ;
      X = X ./ max(max(X));
      X([zeros(a-i-1,b);theLogo(1:i+1,:)]==1) = 1;
      set(theImage,'CData',X.*201);
      drawnow;
   end
end

%This while loop just keeps cycling the flames until the window is
%closed.
while ~isempty(get(gcf,'UserData'))
   theRand = [theRand(3:end,:);theRand(1:2,:)];
   movedUp = [X(2:end,:);theOnes];
   movedUp2 = [movedUp(2:end,:);theOnes];
   upAndLeftAndRight = ([movedUp2(:,2:end),theZeros])+ ...
      ([theZeros,movedUp2(:,1:end-1)]);
   theTemp = theRand .* X;
   X = theTemp + theTemp + movedUp + upAndLeftAndRight + movedUp2 ;
   X = X ./ (max(max(X)));
   X(theLogical==1) = 1;
   set(theImage,'CData',X.*201);
   drawnow;
end
   


