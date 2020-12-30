#--------------------------------------------------------------------------------------------------------------------------
# h: lib::Util::UtilsClass
#--------------------------------------------------------------------------------------------------------------------------
package lib::Util::UtilClass;

#--------------------------------------------------------------------------------------------------------------------------
# pkg system
#--------------------------------------------------------------------------------------------------------------------------
use Moo;

#--------------------------------------------------------------------------------------------------------------------------
# pkg system
#--------------------------------------------------------------------------------------------------------------------------
use Text::Xslate qw(mark_raw);
use Types::Standard qw(Str InstanceOf HashRef Int);
use Data::Dumper;
use utf8;

#--------------------------------------------------------------------------------------------------------------------------
# pkg local
#--------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------
# attributes
#--------------------------------------------------------------------------------------------------------------------------
has pkg_name      => ( is => 'ro', lazy => 1, default => __PACKAGE__,                      isa => Str     );
has base_name     => ( is => 'ro', lazy => 1, default => __FILE__,                         isa => Str     );
has data          => ( is => 'rw', lazy => 1, default => sub{ {} },                        isa => HashRef );
has class         => ( is => 'rw', lazy => 1, default => '',                               isa => Str     );
has attribut      => ( is => 'rw', lazy => 1, default => '',                               isa => Str     );
has parent_dir    => ( is => 'rw', lazy => 1, default => '',                               isa => Str     );
has class_default => ( is => 'ro', lazy => 1, default => 0,                                isa => Int     );
has template_file => ( is => 'rw', lazy => 1, default => 'lib/Util/UtilClass.tx',          isa => Str     );
has template      => ( is => 'rw', lazy => 1, default => 'lib/Util/UtilClassDefault.tx',   isa => Str     );




#--------------------------------------------------------------------------------------------------------------------------
# f* default builder
#---
sub BUILD {
  my $self = shift;
  binmode STDOUT, ':utf8';
}

#--------------------------------------------------------------------------------------------------------------------------
# f* do_make builder
#---
sub do_make {
  my $self = shift;
  print "[$0][do_make] - inici\n";

  my $ok_class      = $self->_validate_class;
  my $ok_attribut   = $self->_validate_attributes;
  my $ok_parent_dir = $self->_validate_parent_dir;

  # validate class
  print "class........ ok - " . $ok_class      . " - value: " . $self->class    . "\n";
  print "attribut..... ok - " . $ok_attribut   . " - value: " . $self->attribut . "\n";
  # print "parent_dir... ok - " . $ok_parent_dir . " - value: " . $self->_validate_parent_dir . "\n";

  # do make class or package
  $self->do_make_class_and_attributes if $ok_class and $ok_attribut;


  print "[$0][do_make] - final\n";
}

#--------------------------------------------------------------------------------------------------------------------------
# f* do_make_class_and_attributes:
#---
sub do_make_class_and_attributes  {
  my $self = shift;
  print "[$0][do_make_class_and_attributes] - inici\n";

  die "[$0][do_make_class_and_attributes] I can't open template: " . $self->template_file . "\n" unless -r $self->template_file;

  my $template_out = $self->data->{_class_file_};
  my $tx = Text::Xslate->new( type => 'text', input_layer => ':utf8' );
  my $template_file = ( $self->class_default ) ? $self->template : $self->template_file ;


  print $tx->render( $template_file, $self->data );  
 
  print "[$0][do_make_class_and_attributes] - final\n";
}

#--------------------------------------------------------------------------------------------------------------------------
# f* _validate_class:
#---
sub _validate_class {
  my $self   = shift;
  my $return = 0;

  if ( $self->class =~ /^\w+$/ ) {
    $self->data->{_class_name_} = $self->class( ucfirst($self->class) );
    $return = 1;
  }
  return $return;
}

#--------------------------------------------------------------------------------------------------------------------------
# f* _validate_parent_dir:
#---
sub _validate_parent_dir {
  my $self   = shift;
  my $dir    = 'lib';
  my $return = 1;

  unless ( -d $dir . '/' . $self->parent_dir ) {
    $return = mkdir $dir . '/' . $self->parent_dir;   
    print "[0][_validate_parent_dir] Error when crate a parent_dir: " . $dir . '/' . $self->parent_dir . "\n$!\n" if !$return;
    $self->data->{_class_file_} = $dir . '/' . $self->class . '.pm';
    $self->data->{_class_pkg_}  = $dir . '::' . $self->class;
  } else {
    $self->data->{_class_file_} = $dir . '/'  . $self->parent_dir . '/'  . $self->class . '.pm';
    $self->data->{_class_pkg_}  = $dir . '::' . $self->parent_dir . '::' . $self->class;
  }
  
  return $return;
}

#--------------------------------------------------------------------------------------------------------------------------
# f* _validate_attributes:
#---
sub _validate_attributes {
  my $self = shift;

  return 0 if $self->attribut eq '';

  my ($i, $end, @attributes, $attributes_count ) = ( 0, 1, (), 0);

  @attributes       = split /,/, $self->attribut;
  $attributes_count = @attributes;

  while ( $i < $attributes_count and $end == 1) {

    my @list_attribute = split /:/, $attributes[$i];

    if ( $list_attribute[$i] ne '' ) {
      print "--> " . $list_attribute[2] . "\n";
      # set value to hash
      $self->data->{_list_attributes_}->{$list_attribute[$i]} =  
        { 'name' => $list_attribute[0],
          'type' => $list_attribute[1] || 'Any',
          'init' => $list_attribute[2] || 'undef',
        }
      ;
    } else {
      $end = 0;
    }
    $i++;
  }

  print "[$0][_validate_attributes] Error invalid attribute: name, type or init\n" if !$end;
  return $end;
}


#--------------------------------------------------------------------------------------------------------------------------
# f* demolish:
#---
sub demolish  {
  my $self = shift;
  foreach (values %$self) { $_->DESTROY if ref $_ eq __PACKAGE__; }
  %$self = ();
}

# end Moo package
#----------------------------------------------------------------------------------------------------------
1;
