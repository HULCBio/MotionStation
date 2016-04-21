%COMPONENTINFO Registry and type information for MATLAB Excel Builder components.
%   COMPONENTINFO(varargin) takes between 0 and 3 inputs and returns an array of structures
%   representing all the registry and type information needed to load and use the component.
%
%   The general syntax for calling componentinfo is given as:
%
%   INFO = COMPONENTINFO([COMPONENT_NAME], [MAJOR_REV], [MINOR_REV])
%
%   COMPONENT_NAME (optional) - Name of component (case sensitive). Defaults to all 
%                               installed components.
%   MAJOR_REV (optional)      - Major revision number. Defaults to all versions.
%   MINOR_REV (optional)      - Minor revision number. Defaults to 0.
%
%   When a component name is supplied, MAJOR_REV and MINOR_REV are interpreted as follows: 
%   If MAJOR_REV > 0 componentinfo returns information on a specific MAJOR_REV.MINOR_REV.
%   If MAJOR_REV = 0 componentinfo returns information on the most recent version.
%   If MAJOR_REV < 0 componentinfo returns information on all versions.
%   When no component name is supplied, information is returned for all components installed 
%   on the system.
%
%   Examples:
%   INFO = COMPONENTINFO('mycomponent',1,0) - Returns info for "mycomponent" version 1.0
%   INFO = COMPONENTINFO('mycomponent')     - Returns info for all versions of "mycomponent"
%   INFO = COMPONENTINFO                    - Returns info for all installed components
%

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/06/17 12:52:50 $

function [info] = componentinfo(varargin)
%#mex
error('MEX file not present');
