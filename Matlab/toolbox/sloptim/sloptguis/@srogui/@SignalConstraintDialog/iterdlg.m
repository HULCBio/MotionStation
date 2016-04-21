function hText = getIterDisplay(this)
% Returns text area for displaying optimization iterations

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:22 $
%   Copyright 1986-2004 The MathWorks, Inc.
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*
import java.awt.*
Proj = this.Project;
if isempty(Proj.IterDisplay) || ~ishandle(Proj.IterDisplay.Frame)
   % Create frame
   hFrame = MJFrame('Optimization Progress');
   hFrame.setBounds(0,0,650,500);
   centerfig(hFrame,0)
   % Add text area
   cp = hFrame.getContentPane;
   cp.setLayout(BorderLayout);
   hText = MJTextArea;
   hText.setFont(com.mathworks.services.FontPrefs.getFontForComponent('Command Window'))
   UIColor = get(0,'DefaultUIControlBackgroundColor');
   hText.setBackground(java.awt.Color(UIColor(1),UIColor(2),UIColor(3)))
   hText.setEditable(false)
   % Scroll pane
   taSP = MJScrollPane(hText);
   cp.add(taSP);
   % Callbacks and listeners
   f = @(x,y) localClose(hFrame,Proj);
   set(hFrame,'WindowClosingCallback', f);
   L = handle.listener(Proj,'ObjectBeingDestroyed', f);
   % Store handles
   Proj.IterDisplay = struct('Text',hText,'Frame',hFrame,'Listeners',L);
   hFrame.setVisible(true)
end
hText = Proj.IterDisplay.Text;
   
%----------- local functions --------------------------

function localClose(hFrame,Proj)
% Clean up when window closed or project destroyed
if ishandle(hFrame)
   hFrame.setVisible(false)
   hFrame.dispose
   Proj.IterDisplay = [];
end
