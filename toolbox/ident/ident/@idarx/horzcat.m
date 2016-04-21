function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDARX models.
%
%   MOD = HORZCAT(MOD1,MOD2,...) performs the concatenation 
%   operation
%         MOD = [MOD1 , MOD2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the models MOD1, MOD2,...
%
%   IDARX models will be converted to IDSS models.
%
% 
%   See also VERTCAT,  IDMODEL.

 %   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:21:59 $

 if nargin==1,
   sys = varargin{1};
    
   return
end
for kj = 1:nargin 
   varargin{kj} = idss(varargin{kj});
end
disp('Adding more inputs to an IDARX object will transform it into an IDSS object.')
