$relativeInside = "developer.mozilla.org/en/";
$relativePath = "Documents/".$relativeInside;
$relativeXULPath = $relativePath."XUL/";
$xulPath = $relativePath."XUL_Reference.html";
$methodPath = $relativeXULPath."Method.html";
$propertyPath = $relativeXULPath."Property.html";
$attributePath = $relativeXULPath."Attribute.html";
$stylePath = $relativeXULPath."Style.html";

use HTML::TagParser;

open(TOKENS, ">Tokens.xml");
print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

$dom = HTML::TagParser->new();
$dom->open($xulPath);
@elems = $dom->getElementsByAttribute("rel", "internal");

foreach $elem (@elems) 
{
	$href = $elem->getAttribute("href");
	if((lc $elem->tagName()) eq "a" && !($href =~ "#") && (substr (lc $href, 0, 5) =~ /xul\//i))
	{
		$name = $elem->getAttribute("href");
		$name =~ s/<//g;
		$name =~ s/>//g;
		$name =~ s/.html//g;
		$name =~ s/_//g;
		$name =~ s/XUL\///;
		if($name eq "Style" || $name eq "Method" || $name eq "Attribute" || $name eq "Property" || length($name) <= 0)
		{
			next;
		}
		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $name."->".$href."\n";
			print TOKENS "<File path=\"".$relativeInside.$href."\"><Token><TokenIdentifier>//apple_ref/cpp/cl/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}


$dom = HTML::TagParser->new();
$dom->open($attributePath);
@elems = $dom->getElementsByAttribute("rel", "internal");

foreach $elem (@elems) 
{
	$href = $elem->getAttribute("href");
	if((lc $elem->tagName()) eq "a" && !($href =~ "#") && (substr (lc $href, 0, 11) =~ /attribute\//i))
	{
		$name = $elem->innerText;
		$name =~ s/<//g;
		$name =~ s/>//g;
		$name =~ s/.html//g;
		$name =~ s/_//g;
		if(length($name) <= 0)
		{
			next;
		}
		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $name."->".$href."\n";
			print TOKENS "<File path=\"".$relativeInside."XUL/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/constant/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

$dom = HTML::TagParser->new();
$dom->open($propertyPath);
@elems = $dom->getElementsByAttribute("rel", "internal");

foreach $elem (@elems) 
{
	$href = $elem->getAttribute("href");
	if((lc $elem->tagName()) eq "a" && !($href =~ "#") && (substr (lc $href, 0, 11) =~ /property\//i))
	{
		$name = $elem->innerText;
		$name =~ s/<//g;
		$name =~ s/>//g;
		$name =~ s/.html//g;
		$name =~ s/_//g;
		if(length($name) <= 0)
		{
			next;
		}
		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $name."->".$href."\n";
			print TOKENS "<File path=\"".$relativeInside."XUL/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/instp/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

$dom = HTML::TagParser->new();
$dom->open($methodPath);
@elems = $dom->getElementsByAttribute("rel", "internal");

foreach $elem (@elems) 
{
	$href = $elem->getAttribute("href");
	if((lc $elem->tagName()) eq "a" && !($href =~ "#") && (substr (lc $href, 0, 11) =~ /method\//i))
	{
		$name = $elem->innerText;
		$name =~ s/<//g;
		$name =~ s/>//g;
		$name =~ s/.html//g;
		$name =~ s/_//g;
		if(length($name) <= 0)
		{
			next;
		}
		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $name."->".$href."\n";
			print TOKENS "<File path=\"".$relativeInside."XUL/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/clm/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

$dom = HTML::TagParser->new();
$dom->open($stylePath);
@elems = $dom->getElementsByTagName("a");

foreach $elem (@elems) 
{
	$href = $elem->getAttribute("href");
	$rel = lc $elem->getAttribute("rel");
	if($rel eq "custom" || $rel eq "internal" && (lc $elem->tagName()) eq "a" && !($href =~ "#") && (substr (lc $href, 0, 11) =~ /style\//i))
	{
		$name = $elem->innerText;
		$name =~ s/<//g;
		$name =~ s/>//g;
		$name =~ s/.html//g;
		$name =~ s/_//g;
		if(length($name) <= 0)
		{
			next;
		}
		$e = lc ($name.$href);
		if(!grep {$_ eq $e} @ADDED) 
		{
			$ADDED[++$#ADDED] = $e;
			print $name."->".$href."\n";
			print TOKENS "<File path=\"".$relativeInside."XUL/".$href."\"><Token><TokenIdentifier>//apple_ref/cpp/cl/".$name."</TokenIdentifier></Token></File>\n";
		}
	}
}

print TOKENS "</Tokens>";
close(TOKENS);
