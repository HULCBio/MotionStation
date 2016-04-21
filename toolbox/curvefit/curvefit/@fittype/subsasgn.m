function c = subsasgn(FITTYPE_OBJ_, varargin)
%SUBSASGN    subsasgn of fittype objects.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:42:58 $

error('curvefit:fittype:subsasgn:subsasgnNotAllowed', ...
   '%s objects can''t be assigned to using subscripts.\n',class(FITTYPE_OBJ_));