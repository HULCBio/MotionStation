% CVLOAD   �t�@�C������ coverage �e�X�g�⌋�ʂ����[�h
%
%
% [TESTS, DATA] = CVLOAD(FILENAME) �́A�e�L�X�g�t�@�C�� FILENAME.CVT �ƃo�C
% �i���t�@�C�� FILENAME.CVB �ɃX�g�A����Ă���e�X�g�ƃf�[�^�����[�h���܂��B
% ���[�h����������ƁATESTS �̒��ɁAcvtest �I�u�W�F�N�g�̃Z���z����o�͂��܂��B
% DATA �́A���܂����[�h���ꂽ cvdata �I�u�W�F�N�g�̃Z���z��ł��BDATA �́A
% TESTS �Ɠ����T�C�Y�������܂����A����̃e�X�g�����ʂ������Ȃ��ꍇ�A��̗v�f
%
% [TESTS, DATA] = CVLOAD(FILENAME, RESTORETOTAL) �́ARESTORETOTAL ��1�̏ꍇ�A
% �ȑO�̎��s����̗ݐό��ʂ𕜌����܂��BRESTORETOTAL ��0�̏ꍇ�A���f���̗ݐ�
% ���ʂ̓N���A����܂��B
%
% ���ʂȍl�����F
%
% 1. �������O�������f�����Acoverage �f�[�^�x�[�X�̒��ɑ��݂���ꍇ�A�d������
% ���Ƃ�����邽�߁A���݂��Ă��郂�f���𒲂ׁA�������������ʂ݂̂��t�@�C��
% ���烍�[�h����܂��B
%
% 2. �t�@�C������Q�Ƃ��ꂽ Simulink ���f�����J����Ă͂��邪 coverage�f�[
% �^�x�[�X���ɑ��݂��Ă��Ȃ��ꍇ�Acoverage �c�[���́A���݂��Ă��郂�f���Ƃ̃���
% �N�������܂��B
%
% 3. �������f�����Q�Ƃ��Ă��邢�����̃t�@�C�������[�h����Ƃ��A�����̃t�@�C
% ���Ɛ������̂��錋�ʂ݂̂����[�h����܂��B
%
% �Q�l : CVDATA, CVTEST, CVSAVE.


% Copyright 1990-2002 The MathWorks, Inc.
