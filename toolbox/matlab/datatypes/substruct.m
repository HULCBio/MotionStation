function s = substruct(varargin)
%SUBSTRUCT Create structure argument for SUBSREF or SUBSASGN.
%    S = SUBSTRUCT(TYPE1,SUBS1,TYPE2,SUBS2,...) creates a structure with 
%    the fields required by an overloaded SUBSREF or SUBSASGN method.
%    Each TYPE string must be one of '.', '()', or '{}'.  The  
%    corresponding SUBS argument must be either a field name (for 
%    the '.' type) or a cell array containing the index vectors (for 
%    the '()' or '{}' types).  The output S is a structure array
%    containing the fields:
%       type -- subscript types '.', '()', or '{}'
%       subs -- actual subscript values (field names or cell arrays
%               of index vectors)
%
%    For example, to call SUBSREF with parameters equivalent to the syntax
%       B = A(i,j).field
%    use
%       S = substruct('()',{i j},'.','field');
%       B = subsref(A,S);
%    Similarly,
%       subsref(A, substruct('()',{1:2, ':'}))  performs  A(1:2,:)
%       subsref(A, substruct('{}',{1 2 3}))     performs  A{1,2,3}.
%
%    See also SUBSREF, SUBSASGN.

%       Copyright 1984-2004 The MathWorks, Inc. 
%       $Revision: 1.7.4.1 $  $Date: 2004/01/26 23:20:53 $

ni = nargin;
if ni<2,
   error('MATLAB:substruct:nargin', 'SUBSTRUCT takes at least two arguments.')
elseif rem(nargin,2),
   error('MATLAB:substruct:narginOdd',...
       'SUBSTRUCT takes an even number of arguments.')
end

s = struct('type',varargin(1:2:end),'subs',varargin(2:2:end));
