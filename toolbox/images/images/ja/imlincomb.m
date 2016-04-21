% IMLINCOMB �C���[�W�̐��`�������v�Z���܂��B
% Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An) �́AK1*A1 + K2*A2 + ... +Kn*An
% ���v�Z���܂��BA1, A2, ..., An�́A�����N���X�A�T�C�Y���������A��X�p�[�X�A
% ���l�z��ł��BK1, K2, ..., Kn�́A�X�J���ŁA�{���x�̎����ł��B
% Z �́AA1�Ɠ����N���X�A�T�C�Y�������܂��B
%
% Z = IMLINCOMB(K1,A1,K2,A2, ..., Kn,An,K) �́AK1*A1 + K2*A2 +
% ... + Kn*An + K���v�Z���܂��B
%
% Z = IMLINCOMB(..., OUTPUT_CLASS) �́AZ �̃N���X���w�肵�܂��B
% OUTPUT_CLASS�́A���l�̃N���X�����܂ޕ�����ł��B
%
% IMADD �� IMMULTIPLY �̂悤�ȌX�̑㐔�֐������q��ԂŃR�[��������
% ���A��g�̃C���[�W�ɁAIMLINCOMB ���g���āA��A�̑㐔������K�p���邱��
% ���ł��܂��B�㐔�֐��̃R�[�������q�ɂ��A���͔z�񂪐����N���X�̏ꍇ�A
% �X�̊֐��́A���̊֐��Ɍ��ʂ�n���O�ɁA���ʂɑł��؂��ۂ߂�K�p��
% �܂��B���̂��߁A�ŏI�I�Ȍ��ʂ́A���x�������܂��B�������AIMLINCOMB �́A
% �ŏI�I�Ȍ��ʂɑł��؂��ۂ߂��s���O�ɁA���ׂĂ̑㐔���Z����x�ɍs���܂��B
%
% �o�� Z �̌X�̗v�f�́A�{���x�̕��������_�ŁA�X�Ɍv�Z����܂��BZ ��
% �����z��̏ꍇ�A�����^�C�v�͈̔͂𒴂���Z�̏o�͗v�f�́A�ł��؂��A�����_
% �ȉ��͊ۂ߂��܂��B
%
% ���1
% ---------
% 2�̃t�@�N�^���g���āA�C���[�W���X�P�[�����܂��B
%
%       I = imread('cameraman.tif');
%       J = imlincomb(2,I);
%       imshow(J)
%
% ���2
% ---------
% 2�̃C���[�W�̍��ɁA0��128�ɃV�t�g���鑀���t��
%
%       I = imread('cameraman.tif');
%       J = uint8(filter2(fspecial('gaussian'), I));
%       K = imlincomb(1,I,-1,J,128); % K(r,c) = I(r,c) - J(r,c) + 128
%       imshow(K)
%
% ���3
% ---------
% �w�肵���o�̓N���X���g�p����2�̃C���[�W��t��
%
%       I = imread('rice.tif');
%       J = imread('cameraman.tif');
%       K = imlincomb(1,I,1,J,'uint16');
%       imshow(K,[])
%
% �Q�l IMADD, IMCOMPLEMENT, IMDIVIDE, IMMULTIPLY, IMSUBTRACT.



%   Copyright 1993-2002 The MathWorks, Inc.
