<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <!-- This stylesheet removes anchors (Lueger and Roell specific) and gives ref[@type='image'] their updated figure targets -->

    <xsl:template match="tei:anchor"/>
    <xsl:template match="tei:sense/text()"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:entry//tei:ref[@type = 'image']">
        <xsl:variable name="id" select='translate(./@target, "#", "")'/>
        <xsl:variable name="id2" select=".//text()"/>
        <xsl:variable name="fig"
            select="./ancestor::tei:entry//tei:anchor[./@xml:id = $id]/following-sibling::tei:figure[1]/@xml:id"/>
        <xsl:choose>
            <xsl:when test="empty($fig)">
                <xsl:variable name="fig"
                    select="./ancestor::tei:sense//tei:figure[contains(.//tei:head/text(), $id2)]/@xml:id"/>
                <xsl:choose>

                    <xsl:when test="count($fig) > 1 or empty($fig)">
                        <xsl:variable name="fig"
                            select="./ancestor::tei:sense//tei:figure[contains(.//tei:head/text(), concat(' ', $id2, '.'))]/@xml:id"/>
                        <xsl:choose>
                            <xsl:when test="empty($fig) or count($fig) > 1">
                                <xsl:variable name="fig"
                                    select=".//tei:anchor[./@xml:id = $id]/following-sibling::tei:figure[1]/@xml:id"/>
                                <xsl:choose>
                                    <xsl:when test="count($fig) = 1">
                                        <ref type="figure" target="{concat('#', $fig)}">
                                            <xsl:apply-templates/>
                                        </ref>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="id2"
                                            select="concat(.//text(), substring(./following-sibling::text()[1], 1, 1))"/>
                                        <xsl:variable name="fig"
                                            select="./ancestor::tei:sense//tei:figure[contains(.//tei:head/text(), concat(' ', $id2, '.'))]/@xml:id"/>
                                        <xsl:choose>
                                            <xsl:when test="count($fig) = 1">
                                                <ref type="figure" target="{concat('#', $fig)}">
                                                  <xsl:apply-templates/>
                                                </ref>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <ref type="figure">
                                                  <xsl:apply-templates/>
                                                </ref>
                                            </xsl:otherwise>
                                        </xsl:choose>

                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:when>
                            <xsl:when test="count($fig) > 1">
                                <ref type="figure" target="{$fig[1]}">
                                    <xsl:apply-templates/>
                                </ref>
                            </xsl:when>
                            <xsl:otherwise>
                                <ref type="figure" target="{concat('#', $fig)}">
                                    <xsl:apply-templates/>
                                </ref>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:when>
                    <xsl:otherwise>
                        <ref type="figure" target="{concat('#', $fig)}">
                            <xsl:apply-templates/>
                        </ref>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <ref type="figure" target="{concat('#', $fig)}">
                    <xsl:apply-templates/>
                </ref>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
