function varargout = daexplr(varargin)
%DAEXPLR Launches the Design Automation Model Explorer.
%   The Model Explorer is a unified explorer tool for Simulink,
%   Stateflow, SimMechanics, and related products.
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

try,

    mlock;
    
    root = slroot;
    whattodo = 0;
    node = 0;

    if nargin > 3
        error('Wrong number of arguments specified to daexplr');
    end

    if nargin > 0
        if ischar(varargin{1}) & nargin > 2
            error('Wrong number of arguments specified to daexplr');
        end
        for i=1:nargin
            if ischar(varargin{i})
                if whattodo ~= 0
                    % Already have whattodo, what string?
                    error('Wrong type of arguments specified to daexplr');
                else
                    whattodo = varargin{i};
                end
            else
                if whattodo ~= 0
                    % Already have whattodo and root
                    if ishandle(varargin{i}) | isnumeric(varargin{i})
                        node = varargin{i};
                    else
                        error('Wrong type of arguments specified to daexplr');
                    end
                else
                    % Dont already have whattodo and root
                    if ishandle(varargin{i})
                        root = varargin{i};
                    else
                        error('Wrong type of arguments specified to daexplr');
                    end
                end
            end
        end
    end
    
    if ~root.isa('DAStudio.Object') | ~root.isHierarchical
        error('Root Object must be a hierarchical DAStudio.Object');
    end

    invokenew = 0;
    if whattodo ~= 0
        if strcmpi(whattodo, 'new') == 1
            invokenew = 1;
        end
    end

    daRoot = DAStudio.Root;
    explorers = daRoot.find('-isa', 'DAStudio.Explorer');
    me = 0;
    if invokenew == 0
        for i=1:length(explorers)
            if root == explorers(i).getRoot
                me = explorers(i);
                break;
            end
        end
    end
    
    if me == 0
        me = DAStudio.Explorer(root, 'DAStudio Model Explorer');
        me.addCustomPropsGroup('Fixed-Point Properties',...
        {   ...
            'OutDataType';...
            'OutDataTypeMode';...
            'OutScaling';...
            'OutputDataTypeScalingMode';...
	    'SaturateOnOverflow';...
            'Rounding';...
            'DataType';...
            'FixptType.Bias';...
            'FixptType.FractionalSlope';...
            'FixptType.RadixPoint';...
            'FixptType.Lock';...
            'FixptType.BaseType';...
        }                     );
    else
        me.show;
    end

    
    if whattodo ~= 0
        if strcmpi(whattodo,'view') == 1
            if ~ishandle(node)
                sfr = sfroot;
                node = sfr.find('id', node);
            end
            me.view(node);
        end
    end
    
    if nargout == 1
        varargout{1} = me;
    end

end;
