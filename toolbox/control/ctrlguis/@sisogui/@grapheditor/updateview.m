function updateview(Editor,varargin)
%UPDATEVIEW  Triggers ViewChanged event.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/04/10 05:02:30 $
Editor.Axes.send('ViewChanged')