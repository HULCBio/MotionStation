% IDMODEL/ZPK �́ALTI/ZPK �t�H�[�}�b�g�ɕϊ����܂��B
%
%   SYS = ZPK(MODEL)
%
% MODEL �́A�C�ӂ� IDMODEL �I�u�W�F�N�g(IDPOLY, IDSS, IDARX, IDGREY) ��
% ���B
% SYS �́AControl System Toolbox �� LTI/ZPK �I�u�W�F�N�g�t�H�[�}�b�g�ɂ�
% ��܂��B
%
% MODEL �̒��̃m�C�Y�� - ����(e) �́AInputGroup 'Noise' �Ƃ��ă��x���t��
% ����Ă��܂��B����A������͂́A'Measured' �Ƃ��ăO���[�v������Ă���
% ���B�ŏ��ɁASYS �̒��̃m�C�Y���͂��P�ʕ��U���������ւ̌��ɑΉ������
% ���ɁA�m�C�Y�`�����l���𐳋K�����܂��B
%
% SYS = ZPK(MODEL('Measured')) �A���邢�́ASYS = ZPK(MODEL, 'M')�́A�m�C
% �Y���͂𖳎����܂��B
%
% SYS = ZPK(MODEL('noise')) �́A(��Ő��K�����ꂽ)�m�C�Y������o�͂܂ł�
% �`�B�֐��V�X�e����^���܂��B
%
% �Q�l�F IDMODEL/ZPKDATA, IDMODEL/SS, LTI/ZPK



%   Copyright 1986-2001 The MathWorks, Inc.
