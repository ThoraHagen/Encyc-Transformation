<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:import href="import_rules.xsl"/>
    <xsl:import href="preface.xsl"/>

    <!-- ________________________Basic TEI Structure________________________ -->

    <xsl:template match="/">
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:value-of select="//META/DEFSERVER/TITLE"/>
                        </title>
                        <author>
                            <xsl:value-of select="/doc//div[@class = 'zenoCOTitles']/h3[1]"/>
                        </author>
                    </titleStmt>
                    <publicationStmt>
                        <publisher/>
                        <date>
                            <xsl:value-of select="/doc/META/DEFSERVER/YEARS"/>
                        </date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl>
                            <xsl:for-each select="/doc/META/DEFBOOK/BOOKCITE">
                                <title>
                                    <xsl:apply-templates/>
                                </title>
                                <figure>
                                    <xsl:variable name="cover"
                                        select="./parent::DEFBOOK/BOOKTITLEFACS"/>
                                    <graphic url="{$cover}"/>
                                </figure>
                            </xsl:for-each>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <front>
                    <div type="mainpage">
                        <div type="title">
                            <figure>
                                <xsl:variable name="cover"
                                    select=".//articlegroup[@name = '-']//image/@src"/>
                                <graphic url="{$cover}"/>
                            </figure>
                            <xsl:for-each
                                select="//articlegroup[@name = '-']//h1 | //articlegroup[@name = '-']//h2 | //articlegroup[@name = '-']//h3 | //articlegroup[@name = '-']//h4">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </div>
                        <xsl:for-each select="//articlegroup[@name = '-']//text//p">
                            <div type="note">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </div>
                        </xsl:for-each>
                    </div>
                    <div type="preface">
                        <xsl:for-each select="//articlegroup[@name = 'M']/article">
                            <xsl:apply-templates mode="preface"/>
                        </xsl:for-each>
                    </div>
                </front>
                <body>
                    <div>
                        <xsl:apply-templates/>
                    </div>
                </body>
                <back> </back>
            </text>
        </TEI>
    </xsl:template>

    <!-- ________________________first <b> is the headword________________________ -->
    <xsl:template match="article/text/p[1]/b[not(preceding-sibling::*)]">
        <term type="headword">
            <hi rend="bold">
                <xsl:apply-templates/>
            </hi>
        </term>
    </xsl:template>

    <!-- ________________________first <spa> might also be the headword________________________ -->
    <xsl:template match="articlegroup[@name = 'A']/article/text/p[1]/spa[1]">
        <xsl:variable name="term" select="./ancestor::article/lem/text()"/>
        <xsl:choose>
            <xsl:when test="contains($term, .)">
                <term type="headword">
                    <hi rend="spaced">
                        <xsl:apply-templates/>
                    </hi>
                </term>
            </xsl:when>
            <xsl:otherwise>
                <hi rend="spaced">
                    <xsl:apply-templates/>
                </hi>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
