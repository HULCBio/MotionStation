% BVPSET  BVP OPTIONS�\���̂̐ݒ�ƏC��
% 
% OPTIONS = BVPSET('NAME1',VALUE1,'NAME2',VALUE2,...)�́ANAME�v���p�e�B
% �ɐݒ肵���l�����ϕ��I�v�V�����\����OPTIONS���쐬���܂��B�ݒ肳���
% ���Ȃ��v���p�e�B�́A�f�t�H���g�l���g���܂��B�ݒ肷��v���p�e�B���́A�v
% ���p�e�B�������ʂł���͈͂ō\���܂���B�܂��A�啶���A�������̋�ʂ͂�
% ��܂���B
%   
% OPTIONS = BVPSET(OLDOPTS,'NAME1',VALUE1,...)�́A���ɐݒ肳��Ă���I�v
% �V�����\����OLDOPTS��ύX���܂��B 
%   
% OPTIONS = BVPSET(OLDOPTS,NEWOPTS)�́A���ɐݒ肳��Ă���I�v�V�����\��
% ��OLDOPTS��V�����I�v�V�����\����NEWOPTS�Ƒg�ݍ��킹�܂��B�������̐V
% �����v���p�e�B���A�Ή�����Â��v���p�e�B�ƒu���������܂��B
%   
% BVPSET���g�ł́A���ׂẴv���p�e�B���Ǝ�蓾��\�Ȓl��\�����܂��B
%   
% BVPSET�v���p�e�B
%   
% RelTol - �c���ɑ΂��鑊�΋��e�ʁA[���̃X�J����  {1e-3} ]
%    ���̃X�J���ʂ́A�c���x�N�g���̂��ׂĂ̗v�f�ɓK�p����܂��B�����āA
%    �f�t�H���g�́A1e-3(0.1%�̐��x)�ł��B�v�Z����� S(x)�́A
%    S'(x) = F(x,S(x))+res(x)�̌����ȉ��ɂȂ�܂��B���b�V���̊e������
%    �����āA�c��res(x)�́A�����𖞑����܂��B
% 
%         norm(res(i)/max(abs(F(i)),AbsTol(i)/RelTol)) < =  RelTol.
%
% AbsTol - �c���ɑ΂����΋��e�ʁA[���̃X�J���܂��̓x�N�g��  {1e-6}]
%    �X�J�����e�ʂ́A�c���x�N�g���̂��ׂĂ̗v�f�ɓK�p����܂��B���e��
%    �x�N�g���̊e�v�f�́A�c���x�N�g���̑Ή�����v�f�ɓK�p����܂��B
%    AbsTol�̃f�t�H���g��1e-6�ł��BRelTol���Q�Ƃ��Ă��������B 
%
% SingularTerm - ���ق�BVP�̓��ٍ��A[ �s�� ]
%    y' = S*y/x + f(x,y,p)�̌`���̕������ɑ΂��Ē萔�s��S��ݒ肵�܂��B
%
% FJacobian - ODEFUN�̉�͓I�ȕΔ����W���A[ �֐� | �s�� | �Z���z�� ]
%    ���Ƃ��΁Ay' = f(x,y)�������Ƃ��A DFDY = FJAC(X,Y)��y�Ɋւ���
%    ���R�r�A��f���v�Z����ꍇ�ɂ́A ���̃v���p�e�B��@FJAC�ɐݒ肵�܂��B
%    ��肪���m�̃p�����[�^���܂ޏꍇ�́A[DFDY,DFDP] = FJAC(X,Y,P)��p��
%    �ւ���f�̉�͓I�ȕΔ������o�͂���K�v������܂��B�萔�̕Δ���������
%    ���ɑ΂��ẮA���̃v���p�e�B��DFDY�̒l�A���邢�̓Z���z��
%    {DFDY,DFDP}�ɐݒ肵�܂��B
%
% BCJacobian - BCFUN�̉�͓I�ȕΔ����W���A[ �֐� | �Z���z�� ]
%    ���Ƃ��΁A���E����bc(ya,yb) = 0�̏ꍇ�A[DBCDYA,DBCDYB] = BCJAC(YA,YB)
%    ��ya��yb�Ɋւ���bc�̕Δ������v�Z����ꍇ�́A���̃v���p�e�B��@BCJAC
%    �ɐݒ肵�܂��B��肪���m�̃p�����[�^���܂ޏꍇ�́A
%    [DBCDYA,DBCDYB,DBCDP] = BCJAC(YA,YB,P) ��p�Ɋւ���f�̕Δ������o��
%    ����K�v������܂��B�萔�̕Δ����������ɑ΂��ẮA���̃v���p�e�B
%    �̓Z���z��{DBCDYA,DBCDYB} �܂��� {DBCDYA,DBCDYB,DBCDP}�ɐݒ肵�܂��B
%
% Nmax - ���b�V���_�̋��e�ő�_���A[���̐��� {floor(1000/n)}]
%
% Stats - �v�Z�ʂ̕\���A[ on | {off} ]
%
% Vectorized - �x�N�g�������ꂽODE�֐��A[ on | {off} ]
%    ���W���֐� ODEFUN([x1 x2 ...],[y1 y2 ...]) �� 
%    [ODEFUN(x1,y1) ODEFUN(x2,y2) ...] ���o�͂���ꍇ�́A���̃v���p�e�B
%    �� 'on' �ɐݒ肵�܂��B�p�����[�^�����݂���ꍇ�́A���W���֐�
%    ODEFUN([x1 x2 ...],[y1 y2 ...],p) �� 
%    [ODEFUN(x1,y1,p) ODEFUN(x2,y2,p) ...] ���o�͂��܂��B
%
% �Q�l �F BVPGET, BVPINIT, BVP4C, DEVAL.


%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
