%=============================================================================
%
% File: getSoftwareEnvironments.m
%
%   Copyright 1994-2003 The MathWorks, Inc.
%
% Topic: 
%
%
% Abstract: 
%
%
% modification history:
%
% who?        when?          what did you do?
% tryan       09/22/03       created this file
%
%  $Revision: 1.1.6.1 $
%=============================================================================
function ret = getSoftwareEnvironments(varargin)
  
  persistent softwareEnvironmentTable;
  
  if isempty(softwareEnvironmentTable)
    
    % Configuration table
    index = 1;
    
%    softwareEnvironmentTable(index).Name      = 'Specified...';
%    softwareEnvironmentTable(index).Type      = 'Specified';
%    softwareEnvironmentTable(index).Environment   = 'Custom';
%    index = index+1;
    
    softwareEnvironmentTable(index).Name        = 'ANSI-C';
    softwareEnvironmentTable(index).Type        = 'ANSI_C';
    softwareEnvironmentTable(index).Environment = 'ansi_tfl_tmw.mat';
    index = index+1;

    softwareEnvironmentTable(index).Name        = 'ISO-C';
    softwareEnvironmentTable(index).Type        = 'ISO_C';
    softwareEnvironmentTable(index).Environment = 'iso_tfl_tmw.mat';
    index = index+1;
    
    softwareEnvironmentTable(index).Name        = 'GNU';
    softwareEnvironmentTable(index).Type        = 'GNU';
    softwareEnvironmentTable(index).Environment = 'gnu_tfl_tmw.mat';
    index = index+1;
    
%    softwareEnvironmentTable(index).Name        = 'Diab';
%    softwareEnvironmentTable(index).Type        = 'Diab';
%    softwareEnvironmentTable(index).Environment = 'diab_tmw';
%    index = index+1;
  end

  ret = [];
  if nargin == 1
    name = varargin{1};
    if isempty(name)
      ret = softwareEnvironmentTable;
    else
      for i = 1:length(softwareEnvironmentTable)
        if strcmp(softwareEnvironmentTable(i).Type, name)
          ret = softwareEnvironmentTable(i);
          break;
        end
      end
    end
  else
    mode = varargin{1};
    val  = varargin {2};

    switch mode
     case 'Type'
      for i = 1:length(softwareEnvironmentTable)
        if strcmp(softwareEnvironmentTable(i).Type, val)
          ret = softwareEnvironmentTable(i);
          break;
        end
      end
      
     case 'Name'
      for i = 1:length(softwareEnvironmentTable)
        if strcmp(softwareEnvironmentTable(i).Name, val)
          ret = softwareEnvironmentTable(i);
          break;
        end
      end
    end
  end
      
%% EOF