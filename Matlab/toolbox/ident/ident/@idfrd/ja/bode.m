% IDMODEL/BODE �́A�`�B�֐��A�܂��́A�X�y�N�g���� Bode ���}���v���b�g����
% ���B
% 
% BODE(M)�A�܂��́ABODE(M,'SD',SD)�A�܂��́ABODE(M,W)
%
% �����ŁAM �́AETFE �� SPA �Ɋ܂܂��v�Z���[�`�����瓾����IDPOLY, 
% IDSS, IDARX, IDGREY �̂悤�� IDMODEL�A�܂��́AIDFRD �I�u�W�F�N�g�ł��B
% 
% �M�����: BODE(M,'SD',SD)
% SD ���[�����傫�������̏ꍇ�ASD �W���΍��ɑΉ�����M����Ԃ��A�_�j��
% �Ŏ�����܂��B���f���̌�Ɉ��� 'FILL' ��t������ BODE(M,'sd',3,'fill') 
% �́A�M����Ԃ�ш�Ƃ��ĕ\�����܂��B
% 
% ���g���w��: BODE(M,W)
% W �́AIDMODELs �Ŏg�p������g���ł��BW ���x�N�g���̏ꍇ�A���g���֐��́A
% W �̒l�ɑ΂��āA�v���b�g����܂��BW ={WMIN,WMAX} �̏ꍇ�AWMIN �� WMAX 
% �Ԃ̎��g����Ԃ��ΐ����Ԋu�ɃJ�o�[����܂��B(����: �����ʂň݂͂܂��B)
% W = {WMIN,WMAX,NP} �́ANP �_�Ōv�Z����܂��BW �̒P�ʂ́Arad/s �ł��B
%
% �����̃��f��
% BODE(M1,M2,...,Mn) ���g���āA�������̃��f���̎��g���֐����v���b�g����
% ���BBODE(M1,'r',M2,'y--',M3,'gx')���g���āA�J���[�A���C���A�}�[�N��ݒ�
% ���邱�Ƃ��ł��܂��B�}�[�J�Ɋւ��ẮAHELP PLOT ���Q�Ƃ��Ă��������B
%
% �O���X�y�N�g��:
% �O���X�y�N�g�����v���b�g����ɂ́ABODE(M('noise')) ���g���܂��B
%
% MIMO ���f��:
% �}���`�`�����l�����f���ɑ΂��āA�e����/�o�̓`�����l���̑g���ɁA��������
% �v���b�g����܂��B�\�[�g�̓��f���� InputName �� OutputName �Ɋ�Â��A��
% �ׂẴ��f���̃`�����l�����������ł���K�v�͂���܂���B������o�͂̑g
% �̃v���b�g����ʂ̑g�̃v���b�g�֕\�����X�V���邽�߂ɂ́AENTER �L�[���
% �͂��܂��B�\���̓r���Ńv���b�g�������I�����邽�߂ɂ́ACTRL-C ����͂���
% ���B�����_�C�A�O�����ɂ��ׂẴv���b�g��\�����邽�߂ɂ́A���̂悤��
% ���s���܂��B
%     BODE(M,'Mode','same')
% �`�����l���̑g�́A�ꎞ�_�ł͂ЂƂ������v���b�g����܂��B����̓��o��
% �Ԃ̉�����\�����邽�߂ɂ́A���̂悤�Ɏ��s���܂��B
%     BODE(M(ky,ku))
%
% �Q�C��/�ʑ��̂ǂ��炩����݂̂̉��:
% �f�t�H���g���[�h�́A�Q�C���v���b�g�ƈʑ��v���b�g�𓯎��Ɏ������̂ł��B
% �X�y�N�g���ɑ΂��āA�ʑ��v���b�g�́A�ȗ�����܂��B�Q�C���̂݁A�܂��͈�
% ���݂̂�\�����邽�߂ɂ́A���ꂼ��A���̂悤�Ɏ��s���܂��B
%     BODE(M,'AP','A')
%     BODE(M,'AP','P')
%
% �v���p�e�B/�l�̑g ('AP',ap), ('SD',SD), ('MODE','same') �́A�C�ӂ̏���
% �Ŏg�p�ł��A�}���`���f���ɂ��@�\���܂��B
%
% �v���b�g�̔�\���A�Q�C��/�ʑ��̌v�Z�̏ȗ�
% �P��V�X�e���ŁA�o�͈�����ݒ肵�āABODE ���R�[������ƁA[MAG,PHASE] = 
% BODE(M,W) �� [MAG,PHASE,W,SDMAG,SDPHASE] = BODE(M) �́A�X�N���[����Ƀv
% ���b�g��\�����܂���B
% 
% M �� NY �o�́ANU ���͂������AW ��NW �̎��g�������ꍇ�AMAG �� PHASE 
% �́AMAG(ky,ku,k) ���A���� ku ����o�� ky �ł̎��g�� W(k) �̉�����^����
% NY-NU-NW �z��ɂȂ�܂��BSDMAG �� SDPHASE �́A�Q�C���ƈʑ��̕W���΍���
% �v�Z�A�o�͂��܂��BW �́A��� rad/s �ŗ^�����܂��BM �� IDFRD �I�u�W�F
% �N�g�̏ꍇ�AW ���w�肷�邱�Ƃ͂ł��܂���B
%
% M �����n��̏ꍇ�AMAG �́A���̃X�y�N�g�����o�͂��APHASE �͏�Ƀ[�����o
% �͂��܂��B
% ���̊֐��́A���U���f���A�A�����f�����Ɏ�舵�����Ƃ��ł��܂��B
%   
% ���f�� M �̏o�͂Ɋ֘A�����(�m�C�Y)�X�y�N�g���𓾂�ɂ́ABODE(M('no-
% ise')) ���g���܂��B���ʂȓ���/�o�͂̉����ɃA�N�Z�X����ɂ́ABODE(M(ky,
% ku)) ���g���܂��B
%
% �Q�l�F FFPLOT, IDMODEL/NYQUIST




%   Copyright 1986-2001 The MathWorks, Inc.
