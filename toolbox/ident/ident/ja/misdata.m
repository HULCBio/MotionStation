%MISDATA: �����f�[�^�̐���
%
%   DATAE = MISDATA(DATAN,MODEL)
%   DATAE = MISDATA(DATAN,MAXITER,TOL)
%
%   DATAN: IDDATA�t�H�[�}�b�g�̃f�[�^�B���͂܂��́A�o�͂̌����f�[�^�́A
%          NaN�Ŏw�肵�܂��B
%   MODEL: �C�ӂ� IDMODEL (IDPOLY, IDSS, IDARX, IDGREY) �t�H�[�}�b�g��
%          ���f���B���̃��f���́A�����f�[�^�̕����̂��߂ɗ��p����܂��B
%   MAXITER: N4SID ���f���̃f�t�H���g�������w�肳��Ă��Ȃ��ꍇ�ɗ��p
%            ����܂��BMAXITER �܂ŃC�^���[�V���������s����AMODEL ��
%            DATAE �����݂ɐ��肳��܂��B�C�^���[�V�����́A�����f�[�^
%            �̐���l�̕ω��� TOL % �ȉ��ɂȂ�ƏI�����܂��B
%            (�f�t�H���g�ł́AMAXITER = 10 �� TOL = 1 �ł��B)
%   DATAE: �����f�[�^�̐���l���܂� IDDATA �t�H�[�}�b�g�̃f�[�^�Z�b�g�B
%          �܂�ADATAN �̌����f�[�^������l�Œu���������܂��B

%	L. Ljung 00-05-10


%	Copyright 1986-2001 The MathWorks, Inc.
