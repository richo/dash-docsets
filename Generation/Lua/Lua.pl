$indexPath = "/Users/bogdan/Desktop/Lua/Contents/Resources/Documents/www.lua.org/manual/5.2/index.html";
$manualPath = "www.lua.org/manual/5.2/manual.html";

use HTML::TagParser;
$| = 1;

open(TOKENS, ">Tokens.xml");
print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

$dom = HTML::TagParser->new();
$dom->open($indexPath);
@anchors = $dom->getElementsByTagName("a");

foreach $anchor(@anchors)
{
	$link = $anchor->getAttribute("href");
	if($link =~ /manual.html\#pdf-/)
	{
		$link =~ s/manual.html\#//;
		$title = $anchor->innerText();
		$type = "func";
		if(!grep {$_ eq $title.$type} @ADDED) 
		{
			$ADDED[++$#ADDED] = $title.$type;
		}
		else
		{
			#print "DUPLICATE FOUND FOR $title at $file\n";
			return;
		}
		#print "$title -> $type\n";
		print TOKENS "<File path=\"".$manualPath."\"><Token><TokenIdentifier>//apple_ref/cpp/".$type."/".$title."</TokenIdentifier><Anchor>".$link."</Anchor></Token></File>\n";
	}
}

print TOKENS "</Tokens>";
close(TOKENS);

