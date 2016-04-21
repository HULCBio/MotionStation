function sys = vertcat(varargin)
%VERTCAT  Vertical concatenation of IDMODEL models.
%
%   MOD = VERTCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 ; MOD2 , ...]
% 
%   This operation amounts to appending  the outputs of the 
%   IDMODEL objects MOD1, MOD2,... and feeding all these models
%   with the same input vector.
% 
%   See also HORZCAT.

 %   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/01/21 09:37:07 $

  
 error(sprintf([' Model concatenation cannot be done for IDGREY models.',...
 '\n Convert model to IDSS or SS first.']))

 