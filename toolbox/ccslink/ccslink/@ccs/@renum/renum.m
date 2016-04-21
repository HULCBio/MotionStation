function nn = renum(varargin)
%RENUM  Constructor for enum-register object 
%  MM = RENUM('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See NUMERIC)
%  ------------------------------
% 
%
%  See Also READ, WRITE, CONVERSION

% 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $ $Date: 2003/11/30 23:11:06 $

nn = ccs.renum;
construct_renum(nn,varargin);

% [EOF] renum.m
 