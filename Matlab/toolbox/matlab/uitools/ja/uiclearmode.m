% UICLEARMODE   �J�����g�̉�b�^���[�h�̃N���A
% 
% UISTATE = UICLEARMODE(FIG) �́Afigure�E�B���h�E�̑Θb�I�ȃv���p�e�B��
% ��~���A�\���� UISTATE �ɑO�̏�Ԃ��o�͂��܂��B���̍\���̂́Afigure��
% WindowButton* �֐��ƃJ�[�\���Ɋւ�������܂݂܂��B�܂��Afigure��
% ���ׂĂ̎q�I�u�W�F�N�g�� ButtonDownFcn �Ɋւ�������܂݂܂��B
%
% UISTATE = UICLEARMODE(FIG�AFUNCTION [, ARGS]) �́A2��ނ̕��@��
% figure FIG �̉�b�I�ȃv���p�e�B���~���܂��B�܂��A�ŏ��̕��@�́A�A�N
% �e�B�u�Ȃ��̂����݂���ꍇ�Ɏ��ʂ��AFigure WindowButtonDown �R�[��
% �o�b�N�̂悤�ɁA���̃C�x���g�n���h�����O�����̂ł��B����1�̕��@�́A
% UICLEARMODE �́A�V�������[�h�ɑ΂���deinstaller �Ƃ��Ċ֐� FUNCTION 
% ���C���X�g�[�����܂��B�ŏI�I�ɁAUICLEARMODE �́AUISUSPEND �̂悤�� 
% WindowButton* �֐������Z�b�g���A�ۑ������ UIRESTORE �ɓn�����\����
% �ɏ����o�͂��܂��B
%
% UISTATE=UICLEARMODE(FIG,'docontext',...) �́Auicontext ���j���[��
% ��~���܂��B
%
% ���:
% 
% ���̊֐��́Aplotedit �� rotate3d�̂悤�ȑ��̃��[�h�Ƌ��Ɏg���V�����Θb
% �^���[�h���`���܂��B
%
% ����́Amyinteractivemode ���A�N�e�B�u�ɂȂ�O�ɁA�v���b�g�ҏW�@�\��
% rotate3d �@�\���~�߂܂��Bmyinteractivemode ���A�N�e�B�u�̏ꍇ�́A
% myinteractive(fig,'off') �Ńv���b�g�ҏW�@�\���Ăт������Ƃ��o���܂��B
% myinteractivemode ���Ăяo���V���^�b�N�X�́A���̂悤�ɂ��܂��B
% 
%       myinteractivemode(gcf,'on')   % �}�E�X�N���b�N�ŃJ�����g�|�C���g
%                                     % ��\�����܂��B
%   
%   function myinteractivemode(fig,newstate)
%   %MYINTERACTIVEMODE.M
%   persistent uistate;
%      switch newstate
%      case 'on'
%         disp('myinteractivemode: on');
%         uistate = uiclearmode(fig,'myinteractivemode',fig,'off');
%         set(fig,'UserData',uistate,...
%                 'WindowButtonDownFcn',...
%                 'get(gcbf,''CurrentPoint'')',...
%                 'Pointer','crosshair');
%      case 'off'
%         disp('myinteractivemode: off');
%         if ~isempty(uistate)
%            uirestore(uistate);
%            uistate = [];
%         end
%      end
%
%  �Q�l�F UISUSPEND, UIRESTORE, SCRIBECLEARMODE.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/28 02:08:54 $
