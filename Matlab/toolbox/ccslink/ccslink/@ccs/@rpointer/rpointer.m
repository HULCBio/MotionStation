function nn = rpointer(varargin)
%POINTER  Constructor for raw memory object 
%  MM = POINTER('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See MEMORYOBJ)
%  -----------------
%  REFTYPE - 
%
%  See Also CAST, READ, WRITE.

% 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $ $Date: 2003/11/30 23:12:04 $

nn = ccs.rpointer;
construct_rpointer(nn,varargin);    

% [EOF] numeric.m
 