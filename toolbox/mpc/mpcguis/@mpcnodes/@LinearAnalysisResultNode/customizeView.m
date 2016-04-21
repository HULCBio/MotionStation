function customizeView(h,manager)

% Copyright 2004 The MathWorks, Inc.

% Removes the combo box and text at the top of the linearization results
% panel since MPC linearization results have only one operating point and
% so this selection tool is not needed
h.getDialogInterface(manager);
panels = h.Dialog.getComponents;
for k=1:length(panels)
    if isa(panels(k),'javax.swing.JPanel')
        awtinvoke(h.Dialog,'remove(Ljava/awt/Component;)',panels(k));
        %awtInvoke(h.Dialog,'remove',panels(k));
        break
    end
end
awtinvoke(h.Dialog,'invalidate');
awtinvoke(h.Dialog,getMethod(getClass(h.Dialog),'repaint',[]));
