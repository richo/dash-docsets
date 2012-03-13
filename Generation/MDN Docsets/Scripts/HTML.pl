$relativeInside = "developer.mozilla.org/en/";
$relativePath = "Documents/".$relativeInside;
$relativeHTMLPath = $relativePath."HTML/";
$htmlPath = $relativeHTMLPath."Element.html";
$relativeSVGPath = $relativePath."SVG/";
$svgPath = $relativeSVGPath."Element.html";

use HTML::TagParser;

open(TOKENS, ">Tokens.xml");

print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

$dom = HTML::TagParser->new();
$dom->open($htmlPath);
@elems = $dom->getElementsByAttribute("rel", "custom");

foreach $elem (@elems) 
{
	if((lc $elem->tagName()) eq "a" && (substr (lc $elem->getAttribute("href"), 0, 9)) =~ /element\//i)
	{
		$name = $elem->innerText;
		$name =~ s/<//;
		$name =~ s/>//;
		$href = $elem->getAttribute("href");

		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $elem->innerText."->".$elem->getAttribute("href")."\n";
			print TOKENS "<File path=\"".$relativeInside."HTML/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/cl/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

=svg comment

$dom = HTML::TagParser->new();
$dom->open($svgPath);
@elems = $dom->getElementsByAttribute("rel", "custom");

foreach $elem (@elems) 
{
	if((lc $elem->tagName()) eq "a" && (substr (lc $elem->getAttribute("href"), 0, 9)) =~ /element\//i)
	{
		$name = $elem->innerText;
		$name =~ s/<//;
		$name =~ s/>//;
		$href = $elem->getAttribute("href");

		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $elem->innerText."->".$elem->getAttribute("href")."\n";
			print TOKENS "<File path=\"".$relativeInside."SVG/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/cl/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

=cut

print TOKENS "</Tokens>";
close(TOKENS);
