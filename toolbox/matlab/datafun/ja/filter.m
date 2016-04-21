% FILTER   1�����f�B�W�^���t�B���^
%
% Y = FILTER(B,A,X) �́A�x�N�g��A��B�ŕ\�킳���t�B���^���g���āA
% �x�N�g��X���̃f�[�^���t�B���^�����O���A�t�B���^�o��Y�𐶐����܂��B
% �t�B���^�́A�W���̍�����������"Direct Form II Transposed"�\���Ƃ���
% ��������܂��B
%
%   a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
%                         - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
%
% a(1) ��1�łȂ���΁AFILTER ��a(1) ���g���ăt�B���^�W���𐳋K�����܂��B
%
% FILTER �́A�ŏ���0�łȂ������ɓK�p����܂��B����������΁A����1��
% ��x�N�g���ƈӖ��̂���s��ɑΉ����A����2�͍s�x�N�g���ɑΉ����܂��B
%
% [Y,Zf] = FILTER(B,A,X,Zi) �́AZi�Ńt�B���^�x���̏����������w�肵�āA
% �x��Zf���o�͂��܂��BZi �́AMAX(LENGTH(A),LENGTH(B))-1 �̒�����
% �x�N�g���A�܂��́A�s�̒����� MAX(LENGTH(A),LENGTH(B))-1  �̎����ŁA
% �c��̎����� X �ƈ�v����z��ł��B
%
% FILTER(B,A,X,[],DIM) �܂��� FILTER(B,A,X,Zi,DIM) �́A���� DIM ��
% �΂��ċ@�\���܂��B
%
%   �Q�l �F FILTER2 , FILTFILT(Signal Processing Toolbox)

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:45 $

%   Built-in function.
