
# lib-perl

## Simple libraries

### lib/Util/BaseObjectMoo.pm

The purpose of this library is to simplify the reading of YAML configuration files and the writing of a log.


### Classic structure of main script and directories

```
script.pl
│
└─config
│   script.yaml
│   
└─log
│   script.log
```

### Requeriments
Moo 
Types::Standard 
YAML::XS 
File::Basename 
Try::Tiny 
Log::Tiny

`cpanm Types::Standard YAML::XS File::Basename Try::Tiny Log::Tiny`


