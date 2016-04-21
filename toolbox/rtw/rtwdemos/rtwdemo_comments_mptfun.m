function comments = rtwdemo_comments_mptfun(objectName, modelName, request)
% An example M-script to create custom comments for Simulink data objects.
% In this example, comments are placed immediately above the data's declaration
% and definition.
%
% You can define your own function name provided it has these three
% auguments.
%
%   INPUTS:
%         objectName: The name of mpt Parameter or Signal object
%         modelName:  The name of working model
%         request:    The nature of the code or information requested. 
%                     Two kinds of requests are supported:
%                     'declComment' -- comment for data declaration
%                     'defnComment' -- comment for data definition
%   OUTPUT:
%         comments:   A comment according to standard C convention
%
% Requirement: This file must be on the MATLAB path.
%
% Recommend: Use get_data_info to get the property value of a Simulink
%            or mpt data object, as illustrated in this example.
%
% See also get_data_info.

%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
%   $Date: 2004/04/19 01:16:58 $

  dataType = get_data_info(objectName, 'DATATYPE');
  units    = get_data_info(objectName, 'UNITS');
  csc      = get_data_info(objectName, 'CUSSTORAGECLASS');

  cr = sprintf('\n');
  
  comments = [cr,...
              '/* Object: ',objectName,' - user description:',cr,...
              '           DataType -- ', dataType,cr,...
              '           Units    -- ', units,cr,...
              '           CSC      -- ', csc,' */'];
  
% EOF
