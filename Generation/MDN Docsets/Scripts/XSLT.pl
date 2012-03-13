$relativeInside = "developer.mozilla.org/en/";
$relativePath = "Documents/".$relativeInside;
$relativeXSLTPath = $relativePath."XSLT/";
$xsltPath = $relativeXSLTPath."Elements.html";

use HTML::TagParser;

open(TOKENS, ">Tokens.xml");

print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

$dom = HTML::TagParser->new();
$dom->open($xsltPath);
@elems = $dom->getElementsByAttribute("rel", "internal");

foreach $elem (@elems) 
{
	$href = $elem->getAttribute("href");
	$name = $elem->innerText;
	$name =~ s/<//g;
	$name =~ s/>//g;
	$name =~ s/.html//g;
	$name =~ s/_//g;
	if((lc $elem->tagName()) eq "a" && !($href =~ "#") && !($href =~ "developer.mozilla") && (substr (lc $name, 0, 4) =~ /xsl:/i))
	{
		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $name."->".$href."\n";
			print TOKENS "<File path=\"".$relativeInside."XSLT/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/cl/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

print TOKENS "</Tokens>";
close(TOKENS);
