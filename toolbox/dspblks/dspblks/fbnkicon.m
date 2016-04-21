function z=fbnkicon(sel)
%FBNKICON Filter-Bank Block Icons
%   Constructs block icons for the filter bank blocks.


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2002/04/14 20:52:47 $

switch sel
case 'full analysis'
   % full-tree analysis
   xy=[facell(1,2,'top');facell(4,0);facell(4,4)];
   
case 'half analysis'
   % half-tree analysis
   xy=[hacell(1,2,2);hacell(4,0)];
   
case 'full synthesis'
   % full-tree synthesis
   xy=[fscell(0,0);fscell(0,4);fscell(3,2,'top')];

case 'half synthesis'
   % half-tree synthesis
   xy=[hscell(0,0);hscell(3,2,'top')];
   
end
z=xy(:,1) + i*xy(:,2);
return

function xy=fscell(x0,y0,isTop)
% Full-Synthesis Cell
n=NaN; n2=[n n];
xy=scell(x0,y0);
if nargin>2,
   xl = [  3   4]';
   yl = [1.5 1.5]';
   lines=[xl+x0 yl+y0];
   xy=[xy;n2;lines];
end
xy=[xy;n2];
return

function xy=facell(x0,y0,isTop)
% Full-Analysis Cell
n=NaN; n2=[n n];
xy=acell(x0,y0);
if nargin>2,
   xl = [ -1   0]';
   yl = [1.5 1.5]';
   lines=[xl+x0 yl+y0];
   xy=[xy;n2;lines];
end
xy=[xy;n2];
return

function xy=hscell(x0,y0,isTop)
% Half-Synthesis Cell
n=NaN; n2=[n n];
xy=scell(x0,y0);
if nargin>2,
   % Top cell has extra line segments:
   % The value of isTop indicates total # of analysis levels
   xl = [  0  x0, n, x0+3 x0+4]';
   yl = [2.5 2.5, n,  2.5  2.5]'+y0;
   lines=[xl yl];
   xy=[xy;n2;lines];
end
xy=[xy;n2];
return

function xy=hacell(x0,y0,isTop)
% Half-Analysis Cell
n=NaN; n2=[n n];
xy=acell(x0,y0);
if nargin>2,
   % Top cell has extra line segments:
   % The value of isTop indicates total # of analysis levels
   xl = [ -1   0, n,   3   3*isTop]';
   yl = [2.5 2.5, n, 2.5       2.5]';
   lines=[xl+x0 yl+y0];
   xy=[xy;n2;lines];
end
xy=[xy;n2];
return

function xy=scell(x0,y0)
% Draw one synthesis filter bank cell, with
%   lower-left corner at (x0,y0)
n=NaN; n2=[n n];
filts=[box(1+x0,0+y0);n2;box(1+x0,2+y0)];
xl=[ 0  1, n,   0   1, n,  2  3   3   2]';
yl=[.5 .5, n, 2.5 2.5, n, .5 .5 2.5 2.5]';
lines=[xl+x0 yl+y0];
xy=[filts;n2;lines;n2];
return

function xy=acell(x0,y0)
% Draw one analysis filter bank cell, with
%   lower-left corner at (x0,y0)
n=NaN; n2=[n n];
filts=[box(1+x0,0+y0);n2;box(1+x0,2+y0)];
xl=[ 1  0   0   1, n, 2  3, n,   2   3]';
yl=[.5 .5 2.5 2.5, n,.5 .5, n, 2.5 2.5]';
lines=[xl+x0 yl+y0];
xy=[filts;n2;lines;n2];
return

function xy=box(x0,y0)
% Draw one filter box with lower-left corner at (x0,y0)
% Unity height/width
xb=[0 1 1 0 0,  1 0]';
yb=[0 0 1 1 0, .5 1]';
xy=[xb+x0 yb+y0];
return

% [EOF] fbnkicon.m
