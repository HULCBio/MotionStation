% GALLERY   Higham�e�X�g�s��
% 
% [out1,out2,...] = GALLERY(matname�Aparam1�Aparam2�A...)�́A�����Ƃ�
% �čs��̃t�@�~�����ł���matname�ƁA�t�@�~���̓��̓p�����[�^��������
% ���B�g�p�ł���s��t�@�~���́A���L���Q�Ƃ��Ă��������B�قƂ�ǂ̊֐�
% �́A�s��̎������w�肷����͈����������A�����łȂ���΁A�P��̏o��
% �����܂��B����ɏ��𓾂邽�߂ɂ́Amatname���s��̃t�@�~�����̂Ƃ��A
% "help private/matname"�ƃ^�C�v���Ă��������B
%
% cauchy    Cauchy�s��
% chebspec  Chebyshev�X�y�N�g�������s��
% chebvand  Chebyshev�������p��Vandermonde-like�s��
% chow      Chow�s��     - ����Toeplitz lower Hessenberg�s��
% circul    Circulant�s��
% clement   Clement�s��  - ��Ίp���[���̎O�d�Ίp�s��
% compar    Comparison�s�� 
% condex    �s��̏������̐���ɑ΂���Counter-���
% cycol     �z���������s��
% dorr      Dorr�s��     - �Ίp�Ɏx�z�I�ȗv�f�����������̈����O�d�Ίp
%           �s��(�o�͈�����3)
% dramadah  �t�s�񂪑傫�������v�f�����悤��1��0�̗v�f�����s��
% fiedler   Fiedler�s��  - �Ώ̍s��
% forsythe  Forsythe�s�� - �u�����ꂽJordan�u���b�N
% frank     Frank�s��    - �������̈����ŗL�l�����s��
% gearmat   Gear�s��
% grcar     Grcar�s��    - �q���ȌŗL�l������Toeplitz�s��
% hanowa    ���f���ʂ̐������ɌŗL�l�����s��
% house     Householder�s�� (�o�͈�����3)
% invhess   ��Hessenberg�s��̋t�s��
% invol     Involutory�s��
% ipjfact   ���q�v�f������Hankel�s��(�o�͈�����2)
% jordbloc  Jordan�u���b�N�s��
% kahan     Kahan�s��    - ���`�s��
% kms       Kac-Murdock  - Szego Toeplitz�s��
% krylov    Krylov�s��
% lauchli   Lauchli�s��  - �����`�s��
% lehmer    Lehmer�s��   - �Ώ̐���s��
% leslie    Leslie �s��
% lesp      �����̕q���ȌŗL�l�����O�d�Ίp�s��
% lotkin    Lotkin�s��
% minij     �Ώ̐���s��MIN(i,j).
% moler     Moler�s��    - �Ώ̐���s��
% neumann   ���UNeumann���̓��ٍs��(�X�p�[�X)
% orthog    �����s��A�܂��́A�قڒ����s��
% parter    Parter�s��   - PI�ɋ߂����ْl������Toeplitz�s��
% pei       Pei�s��
% poisson   Poisson�������̃u���b�N�O�d�Ίp�s��(�X�p�[�X)
% prolate   Prolate�s��  - �Ώ̂ŏ�����������Toeplitz�s��
% randcolu  ���K��������Ɛݒ肵�����ْl���������_���s��
% randcorr  �ݒ肵���ŗL�l���������_���ȑ��֍s��
% randhess  �����_���Ȓ�����Hessenberg�s��
% randjorth �����_����J-�����s��
% rando     �v�f��-1�A0�A1�̃����_���s��
% randsvd   ���炩���ߊ��蓖�Ă�ꂽ���ْl�Ǝw�肳�ꂽ�o���h��������
%           �����_���s��
% redheff   Redheffer��0��1����Ȃ�s��
% riemann   Riemann�����Ɋ֘A����s��
% ris       Ris�s��      - �Ώ�Hankel�s��	
% smoke     Smoke�s��    - "smoke ring"�^���X�y�N�g���������f�s��
% toeppd    �Ώ̐���Toeplitz�s��
% toeppen   �܏d�ΊpToeplitz�s��(�X�p�[�X)
% tridiag   �O�d�Ίp�s��(�X�p�[�X)
% triw      Wilkinson��ɂ��c�_���ꂽ��O�p�s��
% wathen    Wathen�s��   - �L���v�f�s��(�X�p�[�X�A�����_���v�f)
% wilk      Wilkinson�ɂ���X�̍s��(�o�͈�����2)
%
% GALLERY(3)�́A�������̈���3�s3��s��ł��B
% GALLERY(5)�́A�����[���ŗL�l���ł��B�ŗL�l�ƌŗL�x�N�g�������߂�
% �݂Ă��������B
% 
% �Q�l�FMAGIC, HILB, INVHILB, HADAMARD, PASCAL, WILKINSON, ROSSER, 
%       VANDER.

%   References:
%   [1] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Second edition, Society for Industrial and Applied Mathematics,
%       Philadelphia, 2002; Chapter 28.
%   [2] J. R. Westlake, A Handbook of Numerical Matrix Inversion and
%       Solution of Linear Equations, John Wiley, New York, 1968.
%   [3] J. H. Wilkinson, The Algebraic Eigenvalue Problem,
%       Oxford University Press, 1965.
%
%   Nicholas J. Higham
%   Copyright 1984-2002 The MathWorks, Inc.
