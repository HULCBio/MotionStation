function c=cmleval(varargin)
%Evaluate MATLAB Expression
%   This component will evaluate MATLAB expressions in
%   the base workspace.  It allows the user to run
%   functions, manipulate data, create figures, or use
%   any part of MATLAB.
%
%   This component can insert its code into the report,
%   but by default it does not include anything in the 
%   report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:29 $

c=rptgenutil('EmptyComponentStructure','cmleval');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

