<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

	<xsl:template match="html">
		<xsl:apply-templates select="body"/>
	</xsl:template>


	<xsl:template match="body">
		<Tokens version="1.0">
			<xsl:apply-templates select="div"/>
		</Tokens>
	</xsl:template>


	<xsl:template match="div">
		<xsl:apply-templates select="dl"/>
	</xsl:template>
	
	<xsl:template match="dl">
		<xsl:apply-templates select="dt"/>
	</xsl:template>

	<xsl:template match="span">
		<xsl:variable name="ref-path" select="substring-after(a/@href, '..')" />
			<xsl:choose>
				<xsl:when test="contains(a/@href, '#')">
					<Path>api<xsl:value-of select="substring-before($ref-path, '#')" /></Path>
					<Anchor><xsl:value-of select="substring-after($ref-path, '#')" /></Anchor>
				</xsl:when>
				<xsl:otherwise>
					<Path>api<xsl:value-of select="$ref-path" /></Path>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<xsl:template match="dt">
		<Token>
			<TokenIdentifier>
				<xsl:variable name="symbol" select="a[position()=1]/b" />
				<xsl:variable name="span" select="span" />
				<Name>
					<xsl:choose>
						<xsl:when test="$span != ''"><xsl:value-of select="span" /></xsl:when>
						<xsl:otherwise><xsl:value-of select="a" /></xsl:otherwise>
					</xsl:choose>
				</Name>
				<Type>
					<xsl:choose>
						<xsl:when test="contains(., 'Class in')">cl</xsl:when>
						<xsl:when test="contains(., 'Static method in')">clm</xsl:when>
						<xsl:when test="contains(., 'Static variable in')">econst</xsl:when>
						<xsl:when test="contains(., 'Constructor')">clm</xsl:when>
						<xsl:when test="contains(., 'Method in class')">instm</xsl:when>
						<xsl:when test="contains(., 'Method in interface')">intfm</xsl:when>
						<xsl:when test="contains(., 'Method in')">clm</xsl:when>
						<xsl:when test="contains(., 'Variable in')">intfp</xsl:when>
						<xsl:when test="contains(., 'Interface in')">intf</xsl:when>
						<xsl:when test="contains(., 'Exception in')">cl</xsl:when>
						<xsl:when test="contains(., 'Error in')">cl</xsl:when>
						<xsl:when test="contains(., 'Enum in')">cl</xsl:when>
						<xsl:otherwise>clm</xsl:otherwise>
					</xsl:choose>
				</Type>
				<Scope>
					<xsl:value-of select="a[position()=last()]" />
				</Scope>
				<APILanguage>java</APILanguage>
			</TokenIdentifier>
				<xsl:variable name="span" select="span" />
				<xsl:variable name="ref-path" select="substring-after(a/@href, '..')" />
					<xsl:choose>
						<xsl:when test="$span != ''"><xsl:apply-templates select="span"/></xsl:when>
						<xsl:otherwise><Path>api<xsl:value-of select="$ref-path" /></Path></xsl:otherwise>
					</xsl:choose>
</Token>
	</xsl:template>
</xsl:stylesheet>