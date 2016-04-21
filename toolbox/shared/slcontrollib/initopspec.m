function opnew = initopspec(opspec,varargin);
%INITOPSPEC Initialize operating point specification values
%
%   OPNEW=INITOPSPEC(OPSPEC,OPPOINT) initializes the operating point 
%   specification object, OPSPEC, with the values contained in the 
%   operating point object, OPPOINT. The function returns a new operating 
%   point specification object, OPNEW. Create opspec with the function 
%   OPERSPEC. Create OPPOINT with the function OPERPOINT or FINDOP. 
%
%   OPNEW=INITOPSPEC(OPSPEC,X,U) initializes the operating point 
%   specification object, OPSPEC, with the values contained in the state 
%   vector, X, and the input vector, U. You can use the function getxu to 
%   create X and U with the correct ordering. 
%
%   OPNEW=INITOPSPEC(OPSPEC,XSTRUCT,U) initializes the operating point 
%   specification object, OPSPEC, with the values contained in the state 
%   structure, XSTRUCT, and the input vector, U. You can use the function 
%   GETXU to create XSTRUCT and U with the correct ordering. Alternatively, 
%   XSTRUCT, can be saved to the MATLAB workspace after a simulation of the 
%   model. See the Simulink documentation for more information on these 
%   structures.
%
%   See also OPERPOINT, OPERSPEC, GETXU, FINDOP.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:21 $

if nargin == 2
    [x,u] = getxu(varargin{1});
    opnew = setxu(opspec,x,u);
elseif nargin == 3
    x = varargin{1};
    u = varargin{2};
    opnew = setxu(opspec,varargin{1},varargin{2});
end