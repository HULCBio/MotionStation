%% Using the PreLookUp and Interpolation (n-D) Blocks
% The PreLook-Up Index Search block allows you to minimize the number
% of index searches performed across a set of look-up tables and also 
% to mix clipping, extrapolation, and index search algorithms within 
% one table calculation.  (Open the model: <matlab:sldemo_bpcheck>)
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/01 16:22:57 $

%% Introduction 
% This model uses prelookup and interpolation (n-D) blocks. Note how the 
% prelookup block perform the index search portion of the computation 
% and the inteplation blocks perform the rest:

mdl = 'sldemo_bpcheck';
open_system(mdl)

%%
% [Close the model to reset the screen capture]

close_system(mdl)

%%
% These blocks can be found in the Simulink block library in
% the Look-Up Tables sub-library:

open_system('simulink')
open_system(sprintf('simulink/Lookup\nTables'),'simulink','replace')
hilite_system([ gcs, sprintf('/PreLookup\nIndex Search')], 'different')
hilite_system([ gcs, sprintf('/Interpolation (n-D)\nusing PreLookup')], 'different')

%% Optimization: PreLookup Index Search + Interpolation (n-D) Blocks
% Use of the PreLookup Index Search block should be considered for 
% tables with intensive index searches in breakpoint sets.  The preLookup
% Index Search block allows you to do an index search once and reuse the 
% result in many table lookups.  In this model, 3 index search results 
% are used in 5 blocks in a total of 10 uses.  Equivalent regular lookup 
% tables such as the example to the right would have required 10 index 
% searches instead of 3.

open_system(mdl)
preblks = find_system('sldemo_bpcheck','MaskType','LookupIdxSearch');
for k=1:length(preblks)
    hilite_system( preblks{k}, 'different' );
end

%%
% [Close the model to reset the screen capture]

close_system(mdl)
close_system('simulink')

%% Optimization: Sub-table selection option in the Interpolation (n-D)
% One of the Interpolation (n-D) blocks in this model is configured using
% a capability that is new in Simulink 6.0: trailing dimensions of an
% n-D table can be marked as "selection dimensions", meaning that the
% input for that dimension is an integer used only to make a sub-table
% selection, such as picking a 2-D plane from a 3-D table.  The sub-table
% is then interpolated normally.
%
% Interpolation of sub-tables can save tremendous amounts of computation.
% For every dimension eliminated from interpolation, the computation 
% almost halves.  Since an N-dimensional interpolation takes (2^N)-1
% individual interpolation operations (y’ = ylow + f*(yhigh-ylow)), even 
% just one dimension of selection can almost double the speed of the 
% interpolation. Extreme example: a 5-D table with 3 dimensions of 
% sub-table selection and 2-D interpolation: 5-D interpolation would 
% take 2^5-1 = 31 interpolations, but a 2-D interpolation takes 
% only 2^2 - 1 = 3.
%
% The selection ports support vectorization to allow multiple sub-table 
% selection / interpolations in a single block. 

open_system(mdl)
subblk = find_system('sldemo_bpcheck', ...
                      'MaskType',         'LookupNDInterpIdx',...
                      'NumSelectionDims', '1' );
hilite_system( subblk{1}, 'different' );

%%
% The sub-table or multi-table mode of operation is activated by setting
% a non-zero integer for the Number of sub-table selections dimensions 
% parameter in the block's parameter dialog.  The number you set is 
% interpreted as the number of dimensions to select from the highest
% dimensions.  For example, if you have a 3-D table and choose 2, that
% means the first dimension will be interpolated and dimensions 2 and 3
% will be selected:

open_system( subblk{1} )

%%
% [close dialog]

close_system( subblk{1} )

%%
% NOTE: you can remove highlighting from a model using 
% the View / Remove highlighting menuitem or this command:

set_param(mdl,'HiliteAncestors','none')
