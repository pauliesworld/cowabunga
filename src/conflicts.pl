#!/usr/local/bin/perl

# COWAbunga -
# File: conflicts.pl
# Conference on World Affairs Scheduler
#   This file builds the conflict table that gets updated
#   anytime the panel table changes

sub getNumberofConflicts()
{
    # Run wc (word count) on the file, use num of lines -> num of conflicts
    ($file)=@_;
    $ccount = `${WC} < $file`;
    return($ccount);
}

sub conflictDetect()
{
    # System module to check for any conflicts that occur during panel 
    # formation.  First we delete all conflicts matching the corresponding panel
    # then we search for conflicts.  In this way we never discover duplicates 
    # and in a sense, find everything again once we update a panel.  Once all
    # conflicts are found for a given panel, we put them into an array and 
    # append it to the conflicts table.
    #
    # For developing (finding new conflicts)
    #  1. Identify conflict
    #  2. Create a CSV conflict entry in the format
    #		"PANID...DINAP","Message"
    #  3. Push CSV entry into conflicts array
    # Refer to easier conflicts (like panels with no producer/venue etc.)

    ($confile,$condisfile,$pentry)=@_;

    $newconflictsfound=0;
    $panid=$pentry;
    $panid =~ s/.*"PANID//;
    $panid =~ s/DINAP",.*//;

    @lcpaneltable = grep { !/"PANID${panid}DINAP",/ } @paneltable;

    # Begin conflict searching
    
    if($pentry !~ m/PARTID/)
    {
	$newconflictsfound=1;
	$newcon = "\"PANID${panid}DINAP\",\"VITAL\",\"No participants\"\n";
	push(@local_conflicts,$newcon);
    }

    if($pentry =~ m/MODIDDIDOM/)
    {
        #$newconflictsfound=1;
        $newcon = "\"PANID${panid}DINAP\",\"No moderator\"\n";
        #push(@local_conflicts,$newcon);
    }

  # Participant - 1 :: A panelist cannot be assigned to two panels overlapping
  # in time.

    $participants=$venue=$moderator=$producer=$day=$ftime=$stime=$pentry;
    $day =~ s/.*,"DAY//;
    $day =~ s/YAD",.*//;
    $stime =~ s/.*,"STIME//;
    $stime =~ s/EMITS",.*//;
    $ftime =~ s/.*,"FTIME//;
    $ftime =~ s/EMITF",.*//;
    $venue =~ s/.*,"VENID//;
    $venue =~ s/DINEV",.*//;
    $moderator =~ s/.*,"MODID//;
    $moderator =~ s/DIDOM",.*//;
    $producer =~ s/.*,"PRODID//;
    $producer =~ s/DIDORP",.*//;
    $participants =~ s/SETON","/SETON""/;
    $participants =~ s/.*SETON"//;
    $participants =~ s/"PARTID//g;
    $participants =~ s/(DITRAP",)|(DITRAP")/\ /g;
    @ptable = split("\ ",$participants);
    @local_ptable = @ptable;

    # With the time, we can mark off the time range 

    @dbtimetable=("None","0800","0830","0900","0930","1000","1030","1100",
		"1130","1200","1230","1300","1330","1400","1430","1500","1530",
		"1600","1630","1700","1730","1800","1830","1900","1930",
		"2000","2030","2100","2130","2200"
		);

    $ccount = 0;

    # Figure out the start and end time of a panel.

    foreach $time (@dbtimetable)
    {
	if ($time == $stime) 
       	{ 
	    $scount=$ccount; 
	}
	
	if ($time == $ftime) 
	{ 
	    $fcount=$ccount; 
	}

	$ccount++;
    }

    $ccount=0;

    for ($i=$scount; $i<=$fcount; $i++)
    {
	$local_dbtable[$ccount]=$dbtimetable[$i];
	$ccount++;
    }

    if ($venue) 
    { 
	@local_panels_ven = grep { /VENID${venue}DINEV/ } @paneltable; 
    }

    if ($producer) 
    { 
	@local_panels_pro = grep { /PRODID${producer}DIDORP/ } @paneltable; 
    }

    if ($moderator) 
    { 
	@local_panels_mod = grep { /MODID${moderator}DIDOM/ } @paneltable; 
    }

    # @ptable now contains the PIDs of all participants assigned to a panel
    # Lets find conflicts, hooray!

    # Find all panelist/participant scheduling conflicts based on time

    foreach $panelist (@ptable)
    {
	chomp($panelist);
	@local_panels_par = grep { /PARTID${panelist}DITRAP/ } @paneltable;

	foreach $panel (@local_panels_par)
	{
	    chomp($panel);
	    if ($panel =~ m/PANID${panid}DINAP/) { next; }
	    $local_stime=$local_ftime=$local_day=$local_panid=$panel;
            $local_day =~ s/.*,"DAY//;
    	    $local_day =~ s/YAD",.*//;

	    # eliminate 20% of chances by day first
	    if ($panel =~ m/DAY${day}YAD/)
	    {
    	        $local_stime =~ s/.*,"STIME//;
    	    	$local_stime =~ s/EMITS",.*//;
    	    	$local_ftime =~ s/.*,"FTIME//;
    	    	$local_ftime =~ s/EMITF",.*//;
		$local_panid =~ s/.*,"PANID//;
		$local_panid =~ s/DINAP",.*//;

		$ccount=0;
		foreach $time (@dbtimetable)
    		{
        	    if ($time =~ m/$local_stime/) 
		    { 
			$scount=($ccount+1); 
		    } # -1 to get a half hour cushion in front

        	    if ($time =~ m/$local_ftime/) 
		    { 
			$fcount=($ccount-1); 
		    } # +1 to get a half hour cushion behind
        	    $ccount++;
    		}

    		$ccount=0;
		for ($i=$scount; $i<=$fcount; $i++)
    		{ # build each same-day panel time-range
        	    $local_panel_dbtable[$ccount]=$dbtimetable[$i];
        	    $ccount++;
    		}

		# Now we do a comparison to see if any element in 1st panel 
		# array matches anything in others.

		foreach $first (@local_dbtable)
		{
		    foreach $second (@local_panel_dbtable)
		    {
			if ($first =~ m/$second/)
			{
			    $ptimeconflict=1;
			}
		    }
		}

		if ($ptimeconflict)
		{
		    chomp($panelist); chomp($local_panid);
	            $newconflictsfound=1;
                    $newcon = "
			\"PANID${panid}DINAP\",
			\"VITAL\",
			\"PARTID${panelist}DITRAP is already scheduled
			 with CPANID${local_panid}DINAPC during this time.\"
			\n";
		    $newcon =~ s/\t|\n//g;
		    $newcon .= "\n";
                    push(@local_conflicts,$newcon);
		}

		# cleanup this mess
		@local_panel_dbtable=();
		$ptimeconflict=0;
	    }
	}
    }

    # Find venue scheduling conflicts based on time

    foreach $panel (@local_panels_ven)
    {
        chomp($panel);
        if ($panel =~ m/PANID${panid}DINAP/) { next; }
        $local_stime=$local_ftime=$local_day=$local_panid=$panel;
        $local_day =~ s/.*,"DAY//;
        $local_day =~ s/YAD",.*//;

        # Eliminate 20% of chances by day first

        if ($panel =~ m/DAY${day}YAD/)
        {
            $local_stime =~ s/.*,"STIME//;
            $local_stime =~ s/EMITS",.*//;
            $local_ftime =~ s/.*,"FTIME//;
            $local_ftime =~ s/EMITF",.*//;
            $local_panid =~ s/.*,"PANID//;
            $local_panid =~ s/DINAP",.*//;
	    chomp($local_panid);

            $ccount=0;
            foreach $time (@dbtimetable)
            {
                if ($time =~ m/$local_stime/) { $scount=$ccount+1; }
                if ($time =~ m/$local_ftime/) { $fcount=$ccount-1; }
                $ccount++;
            }

            $ccount=0;
            for ($i=$scount; $i<=$fcount; $i++)
            { # build each same-day panel time-range
                $local_panel_dbtable[$ccount]=$dbtimetable[$i];
                $ccount++;
            }

            # Now we do a comparison to see if any element in 1st panel array 
	    # matches anything in others.

            foreach $first (@local_dbtable)
            {
                foreach $second (@local_panel_dbtable)
                {
                    if ($first =~ m/$second/)
                    {
                        $ptimeconflict=1;
                    }
                }
            }

            if ($ptimeconflict)
            {
                chomp($panelist); chomp($local_panid);
                $newconflictsfound=1;
                $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"Venue VENID${venue}DINEV is already scheduled
		 with CPANID${local_panid}DINAPC during this time.\"
		\n";
		$newcon =~ s/\t|\n//g;
                $newcon .= "\n";
                push(@local_conflicts,$newcon);
            }

            # cleanup this mess
            @local_panel_dbtable=();
            $ptimeconflict=0;
        }
    }

    # Find producer scheduling conflicts based on time

    foreach $panel (@local_panels_pro)
    {
        chomp($panel);
        if ($panel =~ m/PANID${panid}DINAP/) { next; }
        $local_stime=$local_ftime=$local_day=$local_panid=$panel;
        $local_day =~ s/.*,"DAY//;
        $local_day =~ s/YAD",.*//;

        # eliminate 20% of chances by day first
        if ($panel =~ m/DAY${day}YAD/)
        {
            $local_stime =~ s/.*,"STIME//;
            $local_stime =~ s/EMITS",.*//;
            $local_ftime =~ s/.*,"FTIME//;
            $local_ftime =~ s/EMITF",.*//;
            $local_panid =~ s/.*,"PANID//;
            $local_panid =~ s/DINAP",.*//;
            chomp($local_panid);

            $ccount=0;

            foreach $time (@dbtimetable)
            {
                if ($time =~ m/$local_stime/) 
		{ 
		    $scount=($ccount-1); 
		} # producers require hour cushion in front (-2)
                
		if ($time =~ m/$local_ftime/) 
		{ 
		    $fcount=($ccount+1); 
		} # producers require hour cushion behind (+2)
	
                $ccount++;
            }

            $ccount=0;
            for ($i=$scount; $i<=$fcount; $i++)
            { # build each same-day panel time-range
                $local_panel_dbtable[$ccount]=$dbtimetable[$i];
                $ccount++;
            }

            # Now we do a comparison to see if any element in 1st panel array 
	    # matches anything in others.

            foreach $first (@local_dbtable)
            {
                foreach $second (@local_panel_dbtable)
                {
                    if ($first =~ m/$second/)
                    {
                        $ptimeconflict=1;
                    }
                }
            }

            if ($ptimeconflict)
            {
                chomp($panelist); chomp($local_panid);
                $newconflictsfound=1;
                $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"Producer PRODID${venue}DIDORP is already scheduled
		 with CPANID${local_panid}DINAPC during this time.\"
		\n";
		$newcon =~ s/\t|\n//g;
                $newcon .= "\n";
                push(@local_conflicts,$newcon);
            }

            # cleanup this mess
            @local_panel_dbtable=();
            $ptimeconflict=0;
        }
    }

    # Find moderator scheduling conflicts based on time

    foreach $panel (@local_panels_mod)
    {
        chomp($panel);
        if ($panel =~ m/PANID${panid}DINAP/) { next; }
        $local_stime=$local_ftime=$local_day=$local_panid=$panel;
        $local_day =~ s/.*,"DAY//;
        $local_day =~ s/YAD",.*//;

        # eliminate 20% of chances by day first
        if ($panel =~ m/DAY${day}YAD/)
        {
            $local_stime =~ s/.*,"STIME//;
            $local_stime =~ s/EMITS",.*//;
            $local_ftime =~ s/.*,"FTIME//;
            $local_ftime =~ s/EMITF",.*//;
            $local_panid =~ s/.*,"PANID//;
            $local_panid =~ s/DINAP",.*//;
            chomp($local_panid);

            $ccount=0;

            foreach $time (@dbtimetable)
            {
                if ($time =~ m/$local_stime/) 
		{ 
		    $scount=($ccount); 
		} # moderators need half hour cushion in front (-1)
		
                if ($time =~ m/$local_ftime/) 
		{ 
		    $fcount=($ccount); 
		} # moderators need half hour cushion behind (+1)
                
		$ccount++;
            }

            $ccount=0;

            for ($i=$scount; $i<=$fcount; $i++)
            { # build each same-day panel time-range
                $local_panel_dbtable[$ccount]=$dbtimetable[$i];
                $ccount++;
            }

            # Now we do a comparison to see if any element in 1st panel array 
	    # matches anything in others.

            foreach $first (@local_dbtable)
            {
                foreach $second (@local_panel_dbtable)
                {
                    if ($first =~ m/$second/)
                    {
                        $ptimeconflict=1;
                    }
                }
            }

            if ($ptimeconflict)
            {
                chomp($panelist); chomp($local_panid);
                $newconflictsfound=1;
                $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"Moderator MODID${venue}DIDOM is already scheduled
		 with CPANID${local_panid}DINAPC during this time.\"
		\n";
		$newcon =~ s/\t|\n//g;
                $newcon .= "\n";
                push(@local_conflicts,$newcon);
            }

            # cleanup this mess
            @local_panel_dbtable=();
            $ptimeconflict=0;
        }
    }

  # Participant - 4 :: No participant should have more than two panels in 
  # any day.

    foreach $pid (@local_ptable)
    {
	chomp($pid);
	$moncount = grep { /,"DAYMondayYAD",.*,"PARTID${pid}DITRAP"/ } 
		@lcpaneltable;
	$tuecount = grep { /,"DAYTuesdayYAD",.*,"PARTID${pid}DITRAP"/ } 
		@lcpaneltable;
	$wedcount = grep { /,"DAYWednesdayYAD",.*,"PARTID${pid}DITRAP"/ } 
		@lcpaneltable;
	$thucount = grep { /,"DAYThursdayYAD",.*,"PARTID${pid}DITRAP"/ } 
		@lcpaneltable;
	$fricount = grep { /,"DAYFridayYAD",.*,"PARTID${pid}DITRAP"/ } 
		@lcpaneltable;
	
	if ($moncount > 1 && $day =~ /Monday/) 
	{
            $newconflictsfound=1;
            $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"PARTID${pid}DITRAP is scheduled for more than two panels
		 on Monday\n";
	    $newcon =~ s/\t|\n//g;
            $newcon .= "\n";
            push(@local_conflicts,$newcon);
	}

        if ($tuecount > 1 && $day =~ /Tuesday/) 
        {
            $newconflictsfound=1;
            $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"PARTID${pid}DITRAP is scheduled for more than two panels
		 on Tuesday\n"; 
            $newcon =~ s/\t|\n//g;
            $newcon .= "\n";
            push(@local_conflicts,$newcon);
        }

        if ($wedcount > 1 && $day =~ /Wednesday/) 
        {
            $newconflictsfound=1;
            $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"PARTID${pid}DITRAP is scheduled for more than two panels
		 on Wednesday\n"; 
            $newcon =~ s/\t|\n//g;
            $newcon .= "\n";
            push(@local_conflicts,$newcon);
        }

        if ($thucount > 1 && $day =~ /Thursday/) 
        {
            $newconflictsfound=1;
            $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"PARTID${pid}DITRAP is scheduled for more than two panels
		 on Thursday\n"; 
            $newcon =~ s/\t|\n//g;
            $newcon .= "\n";
            push(@local_conflicts,$newcon);
        }

        if ($fricount > 1 && $day =~ /Friday/) 
        {
            $newconflictsfound=1;
            $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"PARTID${pid}DITRAP is scheduled for more than two panels
		 on Friday\n"; 
            push(@local_conflicts,$newcon);
        }
    }

  # Participant - 5 :: No pair of participants should be together on more than 
  # two panels during the week.

    $amountofpan = @ptable;
    foreach $part1 (@ptable)
    {
	chomp($part1);
	foreach $part2 (@ptable)
	{
	    chomp($part2);
	    if ($part1 == $part2) { next; }
	
	    @samepartimatches = 
		grep 
		{
			 /"PARTID${part1}DITRAP".*,"PARTID${part2}DITRAP"|
			,"PARTID${part2}DITRAP".*,"PARTID${part1}DITRAP"/ 
		} @paneltable;

	    $numberofmatches = @samepartimatches;

	    if ($numberofmatches > 2)
	    {
		$person1 = $part1;
		$person2 = $part2;

		if ($person1 > $person2)
		{
		    $temp = $person1;
		    $person1 = $person2;
		    $person2 = $temp;
		}

		$newconflictsfound=1;

		foreach $match (@samepartimatches)
		{
		    $match =~ s/.*,"PANID/CPANID/;
		    $match =~ s/DINAP",.*/DINAPC\ /;
		} 
		$samepartimatches = join(' ',@samepartimatches);
		$samepartimatches =~ s/\n//g;
		$newconflictsfound=1;
                $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"PARTID${person1}DITRAP and PARTID${person2}DITRAP are on
		 more than two panels together during this
		 conference week - $samepartimatches -.\"\n";
            	$newcon =~ s/\t|\n//g;
            	$newcon .= "\n";
                push(@local_conflicts,$newcon);
	    }
	    
	    $numberofmatches = 0;
	}
    }

  # Participant - 6 :: No group of three participants should be together on more
  # than one panel during the week.

    $amountofpan = @ptable;
    foreach $part1 (@ptable)
    {
        chomp($part1);
        foreach $part2 (@ptable)
        {
            chomp($part2);
            if ($part1 == $part2) { next; }

	    foreach $part3 (@ptable)
	    {
                @samepartimatches =
                grep
                {
/"PARTID${part1}DITRAP".*,"PARTID${part2}DITRAP",.*"PARTID${part3}DITRAP"|
,"PARTID${part1}DITRAP".*,"PARTID${part3}DITRAP",.*"PARTID${part2}DITRAP"|
,"PARTID${part2}DITRAP".*,"PARTID${part1}DITRAP",.*"PARTID${part3}DITRAP"|
,"PARTID${part2}DITRAP".*,"PARTID${part3}DITRAP",.*"PARTID${part1}DITRAP"|
,"PARTID${part3}DITRAP".*,"PARTID${part1}DITRAP",.*"PARTID${part2}DITRAP"|
,"PARTID${part3}DITRAP".*,"PARTID${part2}DITRAP",.*"PARTID${part1}DITRAP"|
/
                } @paneltable;

                $numberofmatches = @samepartimatches;

            	if ($numberofmatches > 1)
            	{
                    $person1 = $part1;
                    $person2 = $part2;
		    $person3 = $part3;

                    if ($person1 > $person2)
                    {
                    	$temp = $person1;
                    	$person1 = $person2;
                    	$person2 = $temp;
                    }

		    if ($person1 > $person3)
		    {
			$temp = $person1;
			$person1 = $person3;
			$person3 = $temp;
		    }

		    if ($person2 > $person3)
		    {
			$temp = $person1;
			$person2 = $person3;
			$person3 = $temp;
		    }

		    #print "$person1 $person2 $person3 <br>"; 

                    $newconflictsfound=1;

                    foreach $match (@samepartimatches)
                    {
                        $match =~ s/.*,"PANID/CPANID/;
                        $match =~ s/DINAP",.*/DINAPC\ /;
                    }

                    $samepartimatches = join(' ',@samepartimatches);
                    $samepartimatches =~ s/\n//g;
                    $newconflictsfound=1;
                    $newcon = "
			\"PANID${panid}DINAP\",
			\"VITAL\",
			\"PARTID${person1}DITRAP , PARTID${person2}DITRAP and 
			PARTID${person3}DITRAP are on more than one 
			panel together during this conference
			week ~ $samepartimatches ~.\"\n";
                    $newcon =~ s/\t|\n//g;
                    $newcon .= "\n";
                    #push(@local_conflicts,$newcon);
                }
            
  		$numberofmatches = 0;
	    }
        }
    }	

  # Panel - 1 :: No two panels can be assigned the same session number
    $sessinum = $pentry;
    $sessinum =~ s/.*,"SESID//;
    $sessinum =~ s/DISES",.*//;

    if ($sessinum)
    {
	@sessionpanel = grep { /,"SESID${sessinum}DISES",/ } @lcpaneltable;
    }

    $num_sessions = @sessionpanel;

    if ($num_sessions > 0)
    {
	$newconflictsfound=1;
	
	foreach $sessid (@sessionpanel)
    	{
	    chomp($sessid);
	    $sessionpanel = $sessid;
	    $sessionpanel =~ s/.*,"PANID/CPANID/;
	    $sessionpanel =~ s/DINAP",.*/DINAPC/;
	    $newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"This panel and $sessionpanel have the same session
		 number.\"\n";
            $newcon =~ s/\t|\n//g;
            $newcon .= "\n";
	    push(@local_conflicts,$newcon);
	}
    }

  # Panel - 2 :: Each panel must have a producer
    if($pentry =~ m/PRODIDDIDORP/)
    { 
        $newconflictsfound=1;
        $newcon = "
	\"PANID${panid}DINAP\",
	\"VITAL\",
	\"No producer\"
	\n";
        $newcon =~ s/\t|\n//g;
        $newcon .= "\n";
        push(@local_conflicts,$newcon);
    }

  # Panel - 3 :: Each panel must have a venue
    if($pentry =~ m/VENIDDINEV/)
    {
        #$newconflictsfound=1;
        $newcon = "
	\"PANID${panid}DINAP\",
	\"No venue\"
	\n";
        $newcon =~ s/\t|\n//g;
        $newcon .= "\n";
        #push(@local_conflicts,$newcon);
    }

  # Panel - 4 :: The initial panel for each first-time participant should 
  # contain at least one veteran participant if on Monday.

    $numberofparticipants=@ptable;

    if($numberofparticipants > 0)
    {
        @allparticipants = `${CAT} ${DBDIRECTORY}*participants*.db`;

    	foreach $person (@allparticipants)
    	{
	    $fname=$lname=$person;
	    $fname =~ s/.*,"FNAME//;
	    $fname =~ s/EMANF",.*//;
	    $lname =~ s/"LNAME//;
	    $lname =~ s/EMANL",.*//;
	    $person = "$fname $lname";
	    chomp($person);
        }

    	$veterans = 0;

    	foreach $panelist (@ptable)
    	{
	    $this=getParticipantNamefromID($panelist);
	    chomp($this);

	    foreach $person (@allparticipants)
	    {
		$person =~ s/\n//g;
	        if ($this =~ /$person/)
	    	{
		    $matches++;
	    	}
	    }
	
	    if ($matches > 1)
	    {
	        $veterans=1;
 	    }

	    $matches=0;
        }

        if ($veterans == 0 && $day =~ /Monday/)
        {
            $newconflictsfound=1;
            $newcon = "
		\"PANID${panid}DINAP\",
		\"No veteran participants on this panel\"
		\n";
	    $newcon =~ s/\t|\n//g;
            $newcon .= "\n";
            push(@local_conflicts,$newcon);
        }
    }

    # Tag based conflicts

    foreach $tag (@tagtable)
    {
	chomp($tag);
	$tagid = $tagaffect = $tagname = $needs = $tag;
	$tagid =~ s/.*,"TAGID//;
	$tagid =~ s/DIGAT",.*//;
	$needs =~ s/.*,"NEEDS//;
	$needs =~ s/SDEEN",.*//;
	$tagname =~ s/.*,"TAGNAME//;
	$tagname =~ s/EMANGAT",.*//;
	$tagname =~ s/TAGNAME//;
	$tagaffect =~ s/.*,"AFFECTS//;
	$tagaffect =~ s/STCEFFA"//;
	$partind = 0;
	$size = @ptable;
	$must = 1;
	$tested = "0";

	if ($tagaffect =~ m/PAR/)
	{
		foreach $parid (@ptable)
		{ 
		    @participant = grep { /,"PARTID${parid}DITRAP",/ } 
			@partitable;
		    $participant = join('',@participant);
		    chomp($participant);

		    if ($participant =~ m/,"TAGID${tagid}DIGAT"/)
		    {
			    if ($needs =~ m/MUST/)
			    {
				if ($tested =~ m/${parid}/){}
				else
				{
					$must = 0;
					$mustcomp = "PARTID${parid}DITRAP";
				}
			    }
			    for ($count = $partind; $count < $size; $count++)
        		    {
				$parid2 = $ptable[$count];
            			@this_part = grep { /,"PARTID${parid2}DITRAP",/ } 
						@partitable;
        	    		$this_part = join('',@this_part);
	            		chomp($this_part);

            			if ($this_part =~ m/,"TAGID${tagid}DIGAT"/ 
					&& $this_part !~ m/$participant/) 
        	    		{
				    if ($needs =~ m/MUST/)
				    {
				        $must = 1;
					$tested .= $parid2;
				    }
			
				    else	
				    {
				        $newconflictsfound=1;
        	        		$newcon = "
					\"PANID${panid}DINAP\",
					\"VITAL\",
					\"PARTID${parid}DITRAP and PARTID${parid2}DITRAP are
					 on a panel together and have the same cant have tag ~ $tagname ~.\"\n";
        	    			$newcon =~ s/\t|\n//g;
	        	    		$newcon .= "\n";
		                	push(@local_conflicts,$newcon);
				    }
				}
			    }

			    if ($tagaffect =~ m/VEN/)
			    {
			        @this_part = grep { /,"VENID${venue}DINEV",/ } @venuetable;
				$this_part = join('',@this_part);
				chomp($this_part);

				if ($this_part =~ m/,"TAGID${tagid}DIGAT"/)
				{
				    if ($needs =~ m/MUST/)
				    {
				        $must = 1;
					$tested .= $venue;
				    }
		
				    else	
				    {
				        $newconflictsfound=1;
        	        		$newcon = "
					\"PANID${panid}DINAP\",
					\"VITAL\",
					\"PARTID${parid}DITRAP and VENID${venue}DINEV are
					 on a panel together and have the same cant have tag ~ $tagname ~.\"\n";
        	    			$newcon =~ s/\t|\n//g;
	        	    		$newcon .= "\n";
		                	push(@local_conflicts,$newcon);
				    }
				}
			    }

			    if ($tagaffect =~ m/PRO/)
			    {
				@this_part = grep { /,"PRODID${producer}DIDORP",/ } @produtable;
				$this_part = join('',@this_part);
				chomp($this_part);

				if ($this_part =~ m/,"TAGID${tagid}DIGAT"/)
				{
				    if ($needs =~ m/MUST/)
				    {
				        $must = 1;
					$tested .= $producer;
				    }
		
				    else	
				    {
				        $newconflictsfound=1;
        	        		$newcon = "
					\"PANID${panid}DINAP\",
					\"VITAL\",
					\"PARTID${parid}DITRAP and PRODID${producer}DIDORP are
					 on a panel together and have the same cant have tag ~ $tagname ~.\"\n";
        	    			$newcon =~ s/\t|\n//g;
	        	    		$newcon .= "\n";
		                	push(@local_conflicts,$newcon);
				    }
				}
			    }

			    if ($tagaffect =~ m/MOD/)
			    {
				@this_part = grep { /,"MODID${moderator}DIDOM",/ } @modertable;
				$this_part = join('',@this_part);
				chomp($this_part);

				if ($this_part =~ m/,"TAGID${tagid}DIGAT"/)
				{
				    if ($needs =~ m/MUST/)
				    {
				        $must = 1;
					$tested .= $moderator;
				    }
		
				    else	
				    {
				        $newconflictsfound=1;
        	        		$newcon = "
					\"PANID${panid}DINAP\",
					\"VITAL\",
					\"PARTID${parid}DITRAP and MODID${moderator}DIDOM are
					 on a panel together and have the same cant have tag ~ $tagname ~.\"\n";
        	    			$newcon =~ s/\t|\n//g;
	        	    		$newcon .= "\n";
		                	push(@local_conflicts,$newcon);
				    }
				}
			    }
		    }
		    $partind++;
		}
	  }

	  if ($tagaffect =~ m/VEN/)
	  {
		@venuetag = grep { /,"VENID${venue}DINEV",/ } @venuetable;
		$venuetag = join('',@venuetag);
		chomp($venuetag);

		if ($venuetag =~ m/,"TAGID${tagid}DIGAT"/)
		{
			if ($needs =~ m/MUST/)
			{
				if ($tested =~ m/${venue}/){}
				else
				{
					$must = 0;
					$mustcomp = "VENID${venue}DINEV";
				}
			}
			if ($tagaffect =~ m/PRO/)
			{
				@this_part = grep { /,"PRODID${producer}DIDORP",/ } @produtable;
				$this_part = join('',@this_part);
				chomp($this_part);

				if ($this_part =~ m/,"TAGID${tagid}DIGAT"/)
				{
				    if ($needs =~ m/MUST/)
				    {
				        $must = 1;
					$tested .= $producer;
				    }
		
				    else	
				    {
				        $newconflictsfound=1;
        	        		$newcon = "
					\"PANID${panid}DINAP\",
					\"VITAL\",
					\"VENID${venue}DINEV and PRODID${producer}DIDORP are
					 on a panel together and have the same cant have tag ~ $tagname ~.\"\n";
        	    			$newcon =~ s/\t|\n//g;
	        	    		$newcon .= "\n";
		                	push(@local_conflicts,$newcon);
				    }
				}
			}

 			if ($tagaffect =~ m/MOD/)
	  		{
				@this_part = grep { /,"MODID${moderator}DIDOM",/ } @modertable;
				$this_part = join('',@this_part);
				chomp($this_part);

				if ($this_part =~ m/,"TAGID${tagid}DIGAT"/)
				{
				    if ($needs =~ m/MUST/)
				    {
				        $must = 1;
					$tested .= $moderator;
				    }
		
				    else	
				    {
				        $newconflictsfound=1;
        	        		$newcon = "
					\"PANID${panid}DINAP\",
					\"VITAL\",
					\"VENID${venue}DINEV and MODID${moderator}DIDOM are
					 on a panel together and have the same cant have tag ~ $tagname ~.\"\n";
        	    			$newcon =~ s/\t|\n//g;
	        	    		$newcon .= "\n";
		                	push(@local_conflicts,$newcon);
				    }
				}
			}
		}
	  }

	  if ($tagaffect =~ m/PRO/)
	  {
		@producid = grep { /,"PRODID${producer}DIDORP",/ } @produtable;
		$producid = join('',@producid);
		chomp($producid);

		if ($producid =~ m/,"TAGID${tagid}DIGAT"/)
		{
			if ($needs =~ m/MUST/)
			{
				if ($tested =~ m/${producer}/){}
				else
				{
					$must = 0;
					$mustcomp = "PRODID${producer}DIDORP";
				}
			}

			if ($tagaffect =~ m/MOD/)
			{
				@this_part = grep { /,"MODID${moderator}DIDOM",/ } @modertable;
				$this_part = join('',@this_part);
				chomp($this_part);

				if ($this_part =~ m/,"TAGID${tagid}DIGAT"/)
				{
				    if ($needs =~ m/MUST/)
				    {
				        $must = 1;
					$tested .= $moderator;
				    }
		
				    else	
				    {
				        $newconflictsfound=1;
        	        		$newcon = "
					\"PANID${panid}DINAP\",
					\"VITAL\",
					\"PRODID${producer}DIDORP and MODID${moderator}DIDOM are
					 on a panel together and have the same cant have tag ~ $tagname ~.\"\n";
        	    			$newcon =~ s/\t|\n//g;
	        	    		$newcon .= "\n";
		                	push(@local_conflicts,$newcon);
				    }
				}
			}
		}
	}

	if ($tagaffect =~ m/MOD/)
	{
		@modeid = grep { /,"MODID${moderator}DIDOM",/ } @modertable;
		$modeid = join('',@modeid);
		chomp($modeid);

		if ($modeid =~ m/,"TAGID${tagid}DIGAT"/)
		{
			if ($needs =~ m/MUST/)
			{
				if ($tested =~ m/${moderator}/){}
				else
				{
					$must = 0;
					$mustcomp = "MODID${moderator}DIDOM";
				}
			}
		}
	  }

	  if ($must == 0)
	  {
		$newconflictsfound=1;
       		$newcon = "
		\"PANID${panid}DINAP\",
		\"VITAL\",
		\"$mustcomp has must-have conflict: $tagname, but no other 
		 panel component has the same tag.\"\n";
 		$newcon =~ s/\t|\n//g;
       		$newcon .= "\n";
               	push(@local_conflicts,$newcon);
	  }
    }

    open(IN,"<",$confile);
    @global_conflicts=<IN>;
    close(IN);

    open(IN,"<",$condisfile);
    @disabled_conflicts=<IN>;
    close(IN);

    @global_conflicts = grep { !/PANID${panid}DINAP/ } @global_conflicts;

    # Delete all old conflicts matching the current panel ID
    deleteTableObject(\@global_conflicts,$confile);
    $local_count = 0;
 
    if ($newconflictsfound)
    {
	foreach $local_con (@local_conflicts)
	{
	    foreach $disabled_con (@disabled_conflicts)
	    {
		if ( $local_con =~ $disabled_con )
		{
		    $local_count++;
		}
	    }

	    if ($local_count == 0)
	    {
		push(@final_local_conflicts,$local_con);
	    }

	    $local_count=0;
	}

	# Append new conflicts
	addTableObjects(\@final_local_conflicts,$confile);
	removeDuplicates($confile);
    }
}

sub conflictPage()
{
    # This is the main page for viewing All Conflicts, Vital Conflicts, Disabled
    # Conflicts and more.  Each conflict needs to have proper deferencing of 
    # object names into participants, venues, producers, moderators, and panels.
    # PARTID, VENID, MODID, PRODID, CPANID are useful.
    
    ($sid,$confile,$condisfile,$panelfile,$type,$con,$year,$userfile,$sessifile)	=@_;

    open(IN,"<",$confile);
    @contable=<IN>;
    close(IN);

    if($con =~ /all/)
    {
	$aselected="selected";
  	$type="All";
    }

    elsif ($con =~ /disabled/)
    {
	@contable=();
    	open(IN,"<",$condisfile);
        @contable=<IN>;
        close(IN);

	$type="Disabled";
    }

    else
    {
	$vselected="selected";
	$type="Vital";
    }

    $vitalcount=`${CAT} $confile | ${GREP} VITAL | ${WC}`;
    $totalcount=`${CAT} $confile | ${WC}`;

    print( STDOUT <<HTML );

<div id="content">
<h2>$type Conflicts for $yearname</h2>
<hr size="1" noshade>
<font size=2 face=verdana>There are $vitalcount vital conflicts and a total of $totalcount conflicts.</font><br><br>
<ul>
HTML
    if ($type =~ /Vital/)
    {
	print "Vital Conflicts -";
    }

    else
    {
	print "<a href=\"cwasys.pl?sid=$sid&pid=conflicts&y=$year\">Vital Conflicts </a> -";
    }

    if ($type =~ /All/)
    {
	print " All Conflicts -";
    }

    else
    {
	print " <a href=\"cwasys.pl?sid=$sid&pid=conflicts&con=all&y=$year\">All Conflicts</a> -";
    }

    if ($type =~ /Disabled/)
    {
	print " Quieted Conflicts -";
    }

    else
    {
	print " <a href=\"cwasys.pl?sid=$sid&pid=conflicts&con=disabled&y=$year\">Quieted Conflicts</a> -";
    }

    $nummod = grep { /"MODIDDIDOM"/ } @paneltable;

    if ($type =~ /moderator/)
    {
        print " No Moderators ($nummod) -";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=othercon&type=moderator&y=$year\">No Moderators ($nummod) </a> -";
    }

    $numven = grep { /"VENIDDINEV"/ } @paneltable;

    if ($type =~ /venue/)
    {
        print " No Venues ($numven) ";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=othercon&type=venue&y=$year\">No Venues ($numven)</a>";
    }

    print (STDOUT <<HTML);
</ul>
<table class="bettyTable" name="bettyTable" width="700" cellpadding=0>
<th> Name </th> <th> Conflict Description </th>
HTML

    if ($type =~ /Disabled/)
    {
	print "<th> Un-Disable </th>";
    }
    
    else
    {
	print "<th> Disable </th>";
    }

    @contable = sort {lc $a cmp lc $b} @contable;
    
    foreach $entry (@contable)
    {
	chomp($entry);
        $panel=$conentry=$formattedentry=$entry;
        $panel =~ s/"PANID//;
        $panel =~ s/DINAP",.*//;
	$cpanelid=$panelsyn=$panel;
	$panelsyn="\"PANID${panelsyn}DINAP\"";
        @panl = grep { /$panelsyn/ } @paneltable;
	$panel = join('',@panl);
	$panel =~ s/"PANEL//;
	$panel =~ s/LENAP",".*//;
	$panel = addRegExp($panel);
        $conentry =~ s/.*DINAP","//;
	$conentry =~ s/VITAL","//;
        $conentry =~ s/"//g;
	$modentry=$proentry=$partentry=$venentry=$conentry;

	if($conentry =~ m/CPANID/)
	{ # could be more than on conference inside the conflict
	    $conpanelid=$conentry;
	    $concount=0;
	    while ($conpanelid =~ /CPANID/g) { $concount++; }

            if ($concount > 1)
            {
		$conpanelid =~ s/.*\- //;
		$conpanelid =~ s/\-.*//;
                @conconid = split("\ ",$conpanelid);
                $sizeofcon = @conconid;

                foreach $place (@conconid)
                {
                    $stripped = $place;
                    $stripped =~ s/.*CPANID//g;
                    $stripped =~ s/DINAPC.*//g;
                    $conpanelname = getPanelNamefromID($stripped);
		    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
		    {
			$conentry =~ s/$place/$dash $conpanelname/;
		    }

		    else
		    {
                        $conentry =~ s/$place/$dash <a href=cwasys.pl?delete=panel&panbox=$stripped&sid=$sid&y=$year&panelform=Edit>$conpanelname<\/a>/;
		    }
		    $dash = "-";
                }
		$dash = "";
            }

	    else
	    {
	        $conpanelid =~ s/.*CPANID//;
	        $conpanelid =~ s/DINAPC.*//;
	        $conpanel = getPanelNamefromID($conpanelid);
                if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
                {
                    $conentry =~ s/CPANID${conpanelid}DINAPC/$conpanel/;
                }

                else
                {
	            $conentry =~ s/CPANID${conpanelid}DINAPC/<a href=cwasys.pl?delete=panel&panbox=$conpanelid&sid=$sid&y=$year&panelform=Edit>$conpanel<\/a>/;
		}
	    }
 	}

	if($conentry =~ m/VENID/)
	{
            $convenueid=$venentry;
            $convenueid =~ s/.*VENID//;
            $convenueid =~ s/DINEV.*//;
	    chomp($convenueid);
            $convenue = getVenueNamefromID($convenueid);
            if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
            {
                $conentry =~ s/VENID${convenueid}DINEV/$convenue/;
            }

            else
            {
                $conentry =~ s/VENID${convenueid}DINEV/<a href=cwasys.pl?sid=$sid&pid=readonly&object=venue&venid=$convenueid&y=$year>$convenue<\/a>/;
	    }
	}

	if($conentry =~ m/PARTID/)
	{ # could be more than one participant 
	    $conpartid=$partentry;
	    $partcount=0;
	    while ($conpartid =~ /PARTID/g) { $partcount++ }

	    if ($partcount > 1)
	    {
    	    	$conpartid =~ s/\ and\ /\ /g;
	    	$conpartid =~ s/\ are.*//g;
    	    	@conparti = split("\ ",$conpartid);
	    	$sizeofcon = @conparti;

	    	foreach $place (@conparti) 
	    	{ 
		    $stripped = $place;
		    $stripped =~ s/PARTID//;
		    $stripped =~ s/DITRAP//;
		    $conpartname = getParticipantNamefromID($stripped);
		    if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
                    {
                        $conentry =~ s/$place/$conpartname/;
                    }

                    else
                    {
                        $conentry =~ s/$place/<a href=cwasys.pl?sid=$sid&pid=readonly&object=participant&partid=$stripped&y=$year>$conpartname<\/a>/;
		    }
	        }
	    }

	    else
	    {
                $conpartid =~ s/.*PARTID//;
                $conpartid =~ s/DITRAP.*//;
                chomp($conpartid);
                $conpart = getParticipantNamefromID($conpartid);
		if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
                {
		    $conentry =~ s/PARTID${conpartid}DITRAP/$conpart/;
                }

                else
                {
               	    $conentry =~ s/PARTID${conpartid}DITRAP/<a href=cwasys.pl?sid=$sid&pid=readonly&object=participant&partid=$conpartid&y=$year>$conpart<\/a>/;
		}
	    }
	}

	if($conentry =~ m/PRODID/)
	{
            $conproid=$proentry;
            $conproid =~ s/.*PRODID//;
            $conproid =~ s/DIDORP.*//;
            chomp($conproid);
            $conpro = getProducerNamefromID($conproid);

            if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
            {
                 $conentry =~ s/PRODID${conproid}DIDORP/$conpro/;
            }

            else
            {
            	$conentry =~ s/PRODID${conproid}DIDORP/<a href=cwasys.pl?sid=$sid&pid=readonly&object=producer&prodid=$conproid&y=$year>$conpro<\/a>/;
	    }
	}

	if($conentry =~ m/MODID/)
	{
            $conmodid=$modentry;
            $conmodid =~ s/.*MODID//;
            $conmodid =~ s/DIDOM.*//;
            chomp($conmodid);
            $conmod = getModeratorNamefromID($conmodid);

            if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
            {
                $conentry =~ s/MODID${conmodid}DIDOM/$conmod/;
            }

            else
            {
            	$conentry =~ s/MODID${conmodid}DIDOM/<a href=cwasys.pl?sid=$sid&pid=readonly&object=moderator&modid=$conmodid&y=$year>$conmod<\/a>/;
	    }
	}

	if(($con) || ($entry =~ m/VITAL/))
	{ 
            if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
            {
                print "<tr><td>$panel</td><td>$conentry</td>";
            }

            else
            {
	    	print "<tr><td><a href=cwasys.pl?delete=panel&panbox=$cpanelid&sid=$sid&y=$year&panelform=Edit>$panel
		</a></td><td>$conentry</td>";
	    }

	    $formattedentry = addRegExp($formattedentry);
            $page = $ENV{QUERY_STRING};
            chomp($page);
	    print "<td>";

            if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
            {
                print "Unavailable";
            }

            else
            {
	    	print "<form action=\"cwasys.pl\" method=\"GET\">";
            	print "<input type=\"hidden\" name=sid value=\"$sid\">";
            	print "<input type=\"hidden\" name=y value=\"$year\">";
	
	    	if ($type =~ /Disabled/)
	    	{ # Un-disable a disabled conflict
        	    print "<input type=\"hidden\" name=\"conundisable\"
		     value=\"$formattedentry\">";
        	    print "<input type=\"hidden\" name=\"page\" value=\"$page\">";
        	    print "<input type=\"submit\" value=\"Un-Quiet\">";
	    	}

	    	else
	    	{ # Quiet a conflict
        	    print "<input type=\"hidden\" name=\"condisable\" 
		     value=\"$formattedentry\">";
        	    print "<input type=\"hidden\" name=\"page\" value=\"$page\">";
        	    print "<input type=\"submit\" value=\"Quiet\">";
	    	}
		print "</form>";
	    }
	    print "</td></tr>";
	}
    }

print(STDOUT <<HTML);
</table>
</div>

HTML
}

sub listAllConflicts()
{
    # Panel page needs this to show user all conflicts related to their panel
    # We examine the passed panelid, identify all conflicts matching that id, then
    # format then everything accordingly

    ($cpanelid,$confile)=@_;

    open(IN,"<",$confile);
    @contable=<IN>;
    close(IN);

    $cpanelid = "\"PANID${panelid}DINAP\"";

    @localcon = grep { /$cpanelid/ } @contable;
    $size = @localcon;

    if($size)
    {
	print "<center><table cellpadding=0 cellspacing=0 class=bettyTable width=\"75%\"><tr>";
	if ($size == 1)
	{
    	    print "<th><font color=red size=2 face=verdana>$size conflict found</font></th></tr>";
	}

        else
        {
	    print "<th><font color=red size=2 face=verdana>$size conflicts found</font></th></tr>";
    	}

        print "<tr><td><br>";

	foreach $entry (@localcon)
	{
	    $formattedentry = $entry;
    	    $entry =~ s/.*DINAP","//;
	    $entry =~ s/VITAL//;
	    $entry =~ s/"//g;
	    $entry =~ s/\,//;

            if($entry =~ m/CPANID/)
            {
            	$conpanelid=$entry;
                $pancount=0;
                while ($conpanelid =~ /CPANID/g) { $conpanelcount++ }
		
                if ($conpanelcount > 1)
                {
		    $conpanelid =~ s/.*\(\ //;
		    $conpanelid =~ s/\ \).*//;
                    @cpan = split("\ ",$conpanelid);
                    $sizeofcon = @cpan;

                    foreach $place (@cpan)
                    {
			chomp($place);
			$stripped = $place;
			$stripped =~ s/.*CPANID//g;
			$stripped =~ s/DINAPC.*//g;
                        $conpanname = getPanelNamefromID($stripped);
			chomp($conpanname);
			$entry =~ s/CPANID${stripped}DINAPC/$dash <a href=cwasys.pl?delete=panel&panbox=$stripped&sid=$sid&y=$year&panelform=Edit><i>"$conpanname"<\/i><\/a>/;
			$dash = "-";
                    }

		    $dash = "";
                }

                else
                {
            	    $conpanelid =~ s/.*CPANID//;
            	    $conpanelid =~ s/DINAPC.*//;
	    	    chomp($conpanelid);
            	    $conpanel = getPanelNamefromID($conpanelid);
            	    $entry =~ s/CPANID${conpanelid}DINAPC/<a href=cwasys.pl?delete=panel&panbox=$conpanelid&sid=$sid&y=$year&panelform=Edit><i>"$conpanel"<\/i><\/a>/;
	    	    $entry =~ s/\n//g;
		}
            }

            if($entry =~ m/VENID/)
            {
            	$convenueid=$entry;
            	$convenueid =~ s/.*VENID//;
            	$convenueid =~ s/DINEV.*//;
            	chomp($convenueid);
            	$convenue = getVenueNamefromID($convenueid);
            	$entry =~ s/VENID${convenueid}DINEV/<a href=cwasys.pl?sid=$sid&pid=readonly&object=venue&venid=$convenueid&y=$year>$convenue<\/a>/;
	    	$entry =~ s/\n//g;
            }


            if($entry =~ m/PARTID/)
            { # could be more than one participant
            	$conpartid=$entry;
            	$partcount=0;
            	while ($conpartid =~ /PARTID/g) { $partcount++ }

            	if ($partcount > 1)
            	{
                    $conpartid =~ s/\ and\ /\ /g;
                    $conpartid =~ s/\ are.*//g;
                    @conparti = split("\ ",$conpartid);
                    $sizeofcon = @conparti;

                    foreach $place (@conparti)
                    {
                    	$stripped = $place;
                    	$stripped =~ s/.*PARTID//;
			$stripped =~ s/DITRAP.*//g;
			$conpartname = getParticipantNamefromID($stripped);
                    	$entry =~ s/$place/<a href=cwasys.pl?sid=$sid&pid=readonly&object=participant&partid=$stripped&y=$year>$conpartname<\/a>/;
                    }
            	}

                else
                {
                    $conpartid =~ s/.*PARTID//;
                    $conpartid =~ s/DITRAP.*//;
                    chomp($conpartid);
                    $conpart = getParticipantNamefromID($conpartid);
                    $entry =~ s/PARTID${conpartid}DITRAP/<a href=cwasys.pl?sid=$sid&pid=readonly&object=participant&partid=$conpartid&y=$year>$conpart<\/a>/;
                }
        }

            if($entry =~ m/PRODID/)
            {
            	$conproid=$entry;
            	$conproid =~ s/.*PRODID//;
            	$conproid =~ s/DIDORP.*//;
            	chomp($conproid);
            	$conpro = getProducerNamefromID($conproid);
            	$entry =~ s/PRODID${conproid}DIDORP/<a href=cwasys.pl?sid=$sid&pid=readonly&object=producer&prodid=$conproid&y=$year>$conpro<\/a>/;
	    	$entry =~ s/\n//g;
            }

            if($entry =~ m/MODID/)
            {
            	$conmodid=$entry;
            	$conmodid =~ s/.*MODID//;
            	$conmodid =~ s/DIDOM.*//;
            	chomp($conmodid);
            	$conmod = getModeratorNamefromID($conmodid);
            	$entry =~ s/MODID${conmodid}DIDOM/<a href=cwasys.pl?sid=$sid&pid=readonly&object=moderator&modid=$conmodid&y=$year>$conmod<\/a>/;
	    	$entry =~ s/\n//g;
            }

	    $formattedentry = addRegExp($formattedentry);
	    $page = $ENV{QUERY_STRING};
	    chomp($page);

	    chomp($formattedentry);
	    print "<form action=\"cwasys.pl\" method=\"GET\">";
	    print "<input type=\"hidden\" name=sid value=\"$sid\">";
	    print "<input type=\"hidden\" name=y value=\"$year\">";
	    print "<input type=\"hidden\" name=\"condisable\"
		 value=\"$formattedentry\">";
	    print "<input type=\"hidden\" name=\"page\" value=\"$page\">";
	    print "<input type=\"submit\" value=\"Quiet\">";
	    print "&nbsp&nbsp&nbsp&nbsp";
	    print "<font color=red size=2 face=verdana>$entry</font>";
	    print "</form>";
	}
	print "</ul></td></tr></table></center>";
    }
}

sub conflictDisable()
{
    ($confile,$condisfile,$conflict,$page) = @_;

    # Remove this conflict from the conflicts.db file and append it to the
    # conflictsdisabled.db file.  Then refresh to the page where the person
    # was just located.

    open(IN,"<",$confile);
    @confiles = <IN>;
    close(IN);

    $conflict =~ s/\n//g;
    chomp($conflict);
    #chop($conflict);

    addTableObject($conflict,$condisfile);
    @confiles = grep { !/$conflict/ } @confiles;
    deleteTableObject(\@confiles,$confile);
    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?$page\">";
}

sub conflictUnDisable()
{
    ($confile,$condisfile,$conflict,$page) = @_;

    # Remove this conflict from the conflictsdisabled.db file and append it
    # to the conflicts.db file.  Then refresh to the page where the person
    # was just located.

    # A bug was discovered here awhile back related to conflicts not being
    # correctly transfered from one table to the next.  The problem is that 
    # conflict messages CANNOT contain regular expressions.  A parenthese ()
    # broke things before, so avoid that type of nonsense when doing conflict
    # searching.

    open(IN,"<",$condisfile);
    @contents = <IN>;
    close(IN);

    chomp($conflict);

    addTableObject($conflict,$confile);
    @contents = grep { !/$conflict/ } @contents;
    deleteTableObject(\@contents,$condisfile);
    print "<meta http-equiv=\"refresh\" content=\"0; url=cwasys.pl?$page\">";
}

sub noVenueOrModeratorPage()
{
    # Since venues and moderators are assigned at a later time, these need to be
    # shown in a separate conflict page.  This is NOT integrated into conflicts.

    ($sid,$type,$confile,$year,$userfile,$sessifile)=@_;

    open(IN,"<",$confile);
    @contable=<IN>;
    close(IN);

    $vitalcount=`${CAT} $confile | ${GREP} VITAL | ${WC}`;
    $totalcount=`${CAT} $confile | ${WC}`;

    $thistype = ucfirst($type);
    print( STDOUT <<HTML );

<div id="content">
<h2>No ${thistype}s for $yearname</h2>
<hr size="1" noshade>
<font size=2 face=verdana>There are $vitalcount vital conflicts and a total of $totalcount conflicts.</font><br><br>
<ul>
HTML

    if ($type =~ /Vital/)
    {
        print "Vital Conflicts -";
    }

    else
    {
        print "<a href=\"cwasys.pl?sid=$sid&pid=conflicts&y=$year\">Vital Conflicts</a> -";
    }

    if ($type =~ /All/)
    {
        print " All Conflicts -";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=conflicts&con=all&y=$year\">All Conflicts</a> -";
    }

    if ($type =~ /Disabled/)
    {
        print " Quieted Conflicts -";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=conflicts&con=disabled&y=$year\">Quieted Conflicts</a> -";
    }

    $nummod = grep { /"MODIDDIDOM"/ } @paneltable;

    if ($type =~ /moderator/)
    {
	print " No Moderators ($nummod) -";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=othercon&type=moderator&y=$year\">No Moderators ($nummod) </a> -";
    }

    $numven = grep { /"VENIDDINEV"/ } @paneltable;

    if ($type =~ /venue/)
    {
        print " No Venues ($numven) ";
    }

    else
    {
        print " <a href=\"cwasys.pl?sid=$sid&pid=othercon&type=venue&y=$year\">No Venues ($numven)</a>";
    }

    print (STDOUT <<HTML);
</ul>
<table class="bettyTable" name="bettyTable" width="700" cellpadding=0>
<th> Panels </th>
HTML

    if ($type =~ /moderator/)
    {
	@nomoderator = grep { /"MODIDDIDOM"/ } @paneltable;

  	foreach $mod (@nomoderator)
 	{
	    $panelname=$panelid=$mod;
	    $panelname =~ s/.*"PANEL//;
	    $panelname =~ s/LENAP".*//;
	    $panelid =~ s/.*"PANID//;
	    $panelid =~ s/DINAP".*//;
	    chomp($panelid);

            if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
            {
                print "<tr><td>$panelname</td></tr>";
            }

            else
            {	    
	        print "<tr><td><a href=cwasys.pl?delete=panel&panbox=$panelid&sid=$sid&y=$year&panelform=Edit>$panelname</a></td></tr>";    
	    }
	}
    }

    else
    {
	@novenue = grep { /"VENIDDINEV"/ } @paneltable;

        foreach $mod (@novenue)
        {
            $panelname=$panelid=$mod;
            $panelname =~ s/.*"PANEL//;
            $panelname =~ s/LENAP".*//;
            $panelid =~ s/.*"PANID//;
            $panelid =~ s/DINAP".*//;
            chomp($panelid);

            if (getAccessLevel($sid,$userfile,$sessifile) =~ m/planner/)
            {
                print "<tr><td>$panelname</td></tr>";
            }

            else
            {
                print "<tr><td><a href=cwasys.pl?delete=panel&panbox=$panelid&sid=$sid&y=$year&panelform=Edit>$panelname</a></td></tr>";
	    }
        }
    }

    print "</table>";
}

sub getPanelNamefromID()
{
    # Given a panel ID, find the panel title name within the panel table

    ($conpanelid)=@_;
    @conpanel = grep { /,"PANID${conpanelid}DINAP",/ } @paneltable;
    $conpanel = join('',@conpanel);
    chomp($conpanel);
    $conpanel =~ s/.*"PANEL//;
    $conpanel =~ s/LENAP",.*//;
    $conpanel = addRegExp($conpanel);
    return($conpanel);
}

sub getVenueNamefromID()
{
    # Given a venue ID, find the venue name within the venue table

    ($convenueid)=@_;
    @convenue = grep { /,"VENID${convenueid}DINEV",/ } @venuetable;
    $convenue = join('',@convenue);
    chomp($convenue);
    $convenue =~ s/"VENLOC//;
    $convenue =~ s/COLNEV",".*//;
    $conpanel = addRegExp($conpanel);
    return($convenue);
}

sub getParticipantNamefromID()
{
    # Given a participant ID, find the part name within the part table

    ($conpartid)=@_;
    @conpart = grep { /,"PARTID${conpartid}DITRAP",/ } @partitable;
    $conparts = join('',@conpart);
    chomp($conparts);
    $first=$last=$conparts;
    $first =~ s/.*,"FNAME//;
    $first =~ s/EMANF",.*//;
    $last =~ s/"LNAME//;
    $last =~ s/EMANL".*//;
    $conparts = "$first $last";
    $conparts = addRegExp($conparts);
    @conpart = ();
    return($conparts);
}

sub getModeratorNamefromID()
{
    # Given a moderator ID, find the mod name within the mod table

    ($conmodid)=@_;
    @conmod = grep { /,"MODID${conmodid}DIDOM",/ } @modertable;
    $conmod = join('',@conmod);
    chomp($conmod);
    $first=$last=$conmod;
    $first =~ s/.*,"FNAME//;
    $first =~ s/EMANF",.*//;
    $last =~ s/"LNAME//;
    $last =~ s/EMANL".*//;
    $conmod = "$first $last";
    $conmod = addRegExp($conmod);
    return($conmod);
}

sub getProducerNamefromID()
{
    # Given a producer ID, find the prod name within the prod table

    ($conproid)=@_;
    @conpro = grep { /,"PRODID${conproid}DIDORP",/ } @produtable;
    $conpro = join('',@conpro);
    chomp($conpro);
    $first=$last=$conpro;
    $first =~ s/.*,"FNAME//;
    $first =~ s/EMANF",.*//;
    $last =~ s/"LNAME//;
    $last =~ s/EMANL".*//;
    $conpro = "$first $last";
    $conpro = addRegExp($conpro);
    return($conpro);
}

1;
