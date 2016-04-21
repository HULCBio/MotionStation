function h = CCSVersion(varargin)
%CCSVERSION Class instantiation function (for ccs.CCSVersion).

%   Copyright 2004 The MathWorks, Inc.

%%%% Instantiate class
h = ccs.CCSVersion;

%%%% Initialize property values

h = constructCCSStudio(h,varargin);

% [EOF] CCSVersion.m