function sys = cat(dim,varargin)
%CAT  Concatenation of LTI models.
%
%   SYS = CAT(DIM,SYS1,SYS2,...) concatenates the LTI models
%   along the dimension DIM.  The values DIM=1,2 correspond
%   to the output and input dimensions, and the values 
%   DIM=3,4,... correspond to the LTI array dimensions 1,2,...
%
%   For example,
%     * CAT(1,SYS1,SYS2) is equivalent to [SYS1 ; SYS2]
%     * CAT(2,SYS1,SYS2) is equivalent to [SYS1 , SYS2]
%     * CAT(4,SYS1,SYS2) is equivalent to STACK(2,SYS1,SYS2).
%
%   See also HORZCAT, VERTCAT, STACK, APPEND, LTIMODELS.

%   Author(s):  P. Gahinet, 5-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:51:43 $

switch dim
case 1
   sys = vertcat(varargin{:});
case 2
   sys = horzcat(varargin{:});
otherwise
   sys = stack(dim-2,varargin{:});
end

