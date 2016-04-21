function out = sfblk(varargin),
%
% SFBLK Implementaton Of Stateflow-SIMULINK block and instance managament.
%
%
%	Jay R. Torgerson
%	E. Mehran Mestchian
%	Copyright 1995-2002 The MathWorks, Inc.
%	$Revision: 1.36.2.1 $ $Date: 2004/04/15 00:59:55 $

out = 0;

switch(length(varargin)),
	case 0, 
		error('sfblk() called with NO ARGS');
		return;
	case 1,
		method = varargin{1};
		switch (method)
			case 'xIcon',
				out = blk_iconx_method;
				return;
			case 'yIcon',
				out = blk_icony_method;
				return;
			case 'tIcon',
				out = blk_icont_method(gcbh);
				return;
			otherwise, 
				if this_is_an_sflink(gcbh), return; end;
				blk_nuke_callbacks(gcbh);
				return;
		end;
	otherwise,
		if (nargout ~= 1) error('bad num of output args for call to sfblk()'); end;

		method = varargin{1};
		machModelH = varargin{2};
		if (nargin == 3), blockH = varargin{3};	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = blk_iconx_method,
%
%  Generates X data for curved corner blocks.
%
	x = [...
		0.085857;0.073638;0.061668;0.050191;0.039439;0.029633;0.020971;0.013629;0.007759;0.003478;0.000874;0;0;0.000874;0.003478;0.007759;0.013629;0.020971;0.029633;0.039439;0.050191;0.061668;0.073638;0.085857;0.914143;0.926362;0.938332;0.949809;0.960561;0.970367;0.979029;0.986371;0.992241;0.996522;0.999126;1;1;0.999126;0.996522;0.992241;0.986371;0.979029;0.970367;0.960561;0.949809;0.938332;0.926362;0.914143;0.089439;
		... inner icon xdata
		NaN;0.4;0.4;0.405;0.415;0.48;0.495;0.5;0.5;0.495;0.48;0.415;0.405;0.4;
	    NaN;0.5;0.5;0.505;0.515;0.585;0.595;0.6;0.6;0.595;0.58;0.515;0.505;0.5;
		NaN;0.44;0.425;0.44;0.455;0.44;0.44;0.445;0.455;0.47;0.49;0.5;
		NaN;0.55;0.535;0.55;0.565;0.55;0.55;0.55;0.545;0.53;0.51;0.5;
	];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = blk_icony_method,
%
%  Generates Y data for curved corner blocks.
%	
	y = [...
		0;0.001219;0.00485;0.010819;0.019005;0.029242;0.041321;0.054995;0.069987;0.085992;0.102683;0.119722;0.880278;0.897317;0.914008;0.930013;0.945005;0.958679;0.970758;0.980995;0.989181;0.99515;0.998781;1;1;0.998781;0.99515;0.989181;0.980995;0.970758;0.958679;0.945005;0.930013;0.914008;0.897317;0.880278;0.119722;0.102683;0.085992;0.069987;0.054995;0.041321;0.029242;0.019005;0.010819;0.00485;0.001219;0;0;
		... inner icon ydata
		NaN;0.625;0.57;0.555;0.55;0.55;0.555;0.57;0.63;0.645;0.65;0.65;0.64;0.625;
		NaN;0.43;0.37;0.355;0.35;0.35;0.355;0.37;0.425;0.445;0.45;0.45;0.445;0.43;
		NaN;0.525;0.525;0.55;0.525;0.525;0.5;0.465;0.425;0.405;0.4;0.4;
		NaN;0.48;0.48;0.45;0.48;0.48;0.515;0.55;0.58;0.595;0.6;0.6;
   ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = blk_icont_method(blockH),
%
%  Generates str data for block icon
%

%	There's a bug in Simulink where the gcbh at MaskDisplay timme
%	is the source Library and not the link block. So, the following
%	never works.
	if this_is_an_sflink(blockH) 
		str = 'L'; 
		change_icon_to(blockH, 'link')
	else 
		str = '';
		change_icon_to(blockH, 'block')
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blk_nuke_callbacks( blockH )
	set_param(blockH, 'CopyFcn'            , '');
	set_param(blockH, 'DeleteFcn'          , '');
	set_param(blockH, 'ClipboardFcn'       , '');
	set_param(blockH, 'DestroyFcn'         , '');

	verStr = version;
	if (str2num(verStr(1:3)) < 5.2), set_param(blockH, 'UndoDeleteFcn'      , 'sf(''Private'',''sfblk'',''UndoDelete'');');
	else set_param(blockH, 'UndoDeleteFcn' , '');
	end;

	set_param(blockH, 'OpenFcn'		       , '');
	set_param(blockH, 'CloseFcn'		   , '');
	set_param(blockH, 'LoadFcn'		       , '');
	set_param(blockH, 'ModelCloseFcn'	   , '');
	set_param(blockH, 'PostSaveFcn'		   , '');
	set_param(blockH, 'InitFcn'            , '');
	set_param(blockH, 'StartFcn'           , '');
	set_param(blockH, 'StopFcn'            , '');
	set_param(blockH, 'NameChangeFcn'      , '');
	set_param(blockH, 'MaskSelfModifiable' , 'On');

	

