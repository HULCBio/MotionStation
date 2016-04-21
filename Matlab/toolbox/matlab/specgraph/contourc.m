function [varargout] = contourc(varargin)
%CONTOURC Contour computation.
%   CONTOURC calculates the contour matrix C for use by CONTOUR,
%       CONTOUR3, or CONTOURF to draw the actual contour plot.
%   C = CONTOURC(Z) computes the contour matrix for a contour plot
%      of matrix Z treating the values in Z as heights above a plane.
%   C = CONTOURC(X,Y,Z), where X and Y are vectors, specifies the X- 
%      and Y-axes limits for Z.
%   CONTOURC(Z,N) and CONTOURC(X,Y,Z,N) compute N contour lines, 
%      overriding the default automatic value.
%   CONTOURC(Z,V) and CONTOURC(X,Y,Z,V) compute LENGTH(V) contour 
%      lines at the values specified in vector V.
%   
%   The contour matrix C is a two row matrix of contour lines. Each
%   contiguous drawing segment contains the value of the contour, 
%   the number of (x,y) drawing pairs, and the pairs themselves.  
%   The segments are appended end-to-end as
% 
%       C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%            pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%
%   See also CONTOUR, CONTOURF, CONTOUR3.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/10 23:31:42 $
%   Built-in function.

if nargout == 0
  builtin('contourc', varargin{:});
else
  [varargout{1:nargout}] = builtin('contourc', varargin{:});
end
