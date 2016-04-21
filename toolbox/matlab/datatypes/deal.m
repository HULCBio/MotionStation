function varargout = deal(varargin)
%DEAL Deal inputs to outputs.
%    [A,B,C,...] = DEAL(X,Y,Z,...) simply matches up the input and
%       output lists.  It is the same as A=X, B=Y, C=Z, ...
%    [A,B,C,...] = DEAL(X) copies the single input to all
%       the requested outputs.  It is the same as A=X, B=X, C=X, ...
%
%    DEAL is most useful when used with cell arrays and structures
%    via comma separated list expansion.  Here are some useful
%    constructions:
%    [S.FIELD] = DEAL(X) sets all the fields with the name FIELD
%       in the structure array S to the value X.  If S doesn't
%       exist, use [S(1:M).FIELD] = DEAL(X);
%    [X{:}] = DEAL(A.FIELD) copies the values of the field with
%       name FIELD to the cell array X.  If X doesn't exist,
%       use [X{1:M}] = DEAL(A.FIELD).
%    [A,B,C,...] = DEAL(X{:}) copies the contents of the cell
%       array X to the separate variables A,B,C,...
%    [A,B,C,...] = DEAL(S.FIELD) copies the contents of the fields
%       with the name FIELD to separate variables A,B,C,...
%
%    Examples:
%       sys = {rand(3) ones(3,1) eye(3) zeros(3,1)};
%       [a,b,c,d] = deal(sys{:});
%
%       direc = dir; filenames = {};
%       [filenames{1:length(direc),1}] = deal(direc.name);
%
%    See also LISTS, PAREN.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2004/01/26 23:20:45 $

if (nargout ~= nargin) && nargin ~= 1,
  error('MATLAB:deal:narginNargoutMismatch',...
      'The number of outputs should match the number of inputs.')
end

if nargin==1,
  varargout = varargin(ones(1,max(1,nargout)));
else
  varargout = varargin;
end
