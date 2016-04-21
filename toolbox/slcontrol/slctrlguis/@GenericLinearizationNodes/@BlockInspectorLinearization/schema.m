function schema
%SCHEMA  Defines properties for @BlockInspectorLinearization class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2004/04/11 00:35:32 $

%% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'BlockInspectorLinearization');

%% Property for the simulink block 
p = schema.prop(c, 'A', 'MATLAB array');
p.SetFunction = @LocalSetA;
p = schema.prop(c, 'B', 'MATLAB array');
p.SetFunction = @LocalSetB;
p = schema.prop(c, 'C', 'MATLAB array');
p.SetFunction = @LocalSetC;
p = schema.prop(c, 'D', 'MATLAB array');
p.SetFunction = @LocalSetD;

p = schema.prop(c, 'InLinearizationPath','string');
p = schema.prop(c, 'FullBlockName', 'string');
p.Visible = 'off';
p = schema.prop(c, 'SampleTimes', 'MATLAB array');
p.SetFunction = @LocalSetSampleTimes;

p = schema.prop(c, 'DiscardUpdate', 'MATLAB array');
p.Visible = 'off';

%% Storage for all the Block's linearization
p = schema.prop(c, 'allA', 'MATLAB array');    
p.Visible = 'off';
p = schema.prop(c, 'allB', 'MATLAB array');
p.Visible = 'off';
p = schema.prop(c, 'allC', 'MATLAB array');
p.Visible = 'off';
p = schema.prop(c, 'allD', 'MATLAB array');
p.Visible = 'off';
p = schema.prop(c, 'indx', 'MATLAB array');    
p.Visible = 'off';
p = schema.prop(c, 'indu', 'MATLAB array');
p.Visible = 'off';
p = schema.prop(c, 'indy', 'MATLAB array');
p.Visible = 'off';

%% Update functions - Use drawnow to flush java calls to prevent tread
%% locks.
function NewValue = LocalSetSampleTimes(this,NewValue)

if ~isempty(this.DiscardUpdate) && this.DiscardUpdate
    NewValue = this.SampleTimes;
    drawnow
    warndlg(['The the block sample times cannot be modified. ',...
                'The changes will be discarded.'],'Simulink Control Design')
end

function NewValue = LocalSetA(this,NewValue)

if ~isempty(this.DiscardUpdate) && this.DiscardUpdate
    NewValue = this.A;
    drawnow
    warndlg(['The modification of the block A matix is not supported. ',...
                'The changes will be discarded.'],'Simulink Control Design')
end

function NewValue = LocalSetB(this,NewValue)

if ~isempty(this.DiscardUpdate) && this.DiscardUpdate
    NewValue = this.B;
    drawnow
    warndlg(['The modification of the block B matix is not supported. ',...
                'The changes will be discarded.'],'Simulink Control Design')
end

function NewValue = LocalSetC(this,NewValue)

if ~isempty(this.DiscardUpdate) && this.DiscardUpdate
    NewValue = this.C;
    drawnow
    warndlg(['The modification of the block C matix is not supported. ',...
                'The changes will be discarded.'],'Simulink Control Design')
end

function NewValue = LocalSetD(this,NewValue)

if ~isempty(this.DiscardUpdate) && this.DiscardUpdate
    NewValue = this.D;
    drawnow
    warndlg(['The modification of the block D matix is not supported. ',...
                'The changes will be discarded.'],'Simulink Control Design')
end
