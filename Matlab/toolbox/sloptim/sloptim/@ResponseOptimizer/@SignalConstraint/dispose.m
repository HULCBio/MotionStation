function dispose(this,BoundType,idx)
% Deletes constraint #IDX of type BOUNDTYPE.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:50 $
%   Copyright 1990-2004 The MathWorks, Inc.

% RE: assumes idx < #segments
switch BoundType
   case 'LowerBound'
      % Replace [A,B] + [C,D] by [A*,D] where A* line up with CD
      % Get end points 
      xD = this.LowerBoundX(idx+1,2);
      yD = this.LowerBoundY(idx+1,2);
      a = diff(this.LowerBoundY(idx+1,:))/...
         diff(this.LowerBoundX(idx+1,:));
      b = yD - a*xD;
      xA = this.LowerBoundX(idx,1);
      yA = a*xA+b;
      % Translate this segment down by |dY| to clear all upper vertices in range
      % [xA,xD]
      ubx = this.UpperBoundX(:);
      uby = this.UpperBoundY(:);
      idv = find(ubx>=xA & ubx<=xD);
      dy = 1.1 * min([0;uby(idv)-a*ubx(idv)-b]);
      % Construct new lower bound
      this.LowerBoundX = ...
         [this.LowerBoundX(1:idx-1,:) ; [xA xD] ; this.LowerBoundX(idx+2:end,:)];
      this.LowerBoundY = ...
         [this.LowerBoundY(1:idx-1,:) ; [yA yD]+dy ; this.LowerBoundY(idx+2:end,:)];
      this.LowerBoundWeight(idx) = [];
      
   case 'UpperBound'
      xD = this.UpperBoundX(idx+1,2);
      yD = this.UpperBoundY(idx+1,2);
      a = diff(this.UpperBoundY(idx+1,:))/...
         diff(this.UpperBoundX(idx+1,:));
      b = yD - a*xD;
      xA = this.UpperBoundX(idx,1);
      yA = a*xA+b;
      % Translate this segment down by |dY| to clear all upper vertices in range
      % [xA,xD]
      ubx = this.LowerBoundX(:);
      uby = this.LowerBoundY(:);
      idv = find(ubx>=xA & ubx<=xD);
      dy = 1.1 * max([0;uby(idv)-a*ubx(idv)-b]);
      % Construct new upper bound
      this.UpperBoundX = ...
         [this.UpperBoundX(1:idx-1,:) ; [xA xD] ; this.UpperBoundX(idx+2:end,:)];
      this.UpperBoundY = ...
         [this.UpperBoundY(1:idx-1,:) ; [yA yD]+dy ; this.UpperBoundY(idx+2:end,:)];
      this.UpperBoundWeight(idx) = [];
end
