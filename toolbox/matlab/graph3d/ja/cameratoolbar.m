% CAMERATOOLBAR   �Θb�b�I�ɃJ�����𑀍�
% 
% CAMERATOOLBAR �́Afigure�E�B���h�E��Ń}�E�X���h���b�O���邱�Ƃɂ�
% ��A�J�����⃉�C�g��Θb�I�ɑ��삷�邱�Ƃ̂ł���V�����c�[���o�[��
% �쐬���܂��B�J�����g��(gca)�̃J�����v���p�e�B�͉e�����󂯂܂��B
% �c�[���o�[�����������ꂽ�Ƃ��ɁA�������̃J�����v���p�e�B���ݒ肳��
% �܂��B
%
% CAMERATOOLBAR('NoReset') �́A�J�����v���p�e�B�̐ݒ���s��Ȃ���
% �c�[���o�[���쐬���܂��B
% 
% CAMERATOOLBAR('SetMode' mode) �́A�c�[���o�[�̃��[�h��ݒ肵�܂��B
% �ݒ�ł��郂�[�h�́A���̂��̂ł��B:'orbit', 'orbitscenelight',
% 'pan', 'dollyhv', 'dollyfb', 'zoom', 'roll', 'walk', 'nomode'
%
% CAMERATOOLBAR('SetCoordSys' coordsys) �́A�J�����̈ړ��̎厲��ݒ�
% ���܂��Bcoordsys �́A'x', 'y', 'z', 'none' �̂����ꂩ�ł��B
%
% CAMERATOOLBAR('Show') �́A�c�[���o�[��\�����܂��B
% CAMERATOOLBAR('Hide') �́A�c�[���o�[���\���ɂ��܂��B
% CAMERATOOLBAR('Toggle') �́A�c�[���o�[�̉���Ԃ�؂�ւ��܂��B
%
% CAMERATOOLBAR('ResetCameraAndSceneLight') �́A�J�����g�̃J�����ƌ�����
% ���Z�b�g���܂��B
% 
% CAMERATOOLBAR('ResetCamera') �́A�J�����g�̃J���������Z�b�g���܂��B
% CAMERATOOLBAR('ResetSceneLight') �́A�J�����g�̌��������Z�b�g���܂��B
% CAMERATOOLBAR('ResetTarget') �́A�J�����g�̃J�����^�[�Q�b�g�����Z�b�g
% ���܂��B
%
% ret = CAMERATOOLBAR('GetMode') �́A�J�����g���[�h���o�͂��܂��B
% ret = CAMERATOOLBAR('GetCoordSys') �́A�J�����g�厲���o�͂��܂��B 
% ret = CAMERATOOLBAR('GetVisible') �́A�������o�͂��܂��B
% ret = CAMERATOOLBAR �́A�c�[���o�[�ɑ΂���n���h�����o�͂��܂��B
%
% CAMERATOOLBAR('Close') �́A�c�[���o�[���폜���܂��B
%
% ���ӁF�����_�����O���\�́AOpenGL�n�[�h�E�F�A�ɉe�����󂯂܂��B
%
% �Q�l�FROTATE3D, ZOOM.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:54:32 $
