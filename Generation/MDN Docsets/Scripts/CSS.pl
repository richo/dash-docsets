$relativeInside = "developer.mozilla.org/en/";
$relativePath = "Documents/".$relativeInside;
$relativeCSSPath = $relativePath."CSS/";
$cssPath = $relativeCSSPath."CSS_Reference.html";

use HTML::TagParser;

open(TOKENS, ">Tokens.xml");

print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

$dom = HTML::TagParser->new();
$dom->open($cssPath);
@elems = $dom->getElementsByAttribute("rel", "custom");

foreach $elem (@elems) 
{
	$href = $elem->getAttribute("href");
	if((lc $elem->tagName()) eq "a" && !($href =~ "#") && !($href =~ "developer.mozilla"))
	{
		$name = $elem->getAttribute("href");
		$name =~ s/<//g;
		$name =~ s/>//g;
		$name =~ s/.html//g;
		$name =~ s/_//g;

		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $name."->".$href."\n";
			print TOKENS "<File path=\"".$relativeInside."CSS/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/cl/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

print TOKENS "</Tokens>";
close(TOKENS);
