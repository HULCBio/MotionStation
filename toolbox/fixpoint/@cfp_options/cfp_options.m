function c=cfp_options(varargin)
%Fixed-Point Logging Options
%   This component sets Fixed-Point options similar to those
%   set in the Fixed-Point Blockset Interface GUI.  It is 
%   typically used before a Model Simulation component in order
%   to control how the model behaves during simulation.
%
%   See also CFP_BLK_LOOP, CSLSIM, FIXPTDLG

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:55:39 $

c=rptgenutil('EmptyComponentStructure','cfp_options');
c=class(c,c.comp.Class,rptcomponent,rptfpmethods,zslmethods);
c=buildcomponent(c,varargin{:});
