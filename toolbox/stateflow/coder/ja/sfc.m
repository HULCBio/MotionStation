% SFC( METHOD, VARARGS )���g���āAStateflow �}�V���ɑ΂���C�R�[�h�𐶐�
% ���܂��BSFC�́A�K�؂�Stateflow�^�[�Q�b�g�n���h���Ő錾�����R�[������
% �^�[�Q�b�g�ɋ@�\���܂��B
%
% SFC�́A�w�肳�ꂽ�}�V���ɑ΂��āA����C�t�@�C���Z�b�g�𐶐����܂��B
% 
% 1. �}�V���w�b�_�t�@�C��  (.c)
% 2. �}�V���\�[�X�t�@�C��  (.h)
% 3. �}�V�����W�X�g���t�@�C��	(.c) 
%    (�V�~�����[�V�����^�[�Q�b�g�̏ꍇ�̂�)
% 4. �R���p�C���ˑ��̃��C�N�t�@�C�� 
%    (�V�~�����[�V����/MEX/�X�^���h�A���[���^�[�Q�b�g�̏ꍇ)
% 
% �}�V�����̊e�`���[�g�ɑ΂��āA
% 5. �`���[�g�w�b�_�t�@�C�� (.h)
% 6. �`���[�g�\�[�X�t�@�C�� (.c)
%
% SFC('-sfun')�́A���������R�[�h����Simulink S-Function�C���^�t�F�[�X�R
% �[�h���܂݂܂��B
% 
% SFC('-bitops')�́AC���C�N�ȃr�b�g����������܂��B
%
% SFC('-noflow')�́A�t���[�}�̃R�[�h�����ɑ΂��čœK�����s���܂���B
%
% SFC('-exportcharts')�́A�`���[�g�� entry �֐�����during �֐������`���[
% �g���ő�������Ȃ�(�g������Ȃ�)�R�[�h�������\�ɂ��܂��B���̃I�v�V��
% ���́A�X�e�[�g�}�V�����R�[�����郆�[�U�I���W�i���̊O���\�[�X���쐬����
% �ꍇ�ɗL���ł��B�����ŁA�`���[�g���̓��j�[�N�ł���K�v������A���A�p
% �����ȊO�̃L�����N�^���܂�ł͂����܂���B���̃I�v�V�����́AStateflow 
% Coder�̃��C�Z���X�������Ă���ꍇ�̂ݗL���ƂȂ�܂��B
% 
% SFC('-silent')�́A�R�[�h�������̂��ׂẴ��[�j���O���b�Z�[�W���\����
% ���܂��B
% 
% SFC('-preservenames')�́A������V���{���ɑ΂��閼�O�̊g���Ȃ��ŃR�[
% �h�𐶐����܂��B���̏ꍇ�A���ׂẴf�[�^/�X�e�[�g���̓��j�[�N�A���A
% �Ó��� C ���ʎq�ł���K�v������܂��B���Ȃ킿�A�X�C�b�`�̂悤�Ȗ��O��
% ���p�ł��܂���B�����łȂ���΁A�R���p�C���G���[�̌����ƂȂ�ł��傤�B
% 
% SFC('-nocomments')�́A�X�e�[�g�}�V���̃C���v�������g�Ɋ֘A����R�����g
% ���܂܂Ȃ��R�[�h�𐶐����܂��B���[�U�R�����g�̓R�[�h�ɂ��p������܂��B
% 
% SFC('-noecho')�́A�Z�~�R�����őł��؂��Ă��Ȃ��\���̎��s���ʂ�MATLAB
% �R�}���h�E�B���h�E�ւ̕\���𖳌��ɂ��܂��B
% 
% SFC('-msvc4x')�́Amexopts.bat�t�@�C���Ŏw�肳��Ă���R���p�C���̂���
% �̃��C�N�t�@�C���𐶐�����Ɠ����ɁAMicrosoft Visual C++ 4.x�̂��߂̃�
% �C�N�t�@�C���𐶐����܂��B
% 
% SFC('-watcom')�́AWatcom 10.6�R���p�C���̂��߂̃��C�N�t�@�C���𐶐���
% �܂��B
% 
% SFC('-msvc50')�́AMicrosoft Visual C++ 5.0�̂��߂̃��C�N�t�@�C���𐶐�
% ���܂��B
% 
% SFC('-unix')�́AUNIX�v���b�g�t�H�[�����gmake�̂��߂̃��C�N�t�@�C����
% �������܂��B
%  
% LANGUAGE = SFC('language')�A�܂��́ASFC(target, 'language')�́A�^�[�Q
% �b�g���ꕶ�����o�͂��܂��B
%
% [DEBUG, OPTIONAL, NEEDED] = SFC(target, 'flags')�́A3��ނ̃t���O�Ɋ�
% ��������o�͂��܂��BDEBUG�t���O�́AStateflow�f�o�b�K�ɑ΂���I�v�V��
% ���t���O�ł��BOPTIONAL�t���O�́A�R�[�h�����ƍœK���ɉe�����܂��BNEEDED
% �t���O�́A��`�����^�[�Q�b�g�ɑ΂��ĕK���K�v�ƂȂ�t���O�ł��B
%
% REVISION = SFC('revision')�́A�R�[�_�[���r�W�����𕶎��ŏo�͂��܂��B

%   Copyright (c) 1995-2001 by The MathWorks, Inc.
