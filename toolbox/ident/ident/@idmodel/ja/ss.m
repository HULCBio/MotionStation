% IDMODEL/SS �́ALTI/SS �t�H�[�}�b�g�ɕϊ����܂��B
%
%   SYS = SS(MODEL)
%
% MODEL �́A�C�ӂ� IDMODEL �I�u�W�F�N�g(IDPOLY, IDSS, IDARX, IDGREY) ��
% ���B
% SYS �́AControl System Toolbox �� LTI/SS �I�u�W�F�N�g�t�H�[�}�b�g�ɂ�
% ��܂��B
%
% MODEL �̒��̃m�C�Y�� - ����(e) �́AInputGroup 'Noise' �Ƃ��ă��x���t��
% ����Ă��܂��B����A������͂́A'Measured' �Ƃ��ăO���[�v������Ă���
% ���B�ŏ��ɁASYS �̒��̃m�C�Y���͂��P�ʕ��U���������ւ̌��ɑΉ������
% ���ɁA�m�C�Y�`�����l���𐳋K�����܂��B
%
% SYS = SS(MODEL('Measured'))�A���邢�́ASYS = SS(MODEL,'M')�́A�m�C�Y��
% �͂𖳎����܂��B
%
% SYS = SS(MODEL('noise')) �́A�m�C�Y�`�����l���݂̂�\�����܂��B
%
% �Q�l�F IDSS.



%   Copyright 1986-2001 The MathWorks, Inc.
