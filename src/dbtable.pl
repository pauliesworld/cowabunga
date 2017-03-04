#!/usr/local/bin/perl

# COWAbunga -
# File: dbtable.pl
# Conference on World Affairs Scheduler
#   Add and delete objects from the text database
#   Implements locking with the FLOCK perl function
# Status: STABLE

sub addTableObject()
{
    # Append just ONE table object to the given file

    ($entry,$file)=@_;

    sysopen(OUT,$file,O_WRONLY|O_APPEND);
    if(flock(OUT, LOCK_EX)==0)
    {
        printf("A locked state has prevented the database committment");
    }

    else
    {
        print OUT "$entry\n";
        close(OUT);
    }
}

sub addTableObjects()
{
    # Append many objects to a table, useful for adding all conflicts
    # attached to a panel at the same time

    ($entry,$file)=@_;
    @contents=@$entry;

    sysopen(OUT,$file,O_WRONLY|O_APPEND);
    if(flock(OUT, LOCK_EX)==0)
    {
        printf("A locked state has prevented the database committment");
    }
    
    else
    {
        print OUT @contents;
        close(OUT);
    }
}

sub deleteTableObject()
{
    # Delete one object from a table

    ($con,$file)=@_;
    @contents=@$con;

    sysopen(OUT,$file,O_WRONLY|O_TRUNC);
    if(flock(OUT, LOCK_EX)==0)
    {
        printf("A locked state has prevented the database committment");
    }
    
    else
    {
        print OUT @contents;
        close(OUT);
    }
}

1;
