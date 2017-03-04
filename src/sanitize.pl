#!/usr/local/bin/perl

# COWAbunga -
# File: sanitize.pl
# Conference on World Affairs Scheduler
#   Removes regular expression operators from db tables
#   so that things don't get screwy on committments
#   Status: STABLE

sub removeRegExp()
{
    ($s)=@_;

    # convert ascii to octal
    $s =~ s/\044/O044O/g;	# $
    $s =~ s/\050/O050O/g;       # (
    $s =~ s/\051/O051O/g;       # )
    $s =~ s/\052/O052O/g;       # *
    $s =~ s/\053/O053O/g;       # +
    $s =~ s/\056/O056O/g;	# .
    $s =~ s/\077/O077O/g;       # ?
    $s =~ s/\133/O133O/g;       # [
    $s =~ s/\134/O134O/g;	# \
    $s =~ s/\135/O135O/g;       # ]
    $s =~ s/\136/O136O/g;       # ^
    $s =~ s/\174/O174O/g;	# |
    $s =~ s/\042/O042O/g;	# "

    return($s);
}

sub addRegExp()
{
    ($s)=@_;

    # convert octal to ascii
    $s =~ s/O044O/\044/g;       # $
    $s =~ s/O050O/\050/g;       # (
    $s =~ s/O051O/\051/g;       # )
    $s =~ s/O052O/\052/g;       # *
    $s =~ s/O053O/\053/g;       # +
    $s =~ s/O056O/\056/g;       # .
    $s =~ s/O077O/\077/g;       # ?
    $s =~ s/O133O/\133/g;       # [
    $s =~ s/O134O/\134/g;	# \
    $s =~ s/O135O/\135/g;       # ]
    $s =~ s/O136O/\136/g;       # ^
    $s =~ s/O174O/\174/g;       # |
    $s =~ s/O042O/\042/g;	# "
    $s =~ s/"/&quot;/g;		# prevents HTML from misreading quotes

    return($s);
}

1;
