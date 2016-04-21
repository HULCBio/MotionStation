function moduleList = fdmodp(moduleList);
%FDMODP  Filtdes module registry.

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

    moduleList = {moduleList{:} 'fdremez' 'fdfirls' 'fdkaiser' ...
                                'fdbutter' 'fdcheby1' ...
                                'fdcheby2' 'fdellip' ...
                                'fdpzedit'};
