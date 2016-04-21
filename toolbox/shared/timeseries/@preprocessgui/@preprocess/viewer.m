function viewer(h, owningFrame)
%VIEWER
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:33:01 $

import com.mathworks.toolbox.timeseries.*;

% Build GUI
h.javaframe = com.mathworks.toolbox.timeseries.Preprocess(owningFrame,h);
h.javaframe.reset(h);

% Window closing callback - need to create frame variable to
% effectively store callback
set(h.javaframe,'WindowClosingCallback',{@localClose h});
set(h.javaframe,'WindowClosedCallback',{@localClose h});
h.Handles = createHandleArray(h);
    
% Display the gui
awtinvoke(h.javaframe,'setVisible',true);


% -------------------------------------------------------------------------
% --
function s = createHandleArray(h)

% Callback for data sink panel
s.nodescombo = h.javaframe.fNodesCombo;
s.newnodenext = h.javaframe.fNewNodeText;
s.newsaveradio = h.javaframe.newSaveRadio;
s.existsaveradio = h.javaframe.existSaveRadio;
set(s.nodescombo,'ItemStateChangedCallback',{@localDataRoutingCallback h ...
    s.newsaveradio s.existsaveradio s.newnodenext s.nodescombo}); 
set(s.newsaveradio,'ItemStateChangedCallback',{@localDataRoutingCallback h ...
    s.newsaveradio s.existsaveradio s.newnodenext s.nodescombo});
set(s.newnodenext,'FocusLostCallback',{@localDataRoutingCallback h ...
    s.newsaveradio s.existsaveradio s.newnodenext s.nodescombo});

% Exclusion outlier panel
s.winlentxt = h.javaframe.getExclusionPanel.winlenTxt;
s.conftxt = h.javaframe.getExclusionPanel.confTxt;

% Exclusion expression panel
s.exclusiontxt = h.javaframe.getExclusionPanel.expressionTxt;

% Bounds panel
s.domainlowcombo = h.javaframe.getExclusionPanel.fDomainLowCombo;
s.domainhighcombo = h.javaframe.getExclusionPanel.fDomainHighCombo;
s.rangelowcombo = h.javaframe.getExclusionPanel.fRangeLowCombo;
s.rangehighcombo = h.javaframe.getExclusionPanel.fRangeHighCombo;
s.rangehightxt = h.javaframe.getExclusionPanel.fRangeHighTextField;
s.rangelowtxt = h.javaframe.getExclusionPanel.fRangeLowTextField;
s.domainhightxt = h.javaframe.getExclusionPanel.fDomainHighTextField;
s.domainlowtxt = h.javaframe.getExclusionPanel.fDomainLowTextField;

% Exclusion flatliane panel
s.flatlinelength = h.javaframe.getExclusionPanel.flatlineLength;

% Exclusion checkboxes
s.outliercheck = h.javaframe.getExclusionPanel.checkOutliers;
s.flatlinecheck = h.javaframe.getExclusionPanel.checkFlatlines;
s.boundscheck = h.javaframe.getExclusionPanel.checkBounds;
s.expressioncheck = h.javaframe.getExclusionPanel.checkExpression;

% Outlier callbacks
set(s.winlentxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.winlentxt 'Outlierwindow'});
set(s.winlentxt,'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.winlentxt 'Outlierwindow'});
set(s.conftxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.conftxt 'Outlierconf'});
set(s.conftxt,'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.conftxt 'Outlierconf'});

% Expression callback
set(s.exclusiontxt,'ActionPerformedCallback',{@stringTxtBoxCB h.Exclusion s.exclusiontxt 'Mexpression'});
set(s.exclusiontxt,'FocusLostCallback',{@stringTxtBoxCB h.Exclusion s.exclusiontxt 'Mexpression'});

% Flatline window length
set(s.flatlinelength,'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.flatlinelength 'Flatlinelength'});
set(s.flatlinelength,'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.flatlinelength 'Flatlinelength'});

% Bounds callbacks
set(s.domainlowcombo,'ItemStateChangedCallback',{@ComboCB h.Exclusion s.domainlowcombo 'Xlowstrict' {'off','on'}});
set(s.domainhighcombo,'ItemStateChangedCallback',{@ComboCB h.Exclusion s.domainhighcombo 'Xhighstrict' {'off','on'}});
set(s.rangelowcombo,'ItemStateChangedCallback',{@ComboCB h.Exclusion s.rangelowcombo 'Ylowstrict' {'off','on'}});
set(s.rangehighcombo,'ItemStateChangedCallback',{@ComboCB h.Exclusion s.rangehighcombo 'Yhighstrict' {'off','on'}});
set(s.rangehightxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.rangehightxt 'Yhigh'});
set(s.rangelowtxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.rangelowtxt 'Ylow'});
set(s.domainhightxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.domainhightxt 'Xhigh'});
set(s.domainlowtxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Exclusion s.domainlowtxt 'Xlow'});
set(s.rangehightxt,'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.rangehightxt 'Yhigh'});
set(s.rangelowtxt,'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.rangelowtxt 'Ylow'});
set(s.domainhightxt,'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.domainhightxt 'Xhigh'});
set(s.domainlowtxt,'FocusLostCallback',{@numericTxtBoxCB h.Exclusion s.domainlowtxt 'Xlow'});

% Exclusion checkbox callbacks
set(s.outliercheck,'ItemStateChangedCallback',{@CheckCB h.Exclusion s.outliercheck 'Outliersactive'});
set(s.flatlinecheck,'ItemStateChangedCallback',{@CheckCB h.Exclusion s.flatlinecheck 'Flatlineactive'});
set(s.boundscheck,'ItemStateChangedCallback',{@CheckCB h.Exclusion s.boundscheck 'Boundsactive'});
set(s.expressioncheck,'ItemStateChangedCallback',{@CheckCB h.Exclusion s.expressioncheck 'Expressionactive'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Filter Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detrend panel
s.detrendcheck = h.javaframe.getFilterPanel.detrendCheck;
set(s.detrendcheck,'FocusLostCallback',{@CheckCB h.Filtering s.detrendcheck 'Detrendactive'});
set(s.detrendcheck,'ItemStateChangedCallback',{@CheckCB h.Filtering s.detrendcheck 'Detrendactive'});
s.constradio = h.javaframe.getFilterPanel.constRadio;
set(s.constradio,'FocusLostCallback',{@RadioCB h.Filtering s.constradio 'Detrendtype' 'constant'});
set(s.constradio,'ActionPerformedCallback',{@RadioCB h.Filtering s.constradio 'Detrendtype' 'constant'});
s.lineradio = h.javaframe.getFilterPanel.lineRadio;
set(s.lineradio,'FocusLostCallback',{@RadioCB h.Filtering s.lineradio 'Detrendtype' 'line'});
set(s.lineradio,'ActionPerformedCallback',{@RadioCB h.Filtering s.lineradio 'Detrendtype' 'line'});

% First order filter panel
s.firstordtimeconstTxt = h.javaframe.getFilterPanel.firstOrderTimeConstTxt;
set(s.firstordtimeconstTxt,'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.firstordtimeconstTxt 'Timeconst'});
set(s.firstordtimeconstTxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.firstordtimeconstTxt 'Timeconst'});

% Transfer function panel
s.acoeffs = h.javaframe.getFilterPanel.AcoeffTxt;
set(s.acoeffs,'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.acoeffs 'Acoeffs'});
set(s.acoeffs,'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.acoeffs 'Acoeffs'});
s.bcoeffs = h.javaframe.getFilterPanel.BcoeffTxt;
set(s.bcoeffs,'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.bcoeffs 'Bcoeffs'});
set(s.bcoeffs,'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.bcoeffs 'Bcoeffs'});

% Ideal filter panel
s.freqrangetxt = h.javaframe.getFilterPanel.freqRangeTxt;
set(s.freqrangetxt,'FocusLostCallback',{@numericTxtBoxCB h.Filtering s.freqrangetxt 'Range'});
set(s.freqrangetxt,'ActionPerformedCallback',{@numericTxtBoxCB h.Filtering s.freqrangetxt 'Range'});
s.passstopcombo = h.javaframe.getFilterPanel.passstopCombo;
set(s.passstopcombo,'ItemStateChangedCallback', ...
    {@ComboCB h.Filtering s.passstopcombo 'Band' {'pass','stop'}});

% Filter type combo
s.filterselectcombo = h.javaframe.getFilterPanel.filterSelectCombo;
set(s.filterselectcombo,'ItemStateChangedCallback', ...
    {@ComboCB h.Filtering s.filterselectcombo 'Filter' {'firstord','transfer' 'ideal'}});

% Filtering check box
s.filteringcheck = h.javaframe.getFilterPanel.filteringCheck;
set(s.filteringcheck,'ItemStateChangedCallback',{@CheckCB h.Filtering s.filteringcheck 'Filteractive'});
set(s.filteringcheck,'FocusLostCallback',{@CheckCB h.Filtering s.filteringcheck 'Filteractive'});


%%%%%%%%%%% Interp Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s.removecheck = h.javaframe.getInterPanel.removeCheck;
s.missingcheck = h.javaframe.getInterPanel.missingCheck;
s.interpcombo = h.javaframe.getInterPanel.interpCombo;
s.alloranycombo = h.javaframe.getInterPanel.alloranyCombo;
set(s.removecheck,'FocusLostCallback',{@CheckCB h.Interp s.removecheck 'Rowremove'});
set(s.removecheck,'ItemStateChangedCallback',{@CheckCB h.Interp s.removecheck 'Rowremove'});
set(s.missingcheck,'FocusLostCallback',{@CheckCB h.Interp s.missingcheck 'Interpolate'});
set(s.missingcheck,'ItemStateChangedCallback',{@CheckCB h.Interp s.missingcheck 'Interpolate'});
%set(s.alloranycombo,'FocusLostCallback',{@ComboCB h.Interp s.alloranycombo 'Rowor' {'off','on'}});
set(s.alloranycombo,'ItemStateChangedCallback',{@ComboCB h.Interp s.alloranycombo 'Rowor' {'off','on'}});
set(s.interpcombo,'ItemStateChangedCallback',{@ComboCB h.Interp s.interpcombo 'method' {'zoh','Linear'}});


function numericTxtBoxCB(es,ed,h,javaTxt,prop)

% Text box callback for numeric property change detection
try
   txtstr = char(javaTxt.getText);
   if ~isempty(txtstr)     
      newval = eval(char(javaTxt.getText));
   else
      newval = h.findprop(prop).FactoryValue; 
      javaTxt.setText(num2str(newval));
   end
   set(h,prop,newval);
catch % Put back previous value 
   msg = ['You must specify either a numeric value or a MATLAB expression for ', ...
               h.findprop(prop).Description]; 
   msgbox(msg,'Data Preprocessing Tool','modal');
   val = get(h,prop);
   if isnumeric(val) 
       if length(val)==1
          javaTxt.setText(sprintf('%0.3g',val));
       elseif length(val)>1
          javaTxt.setText(['[' num2str(val) ']']);
       end
   elseif ischar(val)
       javaTxt.setText(val);
   end
end

function stringTxtBoxCB(es,ed,h,javaTxt,prop)

% Text box callback for exclsuio property change detection
set(h,prop,char(javaTxt.getText));

function ComboCB(es,ed,h,javaCombo,prop,vals)

% Combo box callback
set(h,prop,vals{double(javaCombo.getSelectedIndex)+1});


function CheckCB(es,ed,h,javaCheck,prop)

% The oulier removal checkbox callback
vals = {'off','on'};
set(h,prop,vals{javaCheck.isSelected+1});


function RadioCB(es,ed,h,radio,prop,val)

if radio.isSelected
    set(h,prop,val);
end

function localClose(es,ed,h)

% Window closing callback
h.close;
    

function localDataRoutingCallback(eventSrc,eventData,h, newSaveRadio,existSaveRadio, ...
   fNewNodeText,fNodesCombo)

% Callback for changes to data sink
if existSaveRadio.isSelected
    h.TargetNode = char(fNodesCombo.getSelectedItem);
else
    h.TargetNode = char(fNewNodeText.getText);
end
