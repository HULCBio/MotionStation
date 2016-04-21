function [Props,AsgnVals] = pnames(sys,flag)
%PNAMES  All public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(SYS) returns the list PROPS of
%   public properties of the SS object SYS, as well as the
%   assignable values ASGNVALS for these properties.  Both
%   PROPS and ASGNVALS are cell vector of strings, and PROPS
%   contains the true case-sensitive property names, including 
%   the parent properties.
%
%   PROPS = PNAMES(SYS,'specific') returns only the SS-specific 
%   public properties of SYS.
%
%   See also  GET, SET.

%       Author(s): P. Gahinet, 7-8-97
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.12 $  $Date: 2002/04/10 06:00:55 $

% SS-specific public properties 
Props = {'a' ; 'b' ; 'c' ; 'd' ; 'e' ; 'StateName'};

% Add public parent properties unless otherwise requested
if nargin==1,
   if nargout==1,
      Props = [Props ; pnames(sys.lti)];
   else
      % Assignable values 
      AsgnVals = {'Nx-by-Nx matrix (Nx = no. of states)'; ...
            'Nx-by-Nu matrix (Nu = no. of inputs)'; ...
            'Ny-by-Nx matrix (Ny = no. of outputs)'; ...
            'Ny-by-Nu matrix'; ...
            'Nx-by-Nx matrix (or [])';...
            'Nx-by-1 cell array of strings'};
      
      [LTIprops,LTIvals] = pnames(sys.lti);
      Props = [Props ; LTIprops];
      AsgnVals = [AsgnVals ; LTIvals];
   end
end

