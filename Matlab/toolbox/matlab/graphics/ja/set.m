% SET   �I�u�W�F�N�g�̃v���p�e�B�̐ݒ�
% 
% SET(H,'PropertyName',PropertyValue) �́A�n���h���ԍ��� H �̃O���t�B�b�N�X
% �I�u�W�F�N�g�̎w�肵���v���p�e�B�̒l��ݒ肵�܂��BH �́A�n���h���ԍ���
% �v�f�Ƃ���x�N�g���ŁA���̏ꍇ SET �́A���ׂẴI�u�W�F�N�g�̃v���p�e�B
% �l��ݒ肵�܂��B
%
% SET(H,a) �́Aa ���t�B�[���h�����I�u�W�F�N�g�̃v���p�e�B���ł���\���̂�
% �Ƃ��A�e�t�B�[���h���Ŏ��ʂ����v���p�e�B���A�\���̂Ɋ܂܂��l���g��
% �Đݒ肵�܂��B
%
% SET(H,pn,pv) �́AH �Ŏw�肳�ꂽ���ׂẴI�u�W�F�N�g�ɑ΂��āA�����񂩂�
% �Ȃ�Z���z�� pn �Ŏw�肳�ꂽ�v���p�e�B���A�Z���z��pv���̑Ή�����l��
% �ݒ肵�܂��B�Z���z�� pn ��1�sN��łȂ���΂Ȃ�܂��񂪁A�Z���z�� pv �́A
% M��length(H) �̂Ƃ��AM�sN��ł��\���܂���B���̂��߁A�e�I�u�W�F�N�g�� pn
% �Ɋ܂܂��v���p�e�B���̃��X�g�ɑ΂��ĈقȂ�l���g���čX�V����܂��B
% 
% SET(H,'PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
% �́A1�̕��ŕ����̃v���p�e�B�l��ݒ肵�܂��BSET �̓����Ăяo���ŁA�v��
% �p�e�B�ƒl�̕�����̑g�A�\���́A�v���p�e�B�ƒl�̃Z���z��̑g���g�����Ƃ�
% �ł��܂��B
%
%   A = SET(H�A'PropertyName') 
%   SET(H,'PropertyName')
% 
% �́A�n���h���ԍ��� H �̃I�u�W�F�N�g�̎w�肵���v���p�e�B�ɑ΂��Ď�蓾��
% �l���o�͂܂��͕\�����܂��B�o�͂����z��́A�\�Ȓl�̕����񂩂�Ȃ�
% �Z���z��A�܂��̓v���p�e�B���\�ȕ�����̒l�̗L���ȑg�������Ȃ��ꍇ
% �́A��̃Z���z��ł��B
% 
%   A = SET(H) 
% 
% SET(H)�́A�n���h���ԍ��� H �̃I�u�W�F�N�g�̂��ׂẴv���p�e�B���ƁA����
% ��̎�肤��l���o�͂܂��͕\�����܂��B�o�͒l�́A�t�B�[���h���� H �̃v��
% �p�e�B���A���̒l����肤��v���p�e�B�l����Ȃ�Z���z��܂��͋�̃Z���z
% ��ł���\���̂ł��B
%
% �I�u�W�F�N�g�̃v���p�e�B�̃f�t�H���g�l�́A������ 'Default'�A�I�u�W�F�N
% �g�^�C�v�A�v���p�e�B�����Ȃ��č���� ProprtyName ��ݒ肷�邱�ƂŁA
% �I�u�W�F�N�g�̏�ʂ̂��̂ɑ΂��Đݒ肳��܂��B���Ƃ��΁A�J�����g��
% figure�E�B���h�E��text�I�u�W�F�N�g�̃f�t�H���g�̐F��Ԃɐݒ肷��ꍇ��
%
%    set(gcf,'DefaultTextColor','red')
% 
% �f�t�H���g�l�́A�I�u�W�F�N�g�̉��ʂ�I�u�W�F�N�g���g�ɑ΂��Ă͐ݒ�ł�
% �܂���B���Ƃ��΁A'DefaultAxesColor' �̒l�́Aaxes��axes�̎q�ɑ΂��Ă͐�
% ��ł��܂��񂪁Afigure�⃋�[�g�ɑ΂��Ă͐ݒ�ł��܂��B
%
% PropertyValues �ɑ΂��āA����3�̕�����͓��ʂȈӖ�������܂��B
% 
%   'default' - �f�t�H���g�l���g�p(�ŋߐڂ̐e)
%   'factory' - �쐬���ɒ�`���ꂽ�l���g�p
%   'remove'  - �f�t�H���g�l������
% 
% �Q�l�FGET, RESET, DELETE, GCF, GCA, FIGURE, AXES.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:12 $
%   Built-in function.
