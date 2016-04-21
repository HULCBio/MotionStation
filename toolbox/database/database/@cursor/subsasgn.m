function A = subsasgn(A,S,B)
%SUBSASGN Assign a value to an an Database Cursor object.
%  SUBSASGN is currently only implemented for dot assignment.
%  For example:
%    H.PROPERTY=VALUE
%
%  See also: SET.


% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.5.4.2 $  $Date: 2004/04/06 01:05:13 $

if strcmp(S.type,'.')
  A = set(A,S.subs,B);
else,
  error('database:cursor:subsasgnFailure','Invalid SUBSASGN indexing method.')     
end % switch
