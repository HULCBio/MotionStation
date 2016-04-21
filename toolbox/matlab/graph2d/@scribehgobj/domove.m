function aObj = domove(aObj, x, y)
%SCRIBEHGOBJ/DOMOVE Move scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:13:25 $

figH = gcbf; oldFigUnits = get(figH,'Units');
oldAxUnits = get(A,'Units');

set(figH,'Units','pixels');
myFigPos = get(figH,'Position');


set(A,'Units','pixels');
pos = get(A,'Position');

% restore original units
set(figH,'Units',oldFigUnits);
set(0,'Units',oldUnits);

% update my position
A = set(A,'Units',oldAxUnits);


function hit = IsInRect(rect,pt)
% ISINRECT Local function

% rect = [l b w h]
rectBounds = [rect(1:2) ; rect(1:2)+rect(3:4)];
% rectBounds = [l b; r t];
hit = (pt >= rectBounds(1,:)) & (pt <=rectBounds(2,:));

