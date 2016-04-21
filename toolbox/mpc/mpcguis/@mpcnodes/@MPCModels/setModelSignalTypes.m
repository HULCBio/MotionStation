function setModelSignalTypes(varargin)

% Force all plant models to agree with the signal type assignments given
% in the MPCStructure node
%
% "this" is the MPCModels node

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:36:47 $

this = varargin{end};
S = this.getMPCStructure;
if isempty(S.iMV) || isempty(S.iMO)
    % Return if structure data haven't been set yet.
    return
end
for i = 1:length(this.Models)
    Plant = this.Models(i).Model;
    InGrp.MV = S.iMV;
    if ~isempty(S.iMD)
        InGrp.MD = S.iMD;
    end
    if ~isempty(S.iUD)
        InGrp.UD = S.iUD;
    end
    OutGrp.MO = S.iMO;
    if ~isempty(S.iUO)
        OutGrp.UO = S.iUO;
    end
    set(Plant, 'InputGroup', InGrp, 'OutputGroup', OutGrp, ...
        'InputName', S.InUDD.CellData(:,1), 'OutputName', ...
        S.OutUDD.CellData(:,1));
    this.Models(i).Model = Plant;
end
