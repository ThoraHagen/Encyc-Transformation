<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <!-- Script to shorten all ID names uniformly + final polish (remove whitespaces,
        transform multiple <def> tags to a single one containing <p>) -->

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- _____________remove whitespaces_____________ -->

    <xsl:template match="tei:sense/text()"/>
    <xsl:template match="tei:back/text()"/>
    <xsl:template match="tei:div/text()"/>

    <xsl:template match="tei:lb"/>


    <!-- _____________sort multiple <def> into paragraphs in one single <def>_____________ -->

    <xsl:template match="tei:sense[.//tei:def[preceding-sibling::tei:def]]">
        <sense xml:id="{generate-id()}">
            <def>
                <xsl:apply-templates/>
            </def>
        </sense>
    </xsl:template>

    <xsl:template match="tei:def[preceding-sibling::tei:def or following-sibling::tei:def]">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <!-- _____________unify ids_____________ -->

    <xsl:template
        match="
            doc('Brockhaus-1809.xml')//tei:entry | doc('Brockhaus-1837.xml')//tei:entry
            | doc('Brockhaus-1911.xml')//tei:entry | doc('Goetzinger-1885.xml')//tei:entry | doc('Hederich-1770.xml')//tei:entry
            | doc('Herder-1854.xml')//tei:entry | doc('Heiligenlex-1858.xml')//tei:entry | doc('Lemery-1721.xml')//tei:entry
            | doc('Roell-1912.xml')//tei:entry | doc('Meyers-1905.xml')//tei:entry
            | doc('Lueger-1904.xml')//tei:entry | doc('Sulzer-1771.xml')//tei:entry
            | doc('Wander-1867.xml')//tei:entry">

        <xsl:variable name="subid" select="substring-before(./@xml:id, '-001')"/>
        <xsl:variable name="subid" select="replace($subid, 'meyers', 'Meyers')"/>
        <xsl:variable name="app" select="substring-after(./@xml:id, '.xml')"/>
        <entry xml:id="{$subid}{$app}" xml:lang="de">
            <xsl:apply-templates/>
        </entry>
    </xsl:template>

    <xsl:template
        match="
            doc('Brockhaus-1809.xml')//tei:ref[@type = 'entry' and @target] |
            doc('Herder-1854.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Lueger-1904.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Roell-1912.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Sulzer-1771.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Wander-1867.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Meyers-1905.xml')//tei:ref[@type = 'entry' and @target]">
        <xsl:variable name="subid" select="substring-before(./@target, '-001')"/>
        <xsl:variable name="subid" select="replace($subid, 'meyers', 'Meyers')"/>
        <xsl:variable name="app" select="substring-after(./@xml:id, '.xml')"/>
        <ref type="entry" target="{$subid}{$app}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <xsl:template
        match="
            doc('DamenConvLex-1834.xml')//tei:entry | doc('Eisler-1904.xml')//tei:entry
            | doc('Eisler-1912.xml')//tei:entry | doc('Kirchner-Michaelis-1907.xml')//tei:entry
            | doc('Mauthner-1923.xml')//tei:entry | doc('Pagel-1901.xml')//tei:entry | doc('Pataky-1898.xml')//tei:entry
            | doc('Schmidt-1902.xml')//tei:entry | doc('Vollmer-1874.xml')//tei:entry">

        <xsl:variable name="subid" select="substring-before(./@xml:id, '.xml')"/>
        <xsl:variable name="app" select="substring-after(./@xml:id, '.xml')"/>
        <entry xml:id="{$subid}{$app}" xml:lang="de">
            <xsl:apply-templates/>
        </entry>
    </xsl:template>

    <xsl:template
        match="
            doc('DamenConvLex-1834.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Eisler-1904.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Eisler-1912.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Schmidt-1902.xml')//tei:ref[@type = 'entry' and @target]
            | doc('Vollmer-1874.xml')//tei:ref[@type = 'entry' and @target]">
        <xsl:variable name="subid" select="substring-before(./@target, '.xml')"/>
        <ref type="entry" target="{$subid}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

</xsl:stylesheet>
