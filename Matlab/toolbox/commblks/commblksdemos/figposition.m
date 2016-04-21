function y=figposition(x)
%FIGPOSITION Positions figure window irrespective of the screen resolution
% Y=FIGPOSITION(X) generates a vector the size of X. 
% This specifies the location of the figure window in pixels
% 
% X is a row vector of size [4 x 1], the first two elements specify where
% the lower left corner of the figure is located and the last two
% elements refer to the width and height of the figure window.
% 
% Example:
% If you would like to position the left bottom corner
% of the figure window 10% from the screen corner, you
% will choose the first column of the x as 10. 
% 
% >> y=figposition([0 30 40 40]);
%
% Here the figure's lower left corner is 0% away from the
% left bottom location of the screen and 30% above the 
% bottom most location. The figure has a width and height
% equal to 40% of the horizontal resolution of the screen size
% and 40% of the vertical resolution of the screen size.

% Copyright 1996-2002 The MathWorks, Inc.
% $ Revision 1.1$ $Date: 2002/04/09 02:13:20 $

% Procure the screen resolution
screenRes=get(0,'ScreenSize');
% Convert x to pixels
y(1,1)=(x(1,1)*screenRes(1,3))/100;
y(1,2)=(x(1,2)*screenRes(1,4))/100;
y(1,3)=(x(1,3)*screenRes(1,3))/100;
y(1,4)=(x(1,4)*screenRes(1,4))/100;

