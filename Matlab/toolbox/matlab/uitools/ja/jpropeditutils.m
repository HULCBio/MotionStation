% JPROPEDITUTILS  PropertyEditor.java �p�̃��[�e���e�B�֐�
% 
% JPROPEDITUTILS �́A��X�̃T�u�֐���p�ӂ��Ă��܂��B
%
%   'jinit' ======================================================= 
%
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH] = JPROPEDITUTILS('jinit',H)
%   [VFIELDS,VALUES,OFIELDS,OPTIONS,PATH] = ....
%                  JPROPEDITUTILS('jinit',H,PROPNAMES)
%
% jget,jset,jpath ���R�[�����āA�����̏o�͈������擾�ł��A1�̃R�[��
% �ŁA���ׂĂ̂��̂��o�͂ł��܂��B
%
% get() �� set() ���瓾����v���p�e�B���X�g���قȂ�ꍇ�́A�v���p�e�B��
% �����킹�悤�Ƃ�������AJPROPEDITUTILS �́A2�̃v���p�e�B���̑g��
% �P�ɏo�͂��܂��B
%
%   'jget' ======================================================== 
%
%   [FIELDS,VALUES,ISMULTIPLE] = JPROPEDITUTILS('jget',H)
%   [FIELDS,VALUES,ISMULTIPLE] = JPROPEDITUTILS('jget',H,PROPNAMES)
%
% �����ŁAH �́AHG �n���h���ԍ����܂� 1 �s M ��̔z��ł��B
% �����ŁAPROPNAMES �́A�v���p�e�B����\��������܂��̓v���p�e�B����
% 1 �s N ��̃Z���z��ł��BPROPNAMES ���ȗ������ꍇ�́AJGET �͂���
% �Ẵv���p�e�B�����擾���܂��B
% 
% �����ŁAFIELDS �́A�v���p�e�B���� 1 �s N ��̃Z���z��ł��B
% �����ŁAVALUES �́A�v���p�e�B�l����Ȃ� 1�s N ��̃Z���z��ł��B
% H ��1��蒷���ꍇ�́A�e�v�f�͒l������ 1�s M ��̃Z���z��ł��B
%
%   'jset' ========================================================
%
%   [FIELDS,OPTION,ISMULTIPLE] = JPROPEDITUTILS('jset',H)
%   [FIELDS,OPTION,ISMULTIPLE] = JPROPEDITUTILS('jset',H,PROPNAMES)
%
% �����ŁAH �́AHG �n���h���ԍ����܂� 1 �s M ��̔z��ł��B
% �����ŁAPROPNAMES �́A�v���p�e�B����\��������܂��̓v���p�e�B����
% 1 �s N ��̃Z���z��ł��BPROPNAMES ���ȗ������ꍇ�́AJSET �͂��ׂ�
% �̃v���p�e�B����ݒ肵�܂��B
% 
% �����ŁAFIELDS �́A�v���p�e�B���� 1 �s N ��̃Z���z��ł��B
% �����ŁAOPTION �́A�K�؂ɃG�~�����[�g���ꂽ�I�v�V�����l�� 1�s N ���
% �Z���z��ł��B
%
%   'jpath' =====================================================
%
%   PATH = JPROPEDITUTILS('jpath',H)
% 
% H �́AHG �I�u�W�F�N�g�̒P��̃n���h���ԍ����A�܂��́A�n���h���ԍ�����
% �Ȃ�x�N�g���ł��BH �̒��̃^�C�v����X�̏ꍇ�͏o�͂����p�X�� 
% 'MIXED' �ɂȂ�܂��B���̑��̏ꍇ�APATH �́A�I�u�W�F�N�g�^�C�v�� m �t�@�C��
% �ւ̑��΃p�X���܂ރZ���z��ɂȂ�܂�(�p�X���t�@�C���̃Z�p���[�^�̑���
% �� . ���g�p����ꍇ�A�o�͂����p�X�́A�p�X�̍ŏ��ƍŌ�ň��̊Ԋu��
% �܂�ł��邱�Ƃɒ��ӂ��Ă�������)�B
%
% �I�u�W�F�N�g�ւ̃p�X��������Ȃ��ꍇ�́A�֐��͂��̃��b�Z�[�W���o��
% ���܂��B
%
%    .toolbox.matlab.graphics.
%
%  'jhelp' =======================================================
%
%  MSG = JPROPEDITUTILS('jhelp',H)
%  MSG = JPROPEDITUTILS('jhelp',TYPE)
%
% H �́A�����I�u�W�F�N�g�^�C�v�̒P��I�u�W�F�N�g�A�܂��́A�n���h���ԍ�
% ����Ȃ�x�N�g���̂����ꂩ�ł��B
% TYPE �́A�I�u�W�F�N�g�^�C�v��\��������ł��B
% MSG �́A�X�e�[�^�X���b�Z�[�W�ł��B
% 
%   'jselect'================================ 
% 
%   MSG = JPROPEDITUTILS('jselect',H) 
% 
%   'japplyexpopts'=============================== 
% 
%   JPROPEDITUTILS('japplyexpopts',H) 
% 
% H �́Afigure�̃n���h���̃x�N�g���ł��B
% 
% �J�����g�̃v���p�e�B��appdata�ɕۑ����āA�V�K�v���p�e�B��ݒ肵�܂��B
%    
%   'jrestorefig'=============================== 
% 
%   JPROPEDITUTILS('jrestorefig',H) 
% 
% H �́Afigure�̃n���h���̃x�N�g���ł��B
% 
% japplyexopt �֐����R�[�������O�ɐݒ肳�ꂽ�v���p�e�B�����X�g�A���܂��B 
% 
%   'jmeshcolor' ==================================== 
% 
%   C = JPROPEDITUTILS('jmeshcolor',H) 
% 
% H �́A�T�[�t�F�X�A�܂��́A�p�b�`�I�u�W�F�N�g�ւ̃n���h���ł��B
% C �́A�B�����b�V���Ƃ��ĕ\���I�u�W�F�N�g���쐬���邽�߂ɕK�v�ȃn��
% �h���ɑ΂��� FaceColor �ł��B
% 
% H ���P��I�u�W�F�N�g�̏ꍇ�́AC ��3�̐�������\������܂��BH ���x�N
% �g���̏ꍇ�AC �̓J���[�̃Z���͔z��ɂȂ�܂��B
% 
% �e��axes�̉����v���p�e�B�� 'off' �ŁAfigure�̃J���[�� 'none' �̏ꍇ�́A
% �o�͂����t�F�[�X�J���[�́A��  [1,1,1] �ɂȂ�܂��B
% 
%  'jinstrument' =================================== 
% 
%  H = JPROPEDITUTILS('jinstrument',H) 
% 
% listeners �� H �̒��̃n���h���ɉ����A���̃��X�g���o�͂��܂�(���ӁF
% listener ��1�񂾂��������܂�)�B


%   Copyright 1984-2002 The MathWorks, Inc.  
