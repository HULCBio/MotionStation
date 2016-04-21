function updatetable(this, VarNames, VarData)
% UPDATETABLE Update the table based on the variable name cell array
% VarNames and the cell array of data VarData.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:21 $
% 
% import java.awt.*;
% import javax.swing.*;
% import com.mathworks.mwswing.*;
% import javax.swing.table.*;
% import com.mathworks.mwswing.mjtable.*;
% import com.mathworks.toolbox.slcontrol.AdvTableObjects.*;

%% Store the data in the object
this.VarNames = VarNames;
this.VarData = VarData;

if length(VarNames) > 0
    %% Get the data for the table
    data = this.createtablecell(VarNames, VarData);
    cm = this.TableColumnNames;
    r = this.Handles.TableModel.getClass.getMethod('setDataVector',[data.getClass,cm.getClass]);

    %% Update the table
    awtinvoke(this.Handles.TableModel,r,data,cm)
else
    %% Clear the table
    awtinvoke(this.Handles.TableModel,'clearRows')
end
