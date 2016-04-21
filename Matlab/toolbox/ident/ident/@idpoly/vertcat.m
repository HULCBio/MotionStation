function sys = vertcat(varargin)
%VERTCAT  Vertical concatenation of IDPOLY models.
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
 %   $Revision: 1.6 $  $Date: 2001/04/06 14:22:21 $
 
if length(varargin)>1
  error('IDPOLY only handles single output. Convert model to IDSS first.')
else
   sys = varargin{1};
end
