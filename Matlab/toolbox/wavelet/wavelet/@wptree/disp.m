function disp(t)
%DISP Display information of WPTREE object.
%
%   See also GET, READ, SET, WRITE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 06-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:39:07 $

% Get wavelet packet tree information.
[order,depth,tn,wavName,Lo_D,Hi_D,Lo_R,Hi_R,entName,entPar] = get(t,...
	'order','depth','tn', ...
	'wavName','Lo_D','Hi_D','Lo_R','Hi_R', ...
	'entName','entPar' ...
	);
dataSize = read(t,'sizes',0);

headerStr = [...
	' Wavelet Packet Object Structure '
    '================================='
	];

infoStr = [...
    ' Size of initial data       : '
    ' Order                      : ' 
    ' Depth                      : '
    ' Terminal nodes             : '
    ' Wavelet Name               : '
    ' Low Decomposition filter   : '
    ' High Decomposition filter  : '
    ' Low Reconstruction filter  : '
    ' High Reconstruction filter : '
    ' Entropy Name               : '
    ' Entropy Parameter          : '
    ];

	
% Setting Strings.
%-----------------
prec = 4;

tn = tn';
nb_tn = length(tn);
lStr = '['; 
if nb_tn>16 , nb_tn = 16; rStr = ' ...]'; else , rStr = ']'; end
tnStr = [lStr int2str(tn(1:nb_tn)) rStr];

lf = length(Lo_D);
lStr = '['; lStr = lStr(ones(4,1));
if lf>8 , lf = 8; rStr = ' ...]'; else , rStr = ']'; end
rStr = rStr(ones(4,1),:);
F = [Lo_D;Hi_D;Lo_R;Hi_R];
indFirst = 6;
FStr = [infoStr(indFirst:indFirst+3,:) lStr num2str(F(:,1:lf),prec) rStr];
if isnumeric(entPar) , entPar = num2str(entPar,prec); end

addLen = 20;
sep = '-';
sepStr = sep(ones(1,size(infoStr,2)+addLen));	


% Displaying.
%------------
disp(' ')
disp(headerStr);
ind = 1;     disp([infoStr(ind,:) , '[' int2str(dataSize) ']'])
ind = ind+1; disp([infoStr(ind,:) , int2str(order)])
ind = ind+1; disp([infoStr(ind,:) , int2str(depth)])
ind = ind+1; disp([infoStr(ind,:) , tnStr])
disp(sepStr);

ind = ind+1; disp([infoStr(ind,:) , wavName])
disp(FStr)
ind = indFirst+3;
disp(sepStr);

ind = ind+1; disp([infoStr(ind,:) , entName])
ind = ind+1; disp([infoStr(ind,:) , entPar])
disp(sepStr);
disp(' ')