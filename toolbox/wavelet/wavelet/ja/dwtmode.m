% DWTMODE�@ ���U�E�F�[�u���b�g�ϊ��g�����[�h
% DWTMODE �́A���U�E�F�[�u���b�g�ϊ��A���U�E�F�[�u���b�g�p�P�b�g�ϊ��Ɋւ���M��
% �܂��̓C���[�W�̊g�����[�h��ݒ肵�܂��B�g�����[�h�́A�M����͂�C���[�W��͂�
% ���̃f�[�^�̒[�ł̘c�݂̉e������舵�����߂̗l�X�ȕ��@��񋟂��܂��B
%
% DWTMODE�A�܂��́ADWTMODE('status') �́A�J�����g�̃��[�h��\�����܂��BST = ...
% DWTMODE �܂��� ST = DWTMODE('status') �́A�J�����g�̃��[�h��\�����A�o�͂��܂��B
% ST = DWTMODE('status','nodisp') �́A�J�����g�̃��[�h��Ԃ��o�͂��܂����A�e�L�X
% �g�̕\���͍s���܂���B
%
% DWTMODE('zpd') �́ADWT ���[�h���[���p�f�B���O���[�h�ɐݒ肵�܂�(�f�t�H���g���[
% �h)�B
%
% DWTMODE('sym') �́ADWT ���[�h��Ώ̊g���ɐݒ肵�܂�(���E��u��������)�B
%
% DWTMODE('spd') (�܂��́ADWTMODE('sp1')) �́ADWT ���[�h��1���̕����p�f�B���O��
% �ݒ肵�܂�(�G�b�W��1�K�����l�̓��})�B
%
% DWTMODE('sp0') �́ADWT ���[�h��0���̕����p�f�B���O�ɐݒ肵�܂�(�G�b�W��萔��
% �g��)�B
%
% DWTMODE('ppd') �́ADWT ���[�h�������I�ȃp�f�B���O�ɐݒ肵�܂�(�G�b�W�������I��
% �g��)�B
%
% ��L5�̃��[�h�́A1������2�����̗����ɂ����ēK�p�\�ł��B�K�p���ꂽ DWT �́A
% �C�ӂ̒����̐M���ɑ΂��āA�킸���ɏ璷�ɂȂ�܂��B
%
% �ȉ��̃��[�h�́ADWT �������I�ɐݒ肵�܂��B���̃I�v�V�����́A�ł����K�͂ȃE�F�[
% �u���b�g�����ōs�Ȃ��܂��B
%
% DWTMODE('per') �́ADWT ���[�h�������I�Ɏ�舵���悤�ݒ肵�܂�(�֐� DWTPER �� 
% DWTPER2 �Ɠ����悤�Ȍ��ʂɂȂ�܂�)�B
%
% DWTMODE �́A5�̐M���g���̂��ꂼ�ꂪ���s������@�ŁA�O���[�o���ϐ����A�b�v�f
% �[�g���܂��B�g�����[�h�̕ύX�́ADWTMODE ��p������@�݂̂ōs���Ă��������B�O��
% �[�o���ϐ��𒼐ڕύX���邱�Ƃ����͔����Ă��������B
%
% --------------------------------------------------------------
% DWTMODE.DEF �t�@�C�������݂���ꍇ�A�f�t�H���g���[�h���A���̃t�@�C������ǂݍ�
% �܂�܂��B���݂��Ȃ��ꍇ�́A("toolbox/wavelet/wavelet" �f�B���N�g����)DWTMODE.
% CFG ���g���܂��BDWTMODE('save',mode) �́ADWTMODE.DEF �t�@�C���̒���(DWTMODE.
% DEF �Ɩ��t����ꂽ���ׂẴt�@�C���͕ۑ��O�ɍ폜����)�V�����f�t�H���g���[�h��
% ���� "mode" ��ۑ����܂��BDWTMODE('save') �́ADWTMODE('save',currentMode)�Ɠ�
% ���ł��B
% --------------------------------------------------------------
%
% �Q�l�F DWT, DWT2.



%   Copyright 1995-2002 The MathWorks, Inc.
