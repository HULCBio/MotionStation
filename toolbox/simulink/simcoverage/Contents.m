%
% Simulink Model Coverage Tool 
%
% Model coverage functions.
%   cvtest               - Create a cvtest object.
%   cvdata               - Translate an integer ID into a cvdata object.
%   cvload               - Load coverage data from file.
%   cvsave               - Save coverage data to file.
%   cvsim                - Run a coverage instrumented simulation.
%   cvreport             - Create a textual report of a cvdata object.
%   cvhtml               - Create an html report of a cvdata object.
%   cvmodelview          - Display coverage data on a model using coloring.
%   cvenable             - Enable coverage for a Simulink model.
%   cvexit               - Exit the coverage environment
%   cvresolve            - Update the coverage tool links to Simulink.
%   cvclean              - Deallocate coverage data associated with model.
%
% Data retrieval functions
%   conditioninfo        - Decision coverage information for a model object
%   decisioninfo         - Condition coverage information for a model object
%   mcdcinfo             - MCDC information for a model object
%   tableinfo            - Look-up table coverage information for a model object
%   sigrangeinfo         - Signal ranges for a model object
%
% Demo files
%   simcovdemo           - Command line demontration of model coverage
%   ratelim_harness      - Model used in simcovdemo
%
% Overloaded arithmetic operations for cvdata objects.
%   cvdata/times - (*)   - Find the intersection of coverage between two cvdata.
%   cvdata/plus  - (+)   - Find the union of coverage between two cvdata.
%   cvdata/minus - (-)   - Find coverage aspects exclusive to first cvdata. 
%

% Copyright 1990-2003 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.1.6.2

