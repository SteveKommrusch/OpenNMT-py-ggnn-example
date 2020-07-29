#!/usr/bin/perl
#
use strict;
use warnings;

if ($ARGV[0]) {
  print "Usage: raw2graph.pl\n";
  print "  Transform raw src sequence to graph input structure.\n";
  exit(1);
}

my $maxnodes=0;
while (<>) {
    my @graph;
    my $nodes=0;
    my $lvl;
    my @parents;
    /X (.* )Y (.*)$/ || die "Bad syntax on input $_";
    my $prog = $1;
    my $target = $2;
    my $nextissharable=0;
    my $new=0;
    my %name2node;
    my $i;
    my $j;
    my @graphline;

    # Remove binary expressions used extraineously in unary ways from
    # ANTLR code
    my $done=0;
    my $orig=$prog;
    $prog="";
    while ($orig=~s/\s*(\S+)\s+(\S.*)$/$2/) {
      my $tok=$1;
      my $rest=$2;
      if (($tok eq "(" || $tok=~/([a-xz]|equality|unary)(Expression|List)/) && $rest=~s/^\(\s+//) {
        $lvl=1;
        my $tmp="";
        if ($tok eq "(") {
          $tmp="( ";
        }
        while ($rest=~s/^(\S+)\s+//) {
          $i=$1;
          if ($i eq "(") {
            if ($lvl==0) {
              $prog .= "$tok ";
              last;
            } 
            $lvl++;
          } elsif ($i eq ")") {
            if ($lvl==0) {
              # Rest had initial ( removed at start, delete this ) and tok.
              $orig = $tmp.$rest;
              last;
            } 
            $lvl--;
          } elsif ($lvl==0) {
            $prog .= "$tok ";
            last;
          }
          $tmp .= "$i "; 
        }
      } else {
        $prog .= "$tok ";
      }
    }
    $prog.= "$orig";
    $lvl=-1;
      
    # Process remaining nodes into graph structure
    foreach $i (split /\s+/,$prog) {
      if ($i eq "(") {
        $lvl++;
        $new=1;
        $nextissharable=0;
      } elsif ($i eq ")") {
        $lvl--;
        $nextissharable=0;
      } else {
        # Handle potentially out-of-vocab nodes which are sharable
        # This code allows multiple uses of a variable to point to the
        # same node to ease GGNN interpretation
        my $node=$nodes++;
        if ($new) {
          $new=0;
          $parents[$lvl]=$node;
          if ($i eq "primaryExpression" || $i eq "directDeclarator") {
            $nextissharable=1;
          }
          if ($lvl > 0) {
            $graph[$parents[$lvl-1]] .= "$node ";
          }
        } else {
          if ($nextissharable) {
            if ($name2node{$i}) {
              $node = $name2node{$i};
              $nodes--;
            } else {
              $name2node{$i} = $node;
            }
            $nextissharable=0;
          }
          $graph[$parents[$lvl]] .= "$node ";
        }
        $graph[$node] = "$i ";
      }
    }
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      print "$graphline[0] ";
    }
    print "<EOT> ";
    # 104 should match the vocab size limit used in setupgraph2seq.sh
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      # Use feature flags to indicate how many edges exist from node
      # This may be helpful as we use different edge types for fanout info too
      if (@graphline == 1) {
        print "100 ";
      } elsif (@graphline == 2) {
        print "101 ";
      } elsif (@graphline == 3) {
        print "102 ";
      } else {
        print "103 ";
      }
    }
    # 104 flags aggregation node
    print "104 <EOT> ";
    # Edge 0 goes from aggregating node to all others
    for ($i=0; $i < $nodes; $i++) {
      print "$nodes $i ";
    }
    print ", ";
    # Edge 1 goes from node to unary child
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      if (@graphline == 2) {
        print "$i $graphline[1] ";
      } 
    }
    print ", ";
    # Edge 2 goes from node to first binary child
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      if (@graphline == 3) {
        print "$i $graphline[1] ";
      } 
    }
    print ", ";
    # Edge 3 goes from node to second binary child
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      if (@graphline == 3) {
        print "$i $graphline[2] ";
      } 
    }
    print ", ";
    # Edge 4 goes from node to first child
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      if (@graphline > 3) {
        print "$i $graphline[1] ";
      } 
    }
    print ", ";
    # Edge 5 goes from node to second child
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      if (@graphline > 3) {
        print "$i $graphline[2] ";
      } 
    }
    print ", ";
    # Edge 6 goes from node to third and later children
    for ($i=0; $i < $nodes; $i++) {
      @graphline=(split / /,$graph[$i]);
      if (@graphline > 3) {
        for ($j = 3; $j < @graphline; $j++) {
          print "$i $graphline[$j] ";
        } 
      } 
    }

    # Print out original X, Y info so this output has complete sample data
    print "X ${prog}Y $target\n";

    if ($nodes > $maxnodes) {
      $maxnodes=$nodes;
    }
}
warn "Note: Maximum nodes used: $maxnodes";
