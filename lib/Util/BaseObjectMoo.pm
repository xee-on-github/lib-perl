#-------------------------------------------------------------------------------------------------------------------
# h: lib::Utils::BaseObjectMoo
#-------------------------------------------------------------------------------------------------------------------
# NAME................... BaseObjectMoo.pm
# CREATION DATE.......... 20150611
# AUTHOR................. ???
#-------------------------------------------------------------------------------------------------------------------
# CHANGE HISTORY
#-------------------------------------------------------------------------------------------------------------------
package lib::Utils::BaseObjectMoo;
use Moo;
use utf8;

#-------------------------------------------------------------------------------------------------------------------
# pkg system
#-------------------------------------------------------------------------------------------------------------------
use Types::Standard qw(Int Str HashRef InstanceOf);
use YAML::XS qw(Load Dump LoadFile DumpFile);
use File::Basename;
use Try::Tiny;
use Log::Tiny;

#-------------------------------------------------------------------------------------------------------------------
# attributes
#-------------------------------------------------------------------------------------------------------------------
has pkg_name     => ( is => 'rw', lazy => 1, default => __PACKAGE__,          isa => Str,                    );
has base_name    => ( is => 'rw', lazy => 1, builder => '_build_base_name',   isa => Str,                    );
has time_start   => ( is => 'ro', lazy => 1, builder => '_build_time_start',  isa => Int,                    );
has config       => ( is => 'rw', lazy => 1, default => sub{ {} },            isa => HashRef,                );
has file_config  => ( is => 'ro', lazy => 1, builder => '_build_file_config', isa => Str,                    );
has file_log     => ( is => 'ro', lazy => 1, builder => '_build_file_log',    isa => Str,                    );
has logger       => ( is => 'rw', lazy => 1, builder => '_build_logger',      isa => InstanceOf['Log::Tiny'] );

#-------------------------------------------------------------------------------------------------------------------
# attributes init values
#-------------------------------------------------------------------------------------------------------------------
sub _build_base_name   { return substr ( __FILE__, 0, -3) . '.yaml' || ''  }
sub _build_time_start  { return time();                                    }
sub _build_file_config { return  'config/' . _build_base_name . '.yaml';   }
sub _build_file_log    { return  'log/'    . _build_base_name . '.log';    }
sub _build_logger      { return  Log::Tiny->new( _build_file_log  );       }

#-------------------------------------------------------------------------------------------------------------------
# constructor
#-------------------------------------------------------------------------------------------------------------------
# f* init_config: return 1 (true) or 0 (false) set reference(hash) but why to call it?
#-------------------------------------------------------------------------------------------------------------------
sub init_config  {
  my $self   = $_[0];
  my $return = 1;

  # exception not read config file and no permission to write
  unless ( -r $self->file_config  || -w $self->file_log )  {
    $self->debug("[initialize_config] I can't read config file (yaml):  " . $self->file_config . "\n$!");
    $self->debug("[initialize_config] I can't write log file:           " . $self->file_log    . "\n$!");
    $return = 0;
  }
  # load config from yaml file or die exception from Moo or perl
  $self->load_config_yaml( $self->file_config );

  return $return;
}

#-------------------------------------------------------------------------------------------------------------------
# public methods
#-------------------------------------------------------------------------------------------------------------------
# f* get_config: no need this method
#---
sub get_config {
  my $self = $_[0];
  return $self->config;
}

#-------------------------------------------------------------------------------------------------------------------
# f* set_config: overwrite hash reference but no need this method
#---
sub set_config {
  my $self   = $_[0];
  my $hash   = $_[1] || '';
  my $return = 1;

  # overwrites all ref(hash) if they exist
  if ( $hash && ref($hash) eq 'HASH' ) {
    $self->config ( $hash );

  # invalid argument input
  } else {
    $self->debug("[set_config] \"hash\" is not a hash is ref/instance of " .ref($hash) . "\n" . "$!" );
    $return = 0;
  }
  return $return;
}

#-------------------------------------------------------------------------------------------------------------------
# f* merge_config: merge keys and values from current config and hash past
#---
sub merge_config {
  my $self = $_[0];
  my $hash = $_[1] || '';
  my $return = 0;

  # create new attributes if they don't exist, don't overwrite exist attributes
  if ( $hash && ref($hash) eq 'HASH' ) {
    foreach my $key (keys %{$hash}) {
      $self->config->{$key} = $hash->{$key} unless ( defined $self->config->{$key});
    }
    $return = 1;
  }

  return $return;
}

#-------------------------------------------------------------------------------------------------------------------
# f* load_config_yaml: return hash reference from content of yaml file
#---
sub load_config_yaml {
  my $self   = $_[0];
  my $file   = $_[1] || '';
  my $config;

  # invalid argument input
  return {} if $file eq '';

  try {
    $config = LoadFile($file);
  } catch {
    $self->debug( "[load_config_yaml] Exception Catch on read $file\n$!" );
  };

  return $config;
}

#-------------------------------------------------------------------------------------------------------------------
# f* set_serialize_file: write hash reference into yaml file
#---
sub set_serialize_file {
  my $self = $_[0];
  my $file = $_[1] || '';
  my $data = $_[2] || {};
  my $return  = 1;

  # try to do it
  try {
    DumpFile($file, $data);
  } catch {
    $return = 0;
    $self->debug( '[' . $self->pkg_name . "][set_serialize_file] Exception. Catch\n$!\n@_\n" );
  };

  return $return;
}

#-------------------------------------------------------------------------------------------------------------------
# f* get_serialize_file: return ref(hash) or empty ref(hash). try to return a yaml file in a reference(hash)
#---
sub get_serialize_file {
  my $self = $_[0];
  my $file = $_[1] || '';

  if ( $file eq '' || ! -r $file  ) {
    $self->stderr("[get_serialize_file] - I can't read file: " . $file . "\nException: $!" );
    return {};
  }
  return $self->load_config_yaml( $file );
}


#-------------------------------------------------------------------------------------------------------------------
# f* call_exception:
#---
sub call_exception  {
  my $self = $_[0];
  my $msg  = $_[1] || '';

  return 0 if  $msg eq '' ;

  # show message stdout and log file
  $self->debug( '[call_exception]' . $msg );

  # show message stderr
  warn '[call_exception] '.  $msg ."\n";

  # finish execution with die
  die '[call_exception] ' . $msg ."\n";
}


#-------------------------------------------------------------------------------------------------------------------
# f* debug: append msg in log file and standard output
#---
sub debug {
  my $self = $_[0];
  my $msg  = $_[1] || '';

  return 0 if $msg eq '';

  # write message into log file
  $self->logger->DEBUG( '[' . $self->pkg_name . ']' . $msg );

  # write message into stdout
  print '[' . $self->pkg_name . ']' . $msg ."\n";

  return 1;
}

#-------------------------------------------------------------------------------------------------------------------
# f* stderr: it's equal warn?? :-|
#---
sub stderr {
  my $self = $_[0];
  my $msg  = $_[1] || '';

  return 0 if $msg eq '';

  warn '[' . $self->pkg_name . ']' . $msg  if $msg ne '';
  return 1;
}



#-------------------------------------------------------------------------------------------------------------------
# end
1;
