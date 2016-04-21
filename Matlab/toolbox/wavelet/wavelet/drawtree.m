function fig = drawtree(t,varargin)
%DRAWTREE Draw wavelet packet decomposition tree.
%   DRAWTREE(T) draws the wavelet packet tree T.
%   F = DRAWTREE(T) returns the figure's handle.
%
%   For an existing figure F produced by a previous call
%   to the DRAWTREE function, DRAWTREE(T,F) draws the wavelet 
%   packet tree T in the figure whose handle is F.
%
%   Example:
%     x   = sin(8*pi*[0:0.005:1]);
%     t   = wpdec(x,3,'db2');
%     fig = drawtree(t);
%     %---------------------------------------
%     % Use command line function to modify t
%     %---------------------------------------
%     t   = wpjoin(t,2);
%     drawtree(t,fig);
%
%   See also READTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $

%--------------%
% OLD VERSION  %
%--------------%
%   DRAWTREE(T,D) draws the wavelet packet tree T.
%   D is the data structure associated with T.
%   F = DRAWTREE(T,D) returns the figure's handle.
%
%   For an existing figure F produced by a previous call
%   to the DRAWTREE function, DRAWTREE(T,F) draws the wavelet 
%   packet tree T in the figure whose handle is F.
%
%   Example:
%     x = sin(8*pi*[0:0.005:1]);
%     [t,d] = wpdec(x,3,'db2');
%     fig   = drawtree(t,d);
%     %--------------------------------------------
%     % Use command line function to modify t or d
%     %--------------------------------------------
%     [t,d] = wpjoin(t,d,2);
%     drawtree(t,d,fig);
%
%   See also READTREE.

% Check arguments.
%-----------------
nbIn = nargin;
switch nbIn
  case {0}  , error('Not enough input arguments.');
      
  case {1,2,3} 
      if isa(t,'wptree')
          maxarg = 2;
      else
          maxarg = 3;
      end
      if (nbIn>maxarg) , error('Too many input arguments.'); end
      
  otherwise , error('Too many input arguments.');
end

% Draw tree.
%-----------
order = treeord(t);
switch order
    case 2 , prefix = 'wp1d';
    case 4 , prefix = 'wp2d';
end
func1 = [prefix 'tool'];
func2 = [prefix 'mngr'];

newfig = 1;
if nargin==maxarg
    fig = varargin{end};
    varargin(end) = [];
    wins = wfindobj('figure');
    if ~isempty(find(wins==fig))
        tagfig = lower(get(fig,'tag'));
        if isequal(func1,tagfig) , newfig = 0; end
    end
end
if newfig , fig = feval(func1); end
feval(func2,'load_dec',fig,t,varargin{:});
