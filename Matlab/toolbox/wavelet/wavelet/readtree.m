function [t,d] = readtree(fig)
%READTREE Read wavelet packet decomposition tree from a figure.
%   T = READTREE(F) reads the wavelet packet
%   decomposition tree from the figure F.
%
%   Example:
%     x   = sin(8*pi*[0:0.005:1]);
%     t   = wpdec(x,3,'db2');
%     fig = drawtree(t);
%     %-------------------------------------
%     % Use the GUI to split or merge Nodes.
%     %-------------------------------------
%     t = readtree(fig);
%
%   See also DRAWTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $

%--------------%
% OLD VERSION  %
%--------------%
%   [T,D] = READTREE(F) reads the Wavelet Packet
%   Decomposition in the figure F.
%   T is the tree structure and D is the data structure
%   associated with T.
%
%   Example:
%     x = sin(8*pi*[0:0.005:1]);
%     [t,d] = wpdec(x,3,'db2');
%     fig   = drawtree(t,d);
%     %-------------------------------------
%     % Use the GUI to split or merge Nodes.
%     %-------------------------------------
%     [t,d] = readtree(fig);
%
%   See also DRAWTREE.

wins = wfindobj('figure');
if ~isempty(find(wins==fig))
    func = lower(get(fig,'tag'));
    if isequal(func,'wp1dtool') | isequal(func,'wp2dtool')
        [t,d] = feval(func,'read',fig);
    else
        t = []; d = [];
        msg = sprintf('no tree and data structures in the figure %s', num2str(fig));
        warndlg(msg,'WARNING');
    end
else
    msg = sprintf('invalid number for figure : %s', num2str(fig));
    warndlg(msg,'WARNING');
end
