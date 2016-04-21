function SignalLabelUpdate(this)

% Copies appropriate properties from the MPCStructure node tables
% to the MPCController tables.

%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.8.5 $  $Date: 2004/04/10 23:35:46 $
%   Author:  Larry Ricker

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

% Initialize local cell arrays
ULimits = this.Handles.ULimits.CellData;
YLimits = this.Handles.YLimits.CellData;
Uwts = this.Handles.Uwts.CellData;
Ywts = this.Handles.Ywts.CellData;
Usoft = this.Handles.Usoft.CellData;
Ysoft = this.Handles.Ysoft.CellData;
ODsize = this.Handles.eHandles(1).UDD.CellData;
IDsize = this.Handles.eHandles(2).UDD.CellData;
Nsize = this.Handles.eHandles(3).UDD.CellData;

% Find the MPCStructure data
S = this.getMPCStructure;
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(S);

ULimits(:,1:2) = S.InData(S.iMV,[1,4]);
Uwts(:,1:3) = S.InData(S.iMV,[1,3,4]);
Usoft(:,1:2) = S.InData(S.iMV,[1,4]);
YLimits(:,1:2) = S.OutData(:,[1,4]);
Ywts(:,1:3) = S.OutData(:,[1,3,4]);
Ysoft(:,1:2) = S.OutData(:,[1,4]);
if NumUD > 0
    IDsize(:, 1:2) = S.InData(S.iUD,[1,4]);
end

ODsize(:, 1:2) = S.OutData(:, [1,4]);
Nsize(:, 1:2) = S.OutData(S.iMO, [1,4]);

% Now make the changes
this.Handles.ULimits.setCellData(ULimits);
this.Handles.YLimits.setCellData(YLimits);
this.Handles.Uwts.setCellData(Uwts);
this.Handles.Ywts.setCellData(Ywts);
this.Handles.Usoft.setCellData(Usoft);
this.Handles.Ysoft.setCellData(Ysoft);
this.Handles.eHandles(1).UDD.setCellData(ODsize);
this.Handles.eHandles(2).UDD.setCellData(IDsize);
this.Handles.eHandles(3).UDD.setCellData(Nsize);


% Set flag to signal that update was done
this.updateTables = 0;
