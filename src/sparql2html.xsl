<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:s="http://www.w3.org/2005/sparql-results#">
	
	<xsl:output	method="html" indent="yes"/>
	
	<xsl:template match="s:sparql">
		<html>
			<head>
				<title>SPARQL Results</title>
			</head>
			<body>
				<h1>SPARQL Results</h1>
				<table border="1">
					<tbody>
						<xsl:apply-templates/>
					</tbody>
					</table>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="s:head">
		<tr>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>

	<xsl:template match="s:variable">
		<th>
			<xsl:value-of select="@name"/>
		</th>	
	</xsl:template>
	
	<xsl:template match="s:result">
		<tr>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>
	
	<xsl:template match="s:binding">
		<td>
			<xsl:value-of select="s:literal"/>
		</td>
	</xsl:template>
	
	<!-- don't pass any other text through -->
	<xsl:template match="text()|@*">
	</xsl:template>
	
</xsl:stylesheet>

