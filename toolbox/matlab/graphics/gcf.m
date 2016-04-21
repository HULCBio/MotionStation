function h = gcf()
%GCF Get handle to current figure.
%   H = GCF returns the handle of the current figure. The current
%   figure is the window into which graphics commands like PLOT,
%   TITLE, SURF, etc. will draw.
%
%   The handle of the current figure is stored in the root
%   property CurrentFigure, and can be queried directly using GET,
%   and modified using FIGURE or SET.
%
%   Clicking on uimenus and uicontrols contained within a figure,
%   or clicking on the drawing area of a figure cause that
%   figure to become current.
%
%   The current figure is not necessarily the frontmost figure on
%   the screen.
%
%   GCF should not be relied upon during callbacks to obtain the
%   handle of the figure whose callback is executing - use GCBO
%   for that purpose.
%
%   See also FIGURE, CLOSE, CLF, GCA, GCBO, GCO, GCBF.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.17 $  $Date: 2002/04/10 17:07:02 $

h = get(0,'CurrentFigure');

% 'CurrentFigure' is no longer guaranteed to return a figure,
% so we might need to create one (because gcf IS guaranteed to
% return a figure)
if isempty(h)
  h = figure;
end
