% FILTER2  2�����f�B�W�^���t�B���^
%
% Y = FILTER2(B,X) �́A2����FIR�t�B���^�s��B���g���āAX���̃f�[�^��
% �t�B���^�����O���܂��B���ʂ�Y�́A2�����R���{�����[�V�������g���Čv�Z
% ����AX�Ɠ����T�C�Y�ɂȂ�܂��B 
%
% Y = FILTER2(B,X,'shape') �́A'shape'�Ŏw�肳���T�C�Y�ŁA2�����R���{
% �����[�V�����ɂ���Čv�Z�����Y���o�͂��܂��B
%     'same'  - X�Ɠ����T�C�Y�ɂȂ�悤�ɁA�R���{�����[�V�����̌��ʂ̒��S��
%            	�����o�͂��܂�(�f�t�H���g)�B
%     'valid' - �[�����������Ɍv�Z���ꂽ�R���{�����[�V�����̌��ʂ݂̂��o��
%               ���܂��Bsize(Y) < size(X)�ƂȂ�܂��B
%     'full'  - ���S��2�����R���{�����[�V�����̌��ʂ��o�͂��܂��B
%               size(Y) > size(X) �ƂȂ�܂��B
%
% FILTER2�́ACONV2���g���āA�قƂ�ǂ̉��Z���s���܂��B2�����R���{
% �����[�V�����́A�t�B���^�s���180�x��]�ɂ��CONV2�ł��B
%
%   �Q�l �F FILTER, CONV2.


%   Clay M. Thompson 9-17-91
%   L. Shure 10-21-91, modified to use conv2 mex-file
%   S. Eddins 12-6-94, modified to check for separability
%   Copyright 1984-2003 The MathWorks, Inc. 
