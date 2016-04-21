function [winclassnames, winnames] = findallwinclasses(flag)
%FINDALLWINCLASSES Find all the non-abstract window classes in the sigwin package
%   [WINCLASSNAMES, WINNAMES] = FINDALLWINCLASSES returns two cell arrays. WINCLASSNAMES
%   contains the names of the classes (barthannwin, ...) and WINNAMES contains the names
%   of the windows (Bartlett-Hanning, ...).
%   [WINCLASSNAMES, WINNAMES] = FINDALLWINCLASSES('NONUSERDEFINED') return the all windows 
%   of the Signal Processing toolbox.
%
%   See also FINDNONABSTRACTSUBCLASSES.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 23:54:48 $ 

error(nargchk(0,1,nargin));
if nargin>0 & ~strcmpi(flag, 'nonuserdefined'),
    error('Invalid input argument');
end

%------------------------------------------------------------------
% Comment this section temporarily due to speed concerns
%------------------------------------------------------------------
% p=findpackage('sigwin');
% c=findclass(p);
% 
% % Find all the classes of the sigwin package
% nsubclasses=[];
% for i=2:length(c),
%     % We assume the first element of c is the window base class
%     if c(i).isDerivedFrom(c(1)),
%         nsubclasses = [nsubclasses; i];
%     end
% end
% 
% % Remove the abstract classes
% removedindex = [];
% for j=1:length(nsubclasses),
%     if strcmpi(c(nsubclasses(j)).Description, 'abstract'),
%         removedindex=[removedindex; j];
%     end
% end
% nsubclasses(removedindex) = [];
% 
% % Get the window name of each class
% winclassnames={};
% winnames = {};
% for k=1:length(nsubclasses),
%     winclassnames=[winclassnames;{c(nsubclasses(k)).Name}];
%     s = get(c(nsubclasses(k)).Properties);
%     ind=find(strcmp({s.Name}, 'name'));
%     winnames=[winnames;{s(ind).FactoryValue}];
% end
% 
% if nargin>0,
%     % Remove the user defined classes
%     index = find(strcmpi('User Defined',winnames));
%     winnames(index) = [];
%     winclassnames(index) = [];
% end
% 
% % Re-order in alphabetical order (see geck 111584)
% [y,i]=sortrows(char(winnames));
% winnames = winnames(i);
% winclassnames = winclassnames(i);

%------------------------------------------------------------------
% Temporary solution
%------------------------------------------------------------------
winclassnames = {'bartlett'; ...
    'barthannwin'; ...
    'blackman'; ...
    'blackmanharris'; ...
    'bohmanwin'; ...
    'chebwin'; ...
    'flattopwin';...
    'gausswin'; ...
    'hamming'; ...
    'hann'; ...
    'kaiser'; ...
    'nuttallwin'; ...
    'parzenwin'; ...
    'rectwin'; ...
    'triang'; ...
    'tukeywin'; ...
    'userdefined'; ...
    'functiondefined'};

winnames = {'Bartlett'; ...
    'Bartlett-Hanning'; ...
    'Blackman'; ...
    'Blackman-Harris'; ...
    'Bohman'; ...
    'Chebyshev'; ...
    'Flat Top';...
    'Gaussian'; ...
    'Hamming'; ...
    'Hann'; ...
    'Kaiser'; ...
    'Nuttall'; ...
    'Parzen'; ...
    'Rectangular'; ...
    'Triangular'; ...
    'Tukey'; ...
    'User Defined'; ...
    'User Defined'};

if nargin>0,
    % Remove the user defined classes
    winnames(end-1:end) = [];
    winclassnames(end-1:end) = [];
end


% [EOF]
