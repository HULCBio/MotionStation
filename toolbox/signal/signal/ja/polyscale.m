% POLYSCALE �������̍��̃X�P�[�����O
% POLYSCALE(A,ALPHA) �́AZ���ʓ��ŁAALPHA�ɂ���āA������A�̍����X�P�[��
% ���O���܂��B�����ŁAA�́A�������W���̃x�N�g���ł��BALPHA�������ŁA0 <=
% ALPHA <= 1�̏ꍇ�AA�̍��́AZ���ʂ̒��Ō��_�����ɕ��ˏ�ɃX�P�[�����O��
% ��܂��B���fALPHA�́A�C�ӂ̕ύX�����̈ʒu�ɗ^���܂��B
%
% ���ȉ�A�������̒��ō��̔��a��Z�����邱�Ƃɂ��A���g�������̒��̃X�y
% �N�g���s�[�N�̃o���h���́A(���R��)�L����܂��B���̉��Z�́A���΂��΁A
% "�o���h���g��"�Ɖ]���܂��B
%
% ���FLPC�����X�y�N�g���̃o���h���g��
%      load mtlb;                    % �����M��
%      Ao = lpc(mtlb(1000:1100),12); % 12���� AR ������
%      Ax = polyscale(Ao,.85);       % �o���h���g��
%      subplot(2,2,1); zplane(1,Ao); title('Original');
%      subplot(2,2,3); zplane(1,Ax); title('Flattened');
%      [ho,w]=freqz(1,Ao);  [hx,w]=freqz(1,Ax);
%      subplot(1,2,2); plot(w,abs(ho), w,abs(hx));
%      legend('Original','Flattened');
%
% �Q�l�F POLYSTAB.



% Copyright 1988-2002 The MathWorks, Inc.
