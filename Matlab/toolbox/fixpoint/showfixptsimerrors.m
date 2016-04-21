function showfixptsimerrors
%SHOWFIXPTSIMERRORS show overflow logs from last simulation

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.6.4.3 $  
% $Date: 2003/05/17 04:47:14 $

global FixPtSimRanges;

for i = 1:length(FixPtSimRanges)

    bo = isfield(FixPtSimRanges{i},'OverflowOccurred');
    bs = isfield(FixPtSimRanges{i},'SaturationOccurred');
    bp = isfield(FixPtSimRanges{i},'ParameterSaturationOccurred');
    bd = isfield(FixPtSimRanges{i},'DivisionByZeroOccurred');

    if bo || bs || bp || bd
    	disp(' ')
    	disp(FixPtSimRanges{i}.Path)
    	
    	if bo
        	disp(' ')
    	    disp(sprintf('    Overflow occurred %d time(s).',FixPtSimRanges{i}.OverflowOccurred))
    	end
    	
    	if bs
        	disp(' ')
    	    disp(sprintf('    Saturation occurred %d time(s).',FixPtSimRanges{i}.SaturationOccurred))
    	end
    	
    	if bp
        	disp(' ')
    	    disp(sprintf('    Parameter saturation occurred %d time(s).',FixPtSimRanges{i}.ParameterSaturationOccurred))
    	end
    	
    	if bd
        	disp(' ')
    	    disp(sprintf('    Division by zero occurred %d time(s).',FixPtSimRanges{i}.DivisionByZeroOccurred))
    	end
    	disp(' ')
    end    	
end
