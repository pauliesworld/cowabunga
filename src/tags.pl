#!/usr/local/bin/perl

# COWAbunga -
# File: tags.pl
# Conference on World Affairs Scheduler
#   Attaches and detaches tags to participants, venues
#    moderators, and producers
#   Status: STABLE

sub addelTagToTableObject()
{
    # Tags can be added and deleted from participants, venues,
    # moderators, and producers.  These are all attached to the
    # end of those tables in the format TAGID DIGAT...
    # Because we can have more than one tag, it MUST be thrown
    # onto the end.

    ($addtag,$deltag,$tagbox,$id,$year,$userfile,$sessifile,$confile,$condisfile)=@_;

    if ($addtag)
    {
	$this = $addtag;
    }

    else
    {
        $this = $deltag;
    }

    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
    {
        print "<meta http-equiv=\"refresh\" content=\"0; url=login.pl??msg=2&
	sid=$sid\">";
        exit 1;
    }

    if ($this =~ m/participant/)
    {
	if ($tagbox)
	{
            @participant = grep { /,"PARTID${id}DITRAP",/ } @partitable;
            @contents = grep { !/,"PARTID${id}DITRAP",/ } @partitable;
            $entry = join('',@participant);
            chomp($entry);

	    if ($addtag)
	    {
            	$entry .= ",\"TAGID${tagbox}DIGAT\"";
	    }

	    else
	    {
	        $entry =~ s/,"TAGID${tagbox}DIGAT"//;
	    }

            deleteTableObject(\@contents,$partifile);
            addTableObject($entry,$partifile);

            @local_pans = grep { /,"PARTID${id}DITRAP"/ } @paneltable;
    		foreach $pan_entry (@local_pans)
		{
			conflictDetect($confile,$condisfile,$pan_entry);
		}

	}

        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	delete=participant&ppbox=$id&sid=$sid&y=$year&partform=Edit\">";
    }

    if ($this =~ m/producer/)
    {
	if ($tagbox)
	{
            @producer = grep { /,"PRODID${id}DIDORP",/ } @produtable;
            @contents = grep { !/,"PRODID${id}DIDORP",/ } @produtable;
            $entry = join('',@producer);
            chomp($entry);

            if ($addtag)
            {
                $entry .= ",\"TAGID${tagbox}DIGAT\"";
            }

            else
            {
                $entry =~ s/,"TAGID${tagbox}DIGAT"//;
            }

            deleteTableObject(\@contents,$produfile);
            addTableObject($entry,$produfile);

            @local_pans = grep { /,"PRODID${id}DIDORP"/ } @paneltable;
    		foreach $pan_entry (@local_pans)
		{
			conflictDetect($confile,$condisfile,$pan_entry);
		}
	}

        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	delete=producer&pubox=$id&sid=$sid&y=$year&prodform=Edit\">";
    }

    if ($this =~ m/moderator/)
    {
	if ($tagbox)
	{
	    @moderator = grep { /,"MODID${id}DIDOM",/ } @modertable;
	    @contents = grep { !/,"MODID${id}DIDOM",/ } @modertable;
	    $entry = join('',@moderator);
	    chomp($entry);

            if ($addtag)
            {
                $entry .= ",\"TAGID${tagbox}DIGAT\"";
            }

            else
            {
                $entry =~ s/,"TAGID${tagbox}DIGAT"//;
            }

	    deleteTableObject(\@contents,$moderfile);
	    addTableObject($entry,$moderfile);

	        @local_pans = grep { /,"MODID${id}DIDOM"/ } @paneltable;
    		foreach $pan_entry (@local_pans)
		{
			conflictDetect($confile,$condisfile,$pan_entry);
		}
	}

        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	delete=moderator&mpbox=$id&sid=$sid&y=$year&moderform=Edit\">";
    }

    if ($this =~ m/venue/)
    {
	if ($tagbox)
	{
            @venue = grep { /,"VENID${id}DINEV",/ } @venuetable;
            @contents = grep { !/,"VENID${id}DINEV",/ } @venuetable;
            $entry = join('',@venue);
            chomp($entry);

            if ($addtag)
            {
            	$entry .= ",\"TAGID${tagbox}DIGAT\"";
            }

            else
            {
                $entry =~ s/,"TAGID${tagbox}DIGAT"//;
            }

            deleteTableObject(\@contents,$venuefile);
            addTableObject($entry,$venuefile);

            @local_pans = grep { /,"VENID${id}DINEV"/ } @paneltable;
    		foreach $pan_entry (@local_pans)
		{
			conflictDetect($confile,$condisfile,$pan_entry);
		}
	}

        print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?
	delete=venue&vpbox=$id&sid=$sid&y=$year&venform=Edit\">";
    }
}

1;
