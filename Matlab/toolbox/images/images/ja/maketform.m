% MAKETFORM �́A�􉽊w�ϊ��\���̂��쐬���܂��BT = MAKETFORM(TRANSFORM-
% TYPE,...) �́ATFORMFWD, TFORMINV, FLIPTFORM, IMTRANSFORM, TFORMARRAY 
% �Ƌ��Ɏg���������􉽊w�I�ϊ��\����('TFORM struct') ���o�͂��܂��B
% TRANSFORMTYPE �́A'affine', 'projective', 'custom', 'box', 'composi-
% te'�̂����ꂩ���w�肵�܂��B.
%
% T = MAKETFORM('affine',A) �́AN-�����̃A�t�B���ϊ��ɑ΂��� TFORM �\��
% �̂��쐬���܂��BA �́A�����Ȏ��� (N+1) �s (N+1) ��A�܂��́A(N+1) �s N 
% ��̍s��ł��BA ���A(N+1) �s (N+1) ��̏ꍇ�AA �̍Ō�̗�́A[zeros(N,
% 1); 1]�Ƃ��܂��B���̑��̏ꍇ�AA �́A���̍Ō�̗񂪁A[zeros(N,1); 1] ��
% �Ȃ�悤�ɁA�����I�Ɋg�傳��܂��BA �́ATFORMFWD(U,T) �̂悤�ȃt�H���[
% �h�ϊ����`���AU �́A1 �s N ��̃x�N�g���ŁAX = U * A(1:N,1:N) + A(N+1,
% 1:N) �ƂȂ�1 �s N ��̃x�N�g�� X ���o�͂��܂��BT �́A�t�H���[�h�ϊ��Ƌt
% �ϊ��𗼕������Ă��܂��B
%
% T = MAKETFORM('projective',A) �́AN-�����̎ˉe�ϊ��ɑ΂��� TFORM ���쐬
% ���܂��BA �́A�����Ȏ��� (N+1) �s (N+1) ��̍s��ł��BA(N+1,N+1) �Ƀ[��
% ��ݒ肷�邱�Ƃ͂ł��܂���BA �́ATFORMFWD(U,T) �̂悤�ȃt�H���[�h�ϊ�
% ���`�ł��܂��B�����ŁAU �́A1 �s N ��̃x�N�g���ŁAX = W(1:N)/W(N+1) 
% �ƂȂ�1 �s N ��̃x�N�g�� X ���o�͂��܂��B�����ŁAW = [U 1] * A �ł��B
% T �́A�t�H���[�h�ϊ��Ƌt�ϊ��𗼕������Ă��܂��B
%   
% T = MAKETFORM('affine',U,X) �́AU �̊e�s�� X �̑Ή�����s�Ƀ}�b�s���O��
% ��2�����̃A�t�B���ϊ��ɑ΂��� TFORM �\���̂��쐬���܂��BU �� X �́A����
% ���� 3 �s 2 ��ŁA���͂Əo�͂̎O�p�`�̒��_��ݒ肵�܂��B���_�́A������
% �ɑ��݂��邱�Ƃ͂ł��܂���B
%
% T = MAKETFORM('projective',U,X) �́AU �̊e�s�� X �̑Ή�����s�Ƀ}�b�s��
% �O����2�����ˉe�ϊ��ɑ΂��� TFORM �\���̂��쐬���܂��BU �� X �́A���ꂼ
% �� 4 �s 2 ��ŁA���͂Əo�͂̎l�ӌ`�̒��_��ݒ肵�܂��B���_�́A�������
% ���݂��邱�Ƃ͂ł��܂���B
%
% T = MAKETFORM('custom',NDIMS_IN,NDIMS_OUT,FORWARD_FCN,INVERSE_FCN,....
% TDATA) �́A���[�U���ݒ肵���֐��n���h���ƃp�����[�^���x�[�X�ɃJ�X�^��
% �� TFORM �\���̂��쐬���܂��BNDIMS_IN �� NDIMS_OUT �́A���͂Əo�͂̎�
% �����ł��BFORWARD_FCN �� INVERSE_FCN �́A�t�H���[�h�֐��Ƌt�֐��ւ̊�
% ���n���h���ł��B�����̊֐��́A�V���^�b�N�X X = FORWARD_FCN(U,T) �� 
% U = INVERSE_FCN(X,T) ���T�|�[�g���Ă��܂��B�����ŁAU �́AP �s NDIMS_IN 
% ��̍s��ŁA���̍s�́A�ϊ��̓��͋�Ԃ̒��̓_�ŁAX �́AP �s NDIMS_OUT 
% ��̍s��ŁA���̍s�́A�ϊ��̏o�͋�Ԃ̒��̓_�ł��BTDATA �́A�C�ӂ� MAT-
% LAB �z��ŁA�J�X�^���ϊ��̃p�����[�^��ۑ����邽�߂ɁA��ʂɂ́A�g���
% �܂��BT �� "tdata"�t�B�[���h��ʂ��āAFORWARD_FCN �� INVERSE_FNC �ɃA�N
% �Z�X���邱�Ƃ��ł��܂��BFORWARD_FCN�A�܂��́AINVERSE_FCN �̂ǂ��炩���A
% ��̏ꍇ�A���Ȃ��Ƃ� INVERSE_FCN �́ATFORMARRAY�A�܂��́AIMTRANSFORM 
% �̂ǂ��炩�Ƌ��ɁAT ���g���Ē�`����K�v������܂��B
%
% T = MAKETFORM('composite',T1,T2,...,TL)�A�܂��́AT = MAKETFORM('compo-
% site', [T1 T2 ... TL]) �́AT1, T2, ..., TL �̃t�H���[�h�֐���t�֐��̊�
% ���I�ȑg�ݍ��킹�ɂȂ�t�H���[�h�֐��Ƌt�֐��� TFORM ���쐬���܂��B����
% ���΁AL = 3 �̏ꍇ�ATFORMFWD(U,T) �́ATFORMFWD(TFORMFWD(TFORMFWD(U,T3),
% T2),T1) �Ɠ����ɂȂ�܂��BT1 ���� TL �܂ł̗v�f�́A���͎����Əo�͎�����
% ���Ɋւ��Đ�������ۂ��Ă���K�v������܂��BT �́A�v�f�ϊ��̂��ׂĂ��A
% �t�H���[�h�ϊ��֐����`���Ă���ꍇ�̂݁A��`���ꂽ�t�H���[�h�ϊ��֐�
% �������Ă��܂��BT �́A�v�f�ϊ��̂��ׂĂ��A�t�ϊ��֐����`���Ă���ꍇ
% �̂݁A��`���ꂽ�t�ϊ��֐��������Ă��܂��B
%
% T = MAKETFORM('box',TSIZE,LOW,HIGH)�A�܂��́AT = MAKETFORM('box',INBOU-
% NDS, OUTBOUNDS) �́AN-�����̃A�t�B�� TFORM �\���� T ���쐬���܂��BTSIZE
% �́A���̐����� N �v�f�x�N�g���ŁALOW �� HIGH ���AN �v�f�����x�N�g����
% ���B�ϊ��́A�O���̒��_ ONES(1,N) �� TSIZE�A�܂��́A �ʂ̒��_ INBOUNDS
% (1,:) �� INBOUND(2,:) �̂����ꂩ�Őݒ肳������"�{�b�N�X"���A�΂����
% �̂̒��_ LOW �� HIGH�A�܂��́AOUTBOUNDS(1,:) �� OUTBOUNDS(2,:) �̂�����
% ���Œ�`���ꂽ�o�̓{�b�N�X�Ƀ}�b�s���O���܂��B
%
% LOW(K) �� HIGH(K) �́ATSIZE(K) ��1�łȂ�����A���݂��ɈقȂ�܂��B1�̏�
% ���AK-�Ԗڂ̎����Ɋւ���A�t�B���X�P�[���t�@�N�^�́A1.0 �Ɖ��肵�Ă���
% ���B���l�ɁAINBOUNDS(1,K) �� INBOUNDS(2,K) �́AOUTBOUNDS(1,K) �� OUTBO-
% UNDS(1,K) �������łȂ�����A�قȂ�܂��B�܂��A���̋t�̊֌W�����藧����
% ���B'box' TFORM �́A�C���[�W�A�܂��́A�z��̍s�Ɨ�̃T�u�X�N���v�g����
% ��"world"���W�n�ɔz�u����Ƃ��ɁA�ʏ�A�g���܂��B
%
% ���
% -------
% �A�t�B���ϊ����쐬���A�K�p���܂��B
%
%       T = maketform('affine',[.5 0 0; .5 2 0; 0 0 1]);
%       tformfwd([10 20],T)
%       I = imread('cameraman.tif');
%       I2 = imtransform(I,T);
%       imshow(I2)
%
% �Q�l�F FLIPTFORM, IMTRANSFORM, TFORMARRAY, TFORMFWD, TFORMINV.



%   Copyright 1993-2002 The MathWorks, Inc.
