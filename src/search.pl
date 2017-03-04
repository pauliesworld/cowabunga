#!/usr/local/bin/perl

# COWAbunga -
# File: search.pl
# Conference on World Affairs Scheduler
#   This file contains the search abilites to access all
#   tables in the database.
#   Status: STABLE

sub searchPage()
{
    # Greps through the primary tables in the database for a given $search 
    # keyword.  Sends back formatted results based on findings.  Since this
    # isn't a major requirement, it most likely will not be a sophisticated 
    # algorithm any greater than basic grep.  But it's still useful for a 
    # system of this size.  We examine on an object by object basis which is
    # means that panels get searched first, then participants, etc.  Most of the
    # time this won't be a problem as the only thing worth searching are panels
    # and their participants, but it speeds things up a bit.

    ($sid,$search,$year) = @_;

    print(STDOUT <<HTML);
<div id="content">
<h2>$yearname Search</h2>
<hr size="1" noshade>
<center><table cellpadding=0 cellspacing=0 border=0 class=bettyTable width=450>
<th><b>You searched for $search</b></th>

</div>

HTML

    $i=0;
    $j=0;
    $k=0;
    $l=0;
    $m=0;

    $search =~ s/\*/\\*/g;
    $search =~ s/\+/\\+/g;
    $search =~ s/\./\\./g;
    $search =~ s/\?/\\?/g;
    $search =~ s/\[/\\[/g;
    $search =~ s/\]/\\]/g;
    $search =~ s/\^/\\^/g;
    $search =~ s/\|/\\|/g;
    $search =~ s/\ /|/g;

    @paneltable = grep { /$search/i } @paneltable;
    @partitable = grep { /$search/i } @partitable;
    @produtable = grep { /$search/i } @produtable;
    @modertable = grep { /$search/i } @modertable;
    @venuetable = grep { /$search/i } @venuetable;

    foreach $entry (@paneltable)
    {
        $entry =~ s/\n//;
        $name=$panid=$day=$entry;
        $name =~ s/"PANEL//;
        $name =~ s/LENAP".*//;
        $name = addRegExp($name);
        $panid =~ s/.*,"PANID//;
        $panid =~ s/DINAP",.*//;
	$day =~ s/.*,"DAY//;
	$day =~ s/YAD",.*//;

        print "<tr><td><a href=\"cwasys.pl?sid=$sid&pid=schedule&y=$year&
	day=$day\">$name</td></tr>";
        $k++;
    }

    foreach $entry (@partitable)
    {
	$entry =~ s/\n//;
	$partid=$lname=$fname=$entry;
	$lname =~ s/"LNAME//;
	$lname =~ s/EMANL".*//;
	$fname =~ s/"LNAME${lname}EMANL","FNAME//;
	$fname =~ s/EMANF".*//;
	$lname = addRegExp($lname);
	$fname = addRegExp($fname);
	$partid =~ s/.*,"PARTID//;
	$partid =~ s/DITRAP",.*//;
        
        print "<tr><td><a href=\"cwasys.pl?sid=$sid&pid=readonly&
	object=participant&partid=$partid&y=$year\">$fname $lname</td></tr>";
        $j++;
    }

    foreach $entry (@produtable)
    {
        $entry =~ s/\n//;
        $prodid=$lname=$fname=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
        $lname = addRegExp($lname);
        $fname = addRegExp($fname);
        $prodid =~ s/.*,"PRODID//;
        $prodid =~ s/DIDORP",.*//;

        print "<tr><td><a href=\"cwasys.pl?sid=$sid&pid=readonly&
	object=producer&prodid=$prodid&y=$year\">$fname $lname</td></tr>";
        $j++;
    }

    foreach $entry (@modertable)
    {
        $entry =~ s/\n//;
        $modid=$lname=$fname=$entry;
        $lname =~ s/"LNAME//;
        $lname =~ s/EMANL".*//;
        $fname =~ s/"LNAME${lname}EMANL","FNAME//;
        $fname =~ s/EMANF".*//;
        $lname = addRegExp($lname);
        $fname = addRegExp($fname);
        $modid =~ s/.*,"MODID//;
        $modid =~ s/DIDOM",.*//;

        print "<tr><td><a href=\"cwasys.pl?sid=$sid&pid=readonly&
	object=moderator&modid=$modid&y=$year\">$fname $lname</td></tr>";
        $j++;
    }

    foreach $entry (@venuetable)
    {
        $entry =~ s/\n//;
        $name=$venid=$entry;
        $name =~ s/"VENLOC//;
        $name =~ s/COLNEV".*//;
	$venid =~ s/.*,"VENID//;
	$venid =~ s/DINEV",.*//;
	$name = addRegExp($name);

  	print "<tr><td><a href=\"cwasys.pl?sid=$sid&pid=readonly&
	object=venue&venid=$venid&y=$year\">$name</td></tr>";
        $k++;
    }

    if($i==0 && $j==0 && $k==0 && $l==0 && $m==0)
    {
        print "<tr><td>Sorry, no results found</td></tr>";
    }
    
    print(STDOUT <<HTML);
</div>
</div>
</table>
</div>
HTML
}

1;
