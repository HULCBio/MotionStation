% MATLAB Report Generator
% Version 2.0 (R14) 05-May-2004
%
% MATLAB Report Generator
%
% Report Generator Functions
%   report          - Generate a report from a setup file.
%   setedit         - Graphically edit a setup file.
%   rptrelatedfiles - Find all files related to a file
%
% Formatting Components
%   rptgen.cfr_image               - Image
%   rptgen.cfr_link                - Link
%   rptgen.cfr_list                - List
%   rptgen.cfr_paragraph           - Paragraph
%   rptgen.cfr_section             - Chapter/Subsection
%   rptgen.cfr_table               - Table
%   rptgen.cfr_text                - Text
%   rptgen.cfr_titlepage           - Title Page
%
% Handle Graphics Components
%   rptgen_hg.chg_ax_loop          - Axes Loop
%   rptgen_hg.chg_ax_snap          - Axes Snapshot
%   rptgen_hg.chg_fig_loop         - Figure Loop
%   rptgen_hg.chg_fig_snap         - Figure Snapshot
%   rptgen_hg.chg_obj_anchor       - Handle Graphics Linking Anchor
%   rptgen_hg.chg_obj_loop         - Object Loop
%   rptgen_hg.chg_obj_name         - Handle Graphics Name
%   rptgen_hg.chg_prop_table       - Handle Graphics Property Table
%   rptgen_hg.chg_property         - Handle Graphics Parameter
%   rptgen_hg.chg_summ_table       - Handle Graphics Summary Table
%
% Logical & Flow Control Components
%   rptgen_lo.clo_else             - Logical Else
%   rptgen_lo.clo_else_if          - Logical Elseif
%   rptgen_lo.clo_for              - For Loop
%   rptgen_lo.clo_if               - Logical If
%   rptgen_lo.clo_then             - Logical Then
%   rptgen_lo.clo_while            - While Loop
%
% MATLAB Components
%   rptgen.cml_eval                - Evaluate MATLAB Expression
%   rptgen.cml_variable            - Insert Variable
%   rptgen.cml_ver                 - MATLAB/Toolbox Version Number
%   rptgen.cml_whos                - Variable Table
%   rptgen.cml_prop_table          - MATLAB Property Table
%
% Report Generator Components
%   rptgen.crg_comment             - Comment
%   rptgen.crg_empty               - Empty Component
%   rptgen.crg_halt_gen            - Stop Report Generation
%   rptgen.crg_import_file         - Import File
%   rptgen.crg_nest_set            - Nest Setup File
%   rptgen.crg_tds                 - Time/Date Stamp
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2004/03/21 22:23:13 $ 