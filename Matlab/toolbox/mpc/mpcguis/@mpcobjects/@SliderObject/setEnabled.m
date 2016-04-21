function setEnabled(this,State)

% Copyright 2003 The MathWorks, Inc.

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

if xor(this.isEnabled, State)
    SwingUtilities.invokeLater(MLthread(this.Slider,'setEnabled',{State},...
        'boolean'));
    SwingUtilities.invokeLater(MLthread(this.TextField,'setEnabled',{State}, ...
        'boolean'));
end
this.isEnabled = State;