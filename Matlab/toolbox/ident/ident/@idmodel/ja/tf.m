% IDMODEL/TF �́ALTI/TF �t�H�[�}�b�g�ɕϊ����܂��B
%
%   SYS = TF(MODEL)
%
% MODEL �́A�C�ӂ� IDMODEL �I�u�W�F�N�g(IDPOLY, IDSS, IDARX, IDGREY) ��
% ���B
% SYS �́AControl System Toolbox �� LTI/TF �I�u�W�F�N�g�t�H�[�}�b�g�ɂ�
% ���Ă��܂��B
%
% MODEL �̒��̃m�C�Y�� - ����(e) �́AInputGroup 'Noise' �Ƃ��ă��x���t��
% ����Ă��܂��B����A������͂́A'Measured' �Ƃ��ăO���[�v������Ă���
% ���B�ŏ��ɁASYS �̒��̃m�C�Y���͂��P�ʕ��U���������ւ̌��ɑΉ������
% ���ɁA�m�C�Y�`�����l���𐳋K�����܂��B
%
% SYS = SS(MODEL('Measured'))�A���邢�́ASYS = TF(MODEL,'m')�́A�m�C�Y
% ���͂𖳎����܂��B
%
% SYS = SS(MODEL('noise')) �́A(��ŋL�q���ꂽ�悤�ɐ��K�����ꂽ)�m�C�Y��
% ����o�͂܂ł̓`�B�֐��V�X�e����^���܂��B
%
% �Q�l TF, IDMODEL/SS.



%   Copyright 1986-2001 The MathWorks, Inc.
