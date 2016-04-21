%% Extracting Detailed Information from Coverage Data
% This demonstration explains how coverage information for a model is bundled
% in the cvdata object and how utility commands can extract information from it
% for an individual subsystem, block, or Stateflow object.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/09/18 18:07:10 $

%% An example model for analysis
% This example illustrates command line access of coverage data for a small
% model that contains aspects of all the supported coverage metrics. The model
% contains some blocks with coverage points at the root level and others at the
% subsystem level.
%  
% Use the following commands to open the model 'cv_small_controller' and its
% subsystem 'Gain.'  

open_system('cv_small_controller');
open_system('cv_small_controller/Gain');

%% Generating coverage data and an HTML report
% Simulate the model with the |cvsim| command. This command captures coverage
% data as a side-effect and returns this information in a cvdata object. The
% cvdata object is a MATLAB object that references the internal data stored in
% the coverage tool and the model data structures that produce that data.  
%  

testObj = cvtest('cv_small_controller');
testObj.settings.decision = 1;
testObj.settings.condition = 1;
testObj.settings.mcdc = 1;
testObj.settings.tableExec = 1;
testObj.settings.sigrange = 1;
data = cvsim(testObj)

%%
% Process the coverage data returned from a |cvsim| command with the report
% generation command |cvhtml|. The resulting report is a convenient
% representation of model coverage for the entire model.
%  

cvhtml('tempfile.html',data);

%% Coverage Data Objects
% Frequently, you want to extract information for a specific subsystem or block
% in the model. A coverage data object is contains series of arrays, one for
% each metric analyzed.  Access this data using structure style references.  For
% example, access raw decision coverage data with the following command:
%  

data.metrics.decision

%%
% Access raw condition coverage with the following command:
%  

data.metrics.condition


%% Extracting coverage information
% Individual elements within the raw coverage data correspond to specific 
% coverage points within the model.  The order of these points is based on the 
% location of blocks within the Simulink and Stateflow hierarchy. Several access 
% commands allow data to be extracted for a specific block or subsystem.

%% Extract decision coverage information 
% Use the |decisioninfo| command to extract decision coverage information for
% individual Simulink blocks or Stateflow objects. 
%  
% The following command extracts a coverage array for the entire model. The 
% first element is the number of coverage points satisfied for the model; the
% second element is the total number of coverage points for the model.  
%  

cov = decisioninfo(data,'cv_small_controller')
percent = 100*cov(1)/cov(2)

%%
% Retrieve coverage information for the 'Saturation' block using the full path
% to that block.  Provide a second return argument for textual descriptions of
% the coverage points within that block. 
% 
%  

[blkCov, description] = decisioninfo(data,'cv_small_controller/Saturation')

decision1 = description.decision(1).text
out_1a = description.decision(1).outcome(1).text
count_1a = description.decision(1).outcome(1).executionCount
out_1b = description.decision(1).outcome(2).text
count_1b = description.decision(1).outcome(2).executionCount

%%
% Quantitative coverage information is available for every point in the 
% hierarchy that contains or has coverage points. Textual descriptions 
% are generated only for objects that have coverage points themselves. For 
% example, invoke |decisioninfo| for the virtual subsystem Gain, and the
% description return value is empty. 
%  

[blkCov, description] = decisioninfo(data,'cv_small_controller/Gain')

%%
% In some cases an object has internal coverage points but also contains 
% descendents with additional coverage points.  Coverage information normally
% includes all the descendents unless a third argument for ignoring descendents
% is set to 1.
%  

subsysOnlycov = decisioninfo(data,'cv_small_controller/Gain',1)

%%
% The |decisioninfo| command also works with block handles, Stateflow IDs, and 
% Stateflow API objects. If an object has no decision coverage, the command
% returns empty outputs.
%  

blkHandle = get_param('cv_small_controller/Saturation','Handle')
blkCov = decisioninfo(data,blkHandle)
missingBlkCov = decisioninfo(data,'cv_small_controller/Sine1')

%% Extracting condition information 
% Condition coverage indicates if the logical inputs to Boolean expressions
% have been evaluated to both true and false.  In Simulink, conditions are the
% inputs to logical operations.
%  
% The |conditioninfo| command for extracting coverage information is very
% similar to the |decisioninfo| command.  It normally returns information about
% an object and all its descendents, but can take a third argument that indicates
% if descendents should be ignored.  It can also return a second output
% containing descriptions of each condition.
%  

cov = conditioninfo(data,'cv_small_controller/Gain/Logic')
[cov, desc] = conditioninfo(data,'cv_small_controller/Gain/Logic');
desc(1)
desc(2)

%% Extracting MCDC information 
% MCDC coverage analyzes the objects in a model that define Boolean expressions.
% MCDC coverage is satisfied for a condition within a Boolean expression if 
% there are two evaluations of the expression such that only that condition 
% changes value and results in changing the value of the entire expression.
%  
% In some cases Boolean expressions are short circuited so that the remaining
% conditions are not evaluated.  The coverage analysis permits conditions
% to change from known values to unknown values and vice versa and still
% treats the condition as unchanged for purposes of MCDC analysis.
%   
% In this example, the logical AND block is analyzed for MCDC coverage with an
% |mcdcinfo| command. This command uses the same syntax as |conditioninfo| and
% |decisioninfo| commands.
%  

[cov, desc] = mcdcinfo(data,'cv_small_controller/Gain/Logic')
desc.condition

%% Extracting lookup table coverage 
% Lookup table coverage records the frequency that lookup occurs for each
% interpolation interval.  Valid intervals for coverage purposes also include
% values less than the smallest breakpoint and values greater than the largest
% breakpoint.  For consistency with the other commands this information is 
% returned as a pair of counts with the number of intervals that executed and 
% the total number of intervals.
%  
% A second output argument causes |tableinfo| to return the execution counts 
% for all interpolation intervals.  If the table has M-by-N output values,
% execution counts are returned in an M+1-by-N+1 matrix.
%  
% A third output argument causes |tableinfo| to return the counts where the input
% was exactly equal to the breakpoint.  This is returned in a cell array of 
% vectors, one for each dimension in the table.
%  

[cov,execCnts,brkEq] = tableinfo(data, 'cv_small_controller/Gain/Gain Table')

%% Extracting signal range information 
% Signal range coverage records the smallest and largest value of Simulink 
% block outputs and Stateflow data objects.  The |sigrangeinfo| command returns 
% two return arguments for the minimum and maximum values, respectively.
%  
% The |sigrangeinfo| command works only for leaf blocks that perform a
% computation; otherwise the command returns empty arguments.
%  

[sigMin, sigMax] = sigrangeinfo(data,'cv_small_controller/Gain/Logic')  % Leaf
[sigMin, sigMax] = sigrangeinfo(data,'cv_small_controller/Gain')        % Nonleaf

%%
% Finish the demo by closing the model.
%  

close_system('cv_small_controller',0);

