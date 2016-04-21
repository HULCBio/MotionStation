%% Model Reference Dependency Graph Demonstration 
% This demonstration explains how to determine and view dependencies among 
% referenced models.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/01 16:22:45 $

%% Demo Requirements
% During this demonstration, Simulink generates files in the current 
% working directory. If you do not want to generate files in this 
% directory, you should change the working directory to a suitable 
% directory.


%% Open the demo model
% Open the demo model: (<matlab:mdlref_depgraph>)
open_system('mdlref_depgraph');

%% Find reference models
% Use the find_mdlrefs utility function to find all Model blocks and
% referenced models in a model. Type help find_mdlrefs for more 
% information about this function. 


[refMdls, modelBlks] = find_mdlrefs('mdlref_depgraph')

%%
% In this example, find_mdlrefs returns two cell arrays, refMdls 
% and modelBlks. refMdls contains the name of all models that are 
% directly or indirectly referenced by 'mdlref_depgraph'. 
% The last element in refMdls is always the name of the input model.
% modelBlks contains block paths for all Model blocks in the top model and
% the referenced models.


%% View model reference dependency graph
% Double click on the blue box in the demo model to view the model
% reference dependency graph. Use the view_mdlrefs utility 
% function to display the model reference dependency graph for a  
% model. The nodes in the graph represent Simulink models. 
% The directed lines indicate model dependencies, 
% e.g., link from mdlref_depgraph to mdlref_house indicates that 
% mdlref_depgraph is referencing mdlref_house.

view_mdlrefs('mdlref_depgraph');


%% Notes 
% Note that there is only one node for each model in the graph, and 
% there is at most one link from one node to another node. Therefore,
% the dependency graph does not capture multiple references from one
% model to another model. However, since a model can be referenced by 
% multiple models, multiple links can come from several nodes into 
% a given node. You can open each model by clicking on the associated node 
% and you can resize the graph. The File menu offers additional options. 
% For example, you can refresh the figure after modifying the models. 
% It also allows you to open all the models, open the Model Explorer to 
% modify their configurations, save all the models and close all the models.

%% Close the models and figures

bdclose('all');
close(gcf);


