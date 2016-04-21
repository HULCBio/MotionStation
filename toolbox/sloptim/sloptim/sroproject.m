function sroproject
% Help for setting up and running Response Optimization projects.
%
%   To perform a Simulink Response Optimization at the command line, you
%   must first create or retrieve a Response Optimization project. Assuming
%   your Simulink model is already equiped with Response Optimization blocks, 
%   you can either
%     * Create a new project using the NEWSRO command:
%          proj = newsro('srodemo1',{'P' 'D'})
%     * Take a snapshot of the project currently associated with your model
%       using the GETSRO command:
%          proj = getsro('srodemo1')
%     * Reload a previously saved project (use the Save Project menu in the
%       Signal Constraint block dialog to save your optimization settings).
%
%   Setting up the optimization
%   ===========================
%   Given a project PROJ, you can 
%
%     * Specify the initial guess, bounds, and scaling factor for individual
%       parameters.  For example
%          ps = findpar(proj,'P')  % access settings for parameter P
%          ps.Minimum = -1
%          ps.Maximum = 1
%       Type get(p) to see all related settings.
%
%    * Specify or modify the shape constraints for individual signals.  Use
%      Signal Constraint block names to reference constrained signals.  For
%      example, 
%          c = findconstr(proj,'srodemo1/Signal Constraint')
%          c.LowerBoundX = [0 5;5 10;10 20]  % modify x-location of break points 
%      
%    * Modify the simulation and optimization settings using SIMSET/SIMGET
%      and OPTIMGET/OPTIMSET.  For example
%          simset(proj,'Solver','ode45')
%
%   Running the optimization
%   ========================
%   Once your project is fully configured, you can start the optimization
%   with the OPTIMIZE command:
%          optimize(proj)
%   The tuned parameters are updated in the base workspace during the
%   optimization.  Use CTRL-C to interrupt the iterations at any time.
%
%   See also NEWSRO, GETSRO, SIMSET, SIMGET, OPTIMSET, OPTIMGET.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/01/03 12:29:16 $
%   Copyright 1990-2003 The MathWorks, Inc.
help sroproject