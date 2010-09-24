#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

use Perl6::Say;

## say �ιԤ����פ��ư�������Ȥˤʤ�
sub hanoi {
    my ($n, $t1, $t2, $t3) = @_;

    if ($n == 1) {
        say sprintf "move D1 from %s to %s", $t1, $t2;
    } else {
        ## �ޤ� n - 1 �Ĥ��٤Ƥ��ˡŪ�� t3 (��)�˰�ư
        hanoi($n - 1, $t1, $t3, $t2);

        ## t1 (��)�ˤϱ���n �������Ĥä��Τǡ�����n �� t2 �˰�ư�Ǥ��롣�椨�˰�ư
        say sprintf "move D%d from %s to %s", $n, $t1, $t2;

        ## ��ˡŪ�� n - 1 �Ĥ� t2 �˰�ư
        hanoi($n - 1, $t3, $t2, $t1);
    }
}

hanoi 3, 'A', 'B', 'C';
