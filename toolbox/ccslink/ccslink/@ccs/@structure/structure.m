function nn = structure(varargin)
%STRUCTURE  Constructor for raw memory object 
%  MM = STRUCT('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See MEMORYOBJ)
%  -----------------
%  Field Names - Description 
%
%  See Also CAST, READ, WRITE.

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2004/04/08 20:47:10 $

nn = ccs.structure;
construct_structure(nn,varargin);

% [EOF] structure.m
 