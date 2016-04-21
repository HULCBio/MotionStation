function object = gco(fig)
%GCO Get handle to current object.
%   OBJECT = GCO returns the current object in the current figure.
%
%   OBJECT = GCO(FIG) returns the current object in the figure FIG.
%
%   The current object is the last object clicked on, excluding
%   uimenus.  If the click was not over a figure child, the
%   figure itself will be the current object.
%
%   The handle of the current object is stored in the figure
%   property CurrentObject, and can be accessed directly using GET
%   and SET.
%
%   Use GCO in a callback to obtain the handle of the object that
%   was clicked on.  MATLAB updates the current object before
%   executing each callback, so the current object may change if
%   one callback is interrupted by another.  To obtain the right
%   handle during a callback, get the current object early, before
%   any calls to DRAWNOW, WAITFOR, PAUSE, FIGURE, or GETFRAME which
%   provide opportunities for other callbacks to interrupt.
%
%   If no figures exist, GCO returns [].
%
%   See also GCBO, GCF, GCA, GCBF.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.21 $  $Date: 2002/04/10 17:07:44 $

if isempty (get (0, 'Children')),
    object = [];
    return;
end;

if(nargin == 0)
    fig = get(0,'CurrentFigure');
end

object = get( fig, 'CurrentObject');
