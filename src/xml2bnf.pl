#!/usr/bin/perl -w
use strict;
use XML::XPath;
use Math::Round;
use Tk 804;
require Tk::NumEntry;
require Tk::ROText;
use File::Temp ();
use File::Temp qw/ :seekable /;
use overload 'eq' => '==';
require File::Temp;

my $fh = File::Temp->new();
my $fname = $fh->filename;
$fh = File::Temp->new(TEMPLATE => my $template);
$fname = $fh->filename;
my $tmp = File::Temp->new( UNLINK => 0, SUFFIX => '.xml' );

#GLOBALS Start 

my $tl;

my @types;

my $_WDiv = '7'; # Node Width Divisor

my $_HtDiv = '10.5';  # Node Height Divisor

my $_ListHtDiv = '21'; # List Height Divisor	

my $_LeftDiv = '7'; # Node Left Divisor		This seems to work fine for the X Direction

my $_TopDiv = '10.5'; # Node Top Divisor		This seems to work fine for the Y Direction

my $_XMLFName = 'input.xml';

my $_ILFName = 'output.il';

my $_EnFlex = '1';


my @Parent;
my @Ptype;
my @GParent;
my $expr;
my @field;
my $N_Left = "./properties/property[\@name=\"Left\"]";
my $N_Top =  "./properties/property[\@name=\"Top\"]" ;
my $N_Width =  "./properties/property[\@name=\"Width\"]";
my $N_Height =  "./properties/property[\@name=\"Height\"]";
my $N_Caption =  "./properties/property[\@name=\"Caption\"]";
my $N_Text = "./properties/property[\@name=\"Text\"]";
my $N_List = "./properties/property[\@name=\"Items.Strings\"]/list/li";
my $N_MaxLength = "./properties/property[\@name=\"MaxLength\"]";
my $N_Columns = "count(./properties/property[\@name =\"Columns\"]/collection/item)";

my $P_Left = "../../../../properties/property[\@name=\"Left\"]" ;
my $P_Top = "../../../../properties/property[\@name=\"Top\"]" ;

my $G_Left = "../../properties/property[\@name=\"Left\"]";
my $G_Top = "../../properties/property[\@name=\"Top\"]";
my $G_Caption = "../../properties/property[\@name=\"Caption\"]";

my $R_Left = "../../../../../../properties/property[\@name=\"Left\"]" ;
my $R_Top = "../../../../../../properties/property[\@name=\"Top\"]" ;

#Globals End	


#############################################################
########################## Start GUI ########################
#############################################################


my (
     # MainWindow
     $MW,
	 # Hash of all widgets
     %ZWIDGETS,
    );
######################
#
# Create the MainWindow
#
######################

$MW = MainWindow->new;


#$mw->title('Dialog');	
$MW->title('XML to BNF Converter v1.0');


#Declare that there is a menu
my $mbar = $MW -> Menu();
$MW -> configure(-menu => $mbar);

#The Main Buttons
my $file = $mbar -> cascade(-label=>"File", -underline=>0, -tearoff => 0);
my $about = $mbar -> cascade(-label =>"About", -underline=>0, -tearoff => 0);

## File Menu ##

$file -> command(-label =>"Help", -underline => 0,
		-command => [\&menuClicked]);
$file -> separator();
$file -> command(-label =>"Exit", -underline => 1,
		-command => sub { exit } );

		
## Help ##
$about -> command(-label =>"About", -command => sub { 
	$MW -> messageBox(-type=>"ok", -message=>"About
----------
This script was created to convert KODA xml form to Cadence SKILL Script.
Made by Venkata Ramanan
Sunnyvale, CA");
});
	

# Widget Labelframe1 isa Labelframe
$ZWIDGETS{'Labelframe1'} = $MW->Labelframe(
   -padx      => 5,
   -pady      => 5,
   -takefocus => 0,
   -text      => 'Select Files',
  )->grid(
   -row    => 1,
   -column => 1,
   -sticky => 'n',
   -ipadx  => 2,
   -ipady  => 2,
   -padx   => 8,
   -pady   => 5,
   
  );

# Widget Label6 isa Label
$ZWIDGETS{'Label6'} = $ZWIDGETS{Labelframe1}->Label(
   -padx      => 1,
   -pady      => 1,
   -takefocus => 0,
   -text      => 'XML Input:',
  )->grid(
   -row    => 1,
   -column => 1,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Label7 isa Label
$ZWIDGETS{'Label7'} = $ZWIDGETS{Labelframe1}->Label(
   -takefocus => 0,
   -text      => 'Skill Output:',
  )->grid(
   -row    => 2,
   -column => 1,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Entry6 isa Entry
$ZWIDGETS{'Entry6'} = $ZWIDGETS{Labelframe1}->Entry(
   -textvariable => \$_XMLFName,
  )->grid(
   -row    => 1,
   -column => 2,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Entry7 isa Entry
$ZWIDGETS{'Entry7'} = $ZWIDGETS{Labelframe1}->Entry(
   -textvariable => \$_ILFName,
  )->grid(
   -row    => 2,
   -column => 2,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Button1 isa Button
$ZWIDGETS{'Button1'} = $ZWIDGETS{Labelframe1}->Button(
   -command => 'main::_SelXML',
   -text    => 'Browse...',
  )->grid(
   -row    => 1,
   -column => 3,
   -padx   => 2,
   -pady   => 2,
   #-onClick => \&fileDialog,
  
  );

# Widget Button2 isa Button
$ZWIDGETS{'Button2'} = $ZWIDGETS{Labelframe1}->Button(
   -command => 'main::_SelIL',
   -text    => 'Browse...',
  )->grid(
   -row    => 2,
   -column => 3,
   -padx   => 2,
   -pady   => 2,
  
  );


# Widget Labelframe2 isa Labelframe
$ZWIDGETS{'Labelframe2'} = $MW->Labelframe(
   -padx      => 5,
   -pady      => 2,
   -takefocus => 0,
   -text      => 'Settings',
  )->grid(
   -row    => 1,
   -column => 2,
   -sticky => 'n',
   -ipadx  => 2,
   -ipady  => 2,
   -padx   => 8,
   -pady   => 5,
  );

  # Widget Label1 isa Label
$ZWIDGETS{'Labelx'} = $ZWIDGETS{Labelframe2}->Label(
   -justify   => 'right',
   -takefocus => 0,
   -text      => 'Divisor',
  )->grid(
   -row    => 1,
   -column => 2,
   -padx   => 0,
   -pady   => 0,
  );
  
  
  # Widget Label1 isa Label
$ZWIDGETS{'Label1'} = $ZWIDGETS{Labelframe2}->Label(
   -justify   => 'right',
   -takefocus => 0,
   -text      => '                 Left:',
  )->grid(
   -row    => 2,
   -column => 1,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Label2 isa Label
$ZWIDGETS{'Label2'} = $ZWIDGETS{Labelframe2}->Label(
   -takefocus => 0,
   -text      => '                 Top:',
  )->grid(
   -row    => 3,
   -column => 1,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Label3 isa Label
$ZWIDGETS{'Label3'} = $ZWIDGETS{Labelframe2}->Label(
   -takefocus => 0,
   -text      => '              Width:',
  )->grid(
   -row    => 4,
   -column => 1,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Label4 isa Label
$ZWIDGETS{'Label4'} = $ZWIDGETS{Labelframe2}->Label(
   -takefocus => 0,
   -text      => '              Height:',
  )->grid(
   -row    => 5,
   -column => 1,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Label5 isa Label
$ZWIDGETS{'Label5'} = $ZWIDGETS{Labelframe2}->Label(
   -takefocus => 0,
   -text      => 'List/Grid Height:',
  )->grid(
   -row    => 6,
   -column => 1,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Checkbutton1 isa Checkbutton
$ZWIDGETS{'Checkbutton1'} = $ZWIDGETS{Labelframe2}->Checkbutton(
   -indicatoron => 1,
   -justify     => 'right',
   -text        => 'Enable Flex Form',
   -variable    => \$_EnFlex,
  )->grid(
   -row    => 7,
   -column => 1,
  );

# Widget Entry1 isa Entry
$ZWIDGETS{'Entry1'} = $ZWIDGETS{Labelframe2}->NumEntry(
	-minvalue => "5.00",
	-maxvalue => "15.00",
	-incvalue => "0.1",
	-exportselection => 1,
   -justify         => 'right',
   -textvariable    => \$_LeftDiv,
   -width           => 5,
   )->grid(
   -row    => 2,
   -column => 2,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Entry2 isa Entry
$ZWIDGETS{'Entry2'} = $ZWIDGETS{Labelframe2}->NumEntry(
	-minvalue => "5.00",
	-maxvalue => "15.00",
	-incvalue => "0.1",	
   -justify      => 'right',
   -textvariable => \$_TopDiv,
   -width        => 5,
  )->grid(
   -row    => 3,
   -column => 2,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Entry3 isa Entry
$ZWIDGETS{'Entry3'} = $ZWIDGETS{Labelframe2}->NumEntry(
	-minvalue => "5.00",
	-maxvalue => "15.00",
	-incvalue => "0.1",	
   -justify      => 'right',
   -textvariable => \$_WDiv,
   -width        => 5,
  )->grid(
   -row    => 4,
   -column => 2,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Entry4 isa Entry
$ZWIDGETS{'Entry4'} = $ZWIDGETS{Labelframe2}->NumEntry(
	-minvalue => "5.00",
	-maxvalue => "15.00",   
	-incvalue => "0.1",	
   -justify      => 'right',
   -textvariable => \$_HtDiv,
   -width        => 5,
  )->grid(
   -row    => 5,
   -column => 2,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Entry5 isa Entry
$ZWIDGETS{'Entry5'} = $ZWIDGETS{Labelframe2}->NumEntry(
	-minvalue => "5.00",
	-maxvalue => "25.00",
	-incvalue => "0.1",	
   -exportselection => 1,
   -justify         => 'right',
   -textvariable    => \$_ListHtDiv,
   -width           => 5,
  )->grid(
   -row    => 6,
   -column => 2,
   -padx   => 2,
   -pady   => 2,
  );

# Widget Button4 isa Button
$ZWIDGETS{'Button4'} = $MW->Button(
#   -command => $MW => \&exitTheApp;
   -command => 'main::_Exit',
   -text    => 'Cancel',
  )->grid(
   -row    => 3,
   -column => 2,
  );

# Widget Button3 isa Button
$ZWIDGETS{'Button3'} = $MW->Button(
   -command => 'main::_do_xml2bnf',
   -text    => 'Convert',
  )->grid(
   -row    => 3,
   -column => 1,
   -pady   => 5,
  );
###############
#
# MainLoop
#
###############

MainLoop;

#############################################################
########################### END GUI #########################
#############################################################


#######################
#
# Subroutines
#
#######################

sub CreateTmpXML{
open my $in,  '<',  $_XMLFName       or die "Can't read old file: $!";
open my $out, '>', $tmp or die "Can't write new file: $!";

	while( <$in> )   # print the lines before the change
		{
	        if ($. == 1){
	        print $out "<?xml version=\"1.0\" ?>"."\n";
	        }else{
	            print $out $_;
	        }
		}
        close $out;
        close $in;


}


sub formInitialize{
		foreach my $property ($_[0]->find('//object[@type="TTabSheet"]')->get_nodelist) {
			my $temp = $property->find('./@name');
			push(@Parent, $temp);
		}
		foreach my $property ($_[0]->find('/object[@type="TAForm"]/components/object')->get_nodelist){
			my $temp = $property->find('./@type');
			push(@Ptype, $temp);
		}
		foreach my $property ($_[0]->find('/object[@type="TAForm"]/components/object[@type="TAGroup"]')->get_nodelist){
			my $temp = $property->find('./@name');
			push(@GParent, $temp);
		}
	}

sub MainFormFunction{
	print Form_IL_Write "/*Created by xml2bnf  perl utility\n" ;
	print Form_IL_Write "Coded by Venkata Ramanan/Sant Clara, CA\n" ;
	print Form_IL_Write "Version History*/"."\n\n" ;
	print Form_IL_Write " ; WARRANTY:\n";
	print Form_IL_Write " ; NONE. NONE. NONE.\n";

	print Form_IL_Write "(defun my_form ()\n";
	print Form_IL_Write "\t\t\ttime = getCurrentTime()\n";
	print Form_IL_Write "\t\t\ttime = parseString(time)\n";
	print Form_IL_Write "\t\t\tday = nth(1 time)\n";
	print Form_IL_Write "\t\t\tmonth = car(time)\n";
	print Form_IL_Write "\t\t\tmonth = upperCase(month)\n";
	print Form_IL_Write "\t\t\tyear = nth(3 time)\n";
	print Form_IL_Write "\t\t\tdate = strcat(\" Date: \" day \" \" month \" \" year)\n";

	print Form_IL_Write "\t\t\t CreateForm()\n";
	print Form_IL_Write "\t\t\tmyform=axlFormCreate( (gensym) form_file nil 'Form_Action t)\n";
	print Form_IL_Write "\t\t\taxlFormDisplay(myform)\n";
	print Form_IL_Write "\t\t\taxlUIWPrint(myform date)\n\n";
	
		
		
		foreach my $property ($_[0]->find('//object[@type="TAListView"]')->get_nodelist) {
				my $col_count = int($property->find($N_Columns));
			if ($col_count != 0){
				my $GridFName = "IntiCols_".$property->find('./@name')."()";
				print Form_IL_Write "\t\t\t"."IntiCols_".$property->find('./@name')."()"."\n";
				print Form_IL_Write "\t\t\t"."axlFormGridUpdate(myform \"".$property->find('./@name')."\")\n";
			}
		}
	print Form_IL_Write "\t\t)\n\n\n";

}

sub formWrite{
print Form_IL_Write "(defun CreateForm ()"."\n";

#my $formfile = $_ILFName;
my $position = rindex($_ILFName, "/") + 1;
my $formfile = substr($_ILFName, $position);
$formfile =~ s/.il/_form.form/g ;

print Form_IL_Write "drain()\n";
print Form_IL_Write "form_file = \"".$formfile."\"\n";
print Form_IL_Write "myform = outfile(form_file \"w\")\n";
print Form_IL_Write "fprintf(myform \"#Created by xml2bnf  perl utility\\n\")\n" ;
print Form_IL_Write "fprintf(myform \"#Coded by Venkata Ramanan/Santa Clara, CA\\n\\n\")\n" ;
print Form_IL_Write "fprintf(myform \"FILE_TYPE=FORM_DEFN VERSION=2\\n\")\n";
print Form_IL_Write "fprintf(myform \"FORM AUTOGREYTEXT\\n\")"."\n";
print Form_IL_Write "fprintf(myform \"FIXED\\n\")"."\n";
print Form_IL_Write "fprintf(myform \"PORT ";

my $fw = int($_[0]->find('//object[@type="TAForm"]/properties/property[@name="Width"]'));
$fw = ($fw / $_WDiv);
my $fh = int($_[0]->find('//object[@type="TAForm"]/properties/property[@name="Height"]'));
$fh = ($fh / $_HtDiv);

print Form_IL_Write nearest(1, $fw) . " ". nearest(1, $fh) . "\\n\")\n";

print Form_IL_Write "fprintf(myform \"". "HEADER \\\"Form Field Type Demo\\\"\\n\\n\")\n";

print Form_IL_Write "fprintf(myform \"POPUP <ENUM>\\\"ITEM1\\\"\\\"0\\\",\\\"ITEM2\\\"\\\"1\\\",\\\"ITEM3\\\"\\\"2\\\",\\\"LAST ONE\\\"\\\"3\\\".\\n\\n\")"."\n";
	foreach my $property ($_[0]->find('//object[@type="TACombo"]')->get_nodelist) {
		my $PopName = $property->find('./@name')."_List";
		my $N_CList = "count(./properties/property[\@name=\"Items.Strings\"]/list/li)";
		my $lcount = int($property->find($N_CList));
		
		if ($lcount != 0){
			print Form_IL_Write "fprintf(myform \"POPUP <".$PopName.">";
			for(my $i = 0; $i <=$lcount; $i=$i+1 ) {
				my $lexpr = "./properties/property[\@name=\"Items.Strings\"]/list/li[position()=".$i."]";
				my $temp = $property->find($lexpr);
				print Form_IL_Write "\\\"".$temp."\\\"\\\"".$i."\\\"";
				if($i==$lcount){
				print Form_IL_Write ".";
				}else{
				print Form_IL_Write ",";
				}
			}
			print Form_IL_Write "\\n\\n\")"."\n";
		}

	}
print Form_IL_Write "fprintf(myform \"". "TILE\\n\\n\")\n";

# Start FORM Objects Definition

 foreach my $property($_[0]->find('/object[@type="TAForm"]/components/object')->get_nodelist){

	my $type = $property->find('./@type');

	if("$type" eq "TAGroup"){

		$expr = "/object[\@type=\"TAForm\"]/components/object[\@type=\"TAGroup\"]//object";
		my @glist;
		foreach my $property ($_[0]->find($expr)->get_nodelist) {
			my $temp = $property->find('./@name');
			push(@glist, $temp);
		}

	foreach my $GParentName (@GParent) {
		    my $expr3 = "/object[\@type=\"TAForm\"]/components/object[\@name=\"$GParentName\"]//object";
		    my $Gleft = "/object[\@type=\"TAForm\"]/components/object[\@name=\"$GParentName\"]/properties/property[\@name=\"Left\"]";
		    my $Gtop = "/object[\@type=\"TAForm\"]/components/object[\@name=\"$GParentName\"]/properties/property[\@name=\"Top\"]";
		    my $Gwidth = "/object[\@type=\"TAForm\"]/components/object[\@name=\"$GParentName\"]/properties/property[\@name=\"Width\"]";
		    my $Gheight = "/object[\@type=\"TAForm\"]/components/object[\@name=\"$GParentName\"]/properties/property[\@name=\"Height\"]";
		    my $Gcaption = "/object[\@type=\"TAForm\"]/components/object[\@name=\"$GParentName\"]/properties/property[\@name=\"Caption\"]";

			print Form_IL_Write "fprintf(myform \"". "## Group Definition in Form## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "GROUP \\\"" . $_[0]->find($Gcaption) . "\\\"" . "\\n\")\n";


			my $tx = int($_[0]->find(($Gleft)));
			my $ty = int($_[0]->find(($Gtop)));

		    $tx = nearest(1, ($tx / $_LeftDiv));
		    $ty = nearest(1, ($ty / $_TopDiv));

		    print Form_IL_Write "fprintf(myform \"". "GLOC ".$tx." ".$ty."\\n\")\n";

		    my $nw = int($_[0]->find($Gwidth));
		    my $nh = int($_[0]->find($Gheight));
		    $nw = nearest(1, ($nw / $_WDiv));
		    $nh = nearest(1, ($nh / $_HtDiv));

		    print Form_IL_Write "fprintf(myform \"". "FSIZE ".$nw. " ".$nh. "\\n\")\n";
		    print Form_IL_Write "fprintf(myform \"ENDGROUP\\n\\n\")"."\n";			

		foreach my $property ($_[0]->find($expr3)->get_nodelist) {
				my $type = $property->find('./@type');
			if ("$type" eq "TAInput") {
				print Form_IL_Write "fprintf(myform \"". "## Input Field in Group## \\n\")\n";
				print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
				&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
				&printFSIZE($property);

			}
			elsif ("$type" eq "TAButton") {
					print Form_IL_Write "fprintf(myform \"". "## Button Field in Group## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
					&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
					&printFSIZE($property);

			}
			elsif ("$type" eq "TAList") {
					print Form_IL_Write "fprintf(myform \"". "## LIST Field in Group## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
					&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
					&printFSIZE($property);

			}
			elsif ("$type" eq "TALabel") {
					print Form_IL_Write "fprintf(myform \"". "## Text Field in Group## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "TEXT " . "\\\"" . $property->find($N_Caption) . "\\\"" . "\\n\")\n";
					&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
					&printFSIZE($property);

			}
			elsif ("$type" eq "TACheckbox") {
					print Form_IL_Write "fprintf(myform \"". "## CheckBox Field in Group## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
					&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
					&printFSIZE($property);
			}
			elsif ("$type" eq "TARadio") {

					print Form_IL_Write "fprintf(myform \"". "## RadioButton Field in Group## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
					&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
					&printFSIZE($property);
			}
			elsif ("$type" eq "TACombo") {
				print Form_IL_Write "fprintf(myform \"". "## ENUM Field in Group## \\n\")\n";
				print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

				&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
				&printFSIZE($property);

			}
			elsif ("$type" eq "TATreeView") {
					print Form_IL_Write "fprintf(myform \"". "## Tree Field in Group## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
					&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
					&printFSIZE($property);
			}
			elsif ("$type" eq "TAListView") {
					print Form_IL_Write "fprintf(myform \"". "## GRID Field in Group## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "GRID " . $property->find('./@name') . "\\n\")\n";

					&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
					&printFSIZE($property);
			}
			elsif("$type" eq "TAProgress") {
				print Form_IL_Write "fprintf(myform \"". "## Progress Field in Group ## \\n\")\n";
				print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

				&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
				&printFSIZE($property);
			}
			elsif("$type" eq "TASlider") {
				print Form_IL_Write "fprintf(myform \"". "## Trackbar Field in Group## \\n\")\n";
				print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

				&printFLOC("GF", $property, $N_Left, $N_Top, $G_Left, $G_Top);
				&printFSIZE($property);
			}

		}

	}
	}
		elsif("$type" eq "TATab"){
			#Start TAB Objects Definition
			print Form_IL_Write "fprintf(myform \"". "## TAB Definition Start## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"TABSET "."\\\"tab\\\""."\\n\")\n";
			print Form_IL_Write "fprintf(myform \"OPTIONS tabsetDispatch\\n\")\n";

			my $expr1;
			my $tval;
			
			$expr1 = "//object[\@name=\"" . $Parent[0] . "\"]/../../properties/property[\@name=\"Left\"]";
			$tval  = nearest(1, (int($_[0]->find($expr1)) / $_LeftDiv));

			print Form_IL_Write "fprintf(myform \"FLOC ".$tval. " ";

			$expr1 = "//object[\@name=\"" . $Parent[0] . "\"]/../../properties/property[\@name=\"Top\"]";
			$tval  = nearest(1, (int($_[0]->find($expr1)) / $_TopDiv));

			print Form_IL_Write $tval. "\\n\")\n";

			$expr1 = "//object[\@name=\"" . $Parent[0] . "\"]/../../properties/property[\@name=\"Width\"]";
			$tval  = nearest(1, (int($_[0]->find($expr1)) / $_WDiv));

			print Form_IL_Write "fprintf(myform \"". "FSIZE " . $tval . " ";
			$expr1 = "//object[\@name=\"" . $Parent[0] . "\"]/../../properties/property[\@name=\"Height\"]";
			$tval  = nearest(1, (int($_[0]->find($expr1)) / $_HtDiv));

			print Form_IL_Write $tval. "\\n\\n\")\n";
			
		foreach my $ParentName (@Parent) {
		$expr = "//object[\@name=\"" . $ParentName . "\"]/.//object";
		my $expr1 = "//object[\@name=\"" . $ParentName . "\"]/properties/property[\@name=\"Caption\"]";
		print Form_IL_Write "fprintf(myform \"TAB \\\"" .$_[0]->find($expr1). "\\\"\\n\\n\")\n";

		foreach my $property ($_[0]->find($expr)->get_nodelist) {
				my $type = $property->find('./@type');

				if ("$type" eq "TAInput") {
					print Form_IL_Write "fprintf(myform \"". "## Input Field TAB## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

					my $type1 = $property->find('../../@type');
					if ("$type1" eq "TTabSheet") {
            			&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
					}
					else{
            			&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
            		}
						&printFSIZE($property);
				}
				elsif ("$type" eq "TAGroup") {
						print Form_IL_Write "fprintf(myform \"". "## Group Definition in TAB## \\n\")\n";
						print Form_IL_Write "fprintf(myform \"". "GROUP \\\"" . $property->find($N_Caption) . "\\\"" . "\\n\")\n";
						&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
						&printFSIZE($property);
					}
				elsif ("$type" eq "TAButton") {
						print Form_IL_Write "fprintf(myform \"". "## Button Field in TAB## \\n\")\n";
						print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

						my $type1 = $property->find('../../@type');

						if ("$type1" eq "TTabSheet") {
							&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
						}
						else {
							&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
						}
							&printFSIZE($property);
					}
				elsif ("$type" eq "TAList") {
							print Form_IL_Write "fprintf(myform \"". "## List Field in TAB## \\n\")\n";
							print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

							my $type1 = $property->find('../../@type');

						if ("$type1" eq "TTabSheet") {
							&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
						}
						else {
							&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
						}
							&printFSIZE($property);
					}
				elsif ("$type" eq "TALabel") {
						print Form_IL_Write "fprintf(myform \"". "## Text Field in TAB## \\n\")\n";
						print Form_IL_Write "fprintf(myform \"". "TEXT " . "\\\"" . $property->find($N_Caption) . "\\\"" . "\\n\")\n";

						my $type1 = $property->find('../../@type');
						if ("$type1" eq "TTabSheet") {
                           	&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
						}
						else {
							&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
						}

							print Form_IL_Write "fprintf(myform \"TGROUP \\\"" . $property->find($G_Caption) . "\\\"\\n\")"."\n";
							print Form_IL_Write "fprintf(myform \"ENDTEXT\\n\\n\")"."\n";
					}
				elsif ("$type" eq "TACheckbox") {
							print Form_IL_Write "fprintf(myform \"". "## CheckBox Field in TAB## \\n\")\n";
							print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

							my $type1 = $property->find('../../@type');
						if ("$type1" eq "TTabSheet") {
							&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
						}
						else {
							&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
						}
							&printFSIZE($property);
				}
				elsif ("$type" eq "TARadio") {
						print Form_IL_Write "fprintf(myform \"". "## RadioButton Field in TAB ## \\n\")\n";
						print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

							my $type1 = $property->find('../../@type');
						if ("$type1" eq "TTabSheet") {
							&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
						}
						else {
							&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
						}
							&printFSIZE($property);
					}
				elsif ("$type" eq "TACombo") {
							print Form_IL_Write "fprintf(myform \"". "## ENUM Field in TAB ## \\n\")\n";
							print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

							my $type1 = $property->find('../../@type');
						if ("$type1" eq "TTabSheet") {

							&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
						}
						else {
							&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
						}
							&printFSIZE($property);
				}
				elsif ("$type" eq "TAListView") {
							print Form_IL_Write "fprintf(myform \"". "## GRID Field in TAB ## \\n\")\n";
							print Form_IL_Write "fprintf(myform \"". "GRID " . $property->find('./@name') . "\\n\")\n";

							my $type1 = $property->find('../../@type');

						if ("$type1" eq "TTabSheet") {
							my $tempp = $property->find('../../properties/property[@name="Caption"]');
							print Form_IL_Write "fprintf(myform \"". "#List Parent is :" . $tempp . "\\n\")\n";
							&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
							}
						else {
							&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
						}
							&printFSIZE($property);

					}
				elsif ("$type" eq "TAProgress") {
					print Form_IL_Write "fprintf(myform \"". "## Progress Field in TAB## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

					my $type1 = $property->find('../../@type');
					if ("$type1" eq "TTabSheet") {
						&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
					}
					else{
						&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
					}
					&printFSIZE($property);
				}
				elsif ("$type" eq "TASlider") {
					print Form_IL_Write "fprintf(myform \"". "## Trackbar Field in TAB## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

					my $type1 = $property->find('../../@type');
					if ("$type1" eq "TTabSheet") {
						&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
					}
					else{
						&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
					}
						&printFSIZE($property);
				}
				elsif ("$type" eq "TATreeView") {
					print Form_IL_Write "fprintf(myform \"". "## TREE Field in TAB## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

					my $type1 = $property->find('../../@type');
					if ("$type1" eq "TTabSheet") {
						&printFLOC("TF", $property,$N_Left,$N_Top,$P_Left,$P_Top);
					}
					else{
						&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top);
					}
						&printFSIZE($property);
				}


			}
			print Form_IL_Write "fprintf(myform \"". "ENDTAB\\n\\n\")\n";
		}

		print Form_IL_Write "fprintf(myform \"". "ENDTABSET\\n\\n\")\n";
		# End TAB Objects Definition
	}
		elsif("$type" eq "TAButton"){

			print Form_IL_Write "fprintf(myform \"". "## Button Field in FORM ## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
			&printFLOC("N", $property, $N_Left, $N_Top);
			&printFSIZE($property);
	}
		elsif ("$type" eq "TAList") {

			print Form_IL_Write "fprintf(myform \"". "## List Field in FORM ## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
			&printFLOC("N", $property, $N_Left, $N_Top);
			&printFSIZE($property);
		}
		elsif ("$type" eq "TAInput") {
			print Form_IL_Write "fprintf(myform \"". "## Input Field in Form## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
			&printFLOC("N", $property, $N_Left, $N_Top);
			&printFSIZE($property);
		}
		elsif ("$type" eq "TALabel") {
			print Form_IL_Write "fprintf(myform \"". "## Text Field in Form## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "TEXT " . "\\\"" . $property->find($N_Caption) . "\\\"" . "\\n\")\n";

			&printFLOC("N", $property, $N_Left, $N_Top);
			print Form_IL_Write "fprintf(myform \"TGROUP \\\"" . $property->find($G_Caption) . "\\\"\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDTEXT\\n\\n\")"."\n";
		}
		elsif ("$type" eq "TACheckbox") {
			print Form_IL_Write "fprintf(myform \"". "## CheckBox Field in Form ## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

			&printFLOC("N", $property, $N_Left, $N_Top);
			&printFSIZE($property);
		}
		elsif ("$type" eq "TARadio") {
			print Form_IL_Write "fprintf(myform \"". "## RadioButton Field in Form## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

			&printFLOC("N", $property, $N_Left, $N_Top);
			&printFSIZE($property);
		}
		elsif ("$type" eq "TACombo") {
			print Form_IL_Write "fprintf(myform \"". "## ENUM Field in Form## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

			&printFLOC("N", $property, $N_Left, $N_Top);
			&printFSIZE($property);
		}
		elsif ("$type" eq "TATreeView") {
					print Form_IL_Write "fprintf(myform \"". "## Treeview Field in Form## \\n\")\n";
					print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";
					&printFLOC("N", $property, $N_Left, $N_Top);
					&printFSIZE($property);
			}
		elsif ("$type" eq "TAListView") {
				print Form_IL_Write "fprintf(myform \"". "## GRID Field in Form## \\n\")\n";
				print Form_IL_Write "fprintf(myform \"". "GRID " . $property->find('./@name') . "\\n\")\n";

				my $type1 = $property->find('../../@type');
				my $tempp = $property->find('../../../../properties/property[@name="Caption"]');

				print Form_IL_Write "fprintf(myform \"". "#Grid Parent is :" . $tempp . "\\n\")\n";

				&printFLOC("N", $property, $N_Left, $N_Top);
				&printFSIZE($property);
		}
		elsif("$type" eq "TAProgress") {
			print Form_IL_Write "fprintf(myform \"". "## Progress Field in Form## \\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

			&printFLOC("N", $property, $N_Left, $N_Top);
			&printFSIZE($property);
		}
		elsif("$type" eq "TASlider") {
				print Form_IL_Write "fprintf(myform \"". "## Trackbar Field in Form## \\n\")\n";
				print Form_IL_Write "fprintf(myform \"". "FIELD " . $property->find('./@name') . "\\n\")\n";

				&printFLOC("N", $property, $N_Left, $N_Top);
				&printFSIZE($property);
			}

	}

#print Form_IL_Write "fprintf(myform \"FLEXMODE edgegravity\\n\\n\")"."\n";
print Form_IL_Write "fprintf(myform \"ENDTILE\\n\\n\")"."\n";
print Form_IL_Write "fprintf(myform \"ENDFORM\\n\\n\")"."\n\n";
print Form_IL_Write "close(myform)\n";
print Form_IL_Write ")"."\n\n\n";
}

sub formAction{
	print Form_IL_Write "(defun Form_Action (myform)\n";
	print Form_IL_Write "(let (t1 item index field cnt)";
	print Form_IL_Write "(printf \"field/value %L = %L (int %L\\n)\" \n";
	print Form_IL_Write "myform->curField myform->curValue, myform->curValueInt )\n";
	print Form_IL_Write "(printf \"doneState %L\\n\" myform->doneState )\n";
	print Form_IL_Write "case(myform->curField\n";
foreach my $property ($_[0]->find('//object')->get_nodelist) {
    my $temp = $property->find('./@type');
    push(@field, $temp);

    if("$temp" eq "TAInput"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;Input Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TAButton"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;Button Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TACheckbox"){
        print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;CheckBox Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TARadio"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;Radio Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TACombo"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;Combo Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TAList"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;List Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TATreeView"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;TreeView Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TASlider"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;Track Bar Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TAProgress"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;Progress Bar Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
	elsif("$temp" eq "TAListView"){
	print Form_IL_Write "\t\t(\"".$property->find('./@name')."\"\n\n";
	print Form_IL_Write "\t\t;Grid Field \n";
	print Form_IL_Write "\t\t;Enter Action Here\n";
	print Form_IL_Write "\t\t\n\t\t)\n";
    }
}

print Form_IL_Write "\t)\n"."\t";
print Form_IL_Write "\t)\n"."\n";
print Form_IL_Write "if((nequal myform->doneState 0)"."\n";
print Form_IL_Write "axlFormClose(myform))"."\n";
print Form_IL_Write ")\n";
}

sub gridFunc{
	foreach my $property ($_[0]->find('//object[@type="TAListView"]')->get_nodelist) {
		my $GridFName ="IntiCols_".$property->find('./@name')."()";
		
		my $colField = $property->find('./@name');
		my $col_count = int($property->find($N_Columns));
		
		if ($col_count != 0){
				#axlFormGridUpdate(fg "grid")
				print Form_IL_Write "procedure(".$GridFName."\n";
				print Form_IL_Write "\t let( (lf p)"."\n";
				print Form_IL_Write "\t lf = myform"."\n";
				print Form_IL_Write "\t p = make_formGridCol()"."\n";
			for(my $i = 0; $i <=$col_count; $i=$i+1 ) {
				my $col_name = "Column_".$i;
				print Form_IL_Write "\t p->fieldType = 'STRING"."\n";
				print Form_IL_Write "\t p->colWidth = ". "12" .""."\n";
				print Form_IL_Write "\t p->align = 'left"."\n";
				print Form_IL_Write "\t p->fieldLength = ". "10" .""."\n";
				print Form_IL_Write "\t p->min = nil"."\n";
				print Form_IL_Write "\t p->max = nil"."\n";
				print Form_IL_Write "\t p->headText = \"".$col_name."\""."\n";
				#print Form_IL_Write "\t p->popup = \"pstring\""."\n";
				print Form_IL_Write "\t axlFormGridInsertCol(lf \"".$colField."\" p)"."\n";
				print Form_IL_Write "\t p->popup = nil"."\n";
				print Form_IL_Write "\n\n";
			}
				print Form_IL_Write "\t ))"."\n";
		}
		
	}

}

sub printFLOC {

    if("$_[0]" eq "GF" ){
	    #&printFLOC("GF", $property,$N_Left,$N_Top,$P_Left,$P_Top,$_[1]);
	    my $tx0 = int($_[1]->find($_[2]));
	    my $tx1 = int($_[1]->find($_[4]));
	    my $tx =  $tx0 + $tx1 ;#+ $tx2 ;#+ $tx3;
	    $tx = nearest(1, ($tx / $_LeftDiv));
	    my $ty0 = int($_[1]->find($_[3]));
	    my $ty1 = int($_[1]->find($_[5]));
	    my $ty =  $ty0 + $ty1 ;#+ $ty2;# + $ty3;
	    $ty = nearest(1, ($ty / $_TopDiv));
	    print Form_IL_Write "fprintf(myform \"". "FLOC " . $tx . " " . $ty . "\\n\")\n";
    }
     elsif("$_[0]" eq "TF" ){
	    my $tx0 = int($_[1]->find($_[2]));
	    my $tx1 = int($_[1]->find($_[4])) - 10;
	    my $tx =  $tx0 + $tx1 ;#+ $tx2 ;#+ $tx3;
	    $tx = nearest(1, ($tx / $_LeftDiv));
	    my $ty0 = int($_[1]->find($_[3]));
	    my $ty1 = int($_[1]->find($_[5]));
	    my $ty =  $ty0 + $ty1 ;#+ $ty2;# + $ty3;
	    $ty = nearest(1, ($ty / $_TopDiv));
	    print Form_IL_Write "fprintf(myform \"". "FLOC " . $tx . " " . $ty . "\\n\")\n";
    }
    elsif("$_[0]" eq "TGF"){
	    #&printFLOC("TGF",$property,$N_Left,$N_Top,$G_Left,$G_Top,$R_Left,$R_Top,$_[1]);
	    my $tx0 = int($_[1]->find($_[2]));
	    my $tx1 = int($_[1]->find($_[4]));
	    my $tx2 = int($_[1]->find($_[6]));
	    my $tx =  $tx0 + $tx1 + $tx2 ;#+ $tx3;
	    $tx = nearest(1, ($tx / $_LeftDiv));
	    my $ty0 = int($_[1]->find($_[3]));
	    my $ty1 = int($_[1]->find($_[5]));
	    my $ty2 = int($_[1]->find($_[7]));

	    my $ty =  $ty0 + $ty1 + $ty2;# + $ty3;
	    $ty = nearest(1, ($ty / $_TopDiv));
	    print Form_IL_Write "fprintf(myform \"". "FLOC " . $tx . " " . $ty . "\\n\")\n";
    }
    elsif("$_[0]" eq "N" ){
	    #&printFLOC("N", $xp, $Gleft, $Gtop,$_[1]);
	    my $tx = int($_[1]->find($_[2]));
	    $tx = nearest(1, ($tx / $_LeftDiv));
	    my $ty = int($_[1]->find($_[3]));
	    $ty = nearest(1, ($ty / $_TopDiv));
	    print Form_IL_Write "fprintf(myform \"". "FLOC " . $tx . " " . $ty . "\\n\")\n";
    }

}

sub printFSIZE {
		my $temp = $_[0]->find('./@type');
		if("$temp" eq "TAInput" ){

			my $twidth = $_[0]->find('./properties/property[@name="MaxLength"]');
			my $nw = int($_[0]->find($N_Width));
			$nw = nearest(1, ($nw / ($_WDiv+1)));
			my $nh = int($_[0]->find($N_Height)) ;
			$nh = nearest(1, ($nh / $_HtDiv));
			print Form_IL_Write "fprintf(myform \"". "FSIZE " . $nw . " " . $nh . "\\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "STRFILLIN " . $nw . " 50\\n\")\n";
		    print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\""."\\n\")"."\n";
		    print Form_IL_Write "fprintf(myform \"". "VALUE \\\"" . $_[0]->find($N_Text) . "\\\""."\\n\")"."\n";
		    print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\\n\")"."\n";
		}
		elsif("$temp" eq "TAButton"){
		    #&printFSIZE($property);
		    print Form_IL_Write "fprintf(myform \"". "MENUBUTTON \\\"". $_[0]->find($N_Caption) . "\\\" ";

		    my $nw = int($_[0]->find($N_Width));
		    $nw = nearest(1, ($nw / $_WDiv));
		    print Form_IL_Write $nw;

		    print Form_IL_Write " ";
		    my $nh = int($_[0]->find($N_Height)) ;
		    $nh = nearest(1, ($nh / $_HtDiv));
		    print Form_IL_Write ($nh+1);

		    print Form_IL_Write "\\n\")\n";
		    print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\"\\n\")"."\n";
		    print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\")"."\n";
		}
		elsif("$temp" eq "TAList"){
		    print Form_IL_Write "fprintf(myform \"". "LIST \\\" \\\" ";

		    my $nw = int($_[0]->find($N_Width)) ;
		    $nw = nearest(1, ($nw / $_WDiv));
		    print Form_IL_Write $nw;

		    print Form_IL_Write " ";
		    my $nh = int($_[0]->find($N_Height));
		    $nh = nearest(1, ($nh / $_ListHtDiv ));
		    print Form_IL_Write $nh;

		    print Form_IL_Write "\\n\")\n";
		    print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\"\\n\")"."\n";
		    print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\")"."\n";
		}
		elsif("$temp" eq "TALabel"){
		    print Form_IL_Write "fprintf(myform \"TGROUP \\\"".$_[0]->find($G_Caption)."\\\"\\n\")"."\n";
		    print Form_IL_Write "fprintf(myform \"ENDTEXT\\n\\n\")"."\n";
		}
  		elsif("$temp" eq "TACheckbox"){
		    print Form_IL_Write "fprintf(myform \"". "CHECKLIST " . "\\\"" . $_[0]->find($N_Caption) . "\\\"" . "\\n\")\n";
            print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\"\\n\")"."\n";
            print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\")"."\n";
		}
		elsif("$temp" eq "TARadio"){
			print Form_IL_Write "fprintf(myform \"". "CHECKLIST " . "\\\"" . $_[0]->find($N_Caption) . "\\\"  \\\"rg\\\"" . "\\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\""."\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\")"."\n";
		}
		elsif("$temp" eq "TACombo"){
			print Form_IL_Write "fprintf(myform \"". "STRFILLIN ";
			my $nw = int($_[0]->find($N_Width));
			$nw = nearest(1, ($nw / ($_WDiv+3)));
			print Form_IL_Write int($nw);
			print Form_IL_Write " 50\\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\"\\n\")"."\n";

			my $PopName = $_[0]->find('./@name')."_List";
			my $N_CList = "count(./properties/property[\@name=\"Items.Strings\"]/list/li)";
			my $lcount = int($_[0]->find($N_CList));
			
			if ($lcount != 0){
			print Form_IL_Write "fprintf(myform \"POP \\\"".$PopName."\\\"\\n\") "."\n" ;
			}else{
			print Form_IL_Write "fprintf(myform \"POP \\\"ENUM\\\"\\n\") "."\n" ;
			}
			print Form_IL_Write "fprintf(myform \"". "OPTIONS multiselect prettyprint\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"". "ENDFIELD\\n\\n\")"."\n";
		}
		elsif("$temp" eq "TATreeView"){
			print Form_IL_Write "fprintf(myform \"". "TREEVIEW ";

			my $nw = int($_[0]->find($N_Width)) ;
			$nw = nearest(1, ($nw / $_WDiv));
			print Form_IL_Write $nw;

			print Form_IL_Write " ";
			my $nh = int($_[0]->find($N_Height));
			$nh = nearest(1, ($nh / $_ListHtDiv ));
			print Form_IL_Write $nh;
			#print Form_IL_Write nearest(1, ((int($property->find($N_Height)) / 16)));
			print Form_IL_Write "\\n\")\n";
			#print Form_IL_Write "fprintf(myform \"". "STRFILLIN " . $nw . " 50\\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\"\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\")"."\n";
		}
		elsif("$temp" eq "TAListView"){
			print Form_IL_Write "fprintf(myform \"". "FSIZE ";

			my $nw = int($_[0]->find($N_Width)) ;
			$nw = nearest(1, ($nw / $_WDiv));
			print Form_IL_Write $nw;

			print Form_IL_Write " ";
			my $nh = int($_[0]->find($N_Height));
			$nh = nearest(1, ($nh / $_HtDiv));
			print Form_IL_Write $nh;
			print Form_IL_Write "\\n\")\n";
			#print Form_IL_Write "fprintf(myform \"POP \\\"popname\\\"\\n\")"."\n\n";
			print Form_IL_Write "fprintf(myform \"OPTIONS HLINES VLINES USERSIZE  \\n\\n\")"."\n";

			print Form_IL_Write "fprintf(myform \"GHEAD TOP\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"HEADSIZE 3\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"OPTIONS 3D MULTI\\n\")"."\n";
			#print Form_IL_Write "fprintf(myform \"POP \\\"popname\\\"\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDGHEAD\\n\\n\")"."\n";

			print Form_IL_Write "fprintf(myform \"GHEAD SIDE\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"OPTIONS 3D NUMBER\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"HEADSIZE 5\\n\")"."\n";
			#print Form_IL_Write "fprintf(myform \"POP \\\"popname\\\"\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDGHEAD\\n\\n\")"."\n";

			print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\"\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDGRID \\n\\n\")"."\n";
		}
		elsif("$temp" eq "TAProgress"){
			my $nw = int($_[0]->find($N_Width)) ;
			$nw = nearest(1, ($nw / $_WDiv));
			my $nh = int($_[0]->find($N_Height));
			$nh = nearest(1, ($nh / $_HtDiv));
			print Form_IL_Write "fprintf(myform \"". "PROGRESS " . $nw . " ".int($nh + 1)."\\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\""."\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\\n\")"."\n";
		}
		elsif("$temp" eq "TASlider"){
			my $nw = int($_[0]->find($N_Width)) ;
			$nw = nearest(1, ($nw / $_WDiv));
			my $nh = int($_[0]->find($N_Height));
			$nh = nearest(1, ($nh / $_HtDiv));

			print Form_IL_Write "fprintf(myform \"". "TRACKBAR " . $nw . " ".$nh."\\n\")\n";
			print Form_IL_Write "fprintf(myform \"". "FGROUP \\\"" . $_[0]->find($G_Caption) . "\\\""."\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"MIN 0\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"MAX 100\\n\")"."\n";
			print Form_IL_Write "fprintf(myform \"ENDFIELD \\n\\n\\n\")"."\n";
		}
		elsif("$temp" eq "TAGroup"){
		my $nw = int($_[0]->find($N_Width));
			my $nh = int($_[0]->find($N_Height));
			$nw = nearest(1, ($nw / $_WDiv));
			$nh = nearest(1, ($nh / $_HtDiv));
			print Form_IL_Write "fprintf(myform \"". "FSIZE ".$nw. " ".$nh. "\\n\")\n";
			print Form_IL_Write "fprintf(myform \"ENDGROUP\\n\\n\")"."\n";
		}
}


sub _Exit {

#$MW -> messageBox(-type=>"ok", -message=>"FIle name is $fileName\n");

exit
}

sub _SelIL {
 my $w = shift;
    my $ent = shift;
    my $operation = shift;
    my $types;
    my $file;
    @types =
      (["SKILL files",           [qw/.il/]],
       ["All files",		'*']
      );
   
	$file = $MW->getSaveFile(-filetypes => \@types);
   
     if (defined $file and $file ne '') {
	 $_ILFName = $file;
     }
}

sub _SelXML {
 my $w = shift;
    my $ent = shift;
    my $operation = shift;
    my $types;
    my $file;
   
    @types =
      (["XML files",           [qw/.xml .kxf/]],
       ["All files",		'*']
      );
   
	$file = $MW->getOpenFile(-filetypes => \@types);
   
     if (defined $file and $file ne '') {
	 $_XMLFName = $file;
     }
}

sub menuClicked {
	
  if (! Exists($tl)) {
    $tl = $MW->Toplevel;
    $tl->title('Help');
my $txt = $tl->Scrolled('ROText',
				-width => '110',
				-exportselection => 1,
				-font => 'Calibri_11_normal_roman_',
				-scrollbars => 'osoe',
				);


$txt -> grid(-row=>1,
	     -column=>1,
	     )->pack;
$txt->insert('end',"

XML 2 BNF Converter Utility

	Table of Contents
	
1. What is xml2bnf utility?
2. Why do I need it?
3. What is the Rationa?
4. How do I create forms with KODA Form designer?
5. What should I have to run this utility?
6. What are the dependencies?
7. I am not sure how to install Perl is there an easy way out?	
8. Where is the XML file?
9. How do I run the conversion utility?
10. How Do I run the skill program?
11. What are the files generated by the skill file?
12. Can I customize the skill file, if so what are the options?	
13. What are the limitations of xml2bnf utility?
14. What fields are supported?
15. I want that particular feature?
16. Can I customize the length/width/location of the fields?
17. How the original form compares to the Allegro Form?
18. What are the Command line options and what do they mean?
19. What are the future plans?
20. What are the mappings from KODA to Allegro Controls?


FAQ
Q1: What is xml2bnf utility?

	Xml2bnf is a Perl script which will convert a XML file to BNF form file 
	The XML file is created with a tool called KODA Form Designer for Autoit
	
	It is available at
	http://www.autoitscript.com/forum/index.php?showtopic=32299
	or
	http://koda.darkhost.ru/page.php?id=download
	
	Autoit is an automation language for windows and is pretty powerful
	BNF Stands for Backus-Naur Form and is the format understood by Cadence Allegro for its form interface.


Q2:Why do I need it?

	Well if you are familiar with Cadence SKILL language writing user interface forms takes a lot of imagination and hard-coding.
	This tool leverages pre-existing tools to make things simpler

Q3:What is the Rational?

	1. A SKILL programmer might want to look at his/her GUI visually first 
	2. A Visual interface for SKILL programming which Cadence lacks very significantly and has no tools on windows based systems
	3. This utility will churn out 1000 lines of skill code in matter of seconds
	4. With the frame-work already taken care all the programmer has to concentrate on the underlying logic
	5. It will enable more people to try out SKILL programming and write GUI utilities

Q4:How do I create forms with KODA Form designer?

	People familiar with Visual Basic Form designer should have no issues in using this tool
	This is very intuitive and KODA tool has an extensive help section on how to design a form.

Q5: What should I have to run this utility?

	You should have the latest Perl distribution installed; you can get them from the following location
	ActivePerl: http://www.activestate.com/activeperl/
	Strawberry Perl: http://strawberryperl.com/ 

Q6: What are the dependencies?

	You should install the following Perl modules to make this utility 
	XML:;XPATH 
	MATH::Round
	Tk
	Tk::NUmEntry
	File::Temp
	In Case of ActivePerl use PPM and in case of strawberry use Padre to initiate CPAN modules and install 
	the listed requirements

Q7: I am not sure how to install Perl is there an easy way out?
	
	There is a self sustained executable file which has no dependencies and will work standalone 
	This is created using Perl PP utility
	I have made an installation package, just install and use it

Q8: Where is the XML file?

	The KODA Form designer saves its file as *.kxf, which is actually an xml file (windows-1251 encoded)
	
Q9: How do I run the conversion utility?
	1. First create a form using the tool with all the controls/fields you could throw at it
	2. Run the <installed location>\\xml2bnf.exe 
	3. Now Do the following
		>Select the source xml(*.kxf)
		>Specify the output skill name
		>Hit Convert button

Q10: How Do I run the skill program?

	After conversion the utility will save a skill file
	You have to open an allegro design and run the following command
		>skill load \"output.il\"
	Then to view the form you have to run the following command
		>skill my_form


Q11: What are the files generated by the skill file?

	When you run the \"skill my_form\" command the skill code will generate a form file called \"myform.form\" 

Q12: Can I customize the skill file, if so what are the options?

	Yes by looking at the myform.form you can edit the fields and its options
	Each field is marked with its location commented out and is easy to identify a particular field
	The settings group on this utility lets you to play with the divisor to arrive at the field location, try everything and stick with what works for you

Q13: What are the limitations of xml2bnf utility?

	1. The locations and size of the fields are not perfect
	2. The STRFILLIN is calculated with respect to the width, but you can manually edit the skill code
	3. The input fields only supports STRING type, you have to manually edit the skill code if you want decimal/float only fields
	4. The POP menu for GRID is still under development
	5. The List View is by default Multi-Select

Q14: What fields are supported?

	Input, Text, Progress Bar, Track Bar, Grid, Tree View, List View, Group, Tabs, Buttons, Radio button, Check Box

Q15: I want that particular feature?

	Please post your request on the cadence forum and I will see what I can do on my spare time

Q16: Can I customize the length/width/location of the fields?

	You can edit the Perl Source and tweak the divisor
	It currently uses divide by 7 on x locations and divide by 10.5 on y locations
	These numbers work fine for me, but you can use anything to suite you

Q17: How the original form compares to the Allegro Form?


Q18: What are the Command line options and what do they mean?

	I am working on the enabling FLEX options on the form

Q19: What are the future plans?

	Include support for other fields and field options

Q20: What are the mappings from KODA to Allegro Controls?

	KODA Control	ALLEGRO BNF Control
	TAForm      	Form Field
	TATab       	Tab Field
	TAGroup     	Group Field
	TAButton    	Button Field
	TAInput     	Input String Field
	TALabel     	Text Field
	TACombo     	ENUM Field, POP is derived from list defined on KODA control
	TARadio     	Radio Button field
	TACheckBox  	Check Box field
	TAProgress  	Progress Bar Field
	TASlider    	Track Bar Field
	TAList		List Field- Default Multi-Select
	TAListView  	GRID- Will create columns w.r.to the definitions in KODA control
	TATreeView  	Treeview Field

");


$tl->Button(-text => 'Close',
	-command => sub {$tl->withdraw })->pack;
  }
  else {
    $tl->deiconify;
    $tl->raise;
  }
  
}
sub _do_xml2bnf {
&CreateTmpXML;  
open Form_IL_Write, '>', $_ILFName or die "Can't write new file: $!";
my $xp = XML::XPath->new(filename => $tmp);
&formInitialize($xp);
&MainFormFunction($xp);
&formWrite($xp);
&formAction($xp);
&gridFunc($xp);
close Form_IL_Write;
print "\n\nCreated the Skill Output \"$_ILFName\n";
print "Run the following commands in Allegro :\n\nskill load \"$_ILFName\"\nmy_form\n\n";
$MW -> messageBox(-type=>"ok", -message=>"\n\nCreated the Skill Output \"$_ILFName	\n\nRun the following commands in Allegro :\n\nskill load \"$_ILFName\"\nmy_form\n\n");
}



$tmp->seek( 0, SEEK_END );
$fh->unlink_on_destroy( 1 );