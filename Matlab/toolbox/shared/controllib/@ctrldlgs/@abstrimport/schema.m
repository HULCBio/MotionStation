function schema
% Defines properties for @abstrimimport an abstract class for import dialog
% creation.
%
%   The abstract class implements the following methods
%       browsebutton - Create a MJButton and wire its call back to browse
%       buttonpanel - Create and wire the Close, Import, Help button panel
%       getmatfilevars - Gets valid MATLAB variables based on the filters
%           firstfilter and secondfilter that have been subclassed.
%       getmodels - Get the valid data from a defined workspace WS that 
%           are named in a cell array VARS.
%       show - Show the dialog.
%       dispose - Dispose the dialog.
%       tablepanel - Create and configure the table and scroll panel.
%       updatetable - Update the table based on new data passed.

%   The subclass of this abstract must implement the methods:
%       CONSTRUCTOR - Used to build the java objects and assemble the JFrame
%       createtablecell - Method to create the table java.lang.Object[][] 
%       firstfilter  - Filter based on class type and size
%       secondfilter - Filter based on the actual loaded data
%       help - Method invoked when the user clicks on the Help Button
%       import - Method invoked when the user clicks on the Import Button

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:18 $

% Register class 
pk = findpackage('ctrldlgs');
c = schema.class(pk,'abstrimport');

% The names of the variables in the selection table
p = schema.prop(c,'VarNames','MATLAB array');
% The variables in the selection table 
p = schema.prop(c,'VarData','MATLAB array');
% Handle of the dialog frame
p = schema.prop(c,'Frame','MATLAB array');
% Structure of Java handles
p = schema.prop(c,'Handles','MATLAB array');
% java.lang.Object[] of the TableColumnNames
p = schema.prop(c,'TableColumnNames','MATLAB array');
% The last path that the user has selected
p = schema.prop(c,'LastPath','string');
% The last file name that the user has selected
p = schema.prop(c,'FileName','string');
