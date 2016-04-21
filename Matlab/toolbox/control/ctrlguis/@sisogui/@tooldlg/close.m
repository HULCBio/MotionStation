function close(h, varargin)
%CLOSE  Hides dialog.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:06:46 $

if h.isVisible
    % Hide dialog
    h.Handles.Frame.hide;
    
    % RE: Needed to properly manage Constr.Selected when dialog becomes visible again
    %     Do it first to remove all constraint listeners.
    h.Constraint = [];
    h.ConstraintList = [];
    
    % RE: Needed to correctly update list of constraints after hiding dialog
    h.Container = [];
end
