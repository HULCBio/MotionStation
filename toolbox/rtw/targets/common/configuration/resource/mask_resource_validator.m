function varargout = mask_resource_validator( block, resource_fcn, varargin )
% MASK_RESOURCE_VALIDATOR -  Controller for a resource grabbing mask
%
% -- Purpose ---
%
% This function is called in the mask. You pass it the function
% handle of the function which will do the resource requesting
% for the mask. This function takes care of calling your function
% only when it needs to be called.
%
% Simulink executes the mask initialization under different
% conditions and not all conditions are suitable for resource
% allocation.
%
% -- Arguments ---
%
%   block           -   Simulink block that is executing this function
%   resource_fcn    -   The resource allocation function will be called
%                       with
%
%                       resource_fcn(block, target, [ , varargin ] )
%
%   varargin        -   The current value of the parameter(s) that is|are being
%                       allocated.
%                       
%
%   varargout       -   The new value of the allocated paramter(s)
%
% -- Example ---
%
%   buffer = mask_resource_validator(block, @buffer_allocator, buffer )
%

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $
%   $Date: 2004/04/19 01:21:29 $
    
        
simStatus = lower(get_param(bdroot(block), 'SimulationStatus'));

switch simStatus
case { 'initializing', 'updating' }
    
    target = RTWConfigurationCB('get_target',block);
    
    if ~target.isBlockRegistered(block);
        varargout = feval(resource_fcn, block, target, varargin{:});
        if ~iscell(varargout) | ( length(varargout) ~= length(varargin) )
            help mask_resource_validator;
            error('The number of passed in parameters must be the same as the number of elements in the returned cell array.');
        end
        target.registerBlock(block);
    else
        varargout = varargin;
    end
    
case { 'stopped' }
    %% -- DO NOTHING ---
    varargout = varargin;
end
        



