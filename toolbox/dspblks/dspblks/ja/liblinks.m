% LIBLINKS   ���C�u���������N���̏o�͂ƕ\��
%
% �����N�\�����؂芷������܂ŁA�I���W�i���̃u���b�N������\���ɂȂ�A
% ���f�����Ō�������e���C�u�����ւ̃t���p�X���A�u���b�N�̉����ɕ\��
% ����܂��B�T���̓��f���̂��ׂẴ��x���ŉ��ʃ��x�������ɍs���܂��B
%
% �����N�\�����I���̏ꍇ�A�e���C�u�����Ƀ����N���Ă���u���b�N�����܂Ƃ�
% �����|�[�g���AMATLAB �R�}���h�E�B���h�E�ɕ\������܂��B
%
% �����N�\�����I���̊ԂɁA���f�����Z�[�u������A���s����ꍇ�A�����N�\��
% �͎����I�ɃI�t�ɂȂ�܂��B
%
% liblinks(SYS) �́A�V�X�e�� SYS �̒��ł̃u���b�N�����N�̕\���󋵂�؂�
% �����܂��BLIBLINKS(SYS,MODE)�́AMODE �� 'on'�A'off'�A'toggle' ��ݒ肷
% �邱�Ƃɂ��A���ڃ����N���̕\���󋵂�ݒ肷�邱�Ƃ��ł��܂��B�f�t�H
% ���g�́ASYS ���J�����g�V�X�e��(gcs)�ŁAMODE �� 'toggle' �ł��B
%
% LIBLINKS(SYS,MODE,LIB) �́A���C�u���� LIB �Ƀ����N������݂̂̂�\��
% ���܂��B���Ƃ��΁ALIB �� 'mylib' ��ݒ肷��ƁA���C�u���� 'mylib' ��
% �����N���Ă���u���b�N�ɑ΂��郉�C�u�����p�X��\�����܂��B�f�t�H���g�ŁA
% LIB �́A''�ŁA���ׂẴ��C�u�����Ƀ����N���Ă�����̂��\������܂��B
%
% �����̃��C�u�����́A�Z���z��ŕ������ݒ肷�邱�Ƃɂ��A�w�肷�邱��
% ���ł��܂��B���Ƃ��΁ALIB={'lib1','lib2'} �́A���C�u����'lib1' �� 
% 'lib2'�Ƀ����N���Ă���u���b�N�Ɋւ���u���b�N�����N��\�����܂��B
%
% ��������"�}�N��"�����ALIB�ɑ΂��ăT�|�[�g����Ă��܂��B�����āA�Ή�
% ����u���b�N�Z�b�g���i�̒��Ɋ܂܂��O�����Đݒ肵�����C�u�������ɒ���
% �Ή����܂��B
%
%     �}�N��       ���i
%    ----------   ------------------------------------
%    'comm1'      Version 1��Communications Toolbox 
%    'comm15'     Version 1.5��Communications Toolbox
%    'comm2'      Version 2��Communications Blockset
%    'dsp2'       Version 2��DSP Blockset
%    'dsp3'       Version 3��DSP Blockset
%    'dsp4'       Version 4��DSP Blockset
%    'fp2'        Version 2��Fixed Point Blockset
%    'sl2'        Version 2��Simulink
%    'sl3'        Version 3��Simulink
%
% �}�N���́A�����g�ݍ��킹����A�ǉ��̃��C�u�������Ƌ��Ɏg�����Ƃ��ł��܂��B
% ���Ƃ��΁ALIB��{'dsp2','mylib'}��ݒ肷�邱�Ƃ́ADSP Blockset Version 2
% �̒��̔C�ӂ̃��C�u�����Ƀ����N���Ă���u���b�N�ƃ��[�U���ݒ肵�� 'mylib'
% ���C�u�����Ƀ����N���Ă��邷�ׂẴu���b�N�ɑ΂���u���b�N�p�X����
% �\�����܂��B
%
% LIBLINKS(SYS,MODE,LIB,CLRS)�́ALIB�ɂ��ݒ肳�ꂽ�e�X�̃��C�u�����ɑ�
% ������u���b�N���������邽�߂Ɏg�p����J���[��ݒ肵�܂��B�J���[�̐ݒ�
% �́A�����Ɉ�F�Ƃ��邩�A�܂��́ALIB�̒��̊e�v�f�Ɋe�X��F���g�����Ƃ�
% �ł��܂��B�ݒ肷��J���[�́A'red'�A'blue'�A'black' �̂悤�ɕK���������
% �ݒ肵�Ȃ���΂Ȃ�܂���B�f�t�H���g�ł́A���ׂẴu���b�N�ŁA'red' ��
% �g���܂��B
%
% BLKS=LIBLINKS(...)�́A�e�X���|�[�g����郊���N�ւ̃t���p�X���܂ލ\����
% ���o�͂��܂��B�\���̂́ALIB �������ɐݒ肳�ꂽ�X�̃��C�u�����v�f��
% ��Ɉ�̃t�B�[���h���������Ă��܂��B���Ƃ��΁ALIB �� {'dsp2','mylib'} 
% �̏ꍇ�ABLKS �́A2�̃t�B�[���h�A.dsp2 �� .mylib �������Ă��܂��B
% �e�t�B�[���h�̓��e�́A�p�X���̃Z���z��ɂȂ�A�����N���ꂽ�u���b�N��
% �΂��āA��̃p�X�������A���ꂪ�Ή����郉�C�u�����Ƀ����N���܂��B


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6.6.1 $ $Date: 2003/07/22 21:03:50 $
