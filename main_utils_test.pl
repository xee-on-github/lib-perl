#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use utf8;

# pkg system
#----------------------------------------------------------------------------------------------------------
use Getopt::Long qw(GetOptions);

# lib
#----------------------------------------------------------------------------------------------------------
use lib './';

#----------------------------------------------------------------------------------------------------------
# MAIN
#----------------------------------------------------------------------------------------------------------

# var
my ( $class_or_package_test, $class_or_package ) = ( '', '' );

# read argument
GetOptions( 'class_or_package_test=s'   => \$class_or_package_test );

# parameter is missing
&msg_error( 'parameter is missing' ) if $class_or_package_test eq '';
 
# no class or package exists
$class_or_package = 'lib/Test/' . $class_or_package_test . '.pm';
&msg_error( "no class or package exists on: $class_or_package" ) unless -r $class_or_package;

# call main test
say "call main test";



#----------------------------------------------------------------------------------------------------------
# SUBS
#-------------------------------------------------------------------------------------------------------------------
# f* msg_error
#--- 
sub msg_error {
  my $msg = $_[0] || '';
  say "perl $0 --class_or_package_test <BaseObject>\nor\n./$0 --class_or_package_test <BaseObject>";
  say " *INFO* $msg" if $msg ne '';
  exit;  
}
