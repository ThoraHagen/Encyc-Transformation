<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:entry[not(.//tei:term/text() eq 'Austern')]//tei:note[@type = 'footnote']"/>

    <xsl:template match="tei:sense[not(./ancestor::tei:entry//tei:term/text() eq 'Austern')]">
        <sense xml:id="{./@xml:id}">
            <def>
                <xsl:for-each select="./tei:def">
                    <xsl:apply-templates/>
                </xsl:for-each>
                <note>
                    <xsl:for-each select="./tei:note[@type = 'footnote']">
                        <xsl:variable name="apos">'</xsl:variable>
                        <xsl:variable name="id" select="translate(./@xml:id, $apos, '')"/>
                        <note type="footnote" xml:id="{translate($id, '.', '')}">
                            <xsl:apply-templates/>
                        </note>
                    </xsl:for-each>
                </note>
            </def>
        </sense>
    </xsl:template>
    
    <xsl:template match='tei:ref[@type="footnote"]'>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="target" select="translate(./@target, $apos, '')"/>
        <ref type='footnote' target="{translate($target, '.', '')}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

</xsl:stylesheet>
