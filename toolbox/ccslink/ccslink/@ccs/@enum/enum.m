function nn = enum(varargin)
%ENUM  Constructor for raw memory object 
%  MM = ENUM('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See NUMERIC)
%  ------------------------------
% 
%
%  See Also READ, WRITE, CONVERSION

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2004/04/08 20:45:59 $

nn = ccs.enum;
construct_enum(nn,varargin);

% [EOF] numeric.m
 