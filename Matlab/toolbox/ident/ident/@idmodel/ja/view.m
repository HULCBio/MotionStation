% VIEW �́A���f���̎�X�̓������v���b�g���܂��B
% 
% ���̃��[�`���́ALTIVIEW ��K�v�Ƃ���̂ŁAControl System Toolbox ��K
% �v�Ƃ��܂��B
%   
% VIEW(Mod)
% 
% Mod �́A�C�ӂ�IDMODEL (IDGREY, IDARX, IDPOLY, IDSS)�A�܂��́AIDFRD ��
% �f���ł��B
% VIEW �́ACSTB �̒��� LTIVIEW �֐��ɃA�N�Z�X���A�ɂ��_�}�Ɠ��l�ɁA�X
% �e�b�v�����A�C���p���X�����A�{�[�h���}�A�i�C�L�X�g���}�A�j�R���X���}�A
% �ɗ�v���b�g��`���܂��B
%
% �����U��s�m�����̏��͎����܂���B�M����Ԃ𒲂ׂ�ɂ́A�R�}���h BO-
% DE, NYQUIST, STEP,IMPULSE, PZMAP ���g���Ă��������B
%
% ����\�ȓ��͂������f���ɑ΂��āA�����̓��͂���o�͂ւ̓`�B�֐���
% �����݂̂�������܂��B�m�C�Y������o�͂܂ł̓`�B�֐��̐����𒲂ׂ�ɂ�
% VIEW(m('n')) ('n' �́A'noise'�̗�)���g���܂��B�m�C�Y�̓`�B�֐��́A���f
% ���� NoiseVariance ���g���Đ��K������A�m�C�Y���́A�P�ʋ����U�s�����
% ���F�m�C�Y�ƂȂ�܂��B
%
% ���n�񃂃f��(������͂��Ȃ�)�ɑ΂��āA���K�����ꂽ�m�C�Y������̓`�B��
% ���ƂȂ�܂��B
%
% �������̃��f�����AVIEW(Mod1,Mod2,....,ModN) ���g���Ĕ�ׂ��܂��B��
% �X�̃��f���ɑ΂��āAPlotStyle(�J���[�A�}�[�J�A���C���X�^�C��)�́A
%
%    VIEW(Mod1,'PlotStyle1',Mod2,'PlotStyle2',...,ModN,'PlotStyleN')
% 
% �Őݒ�ł��܂��BPlotStyle �́A 'b', 'b+:'�̂悤�Ȓl����邱�Ƃ��ł���
% ���BHELP PLOT ���Q�Ƃ��Ă��������B
%   
% �����̍Ō�ɁA���̕�����
% 
%   'step','impulse','bode','nyquist','nichols','sigma','pzmap','iopzmap';
% 
% �������邱�Ƃ��ł��A�Ή�����^�C�v�ŁA�v���b�g�����������܂��B������
% ������(6 �܂�)�̃Z���z����g���āA�}���`�v���b�g���쐬���邱�Ƃ��ł�
% �܂��B
%
% VIEW �́AIDFRD ���f���p��(SPA �� ETFE �œ�����)�o�͕��U�X�y�N�g����
% �T�|�[�g���Ă��܂���B
%
% VIEW �́ALTIVIEW �̂��ׂẴI�v�V�������J�o�[���Ă��܂���BLTIVIEW ��
% �@�\�����\���ɗ��p���邽�߂ɂ́AControl Toolbox �̃R�}���h ltiview ��
% �g�p���Ă��������B�����𒼐ڃC���|�[�g�ł��邽�߁A���f���� lti �I�u
% �W�F�N�g�ɕϊ�����K�v�͂���܂���B


%   Copyright 1986-2001 The MathWorks, Inc.
