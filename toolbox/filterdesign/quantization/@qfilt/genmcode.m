function str = genmcode(Hq)
%GENMCODE Generate the M-code to reproduce the filter.

%   Author(s): J. Schickler
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/06/03 15:58:12 $

labels = coefficientnames(Hq);

% Setup the qfilts special properties
iargs = sprintf(',''FilterStructure'', ''%s''', get(Hq, 'FilterStructure'));

iargs = sprintf('%s, ''CoefficientFormat'', %s', iargs, tostring(get(Hq, 'CoefficientFormat')));
iargs = sprintf('%s, ''InputFormat'', %s', iargs, tostring(get(Hq, 'InputFormat')));
iargs = sprintf('%s, ''OutputFormat'', %s', iargs, tostring(get(Hq, 'OutputFormat')));
iargs = sprintf('%s, ''MultiplicandFormat'', %s', iargs, tostring(get(Hq, 'MultiplicandFormat')));
iargs = sprintf('%s, ''ProductFormat'', %s', iargs, tostring(get(Hq, 'ProductFormat')));
iargs = sprintf('%s, ''SumFormat'', %s', iargs, tostring(get(Hq, 'SumFormat')));

coeffs = referencecoefficients(Hq);

if iscell(coeffs{1}),
    for indx = 1:length(coeffs)
        for jndx = 1:length(coeffs{indx})
            coeffs{indx}{jndx} = sprintf('[%s]', num2str(coeffs{indx}{jndx}, '%22.18g'));
        end
        coeffs{indx}{1} = sprintf('{%s', coeffs{indx}{1});
        coeffs{indx}{end} = sprintf('%s}', coeffs{indx}{end});
        coeffs{indx} = sprintf('%s, ', coeffs{indx}{:});
        coeffs{indx}(end-1:end) = [];
    end
    coeffs = sprintf('%s, ', coeffs{:});
    coeffs = {sprintf('{%s}', coeffs(1:end-2))};
    labels = {'coefficients'};
    inputs = labels{1};
    descs  = {'SOS Coefficients'};
else
    
    for indx = 1:length(coeffs)
        coeffs{indx} = num2str(coeffs{indx}, '%22.18g');
        coeffs{indx} = sprintf('[%s]', coeffs{indx});
        
        % Remove all the extra spaces.
        [s, f] = regexp(coeffs{indx}, ' + ');
        idx = [];
        for jndx = 1:length(s)
            idx = [idx s(jndx)+1:f(jndx)];
        end
        
        coeffs{indx}(idx) = [];
        descs{indx} = sprintf('%s coefficient vector', labels{indx});
    end
    inputs = sprintf('%s, ', labels{:});
    inputs(end-1:end) = [];

    % Convert the coefficients back to strings.
    for indx = 1:length(coeffs)
        coeffs{indx} = num2str(coeffs{indx});
    end
    inputs = sprintf('{%s}', inputs);
end

inputs = ['''ReferenceCoefficients'', ' inputs];

h = sigcodegen.mcodebuffer;

h.add(h.formatparams(labels, coeffs, descs));
h.cr;
h.cradd('Hd = qfilt(%s%s);', inputs, iargs);

str = h.string;

% [EOF]
