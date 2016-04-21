%FINDCONSTR  Find constraints on given response.
%
%   CONSTRAINTS=FINDCONSTR(PROJ,'BLOCKNAME') returns a constraint object 
%   for the Signal Constraint block, BLOCKNAME, within the response
%   optimization project, PROJ. This object contains all the data defining
%   the desired response including the positions of the constraint bound
%   segments as well as the reference signals. The constraints are used in
%   a response optimization to define the region in which the response
%   signal must lie. 
%
%   Modify the constraint object properties UpperBoundX, UpperBoundY,
%   LowerBoundX, and LowerBoundY to specify new constraint bound segments
%   on the signals. These properties define the x and y values for the
%   beginning and ending points of each constraint bound segment.
%
%   Modify the constraint object properties ReferenceX and ReferenceY to
%   specify a new reference signal to track. These properties contain the
%   vectors of  x and y data defining the reference signal.
%
%   Example:
%     proj = getsro('srodemo1')
%     c = findconstr(proj,gcb)
% 
%   See also RESPONSEOPTIMIZER/FINDPAR, GETSRO, NEWSRO,
%   RESPONSEOPTIMIZER/OPTIMIZE.

%  Author(s): Pascal Gahinet
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2004/04/19 01:33:36 $

