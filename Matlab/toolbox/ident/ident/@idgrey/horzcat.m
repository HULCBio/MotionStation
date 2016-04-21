function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDGREY models.
%
%   MOD = HORZCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 , MOD2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the models MOD1, MOD2,...
% 
%   See also IDGREY/VERTCAT, IDGREY

 %   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2002/01/21 09:36:55 $
 
 
 error(sprintf([' Model concatenation cannot be done for IDGREY models.',...
 '\n Convert model to IDSS or SS first.']))
 
