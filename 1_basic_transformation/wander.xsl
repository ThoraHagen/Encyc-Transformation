<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:def[.//tei:ref[@type='temp']]">
        <note type='footnote' xml:id="{.//tei:ref/@xml:id}">
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    
    <xsl:template match="tei:ref[@type='temp']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:def[not(child::*)]"/>
</xsl:stylesheet>
