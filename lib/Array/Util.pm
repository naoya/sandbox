package Array::Util;
use strict;
use warnings;
use Exporter::Lite;

our @EXPORT = qw/delete_at index_of/;
our @EXPORT_OK = @EXPORT;

## 一応 splice() の方が速いが、splice は closer end に対して O(n)
sub delete_at (\@$) {
    my ($array, $i) = @_;
    if ($i > @$array - 1) {
        return;
    }

    my @end = splice @$array, $i;
    my $value = shift @end;
    push @$array, @end;

    return $value;
}

## ベンチ用
sub old_delete_at (\@$) {
    my ($array, $i) = @_;
    if ($i > @$array - 1) {
        return;
    }

    ## ひとつずつずらすナイーブな実装
    my $value = $array->[$i];

    my $len = @$array;
    for (my $j = $i; $j < $len; $j++) {
       $array->[$j] = $array->[$j + 1];
    }
    $#{@$array}--;

    return $value;
}

sub index_of (\@$) {
    my ($array, $c) = @_;
    for (my $i = 0; $i < @$array; $i++) {
        if ($array->[$i] == $c) {
            return $i;
        }
    }
}

1;
