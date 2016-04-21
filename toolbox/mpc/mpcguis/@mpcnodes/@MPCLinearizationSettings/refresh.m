function refresh(h)

% Copyright 2003 The MathWorks, Inc.

% Updates linearization table to reflect the state of the Simulink model
h.SyncSimulinkIO;
h.AnalysisIOTableModelUDD.data = h.getIOTableData;
evt = javax.swing.event.TableModelEvent(h.AnalysisIOTableModelUDD);
h.AnalysisIOTableModelUDD.fireTableChanged(evt);
