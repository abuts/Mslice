#!/usr/bin/perl -w
###############################################################################
use strict;
###############################################################################
#
# script is used to update the field-value pairs in mslice msp text files and homer instrument settings txt files
# despite the same name, there is difference in the $val_framing value, which makes mslice msp and homer set-up files different
# 
# should be run from Matlab but can be used as stand-alone application
# 
if ($#ARGV < 2 || $#ARGV % 2){
  print "\n\n Usage: set_key_value file_to_modify key value [key value ... ]  \n\n";
  print " Script called with ",$#ARGV+1, " arguments; Number of arguments has to be odd and bigger than 2 \n";  
  exit 1;
};

my %rep_keys;
my $file=$ARGV[0];
my $i;
for($i=1; $i<$#ARGV;$i+=2){
	$rep_keys{$ARGV[$i]} = $ARGV[$i+1];
}

my $pair_separator='=';  # the separator dividing value from the key
my $val_framing   =' ';  # the framing aroung value (can be empty)


set_values($file,$pair_separator,$val_framing,%rep_keys);

exit(0);
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
###############################################################################
sub replace_value{   #12/24/09 1:25:PM
###############################################################################
# replace walue corresponding to the key, in the input string $data
# The $data is formatted according to the Tortose SVN rules. 
    my($key,$value,$pairs_separator,$val_framing,$data)=@_;
    my @tmp=split(/\$/,$data);
    my($i,@buf, $is_chomped);
    
    for($i=0;$i<=$#tmp;$i++){
        my @pair = split(/$pairs_separator/,$tmp[$i]);
        
        if($#pair==0){    next;  # no key-walue pairs, key is empty  
        }

        if($pair[0] =~ m/$key/){  # extract key
            $is_chomped = chomp($pair[1]);
            if($val_framing eq ''){                
                $pair[1]=$value;
            }else{   # we expect value to have $val_framing around it
                $pair[1] =~s/^$val_framing//;
                $pair[1] =~s/$val_framing$//;                
                $pair[1]=$val_framing.$value.$val_framing;
            }
            if($is_chomped){
                    $pair[1]=$pair[1]."$/";
            }
            
            $tmp[$i]=join($pairs_separator,@pair);
            last;
        }
    }
    $data=join('$',@tmp);
    
    return $data;
}
###############################################################################
sub set_values{   #12/24/09 1:25:PM
# read the file and replace the values from the file corresponding to the keys,
# specified in the imput hash, by the values corresponding to the hash values
###############################################################################
    my($out_file,$separator,$val_framing,%rep_keys)=@_;
	$out_file =~ s/\\/\//g;
	my $ind_loc = rindex($out_file,'/');
	my $path;
	if($ind_loc>0){
		$path = substr($out_file,0,$ind_loc+1);
	}else{
		$path = '';
	}
	print $path;
    my($wk_file)=$path."tmp.dat";
	print $wk_file,"\n";
    my($data,$rd,$the_key,$the_value,$i);
    my (@kk) = keys(%rep_keys);
    
    open(OUTDATA,">$wk_file") || die " can not open temporary file $wk_file for keys replacet\n";
    open(INDATA,$out_file)    || die " can not open target file $out_file\n";
    
    while($data=<INDATA>){
        for($i=0;$i<=$#kk;$i++){
            $the_key=$kk[$i];
            if($data=~m/$the_key/){
                $the_value=$rep_keys{$the_key};
                $data=replace_value($the_key,$the_value,$separator,$val_framing,$data);
            }
        }
        print OUTDATA $data;
    }
    close(OUTDATA);
    close(INDATA);
    unlink($out_file) || die " can not delete $out_file, The replacement file $wk_file created successfully and you should rename it to ",$out_file," manually\n";
    rename($wk_file,$out_file) || die " can not rename temporary file $wk_file to a target file $out_file";
}
