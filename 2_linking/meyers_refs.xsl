<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <!-- Simple stylesheet to sort ref targets from linked Meyers into appendix refs and entry refs 
         when more than one target is found (always exactly one entry- and one app ref)-->
    <!-- used after link_entries -->

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="contains(./@target, ' ')">
                <xsl:variable name="app_sign">»</xsl:variable>
                <xsl:choose>
                    <xsl:when test="starts-with(./text(), $app_sign)">
                        <xsl:variable name="app" select="substring-after(./@target, ' ')"/>
                        <ref type="appendix" target="#{$app}">
                            <xsl:apply-templates/>
                        </ref>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="entry" select="substring-before(./@target, ' ')"/>
                        <ref type="entry" target="{$entry}">
                            <xsl:apply-templates/>
                        </ref>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <ref type="entry" target="{./@target}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:ref[@target eq '#']" priority="2">
        <ref type="entry">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>
</xsl:stylesheet>
