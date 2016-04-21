% PEM �́A��ʐ��`���f���̗\���덷������v�Z���܂��B
% 
%   MODEL = PEM(DATA,Mi)  
%
%   MODEL : ���肷�郂�f���� IDPOLY�A�܂��́AIDSS �I�u�W�F�N�g�t�H�[�}�b
%           �g�̌^�ŁA���肵�������U�ƍ\�����Ƌ��ɏo�͂��܂��B
%           Model.NoiseVariance �́ADATA ���琄�肳�ꂽ�C�m�x�[�V������
%           �U�ł��BMODEL �̐��m�ȃt�H�[�}�b�g�́AHELP IDPOLY ��HELP IDSS
%           ���Q�Ƃ��Ă��������B
%
%   DATA :  IDDATA �I�u�W�F�N�g�t�H�[�}�b�g�ŋL�q���ꂽ����Ɏg�p����f
%           �[�^�BHELP IDDATA ���Q�ƁB
%
%   Mi   : ���f���\�����`����s��A�܂��́A�I�u�W�F�N�g 
%           Mi = nx (an integer) �́A���� nx �̈�ʐ��`��ԃ��f����^��
%           �܂��B
%     
%           Mi = [na nb nc nd nf nk] �́A���̂悤�Ȉ�ʑ��������f����
%           ������ݒ肵�܂��B(�����̓f�[�^�̏ꍇ�Anb,nf,nk �͍s�x�N�g��
%           �ŁA���̓`�����l�����Ɠ����x�N�g�����ł��B)
%	  
%               A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%     
%          �ʂȕ\���Ƃ��āAMODEL = PEM(DATA,'na',na,'nb',nb,...) ������
%          �ȗ����������́A�[���ƍl���܂��B
%
%          ��ԋ�ԃ��f���ɑ΂��āAMODEL = PEM(DATA,'nx',nx) �́Anx �Ɏ�
%          ���x�N�g�����`���܂��B�����ŁA�����̍ŏI�I�����v������܂��B
%
%          Mi �́AIDSS, IDPOLY, IDGREY �Ő��肵�����f���A�܂��́A�쐬����
%          ���f���ł��B
%          �ŏ����́AMi �Őݒ肳�ꂽ�p�����[�^�ŏ���������܂��B
%
% MODEL = PEM(DATA,Mi,Property_1,Value_1, ...., Property_n,Value_n) ���g
% ���āA���f���\����A���S���Y���Ɋ֘A���邷�ׂẴv���p�e�B���^������
% ���B�v���p�e�B�̖�/�l�̃��X�g�ɂ��ẮAHelp IDSS, IDPOLY, EDGREY, 
% IDPROPS ALGORITHMS ���Q�Ƃ��Ă��������B�A���S���Y���ɉe�����邢������
% �d�v�ȃv���p�e�B�́A���̂��̂ł��B
%       'nk': ���͂���̒x��
%       'InitialState': �����t�B���^��Ԃ̎�舵�����@
%       'Focus': ����̎��g���͈͂Ƀt�B�b�g�����t�H�[�J�X
%       'trace': ����ߒ��Ɋւ�����̃R�}���h�E�B���h�E�\���̐���
%
% ���ׂẲ\�ȕ\�L�@�ɂ����ă��f���\�� Mi ���ȗ�����ƁA�f�[�^���琄��
% ����郂�f�������̏�ԋ�ԕ\���ɂȂ�܂��B���������āAMODEL = PEM(Z) �́A
% nk = 1 �̑Ó��ȃ��f���\���𐄒肵�܂��B
%
% �Q�l: IDPOLY, IDSS, IDGREY, ARMAX, OE, BJ, IDPROPS


%	L. Ljung 10-1-86, 7-25-94


%       Copyright 1986-2001 The MathWorks, Inc.
