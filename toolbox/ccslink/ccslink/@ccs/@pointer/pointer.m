function nn = pointer(varargin)
%POINTER  Constructor for raw memory object 
%  MM = POINTER('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See MEMORYOBJ)
%  -----------------
%  REFTYPE - 
%
%  See Also CAST, READ, WRITE.

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2004/04/08 20:46:45 $

nn = ccs.pointer;
construct_pointer(nn,varargin);    

% [EOF] numeric.m
 