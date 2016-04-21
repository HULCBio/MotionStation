% Simulink Report Generator
% Version 2.0 (R14) 05-May-2004
%
% Report Generator Functions.
%   report          - Generate a report from a setup file.
%   setedit         - Graphically edit a setup file.
%   rptrelatedfiles - Find all files related to a file
%
% Simulink Components
%   rptgen_sl.csl_auto_table       - Simulink Automatic Table
%   rptgen_sl.csl_blk_count        - Block Type Count
%   rptgen_sl.csl_blk_loop         - Block Loop
%   rptgen_sl.csl_blk_sort_list    - Block Execution Order List
%   rptgen_sl.csl_mdl_changelog    - Model Change Log
%   rptgen_sl.csl_mdl_loop         - Model Loop
%   rptgen_sl.csl_mdl_sim          - Model Simulation
%   rptgen_sl.csl_obj_anchor       - Simulink Linking Anchor
%   rptgen_sl.csl_obj_fun_var      - Simulink Functions & Variables
%   rptgen_sl.csl_obj_name         - Simulink Name
%   rptgen_sl.csl_prop_table       - Simulink Property Table
%   rptgen_sl.csl_property         - Simulink Property
%   rptgen_sl.csl_sig_loop         - Signal Loop
%   rptgen_sl.csl_summ_table       - Simulink Summary Table
%   rptgen_sl.csl_sys_filter       - System Filter
%   rptgen_sl.csl_sys_list         - System Hierarchy
%   rptgen_sl.csl_sys_loop         - System Loop
%   rptgen_sl.csl_sys_snap         - System Snapshot
%
% Simulink Blocks Components
%   rptgen_sl.csl_blk_bus          - Bus
%   rptgen_sl.csl_blk_doc          - Documentation
%   rptgen_sl.csl_blk_lookup       - Look-Up Table
%   rptgen_sl.csl_blk_scope        - Scope Snapshot
%   rptgen_sl.csl_blk_toworkspace  - To Workspace Plot
%
% Stateflow Components
%   rptgen_sf.csf_auto_table       - Stateflow Automatic Table
%   rptgen_sf.csf_chart_loop       - Chart Loop
%   rptgen_sf.csf_count            - Stateflow Count
%   rptgen_sf.csf_hier             - Stateflow Hierarchy
%   rptgen_sf.csf_hier_loop        - Stateflow Hierarchy Loop
%   rptgen_sf.csf_machine_loop     - Machine Loop
%   rptgen_sf.csf_obj_anchor       - Stateflow Linking Anchor
%   rptgen_sf.csf_obj_filter       - Stateflow Filter
%   rptgen_sf.csf_obj_loop         - Object Loop
%   rptgen_sf.csf_obj_name         - Stateflow Name
%   rptgen_sf.csf_obj_snap         - Stateflow Snapshot
%   rptgen_sf.csf_prop_table       - Stateflow Property Table
%   rptgen_sf.csf_property         - Stateflow Property
%   rptgen_sf.csf_state_loop       - State Loop
%   rptgen_sf.csf_summ_table       - Stateflow Summary Table
%   rptgen_sf.csf_truthtable       - Truth Table
%
% See also RPTGEN

%   Copyright 1997-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2004/03/21 22:41:55 $ 