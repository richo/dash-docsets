$docPath = "/Users/bogdan/Desktop/Corona/Contents/Resources/Documents/";

use HTML::TagParser;
use File::Find;
$| = 1;

open(TOKENS, ">Tokens.xml");
print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

find( \&parseHTML, $docPath);

print TOKENS "</Tokens>";
close(TOKENS);

sub parseHTML
{
	if(/\.html$/)
	{
		$file = "$File::Find::name$/";
		chomp($file);
		$dom = HTML::TagParser->new();
		$dom->open($file);
		$file =~ s/\/Users\/bogdan\/Desktop\/Corona\/Contents\/Resources\/Documents\///;
		@titles = $dom->getElementsByClassName("title clear");
		
		foreach $title(@titles)
		{
			if($title->tagName =~ /h2/i)
			{
				$title = $title->innerText();
				$title =~ s/\(( )*\)/\(\)/g;
				$title =~ s/ \*iOS only\*//;
				$title =~ s/ \*\*old\*\*//;
				if($title =~ / /)
				{
					print "Ignored: ".$title."\n";
					return;
				}
				if(!($title =~ /\./ || $title =~ /_/ || $title =~ /\(\)/ || $title =~ /:/ || $title =~ /sqlite3/i || $title =~ /memoryWarning/))
				{
					print "Ignored dot: ".$title."\n";
					return;
				}
				$type = "clconst";
				if($title =~ /\(/ && $title =~ /\)/)
				{
					$type = "func";
				}
				if(!grep {$_ eq $title.$type} @ADDED) 
				{
					$ADDED[++$#ADDED] = $title.$type;
				}
				else
				{
					#print "DUPLICATE FOUND FOR $title at $file\n";
					return;
				}
				print "$title -> $type\n";
				print TOKENS "<File path=\"".$file."\"><Token><TokenIdentifier>//apple_ref/cpp/".$type."/".$title."</TokenIdentifier></Token></File>\n";
			}
		}
	}
}