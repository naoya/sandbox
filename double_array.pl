#!/usr/local/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Perl6::Say;

my @BASE = (undef, 1);
my @CHECK;
my $TAIL;
my $POS = 1;
my %code = (
    '#' => 1,
    a   => 2,
    b   => 3,
    c   => 4,
    d   => 5,
    e   => 6,
    f   => 7,
    g   => 8,
    h   => 9,
    i   => 10,
    j   => 11,
    k   => 12,
    l   => 13,
    m   => 14,
    n   => 15,
    o   => 16,
    p   => 17,
    q   => 18,
    r   => 19,
    s   => 20,
    t   => 21,
    u   => 22,
    v   => 23,
    w   => 24,
    x   => 25,
    y   => 26,
    z   => 27,
);

sub insert {
    my $str = shift;
    $str .= '#';

    my $i = 1; # いま何文字目か
    my $n = 1; # BASE の索引
    for my $c (map { $code{$_} } split //, $str) {
        my $next = $BASE[$n] + $c;
        if (not defined $CHECK[$next]) {
            $BASE[$next]  = -$POS;
            $CHECK[$next] = $n;
            $TAIL .= substr($str, $i);
            $POS = length($TAIL) + 1;
            show($str);
            last;
        } elsif ($CHECK[$next] == $n) {
            ## Case.3
            if ($BASE[$next] < 0) {
                ## This negative value indicates that searching has
                ## finished and string comparison is to be performed

                my $tmp = -$BASE[$next];
                my $off = -$BASE[$next] - 1;

                my $len = index($TAIL, '#', $off) + 1 - $off;
                my $s1 = substr($TAIL, $off, $len);
                my $s2 = substr($str, $i); # FIXME

                ## 新たに分岐する軸の番号を決める
                my $new_check = $next;
                my @common = common_prefix($s1, $s2);
                for (@common) {
                    my $q = X_CHECK($_);
                    $BASE[$next] = $q;
                    ## 次は TAIL じゃなく new_check になる
                    $new_check = $BASE[$next] + $code{$_};
                    $CHECK[$new_check] = $next;
                    $next = $new_check;
                }
                if (not defined $new_check) {
                    die 'assert ($new_check undefined)';
                }

                ## To store the remaining strings : new_check の次の文字
                my $ss1 = substr($s1, scalar @common);
                my $ss2 = substr($s2, scalar @common);

                $BASE[$new_check] = X_CHECK(substr($ss1, 0, 1), substr($ss2, 0, 1));

                ## chelor
                my $n_s1 = $BASE[$new_check] + $code{substr($ss1, 0, 1)};
                $BASE[$n_s1] = - $tmp;
                $CHECK[$n_s1] = $new_check;
                $off = -$BASE[$n_s1] - 1;
                substr($TAIL, $off, length($ss1) - 1) = substr($ss1, 1);

                ## dge
                my $n_s2 = $BASE[$new_check] + $code{substr($ss2, 0, 1)};
                $BASE[$n_s2]  = - $POS;
                $CHECK[$n_s2] = $new_check;
                $TAIL .= substr($ss2, 1);
                $POS = length($TAIL) + 1;

                show($str);
                last;
            } else {
                $n = $next;
                $i++;
            }
        } else {
            ## Case 4
            my $n1 = $CHECK[$next];
            my @e1 = get_edges($n1); # LIST[1]
            my @e2 = get_edges($n);  # LIST[3]

            my $un; # update node num
            my $ue; # update edges
            if (@e2 + 1 < @e1) {
                ## FIXME: こっちにするとバグるなあ・・・なぜだ
                # $un = $n;
                # $ue = \@e2;

                ## とりあえず
                $un = $n1;
                $ue = \@e1;
            } else {
                $un = $n1;
                $ue = \@e1;
            }

            my $tmp_base = $BASE[$un];
            $BASE[$un] = X_CHECK(@$ue);

            for (@$ue) {
                my $tmp_node1 = $tmp_base  + $code{$_};
                my $tmp_node2 = $BASE[$un] + $code{$_};
                $BASE[$tmp_node2]  = $BASE[$tmp_node1];
                $CHECK[$tmp_node2] = $CHECK[$tmp_node1];

                if ($BASE[$tmp_node1] > 0) {
                    for (get_edges($tmp_node1)) {
                        $CHECK[ $BASE[$tmp_node1] + $code{$_} ] = $tmp_node2;
                    }
                }

                $BASE[$tmp_node1]  = undef;
                $CHECK[$tmp_node1] = undef;
            }
            show($str);
            ## Now the conflict generated by the collision of 'b' from ba'b'y has been solved.
            ## Finally, insert the remaining part of the new string 'by#' into TAIL.
            my $next = $BASE[$n] + $c;
            $BASE[$next]  = -$POS;
            $CHECK[$next] = $n;
            $TAIL .= substr($str, $i);
            $POS  = length($TAIL) + 1;
            show($str);
            last;
        }
    }
}

sub get_edges {
    my $s = shift;
    my @edges;
    for my $ch (keys %code) {
        my $next = $BASE[$s] + $code{$ch};
        if (not defined $next) {
            next;
        }

        if (not defined $CHECK[$next]) {
            next;
        }

        if ($CHECK[$next] == $s) {
            push @edges, $ch;
        }
    }
    return @edges;
}

sub X_CHECK {
    my $q = 1;
    for my $c (map { $code{$_} } @_) {
        while (1) {
            if (not defined $CHECK[$q + $c]) {
                last;
            } else {
                $q++;
            }
        }
    }
    return $q;
}

sub common_prefix {
    my ($s1, $s2) = @_;
    my @ret;
    my $i = 0;
    my $l = length $s1 < length $s2 ? length $s1 : length $s2;
    for (; $i < $l; $i++) {
        if (substr($s1, $i, 1) ne substr($s2, $i, 1)) {
            last;
        }
    }
    return split //, substr($s1, 0, $i);
}

sub show {
    my $str = shift;
    say $str;
    say sprintf 'BASE:  [%s]', join(', ', map { defined $_ ? $_ : '-' } @BASE );
    say sprintf 'CHECK: [%s]', join(', ', map { defined $_ ? $_ : '-' } @CHECK);
    say 'TAIL: ', $TAIL;
    say 'POS: ', $POS;
    say
}

sub retrieve {
    my $q = shift;
    $q .= '#';

    my $n = 1;
    my $prefix;
    for (split //, $q) {
        my $c    = $code{$_};
        my $next = $BASE[$n] + $c;
        if (defined $CHECK[$next] and $CHECK[$next] == $n) {
            $n = $next;
            $prefix .= $_;
            next;
        } else {
            if ($BASE[$n] < 0) {
                my $offset = -$BASE[$n] - 1;
                my $len = index($TAIL, '#', $offset) + 1 - $offset;
                my $suffix = substr($TAIL, $offset, $len);
                if ($q eq $prefix . $suffix) {
                    return 1;
                }
            }
            return;
        }
    }
    return;
}

insert('bachelor');
insert('jar');
insert('badge');
insert('bem');
insert('bom');
insert('foo');
insert('backup');
insert('naoya');
insert('yuna');
insert('naoko');
insert('baby');
insert('bab'); # 登録できてないし!

use Test::More qw/no_plan/;

ok retrieve('bachelor');
ok retrieve('jar');
ok retrieve('badge');
ok retrieve('bem');
ok retrieve('bom');
ok retrieve('foo');
ok retrieve('backup');
ok retrieve('naoya');
ok retrieve('yuna');
ok retrieve('naoko');
ok retrieve('baby');
ok retrieve('bab');
