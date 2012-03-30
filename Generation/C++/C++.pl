$xmlPath = "index-functions.xml";

use XML::DOM;
use File::Basename;
use LWPx::ParanoidAgent;
use File::Find;
use URI::Escape;
use HTML::TagParser;
use HTML::DOM;
$| = 1;

find(\&addAnchors, "C++/");

sub addAnchors
{
	if(/\.html$/)
	{
		$file = "$File::Find::name$/";
		chomp($file);
		$dom = new HTML::DOM;
		$file = "/Users/bogdan/Desktop/".$file;
		$dom->parse_file($file);
		@divs = $dom->getElementsByClassName("t-dcl-member-div");
		foreach $div(@divs) 
		{
			if($div->nodeName ne "DIV")
			{
				next;
			}
			$elems = $div->getElementsByTagName("a");
			$should_print = 0;
			if($elems->length <= 0)
			{
				$elems = $div->getElementsByTagName("div");
				$should_print = 1;
				if($elems->length <= 0)
				{
					print "Skipped for ".$div->innerHTML."\n";
					next;
				}
			}
			$elem = $elems->[0];
			$name = $elem->innerText;
			if(length($name) > 0)
			{
				$td = $div->parentNode;
				if($td->nodeName eq "TD")
				{
					$nextTD = $td->nextSibling;
					if(!defined($nextTD))
					{
						next;
					}
					$nextTD = $nextTD->nextSibling;
					if(defined($nextTD) && $nextTD->nodeName eq "TD")
					{
						$marks = $nextTD->getElementsByClassName("t-mark");
						$mark = $marks->[$marks->length-1];
						if(!defined($mark))
						{
							next;
						}
						
						if($mark->innerHTML =~ /member function/)
						{
							$type = "clm";
						}
						elsif($mark->innerHTML =~ /function/ || $mark->innerHTML =~ /keyword/ || $mark->innerHTML =~ /global object/)
						{
							$type = "func";
						}
						elsif($mark->innerHTML =~ /class/)
						{
							$type = "cl";
						}
						elsif($mark->innerHTML =~ /macro/)
						{
							$type = "macro";
						}
						elsif($mark->innerHTML =~ /typedef/)
						{
							$type = "tdef";
						}
						elsif($mark->innerHTML =~ /constant/)
						{
							$type = "clconst";
						}
						elsif($mark->innerHTML =~ /public member/)
						{
							$type = "instp";
						}
						elsif(!($mark->innerHTML =~ /concept/) && !($mark->innerHTML =~ /Since/i) && !($mark->innerHTML =~ /protected member/))
						{
							print $file."\n";
							print $elem->innerHTML."\n";
							print $mark->innerHTML."\n\n";
							next;
						}
						else
						{
							next;
						}
						$inner = $elem->innerHTML;
						$inner =~ s/ //g;
						$inner =~ s/<span(.*?)<\/span>//gi;
						@components = split(/<br>/, $inner);
						if($inner =~ /strongclass=\"selflink\">/)
						{
							next;
						}
						foreach $component(@components)
						{
							if($component =~ /</)
							{
								print "Mismatched tag found for $component in $file\n";
								break;
							}
							@members = split(/::/, $component);
							$member = $members[$#members];
							$member = uri_escape_utf8($member);

							$a = $dom->createElement("a");
							$a->setAttribute("name", "//apple_ref/cpp/".$type."/".uri_escape_utf8($member));
							$elem->parentNode->insertBefore($a, $elem);
							$a = $dom->createElement("a");
							$a->setAttribute("name", uri_escape_utf8($member));
							$elem->parentNode->insertBefore($a, $elem);
						}
					}
				}
			}
		}
		open(FILE, ">$file");
		print FILE $dom->innerHTML;
		close(FILE);
	}
}

open(TOKENS, ">Tokens.xml");
print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";
$parser = new XML::DOM::Parser;
$dom = $parser->parsefile($xmlPath);
@elems = $dom->getElementsByTagName("*");

foreach $elem(@elems) 
{
	$tag = $elem->getNodeName;
	$name = $elem->getAttribute("name");
	$type = $tag;
	if($tag ne "const" && $tag ne "function" && $tag ne "class" && $tag ne "enum" && $tag ne "typedef")
	{
		next;
	}
	$link = $elem->getAttribute("link");
	unless(length($link) > 0 && $link ne ".")
	{
		$link = "";
	}
	$parent = $elem->getParentNode;
	$parentName = $parent->getNodeName;
	if($parentName eq "class" || $parentName eq "enum")
	{
		if(length($link) <= 0)
		{
			$link = $parent->getAttribute("link")."/".$elem->getAttribute("name");
		}
		else
		{
			if($link ne ".")
			{
				$link = $parent->getAttribute("link")."/".$link;
			}
			else
			{
				$link = $parent->getAttribute("link");
			}
		}
		if($type eq "function")
		{
			$type = "clm";
		}
		elsif($type eq "const")
		{
			$type = "variable";
		}
		$name = $parent->getAttribute("name")."::".$name;
	}
	$alias = $elem->getAttribute("alias");
	if(length($link) <= 0 && length($alias) > 0)
	{
		@es = $dom->getElementsByTagName("*");
		foreach $e(@es)
		{
			$eName = $e->getNodeName;
			if($e->getAttribute("name") eq $alias && ($eName eq "class" || $eName eq "enum"))
			{
				$link = $e->getAttribute("link");
				break;
			}
		}
	}
	if(length($link) <= 0)
	{
		print "Could not get link for: $name\n";
	}
	$link =~ s/\s+/_/g;
	$link =~ s/:://g;
	$type = ($type eq "const") ? "macro" : $type;
	$type = ($type eq "variable") ? "clconst" : $type;
	$type = ($type eq "function") ? "func" : $type;
	$type = ($type eq "enum") ? "tdef" : $type;
	$type = ($type eq "typedef") ? "tdef" : $type;
	$type = ($type eq "class") ? "cl" : $type;
	if($type ne "macro" && $type ne "macro" && $type ne "func" && $type ne "tdef" && $type ne "cl" && $type ne "clm" && $type ne "clconst")
	{
		print "Unknown type found: $type\n";
	}
	$link = "output/en.cppreference.com/w/".$link;
	$initialLink = $link;
	$fullLink = "C++/Contents/Resources/Documents/".$link.".html";
	$altFullLink = "C++/Contents/Resources/Documents/".$link."html.html";
	while(!(-e $fullLink) && !(-e $altFullLink))
	{
		$urlLink = substr($link, 29, length($link)-29);
		$url = "http://en.cppreference.com/w/".$urlLink;
		$redir = "";
		$retryCount = 0;
		do
		{
			++$retryCount;
			sleep(1);
			$ua = LWPx::ParanoidAgent->new;
			$ua->timeout(15);
  			$req = HTTP::Request->new(GET => "$url");
			$res = $ua->request($req);
			if ($res->is_success) 
			{
				if($res->request->url() ne $url)
				{
					$redir = $res->request->url();
				}
			}
			elsif($res->code != 404)
			{
				#print $res->status_line." for $url\n";
			}
		} while($res->code == 500 && $retryCount < 5);

		if($retryCount >= 4)
		{
			print "LWP failed for $url\n";
		}

		($filename, $directory) = fileparse($link);
		
		if(length($redir) > 0)
		{
			$redir = substr($redir, 29, length($redir)-29);
			$link = "output/en.cppreference.com/w/".$redir;
			print $link."\n";
		}
		else
		{
			$chop = chop($directory);
			if($chop ne "/")
			{
				$directory .= $chop;
			}
			$link = $directory;
		}
		$fullLink = "C++/Contents/Resources/Documents/".$link.".html";
		$altFullLink = "C++/Contents/Resources/Documents/".$link."html.html";
	}
	if(!(-e $fullLink) && !(-e $altFullLink))
	{
		print "Couldn't find for $name";
	}
	else
	{
		if($initialLink ne $link)
		{
			#print "Initial: $initialLink\n";
			#print "Became: $link\n\n";
		}
		$link = (-e $fullLink) ? $link.".html" : $link."html.html";

		$e = lc ($name.$type.$link);
		if(!grep {$_ eq $e} @ADDED) 
		{
			@components = split(/::/, $name);
			$anchor = $components[$#components];
			$name =~ s/</&lt;/g;
			$name =~ s/>/&gt;/g;
			$name =~ s/&/&amp;/g;
			$name =~ s/"/&quot;/g;
			$ADDED[++$#ADDED] = $e;
			print TOKENS "<File path=\"".$link."\"><Token><TokenIdentifier>//apple_ref/cpp/".$type."/".$name."</TokenIdentifier><Anchor>".uri_escape_utf8($anchor)."</Anchor></Token></File>\n";
		}
		else
		{
			#print "Duplicate found: $e\n";
		}
	}
}

print TOKENS "</Tokens>";
close(TOKENS);
