% Simulink Response Optimization 
% Version 2.0 (R14) 05-May-2004 
%
% Response Optimization blocks.
%   srolib     - Library of Response Optimization blocks.
%   ncdupdate  - Upgrade models with old NCD blocks.
%
% Command line interface.
%   sroproject                   - General help on the command line 
%                                  interface.
%   newsro                       - Create default response optimization 
%                                  project for Simulink model.
%   getsro                       - Take snapshot of current response
%                                  optimization project.
%   ResponseOptimizer/initpar    - Initialize tuned parameters.
%   ResponseOptimizer/findpar    - Find specifications for given tuned 
%                                  parameter.
%   ResponseOptimizer/findconstr - Find constraints on given response.
%   ResponseOptimizer/simset     - Modify simulation settings for response
%                                  optimization project.
%   ResponseOptimizer/simget     - Retrieve current simulation settings for
%                                  response optimization project.
%   ResponseOptimizer/optimset   - Modify optimizer settings for response
%                                  optimization project.
%   ResponseOptimizer/optimget   - Retrieve current optimizer settings for
%                                  response optimization project.
%   ResponseOptimizer/optimize   - Run response optimization project.
%   gridunc                      - Define grid of uncertain parameter
%                                  values.
%   randunc                      - Randomly sample uncertain parameters.
%   ResponseOptimizer/setunc     - Specify parameter uncertainty in
%                                  response optimization project.
%
% Demonstrations.
%   Type "demo" or "help sloptdemos" for a list of available demos.

% Copyright 2002-2004 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.1.6.6 $Date: 2004/04/19 01:33:47 $
