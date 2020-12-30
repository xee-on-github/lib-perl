#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use utf8;

#----------------------------------------------------------------------------------------------------------
# lib
#----------------------------------------------------------------------------------------------------------
use FindBin;
use lib "$FindBin::Bin/";
# use lib './';

#----------------------------------------------------------------------------------------------------------
# pkg local
#----------------------------------------------------------------------------------------------------------
use lib::Util::UtilClass;

#----------------------------------------------------------------------------------------------------------
# pkg system
#----------------------------------------------------------------------------------------------------------
use Getopt::Long qw(GetOptions);

#----------------------------------------------------------------------------------------------------------
# MAIN
#----------------------------------------------------------------------------------------------------------

# var
my ( $class, $attribut, $parent_dir, $class_default ) = ( '', '', '', 0 );

# read argument
GetOptions(
  'class=s'         => \$class,
  'attributes=s'    => \$attribut,
  'parent_dir=i'    => \$parent_dir,
  'class_default=i' => \$class_default,
);

# error class name is empty
&msg_error( 'parameter is missing' ) if $class eq '';


# call main test
my $pkg_class_util = lib::Util::UtilClass->new (
  class         => $class,
  attribut      => $attribut,
  parent_dir    => $parent_dir,
  class_default => $class_default
)->do_make;




#----------------------------------------------------------------------------------------------------------
# SUBS
#-------------------------------------------------------------------------------------------------------------------
# f* msg_error
#---
sub msg_error {
  my $msg = $_[0] || '';
  say "perl $0 --class <class_name> --attributes [<attrib_01:type:init_value>] --method [<method_01:arg_0:arg_01:arg_n>] --class_default <1|0>
  \nor\n./$0 --class <class_name> --attributes [<attrib_01:type:init_value>] --method [<method_01:arg_0:arg_01:arg_n>] --class_default <1|0>";

  say " *INFO* $msg" if $msg ne '';
  exit;
}
